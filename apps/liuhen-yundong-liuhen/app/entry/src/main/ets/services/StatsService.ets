import {
  AchievementDef, HomePageSnapshot, MonthStats, PersonalBest, TrendBar, TypeShare, WeekStats,
  WorkoutRecord, WorkoutTypeOption
} from '../models/WorkoutModels'
import { DateHelper } from './DateHelper'
import { WorkoutStore } from './WorkoutStore'

export class StatsService {
  static initHomeStatsStorage(): void {
    AppStorage.setOrCreate('homeWeekCount', 0)
    AppStorage.setOrCreate('homeWeekMinutes', 0)
    AppStorage.setOrCreate('homeWeekAvg', 0)
    AppStorage.setOrCreate('homeWeekMax', 0)
    AppStorage.setOrCreate('homeMonthCount', 0)
    AppStorage.setOrCreate('homeWeekRange', '')
    AppStorage.setOrCreate('homeLatestMinutes', 0)
    AppStorage.setOrCreate('homeLatestDistance', 0)
    AppStorage.setOrCreate('homeLatestDateKey', '')
    AppStorage.setOrCreate('homeLatestId', '')
    AppStorage.setOrCreate('homeLatestInWeek', 0)
    AppStorage.setOrCreate('homeStatsEpoch', 0)
  }

  static async publishHomeStats(): Promise<void> {
    const snap = await StatsService.loadHomeSnapshot()
    AppStorage.setOrCreate('homeWeekCount', snap.week.count)
    AppStorage.setOrCreate('homeWeekMinutes', snap.week.totalMinutes)
    AppStorage.setOrCreate('homeWeekAvg', snap.week.avgMinutes)
    AppStorage.setOrCreate('homeWeekMax', snap.week.maxMinutes)
    AppStorage.setOrCreate('homeMonthCount', snap.month.count)
    AppStorage.setOrCreate('homeWeekRange', snap.weekRangeLabel)
    if (snap.latest !== undefined) {
      AppStorage.setOrCreate('homeLatestMinutes', snap.latest.durationMinutes())
      AppStorage.setOrCreate('homeLatestDistance', snap.latest.distanceKm)
      AppStorage.setOrCreate('homeLatestDateKey', snap.latest.dateKey)
      AppStorage.setOrCreate('homeLatestId', snap.latest.id)
      AppStorage.setOrCreate('homeLatestInWeek', snap.latestInWeek ? 1 : 0)
    } else {
      AppStorage.setOrCreate('homeLatestMinutes', 0)
      AppStorage.setOrCreate('homeLatestDistance', 0)
      AppStorage.setOrCreate('homeLatestDateKey', '')
      AppStorage.setOrCreate('homeLatestId', '')
      AppStorage.setOrCreate('homeLatestInWeek', 0)
    }
    const n = (AppStorage.get<number>('homeStatsEpoch') ?? 0) + 1
    AppStorage.setOrCreate('homeStatsEpoch', n)
  }

  static async loadHomeSnapshot(): Promise<HomePageSnapshot> {
    const list = await WorkoutStore.loadAll()
    return StatsService.snapshotFromRecords(list)
  }

  static snapshotFromRecords(list: WorkoutRecord[]): HomePageSnapshot {
    const snap = new HomePageSnapshot()
    const monday = DateHelper.mondayKey(DateHelper.todayKey())
    snap.weekRangeLabel = DateHelper.weekRangeLabel(monday)
    const weekRecords: WorkoutRecord[] = []
    for (const r of list) {
      if (DateHelper.isRecordInWeek(r.dateKey, r.timestamp, monday)) {
        weekRecords.push(r)
      }
    }
    snap.week = StatsService.buildWeekStats(weekRecords)
    snap.month = StatsService.buildMonthStats(list)
    if (list.length > 0) {
      snap.latest = list[0]
      snap.latestInWeek = DateHelper.isRecordInWeek(list[0].dateKey, list[0].timestamp, monday)
    }
    return snap
  }

  private static buildWeekStats(records: WorkoutRecord[]): WeekStats {
    const s = new WeekStats()
    s.count = records.length
    let totalSec = 0
    let maxMin = 0
    for (const r of records) {
      const sec = r.durationSeconds !== r.durationSeconds ? 0 : r.durationSeconds
      totalSec += sec
      const mins = Math.round(sec / 60)
      if (mins > maxMin) {
        maxMin = mins
      }
    }
    s.totalMinutes = Math.round(totalSec / 60)
    s.maxMinutes = maxMin
    s.avgMinutes = s.count > 0 ? Math.round(s.totalMinutes / s.count) : 0
    return s
  }

  private static buildMonthStats(list: WorkoutRecord[]): MonthStats {
    const ref = new Date()
    const m = new MonthStats()
    for (const r of list) {
      if (DateHelper.isRecordInMonth(r.dateKey, r.timestamp, ref)) {
        m.count++
        m.totalMinutes += Math.round(r.durationSeconds / 60)
        m.totalDistanceKm += r.distanceKm
      }
    }
    m.totalDistanceKm = Math.round(m.totalDistanceKm * 10) / 10
    return m
  }

  static async weekStats(): Promise<WeekStats> {
    const list = await WorkoutStore.loadAll()
    const monday = DateHelper.mondayKey(DateHelper.todayKey())
    const records: WorkoutRecord[] = []
    for (const r of list) {
      if (DateHelper.isRecordInWeek(r.dateKey, r.timestamp, monday)) {
        records.push(r)
      }
    }
    return StatsService.buildWeekStats(records)
  }

  static async monthStats(): Promise<MonthStats> {
    const list = await WorkoutStore.loadAll()
    return StatsService.buildMonthStats(list)
  }

  static async totalStats(): Promise<MonthStats> {
    const list = await WorkoutStore.loadAll()
    const m = new MonthStats()
    m.count = list.length
    let totalSec = 0
    let dist = 0
    for (const r of list) {
      totalSec += r.durationSeconds
      dist += r.distanceKm
    }
    m.totalMinutes = Math.round(totalSec / 60)
    m.totalDistanceKm = Math.round(dist * 10) / 10
    return m
  }

  static async streakDays(): Promise<number> {
    let streak = 0
    const cursor = new Date()
    const todayKey = DateHelper.todayKey()
    const todayList = await WorkoutStore.workoutsForDate(todayKey)
    if (todayList.length === 0) {
      cursor.setDate(cursor.getDate() - 1)
    }
    for (let i = 0; i < 366; i++) {
      const k = DateHelper.keyFromDate(cursor)
      const dayRecords = await WorkoutStore.workoutsForDate(k)
      if (dayRecords.length > 0) {
        streak++
        cursor.setDate(cursor.getDate() - 1)
      } else {
        break
      }
    }
    return streak
  }

  static async weeklyTrendBars(weeks: number): Promise<TrendBar[]> {
    const out: TrendBar[] = []
    const cursor = new Date()
    for (let w = weeks - 1; w >= 0; w--) {
      const end = new Date(cursor)
      end.setDate(end.getDate() - w * 7)
      const monday = DateHelper.mondayKey(DateHelper.keyFromDate(end))
      const keys = DateHelper.weekKeysFromMonday(monday)
      const records = await WorkoutStore.workoutsInRange(keys[0], keys[keys.length - 1])
      const bar = new TrendBar()
      bar.label = DateHelper.displayShort(monday)
      bar.count = records.length
      out.push(bar)
    }
    return out
  }

  static async monthActiveDates(year: number, month: number): Promise<string[]> {
    const keys = DateHelper.monthKeys(year, month)
    const records = await WorkoutStore.workoutsInRange(keys[0], keys[keys.length - 1])
    const seen: string[] = []
    for (const r of records) {
      let found = false
      for (const s of seen) {
        if (s === r.dateKey) {
          found = true
          break
        }
      }
      if (!found) {
        seen.push(r.dateKey)
      }
    }
    return seen
  }

  static async weekendSessionsThisMonth(): Promise<number> {
    const d = new Date()
    const keys = DateHelper.monthKeys(d.getFullYear(), d.getMonth() + 1)
    const records = await WorkoutStore.workoutsInRange(keys[0], keys[keys.length - 1])
    let n = 0
    for (const r of records) {
      const day = DateHelper.parseKey(r.dateKey).getDay()
      if (day === 0 || day === 6) {
        n++
      }
    }
    return n
  }

  static async typeShares(): Promise<TypeShare[]> {
    const list = await WorkoutStore.loadAll()
    const out: TypeShare[] = []
    for (const opt of WorkoutTypeOption.all()) {
      const share = new TypeShare()
      share.typeKey = opt.key
      share.label = opt.label
      for (const r of list) {
        const ck = WorkoutTypeOption.canonical(r.typeKey)
        if (ck === opt.key) {
          share.count++
          share.minutes += r.durationMinutes()
        }
      }
      if (share.count > 0) {
        out.push(share)
      }
    }
    return out
  }

  static async personalBests(): Promise<PersonalBest[]> {
    const list = await WorkoutStore.loadAll()
    const out: PersonalBest[] = []
    for (const opt of WorkoutTypeOption.all()) {
      let bestSec = 0
      let bestId = ''
      let bestDate = ''
      for (const r of list) {
        if (WorkoutTypeOption.canonical(r.typeKey) === opt.key && r.durationSeconds > bestSec) {
          bestSec = r.durationSeconds
          bestId = r.id
          bestDate = r.dateKey
        }
      }
      if (bestSec > 0) {
        const b = new PersonalBest()
        b.typeKey = opt.key
        b.label = opt.label
        b.durationSeconds = bestSec
        b.workoutId = bestId
        b.dateKey = bestDate
        out.push(b)
      }
    }
    return out
  }
}

export class AchievementService {
  static defs(): AchievementDef[] {
    const out: AchievementDef[] = []
    const rows: string[][] = [
      ['first', '首运动', '完成第一次运动记录', '1'],
      ['count3', '热身达人', '累计运动 3 次', '3'],
      ['count7', '一周活力', '累计运动 7 次', '7'],
      ['count14', '双周坚持', '累计运动 14 次', '14'],
      ['count30', '月度跑者', '累计运动 30 次', '30'],
      ['streak7', '连续7天', '连续 7 天有运动', '7'],
      ['streak14', '连续14天', '连续 14 天有运动', '14'],
      ['streak30', '连续30天', '连续 30 天有运动', '30']
    ]
    for (const row of rows) {
      const d = new AchievementDef()
      d.id = row[0]
      d.title = row[1]
      d.description = row[2]
      d.threshold = parseInt(row[3], 10)
      out.push(d)
    }
    return out
  }

  static async evaluateAndUnlock(): Promise<string[]> {
    const newly: string[] = []
    const total = await WorkoutStore.loadAll()
    const count = total.length
    const streak = await StatsService.streakDays()
    const unlocked = await WorkoutStore.loadUnlockedAchievements()
    const checks: string[][] = [
      ['first', '1', `${count}`],
      ['count3', '3', `${count}`],
      ['count7', '7', `${count}`],
      ['count14', '14', `${count}`],
      ['count30', '30', `${count}`],
      ['streak7', '7', `${streak}`],
      ['streak14', '14', `${streak}`],
      ['streak30', '30', `${streak}`]
    ]
    for (const c of checks) {
      const id = c[0]
      const need = parseInt(c[1], 10)
      const have = parseInt(c[2], 10)
      let already = false
      for (const u of unlocked) {
        if (u === id) {
          already = true
          break
        }
      }
      if (!already && have >= need) {
        await WorkoutStore.unlockAchievement(id)
        newly.push(id)
      }
    }
    return newly
  }
}
