import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE = 'zhange_settings_v1'
const KEY_THEME = 'theme_mode'

export type ThemePreference = 'light' | 'dark' | 'system'

export class SettingsService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SettingsService.pref = await preferences.getPreferences(context, STORE)
    } catch {
      SettingsService.pref = null
    }
  }

  static async getThemeMode(): Promise<ThemePreference> {
    const raw = await SettingsService.getString(KEY_THEME, 'system')
    if (raw === 'light' || raw === 'dark') {
      return raw
    }
    return 'system'
  }

  static async setThemeMode(mode: ThemePreference): Promise<void> {
    await SettingsService.putString(KEY_THEME, mode, true)
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (SettingsService.pref === null) {
      return fallback
    }
    try {
      const v = await SettingsService.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string, flush: boolean): Promise<void> {
    if (SettingsService.pref === null) {
      return
    }
    try {
      await SettingsService.pref.put(key, value)
      if (flush) {
        await SettingsService.pref.flush()
      }
    } catch {
      // ignore
    }
  }
}
