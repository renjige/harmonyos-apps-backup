import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'SessionStore'
const STORE_NAME = 'app_session'
const KEY_TOKEN = 'accessToken'
const KEY_USER = 'currentUsername'
const KEY_PRIVACY = 'privacyAccepted'
const KEY_HISTORY = 'drinkBrowseHistory'
const KEY_FEEL = 'feelTempC'

/**
 * 可靠会话持久化：preferences + flush。
 * 勿仅依赖 PersistentStorage（杀进程易丢）。
 */
export class SessionStore {
  private static pref: preferences.Preferences | null = null
  private static ready: boolean = false

  static isReady(): boolean {
    return SessionStore.ready
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SessionStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const tokenValue = await SessionStore.pref.get(KEY_TOKEN, '')
      const userValue = await SessionStore.pref.get(KEY_USER, '')
      const privacyValue = await SessionStore.pref.get(KEY_PRIVACY, false)
      const historyValue = await SessionStore.pref.get(KEY_HISTORY, '')
      const feelValue = await SessionStore.pref.get(KEY_FEEL, 32)
      const token: string = typeof tokenValue === 'string' ? tokenValue : ''
      const username: string = typeof userValue === 'string' ? userValue : ''
      const privacy: boolean = privacyValue === true
      const history: string = typeof historyValue === 'string' ? historyValue : ''
      const feelTemp: number = typeof feelValue === 'number' ? feelValue : 32
      AppStorage.setOrCreate(KEY_TOKEN, token)
      AppStorage.setOrCreate(KEY_USER, username)
      AppStorage.setOrCreate(KEY_PRIVACY, privacy)
      AppStorage.setOrCreate(KEY_HISTORY, history)
      AppStorage.setOrCreate(KEY_FEEL, feelTemp)
      SessionStore.ready = true
      hilog.info(0x0000, TAG, 'session restored, hasToken=%{public}s', `${token.length > 0}`)
    } catch {
      AppStorage.setOrCreate(KEY_TOKEN, '')
      AppStorage.setOrCreate(KEY_USER, '')
      AppStorage.setOrCreate(KEY_PRIVACY, false)
      AppStorage.setOrCreate(KEY_HISTORY, '')
      AppStorage.setOrCreate(KEY_FEEL, 32)
      SessionStore.ready = true
      hilog.error(0x0000, TAG, 'session init failed, using empty')
    }
  }

  static async saveSession(token: string, username: string): Promise<void> {
    AppStorage.setOrCreate(KEY_TOKEN, token)
    AppStorage.setOrCreate(KEY_USER, username)
    await SessionStore.putString(KEY_TOKEN, token)
    await SessionStore.putString(KEY_USER, username)
  }

  static async clearSession(): Promise<void> {
    AppStorage.setOrCreate(KEY_TOKEN, '')
    AppStorage.setOrCreate(KEY_USER, '')
    await SessionStore.putString(KEY_TOKEN, '')
    await SessionStore.putString(KEY_USER, '')
  }

  static async savePrivacyAccepted(accepted: boolean): Promise<void> {
    AppStorage.setOrCreate(KEY_PRIVACY, accepted)
    await SessionStore.putBool(KEY_PRIVACY, accepted)
  }

  static async saveHistory(joined: string): Promise<void> {
    AppStorage.setOrCreate(KEY_HISTORY, joined)
    await SessionStore.putString(KEY_HISTORY, joined)
  }

  static async saveFeelTemp(temp: number): Promise<void> {
    AppStorage.setOrCreate(KEY_FEEL, temp)
    if (SessionStore.pref === null) {
      return
    }
    await SessionStore.pref.put(KEY_FEEL, temp)
    await SessionStore.pref.flush()
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (SessionStore.pref === null) {
      return
    }
    await SessionStore.pref.put(key, value)
    await SessionStore.pref.flush()
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (SessionStore.pref === null) {
      return
    }
    await SessionStore.pref.put(key, value)
    await SessionStore.pref.flush()
  }
}
