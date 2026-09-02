import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE_NAME = 'kitchen_lab_favorites'
const KEY_IDS = 'recipeIds'

/** 菜谱收藏 — 本地 Preferences；登录后可收藏（gate: favorite_recipe） */
export class RecipeFavoriteService {
  private static pref: preferences.Preferences | null = null
  private static ids: string[] = []
  private static ready: boolean = false

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      RecipeFavoriteService.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await RecipeFavoriteService.pref.get(KEY_IDS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      RecipeFavoriteService.ids = RecipeFavoriteService.parseIds(text)
      RecipeFavoriteService.ready = true
      AppStorage.setOrCreate('favoriteTick', 0)
    } catch {
      RecipeFavoriteService.ids = []
      RecipeFavoriteService.ready = true
    }
  }

  static listIds(): string[] {
    const out: string[] = []
    for (let id of RecipeFavoriteService.ids) {
      out.push(id)
    }
    return out
  }

  static isFavorite(recipeId: string): boolean {
    for (let id of RecipeFavoriteService.ids) {
      if (id === recipeId) {
        return true
      }
    }
    return false
  }

  static async toggle(recipeId: string): Promise<boolean> {
    if (recipeId.length === 0) {
      return false
    }
    if (RecipeFavoriteService.isFavorite(recipeId)) {
      await RecipeFavoriteService.remove(recipeId)
      return false
    }
    await RecipeFavoriteService.add(recipeId)
    return true
  }

  static async add(recipeId: string): Promise<void> {
    if (RecipeFavoriteService.isFavorite(recipeId)) {
      return
    }
    RecipeFavoriteService.ids.push(recipeId)
    await RecipeFavoriteService.persist()
  }

  static async remove(recipeId: string): Promise<void> {
    const next: string[] = []
    for (let id of RecipeFavoriteService.ids) {
      if (id !== recipeId) {
        next.push(id)
      }
    }
    RecipeFavoriteService.ids = next
    await RecipeFavoriteService.persist()
  }

  private static async persist(): Promise<void> {
    const json = JSON.stringify(RecipeFavoriteService.ids)
    if (RecipeFavoriteService.pref !== null) {
      await RecipeFavoriteService.pref.put(KEY_IDS, json)
      await RecipeFavoriteService.pref.flush()
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
