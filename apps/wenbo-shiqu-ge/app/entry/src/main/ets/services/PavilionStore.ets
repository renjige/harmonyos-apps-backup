import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { PavilionStats } from '../models/PavilionModels'
import { PavilionDetailNav } from './PavilionDetailNav'
import { ExploreStore } from './ExploreStore'
import { JournalStore } from './JournalStore'

const STORE_NAME = 'shiquge_local'
const KEY_FAVORITES = 'favorites_json'
const KEY_HISTORY = 'history_json'
const KEY_DARK = 'dark_mode'
const KEY_CAT_ART = 'catalog_articles'
const KEY_CAT_DAY = 'catalog_daily'
const KEY_CAT_COL = 'catalog_collections'

export class PavilionStore {
  private static pref: preferences.Preferences | null = null
  private static favorites: string[] = []
  private static history: string[] = []
  private static cacheArticles: string = ''
  private static cacheDaily: string = ''
  private static cacheCols: string = ''

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      PavilionStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const rawFav = await PavilionStore.pref.get(KEY_FAVORITES, '[]')
      const favStr: string = typeof rawFav === 'string' ? rawFav : '[]'
      PavilionStore.favorites = PavilionStore.parseIdList(favStr)
      const rawHist = await PavilionStore.pref.get(KEY_HISTORY, '[]')
      const histStr: string = typeof rawHist === 'string' ? rawHist : '[]'
      PavilionStore.history = PavilionStore.parseIdList(histStr)
      const dark = await PavilionStore.pref.get(KEY_DARK, false)
      AppStorage.setOrCreate('darkModeOn', dark === true)
      PavilionStore.cacheArticles = await PavilionStore.readStr(KEY_CAT_ART)
      PavilionStore.cacheDaily = await PavilionStore.readStr(KEY_CAT_DAY)
      PavilionStore.cacheCols = await PavilionStore.readStr(KEY_CAT_COL)
    } catch {
      PavilionStore.favorites = []
      PavilionStore.history = []
    }
  }

  static catalog(kind: string): string {
    if (kind === 'daily') {
      return PavilionStore.cacheDaily
    }
    if (kind === 'collections') {
      return PavilionStore.cacheCols
    }
    return PavilionStore.cacheArticles
  }

  static async saveCatalog(kind: string, raw: string): Promise<void> {
    if (raw.length < 8) {
      return
    }
    if (kind === 'daily') {
      PavilionStore.cacheDaily = raw
      await PavilionStore.putStr(KEY_CAT_DAY, raw)
      return
    }
    if (kind === 'collections') {
      PavilionStore.cacheCols = raw
      await PavilionStore.putStr(KEY_CAT_COL, raw)
      return
    }
    PavilionStore.cacheArticles = raw
    await PavilionStore.putStr(KEY_CAT_ART, raw)
  }

  static isFavorite(id: string): boolean {
    return PavilionStore.contains(PavilionStore.favorites, id)
  }

  static favoriteIds(): string[] {
    const copy: string[] = []
    for (const id of PavilionStore.favorites) {
      copy.push(id)
    }
    return copy
  }

  static historyIds(): string[] {
    const copy: string[] = []
    for (const id of PavilionStore.history) {
      copy.push(id)
    }
    return copy
  }

  static stats(): PavilionStats {
    const s = new PavilionStats()
    s.favorites = PavilionStore.favorites.length
    s.reads = PavilionStore.history.length
    s.notes = ExploreStore.noteCount()
    s.cards = ExploreStore.cardCount()
    s.days = ExploreStore.dayCount()
    s.logs = JournalStore.logCount()
    s.finds = JournalStore.findCount()
    s.wishes = JournalStore.wishDoneCount()
    s.tasks = ExploreStore.taskDoneCount()
    return s
  }

  static async toggleFavorite(id: string): Promise<boolean> {
    if (PavilionStore.isFavorite(id)) {
      PavilionStore.favorites = PavilionStore.removeId(PavilionStore.favorites, id)
      await PavilionStore.flushIds(KEY_FAVORITES, PavilionStore.favorites)
      PavilionStore.bump()
      return false
    }
    PavilionStore.favorites = PavilionStore.prependId(PavilionStore.favorites, id)
    await PavilionStore.flushIds(KEY_FAVORITES, PavilionStore.favorites)
    PavilionStore.bump()
    return true
  }

  static async markRead(id: string): Promise<void> {
    if (id.length === 0) {
      return
    }
    PavilionStore.history = PavilionStore.removeId(PavilionStore.history, id)
    PavilionStore.history = PavilionStore.prependId(PavilionStore.history, id)
    await PavilionStore.flushIds(KEY_HISTORY, PavilionStore.history)
    await ExploreStore.touchDay()
  }

  static async setDark(on: boolean): Promise<void> {
    AppStorage.setOrCreate('darkModeOn', on)
    if (PavilionStore.pref !== null) {
      await PavilionStore.pref.put(KEY_DARK, on)
      await PavilionStore.pref.flush()
    }
  }

  static async clearCache(): Promise<void> {
    PavilionStore.cacheArticles = ''
    PavilionStore.cacheDaily = ''
    PavilionStore.cacheCols = ''
    await PavilionStore.putStr(KEY_CAT_ART, '')
    await PavilionStore.putStr(KEY_CAT_DAY, '')
    await PavilionStore.putStr(KEY_CAT_COL, '')
    PavilionStore.bump()
  }

  private static async readStr(key: string): Promise<string> {
    if (PavilionStore.pref === null) {
      return ''
    }
    const raw = await PavilionStore.pref.get(key, '')
    return typeof raw === 'string' ? raw : ''
  }

  private static async putStr(key: string, value: string): Promise<void> {
    if (PavilionStore.pref === null) {
      return
    }
    await PavilionStore.pref.put(key, value)
    await PavilionStore.pref.flush()
  }

  private static bump(): void {
    PavilionDetailNav.bumpRefresh()
  }

  private static contains(list: string[], id: string): boolean {
    for (const row of list) {
      if (row === id) {
        return true
      }
    }
    return false
  }

  private static prependId(list: string[], id: string): string[] {
    const next: string[] = [id]
    for (const row of list) {
      if (row !== id) {
        next.push(row)
      }
    }
    return next
  }

  private static removeId(list: string[], id: string): string[] {
    const next: string[] = []
    for (const row of list) {
      if (row !== id) {
        next.push(row)
      }
    }
    return next
  }

  private static parseIdList(text: string): string[] {
    const out: string[] = []
    if (text.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(text) as string[]
      for (const id of parsed) {
        out.push(id)
      }
    } catch {
      return out
    }
    return out
  }

  private static async flushIds(key: string, ids: string[]): Promise<void> {
    if (PavilionStore.pref === null) {
      return
    }
    let json = '['
    for (let i = 0; i < ids.length; i++) {
      if (i > 0) {
        json += ','
      }
      json += JSON.stringify(ids[i])
    }
    json += ']'
    await PavilionStore.pref.put(key, json)
    await PavilionStore.pref.flush()
  }
}
