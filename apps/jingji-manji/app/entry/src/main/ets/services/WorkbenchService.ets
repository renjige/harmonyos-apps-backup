import { WorkbenchStats } from '../models/SportModels'
import { SportStore } from './SportStore'
import { SportAnalytics } from './SportAnalytics'
import { FavoriteStore } from './FavoriteStore'
import { PlanStore } from './PlanStore'
import { SportRecordService } from './SportRecordService'

export class WorkbenchService {
  static stats(): WorkbenchStats {
    const s = new WorkbenchStats()
    const summary = SportAnalytics.summarize()
    s.totalRecords = summary.totalSessions
    s.streakDays = summary.streakDays
    s.favoriteCount = FavoriteStore.count()
    const today = SportRecordService.todayKey()
    for (const r of SportStore.list()) {
      if (r.recordDate === today) {
        s.todaySessions += 1
      }
    }
    s.todayHasRecord = s.todaySessions > 0
    let done = 0
    let total = 0
    for (const p of PlanStore.active()) {
      for (const t of p.tasks) {
        total += t.targetCount
        done += t.doneCount > t.targetCount ? t.targetCount : t.doneCount
      }
    }
    s.activePlanTasksDone = done
    s.activePlanTasksTotal = total
    s.planProgressPct = total > 0 ? Math.round((done / total) * 100) : 0
    return s
  }
}
