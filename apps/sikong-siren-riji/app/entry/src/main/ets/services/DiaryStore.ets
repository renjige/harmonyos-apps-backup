import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { DiaryEntry, DiaryFilter } from '../models/DiaryModels'
import { DateHelper } from './DateHelper'

const STORE = 'siren_diary_v1'
const KEY_ENTRIES = 'entries'
const KEY_DRAFT_PREFIX = 'draft_'

export class DiaryStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      DiaryStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      DiaryStore.pref = null
    }
  }

  static async loadAll(): Promise<DiaryEntry[]> {
    const raw = await DiaryStore.getString(KEY_ENTRIES, '')
    return DiaryStore.parseEntries(raw)
  }

  static async saveEntry(entry: DiaryEntry): Promise<void> {
    entry.recomputeWordCount()
    entry.updatedAt = Date.now()
    const list = await DiaryStore.loadAll()
    const next: DiaryEntry[] = []
    let found = false
    for (const it of list) {
      if (it.id === entry.id) {
        next.push(entry)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(entry)
    }
    next.sort((a, b) => b.updatedAt - a.updatedAt)
    await DiaryStore.persistEntries(next)
    await DiaryStore.clearDraft(entry.dateKey)
  }

  static async deleteEntry(id: string): Promise<void> {
    const list = await DiaryStore.loadAll()
    const next: DiaryEntry[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await DiaryStore.persistEntries(next)
  }

  static async findById(id: string): Promise<DiaryEntry | undefined> {
    const list = await DiaryStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async findByDate(dateKey: string): Promise<DiaryEntry[]> {
    const list = await DiaryStore.loadAll()
    const out: DiaryEntry[] = []
    for (const it of list) {
      if (it.dateKey === dateKey) {
        out.push(it)
      }
    }
    return out
  }

  static async filterEntries(filter: DiaryFilter): Promise<DiaryEntry[]> {
    const list = await DiaryStore.loadAll()
    const out: DiaryEntry[] = []
    for (const it of list) {
      if (filter.favoritesOnly && !it.isFavorite) {
        continue
      }
      if (filter.moodKey.length > 0 && it.moodKey !== filter.moodKey) {
        continue
      }
      if (filter.startDateKey.length > 0 && it.dateKey < filter.startDateKey) {
        continue
      }
      if (filter.endDateKey.length > 0 && it.dateKey > filter.endDateKey) {
        continue
      }
      if (filter.keyword.length > 0) {
        const kw = filter.keyword.toLowerCase()
        const hay = `${it.title} ${it.body}`.toLowerCase()
        if (hay.indexOf(kw) < 0) {
          continue
        }
      }
      out.push(it)
    }
    return out
  }

  static async toggleFavorite(id: string): Promise<boolean> {
    const entry = await DiaryStore.findById(id)
    if (entry === undefined) {
      return false
    }
    entry.isFavorite = !entry.isFavorite
    await DiaryStore.saveEntry(entry)
    return entry.isFavorite
  }

  static async saveDraft(dateKey: string, body: string, title: string): Promise<void> {
    const payload = `${title}\t${body}`
    await DiaryStore.putString(`${KEY_DRAFT_PREFIX}${dateKey}`, payload)
  }

  static async loadDraft(dateKey: string): Promise<string[]> {
    const raw = await DiaryStore.getString(`${KEY_DRAFT_PREFIX}${dateKey}`, '')
    if (raw.length === 0) {
      return ['', '']
    }
    const tab = raw.indexOf('\t')
    if (tab < 0) {
      return ['', raw]
    }
    return [raw.substring(0, tab), raw.substring(tab + 1)]
  }

  static async clearDraft(dateKey: string): Promise<void> {
    await DiaryStore.putString(`${KEY_DRAFT_PREFIX}${dateKey}`, '')
  }

  static async datesWithEntries(year: number, month: number): Promise<Set<string>> {
    const list = await DiaryStore.loadAll()
    const set = new Set<string>()
    const prefix = `${year}-${month < 10 ? `0${month}` : `${month}`}`
    for (const it of list) {
      if (it.dateKey.indexOf(prefix) === 0) {
        set.add(it.dateKey)
      }
    }
    return set
  }

  static async exportAllText(): Promise<string> {
    const list = await DiaryStore.loadAll()
    const lines: string[] = []
    lines.push('私人日记 — 导出')
    lines.push(`导出时间：${DateHelper.displayDate(DateHelper.todayKey())}`)
    lines.push('')
    for (const it of list) {
      lines.push('---')
      lines.push(DateHelper.displayDate(it.dateKey))
      lines.push(`心情：${it.moodLabel}${it.weather.length > 0 ? ` · 天气：${it.weather}` : ''}`)
      if (it.title.length > 0) {
        lines.push(it.title)
      }
      lines.push(it.body)
      lines.push('')
    }
    return lines.join('\n')
  }

  private static async persistEntries(items: DiaryEntry[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(DiaryStore.serialize(it))
    }
    await DiaryStore.putString(KEY_ENTRIES, lines.join('\n'))
  }

  private static serialize(it: DiaryEntry): string {
    const title = it.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const body = it.body.replace(/\n/g, '\\n')
    const imgs = it.imagePaths.replace(/\|/g, ',')
    return [
      it.id, it.dateKey, it.moodKey, it.moodLabel, title, body,
      `${it.wordCount}`, it.isFavorite ? '1' : '0', imgs, it.audioPath,
      `${it.createdAt}`, `${it.updatedAt}`, it.weather
    ].join('\t')
  }

  private static parseEntries(raw: string): DiaryEntry[] {
    const out: DiaryEntry[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 12) {
        continue
      }
      const e = new DiaryEntry()
      e.id = parts[0]
      e.dateKey = parts[1]
      e.moodKey = parts[2]
      e.moodLabel = parts[3]
      e.title = parts[4]
      e.body = parts[5].replace(/\\n/g, '\n')
      e.wordCount = parseInt(parts[6], 10)
      e.isFavorite = parts[7] === '1'
      e.imagePaths = parts[8].replace(/,/g, '|')
      e.audioPath = parts[9]
      e.createdAt = parseInt(parts[10], 10)
      e.updatedAt = parseInt(parts[11], 10)
      e.weather = parts.length > 12 ? parts[12] : ''
      out.push(e)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (DiaryStore.pref === null) {
      return fallback
    }
    try {
      const v = await DiaryStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (DiaryStore.pref === null) {
      return
    }
    try {
      await DiaryStore.pref.put(key, value)
      await DiaryStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
