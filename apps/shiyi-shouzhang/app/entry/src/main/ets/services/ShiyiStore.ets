import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  AppSettings,
  JournalEntry,
  PickupItem,
  RitualEntry,
  ShiyiBundle,
  TagItem
} from '../models/ShiyiModels'
import { DefaultTags } from './MoodCatalog'

const STORE = 'shiyi_local'
const KEY_BUNDLE = 'bundle'
const KEY_REV = 'shiyiRev'

export class ShiyiStore {
  private static pref: preferences.Preferences | null = null
  private static cache: ShiyiBundle = new ShiyiBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ShiyiStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await ShiyiStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      ShiyiStore.cache = ShiyiStore.parseBundle(raw)
      ShiyiStore.ensureDefaultTags()
    } catch {
      ShiyiStore.cache = new ShiyiBundle()
      ShiyiStore.ensureDefaultTags()
    }
    ShiyiStore.bump()
  }

  static snapshot(): ShiyiBundle {
    return ShiyiStore.cache
  }

  static journals(): JournalEntry[] {
    return ShiyiStore.cache.journals
  }

  static pickups(): PickupItem[] {
    return ShiyiStore.cache.pickups
  }

  static tags(): TagItem[] {
    return ShiyiStore.cache.tags
  }

  static settings(): AppSettings {
    return ShiyiStore.cache.settings
  }

  static findJournal(id: string): JournalEntry | null {
    for (const item of ShiyiStore.cache.journals) {
      if (item.id === id) {
        return item
      }
    }
    return null
  }

  static findByDate(date: string): JournalEntry[] {
    const out: JournalEntry[] = []
    for (const item of ShiyiStore.cache.journals) {
      if (item.entryDate === date) {
        out.push(item)
      }
    }
    return out
  }

  static todayFirst(): JournalEntry | null {
    const list = ShiyiStore.findByDate(ShiyiStore.today())
    for (const item of list) {
      return item
    }
    return null
  }

  static recent(limit: number): JournalEntry[] {
    const copy: JournalEntry[] = []
    for (const item of ShiyiStore.sortedJournals()) {
      if (copy.length < limit) {
        copy.push(item)
      }
    }
    return copy
  }

  static sortedJournals(): JournalEntry[] {
    const copy: JournalEntry[] = []
    for (const item of ShiyiStore.cache.journals) {
      copy.push(item)
    }
    copy.sort((a: JournalEntry, b: JournalEntry): number => {
      if (a.entryDate === b.entryDate) {
        return b.updatedAt - a.updatedAt
      }
      return a.entryDate < b.entryDate ? 1 : -1
    })
    return copy
  }

  static datesWithJournal(): string[] {
    const seen: string[] = []
    for (const item of ShiyiStore.cache.journals) {
      let exists = false
      for (const d of seen) {
        if (d === item.entryDate) {
          exists = true
          break
        }
      }
      if (!exists) {
        seen.push(item.entryDate)
      }
    }
    return seen
  }

  static ritualOf(date: string): RitualEntry | null {
    for (const item of ShiyiStore.cache.rituals) {
      if (item.entryDate === date) {
        return item
      }
    }
    return null
  }

  static async saveJournal(entry: JournalEntry): Promise<boolean> {
    try {
      const next = ShiyiStore.cloneBundle()
      let found = false
      const list: JournalEntry[] = []
      for (const item of next.journals) {
        if (item.id === entry.id) {
          list.push(entry)
          found = true
        } else {
          list.push(item)
        }
      }
      if (!found) {
        list.push(entry)
      }
      next.journals = list
      await ShiyiStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async deleteJournal(id: string): Promise<boolean> {
    try {
      const next = ShiyiStore.cloneBundle()
      const list: JournalEntry[] = []
      for (const item of next.journals) {
        if (item.id !== id) {
          list.push(item)
        }
      }
      next.journals = list
      await ShiyiStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async savePickup(item: PickupItem): Promise<boolean> {
    try {
      const next = ShiyiStore.cloneBundle()
      let found = false
      const list: PickupItem[] = []
      for (const row of next.pickups) {
        if (row.id === item.id) {
          list.push(item)
          found = true
        } else {
          list.push(row)
        }
      }
      if (!found) {
        list.push(item)
      }
      next.pickups = list
      await ShiyiStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async deletePickup(id: string): Promise<boolean> {
    try {
      const next = ShiyiStore.cloneBundle()
      const list: PickupItem[] = []
      for (const row of next.pickups) {
        if (row.id !== id) {
          list.push(row)
        }
      }
      next.pickups = list
      await ShiyiStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async saveRitual(ritual: RitualEntry): Promise<boolean> {
    try {
      const next = ShiyiStore.cloneBundle()
      const list: RitualEntry[] = []
      let found = false
      for (const row of next.rituals) {
        if (row.entryDate === ritual.entryDate) {
          list.push(ritual)
          found = true
        } else {
          list.push(row)
        }
      }
      if (!found) {
        list.push(ritual)
      }
      next.rituals = list
      await ShiyiStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async saveTags(tags: TagItem[]): Promise<boolean> {
    try {
      const next = ShiyiStore.cloneBundle()
      next.tags = tags
      await ShiyiStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async saveSettings(settings: AppSettings): Promise<boolean> {
    try {
      const next = ShiyiStore.cloneBundle()
      next.settings = settings
      await ShiyiStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async clearAll(): Promise<boolean> {
    try {
      const next = new ShiyiBundle()
      ShiyiStore.cache = next
      ShiyiStore.ensureDefaultTags()
      await ShiyiStore.persist(ShiyiStore.cache)
      return true
    } catch {
      return false
    }
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static today(): string {
    return ShiyiStore.formatDate(new Date())
  }

  static formatDate(d: Date): string {
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms: string = m < 10 ? `0${m}` : `${m}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static displayDate(iso: string): string {
    if (iso.length < 10) {
      return iso
    }
    const y = iso.substring(0, 4)
    const m = iso.substring(5, 7)
    const d = iso.substring(8, 10)
    return `${y}年${Number.parseInt(m)}月${Number.parseInt(d)}日`
  }

  static greeting(): string {
    const hour = new Date().getHours()
    if (hour < 6) {
      return '夜安'
    }
    if (hour < 11) {
      return '早安'
    }
    if (hour < 14) {
      return '上午好'
    }
    if (hour < 18) {
      return '下午好'
    }
    return '晚安'
  }

  private static bump(): void {
    const cur = AppStorage.get<number>(KEY_REV)
    const next = (cur ?? 0) + 1
    AppStorage.setOrCreate(KEY_REV, next)
  }

  private static ensureDefaultTags(): void {
    if (ShiyiStore.cache.tags.length > 0) {
      return
    }
    const names = DefaultTags.names()
    const tags: TagItem[] = []
    for (const name of names) {
      const tag = new TagItem()
      tag.id = `tag_${name}`
      tag.name = name
      tag.custom = false
      tags.push(tag)
    }
    ShiyiStore.cache.tags = tags
  }

  private static cloneBundle(): ShiyiBundle {
    const next = new ShiyiBundle()
    next.journals = ShiyiStore.cache.journals
    next.pickups = ShiyiStore.cache.pickups
    next.tags = ShiyiStore.cache.tags
    next.rituals = ShiyiStore.cache.rituals
    next.settings = ShiyiStore.cache.settings
    return next
  }

  private static async persist(next: ShiyiBundle): Promise<void> {
    ShiyiStore.cache = next
    await ShiyiStore.putString(KEY_BUNDLE, JSON.stringify(next))
    ShiyiStore.bump()
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ShiyiStore.pref === null) {
      return
    }
    await ShiyiStore.pref.put(key, value)
    await ShiyiStore.pref.flush()
  }

  private static parseBundle(raw: string): ShiyiBundle {
    const empty = new ShiyiBundle()
    if (raw.length === 0) {
      return empty
    }
    try {
      const parsed = JSON.parse(raw) as ShiyiBundle
      const out = new ShiyiBundle()
      if (parsed.journals !== undefined) {
        out.journals = parsed.journals
      }
      if (parsed.pickups !== undefined) {
        out.pickups = parsed.pickups
      }
      if (parsed.tags !== undefined) {
        out.tags = parsed.tags
      }
      if (parsed.rituals !== undefined) {
        out.rituals = parsed.rituals
      }
      if (parsed.settings !== undefined) {
        out.settings = parsed.settings
      }
      return out
    } catch {
      return empty
    }
  }
}
