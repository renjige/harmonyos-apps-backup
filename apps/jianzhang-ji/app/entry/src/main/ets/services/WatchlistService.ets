import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { BrochureBizService } from './BrochureBizService'
import { AuthService } from './AuthService'

const STORE_NAME = 'jz_watchlist'
const KEY_IDS = 'brochureIds'
const KEY_API_MAP = 'apiMap'

class WatchApiEntry {
  brochureId: string = ''
  apiId: string = ''
}

/** 关注院校 — 游客本地；登录后同步 /biz/enrollment-guide/watchlist。 */
export class WatchlistService {
  private static pref: preferences.Preferences | null = null
  private static ids: string[] = []
  private static apiMap: WatchApiEntry[] = []
  private static ready: boolean = false

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      WatchlistService.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await WatchlistService.pref.get(KEY_IDS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      WatchlistService.ids = WatchlistService.parseIds(text)
      const rawMap = await WatchlistService.pref.get(KEY_API_MAP, '[]')
      const mapText: string = typeof rawMap === 'string' ? rawMap : '[]'
      WatchlistService.apiMap = WatchlistService.parseApiMap(mapText)
      WatchlistService.ready = true
      AppStorage.setOrCreate('watchTick', 0)
    } catch {
      WatchlistService.ids = []
      WatchlistService.apiMap = []
      WatchlistService.ready = true
    }
  }

  static listIds(): string[] {
    const out: string[] = []
    for (let id of WatchlistService.ids) {
      out.push(id)
    }
    return out
  }

  static count(): number {
    return WatchlistService.ids.length
  }

  static isWatching(brochureId: string): boolean {
    for (let id of WatchlistService.ids) {
      if (id === brochureId) {
        return true
      }
    }
    return false
  }

  static async toggle(brochureId: string, title: string): Promise<boolean> {
    if (WatchlistService.isWatching(brochureId)) {
      await WatchlistService.remove(brochureId)
      return false
    }
    await WatchlistService.add(brochureId, title)
    return true
  }

  static async add(brochureId: string, title: string): Promise<void> {
    if (WatchlistService.isWatching(brochureId)) {
      return
    }
    WatchlistService.ids.push(brochureId)
    await WatchlistService.persist()
    if (AuthService.isLoggedIn()) {
      const user = AuthService.currentUsername()
      const row = await BrochureBizService.addWatchlist(user, title, brochureId)
      if (row !== undefined) {
        WatchlistService.setApiId(brochureId, row.id)
        await WatchlistService.persistApiMap()
      }
    }
  }

  static async remove(brochureId: string): Promise<void> {
    const next: string[] = []
    for (let id of WatchlistService.ids) {
      if (id !== brochureId) {
        next.push(id)
      }
    }
    WatchlistService.ids = next
    await WatchlistService.persist()
    if (AuthService.isLoggedIn()) {
      const apiId = WatchlistService.apiIdOf(brochureId)
      if (apiId.length > 0) {
        const user = AuthService.currentUsername()
        await BrochureBizService.removeWatchlist(apiId, user)
        WatchlistService.removeApiEntry(brochureId)
        await WatchlistService.persistApiMap()
      }
    }
  }

  static async syncFromServer(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const user = AuthService.currentUsername()
    const remote = await BrochureBizService.loadWatchlist(user)
    const merged: string[] = []
    for (let id of WatchlistService.ids) {
      merged.push(id)
    }
    for (let row of remote) {
      if (row.targetId.length > 0 && !WatchlistService.containsId(merged, row.targetId)) {
        merged.push(row.targetId)
      }
      WatchlistService.setApiId(row.targetId, row.id)
    }
    WatchlistService.ids = merged
    await WatchlistService.persist()
    await WatchlistService.persistApiMap()
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
    for (let row of WatchlistService.apiMap) {
      if (row.brochureId === brochureId) {
        return row.apiId
      }
    }
    return ''
  }

  private static setApiId(brochureId: string, apiId: string): void {
    WatchlistService.removeApiEntry(brochureId)
    const entry = new WatchApiEntry()
    entry.brochureId = brochureId
    entry.apiId = apiId
    WatchlistService.apiMap.push(entry)
  }

  private static removeApiEntry(brochureId: string): void {
    const next: WatchApiEntry[] = []
    for (let row of WatchlistService.apiMap) {
      if (row.brochureId !== brochureId) {
        next.push(row)
      }
    }
    WatchlistService.apiMap = next
  }

  private static async persist(): Promise<void> {
    const json = JSON.stringify(WatchlistService.ids)
    if (WatchlistService.pref !== null) {
      await WatchlistService.pref.put(KEY_IDS, json)
      await WatchlistService.pref.flush()
    }
    const tick = AppStorage.get<number>('watchTick') ?? 0
    AppStorage.setOrCreate('watchTick', tick + 1)
  }

  private static async persistApiMap(): Promise<void> {
    const payload: WatchMapWire[] = []
    for (let row of WatchlistService.apiMap) {
      const w = new WatchMapWire()
      w.brochureId = row.brochureId
      w.apiId = row.apiId
      payload.push(w)
    }
    const json = JSON.stringify(payload)
    if (WatchlistService.pref !== null) {
      await WatchlistService.pref.put(KEY_API_MAP, json)
      await WatchlistService.pref.flush()
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

  private static parseApiMap(raw: string): WatchApiEntry[] {
    try {
      const parsed = JSON.parse(raw) as WatchMapWire[]
      const out: WatchApiEntry[] = []
      for (let row of parsed) {
        if (row.brochureId.length > 0 && row.apiId.length > 0) {
          const e = new WatchApiEntry()
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

class WatchMapWire {
  brochureId: string = ''
  apiId: string = ''
}
