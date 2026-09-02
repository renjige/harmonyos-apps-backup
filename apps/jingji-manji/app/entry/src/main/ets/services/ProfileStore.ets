import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { UserProfile } from '../models/SportModels'

const STORE_NAME = 'sport_profile_v1'
const KEY_PROFILE = 'user_profile_json'

export class ProfileStore {
  private static pref: preferences.Preferences | null = null
  private static profile: UserProfile = ProfileStore.defaultProfile()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ProfileStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await ProfileStore.pref.get(KEY_PROFILE, '')
      const text: string = typeof raw === 'string' ? raw : ''
      if (text.length > 0) {
        ProfileStore.profile = ProfileStore.parseProfile(text)
      }
    } catch {
      ProfileStore.profile = ProfileStore.defaultProfile()
    }
  }

  static get(): UserProfile {
    return ProfileStore.profile
  }

  static async save(profile: UserProfile): Promise<void> {
    ProfileStore.profile = profile
    if (ProfileStore.pref === null) {
      return
    }
    await ProfileStore.pref.put(KEY_PROFILE, JSON.stringify(profile))
    await ProfileStore.pref.flush()
  }

  private static defaultProfile(): UserProfile {
    return new UserProfile()
  }

  private static parseProfile(text: string): UserProfile {
    try {
      const o = JSON.parse(text) as Record<string, string | number | boolean>
      const p = new UserProfile()
      p.nickname = typeof o['nickname'] === 'string' ? o['nickname'] : '运动者'
      p.bio = typeof o['bio'] === 'string' ? o['bio'] : ''
      p.sportPref = typeof o['sportPref'] === 'string' ? o['sportPref'] : '跑步'
      p.monthlyGoalSessions =
        typeof o['monthlyGoalSessions'] === 'number' ? o['monthlyGoalSessions'] : 12
      p.useKm = typeof o['useKm'] === 'boolean' ? o['useKm'] : true
      return p
    } catch {
      return ProfileStore.defaultProfile()
    }
  }
}
