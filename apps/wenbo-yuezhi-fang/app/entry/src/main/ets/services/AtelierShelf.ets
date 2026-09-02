import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { FavoriteItem, FavoriteListPayload } from '../models/AtelierModels'

const STORE_NAME = 'yuezhifang_local'
const KEY_SHELF = 'shelf_json'

/** 书坊本机缓存：API 失败时仍能看见自己刚收入的篇目 */
export class AtelierShelf {
  private static pref: preferences.Preferences | null = null
  private static items: FavoriteItem[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      AtelierShelf.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await AtelierShelf.pref.get(KEY_SHELF, '{"list":[]}')
      const text: string = typeof raw === 'string' ? raw : '{"list":[]}'
      AtelierShelf.items = AtelierShelf.decode(text)
    } catch {
      AtelierShelf.items = []
    }
  }

  static allForUser(userId: string): FavoriteItem[] {
    const out: FavoriteItem[] = []
    if (userId.length === 0) {
      return out
    }
    for (const row of AtelierShelf.items) {
      if (row.userId === userId && row.contentType !== 'post') {
        out.push(row)
      }
    }
    return out
  }

  static async upsert(item: FavoriteItem): Promise<void> {
    if (item.contentId.length === 0) {
      return
    }
    const next: FavoriteItem[] = []
    let replaced = false
    for (const row of AtelierShelf.items) {
      if (row.contentId === item.contentId && row.userId === item.userId) {
        next.push(item)
        replaced = true
      } else {
        next.push(row)
      }
    }
    if (!replaced) {
      next.unshift(item)
    }
    AtelierShelf.items = next
    await AtelierShelf.flush()
  }

  static async removeById(id: string, contentId: string, userId: string): Promise<void> {
    const next: FavoriteItem[] = []
    for (const row of AtelierShelf.items) {
      const sameId = id.length > 0 && row.id === id
      const sameContent = row.contentId === contentId && row.userId === userId
      if (sameId || sameContent) {
        continue
      }
      next.push(row)
    }
    AtelierShelf.items = next
    await AtelierShelf.flush()
  }

  static async clearUser(userId: string): Promise<void> {
    const next: FavoriteItem[] = []
    for (const row of AtelierShelf.items) {
      if (row.userId !== userId) {
        next.push(row)
      }
    }
    AtelierShelf.items = next
    await AtelierShelf.flush()
  }

  private static decode(text: string): FavoriteItem[] {
    const out: FavoriteItem[] = []
    try {
      const parsed = JSON.parse(text) as FavoriteListPayload
      if (parsed === undefined || parsed.list === undefined) {
        return out
      }
      for (const w of parsed.list) {
        const item = FavoriteItem.fromWire(w)
        if (item.contentId.length > 0) {
          out.push(item)
        }
      }
    } catch {
      return out
    }
    return out
  }

  private static async flush(): Promise<void> {
    if (AtelierShelf.pref === null) {
      return
    }
    let json = '{"list":['
    for (let i = 0; i < AtelierShelf.items.length; i++) {
      if (i > 0) {
        json += ','
      }
      json += AtelierShelf.items[i].toJsonString()
    }
    json += ']}'
    await AtelierShelf.pref.put(KEY_SHELF, json)
    await AtelierShelf.pref.flush()
  }
}
