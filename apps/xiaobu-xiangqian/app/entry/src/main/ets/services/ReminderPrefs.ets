import preferences from '@ohos.data.preferences'

const PREF_NAME = 'xiaobu_reminder_prefs'
const KEY_ENABLED = 'reminderEnabled'
const KEY_TIME = 'reminderTime'
const KEY_MESSAGE = 'reminderMessage'

export class ReminderPrefs {
  private static store: preferences.Preferences | null = null

  static async init(context: Context): Promise<void> {
    if (ReminderPrefs.store !== null) {
      return
    }
    ReminderPrefs.store = await preferences.getPreferences(context, PREF_NAME)
  }

  static async isEnabled(): Promise<boolean> {
    if (ReminderPrefs.store === null) {
      return false
    }
    return await ReminderPrefs.store.get(KEY_ENABLED, false) as boolean
  }

  static async getTime(): Promise<string> {
    if (ReminderPrefs.store === null) {
      return '20:00'
    }
    return await ReminderPrefs.store.get(KEY_TIME, '20:00') as string
  }

  static async getMessage(): Promise<string> {
    if (ReminderPrefs.store === null) {
      return '今天的小步目标完成了吗？'
    }
    return await ReminderPrefs.store.get(KEY_MESSAGE, '今天的小步目标完成了吗？') as string
  }

  static async save(enabled: boolean, time: string, message: string): Promise<void> {
    if (ReminderPrefs.store === null) {
      return
    }
    await ReminderPrefs.store.put(KEY_ENABLED, enabled)
    await ReminderPrefs.store.put(KEY_TIME, time)
    await ReminderPrefs.store.put(KEY_MESSAGE, message)
    await ReminderPrefs.store.flush()
  }
}
