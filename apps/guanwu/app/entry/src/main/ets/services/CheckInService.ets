import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { DateHelper } from './DateHelper'

const STORE = 'guanwu_checkin_v1'
const KEY_ENTRIES = 'entries'

export class CheckInService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      CheckInService.pref = await preferences.getPreferences(context, STORE)
    } catch {
      CheckInService.pref = null
    }
  }

  static async isCheckedIn(dateKey: string): Promise<boolean> {
    const raw = await CheckInService.getString(KEY_ENTRIES, '')
    if (raw.length === 0) {
      return false
    }
    for (const line of raw.split('\n')) {
      if (line.startsWith(`${dateKey}\t`)) {
        return true
      }
    }
    return false
  }

  static async checkInToday(note: string = ''): Promise<boolean> {
    const key = DateHelper.todayKey()
    if (await CheckInService.isCheckedIn(key)) {
      return false
    }
    const raw = await CheckInService.getString(KEY_ENTRIES, '')
    const safeNote = note.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const line = `${key}\t${Date.now()}\tmanual\t${safeNote}`
    const next = raw.length > 0 ? `${raw}\n${line}` : line
    await CheckInService.putString(KEY_ENTRIES, next)
    return true
  }

  static async autoFromRecord(): Promise<boolean> {
    const key = DateHelper.todayKey()
    if (await CheckInService.isCheckedIn(key)) {
      return false
    }
    const raw = await CheckInService.getString(KEY_ENTRIES, '')
    const line = `${key}\t${Date.now()}\tauto\t`
    const next = raw.length > 0 ? `${raw}\n${line}` : line
    await CheckInService.putString(KEY_ENTRIES, next)
    return true
  }

  static async countInMonth(): Promise<number> {
    const raw = await CheckInService.getString(KEY_ENTRIES, '')
    if (raw.length === 0) {
      return 0
    }
    const now = new Date()
    const prefix = `${now.getFullYear()}-${CheckInService.pad(now.getMonth() + 1)}`
    let count = 0
    for (const line of raw.split('\n')) {
      if (line.startsWith(prefix)) {
        count++
      }
    }
    return count
  }

  private static pad(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (CheckInService.pref === null) {
      return fallback
    }
    try {
      const v = await CheckInService.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (CheckInService.pref === null) {
      return
    }
    try {
      await CheckInService.pref.put(key, value)
      await CheckInService.pref.flush()
    } catch {
    }
  }
}
