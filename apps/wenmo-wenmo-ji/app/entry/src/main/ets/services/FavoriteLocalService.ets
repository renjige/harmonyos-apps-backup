import { preferences } from '@kit.ArkData'
import { WisdomItem } from '../models/WisdomHallModels'

class LocalFavoriteEntry {
  quoteId: string = ''
  title: string = ''
  authorName: string = ''
  category: string = ''
  favoritedAt: string = ''
}

/** 游客与离线收藏：Preferences 持久化 */
export class FavoriteLocalService {
  private static readonly STORE: string = 'zhiyu_favorites'
  private static readonly KEY: string = 'items'
  private static prefs: preferences.Preferences | null = null

  static async init(context: Context): Promise<void> {
    if (FavoriteLocalService.prefs !== null) {
      return
    }
    FavoriteLocalService.prefs = await preferences.getPreferences(context, FavoriteLocalService.STORE)
  }

  static async list(): Promise<WisdomItem[]> {
    const raw = await FavoriteLocalService.readRaw()
    const out: WisdomItem[] = []
    for (const row of raw) {
      const item = new WisdomItem()
      item.id = row.quoteId
      item.targetId = row.quoteId
      item.targetKind = 'quote'
      item.title = row.title
      item.authorName = row.authorName
      item.category = row.category
      item.createdAt = row.favoritedAt
      out.push(item)
    }
    out.sort((a, b) => b.createdAt.localeCompare(a.createdAt))
    return out
  }

  static async count(): Promise<number> {
    const raw = await FavoriteLocalService.readRaw()
    return raw.length
  }

  static async isFavorited(quoteId: string): Promise<boolean> {
    const raw = await FavoriteLocalService.readRaw()
    for (const row of raw) {
      if (row.quoteId === quoteId) {
        return true
      }
    }
    return false
  }

  static async add(quote: WisdomItem): Promise<void> {
    const raw = await FavoriteLocalService.readRaw()
    const filtered: LocalFavoriteEntry[] = []
    for (const row of raw) {
      if (row.quoteId !== quote.id) {
        filtered.push(row)
      }
    }
    const entry = new LocalFavoriteEntry()
    entry.quoteId = quote.id
    entry.title = quote.title
    entry.authorName = quote.authorName
    entry.category = quote.category
    entry.favoritedAt = new Date().toISOString()
    filtered.unshift(entry)
    await FavoriteLocalService.writeRaw(filtered)
  }

  static async remove(quoteId: string): Promise<void> {
    const raw = await FavoriteLocalService.readRaw()
    const filtered: LocalFavoriteEntry[] = []
    for (const row of raw) {
      if (row.quoteId !== quoteId) {
        filtered.push(row)
      }
    }
    await FavoriteLocalService.writeRaw(filtered)
  }

  private static async readRaw(): Promise<LocalFavoriteEntry[]> {
    if (FavoriteLocalService.prefs === null) {
      return []
    }
    const text = await FavoriteLocalService.prefs.get(FavoriteLocalService.KEY, '[]') as string
    try {
      const parsed = JSON.parse(text) as LocalFavoriteEntry[]
      if (Array.isArray(parsed)) {
        return parsed
      }
    } catch {
      return []
    }
    return []
  }

  private static async writeRaw(items: LocalFavoriteEntry[]): Promise<void> {
    if (FavoriteLocalService.prefs === null) {
      return
    }
    await FavoriteLocalService.prefs.put(FavoriteLocalService.KEY, JSON.stringify(items))
    await FavoriteLocalService.prefs.flush()
  }
}
