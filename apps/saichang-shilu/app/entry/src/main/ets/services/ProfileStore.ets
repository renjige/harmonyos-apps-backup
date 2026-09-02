import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { UserProfile } from '../models/SportRecord'

const KEY_PROFILE = 'profile'
const KEY_COLOR = 'colorMode'

export class ProfileStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ProfileStore.pref = await preferences.getPreferences(context, 'saichang_profile_v1')
    } catch {
      ProfileStore.pref = null
    }
  }

  static async load(): Promise<UserProfile> {
    const raw = await ProfileStore.getString(KEY_PROFILE, '')
    const p = new UserProfile()
    if (raw.length === 0) {
      return p
    }
    const parts = raw.split('\t')
    if (parts.length >= 1) {
      p.nickname = parts[0]
    }
    if (parts.length >= 2) {
      p.avatarPath = parts[1]
    }
    if (parts.length >= 3 && parts[2].length > 0) {
      p.preferredSports = parts[2].split('|')
    }
    return p
  }

  static async save(profile: UserProfile): Promise<void> {
    const sports = profile.preferredSports.join('|')
    await ProfileStore.putString(KEY_PROFILE, `${profile.nickname}\t${profile.avatarPath}\t${sports}`)
  }

  static async saveColorMode(mode: string): Promise<void> {
    await ProfileStore.putString(KEY_COLOR, mode)
  }

  static async loadColorMode(): Promise<string> {
    return ProfileStore.getString(KEY_COLOR, 'light')
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ProfileStore.pref === null) {
      return fallback
    }
    try {
      const v = await ProfileStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ProfileStore.pref === null) {
      return
    }
    try {
      await ProfileStore.pref.put(key, value)
      await ProfileStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
