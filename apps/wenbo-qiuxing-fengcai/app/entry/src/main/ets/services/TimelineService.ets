import { TimelineEntry } from '../models/FanGrowthModels'
import { BrowseHistoryService } from './BrowseHistoryService'
import { ScoutNoteService } from './ScoutNoteService'
import { WatchPlanService } from './WatchPlanService'
import { QuizRecordService } from './QuizRecordService'
import { WatchReviewService } from './WatchReviewService'
import { AchievementService } from './AchievementService'

/** 合并浏览/计划/笔记/测验/观赛评/成就 — 按时间排序 */
export class TimelineService {
  static list(limit: number = 30): TimelineEntry[] {
    const all: TimelineEntry[] = []
    for (const h of BrowseHistoryService.list(20)) {
      const e = new TimelineEntry()
      e.id = `browse_${h.kind}_${h.id}`
      e.kind = 'browse'
      e.title = h.title
      e.subtitle = `浏览${h.kindLabel()}`
      e.at = h.viewedAt
      e.refId = h.id
      e.refKind = h.kind
      all.push(e)
    }
    for (const p of WatchPlanService.list()) {
      const e = new TimelineEntry()
      e.id = `plan_${p.eventId}`
      e.kind = 'plan'
      e.title = p.title
      e.subtitle = p.watched ? '已标记观看' : '加入观赛计划'
      e.at = p.addedAt
      e.refId = p.eventId
      e.refKind = 'event'
      all.push(e)
    }
    for (const n of ScoutNoteService.list()) {
      const e = new TimelineEntry()
      e.id = `note_${n.athleteId}`
      e.kind = 'note'
      e.title = n.title.length > 0 ? n.title : '球探笔记'
      e.subtitle = n.scoreLine()
      e.at = n.updatedAt
      e.refId = n.athleteId
      e.refKind = 'athlete'
      all.push(e)
    }
    for (const q of QuizRecordService.list()) {
      const e = new TimelineEntry()
      e.id = q.id
      e.kind = 'quiz'
      e.title = `知识挑战 ${q.score}/${q.total}`
      e.subtitle = '完成一轮测验'
      e.at = q.at
      e.refId = q.id
      e.refKind = 'quiz'
      all.push(e)
    }
    for (const r of WatchReviewService.list()) {
      const e = new TimelineEntry()
      e.id = r.id
      e.kind = 'review'
      e.title = r.eventTitle
      e.subtitle = `观赛评 ${r.rating} 星 · ${r.athleteName}`
      e.at = r.watchedAt
      e.refId = r.eventId
      e.refKind = 'event'
      all.push(e)
    }
    for (const u of AchievementService.listUnlocked()) {
      const def = AchievementService.defById(u.id)
      if (def !== undefined) {
        const e = new TimelineEntry()
        e.id = `ach_${u.id}`
        e.kind = 'achievement'
        e.title = def.title
        e.subtitle = def.caption
        e.at = u.unlockedAt
        e.refId = u.id
        e.refKind = 'achievement'
        all.push(e)
      }
    }
    return TimelineService.sortAndTrim(all, limit)
  }

  private static sortAndTrim(items: TimelineEntry[], limit: number): TimelineEntry[] {
    const sorted: TimelineEntry[] = []
    for (const item of items) {
      sorted.push(item)
    }
    sorted.sort((a: TimelineEntry, b: TimelineEntry): number => {
      if (a.at > b.at) {
        return -1
      }
      if (a.at < b.at) {
        return 1
      }
      return 0
    })
    const out: TimelineEntry[] = []
    let i = 0
    while (i < sorted.length && out.length < limit) {
      out.push(sorted[i])
      i += 1
    }
    return out
  }
}
