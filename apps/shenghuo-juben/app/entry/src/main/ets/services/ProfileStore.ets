import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'

const STORE = 'shenghuo_profile_v1'
const KEY_NICK = 'nickname'
const KEY_AVATAR = 'avatarPath'
const KEY_DARK = 'darkMode'

export class ProfileStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ProfileStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ProfileStore.pref = null
    }
  }

  static async getNickname(): Promise<string> {
    const v = await ProfileStore.getString(KEY_NICK, '生活主角')
    return v.length > 0 ? v : '生活主角'
  }

  static async setNickname(name: string): Promise<void> {
    await ProfileStore.putString(KEY_NICK, name.trim())
  }

  static async getAvatarPath(): Promise<string> {
    return ProfileStore.getString(KEY_AVATAR, '')
  }

  static async setAvatarPath(path: string): Promise<void> {
    await ProfileStore.putString(KEY_AVATAR, path)
  }

  static async isDarkMode(): Promise<boolean> {
    const v = await ProfileStore.getString(KEY_DARK, '0')
    return v === '1'
  }

  static async setDarkMode(enabled: boolean): Promise<void> {
    await ProfileStore.putString(KEY_DARK, enabled ? '1' : '0')
    AppStorage.setOrCreate('darkModeEnabled', enabled)
    Theme.setColorMode(enabled ? 'dark' : 'light')
  }

  static async loadDarkModeToAppStorage(): Promise<void> {
    const dark = await ProfileStore.isDarkMode()
    AppStorage.setOrCreate('darkModeEnabled', dark)
    Theme.setColorMode(dark ? 'dark' : 'light')
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
