import { SessionStore } from './SessionStore'

/**
 * 收藏场馆（本机 Preferences）。游客可收藏；审核员可演示「写入」而非纯浏览。
 */
export class CourtFavoriteStore {
  static listIds(): string[] {
    const raw = AppStorage.get<string>('courtFavoriteIds') ?? ''
    if (raw.length === 0) {
      return []
    }
    return raw.split(',')
  }

  static isFavorite(venueId: string): boolean {
    if (venueId.length === 0) {
      return false
    }
    const ids = CourtFavoriteStore.listIds()
    for (let id of ids) {
      if (id === venueId) {
        return true
      }
    }
    return false
  }

  static count(): number {
    return CourtFavoriteStore.listIds().length
  }

  static async toggle(venueId: string): Promise<boolean> {
    if (venueId.length === 0) {
      return false
    }
    const next: string[] = []
    let found = false
    for (let id of CourtFavoriteStore.listIds()) {
      if (id === venueId) {
        found = true
      } else if (id.length > 0) {
        next.push(id)
      }
    }
    if (!found) {
      next.push(venueId)
    }
    const csv = next.join(',')
    AppStorage.setOrCreate('courtFavoriteIds', csv)
    await SessionStore.saveFavorites(csv)
    return !found
  }
}
