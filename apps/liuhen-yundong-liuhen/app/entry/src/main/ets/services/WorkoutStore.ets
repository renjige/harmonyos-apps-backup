import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { UserSettings, WeeklySnapshot, WorkoutRecord } from '../models/WorkoutModels'
import { DataBus } from './DataBus'
import { DateHelper } from './DateHelper'
import { HabitStore } from './HabitStore'

const STORE = 'sport_trace_v1'
const KEY_RECORDS = 'records'
const KEY_SETTINGS = 'settings'
const KEY_ACHIEVEMENTS = 'achievements'
const KEY_SNAPSHOTS = 'snapshots'

export class WorkoutStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      WorkoutStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      WorkoutStore.pref = null
    }
  }

  static async loadAll(): Promise<WorkoutRecord[]> {
    const raw = await WorkoutStore.getString(KEY_RECORDS, '')
    return WorkoutStore.parseRecords(raw)
  }

  static async saveWorkout(record: WorkoutRecord): Promise<void> {
    const list = await WorkoutStore.loadAll()
    list.unshift(record)
    await WorkoutStore.persistRecords(list)
  }

  static async updateWorkout(record: WorkoutRecord): Promise<void> {
    const list = await WorkoutStore.loadAll()
    const next: WorkoutRecord[] = []
    let found = false
    for (const r of list) {
      if (r.id === record.id) {
        record.distanceKm = WorkoutRecord.estimateDistance(record.typeKey, record.durationSeconds)
        next.push(record)
        found = true
      } else {
        next.push(r)
      }
    }
    if (!found) {
      next.unshift(record)
    }
    await WorkoutStore.persistRecords(next)
  }

  static async findById(id: string): Promise<WorkoutRecord | undefined> {
    const list = await WorkoutStore.loadAll()
    for (const r of list) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async deleteWorkout(id: string): Promise<void> {
    const list = await WorkoutStore.loadAll()
    const next: WorkoutRecord[] = []
    for (const r of list) {
      if (r.id !== id) {
        next.push(r)
      }
    }
    await WorkoutStore.persistRecords(next)
  }

  static async workoutsForDate(dateKey: string): Promise<WorkoutRecord[]> {
    const target = DateHelper.normalizeKey(dateKey)
    const list = await WorkoutStore.loadAll()
    const out: WorkoutRecord[] = []
    for (const r of list) {
      if (DateHelper.normalizeKey(r.dateKey) === target) {
        out.push(r)
      }
    }
    return out
  }

  static async workoutsInRange(startKey: string, endKey: string): Promise<WorkoutRecord[]> {
    const start = DateHelper.parseKey(DateHelper.normalizeKey(startKey)).getTime()
    const endDate = DateHelper.parseKey(DateHelper.normalizeKey(endKey))
    endDate.setHours(23, 59, 59, 999)
    const end = endDate.getTime()
    const list = await WorkoutStore.loadAll()
    const out: WorkoutRecord[] = []
    for (const r of list) {
      const t = DateHelper.parseKey(DateHelper.normalizeKey(r.dateKey)).getTime()
      if (t >= start && t <= end) {
        out.push(r)
      }
    }
    return out
  }

  static async latestWorkout(): Promise<WorkoutRecord | undefined> {
    const list = await WorkoutStore.loadAll()
    if (list.length === 0) {
      return undefined
    }
    return list[0]
  }

  static async loadSettings(): Promise<UserSettings> {
    const raw = await WorkoutStore.getString(KEY_SETTINGS, '')
    const s = new UserSettings()
    if (raw.length === 0) {
      return s
    }
    const parts = raw.split('\t')
    if (parts.length >= 1 && parts[0].length > 0) {
      s.nickname = parts[0]
    }
    if (parts.length >= 2 && parts[1].length > 0) {
      s.themeMode = parts[1]
    }
    if (parts.length >= 3) {
      const g = parseInt(parts[2], 10)
      if (g > 0) {
        s.weeklyGoal = g
      }
    }
    if (parts.length >= 4) {
      const t = parseInt(parts[3], 10)
      if (t > 0) {
        s.monthTarget = t
      }
    }
    return s
  }

  static async saveSettings(settings: UserSettings): Promise<void> {
    const line = `${settings.nickname}\t${settings.themeMode}\t${settings.weeklyGoal}\t${settings.monthTarget}`
    await WorkoutStore.putString(KEY_SETTINGS, line)
    DataBus.bump()
  }

  static async loadUnlockedAchievements(): Promise<string[]> {
    const raw = await WorkoutStore.getString(KEY_ACHIEVEMENTS, '')
    if (raw.length === 0) {
      return []
    }
    return raw.split(',')
  }

  static async unlockAchievement(id: string): Promise<void> {
    const ids = await WorkoutStore.loadUnlockedAchievements()
    for (const x of ids) {
      if (x === id) {
        return
      }
    }
    ids.push(id)
    await WorkoutStore.putString(KEY_ACHIEVEMENTS, ids.join(','))
    DataBus.bump()
  }

  static async loadSnapshots(): Promise<WeeklySnapshot[]> {
    const raw = await WorkoutStore.getString(KEY_SNAPSHOTS, '')
    const out: WeeklySnapshot[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 4) {
        continue
      }
      const s = new WeeklySnapshot()
      s.id = p[0]
      s.weekStart = p[0]
      s.reflection = p[1]
      s.pinned = parseInt(p[2], 10)
      s.insight = p.length >= 4 ? p[3] : ''
      out.push(s)
    }
    return out
  }

  static async saveSnapshotNote(id: string, reflection: string, pinned: number, insight: string): Promise<void> {
    const list = await WorkoutStore.loadSnapshots()
    const next: WeeklySnapshot[] = []
    let found = false
    for (const s of list) {
      if (s.id === id) {
        s.reflection = reflection
        s.pinned = pinned
        s.insight = insight
        next.push(s)
        found = true
      } else {
        next.push(s)
      }
    }
    if (!found) {
      const s = new WeeklySnapshot()
      s.id = id
      s.weekStart = id
      s.reflection = reflection
      s.pinned = pinned
      s.insight = insight
      next.push(s)
    }
    const lines: string[] = []
    for (const s of next) {
      lines.push(`${s.id}\t${s.reflection}\t${s.pinned}\t${s.insight}`)
    }
    await WorkoutStore.putString(KEY_SNAPSHOTS, lines.join('\n'))
    DataBus.bump()
  }

  static async clearAllData(): Promise<void> {
    await WorkoutStore.putString(KEY_RECORDS, '')
    await WorkoutStore.putString(KEY_ACHIEVEMENTS, '')
    await WorkoutStore.putString(KEY_SNAPSHOTS, '')
    await HabitStore.clearAll()
    await DataBus.refreshAll()
  }

  static async exportText(): Promise<string> {
    const list = await WorkoutStore.loadAll()
    let text = '运动留痕 · 数据导出\n'
    for (const r of list) {
      text += `${r.dateKey}\t${r.typeKey}\t${r.durationMinutes()}分\t${r.distanceKm}km\t${r.note}\n`
    }
    return text
  }

  private static parseRecords(raw: string): WorkoutRecord[] {
    const out: WorkoutRecord[] = []
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
      const r = new WorkoutRecord()
      r.id = p[0]
      r.typeKey = p[1]
      r.durationSeconds = parseInt(p[2], 10)
      const ts = parseInt(p[3], 10)
      r.timestamp = ts !== ts ? 0 : ts
      const clamped = DateHelper.clampRecordDates(p[4], r.timestamp)
      r.dateKey = clamped.dateKey
      r.timestamp = clamped.timestamp
      r.note = p[5]
      r.distanceKm = p.length >= 7 ? parseFloat(p[6]) : WorkoutRecord.estimateDistance(r.typeKey, r.durationSeconds)
      r.tagKey = p.length >= 8 ? p[7] : ''
      r.energyKey = p.length >= 9 ? p[8] : ''
      r.feeling = p.length >= 10 ? p[9] : ''
      out.push(r)
    }
    out.sort((a, b) => b.timestamp - a.timestamp)
    return out
  }

  private static async persistRecords(list: WorkoutRecord[]): Promise<void> {
    const lines: string[] = []
    for (const r of list) {
      lines.push(`${r.id}\t${r.typeKey}\t${r.durationSeconds}\t${r.timestamp}\t${r.dateKey}\t${r.note}\t${r.distanceKm}\t${r.tagKey}\t${r.energyKey}\t${r.feeling}`)
    }
    await WorkoutStore.putString(KEY_RECORDS, lines.join('\n'))
    await DataBus.refreshAll()
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (WorkoutStore.pref === null) {
      return fallback
    }
    try {
      const v = await WorkoutStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (WorkoutStore.pref === null) {
      return
    }
    try {
      await WorkoutStore.pref.put(key, value)
      await WorkoutStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
