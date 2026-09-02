import { WeeklySnapshot, WorkoutRecord, WorkoutTypeOption } from '../models/WorkoutModels'
import { DateHelper } from './DateHelper'
import { StatsService } from './StatsService'
import { WorkoutStore } from './WorkoutStore'

export class InsightService {
  static async weeklyInsight(): Promise<string> {
    const week = await StatsService.weekStats()
    const settings = await WorkoutStore.loadSettings()
    if (week.count === 0) {
      return '本周还没有运动痕迹。点「开始运动」或到「留痕」补记一场，把今天留下。'
    }
    if (week.count >= settings.weeklyGoal) {
      return `本周已留下 ${week.count} 道痕迹，达成每周目标。去「留痕」写一句本周复盘吧。`
    }
    const left = settings.weeklyGoal - week.count
    return `本周已运动 ${week.count} 次，距离目标还差 ${left} 次。每一次都会在时间线上留下印记。`
  }

  static composeWeekInsight(records: WorkoutRecord[], goal: number): string {
    if (records.length === 0) {
      return '这一周还是空白。补记或开始一场运动，时间线就会出现第一个点。'
    }
    let totalMin = 0
    for (const r of records) {
      totalMin += r.durationMinutes()
    }
    const topKey = InsightService.topType(records)
    const topName = WorkoutTypeOption.labelFor(topKey)
    const goalHint = records.length >= goal ?
      '已达成每周目标。' : `距目标还差 ${goal - records.length} 次。`
    return `本周运动 ${records.length} 次、共 ${totalMin} 分钟，以「${topName}」居多。${goalHint}`
  }

  static async recentSnapshots(weekCount: number): Promise<WeeklySnapshot[]> {
    const saved = await WorkoutStore.loadSnapshots()
    const settings = await WorkoutStore.loadSettings()
    const out: WeeklySnapshot[] = []
    const cursor = new Date()
    for (let w = 0; w < weekCount; w++) {
      const end = new Date(cursor.getTime())
      end.setDate(end.getDate() - w * 7)
      const monday = DateHelper.mondayKey(DateHelper.keyFromDate(end))
      const keys = DateHelper.weekKeysFromMonday(monday)
      const records = await WorkoutStore.workoutsInRange(keys[0], keys[keys.length - 1])
      const snap = new WeeklySnapshot()
      snap.id = monday
      snap.weekStart = monday
      snap.weekLabel = DateHelper.weekRangeLabel(monday)
      snap.count = records.length
      let mins = 0
      for (const r of records) {
        mins += r.durationMinutes()
      }
      snap.totalMinutes = mins
      snap.topType = InsightService.topType(records)
      snap.insight = InsightService.composeWeekInsight(records, settings.weeklyGoal)
      for (const s of saved) {
        if (s.id === monday) {
          snap.reflection = s.reflection
          snap.pinned = s.pinned
        }
      }
      if (snap.count > 0 || snap.reflection.length > 0 || snap.pinned === 1) {
        out.push(snap)
      }
    }
    const pinned: WeeklySnapshot[] = []
    const rest: WeeklySnapshot[] = []
    for (const s of out) {
      if (s.pinned === 1) {
        pinned.push(s)
      } else {
        rest.push(s)
      }
    }
    return pinned.concat(rest)
  }

  private static topType(records: WorkoutRecord[]): string {
    if (records.length === 0) {
      return ''
    }
    const opts = WorkoutTypeOption.all()
    const counts: number[] = []
    for (let i = 0; i < opts.length; i++) {
      counts.push(0)
    }
    for (const r of records) {
      const ck = WorkoutTypeOption.canonical(r.typeKey)
      for (let i = 0; i < opts.length; i++) {
        if (opts[i].key === ck) {
          counts[i]++
        }
      }
    }
    let best = 0
    for (let i = 1; i < counts.length; i++) {
      if (counts[i] > counts[best]) {
        best = i
      }
    }
    return opts[best].key
  }
}
