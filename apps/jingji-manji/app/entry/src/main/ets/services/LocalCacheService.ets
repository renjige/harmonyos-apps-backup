import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE_NAME = 'sport_ui_cache_v1'

/** 界面缓存（问卷草稿、统计快照等），不含运动记录/挑战业务数据 */
export class LocalCacheService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      LocalCacheService.pref = await preferences.getPreferences(context, STORE_NAME)
    } catch {
      LocalCacheService.pref = null
    }
  }

  static async saveDraft(key: string, value: string): Promise<void> {
    if (LocalCacheService.pref === null) {
      return
    }
    await LocalCacheService.pref.put(key, value)
    await LocalCacheService.pref.flush()
  }

  static async readDraft(key: string): Promise<string> {
    if (LocalCacheService.pref === null) {
      return ''
    }
    const raw = await LocalCacheService.pref.get(key, '')
    return typeof raw === 'string' ? raw : ''
  }

  static async clearAll(): Promise<void> {
    if (LocalCacheService.pref !== null) {
      await LocalCacheService.pref.clear()
      await LocalCacheService.pref.flush()
    }
    AppStorage.setOrCreate('diagnoseDraftStep', 0)
    AppStorage.setOrCreate('localCacheEpoch', Date.now())
  }
}
