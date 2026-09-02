import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { UserProfile, WorkoutRecord } from '../models/WorkoutModels'
import { DateHelper } from './DateHelper'

const STORE = 'tineng_workout_v1'
const KEY_WORKOUTS = 'workouts'
const KEY_PROFILE = 'profile'
const KEY_ACHIEVEMENTS = 'achievements'

export class WorkoutStore {
  private static pref: preferences.Preferences | null = null
  private static appContext: common.UIAbilityContext | null = null
  private static cache: WorkoutRecord[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    WorkoutStore.appContext = context
    await WorkoutStore.ensurePref()
    WorkoutStore.cache = await WorkoutStore.readWorkoutsFromDisk()
  }

  static async ensurePref(): Promise<void> {
    if (WorkoutStore.pref !== null || WorkoutStore.appContext === null) {
      return
    }
    try {
      WorkoutStore.pref = await preferences.getPreferences(WorkoutStore.appContext, STORE)
    } catch {
      WorkoutStore.pref = null
    }
  }

  static async loadAll(): Promise<WorkoutRecord[]> {
    await WorkoutStore.ensurePref()
    if (WorkoutStore.pref !== null) {
      WorkoutStore.cache = await WorkoutStore.readWorkoutsFromDisk()
    }
    const copy: WorkoutRecord[] = []
    for (const w of WorkoutStore.cache) {
      copy.push(w)
    }
    return copy
  }

  static async findById(id: string): Promise<WorkoutRecord | undefined> {
    const list = await WorkoutStore.loadAll()
    for (const w of list) {
      if (w.id === id) {
        return w
      }
    }
    return undefined
  }

  static async workoutsForDate(dateKey: string): Promise<WorkoutRecord[]> {
    const list = await WorkoutStore.loadAll()
    const out: WorkoutRecord[] = []
    for (const w of list) {
      if (w.dateKey === dateKey) {
        out.push(w)
      }
    }
    return out
  }

  static async saveWorkout(record: WorkoutRecord): Promise<void> {
    await WorkoutStore.ensurePref()
    const list = await WorkoutStore.loadAll()
    const next: WorkoutRecord[] = []
    let replaced = false
    for (const w of list) {
      if (w.id === record.id) {
        next.push(record)
        replaced = true
      } else {
        next.push(w)
      }
    }
    if (!replaced) {
      next.push(record)
    }
    next.sort((a, b) => b.timestamp - a.timestamp)
    WorkoutStore.cache = next
    await WorkoutStore.persistWorkouts(next)
  }

  static async deleteWorkout(id: string): Promise<void> {
    const list = await WorkoutStore.loadAll()
    const next: WorkoutRecord[] = []
    for (const w of list) {
      if (w.id !== id) {
        next.push(w)
      }
    }
    WorkoutStore.cache = next
    await WorkoutStore.persistWorkouts(next)
  }

  static async workoutsInRange(startKey: string, endKey: string): Promise<WorkoutRecord[]> {
    const list = await WorkoutStore.loadAll()
    const out: WorkoutRecord[] = []
    for (const w of list) {
      if (w.dateKey >= startKey && w.dateKey <= endKey) {
        out.push(w)
      }
    }
    return out
  }

  static async loadProfile(): Promise<UserProfile> {
    await WorkoutStore.ensurePref()
    const raw = await WorkoutStore.getString(KEY_PROFILE, '')
    if (raw.length === 0) {
      return new UserProfile()
    }
    const parts = raw.split('\t')
    const p = new UserProfile()
    if (parts.length >= 1) {
      p.nickname = parts[0]
    }
    if (parts.length >= 2) {
      p.avatarKey = parts[1]
    }
    if (parts.length >= 3) {
      const n = DateHelper.safeInt(parts[2], 5)
      p.weeklyGoalDays = n > 0 ? n : 5
    }
    if (parts.length >= 4) {
      const n = DateHelper.safeInt(parts[3], 30)
      p.dailyGoalMinutes = n > 0 ? n : 30
    }
    if (parts.length >= 5 && parts[4].length > 0) {
      p.themeMode = parts[4]
    }
    if (parts.length >= 6) {
      p.themeSpaceKey = parts[5]
    }
    return p
  }

  static async saveProfile(profile: UserProfile): Promise<void> {
    const line =
      `${profile.nickname}\t${profile.avatarKey}\t${profile.weeklyGoalDays}\t${profile.dailyGoalMinutes}\t${profile.themeMode}\t${profile.themeSpaceKey}`
    await WorkoutStore.putString(KEY_PROFILE, line)
  }

  static async loadUnlockedAchievements(): Promise<string[]> {
    const raw = await WorkoutStore.getString(KEY_ACHIEVEMENTS, '')
    if (raw.length === 0) {
      return []
    }
    return raw.split(',')
  }

  static async unlockAchievement(id: string): Promise<void> {
    const list = await WorkoutStore.loadUnlockedAchievements()
    for (const a of list) {
      if (a === id) {
        return
      }
    }
    list.push(id)
    await WorkoutStore.putString(KEY_ACHIEVEMENTS, list.join(','))
  }

  static async clearAllWorkouts(): Promise<void> {
    WorkoutStore.cache = []
    await WorkoutStore.putString(KEY_WORKOUTS, '')
    await WorkoutStore.putString(KEY_ACHIEVEMENTS, '')
  }

  static async readRaw(key: string): Promise<string> {
    await WorkoutStore.ensurePref()
    return WorkoutStore.getString(key, '')
  }

  static async writeRaw(key: string, value: string): Promise<void> {
    await WorkoutStore.ensurePref()
    await WorkoutStore.putString(key, value)
  }

  private static async readWorkoutsFromDisk(): Promise<WorkoutRecord[]> {
    const raw = await WorkoutStore.getString(KEY_WORKOUTS, '')
    return WorkoutStore.parseWorkouts(raw)
  }

  private static async persistWorkouts(items: WorkoutRecord[]): Promise<void> {
    const lines: string[] = []
    for (const w of items) {
      lines.push(WorkoutStore.serialize(w))
    }
    await WorkoutStore.putString(KEY_WORKOUTS, lines.join('\n'))
  }

  private static serialize(w: WorkoutRecord): string {
    const note = w.note.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const insight = w.insight.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const manual = w.caloriesManual ? '1' : '0'
    return [
      w.id,
      w.typeKey,
      w.dateKey,
      `${w.durationMinutes}`,
      `${w.distanceKm}`,
      `${w.calories}`,
      w.heartRateZone,
      note,
      `${w.timestamp}`,
      manual,
      w.feeling,
      w.tag,
      insight,
      w.completeState,
      `${w.starRating}`,
      w.sessionTitle.replace(/\t/g, ' ').replace(/\n/g, ' ')
    ].join('\t')
  }

  private static parseWorkouts(raw: string): WorkoutRecord[] {
    const out: WorkoutRecord[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 9) {
        continue
      }
      const w = new WorkoutRecord()
      w.id = parts[0]
      w.typeKey = parts[1]
      w.dateKey = parts[2]
      w.durationMinutes = DateHelper.safeInt(parts[3], 0)
      const dist = parseFloat(parts[4])
      w.distanceKm = isNaN(dist) ? 0 : dist
      w.calories = DateHelper.safeInt(parts[5], 0)
      w.heartRateZone = parts[6]
      w.note = parts[7]
      w.timestamp = DateHelper.safeInt(parts[8], 0)
      if (parts.length >= 10) {
        w.caloriesManual = parts[9] === '1'
      }
      if (parts.length >= 11) {
        w.feeling = parts[10]
      }
      if (parts.length >= 12) {
        w.tag = parts[11]
      }
      if (parts.length >= 13) {
        w.insight = parts[12]
      }
      if (parts.length >= 14 && parts[13].length > 0) {
        w.completeState = parts[13]
      }
      if (parts.length >= 15) {
        w.starRating = DateHelper.safeInt(parts[14], 0)
      }
      if (parts.length >= 16) {
        w.sessionTitle = parts[15]
      }
      out.push(w)
    }
    out.sort((a, b) => b.timestamp - a.timestamp)
    return out
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
    await WorkoutStore.ensurePref()
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
