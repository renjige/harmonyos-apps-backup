import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { ProfileData } from '../models/MoodModels'

const STORE = 'yuehen_profile_v1'
const KEY_NICK = 'nickname'
const KEY_AVATAR = 'avatarPath'

export class ProfileService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ProfileService.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ProfileService.pref = null
    }
  }

  static async load(): Promise<ProfileData> {
    const p = new ProfileData()
    p.nickname = await ProfileService.getString(KEY_NICK, '月痕旅人')
    p.avatarPath = await ProfileService.getString(KEY_AVATAR, '')
    return p
  }

  static async saveNickname(name: string): Promise<void> {
    await ProfileService.putString(KEY_NICK, name.trim().length > 0 ? name.trim() : '月痕旅人')
  }

  static async saveAvatar(path: string): Promise<void> {
    await ProfileService.putString(KEY_AVATAR, path)
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ProfileService.pref === null) {
      return fallback
    }
    try {
      const v = await ProfileService.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ProfileService.pref === null) {
      return
    }
    try {
      await ProfileService.pref.put(key, value)
      await ProfileService.pref.flush()
    } catch {
      // ignore
    }
  }
}
