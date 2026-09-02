import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE_NAME = 'product_guide'
const KEY_SEEN = 'guide_seen_v2'

/** 产品特色引导：首启展示一次，可在「我的」再次打开 */
export class GuideStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      GuideStore.pref = await preferences.getPreferences(context, STORE_NAME)
    } catch {
      GuideStore.pref = null
    }
  }

  static async shouldShow(): Promise<boolean> {
    if (GuideStore.pref === null) {
      return false
    }
    try {
      const seen = await GuideStore.pref.get(KEY_SEEN, false)
      return seen !== true
    } catch {
      return false
    }
  }

  static async markSeen(): Promise<void> {
    if (GuideStore.pref === null) {
      return
    }
    try {
      await GuideStore.pref.put(KEY_SEEN, true)
      await GuideStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
