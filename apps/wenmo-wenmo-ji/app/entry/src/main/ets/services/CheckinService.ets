import { preferences } from '@kit.ArkData'

/** 文墨日历 — 每日阅读/笔记打卡（本机持久化） */
export class CheckinService {
  private static readonly STORE: string = 'wenmo_checkin'
  private static readonly KEY_DAYS: string = 'checkedDays'
  private static prefs: preferences.Preferences | null = null

  static async init(context: Context): Promise<void> {
    if (CheckinService.prefs !== null) {
      return
    }
    CheckinService.prefs = await preferences.getPreferences(context, CheckinService.STORE)
  }

  static dateKey(d: Date = new Date()): string {
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  private static async loadDays(): Promise<string[]> {
    if (CheckinService.prefs === null) {
      return []
    }
    const raw = await CheckinService.prefs.get(CheckinService.KEY_DAYS, '[]') as string
    try {
      const parsed = JSON.parse(raw) as string[]
      if (Array.isArray(parsed)) {
        return parsed
      }
    } catch {
      // ignore
    }
    return []
  }

  private static async saveDays(days: string[]): Promise<void> {
    if (CheckinService.prefs === null) {
      return
    }
    await CheckinService.prefs.put(CheckinService.KEY_DAYS, JSON.stringify(days))
    await CheckinService.prefs.flush()
  }

  static async isChecked(dateKey: string = CheckinService.dateKey()): Promise<boolean> {
    const days = await CheckinService.loadDays()
    return days.includes(dateKey)
  }

  static async toggleToday(): Promise<boolean> {
    const key = CheckinService.dateKey()
    const days = await CheckinService.loadDays()
    if (days.includes(key)) {
      const next: string[] = []
      for (const d of days) {
        if (d !== key) {
          next.push(d)
        }
      }
      await CheckinService.saveDays(next)
      return false
    }
    days.push(key)
    await CheckinService.saveDays(days)
    return true
  }

  static async streakDays(): Promise<number> {
    const days = await CheckinService.loadDays()
    let streak = 0
    const today = new Date()
    for (let i = 0; i < 365; i++) {
      const d = new Date(today.getTime() - i * 86400000)
      const key = CheckinService.dateKey(d)
      if (days.includes(key)) {
        streak += 1
      } else if (i > 0) {
        break
      }
    }
    return streak
  }

  static async totalDays(): Promise<number> {
    return (await CheckinService.loadDays()).length
  }
}
