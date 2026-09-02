import {
  ApiResponse,
  EmptyPayload,
  FavoriteRowWire,
  FavoriteSyncRow,
  FavoriteToggleRequest,
  FavoritesSyncRequest,
  HistoryPushRequest,
  HistoryRowWire
} from '../models/ApiModels'
import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'

/** 登录用户收藏 / 浏览记录与 SaaS /me/* 同步 */
export class UserPrefsSyncService {
  private static favStorageKey(): string {
    return 'zhuke_favorites'
  }

  private static historyStorageKey(): string {
    return 'zhuke_history'
  }

  private static canSync(): boolean {
    return AuthService.isLoggedIn()
  }

  static async pull(): Promise<void> {
    if (!UserPrefsSyncService.canSync()) {
      return
    }
    await UserPrefsSyncService.pullFavorites()
    await UserPrefsSyncService.pullHistory()
  }

  private static async pullFavorites(): Promise<void> {
    try {
      const res: ApiResponse<FavoriteRowWire[]> = await HttpClient.get<FavoriteRowWire[]>('/me/favorites')
      if (res.code !== 0 || res.data === undefined) {
        return
      }
      const rows = res.data
      if (rows.length === 0) {
        return
      }
      const parts: string[] = []
      for (const row of rows) {
        parts.push(`${row.type}:${row.id}::${row.title}`)
      }
      AppStorage.setOrCreate(UserPrefsSyncService.favStorageKey(), parts.join('|'))
    } catch {
      // 离线或未登录时忽略
    }
  }

  private static async pullHistory(): Promise<void> {
    try {
      const res: ApiResponse<HistoryRowWire[]> = await HttpClient.get<HistoryRowWire[]>('/me/history')
      if (res.code !== 0 || res.data === undefined) {
        return
      }
      const rows = res.data
      if (rows.length === 0) {
        return
      }
      const parts: string[] = []
      for (const row of rows) {
        parts.push(`${row.type}:${row.id}::${row.title}::${row.viewedAt}`)
      }
      AppStorage.setOrCreate(UserPrefsSyncService.historyStorageKey(), parts.join('|'))
    } catch {
      // 离线或未登录时忽略
    }
  }

  static pushFavoriteToggle(type: string, id: string, title: string): void {
    if (!UserPrefsSyncService.canSync()) {
      return
    }
    const body = new FavoriteToggleRequest()
    body.type = type
    body.id = id
    body.title = title
    UserPrefsSyncService.firePut('/me/favorites/toggle', body)
  }

  static pushFavoritesSnapshot(): void {
    if (!UserPrefsSyncService.canSync()) {
      return
    }
    const req = new FavoritesSyncRequest()
    req.favorites = UserPrefsSyncService.parseLocalFavorites()
    UserPrefsSyncService.firePut('/me/favorites/sync', req)
  }

  static pushHistory(type: string, id: string, title: string): void {
    if (!UserPrefsSyncService.canSync()) {
      return
    }
    const body = new HistoryPushRequest()
    body.type = type
    body.id = id
    body.title = title
    UserPrefsSyncService.firePut('/me/history', body)
  }

  static pushClearHistory(): void {
    if (!UserPrefsSyncService.canSync()) {
      return
    }
    UserPrefsSyncService.fireDelete('/me/history')
  }

  private static firePut(path: string, body: object): void {
    HttpClient.put<EmptyPayload>(path, body).then(() => {
      return
    }).catch(() => {
      return
    })
  }

  private static fireDelete(path: string): void {
    HttpClient.delete<EmptyPayload>(path, new EmptyPayload()).then(() => {
      return
    }).catch(() => {
      return
    })
  }

  private static parseLocalFavorites(): FavoriteSyncRow[] {
    const raw = AppStorage.get<string>(UserPrefsSyncService.favStorageKey()) ?? ''
    const rows: FavoriteSyncRow[] = []
    if (raw.length === 0) {
      return rows
    }
    const parts = raw.split('|')
    for (const p of parts) {
      const segs = p.split('::')
      if (segs.length < 2) {
        continue
      }
      const idParts = segs[0].split(':')
      if (idParts.length < 2) {
        continue
      }
      const row = new FavoriteSyncRow()
      row.type = idParts[0]
      row.id = idParts[1]
      row.title = segs[1]
      row.createdAt = new Date().toISOString()
      rows.push(row)
    }
    return rows
  }
}
