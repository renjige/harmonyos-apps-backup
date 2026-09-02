import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { EmotionOption, ObservationNote, UserProfile } from '../models/ObservationModels'
import { DateHelper } from './DateHelper'

const STORE = 'ximan_observation_v1'
const KEY_NOTES = 'notes'
const KEY_PROFILE = 'profile'
const KEY_REMINDER_AGENT = 'reminder_agent_id'

export class ObservationStore {
  private static pref: preferences.Preferences | null = null
  static readonly DAILY_LIMIT: number = 3

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ObservationStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ObservationStore.pref = null
    }
  }

  static async loadAll(): Promise<ObservationNote[]> {
    const raw = await ObservationStore.getString(KEY_NOTES, '')
    return ObservationStore.parseNotes(raw)
  }

  static async notesForDate(dateKey: string): Promise<ObservationNote[]> {
    const list = await ObservationStore.loadAll()
    const out: ObservationNote[] = []
    for (const n of list) {
      if (n.dateKey === dateKey) {
        out.push(n)
      }
    }
    out.sort((a, b) => b.createdAt - a.createdAt)
    return out
  }

  static async todayCount(): Promise<number> {
    const today = await ObservationStore.notesForDate(DateHelper.todayKey())
    return today.length
  }

  static async canAddToday(): Promise<boolean> {
    const count = await ObservationStore.todayCount()
    return count < ObservationStore.DAILY_LIMIT
  }

  static async addNote(text: string, emotionKey: string): Promise<boolean> {
    const trimmed = text.trim()
    if (trimmed.length === 0 || trimmed.length > 50) {
      return false
    }
    if (!(await ObservationStore.canAddToday())) {
      return false
    }
    const em = EmotionOption.find(emotionKey)
    const note = ObservationNote.createNew(DateHelper.todayKey())
    note.text = trimmed
    note.emotionKey = em !== undefined ? em.key : 'calm'
    note.emotionLabel = em !== undefined ? em.label : '平静'
    const list = await ObservationStore.loadAll()
    list.push(note)
    list.sort((a, b) => b.createdAt - a.createdAt)
    await ObservationStore.persistNotes(list)
    return true
  }

  static async updateNote(id: string, text: string, emotionKey: string): Promise<boolean> {
    const trimmed = text.trim()
    if (trimmed.length === 0 || trimmed.length > 50) {
      return false
    }
    const em = EmotionOption.find(emotionKey)
    const list = await ObservationStore.loadAll()
    let found = false
    for (const n of list) {
      if (n.id === id) {
        n.text = trimmed
        n.emotionKey = em !== undefined ? em.key : n.emotionKey
        n.emotionLabel = em !== undefined ? em.label : n.emotionLabel
        found = true
      }
    }
    if (!found) {
      return false
    }
    await ObservationStore.persistNotes(list)
    return true
  }

  static async deleteNote(id: string): Promise<void> {
    const list = await ObservationStore.loadAll()
    const next: ObservationNote[] = []
    for (const n of list) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    await ObservationStore.persistNotes(next)
  }

  static async notesInRange(startKey: string, endKey: string): Promise<ObservationNote[]> {
    const list = await ObservationStore.loadAll()
    const out: ObservationNote[] = []
    for (const n of list) {
      if (n.dateKey >= startKey && n.dateKey <= endKey) {
        out.push(n)
      }
    }
    return out
  }

  static async loadProfile(): Promise<UserProfile> {
    const raw = await ObservationStore.getString(KEY_PROFILE, '')
    if (raw.length === 0) {
      return new UserProfile()
    }
    const parts = raw.split('\t')
    const p = new UserProfile()
    if (parts.length >= 1) {
      p.nickname = parts[0]
    }
    if (parts.length >= 2) {
      p.avatarKey = parts[1]
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
    const line =
      `${profile.nickname}\t${profile.avatarKey}\t${profile.reminderHour}\t${profile.reminderMinute}\t${enabled}\t${profile.themeMode}`
    await ObservationStore.putString(KEY_PROFILE, line)
  }

  static async clearAllNotes(): Promise<void> {
    await ObservationStore.putString(KEY_NOTES, '')
  }

  static async saveReminderAgentId(id: number): Promise<void> {
    await ObservationStore.putString(KEY_REMINDER_AGENT, `${id}`)
  }

  static async loadReminderAgentId(): Promise<number> {
    const raw = await ObservationStore.getString(KEY_REMINDER_AGENT, '0')
    return parseInt(raw, 10)
  }

  static async findById(id: string): Promise<ObservationNote | undefined> {
    const list = await ObservationStore.loadAll()
    for (const n of list) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static async exportJson(): Promise<string> {
    const list = await ObservationStore.loadAll()
    const profile = await ObservationStore.loadProfile()
    const lines: string[] = []
    lines.push('{')
    lines.push(`"exportedAt":${Date.now()},`)
    lines.push(`"nickname":"${profile.nickname.replace(/"/g, '\\"')}",`)
    lines.push('"notes":[')
    for (let i = 0; i < list.length; i++) {
      const n = list[i]
      const text = n.text.replace(/\\/g, '\\\\').replace(/"/g, '\\"')
      lines.push('{')
      lines.push(`"id":"${n.id}",`)
      lines.push(`"dateKey":"${n.dateKey}",`)
      lines.push(`"text":"${text}",`)
      lines.push(`"emotionKey":"${n.emotionKey}",`)
      lines.push(`"emotionLabel":"${n.emotionLabel}",`)
      lines.push(`"createdAt":${n.createdAt}`)
      lines.push(i < list.length - 1 ? '},' : '}')
    }
    lines.push(']')
    lines.push('}')
    return lines.join('')
  }

  private static async persistNotes(items: ObservationNote[]): Promise<void> {
    const lines: string[] = []
    for (const n of items) {
      lines.push(ObservationStore.serialize(n))
    }
    await ObservationStore.putString(KEY_NOTES, lines.join('\n'))
  }

  private static serialize(n: ObservationNote): string {
    const text = n.text.replace(/\t/g, ' ').replace(/\n/g, ' ')
    return [n.id, n.dateKey, text, n.emotionKey, n.emotionLabel, `${n.createdAt}`].join('\t')
  }

  private static parseNotes(raw: string): ObservationNote[] {
    const out: ObservationNote[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 6) {
        continue
      }
      const n = new ObservationNote()
      n.id = parts[0]
      n.dateKey = parts[1]
      n.text = parts[2]
      n.emotionKey = parts[3]
      n.emotionLabel = parts[4]
      n.createdAt = parseInt(parts[5], 10)
      out.push(n)
    }
    out.sort((a, b) => b.createdAt - a.createdAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ObservationStore.pref === null) {
      return fallback
    }
    try {
      const v = await ObservationStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ObservationStore.pref === null) {
      return
    }
    try {
      await ObservationStore.pref.put(key, value)
      await ObservationStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
