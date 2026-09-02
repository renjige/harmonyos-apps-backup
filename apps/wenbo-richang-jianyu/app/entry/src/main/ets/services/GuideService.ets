import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE = 'app_guide'
const KEY_SEEN = 'product_guide_v104'

/** 首次功能引导（非隐私页） */
export class GuideService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      GuideService.pref = await preferences.getPreferences(context, STORE)
      const seen = await GuideService.pref.get(KEY_SEEN, false)
      AppStorage.setOrCreate('showProductGuide', seen !== true)
    } catch {
      AppStorage.setOrCreate('showProductGuide', false)
    }
  }

  static async markSeen(): Promise<void> {
    AppStorage.setOrCreate('showProductGuide', false)
    if (GuideService.pref !== null) {
      await GuideService.pref.put(KEY_SEEN, true)
      await GuideService.pref.flush()
    }
  }
}
