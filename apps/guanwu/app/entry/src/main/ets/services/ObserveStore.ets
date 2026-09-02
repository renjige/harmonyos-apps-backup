import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { ObserveRecord, UserProfile } from '../models/ObserveModels'
import { DateHelper } from './DateHelper'
import { ImagePathUtil } from './ImagePathUtil'

const STORE = 'guanwu_observe_v1'
const KEY_NOTES = 'records'
const KEY_PROFILE = 'profile'
const KEY_REMINDER_AGENT = 'reminder_agent_id'

export class ObserveStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ObserveStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ObserveStore.pref = null
    }
  }

  static async loadAll(): Promise<ObserveRecord[]> {
    const raw = await ObserveStore.getString(KEY_NOTES, '')
    return ObserveStore.parseRecords(raw)
  }

  static async findById(id: string): Promise<ObserveRecord | undefined> {
    const list = await ObserveStore.loadAll()
    for (const n of list) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static async notesForDate(dateKey: string): Promise<ObserveRecord[]> {
    const list = await ObserveStore.loadAll()
    const out: ObserveRecord[] = []
    for (const n of list) {
      if (n.dateKey === dateKey) {
        out.push(n)
      }
    }
    out.sort((a, b) => b.createdAt - a.createdAt)
    return out
  }

  static async notesInRange(startKey: string, endKey: string): Promise<ObserveRecord[]> {
    const list = await ObserveStore.loadAll()
    const out: ObserveRecord[] = []
    for (const n of list) {
      if (n.dateKey >= startKey && n.dateKey <= endKey) {
        out.push(n)
      }
    }
    return out
  }

  static async addRecord(record: ObserveRecord): Promise<boolean> {
    const trimmed = record.content.trim()
    if (trimmed.length === 0 || trimmed.length > 800) {
      return false
    }
    if (record.kind.length === 0) {
      return false
    }
    record.content = trimmed
    record.updatedAt = Date.now()
    record.imagePaths = ObserveStore.normalizeImagePaths(record.imagePaths)
    const list = await ObserveStore.loadAll()
    list.push(record)
    list.sort((a, b) => b.createdAt - a.createdAt)
    await ObserveStore.persist(list)
    return true
  }

  static async updateRecord(record: ObserveRecord): Promise<boolean> {
    const trimmed = record.content.trim()
    if (trimmed.length === 0 || trimmed.length > 800) {
      return false
    }
    const list = await ObserveStore.loadAll()
    let found = false
    for (const n of list) {
      if (n.id === record.id) {
        n.kind = record.kind
        n.subtypeKey = record.subtypeKey
        n.content = trimmed
        n.imagePaths = ObserveStore.normalizeImagePaths(record.imagePaths)
        n.updatedAt = Date.now()
        n.categoryKey = record.categoryKey
        n.subjectId = record.subjectId
        n.tags = record.tags
        n.favorited = record.favorited
        n.itemName = record.itemName
        found = true
      }
    }
    if (!found) {
      return false
    }
    await ObserveStore.persist(list)
    return true
  }

  static async deleteRecord(id: string): Promise<void> {
    const list = await ObserveStore.loadAll()
    const next: ObserveRecord[] = []
    for (const n of list) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    await ObserveStore.persist(next)
  }

  static async search(keyword: string): Promise<ObserveRecord[]> {
    const q = keyword.trim()
    const list = await ObserveStore.loadAll()
    if (q.length === 0) {
      return list
    }
    const out: ObserveRecord[] = []
    for (const n of list) {
      if (n.content.indexOf(q) >= 0 || n.kindLabel().indexOf(q) >= 0 || n.subtypeLabel().indexOf(q) >= 0 ||
        n.itemName.indexOf(q) >= 0 || n.tags.indexOf(q) >= 0 || n.categoryKey.indexOf(q) >= 0) {
        out.push(n)
      }
    }
    return out
  }

  static async filterByKind(kind: string): Promise<ObserveRecord[]> {
    const list = await ObserveStore.loadAll()
    if (kind.length === 0 || kind === 'all') {
      return list
    }
    const out: ObserveRecord[] = []
    for (const n of list) {
      if (n.kind === kind) {
        out.push(n)
      }
    }
    return out
  }

  static async filterByCategory(categoryKey: string): Promise<ObserveRecord[]> {
    const list = await ObserveStore.loadAll()
    if (categoryKey.length === 0 || categoryKey === 'all') {
      return list
    }
    const out: ObserveRecord[] = []
    for (const n of list) {
      if (n.categoryKey === categoryKey) {
        out.push(n)
      }
    }
    return out
  }

  static async filterFavorites(): Promise<ObserveRecord[]> {
    const list = await ObserveStore.loadAll()
    const out: ObserveRecord[] = []
    for (const n of list) {
      if (n.favorited) {
        out.push(n)
      }
    }
    return out
  }

  static async notesForSubject(subjectId: string): Promise<ObserveRecord[]> {
    const list = await ObserveStore.loadAll()
    const out: ObserveRecord[] = []
    if (subjectId.length === 0) {
      return out
    }
    for (const n of list) {
      if (n.subjectId === subjectId) {
        out.push(n)
      }
    }
    out.sort((a, b) => a.createdAt - b.createdAt)
    return out
  }

  static async toggleFavorite(id: string): Promise<boolean> {
    const list = await ObserveStore.loadAll()
    let found = false
    for (const n of list) {
      if (n.id === id) {
        n.favorited = !n.favorited
        n.updatedAt = Date.now()
        found = true
      }
    }
    if (!found) {
      return false
    }
    await ObserveStore.persist(list)
    return true
  }

  static async streakDays(): Promise<number> {
    const list = await ObserveStore.loadAll()
    const set = new Set<string>()
    for (const n of list) {
      set.add(n.dateKey)
    }
    let streak = 0
    const cursor = new Date()
    while (true) {
      const key = DateHelper.keyFromDate(cursor)
      if (!set.has(key)) {
        if (streak === 0 && key === DateHelper.todayKey()) {
          cursor.setDate(cursor.getDate() - 1)
          continue
        }
        break
      }
      streak++
      cursor.setDate(cursor.getDate() - 1)
      if (streak > 400) {
        break
      }
    }
    return streak
  }

  static async uniqueDays(): Promise<number> {
    const list = await ObserveStore.loadAll()
    const set = new Set<string>()
    for (const n of list) {
      set.add(n.dateKey)
    }
    return set.size
  }

  static async loadProfile(): Promise<UserProfile> {
    const raw = await ObserveStore.getString(KEY_PROFILE, '')
    if (raw.length === 0) {
      return new UserProfile()
    }
    const parts = raw.split('\t')
    const p = new UserProfile()
    if (parts.length >= 1 && parts[0].length > 0) {
      p.nickname = parts[0]
    }
    if (parts.length >= 2 && parts[1].length > 0) {
      p.signature = parts[1]
    }
    if (parts.length >= 3) {
      p.reminderHour = parseInt(parts[2], 10)
    }
    if (parts.length >= 4) {
      p.reminderMinute = parseInt(parts[3], 10)
    }
    if (parts.length >= 5) {
      p.reminderEnabled = parts[4] === '1'
    }
    if (parts.length >= 6 && parts[5].length > 0) {
      p.themeMode = parts[5]
    }
    return p
  }

  static async saveProfile(profile: UserProfile): Promise<void> {
    const enabled = profile.reminderEnabled ? '1' : '0'
    const nick = profile.nickname.replace(/\t/g, ' ')
    const sig = profile.signature.replace(/\t/g, ' ')
    const line = `${nick}\t${sig}\t${profile.reminderHour}\t${profile.reminderMinute}\t${enabled}\t${profile.themeMode}`
    await ObserveStore.putString(KEY_PROFILE, line)
  }

  static async clearAllRecords(): Promise<void> {
    await ObserveStore.putString(KEY_NOTES, '')
  }

  static async saveReminderAgentId(id: number): Promise<void> {
    await ObserveStore.putString(KEY_REMINDER_AGENT, `${id}`)
  }

  static async loadReminderAgentId(): Promise<number> {
    const raw = await ObserveStore.getString(KEY_REMINDER_AGENT, '0')
    return parseInt(raw, 10)
  }

  static async exportJson(): Promise<string> {
    const list = await ObserveStore.loadAll()
    const profile = await ObserveStore.loadProfile()
    const lines: string[] = []
    lines.push('{')
    lines.push(`"app":"观物",`)
    lines.push(`"exportedAt":${Date.now()},`)
    lines.push(`"nickname":"${ObserveStore.esc(profile.nickname)}",`)
    lines.push('"records":[')
    for (let i = 0; i < list.length; i++) {
      const n = list[i]
      lines.push('{')
      lines.push(`"id":"${n.id}",`)
      lines.push(`"dateKey":"${n.dateKey}",`)
      lines.push(`"kind":"${n.kind}",`)
      lines.push(`"subtypeKey":"${n.subtypeKey}",`)
      lines.push(`"content":"${ObserveStore.esc(n.content)}",`)
      lines.push(`"createdAt":${n.createdAt}`)
      lines.push(i < list.length - 1 ? '},' : '}')
    }
    lines.push(']')
    lines.push('}')
    return lines.join('')
  }

  private static esc(text: string): string {
    return text.replace(/\\/g, '\\\\').replace(/"/g, '\\"')
  }

  private static async persist(items: ObserveRecord[]): Promise<void> {
    const lines: string[] = []
    for (const n of items) {
      lines.push(ObserveStore.serialize(n))
    }
    await ObserveStore.putString(KEY_NOTES, lines.join('\n'))
  }

  private static normalizeImagePaths(paths: string[]): string[] {
    const out: string[] = []
    for (const p of paths) {
      const normalized = ImagePathUtil.normalizeStored(p)
      if (normalized.length > 0) {
        out.push(normalized)
      }
    }
    return out
  }

  private static serialize(n: ObserveRecord): string {
    const text = n.content.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const images = n.imagePaths.join('|')
    const fav = n.favorited ? '1' : '0'
    const item = n.itemName.replace(/\t/g, ' ')
    const tags = n.tags.replace(/\t/g, ',')
    return [n.id, n.dateKey, n.kind, n.subtypeKey, text, images, `${n.createdAt}`, `${n.updatedAt}`,
      n.categoryKey, n.subjectId, tags, fav, item].join('\t')
  }

  private static parseRecords(raw: string): ObserveRecord[] {
    const out: ObserveRecord[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 7) {
        continue
      }
      const n = new ObserveRecord()
      n.id = parts[0]
      n.dateKey = parts[1]
      n.kind = parts[2]
      n.subtypeKey = parts[3]
      n.content = parts[4]
      if (parts[5].length > 0) {
        n.imagePaths = ObserveStore.normalizeImagePaths(parts[5].split('|'))
      }
      n.createdAt = parseInt(parts[6], 10)
      n.updatedAt = parts.length >= 8 ? parseInt(parts[7], 10) : n.createdAt
      n.categoryKey = parts.length >= 9 && parts[8].length > 0 ? parts[8] : 'nature'
      n.subjectId = parts.length >= 10 ? parts[9] : ''
      n.tags = parts.length >= 11 ? parts[10] : ''
      n.favorited = parts.length >= 12 && parts[11] === '1'
      n.itemName = parts.length >= 13 ? parts[12] : ''
      out.push(n)
    }
    out.sort((a, b) => b.createdAt - a.createdAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ObserveStore.pref === null) {
      return fallback
    }
    try {
      const v = await ObserveStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ObserveStore.pref === null) {
      return
    }
    try {
      await ObserveStore.pref.put(key, value)
      await ObserveStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
