import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { BrochureBizService } from './BrochureBizService'
import { AuthService } from './AuthService'

const STORE_NAME = 'jz_favorites'
const KEY_IDS = 'brochureIds'
const KEY_API_MAP = 'apiMap'

class FavApiEntry {
  brochureId: string = ''
  apiId: string = ''
}

/**
 * 简章收藏 — 游客本地 Preferences；登录后同步 /biz/enrollment-guide/favorites。
 */
export class FavoriteService {
  private static pref: preferences.Preferences | null = null
  private static ids: string[] = []
  private static apiMap: FavApiEntry[] = []
  private static ready: boolean = false

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      FavoriteService.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await FavoriteService.pref.get(KEY_IDS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      FavoriteService.ids = FavoriteService.parseIds(text)
      const rawMap = await FavoriteService.pref.get(KEY_API_MAP, '[]')
      const mapText: string = typeof rawMap === 'string' ? rawMap : '[]'
      FavoriteService.apiMap = FavoriteService.parseApiMap(mapText)
      FavoriteService.ready = true
      AppStorage.setOrCreate('favoriteTick', 0)
    } catch {
      FavoriteService.ids = []
      FavoriteService.apiMap = []
      FavoriteService.ready = true
    }
  }

  static isReady(): boolean {
    return FavoriteService.ready
  }

  static listIds(): string[] {
    const out: string[] = []
    for (let id of FavoriteService.ids) {
      out.push(id)
    }
    return out
  }

  static count(): number {
    return FavoriteService.ids.length
  }

  static isFavorite(brochureId: string): boolean {
    for (let id of FavoriteService.ids) {
      if (id === brochureId) {
        return true
      }
    }
    return false
  }

  static async toggle(brochureId: string, title: string): Promise<boolean> {
    if (brochureId.length === 0) {
      return false
    }
    if (FavoriteService.isFavorite(brochureId)) {
      await FavoriteService.remove(brochureId)
      return false
    }
    await FavoriteService.add(brochureId, title)
    return true
  }

  static async add(brochureId: string, title: string): Promise<void> {
    if (FavoriteService.isFavorite(brochureId)) {
      return
    }
    FavoriteService.ids.push(brochureId)
    await FavoriteService.persist()
    if (AuthService.isLoggedIn()) {
      const user = AuthService.currentUsername()
      const row = await BrochureBizService.addFavorite(user, title, brochureId)
      if (row !== undefined) {
        FavoriteService.setApiId(brochureId, row.id)
        await FavoriteService.persistApiMap()
      }
    }
  }

  static async remove(brochureId: string): Promise<void> {
    const next: string[] = []
    for (let id of FavoriteService.ids) {
      if (id !== brochureId) {
        next.push(id)
      }
    }
    FavoriteService.ids = next
    await FavoriteService.persist()
    if (AuthService.isLoggedIn()) {
      const apiId = FavoriteService.apiIdOf(brochureId)
      if (apiId.length > 0) {
        const user = AuthService.currentUsername()
        await BrochureBizService.removeFavorite(apiId, user)
        FavoriteService.removeApiEntry(brochureId)
        await FavoriteService.persistApiMap()
      }
    }
  }

  static async syncFromServer(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const user = AuthService.currentUsername()
    const remote = await BrochureBizService.loadFavorites(user)
    const merged: string[] = []
    for (let id of FavoriteService.ids) {
      merged.push(id)
    }
    for (let row of remote) {
      if (row.targetId.length > 0 && !FavoriteService.containsId(merged, row.targetId)) {
        merged.push(row.targetId)
      }
      FavoriteService.setApiId(row.targetId, row.id)
    }
    FavoriteService.ids = merged
    await FavoriteService.persist()
    await FavoriteService.persistApiMap()
  }

  private static containsId(list: string[], id: string): boolean {
    for (let x of list) {
      if (x === id) {
        return true
      }
    }
    return false
  }

  private static apiIdOf(brochureId: string): string {
    for (let row of FavoriteService.apiMap) {
      if (row.brochureId === brochureId) {
        return row.apiId
      }
    }
    return ''
  }

  private static setApiId(brochureId: string, apiId: string): void {
    FavoriteService.removeApiEntry(brochureId)
    const entry = new FavApiEntry()
    entry.brochureId = brochureId
    entry.apiId = apiId
    FavoriteService.apiMap.push(entry)
  }

  private static removeApiEntry(brochureId: string): void {
    const next: FavApiEntry[] = []
    for (let row of FavoriteService.apiMap) {
      if (row.brochureId !== brochureId) {
        next.push(row)
      }
    }
    FavoriteService.apiMap = next
  }

  private static async persist(): Promise<void> {
    const json = JSON.stringify(FavoriteService.ids)
    if (FavoriteService.pref !== null) {
      await FavoriteService.pref.put(KEY_IDS, json)
      await FavoriteService.pref.flush()
    }
    const tick = AppStorage.get<number>('favoriteTick') ?? 0
    AppStorage.setOrCreate('favoriteTick', tick + 1)
  }

  private static async persistApiMap(): Promise<void> {
    const payload: ApiMapWire[] = []
    for (let row of FavoriteService.apiMap) {
      const w = new ApiMapWire()
      w.brochureId = row.brochureId
      w.apiId = row.apiId
      payload.push(w)
    }
    const json = JSON.stringify(payload)
    if (FavoriteService.pref !== null) {
      await FavoriteService.pref.put(KEY_API_MAP, json)
      await FavoriteService.pref.flush()
    }
  }

  private static parseIds(raw: string): string[] {
    try {
      const parsed = JSON.parse(raw) as string[]
      const out: string[] = []
      for (let id of parsed) {
        if (typeof id === 'string' && id.length > 0) {
          out.push(id)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseApiMap(raw: string): FavApiEntry[] {
    try {
      const parsed = JSON.parse(raw) as ApiMapWire[]
      const out: FavApiEntry[] = []
      for (let row of parsed) {
        if (row.brochureId.length > 0 && row.apiId.length > 0) {
          const e = new FavApiEntry()
          e.brochureId = row.brochureId
          e.apiId = row.apiId
          out.push(e)
        }
      }
      return out
    } catch {
      return []
    }
  }
}

class ApiMapWire {
  brochureId: string = ''
  apiId: string = ''
}
