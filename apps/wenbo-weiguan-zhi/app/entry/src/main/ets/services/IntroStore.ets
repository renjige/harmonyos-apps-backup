import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE = 'weiguan_intro_v1'
const KEY_SEEN = 'method_intro_seen'

export class IntroStore {
  private static pref: preferences.Preferences | null = null
  private static seen: boolean = false

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      IntroStore.pref = await preferences.getPreferences(context, STORE)
      const v = await IntroStore.pref.get(KEY_SEEN, false)
      IntroStore.seen = v === true
    } catch {
      IntroStore.pref = null
      IntroStore.seen = false
    }
  }

  static shouldShowIntro(): boolean {
    return !IntroStore.seen
  }

  static async markSeen(): Promise<void> {
    IntroStore.seen = true
    if (IntroStore.pref === null) {
      return
    }
    try {
      await IntroStore.pref.put(KEY_SEEN, true)
      await IntroStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
