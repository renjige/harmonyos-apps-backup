import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { AppSettings } from '../models/DiaryModels'
import { AppLockService } from './AppLockService'

const STORE = 'siren_settings'
const KEY_THEME = 'theme_mode'
const KEY_FONT = 'font_scale'

export class SettingsService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SettingsService.pref = await preferences.getPreferences(context, STORE)
    } catch {
      SettingsService.pref = null
    }
  }

  static async load(): Promise<AppSettings> {
    const s = new AppSettings()
    s.themeMode = await SettingsService.getString(KEY_THEME, 'system')
    s.fontScale = await SettingsService.getString(KEY_FONT, 'medium')
    s.appLockEnabled = await AppLockService.isEnabled()
    return s
  }

  static async saveTheme(mode: string): Promise<void> {
    await SettingsService.putString(KEY_THEME, mode)
    AppStorage.setOrCreate('themeMode', mode)
  }

  static async saveFontScale(scale: string): Promise<void> {
    await SettingsService.putString(KEY_FONT, scale)
    AppStorage.setOrCreate('fontScale', scale)
  }

  static fontMultiplier(): number {
    const scale = AppStorage.get<string>('fontScale') ?? 'medium'
    if (scale === 'small') {
      return 0.9
    }
    if (scale === 'large') {
      return 1.12
    }
    return 1.0
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

  private static async putString(key: string, value: string): Promise<void> {
    if (SettingsService.pref === null) {
      return
    }
    try {
      await SettingsService.pref.put(key, value)
      await SettingsService.pref.flush()
    } catch {
      // ignore
    }
  }
}
