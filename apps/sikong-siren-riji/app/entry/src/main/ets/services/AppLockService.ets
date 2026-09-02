import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE = 'siren_app_lock'
const KEY_ENABLED = 'enabled'
const KEY_PIN = 'pin_hash'
const KEY_TYPE = 'lock_type'

export class AppLockService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      AppLockService.pref = await preferences.getPreferences(context, STORE)
    } catch {
      AppLockService.pref = null
    }
  }

  static async isEnabled(): Promise<boolean> {
    const v = await AppLockService.getString(KEY_ENABLED, '0')
    return v === '1'
  }

  static async setEnabled(enabled: boolean): Promise<void> {
    await AppLockService.putString(KEY_ENABLED, enabled ? '1' : '0')
  }

  static async setPin(pin: string): Promise<void> {
    await AppLockService.putString(KEY_PIN, AppLockService.hashPin(pin))
    await AppLockService.putString(KEY_TYPE, 'pin')
    await AppLockService.setEnabled(true)
  }

  static async verifyPin(pin: string): Promise<boolean> {
    const stored = await AppLockService.getString(KEY_PIN, '')
    if (stored.length === 0) {
      return true
    }
    return stored === AppLockService.hashPin(pin)
  }

  static async clearLock(): Promise<void> {
    await AppLockService.putString(KEY_PIN, '')
    await AppLockService.setEnabled(false)
  }

  static async hasPin(): Promise<boolean> {
    const stored = await AppLockService.getString(KEY_PIN, '')
    return stored.length > 0
  }

  private static hashPin(pin: string): string {
    let h = 0
    for (let i = 0; i < pin.length; i++) {
      h = ((h << 5) - h) + pin.charCodeAt(i)
      h = h & h
    }
    return `p${Math.abs(h)}_${pin.length}`
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (AppLockService.pref === null) {
      return fallback
    }
    try {
      const v = await AppLockService.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (AppLockService.pref === null) {
      return
    }
    try {
      await AppLockService.pref.put(key, value)
      await AppLockService.pref.flush()
    } catch {
      // ignore
    }
  }
}
