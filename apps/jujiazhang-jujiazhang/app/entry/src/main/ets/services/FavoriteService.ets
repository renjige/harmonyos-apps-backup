import { FavoriteRecord } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'
import { ActivityService } from './ActivityService'

export class FavoriteService {
  static isFavorite(targetType: string, targetId: string): boolean {
    for (const row of JujiaLocalStore.favorites()) {
      if (row.targetType === targetType && row.targetId === targetId) {
        return true
      }
    }
    return false
  }

  static async toggle(targetType: string, targetId: string, title: string): Promise<boolean> {
    if (FavoriteService.isFavorite(targetType, targetId)) {
      await FavoriteService.remove(targetType, targetId)
      return false
    }
    await FavoriteService.add(targetType, targetId, title)
    return true
  }

  static async add(targetType: string, targetId: string, title: string): Promise<void> {
    const rows = JujiaLocalStore.favorites().slice()
    const fav = new FavoriteRecord()
    fav.id = JujiaLocalStore.newId('fav')
    fav.targetType = targetType
    fav.targetId = targetId
    fav.title = title
    fav.createdAt = JujiaLocalStore.nowIso()
    rows.unshift(fav)
    await JujiaLocalStore.saveFavorites(rows)
    await ActivityService.log('favorite', targetType, targetId, title, '已加入收藏')
  }

  static async remove(targetType: string, targetId: string): Promise<void> {
    const next: FavoriteRecord[] = []
    for (const row of JujiaLocalStore.favorites()) {
      if (row.targetType !== targetType || row.targetId !== targetId) {
        next.push(row)
      }
    }
    await JujiaLocalStore.saveFavorites(next)
  }

  static list(typeFilter: string = 'all'): FavoriteRecord[] {
    if (typeFilter === 'all') {
      return JujiaLocalStore.favorites()
    }
    const out: FavoriteRecord[] = []
    for (const row of JujiaLocalStore.favorites()) {
      if (row.targetType === typeFilter) {
        out.push(row)
      }
    }
    return out
  }

  static countAll(): number {
    return JujiaLocalStore.favorites().length
  }
}
