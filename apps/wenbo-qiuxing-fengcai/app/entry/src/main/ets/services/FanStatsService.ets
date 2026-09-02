import { EventItem, WatchPlanItem } from '../models/StarModels'
import { FanDashboardSnapshot, TimelineEntry, WeeklyReviewSnapshot } from '../models/FanGrowthModels'
import { BrowseHistoryService } from './BrowseHistoryService'
import { ScoutNoteService } from './ScoutNoteService'
import { WatchPlanService } from './WatchPlanService'
import { QuizRecordService } from './QuizRecordService'
import { CompareSetService } from './CompareSetService'
import { WatchReviewService } from './WatchReviewService'
import { StreakService } from './StreakService'
import { AchievementService } from './AchievementService'

/** 聚合球迷工作台数据 */
export class FanStatsService {
  static dashboard(): FanDashboardSnapshot {
    const snap = new FanDashboardSnapshot()
    snap.watchedCount = WatchPlanService.watchedCount()
    snap.planTotal = WatchPlanService.count()
    if (snap.planTotal > 0) {
      snap.planProgress = snap.watchedCount / snap.planTotal
    }
    snap.noteCount = ScoutNoteService.count()
    snap.browseCount = BrowseHistoryService.count()
    snap.streakDays = StreakService.openStreak()
    const qs = QuizRecordService.statsSnapshot()
    snap.quizBest = qs.bestScore
    snap.quizAttempts = qs.totalAttempts
    snap.reviewCount = WatchReviewService.count()
    snap.compareSetCount = CompareSetService.count()
    const next = FanStatsService.nextUnwatchedPlan()
    if (next !== undefined) {
      snap.nextPlanTitle = next.title
      const ev = new EventItem()
      ev.startAt = next.startAt
      ev.status = 'upcoming'
      snap.nextPlanCountdown = ev.countdownLabel()
    }
    return snap
  }

  static nextUnwatchedPlan(): WatchPlanItem | undefined {
    for (const item of WatchPlanService.list()) {
      if (!item.watched) {
        return item
      }
    }
    return undefined
  }

  static weekReview(): WeeklyReviewSnapshot {
    const snap = new WeeklyReviewSnapshot()
    const now = new Date()
    const day = now.getDay()
    const diff = day === 0 ? 6 : day - 1
    const monday = new Date(now.getFullYear(), now.getMonth(), now.getDate() - diff)
    monday.setHours(0, 0, 0, 0)
    const weekStart = monday.getTime()
    snap.weekKey = `${monday.getFullYear()}-W${Math.ceil((monday.getDate()) / 7)}`
    for (const item of WatchPlanService.list()) {
      if (item.watched && item.addedAt >= weekStart) {
        snap.watchedCount += 1
      }
    }
    for (const note of ScoutNoteService.list()) {
      if (note.updatedAt >= weekStart) {
        snap.notesCount += 1
      }
    }
    for (const r of QuizRecordService.list()) {
      if (r.at >= weekStart) {
        snap.quizAttempts += 1
      }
    }
    snap.browseCount = BrowseHistoryService.count()
    return snap
  }

  static async bumpAndEvaluate(): Promise<string> {
    await AchievementService.evaluateAll()
    return AchievementService.consumeToast()
  }
}
