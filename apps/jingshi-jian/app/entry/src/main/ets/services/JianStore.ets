import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { JianEntry } from '../models/JianModels'

const STORE = 'jingshi_jian_v1'
const KEY_ENTRIES = 'entries'
const KEY_FAV_QUOTES = 'fav_quotes'
const KEY_DRAFT_PREFIX = 'draft_'

export class JianStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      JianStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      JianStore.pref = null
    }
  }

  static async loadAll(): Promise<JianEntry[]> {
    const raw = await JianStore.getString(KEY_ENTRIES, '')
    return JianStore.parseEntries(raw)
  }

  static async saveEntry(entry: JianEntry): Promise<void> {
    entry.recomputeWordCount()
    entry.updatedAt = Date.now()
    const list = await JianStore.loadAll()
    const next: JianEntry[] = []
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
    await JianStore.persistEntries(next)
    await JianStore.clearDraft(entry.dateKey)
  }

  static async deleteEntry(id: string): Promise<void> {
    const list = await JianStore.loadAll()
    const next: JianEntry[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await JianStore.persistEntries(next)
  }

  static async findById(id: string): Promise<JianEntry | undefined> {
    const list = await JianStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async toggleFavorite(id: string): Promise<boolean> {
    const entry = await JianStore.findById(id)
    if (entry === undefined) {
      return false
    }
    entry.isFavorite = !entry.isFavorite
    await JianStore.saveEntry(entry)
    return entry.isFavorite
  }

  static async loadFavorites(): Promise<JianEntry[]> {
    const list = await JianStore.loadAll()
    const out: JianEntry[] = []
    for (const it of list) {
      if (it.isFavorite) {
        out.push(it)
      }
    }
    return out
  }

  static async saveDraft(dateKey: string, body: string, moodId: string): Promise<void> {
    await JianStore.putString(`${KEY_DRAFT_PREFIX}${dateKey}`, `${body}\t${moodId}`, false)
  }

  static async loadDraft(dateKey: string): Promise<string[]> {
    const raw = await JianStore.getString(`${KEY_DRAFT_PREFIX}${dateKey}`, '')
    if (raw.length === 0) {
      return ['', '']
    }
    const idx = raw.lastIndexOf('\t')
    if (idx < 0) {
      return [raw, '']
    }
    return [raw.substring(0, idx), raw.substring(idx + 1)]
  }

  static async clearDraft(dateKey: string): Promise<void> {
    await JianStore.putString(`${KEY_DRAFT_PREFIX}${dateKey}`, '')
  }

  static async favoriteQuoteIds(): Promise<string[]> {
    const raw = await JianStore.getString(KEY_FAV_QUOTES, '')
    if (raw.length === 0) {
      return []
    }
    return raw.split(',')
  }

  static async toggleFavoriteQuote(quoteId: string): Promise<boolean> {
    const ids = await JianStore.favoriteQuoteIds()
    const next: string[] = []
    let found = false
    for (const id of ids) {
      if (id === quoteId) {
        found = true
      } else if (id.length > 0) {
        next.push(id)
      }
    }
    if (!found) {
      next.push(quoteId)
    }
    await JianStore.putString(KEY_FAV_QUOTES, next.join(','))
    return !found
  }

  static async isQuoteFavorite(quoteId: string): Promise<boolean> {
    const ids = await JianStore.favoriteQuoteIds()
    for (const id of ids) {
      if (id === quoteId) {
        return true
      }
    }
    return false
  }

  static async exportAllText(): Promise<string> {
    const list = await JianStore.loadAll()
    const lines: string[] = []
    lines.push('静时笺 — 导出')
    lines.push(`共 ${list.length} 笺`)
    lines.push('')
    for (const it of list) {
      lines.push('---')
      lines.push(`${it.dateKey} ${it.timeStr}`)
      if (it.moodId.length > 0) {
        lines.push(`心情：${it.moodId}`)
      }
      lines.push(it.body)
      lines.push('')
    }
    return lines.join('\n')
  }

  private static async persistEntries(items: JianEntry[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(JianStore.serialize(it))
    }
    await JianStore.putString(KEY_ENTRIES, lines.join('\n'))
  }

  private static serialize(it: JianEntry): string {
    const body = it.body.replace(/\n/g, '\\n')
    const fav = it.isFavorite ? '1' : '0'
    return [it.id, it.dateKey, it.timeStr, body, it.moodId, fav, `${it.wordCount}`, `${it.createdAt}`, `${it.updatedAt}`].join('\t')
  }

  private static parseEntries(raw: string): JianEntry[] {
    const out: JianEntry[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 9) {
        continue
      }
      const e = new JianEntry()
      e.id = parts[0]
      e.dateKey = parts[1]
      e.timeStr = parts[2]
      e.body = parts[3].replace(/\\n/g, '\n')
      e.moodId = parts[4]
      e.isFavorite = parts[5] === '1'
      e.wordCount = parseInt(parts[6], 10)
      e.createdAt = parseInt(parts[7], 10)
      e.updatedAt = parseInt(parts[8], 10)
      out.push(e)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (JianStore.pref === null) {
      return fallback
    }
    try {
      const v = await JianStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string, flushNow: boolean = true): Promise<void> {
    if (JianStore.pref === null) {
      return
    }
    try {
      await JianStore.pref.put(key, value)
      if (flushNow) {
        await JianStore.pref.flush()
      }
    } catch {
      // ignore
    }
  }
}
