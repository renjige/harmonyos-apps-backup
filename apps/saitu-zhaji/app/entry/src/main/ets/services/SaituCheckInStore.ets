import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { CheckIn } from '../models/SaituGrowthModels'
import { DateHelper } from './DateHelper'
import { SaituRefreshSignals } from './SaituRefreshSignals'

const STORE = 'saitu_zhaji_checkin_v1'
const KEY_CHECKINS = 'checkins'

export class SaituCheckInStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SaituCheckInStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      SaituCheckInStore.pref = null
    }
  }

  static async loadCheckIns(): Promise<CheckIn[]> {
    const list = SaituCheckInStore.parse(await SaituCheckInStore.getString(KEY_CHECKINS, ''))
    list.sort((a, b) => b.createdAt - a.createdAt)
    return list
  }

  static async saveCheckIn(item: CheckIn): Promise<void> {
    const list = await SaituCheckInStore.loadCheckIns()
    const next: CheckIn[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    await SaituCheckInStore.persist(next)
    SaituRefreshSignals.bumpTrackEpoch()
  }

  static async deleteCheckIn(id: string): Promise<void> {
    const list = await SaituCheckInStore.loadCheckIns()
    const next: CheckIn[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await SaituCheckInStore.persist(next)
  }

  static async hasTodayCheckIn(): Promise<boolean> {
    const key = CheckIn.todayKey()
    const list = await SaituCheckInStore.loadCheckIns()
    for (const it of list) {
      if (it.dateKey === key) {
        return true
      }
    }
    return false
  }

  static async todayCheckIn(): Promise<CheckIn | undefined> {
    const key = CheckIn.todayKey()
    const list = await SaituCheckInStore.loadCheckIns()
    for (const it of list) {
      if (it.dateKey === key) {
        return it
      }
    }
    return undefined
  }

  static async checkInStreak(): Promise<number> {
    const list = await SaituCheckInStore.loadCheckIns()
    const keys = new Set<string>()
    for (const it of list) {
      keys.add(it.dateKey)
    }
    let streak = 0
    const cursor = new Date()
    for (;;) {
      const key = DateHelper.keyFromDate(cursor)
      if (keys.has(key)) {
        streak++
        cursor.setDate(cursor.getDate() - 1)
      } else {
        break
      }
    }
    return streak
  }

  static async clearAll(): Promise<void> {
    await SaituCheckInStore.putString(KEY_CHECKINS, '')
  }

  private static async persist(items: CheckIn[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      const note = it.note.replace(/\n/g, '\\n').replace(/\t/g, ' ')
      lines.push([it.id, it.dateKey, it.journeyId, it.milestoneId, note, `${it.createdAt}`].join('\t'))
    }
    await SaituCheckInStore.putString(KEY_CHECKINS, lines.join('\n'))
  }

  private static parse(raw: string): CheckIn[] {
    const out: CheckIn[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 6) {
        continue
      }
      const c = new CheckIn()
      c.id = p[0]
      c.dateKey = p[1]
      c.journeyId = p[2]
      c.milestoneId = p[3]
      c.note = p[4].replace(/\\n/g, '\n')
      c.createdAt = parseInt(p[5], 10)
      out.push(c)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (SaituCheckInStore.pref === null) {
      return fallback
    }
    try {
      const v = await SaituCheckInStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (SaituCheckInStore.pref === null) {
      return
    }
    try {
      await SaituCheckInStore.pref.put(key, value)
      await SaituCheckInStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
