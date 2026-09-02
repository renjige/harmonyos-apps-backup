import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { FavoriteSnapshot, InspirationItem } from '../models/LanguageCraftModels'
import { AppRefresh } from './AppRefresh'
import { AppStoreContext } from './AppStoreContext'

/** 灵感收藏 — Preferences 本机存储 */
export class FavoriteStore {
  private static readonly STORE: string = 'yanyu_favorites'
  private static readonly KEY: string = 'items'
  private static prefs: preferences.Preferences | null = null

  static async init(context: common.Context): Promise<void> {
    AppStoreContext.bind(context)
    if (FavoriteStore.prefs !== null) {
      return
    }
    FavoriteStore.prefs = await preferences.getPreferences(context, FavoriteStore.STORE)
  }

  private static async ensureReady(): Promise<boolean> {
    if (FavoriteStore.prefs !== null) {
      return true
    }
    const ctx = AppStoreContext.get()
    if (ctx === null) {
      return false
    }
    try {
      FavoriteStore.prefs = await preferences.getPreferences(ctx, FavoriteStore.STORE)
      return FavoriteStore.prefs !== null
    } catch {
      return false
    }
  }

  static async list(): Promise<FavoriteSnapshot[]> {
    return FavoriteStore.readRaw()
  }

  static async count(): Promise<number> {
    const raw = await FavoriteStore.readRaw()
    return raw.length
  }

  static async isFavorited(inspirationId: string): Promise<boolean> {
    const raw = await FavoriteStore.readRaw()
    for (const row of raw) {
      if (row.inspirationId === inspirationId) {
        return true
      }
    }
    return false
  }

  static async add(item: InspirationItem): Promise<void> {
    const raw = await FavoriteStore.readRaw()
    const filtered: FavoriteSnapshot[] = []
    for (const row of raw) {
      if (row.inspirationId !== item.id) {
        filtered.push(row)
      }
    }
    const snap = new FavoriteSnapshot()
    snap.inspirationId = item.id
    snap.title = item.title
    snap.category = item.category
    snap.summary = item.summary
    snap.coverKey = item.coverKey
    snap.favoritedAt = new Date().toISOString()
    filtered.unshift(snap)
    await FavoriteStore.writeRaw(filtered)
    AppRefresh.bumpFav()
  }

  static async remove(inspirationId: string): Promise<void> {
    const raw = await FavoriteStore.readRaw()
    const filtered: FavoriteSnapshot[] = []
    for (const row of raw) {
      if (row.inspirationId !== inspirationId) {
        filtered.push(row)
      }
    }
    await FavoriteStore.writeRaw(filtered)
    AppRefresh.bumpFav()
  }

  static async toggle(item: InspirationItem): Promise<boolean> {
    const fav = await FavoriteStore.isFavorited(item.id)
    if (fav) {
      await FavoriteStore.remove(item.id)
      return false
    }
    await FavoriteStore.add(item)
    return true
  }

  private static async readRaw(): Promise<FavoriteSnapshot[]> {
    const ready = await FavoriteStore.ensureReady()
    if (!ready || FavoriteStore.prefs === null) {
      return []
    }
    const text = await FavoriteStore.prefs.get(FavoriteStore.KEY, '[]') as string
    try {
      const parsed = JSON.parse(text) as FavoriteSnapshot[]
      if (Array.isArray(parsed)) {
        return parsed
      }
    } catch {
      return []
    }
    return []
  }

  private static async writeRaw(items: FavoriteSnapshot[]): Promise<void> {
    const ready = await FavoriteStore.ensureReady()
    if (!ready || FavoriteStore.prefs === null) {
      return
    }
    await FavoriteStore.prefs.put(FavoriteStore.KEY, JSON.stringify(items))
    await FavoriteStore.prefs.flush()
  }
}
