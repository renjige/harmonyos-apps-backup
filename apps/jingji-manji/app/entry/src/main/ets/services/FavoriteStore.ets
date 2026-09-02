import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { FavoriteCollection, FavoriteItem } from '../models/SportModels'

const STORE_NAME = 'sport_favorite_v1'
const KEY_ITEMS = 'favorite_items_json'
const KEY_COLLECTIONS = 'favorite_collections_json'

export class FavoriteStore {
  private static pref: preferences.Preferences | null = null
  private static items: FavoriteItem[] = []
  private static collections: FavoriteCollection[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      FavoriteStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const rawItems = await FavoriteStore.pref.get(KEY_ITEMS, '[]')
      const rawCols = await FavoriteStore.pref.get(KEY_COLLECTIONS, '[]')
      FavoriteStore.items = FavoriteStore.parseItems(typeof rawItems === 'string' ? rawItems : '[]')
      FavoriteStore.collections = FavoriteStore.parseCollections(typeof rawCols === 'string' ? rawCols : '[]')
      if (FavoriteStore.collections.length === 0) {
        const c = new FavoriteCollection()
        c.id = 'default'
        c.name = '我的收藏'
        c.createdAt = new Date().toISOString()
        FavoriteStore.collections.push(c)
        await FavoriteStore.flush()
      }
    } catch {
      FavoriteStore.items = []
      FavoriteStore.collections = []
    }
  }

  static list(): FavoriteItem[] {
    return FavoriteStore.items.slice()
  }

  static count(): number {
    return FavoriteStore.items.length
  }

  static isFavorite(targetType: string, targetId: string): boolean {
    for (const item of FavoriteStore.items) {
      if (item.targetType === targetType && item.targetId === targetId) {
        return true
      }
    }
    return false
  }

  static async toggleRecord(recordId: string): Promise<boolean> {
    if (FavoriteStore.isFavorite('record', recordId)) {
      await FavoriteStore.removeByTarget('record', recordId)
      return false
    }
    const item = new FavoriteItem()
    item.id = `fav_${Date.now()}`
    item.targetType = 'record'
    item.targetId = recordId
    item.collectionId = 'default'
    item.createdAt = new Date().toISOString()
    FavoriteStore.items.push(item)
    await FavoriteStore.flush()
    return true
  }

  static async removeByTarget(targetType: string, targetId: string): Promise<void> {
    const next: FavoriteItem[] = []
    for (const item of FavoriteStore.items) {
      if (item.targetType !== targetType || item.targetId !== targetId) {
        next.push(item)
      }
    }
    FavoriteStore.items = next
    await FavoriteStore.flush()
  }

  static async removeByRecordId(recordId: string): Promise<void> {
    await FavoriteStore.removeByTarget('record', recordId)
  }

  private static async flush(): Promise<void> {
    if (FavoriteStore.pref === null) {
      return
    }
    await FavoriteStore.pref.put(KEY_ITEMS, JSON.stringify(FavoriteStore.items))
    await FavoriteStore.pref.put(KEY_COLLECTIONS, JSON.stringify(FavoriteStore.collections))
    await FavoriteStore.pref.flush()
  }

  private static parseItems(text: string): FavoriteItem[] {
    try {
      const arr = JSON.parse(text) as object[]
      const out: FavoriteItem[] = []
      for (const raw of arr) {
        const o = raw as Record<string, string>
        const item = new FavoriteItem()
        item.id = o['id'] ?? ''
        item.targetType = o['targetType'] ?? 'record'
        item.targetId = o['targetId'] ?? ''
        item.collectionId = o['collectionId'] ?? 'default'
        item.createdAt = o['createdAt'] ?? ''
        if (item.id.length > 0) {
          out.push(item)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseCollections(text: string): FavoriteCollection[] {
    try {
      const arr = JSON.parse(text) as object[]
      const out: FavoriteCollection[] = []
      for (const raw of arr) {
        const o = raw as Record<string, string>
        const c = new FavoriteCollection()
        c.id = o['id'] ?? ''
        c.name = o['name'] ?? '我的收藏'
        c.createdAt = o['createdAt'] ?? ''
        if (c.id.length > 0) {
          out.push(c)
        }
      }
      return out
    } catch {
      return []
    }
  }
}
