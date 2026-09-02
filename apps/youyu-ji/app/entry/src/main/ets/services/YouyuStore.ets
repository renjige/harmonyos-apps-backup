import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  CornerBundle,
  CornerEntry,
  CornerSettings,
  CornerStats,
  CornerTag,
  DateGroup,
  TagCount
} from '../models/YouyuModels'
import { MoodCatalog } from './MoodCatalog'

const STORE = 'youyu_local'
const KEY_BUNDLE = 'bundle'
const KEY_REV = 'youyuRev'

export class YouyuStore {
  private static pref: preferences.Preferences | null = null
  private static cache: CornerBundle = new CornerBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      YouyuStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await YouyuStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      YouyuStore.cache = YouyuStore.parseBundle(raw)
      YouyuStore.ensureDefaultTags()
    } catch {
      YouyuStore.cache = new CornerBundle()
      YouyuStore.ensureDefaultTags()
    }
    const dark = YouyuStore.cache.settings.darkMode
    AppStorage.setOrCreate('darkModeOn', dark)
    YouyuStore.bump()
  }

  static snapshot(): CornerBundle {
    return YouyuStore.cache
  }

  static entries(): CornerEntry[] {
    return YouyuStore.cache.entries
  }

  static tags(): CornerTag[] {
    return YouyuStore.cache.tags
  }

  static settings(): CornerSettings {
    return YouyuStore.cache.settings
  }

  static findEntry(id: string): CornerEntry | null {
    for (const item of YouyuStore.cache.entries) {
      if (item.id === id) {
        return item
      }
    }
    return null
  }

  static sortedEntries(): CornerEntry[] {
    const copy: CornerEntry[] = []
    for (const item of YouyuStore.cache.entries) {
      copy.push(item)
    }
    copy.sort((a: CornerEntry, b: CornerEntry): number => {
      if (a.entryDate === b.entryDate) {
        return b.updatedAt - a.updatedAt
      }
      return a.entryDate < b.entryDate ? 1 : -1
    })
    return copy
  }

  static groupedTimeline(tagFilter: string): DateGroup[] {
    const groups: DateGroup[] = []
    const list = YouyuStore.sortedEntries()
    for (const item of list) {
      if (tagFilter.length > 0 && !YouyuStore.entryHasTag(item, tagFilter)) {
        continue
      }
      let found: DateGroup | null = null
      for (const g of groups) {
        if (g.date === item.entryDate) {
          found = g
          break
        }
      }
      if (found === null) {
        const g = new DateGroup()
        g.date = item.entryDate
        g.label = YouyuStore.displayDate(item.entryDate)
        g.items = []
        g.items.push(item)
        groups.push(g)
      } else {
        found.items.push(item)
      }
    }
    return groups
  }

  static entryHasTag(item: CornerEntry, tagId: string): boolean {
    const tags = item.tagList()
    for (const t of tags) {
      if (t === tagId) {
        return true
      }
    }
    return false
  }

  static pickRandom(): CornerEntry | null {
    return YouyuStore.pickRandomExcept('')
  }

  static pickRandomExcept(excludeId: string): CornerEntry | null {
    const list = YouyuStore.cache.entries
    if (list.length === 0) {
      return null
    }
    const candidates: CornerEntry[] = []
    for (const item of list) {
      if (excludeId.length === 0 || item.id !== excludeId) {
        candidates.push(item)
      }
    }
    const pool = candidates.length > 0 ? candidates : list
    const idx = Math.floor(Math.random() * pool.length)
    let i = 0
    for (const item of pool) {
      if (i === idx) {
        return item
      }
      i += 1
    }
    return null
  }

  static stats(): CornerStats {
    const out = new CornerStats()
    out.total = YouyuStore.cache.entries.length
    out.streak = YouyuStore.calcStreak()
    const monthPrefix = YouyuStore.today().substring(0, 7)
    let month = 0
    for (const item of YouyuStore.cache.entries) {
      if (item.entryDate.indexOf(monthPrefix) === 0) {
        month += 1
      }
    }
    out.monthCount = month
    const counts: TagCount[] = []
    for (const tag of YouyuStore.cache.tags) {
      const row = new TagCount()
      row.id = tag.id
      row.name = tag.name
      row.count = 0
      for (const item of YouyuStore.cache.entries) {
        if (YouyuStore.entryHasTag(item, tag.id)) {
          row.count += 1
        }
      }
      counts.push(row)
    }
    out.tags = counts
    return out
  }

  static calcStreak(): number {
    const days: string[] = []
    for (const item of YouyuStore.cache.entries) {
      let exists = false
      for (const d of days) {
        if (d === item.entryDate) {
          exists = true
          break
        }
      }
      if (!exists) {
        days.push(item.entryDate)
      }
    }
    days.sort((a: string, b: string): number => {
      return a < b ? 1 : -1
    })
    if (days.length === 0) {
      return 0
    }
    let first = ''
    for (const d of days) {
      first = d
      break
    }
    const today = YouyuStore.today()
    const yest = YouyuStore.shiftDay(today, -1)
    let cursor = ''
    if (first === today) {
      cursor = today
    } else if (first === yest) {
      cursor = yest
    } else {
      return 0
    }
    let streak = 0
    for (const d of days) {
      if (d === cursor) {
        streak += 1
        cursor = YouyuStore.shiftDay(cursor, -1)
      } else if (d < cursor) {
        break
      }
    }
    return streak
  }

  static async saveEntry(entry: CornerEntry): Promise<boolean> {
    try {
      const next = YouyuStore.cloneBundle()
      const list: CornerEntry[] = []
      let found = false
      for (const item of next.entries) {
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
      next.entries = list
      await YouyuStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async deleteEntry(id: string): Promise<boolean> {
    try {
      const next = YouyuStore.cloneBundle()
      const list: CornerEntry[] = []
      for (const item of next.entries) {
        if (item.id !== id) {
          list.push(item)
        }
      }
      next.entries = list
      await YouyuStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async saveTags(tags: CornerTag[]): Promise<boolean> {
    try {
      const next = YouyuStore.cloneBundle()
      next.tags = tags
      await YouyuStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async saveSettings(settings: CornerSettings): Promise<boolean> {
    try {
      const next = YouyuStore.cloneBundle()
      next.settings = settings
      await YouyuStore.persist(next)
      AppStorage.setOrCreate('darkModeOn', settings.darkMode)
      return true
    } catch {
      return false
    }
  }

  static async clearAll(): Promise<boolean> {
    try {
      const keep = YouyuStore.cache.settings
      const next = new CornerBundle()
      next.settings = keep
      YouyuStore.cache = next
      YouyuStore.ensureDefaultTags()
      await YouyuStore.persist(YouyuStore.cache)
      return true
    } catch {
      return false
    }
  }

  static exportText(): string {
    const lines: string[] = []
    lines.push('悠隅纪 · 本机记录导出')
    const list = YouyuStore.sortedEntries()
    for (const item of list) {
      lines.push('---')
      lines.push(YouyuStore.displayDate(item.entryDate))
      lines.push(`${MoodCatalog.labelOf(item.mood)}  ${item.tagCsv}`)
      lines.push(item.body)
    }
    return lines.join('\n')
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static today(): string {
    return YouyuStore.formatDate(new Date())
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
    const today = YouyuStore.today()
    if (iso === today) {
      return '今天'
    }
    if (iso === YouyuStore.shiftDay(today, -1)) {
      return '昨天'
    }
    return `${y}年${Number.parseInt(m)}月${Number.parseInt(d)}日`
  }

  static greeting(): string {
    const hour = new Date().getHours()
    if (hour < 6) {
      return '夜安，这一隅还亮着'
    }
    if (hour < 11) {
      return '早安，光刚落在窗边'
    }
    if (hour < 18) {
      return '午后，把此刻轻轻放下'
    }
    return '晚安，留下今天的温度'
  }

  static shiftDay(iso: string, delta: number): string {
    const d = new Date(`${iso}T12:00:00`)
    d.setDate(d.getDate() + delta)
    return YouyuStore.formatDate(d)
  }

  static touchUi(): void {
    YouyuStore.bump()
  }

  private static bump(): void {
    const cur = AppStorage.get<number>(KEY_REV)
    const next = (cur ?? 0) + 1
    AppStorage.setOrCreate(KEY_REV, next)
  }

  private static ensureDefaultTags(): void {
    if (YouyuStore.cache.tags.length > 0) {
      return
    }
    const names = MoodCatalog.defaultTagNames()
    const tags: CornerTag[] = []
    for (const name of names) {
      const tag = new CornerTag()
      tag.id = `tag_${name}`
      tag.name = name
      tag.custom = false
      tags.push(tag)
    }
    YouyuStore.cache.tags = tags
  }

  private static cloneBundle(): CornerBundle {
    const next = new CornerBundle()
    next.entries = YouyuStore.cache.entries
    next.tags = YouyuStore.cache.tags
    next.settings = YouyuStore.cache.settings
    return next
  }

  private static async persist(next: CornerBundle): Promise<void> {
    YouyuStore.cache = next
    await YouyuStore.putString(KEY_BUNDLE, YouyuStore.toJson(next))
    YouyuStore.bump()
  }

  private static toJson(bundle: CornerBundle): string {
    return JSON.stringify(bundle)
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (YouyuStore.pref === null) {
      return
    }
    await YouyuStore.pref.put(key, value)
    await YouyuStore.pref.flush()
  }

  private static parseBundle(raw: string): CornerBundle {
    const empty = new CornerBundle()
    if (raw.length === 0) {
      return empty
    }
    try {
      const parsed = JSON.parse(raw) as CornerBundle
      const out = new CornerBundle()
      if (parsed.entries !== undefined) {
        const list: CornerEntry[] = []
        for (const row of parsed.entries) {
          const e = new CornerEntry()
          e.id = row.id
          e.body = row.body
          e.mood = row.mood
          e.tagCsv = row.tagCsv
          e.photoPath = row.photoPath
          e.entryDate = row.entryDate
          e.createdAt = row.createdAt
          e.updatedAt = row.updatedAt
          list.push(e)
        }
        out.entries = list
      }
      if (parsed.tags !== undefined) {
        const tags: CornerTag[] = []
        for (const row of parsed.tags) {
          const t = new CornerTag()
          t.id = row.id
          t.name = row.name
          t.custom = row.custom
          tags.push(t)
        }
        out.tags = tags
      }
      if (parsed.settings !== undefined) {
        const s = new CornerSettings()
        s.darkMode = parsed.settings.darkMode
        s.reminderEnabled = parsed.settings.reminderEnabled
        s.reminderHour = parsed.settings.reminderHour
        s.reminderMinute = parsed.settings.reminderMinute
        s.reminderAgentId = parsed.settings.reminderAgentId
        s.nickname = parsed.settings.nickname
        out.settings = s
      }
      return out
    } catch {
      return empty
    }
  }
}
