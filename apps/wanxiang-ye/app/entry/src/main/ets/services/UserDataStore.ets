import { common } from '@kit.AbilityKit'
import { LocalPrefs } from './LocalPrefs'

const KEY_FAVORITES = 'favorite_ids'
const KEY_READ_LATER = 'read_later_ids'
const KEY_HISTORY = 'history_ids'
const KEY_SEARCH = 'search_history'
const KEY_THEME = 'theme_mode'
const KEY_NOTES = 'reading_notes'
const KEY_READ_COUNT = 'read_count'

export class UserDataStore {
  static async init(context: common.UIAbilityContext): Promise<void> {
    await LocalPrefs.init(context)
  }

  static async getFavoriteIds(): Promise<string[]> {
    return UserDataStore.parseIds(await LocalPrefs.getString(KEY_FAVORITES, ''))
  }

  static async isFavorite(id: string): Promise<boolean> {
    const ids = await UserDataStore.getFavoriteIds()
    return ids.indexOf(id) >= 0
  }

  static async toggleFavorite(id: string): Promise<boolean> {
    const ids = await UserDataStore.getFavoriteIds()
    const idx = ids.indexOf(id)
    if (idx >= 0) {
      ids.splice(idx, 1)
      await LocalPrefs.putString(KEY_FAVORITES, ids.join(','))
      return false
    }
    ids.unshift(id)
    await LocalPrefs.putString(KEY_FAVORITES, ids.join(','))
    return true
  }

  static async getReadLaterIds(): Promise<string[]> {
    return UserDataStore.parseIds(await LocalPrefs.getString(KEY_READ_LATER, ''))
  }

  static async isReadLater(id: string): Promise<boolean> {
    const ids = await UserDataStore.getReadLaterIds()
    return ids.indexOf(id) >= 0
  }

  static async toggleReadLater(id: string): Promise<boolean> {
    const ids = await UserDataStore.getReadLaterIds()
    const idx = ids.indexOf(id)
    if (idx >= 0) {
      ids.splice(idx, 1)
      await LocalPrefs.putString(KEY_READ_LATER, ids.join(','))
      return false
    }
    ids.unshift(id)
    await LocalPrefs.putString(KEY_READ_LATER, ids.join(','))
    return true
  }

  static async getNote(itemId: string): Promise<string> {
    const map = await UserDataStore.loadNotes()
    const note = map.get(itemId)
    return note !== undefined ? note : ''
  }

  static async saveNote(itemId: string, note: string): Promise<void> {
    const map = await UserDataStore.loadNotes()
    const trimmed = note.trim()
    if (trimmed.length === 0) {
      map.delete(itemId)
    } else {
      map.set(itemId, trimmed)
    }
    await UserDataStore.persistNotes(map)
  }

  static async listNotedItemIds(): Promise<string[]> {
    const map = await UserDataStore.loadNotes()
    const out: string[] = []
    map.forEach((value: string, key: string) => {
      if (value.length > 0) {
        out.push(key)
      }
    })
    return out
  }

  static async getReadCount(): Promise<number> {
    return LocalPrefs.getInt(KEY_READ_COUNT, 0)
  }

  static async recordRead(id: string): Promise<void> {
    const count = await UserDataStore.getReadCount()
    await LocalPrefs.putInt(KEY_READ_COUNT, count + 1)
    await UserDataStore.pushHistory(id)
  }

  static async pushHistory(id: string): Promise<void> {
    let ids = await UserDataStore.parseIds(await LocalPrefs.getString(KEY_HISTORY, ''))
    const filtered: string[] = []
    for (const x of ids) {
      if (x !== id) {
        filtered.push(x)
      }
    }
    filtered.unshift(id)
    if (filtered.length > 50) {
      filtered.length = 50
    }
    await LocalPrefs.putString(KEY_HISTORY, filtered.join(','))
  }

  static async getHistoryIds(): Promise<string[]> {
    return UserDataStore.parseIds(await LocalPrefs.getString(KEY_HISTORY, ''))
  }

  static async clearHistory(): Promise<void> {
    await LocalPrefs.putString(KEY_HISTORY, '')
  }

  static async getSearchHistory(): Promise<string[]> {
    return UserDataStore.parseIds(await LocalPrefs.getString(KEY_SEARCH, '|'))
  }

  static async addSearchTerm(term: string): Promise<void> {
    const t = term.trim()
    if (t.length === 0) {
      return
    }
    let list = await UserDataStore.getSearchHistory()
    const next: string[] = [t]
    for (const x of list) {
      if (x !== t) {
        next.push(x)
      }
    }
    if (next.length > 10) {
      next.length = 10
    }
    await LocalPrefs.putString(KEY_SEARCH, next.join('|'))
  }

  static async clearSearchHistory(): Promise<void> {
    await LocalPrefs.putString(KEY_SEARCH, '')
  }

  static async getThemeMode(): Promise<string> {
    const v = await LocalPrefs.getString(KEY_THEME, 'system')
    return v.length > 0 ? v : 'system'
  }

  static async saveThemeMode(mode: string): Promise<void> {
    await LocalPrefs.putString(KEY_THEME, mode)
    AppStorage.setOrCreate('colorMode', mode)
  }

  private static async loadNotes(): Promise<Map<string, string>> {
    const raw = await LocalPrefs.getString(KEY_NOTES, '')
    const map: Map<string, string> = new Map()
    if (raw.length === 0) {
      return map
    }
    const chunks = raw.split('||')
    for (const chunk of chunks) {
      const sep = chunk.indexOf('|')
      if (sep > 0) {
        const id = chunk.substring(0, sep)
        const body = chunk.substring(sep + 1)
        if (id.length > 0 && body.length > 0) {
          map.set(id, body)
        }
      }
    }
    return map
  }

  private static async persistNotes(map: Map<string, string>): Promise<void> {
    const parts: string[] = []
    map.forEach((value: string, key: string) => {
      parts.push(`${key}|${value}`)
    })
    await LocalPrefs.putString(KEY_NOTES, parts.join('||'))
  }

  private static parseIds(raw: string): string[] {
    if (raw.length === 0) {
      return []
    }
    const sep = raw.indexOf('|') >= 0 ? '|' : ','
    const parts = raw.split(sep)
    const out: string[] = []
    for (const p of parts) {
      const s = p.trim()
      if (s.length > 0 && out.indexOf(s) < 0) {
        out.push(s)
      }
    }
    return out
  }
}
