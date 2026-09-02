import { common } from '@kit.AbilityKit'
import { LocalPrefs } from './LocalPrefs'

/**
 * 共享 Preferences 读写（Knowledge / Spark / Plan 等 Store 复用）。
 */
export class WanXiangLocalStore {
  static async init(context: common.UIAbilityContext): Promise<void> {
    await LocalPrefs.init(context)
  }

  static async getString(key: string, fallback: string): Promise<string> {
    return LocalPrefs.getString(key, fallback)
  }

  static async putString(key: string, value: string): Promise<void> {
    await LocalPrefs.putString(key, value)
  }

  static newId(prefix: string): string {
    return LocalPrefs.newId(prefix)
  }
}
