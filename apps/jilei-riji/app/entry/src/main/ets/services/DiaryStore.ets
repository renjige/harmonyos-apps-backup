import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { DiaryEntry } from '../models/DiaryModels'

const STORE = 'jilei_diary_v1'
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

  static async findTodayEntry(): Promise<DiaryEntry | undefined> {
    const list = await DiaryStore.loadAll()
    const today = new Date()
    const y = today.getFullYear()
    const m = today.getMonth() + 1
    const d = today.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = d < 10 ? `0${d}` : `${d}`
    const key = `${y}-${ms}-${ds}`
    for (const it of list) {
      if (it.dateKey === key) {
        return it
      }
    }
    return undefined
  }

  static async saveDraft(dateKey: string, body: string): Promise<void> {
    await DiaryStore.putString(`${KEY_DRAFT_PREFIX}${dateKey}`, body, false)
  }

  static async loadDraft(dateKey: string): Promise<string> {
    return DiaryStore.getString(`${KEY_DRAFT_PREFIX}${dateKey}`, '')
  }

  static async clearDraft(dateKey: string): Promise<void> {
    await DiaryStore.putString(`${KEY_DRAFT_PREFIX}${dateKey}`, '')
  }

  static async exportAllText(): Promise<string> {
    const list = await DiaryStore.loadAll()
    const lines: string[] = []
    lines.push('积累日记 — 导出')
    lines.push(`共 ${list.length} 篇`)
    lines.push('')
    for (const it of list) {
      lines.push('---')
      lines.push(it.dateKey)
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
    const body = it.body.replace(/\n/g, '\\n')
    return [it.id, it.dateKey, body, it.imagePath, `${it.wordCount}`, `${it.createdAt}`, `${it.updatedAt}`].join('\t')
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
      if (parts.length < 7) {
        continue
      }
      const e = new DiaryEntry()
      e.id = parts[0]
      e.dateKey = parts[1]
      e.body = parts[2].replace(/\\n/g, '\n')
      e.imagePath = parts[3]
      e.wordCount = parseInt(parts[4], 10)
      e.createdAt = parseInt(parts[5], 10)
      e.updatedAt = parseInt(parts[6], 10)
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

  private static async putString(key: string, value: string, flushNow: boolean = true): Promise<void> {
    if (DiaryStore.pref === null) {
      return
    }
    try {
      await DiaryStore.pref.put(key, value)
      if (flushNow) {
        await DiaryStore.pref.flush()
      }
    } catch {
      // ignore
    }
  }
}
