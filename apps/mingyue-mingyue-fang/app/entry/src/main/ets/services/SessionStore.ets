import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'SessionStore'
const STORE_NAME = 'app_session'
const KEY_TOKEN = 'accessToken'
const KEY_USER = 'currentUsername'
const KEY_PRIVACY = 'privacyAccepted'
const KEY_HIDDEN_BOOKS = 'hiddenBookIds'
const KEY_NICKNAME = 'displayNickname'

/**
 * 可靠会话持久化：preferences + flush。
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
      const hiddenValue = await SessionStore.pref.get(KEY_HIDDEN_BOOKS, '')
      const nicknameValue = await SessionStore.pref.get(KEY_NICKNAME, '')
      const token: string = typeof tokenValue === 'string' ? tokenValue : ''
      const username: string = typeof userValue === 'string' ? userValue : ''
      const privacy: boolean = privacyValue === true
      const hidden: string = typeof hiddenValue === 'string' ? hiddenValue : ''
      const nickname: string = typeof nicknameValue === 'string' ? nicknameValue : ''
      AppStorage.setOrCreate(KEY_TOKEN, token)
      AppStorage.setOrCreate(KEY_USER, username)
      AppStorage.setOrCreate(KEY_PRIVACY, privacy)
      AppStorage.setOrCreate(KEY_HIDDEN_BOOKS, hidden)
      AppStorage.setOrCreate(KEY_NICKNAME, nickname)
      SessionStore.ready = true
      hilog.info(0x0000, TAG, 'session restored, hasToken=%{public}s', `${token.length > 0}`)
    } catch {
      AppStorage.setOrCreate(KEY_TOKEN, '')
      AppStorage.setOrCreate(KEY_USER, '')
      AppStorage.setOrCreate(KEY_PRIVACY, false)
      AppStorage.setOrCreate(KEY_HIDDEN_BOOKS, '')
      AppStorage.setOrCreate(KEY_NICKNAME, '')
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

  static displayNickname(): string {
    const raw = AppStorage.get<string>(KEY_NICKNAME)
    return raw !== undefined && raw !== null ? raw : ''
  }

  static async saveDisplayNickname(name: string): Promise<void> {
    const trimmed = name.trim()
    AppStorage.setOrCreate(KEY_NICKNAME, trimmed)
    await SessionStore.putString(KEY_NICKNAME, trimmed)
  }

  static hiddenBookIds(): string[] {
    const raw = AppStorage.get<string>(KEY_HIDDEN_BOOKS)
    const text = raw !== undefined && raw !== null ? raw : ''
    const out: string[] = []
    const parts = text.split(',')
    for (const part of parts) {
      if (part.length > 0) {
        out.push(part)
      }
    }
    return out
  }

  static isBookHidden(id: string): boolean {
    const ids = SessionStore.hiddenBookIds()
    for (const hid of ids) {
      if (hid === id) {
        return true
      }
    }
    return false
  }

  static async hideBook(id: string): Promise<void> {
    if (id.length === 0 || SessionStore.isBookHidden(id)) {
      return
    }
    const ids = SessionStore.hiddenBookIds()
    ids.push(id)
    const joined = ids.join(',')
    AppStorage.setOrCreate(KEY_HIDDEN_BOOKS, joined)
    await SessionStore.putString(KEY_HIDDEN_BOOKS, joined)
  }

  /** 清除本地缓存（不登出、不删云端记录） */
  static async clearLocalCache(): Promise<void> {
    AppStorage.setOrCreate(KEY_HIDDEN_BOOKS, '')
    await SessionStore.putString(KEY_HIDDEN_BOOKS, '')
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
