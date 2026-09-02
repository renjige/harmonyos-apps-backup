import { ReviewSnapshot } from '../models/SportModels'
import { SportStore } from './SportStore'
import { SportRecordService } from './SportRecordService'
import { SportAnalytics } from './SportAnalytics'

export class ReviewService {
  static today(): ReviewSnapshot {
    const snap = new ReviewSnapshot()
    snap.period = 'today'
    snap.periodLabel = '今日回顾'
    const today = SportRecordService.todayKey()
    for (const r of SportStore.list()) {
      if (r.recordDate === today) {
        snap.sessions += 1
        snap.durationMin += r.durationMin
        snap.distanceKm += r.distanceKm
      }
    }
    if (snap.sessions === 0) {
      snap.highlights.push('今天还没有训练记录，去「训练」页完成一笔吧。')
    } else {
      snap.highlights.push(`今日已完成 ${snap.sessions} 次，共 ${snap.durationMin} 分钟。`)
      if (snap.distanceKm > 0) {
        snap.highlights.push(`今日里程 ${snap.distanceKm.toFixed(1)} km。`)
      }
    }
    return snap
  }

  static week(): ReviewSnapshot {
    const snap = new ReviewSnapshot()
    snap.period = 'week'
    snap.periodLabel = '本周回顾'
    const cmp = SportAnalytics.weekCompare()
    snap.sessions = cmp.thisWeekSessions
    snap.durationMin = cmp.thisWeekDurationMin
    for (const r of SportStore.list()) {
      const idx = SportAnalyticsWeekIndex(r.recordDate)
      if (idx >= 0 && idx < 7) {
        snap.distanceKm += r.distanceKm
      }
    }
    snap.highlights.push(`本周 ${snap.sessions} 次 · ${snap.durationMin} 分钟 · ${snap.distanceKm.toFixed(1)} km。`)
    if (cmp.deltaSessions > 0) {
      snap.highlights.push(`比上周多练 ${cmp.deltaSessions} 次，节奏向上。`)
    } else if (cmp.deltaSessions < 0) {
      snap.highlights.push(`比上周少 ${Math.abs(cmp.deltaSessions)} 次，可设一个小计划拉回状态。`)
    } else {
      snap.highlights.push('与上周训练次数持平，保持稳定也是进步。')
    }
    return snap
  }

  static month(): ReviewSnapshot {
    const full = SportAnalytics.monthlyReport()
    const snap = new ReviewSnapshot()
    snap.period = 'month'
    snap.periodLabel = full.monthLabel
    snap.sessions = full.sessions
    snap.durationMin = full.durationMin
    snap.distanceKm = full.distanceKm
    for (const line of full.highlights) {
      snap.highlights.push(line)
    }
    return snap
  }
}

function SportAnalyticsWeekIndex(dateKey: string): number {
  try {
    const parts = dateKey.split('-')
    if (parts.length < 3) {
      return -1
    }
    const y = parseInt(parts[0], 10)
    const m = parseInt(parts[1], 10) - 1
    const day = parseInt(parts[2], 10)
    const d = new Date(y, m, day)
    const now = new Date()
    now.setHours(0, 0, 0, 0)
    d.setHours(0, 0, 0, 0)
    const diffDays = Math.round((now.getTime() - d.getTime()) / 86400000)
    if (diffDays < 0 || diffDays > 6) {
      return -1
    }
    return 6 - diffDays
  } catch {
    return -1
  }
}
