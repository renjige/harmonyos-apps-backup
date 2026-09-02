import { preferences } from '@kit.ArkData'

/** 记录「今日已阅」状态（按自然日） */
export class ReadTodayService {
  private static readonly STORE: string = 'zhiyu_read_today'
  private static readonly KEY: string = 'lastDay'
  private static prefs: preferences.Preferences | null = null

  static async init(context: Context): Promise<void> {
    if (ReadTodayService.prefs !== null) {
      return
    }
    ReadTodayService.prefs = await preferences.getPreferences(context, ReadTodayService.STORE)
  }

  static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    return `${d.getFullYear()}-${m < 10 ? '0' + m : m}-${day < 10 ? '0' + day : day}`
  }

  static async markReadToday(): Promise<void> {
    if (ReadTodayService.prefs === null) {
      return
    }
    await ReadTodayService.prefs.put(ReadTodayService.KEY, ReadTodayService.todayKey())
    await ReadTodayService.prefs.flush()
  }

  static async isReadToday(): Promise<boolean> {
    if (ReadTodayService.prefs === null) {
      return false
    }
    const saved = await ReadTodayService.prefs.get(ReadTodayService.KEY, '') as string
    return saved === ReadTodayService.todayKey()
  }
}
