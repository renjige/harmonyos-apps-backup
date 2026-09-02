import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'SessionStore'
const STORE_NAME = 'app_session'
const KEY_TOKEN = 'accessToken'
const KEY_USER = 'currentUsername'
const KEY_PRIVACY = 'privacyAccepted'
const KEY_FAV = 'courtFavoriteIds'
const KEY_BOOKING_STATUS = 'courtBookingStatus'
const KEY_FAN = 'fanEntries'
const KEY_STREAK_DAY = 'fanStreakDay'
const KEY_STREAK_COUNT = 'fanStreakCount'

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
      const favValue = await SessionStore.pref.get(KEY_FAV, '')
      const statusValue = await SessionStore.pref.get(KEY_BOOKING_STATUS, '')
      const fanValue = await SessionStore.pref.get(KEY_FAN, '')
      const streakDayValue = await SessionStore.pref.get(KEY_STREAK_DAY, '')
      const streakCountValue = await SessionStore.pref.get(KEY_STREAK_COUNT, '0')
      const token: string = typeof tokenValue === 'string' ? tokenValue : ''
      const username: string = typeof userValue === 'string' ? userValue : ''
      const privacy: boolean = privacyValue === true
      AppStorage.setOrCreate(KEY_TOKEN, token)
      AppStorage.setOrCreate(KEY_USER, username)
      AppStorage.setOrCreate(KEY_PRIVACY, privacy)
      const favorites: string = typeof favValue === 'string' ? favValue : ''
      AppStorage.setOrCreate(KEY_FAV, favorites)
      const bookingStatus: string = typeof statusValue === 'string' ? statusValue : ''
      AppStorage.setOrCreate(KEY_BOOKING_STATUS, bookingStatus)
      const fanRaw: string = typeof fanValue === 'string' ? fanValue : ''
      AppStorage.setOrCreate(KEY_FAN, fanRaw)
      const streakDay: string = typeof streakDayValue === 'string' ? streakDayValue : ''
      AppStorage.setOrCreate(KEY_STREAK_DAY, streakDay)
      const streakCount: string = typeof streakCountValue === 'string' ? streakCountValue : '0'
      AppStorage.setOrCreate(KEY_STREAK_COUNT, streakCount)
      SessionStore.ready = true
      hilog.info(0x0000, TAG, 'session restored, hasToken=%{public}s', `${token.length > 0}`)
    } catch {
      AppStorage.setOrCreate(KEY_TOKEN, '')
      AppStorage.setOrCreate(KEY_USER, '')
      AppStorage.setOrCreate(KEY_PRIVACY, false)
      AppStorage.setOrCreate(KEY_FAV, '')
      AppStorage.setOrCreate(KEY_BOOKING_STATUS, '')
      AppStorage.setOrCreate(KEY_FAN, '')
      AppStorage.setOrCreate(KEY_STREAK_DAY, '')
      AppStorage.setOrCreate(KEY_STREAK_COUNT, '0')
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

  static async saveFavorites(csv: string): Promise<void> {
    AppStorage.setOrCreate(KEY_FAV, csv)
    await SessionStore.putString(KEY_FAV, csv)
  }

  static async saveBookingStatus(raw: string): Promise<void> {
    AppStorage.setOrCreate(KEY_BOOKING_STATUS, raw)
    await SessionStore.putString(KEY_BOOKING_STATUS, raw)
  }

  static async saveFanEntries(raw: string): Promise<void> {
    AppStorage.setOrCreate(KEY_FAN, raw)
    await SessionStore.putString(KEY_FAN, raw)
  }

  static async saveStreak(day: string, count: string): Promise<void> {
    AppStorage.setOrCreate(KEY_STREAK_DAY, day)
    AppStorage.setOrCreate(KEY_STREAK_COUNT, count)
    await SessionStore.putString(KEY_STREAK_DAY, day)
    await SessionStore.putString(KEY_STREAK_COUNT, count)
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
