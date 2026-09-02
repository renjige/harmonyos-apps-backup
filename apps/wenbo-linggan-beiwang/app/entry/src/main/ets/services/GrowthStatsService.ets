import { InspirationItem } from '../models/InspirationModels'
import { CaptureStreakService } from './CaptureStreakService'
import { GrowthPayload } from '../models/GrowthModels'
import { WeeklyReviewService } from './WeeklyReviewService'

export class WeekDayCount {
  label: string = ''
  iso: string = ''
  count: number = 0
}

export class GrowthStatsSnapshot {
  captureTotal: number = 0
  favoriteTotal: number = 0
  boardTotal: number = 0
  planTotal: number = 0
  planAvgProgress: number = 0
  streakDays: number = 0
  weekCapture: number = 0
  weekGoal: number = 5
  checkInToday: boolean = false
  weekCheckIns: number = 0
  monthCheckIns: number = 0
  topicCount: number = 0
}

export class GrowthStatsService {
  static weekGoal(): number {
    return 5
  }

  static avgProgress(plans: InspirationItem[]): number {
    if (plans.length === 0) {
      return 0
    }
    let sum = 0
    for (const p of plans) {
      sum += p.progress
    }
    return Math.round(sum / plans.length)
  }

  static snapshot(
    inspirations: InspirationItem[],
    favorites: InspirationItem[],
    boards: InspirationItem[],
    plans: InspirationItem[],
    growth: GrowthPayload,
    checkInToday: boolean
  ): GrowthStatsSnapshot {
    const s = new GrowthStatsSnapshot()
    s.captureTotal = inspirations.length
    s.favoriteTotal = favorites.length
    s.boardTotal = boards.length
    s.planTotal = plans.length
    s.planAvgProgress = GrowthStatsService.avgProgress(plans)
    s.streakDays = CaptureStreakService.consecutiveDays(inspirations)
    const weekStart = WeeklyReviewService.weekStartIso()
    let week = 0
    for (const it of inspirations) {
      if (WeeklyReviewService.inThisWeek(WeeklyReviewService.itemDate(it), weekStart)) {
        week += 1
      }
    }
    s.weekCapture = week
    s.weekGoal = GrowthStatsService.weekGoal()
    s.checkInToday = checkInToday
    s.weekCheckIns = 0
    for (const c of growth.checkIns) {
      if (c.date >= weekStart) {
        s.weekCheckIns += 1
      }
    }
    const now = GrowthStatsService.monthPrefix()
    for (const c of growth.checkIns) {
      if (c.date.indexOf(now) === 0) {
        s.monthCheckIns += 1
      }
    }
    s.topicCount = growth.topics.length
    return s
  }

  static monthPrefix(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${d.getFullYear()}-${ms}`
  }

  static weekBars(inspirations: InspirationItem[]): WeekDayCount[] {
    const start = WeeklyReviewService.weekStartIso()
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '日']
    const parts = start.split('-')
    const y = parts.length > 0 ? parseInt(parts[0], 10) : 2026
    const mo = parts.length > 1 ? parseInt(parts[1], 10) : 1
    const da = parts.length > 2 ? parseInt(parts[2], 10) : 1
    const items: WeekDayCount[] = []
    for (let i = 0; i < 7; i++) {
      const d = new Date()
      d.setFullYear(y, mo - 1, da + i)
      const iso = CaptureStreakService.isoOf(d)
      let n = 0
      for (const it of inspirations) {
        if (WeeklyReviewService.itemDate(it) === iso) {
          n += 1
        }
      }
      const row = new WeekDayCount()
      row.label = labels[i]
      row.iso = iso
      row.count = n
      items.push(row)
    }
    return items
  }

  static weekProgressRatio(weekCapture: number, goal: number): number {
    if (goal <= 0) {
      return 0
    }
    const r = weekCapture / goal
    if (r > 1) {
      return 1
    }
    return r
  }
}
