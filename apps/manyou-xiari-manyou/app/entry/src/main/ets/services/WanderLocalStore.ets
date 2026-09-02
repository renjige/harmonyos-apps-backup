import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { CheckItem, JournalDayGroup, JournalItem } from '../models/WanderModels'

const STORE = 'wander_local'
const KEY_JOURNALS = 'journals'
const KEY_CHECKS = 'checklist'
const KEY_FAVS = 'favorites'
const KEY_INSP_FAVS = 'inspiration_favorites'
const KEY_DARK_MODE = 'dark_mode_on'

export class WanderLocalStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      WanderLocalStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      WanderLocalStore.pref = null
    }
  }

  static async loadJournals(): Promise<JournalItem[]> {
    const raw = await WanderLocalStore.getString(KEY_JOURNALS, '{"items":[]}')
    return WanderLocalStore.parseJournals(raw)
  }

  static async saveJournals(items: JournalItem[]): Promise<void> {
    const parts: string[] = []
    for (const it of items) {
      parts.push(WanderLocalStore.journalJson(it))
    }
    await WanderLocalStore.putString(KEY_JOURNALS, `{"items":[${parts.join(',')}]}`)
  }

  static async upsertJournal(item: JournalItem): Promise<void> {
    const list = await WanderLocalStore.loadJournals()
    const next: JournalItem[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    await WanderLocalStore.saveJournals(next)
  }

  static async removeJournal(id: string): Promise<void> {
    const list = await WanderLocalStore.loadJournals()
    const next: JournalItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await WanderLocalStore.saveJournals(next)
  }

  static async findJournal(id: string): Promise<JournalItem | undefined> {
    const list = await WanderLocalStore.loadJournals()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async loadChecks(): Promise<CheckItem[]> {
    const raw = await WanderLocalStore.getString(KEY_CHECKS, '')
    if (raw.length === 0) {
      return WanderLocalStore.defaultChecks()
    }
    return WanderLocalStore.parseChecks(raw)
  }

  static async saveChecks(items: CheckItem[]): Promise<void> {
    const parts: string[] = []
    for (const it of items) {
      const done = it.done ? 'true' : 'false'
      parts.push(`{"id":${JSON.stringify(it.id)},"label":${JSON.stringify(it.label)},"done":${done}}`)
    }
    await WanderLocalStore.putString(KEY_CHECKS, `{"items":[${parts.join(',')}]}`)
  }

  static async loadFavoriteIds(): Promise<string[]> {
    const raw = await WanderLocalStore.getString(KEY_FAVS, '')
    if (raw.length === 0) {
      return []
    }
    const out: string[] = []
    const parts = raw.split(',')
    for (const p of parts) {
      if (p.length > 0) {
        out.push(p)
      }
    }
    return out
  }

  static async isFavorite(id: string): Promise<boolean> {
    const ids = await WanderLocalStore.loadFavoriteIds()
    for (const x of ids) {
      if (x === id) {
        return true
      }
    }
    return false
  }

  static async toggleFavorite(id: string): Promise<boolean> {
    const ids = await WanderLocalStore.loadFavoriteIds()
    const next: string[] = []
    let found = false
    for (const x of ids) {
      if (x === id) {
        found = true
      } else {
        next.push(x)
      }
    }
    if (!found) {
      next.push(id)
    }
    await WanderLocalStore.putString(KEY_FAVS, next.join(','))
    return !found
  }

  static async loadInspirationFavoriteIds(): Promise<string[]> {
    const raw = await WanderLocalStore.getString(KEY_INSP_FAVS, '')
    if (raw.length === 0) {
      return []
    }
    const out: string[] = []
    const parts = raw.split(',')
    for (const p of parts) {
      if (p.length > 0) {
        out.push(p)
      }
    }
    return out
  }

  static async isInspirationFavorited(id: string): Promise<boolean> {
    const ids = await WanderLocalStore.loadInspirationFavoriteIds()
    for (const x of ids) {
      if (x === id) {
        return true
      }
    }
    return false
  }

  static async addInspirationFavorite(id: string): Promise<void> {
    const ids = await WanderLocalStore.loadInspirationFavoriteIds()
    for (const x of ids) {
      if (x === id) {
        return
      }
    }
    ids.push(id)
    await WanderLocalStore.putString(KEY_INSP_FAVS, ids.join(','))
  }

  static async removeInspirationFavorite(id: string): Promise<void> {
    const ids = await WanderLocalStore.loadInspirationFavoriteIds()
    const next: string[] = []
    for (const x of ids) {
      if (x !== id) {
        next.push(x)
      }
    }
    await WanderLocalStore.putString(KEY_INSP_FAVS, next.join(','))
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static notifyDataChanged(): void {
    const cur = AppStorage.get<number>('wanderDataRefresh')
    const next = cur !== undefined && cur !== null ? cur + 1 : 1
    AppStorage.setOrCreate('wanderDataRefresh', next)
  }

  static todayLabel(): string {
    const d = new Date()
    const mo = d.getMonth() + 1
    const day = d.getDate()
    return `${d.getFullYear()}.${mo}.${day}`
  }

  static async loadDarkMode(): Promise<boolean> {
    const raw = await WanderLocalStore.getString(KEY_DARK_MODE, 'false')
    return raw === 'true'
  }

  static async saveDarkMode(on: boolean): Promise<void> {
    await WanderLocalStore.putString(KEY_DARK_MODE, on ? 'true' : 'false')
  }

  static groupJournalsByMonth(items: JournalItem[]): JournalDayGroup[] {
    const labels: string[] = []
    const buckets: JournalItem[][] = []
    for (const it of items) {
      const label = WanderLocalStore.monthLabel(it)
      let idx = -1
      for (let i = 0; i < labels.length; i++) {
        if (labels[i] === label) {
          idx = i
          break
        }
      }
      if (idx < 0) {
        labels.push(label)
        const bucket: JournalItem[] = []
        bucket.push(it)
        buckets.push(bucket)
      } else {
        buckets[idx].push(it)
      }
    }
    const out: JournalDayGroup[] = []
    for (let i = 0; i < labels.length; i++) {
      const g = new JournalDayGroup()
      g.label = labels[i]
      g.items = buckets[i]
      out.push(g)
    }
    return out
  }

  private static monthLabel(it: JournalItem): string {
    if (it.dateLabel.length > 0) {
      const parts = it.dateLabel.replace(/-/g, '.').split('.')
      if (parts.length >= 2) {
        const y = parts[0]
        const m = parts[1]
        return `${y}年${m}月`
      }
    }
    if (it.createdAt > 0) {
      const d = new Date(it.createdAt)
      return `${d.getFullYear()}年${d.getMonth() + 1}月`
    }
    return '更早'
  }

  static defaultChecks(): CheckItem[] {
    const out: CheckItem[] = []
    const names: string[] = []
    names.push('饮用水')
    names.push('防晒用品')
    names.push('遮阳帽')
    names.push('轻便鞋')
    names.push('纸巾')
    names.push('充电设备')
    names.push('雨具')
    let n = 1
    for (const label of names) {
      const it = new CheckItem()
      it.id = `ck${n}`
      it.label = label
      it.done = false
      out.push(it)
      n += 1
    }
    return out
  }

  private static journalJson(it: JournalItem): string {
    return `{"id":${JSON.stringify(it.id)},"title":${JSON.stringify(it.title)},"place":${JSON.stringify(it.place)},"body":${JSON.stringify(it.body)},"mood":${JSON.stringify(it.mood)},"dateLabel":${JSON.stringify(it.dateLabel)},"coverKey":${JSON.stringify(it.coverKey)},"photoUri":${JSON.stringify(it.photoUri)},"createdAt":${it.createdAt}}`
  }

  private static parseJournals(raw: string): JournalItem[] {
    const out: JournalItem[] = []
    try {
      const root = JSON.parse(raw) as JournalFile
      if (root.items === undefined) {
        return out
      }
      for (const w of root.items) {
        const it = new JournalItem()
        it.id = w.id ?? ''
        it.title = w.title ?? ''
        it.place = w.place ?? ''
        it.body = w.body ?? ''
        it.mood = w.mood ?? ''
        it.dateLabel = w.dateLabel ?? ''
        it.coverKey = w.coverKey ?? ''
        it.photoUri = w.photoUri ?? ''
        it.createdAt = w.createdAt ?? 0
        out.push(it)
      }
    } catch {
      return out
    }
    return out
  }

  private static parseChecks(raw: string): CheckItem[] {
    const out: CheckItem[] = []
    try {
      const root = JSON.parse(raw) as CheckFile
      if (root.items === undefined) {
        return WanderLocalStore.defaultChecks()
      }
      for (const w of root.items) {
        const it = new CheckItem()
        it.id = w.id ?? ''
        it.label = w.label ?? ''
        it.done = w.done === true
        out.push(it)
      }
    } catch {
      return WanderLocalStore.defaultChecks()
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (WanderLocalStore.pref === null) {
      return fallback
    }
    const v = await WanderLocalStore.pref.get(key, fallback)
    return typeof v === 'string' ? v : fallback
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (WanderLocalStore.pref === null) {
      return
    }
    await WanderLocalStore.pref.put(key, value)
    await WanderLocalStore.pref.flush()
  }
}

class JournalFile {
  items: JournalItem[] = []
}

class CheckFile {
  items: CheckItem[] = []
}
