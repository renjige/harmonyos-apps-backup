import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE_NAME = 'career_favorites'
const KEY_IDS = 'courseIds'

/**
 * 课程收藏 — 本地 Preferences 持久化（游客登录后仍可保留）。
 */
export class FavoriteService {
  private static pref: preferences.Preferences | null = null
  private static ids: string[] = []
  private static ready: boolean = false

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      FavoriteService.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await FavoriteService.pref.get(KEY_IDS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      FavoriteService.ids = FavoriteService.parseIds(text)
      FavoriteService.ready = true
      AppStorage.setOrCreate('favoriteTick', 0)
    } catch {
      FavoriteService.ids = []
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

  static isFavorite(courseId: string): boolean {
    for (let id of FavoriteService.ids) {
      if (id === courseId) {
        return true
      }
    }
    return false
  }

  static async toggle(courseId: string): Promise<boolean> {
    if (courseId.length === 0) {
      return false
    }
    if (FavoriteService.isFavorite(courseId)) {
      await FavoriteService.remove(courseId)
      return false
    }
    await FavoriteService.add(courseId)
    return true
  }

  static async add(courseId: string): Promise<void> {
    if (FavoriteService.isFavorite(courseId)) {
      return
    }
    FavoriteService.ids.push(courseId)
    await FavoriteService.persist()
  }

  static async remove(courseId: string): Promise<void> {
    const next: string[] = []
    for (let id of FavoriteService.ids) {
      if (id !== courseId) {
        next.push(id)
      }
    }
    FavoriteService.ids = next
    await FavoriteService.persist()
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
}
