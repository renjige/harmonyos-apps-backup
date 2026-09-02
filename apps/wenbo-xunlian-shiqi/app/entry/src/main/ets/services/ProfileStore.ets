import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { UserProfile } from '../models/TrainingModels'

const STORE_NAME = 'training_fun_profile_v1'
const KEY_PROFILE = 'profile_json'

export class ProfileStore {
  private static pref: preferences.Preferences | null = null
  private static cache: UserProfile = new UserProfile()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ProfileStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await ProfileStore.pref.get(KEY_PROFILE, '')
      const text: string = typeof raw === 'string' ? raw : ''
      ProfileStore.cache = ProfileStore.parseProfile(text)
    } catch {
      ProfileStore.cache = new UserProfile()
    }
  }

  static get(): UserProfile {
    return ProfileStore.cache
  }

  static async ensureFirstUse(): Promise<void> {
    if (ProfileStore.cache.firstUseAt <= 0) {
      ProfileStore.cache.firstUseAt = Date.now()
      await ProfileStore.flush()
    }
  }

  static async save(profile: UserProfile): Promise<void> {
    ProfileStore.cache = profile
    await ProfileStore.flush()
  }

  private static async flush(): Promise<void> {
    if (ProfileStore.pref === null) {
      return
    }
    await ProfileStore.pref.put(KEY_PROFILE, JSON.stringify(ProfileStore.cache))
    await ProfileStore.pref.flush()
  }

  private static parseProfile(text: string): UserProfile {
    const p = new UserProfile()
    if (text.length === 0) {
      return p
    }
    try {
      const o = JSON.parse(text) as Record<string, string | number>
      p.nickname = typeof o['nickname'] === 'string' ? o['nickname'] : '训练者'
      p.firstUseAt = typeof o['firstUseAt'] === 'number' ? o['firstUseAt'] : 0
      p.themeMode = typeof o['themeMode'] === 'string' ? o['themeMode'] : 'system'
      p.featureTourSeen = typeof o['featureTourSeen'] === 'number' ? o['featureTourSeen'] : 0
      p.experiencePackLoaded = typeof o['experiencePackLoaded'] === 'number' ? o['experiencePackLoaded'] : 0
    } catch {
      return p
    }
    return p
  }
}
