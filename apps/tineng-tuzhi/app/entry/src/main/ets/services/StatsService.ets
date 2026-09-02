import {
  HeatmapCell,
  MixBar,
  PersonalBest,
  TrendPoint,
  WeekCompareSnapshot,
  WorkoutRecord,
  WorkoutStats,
  WorkoutTypeOption
} from '../models/WorkoutModels'
import { DateHelper } from './DateHelper'
import { WorkoutStore } from './WorkoutStore'

export class StatsService {
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
      const dayWorkouts = await WorkoutStore.workoutsForDate(k)
      if (dayWorkouts.length > 0) {
        streak++
        cursor.setDate(cursor.getDate() - 1)
      } else {
        break
      }
    }
    return streak
  }

  static async todayMinutes(): Promise<number> {
    const list = await WorkoutStore.workoutsForDate(DateHelper.todayKey())
    return StatsService.sumMinutes(list)
  }

  static async weekActiveDays(): Promise<number> {
    const keys = DateHelper.lastNDays(7)
    let count = 0
    for (const k of keys) {
      const day = await WorkoutStore.workoutsForDate(k)
      if (day.length > 0) {
        count++
      }
    }
    return count
  }

  static async weekProgress(): Promise<number> {
    const profile = await WorkoutStore.loadProfile()
    const active = await StatsService.weekActiveDays()
    if (profile.weeklyGoalDays === 0) {
      return 0
    }
    return Math.min(100, Math.round((active / profile.weeklyGoalDays) * 100))
  }

  static async trendPoints(mode: string): Promise<TrendPoint[]> {
    if (mode === 'year') {
      return StatsService.yearTrendPoints()
    }
    if (mode === 'month') {
      return StatsService.monthTrendPoints()
    }
    return StatsService.weekTrendPoints()
  }

  static async heatmapData(year?: number, month?: number): Promise<HeatmapCell[]> {
    const now = new Date()
    const y = year !== undefined ? year : now.getFullYear()
    const m = month !== undefined ? month : now.getMonth() + 1
    const keys = DateHelper.monthKeys(y, m)
    const all = await WorkoutStore.loadAll()
    const minuteMap: Map<string, number> = new Map()
    for (const w of all) {
      const prev = minuteMap.get(w.dateKey) ?? 0
      minuteMap.set(w.dateKey, prev + w.durationMinutes)
    }
    let maxMin = 1
    for (const k of keys) {
      const mins = minuteMap.get(k) ?? 0
      if (mins > maxMin) {
        maxMin = mins
      }
    }
    const out: HeatmapCell[] = []
    for (const k of keys) {
      const cell = new HeatmapCell()
      cell.dateKey = k
      cell.dayOfMonth = DateHelper.parseKey(k).getDate()
      cell.minutes = minuteMap.get(k) ?? 0
      if (cell.minutes === 0) {
        cell.level = 0
      } else if (cell.minutes < maxMin * 0.25) {
        cell.level = 1
      } else if (cell.minutes < maxMin * 0.5) {
        cell.level = 2
      } else if (cell.minutes < maxMin * 0.75) {
        cell.level = 3
      } else {
        cell.level = 4
      }
      out.push(cell)
    }
    return out
  }

  static async totals(): Promise<WorkoutStats> {
    const list = await WorkoutStore.loadAll()
    const profile = await WorkoutStore.loadProfile()
    const stats = new WorkoutStats()
    stats.totalWorkouts = list.length
    stats.totalMinutes = StatsService.sumMinutes(list)
    stats.totalCalories = StatsService.sumCalories(list)
    stats.totalDistanceKm = StatsService.sumDistance(list)
    stats.streakDays = await StatsService.streakDays()
    stats.todayMinutes = await StatsService.todayMinutes()
    stats.weekActiveDays = await StatsService.weekActiveDays()
    stats.weekGoalDays = profile.weeklyGoalDays
    const common = StatsService.mostCommonTypeKey(list)
    stats.mostCommonType = common
    stats.mostCommonTypeLabel = WorkoutTypeOption.labelFor(common)
    return stats
  }

  static async personalBests(): Promise<PersonalBest[]> {
    const list = await WorkoutStore.loadAll()
    const out: PersonalBest[] = []
    let maxDuration = 0
    let maxDistance = 0
    let maxCalories = 0
    let maxDayMinutes = 0
    const dayMap: Map<string, number> = new Map()
    for (const w of list) {
      if (w.durationMinutes > maxDuration) {
        maxDuration = w.durationMinutes
      }
      if (w.distanceKm > maxDistance) {
        maxDistance = w.distanceKm
      }
      if (w.calories > maxCalories) {
        maxCalories = w.calories
      }
      const prev = dayMap.get(w.dateKey) ?? 0
      dayMap.set(w.dateKey, prev + w.durationMinutes)
    }
    dayMap.forEach((mins: number) => {
      if (mins > maxDayMinutes) {
        maxDayMinutes = mins
      }
    })
    const pb1 = new PersonalBest()
    pb1.key = 'duration'
    pb1.label = '单次最长时长'
    pb1.value = `${maxDuration}`
    pb1.unit = '分钟'
    out.push(pb1)
    const pb2 = new PersonalBest()
    pb2.key = 'distance'
    pb2.label = '单次最远距离'
    pb2.value = maxDistance > 0 ? `${maxDistance.toFixed(1)}` : '0'
    pb2.unit = '公里'
    out.push(pb2)
    const pb3 = new PersonalBest()
    pb3.key = 'calories'
    pb3.label = '单次最高消耗'
    pb3.value = `${maxCalories}`
    pb3.unit = '千卡'
    out.push(pb3)
    const pb4 = new PersonalBest()
    pb4.key = 'day'
    pb4.label = '单日最高时长'
    pb4.value = `${maxDayMinutes}`
    pb4.unit = '分钟'
    out.push(pb4)
    return out
  }

  static mostCommonType(records: WorkoutRecord[]): string {
    return StatsService.mostCommonTypeKey(records)
  }

  private static mostCommonTypeKey(records: WorkoutRecord[]): string {
    const map: Map<string, number> = new Map()
    for (const w of records) {
      const c = map.get(w.typeKey) ?? 0
      map.set(w.typeKey, c + 1)
    }
    let top = 'other'
    let topC = 0
    map.forEach((count: number, key: string) => {
      if (count > topC) {
        topC = count
        top = key
      }
    })
    return top
  }

  private static async weekTrendPoints(): Promise<TrendPoint[]> {
    const keys = DateHelper.lastNDays(7)
    keys.reverse()
    return StatsService.buildTrendForKeys(keys)
  }

  private static async monthTrendPoints(): Promise<TrendPoint[]> {
    const d = new Date()
    const keys = DateHelper.monthKeys(d.getFullYear(), d.getMonth() + 1)
    const all = await WorkoutStore.loadAll()
    const minuteMap: Map<string, number> = new Map()
    for (const w of all) {
      const prev = minuteMap.get(w.dateKey) ?? 0
      minuteMap.set(w.dateKey, prev + w.durationMinutes)
    }
    const buckets: WeekTrendBucket[] = []
    for (let i = 0; i < 5; i++) {
      const b = new WeekTrendBucket()
      b.weekIndex = i
      buckets.push(b)
    }
    for (const k of keys) {
      const day = DateHelper.parseKey(k).getDate()
      let idx = Math.floor((day - 1) / 7)
      if (idx > 4) {
        idx = 4
      }
      for (const b of buckets) {
        if (b.weekIndex === idx) {
          b.minutes += minuteMap.get(k) ?? 0
          b.hasDays = true
        }
      }
    }
    const out: TrendPoint[] = []
    for (const b of buckets) {
      if (!b.hasDays) {
        continue
      }
      const p = new TrendPoint()
      p.dateKey = `mw-${b.weekIndex}`
      p.label = `第${b.weekIndex + 1}周`
      p.value = b.minutes
      out.push(p)
    }
    return out
  }

  private static async yearTrendPoints(): Promise<TrendPoint[]> {
    const d = new Date()
    const y = d.getFullYear()
    const out: TrendPoint[] = []
    for (let m = 1; m <= 12; m++) {
      const keys = DateHelper.monthKeys(y, m)
      const list = await WorkoutStore.workoutsInRange(keys[0], keys[keys.length - 1])
      const p = new TrendPoint()
      p.dateKey = `${y}-${m < 10 ? `0${m}` : `${m}`}`
      p.label = `${m}月`
      p.value = StatsService.sumMinutes(list)
      out.push(p)
    }
    return out
  }

  private static async buildTrendForKeys(keys: string[]): Promise<TrendPoint[]> {
    const all = await WorkoutStore.loadAll()
    const minuteMap: Map<string, number> = new Map()
    for (const w of all) {
      const prev = minuteMap.get(w.dateKey) ?? 0
      minuteMap.set(w.dateKey, prev + w.durationMinutes)
    }
    const out: TrendPoint[] = []
    for (const k of keys) {
      const p = new TrendPoint()
      p.dateKey = k
      p.label = DateHelper.displayShort(k)
      p.value = minuteMap.get(k) ?? 0
      out.push(p)
    }
    return out
  }

  private static sumMinutes(list: WorkoutRecord[]): number {
    let s = 0
    for (const w of list) {
      s += w.durationMinutes
    }
    return s
  }

  private static sumCalories(list: WorkoutRecord[]): number {
    let s = 0
    for (const w of list) {
      s += w.calories
    }
    return s
  }

  private static sumDistance(list: WorkoutRecord[]): number {
    let s = 0
    for (const w of list) {
      s += w.distanceKm
    }
    return Math.round(s * 10) / 10
  }

  static async sportMix(startKey: string, endKey: string): Promise<MixBar[]> {
    const list = await WorkoutStore.workoutsInRange(startKey, endKey)
    const minuteMap: Map<string, number> = new Map()
    let total = 0
    for (const w of list) {
      const prev = minuteMap.get(w.typeKey) ?? 0
      minuteMap.set(w.typeKey, prev + w.durationMinutes)
      total += w.durationMinutes
    }
    const out: MixBar[] = []
    for (const opt of WorkoutTypeOption.all()) {
      const mins = minuteMap.get(opt.key) ?? 0
      if (mins <= 0) {
        continue
      }
      const bar = new MixBar()
      bar.typeKey = opt.key
      bar.label = opt.label
      bar.minutes = mins
      bar.ratio = total > 0 ? mins / total : 0
      out.push(bar)
    }
    return out
  }

  static async weekCompareSnapshot(): Promise<WeekCompareSnapshot> {
    const today = DateHelper.todayKey()
    const thisKeys = DateHelper.weekDateKeys(today)
    const lastMonday = DateHelper.lastWeekMondayKey(today)
    const lastKeys = DateHelper.weekDateKeys(lastMonday)
    const thisList = await WorkoutStore.workoutsInRange(thisKeys[0], thisKeys[6])
    const lastList = await WorkoutStore.workoutsInRange(lastKeys[0], lastKeys[6])
    const snap = new WeekCompareSnapshot()
    snap.thisMinutes = StatsService.sumMinutes(thisList)
    snap.lastMinutes = StatsService.sumMinutes(lastList)
    snap.thisCalories = StatsService.sumCalories(thisList)
    snap.lastCalories = StatsService.sumCalories(lastList)
    snap.thisDays = StatsService.countActiveDays(thisList)
    snap.lastDays = StatsService.countActiveDays(lastList)
    snap.deltaMinutes = snap.thisMinutes - snap.lastMinutes
    return snap
  }

  static async peakDay(startKey: string, endKey: string): Promise<HeatmapCell> {
    const list = await WorkoutStore.workoutsInRange(startKey, endKey)
    const cell = new HeatmapCell()
    const map: Map<string, number> = new Map()
    for (const w of list) {
      const prev = map.get(w.dateKey) ?? 0
      map.set(w.dateKey, prev + w.durationMinutes)
    }
    let topKey = ''
    let topMins = 0
    map.forEach((mins: number, key: string) => {
      if (mins > topMins) {
        topMins = mins
        topKey = key
      }
    })
    cell.dateKey = topKey
    cell.minutes = topMins
    return cell
  }

  private static countActiveDays(list: WorkoutRecord[]): number {
    const set: Map<string, number> = new Map()
    for (const w of list) {
      set.set(w.dateKey, 1)
    }
    return set.size
  }
}

class WeekTrendBucket {
  weekIndex: number = 0
  minutes: number = 0
  hasDays: boolean = false
}
