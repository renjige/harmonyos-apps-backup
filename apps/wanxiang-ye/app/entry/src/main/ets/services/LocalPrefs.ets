import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { AppContextService } from './AppContextService'

const STORE = 'wanxiang_user_v1'

/**
 * 统一本机 Preferences（UserDataStore / WanXiangLocalStore 共用同一实例）。
 * HarmonyOS 6.x 可能将数字型 value 以 number 返回，须兼容否则统计恒为 0。
 */
export class LocalPrefs {
  private static pref: preferences.Preferences | null = null
  private static initDone: boolean = false

  static isReady(): boolean {
    return LocalPrefs.pref !== null && LocalPrefs.initDone
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    if (LocalPrefs.pref !== null) {
      LocalPrefs.initDone = true
      AppStorage.setOrCreate('wanxiangStoreReady', true)
      return
    }
    try {
      LocalPrefs.pref = await preferences.getPreferences(context, STORE)
      LocalPrefs.initDone = true
      AppStorage.setOrCreate('wanxiangStoreReady', true)
    } catch {
      LocalPrefs.pref = null
      LocalPrefs.initDone = false
      AppStorage.setOrCreate('wanxiangStoreReady', false)
    }
  }

  static async ensureReady(): Promise<boolean> {
    if (LocalPrefs.pref !== null) {
      return true
    }
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      return false
    }
    await LocalPrefs.init(ctx)
    return LocalPrefs.pref !== null
  }

  static coerceString(value: preferences.ValueType, fallback: string): string {
    if (typeof value === 'string') {
      return value
    }
    if (typeof value === 'number') {
      return `${value}`
    }
    if (typeof value === 'boolean') {
      return value ? '1' : '0'
    }
    return fallback
  }

  static async getString(key: string, fallback: string): Promise<string> {
    const ok = await LocalPrefs.ensureReady()
    if (!ok || LocalPrefs.pref === null) {
      return fallback
    }
    try {
      const v = await LocalPrefs.pref.get(key, fallback)
      return LocalPrefs.coerceString(v, fallback)
    } catch {
      return fallback
    }
  }

  static async getInt(key: string, fallback: number): Promise<number> {
    const raw = await LocalPrefs.getString(key, `${fallback}`)
    const n = parseInt(raw, 10)
    return Number.isNaN(n) ? fallback : n
  }

  static async putString(key: string, value: string): Promise<void> {
    const ok = await LocalPrefs.ensureReady()
    if (!ok || LocalPrefs.pref === null) {
      return
    }
    try {
      await LocalPrefs.pref.put(key, value)
      await LocalPrefs.pref.flush()
    } catch {
    }
  }

  static async putInt(key: string, value: number): Promise<void> {
    await LocalPrefs.putString(key, `${value}`)
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }
}
