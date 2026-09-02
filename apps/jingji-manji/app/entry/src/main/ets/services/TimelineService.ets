import { TimelineEvent } from '../models/SportModels'
import { SportStore } from './SportStore'
import { PlanStore } from './PlanStore'
import { FavoriteStore } from './FavoriteStore'
import { AchievementEngine } from './AchievementEngine'

export class TimelineService {
  static build(limit: number = 40): TimelineEvent[] {
    const events: TimelineEvent[] = []
    for (const r of SportStore.list()) {
      const e = new TimelineEvent()
      e.date = r.recordDate
      e.eventType = 'record'
      e.title = `${r.sportType} · ${r.durationMin} 分钟`
      e.subtitle = r.takeaway.length > 0 ? r.takeaway : r.tags
      e.refId = r.id
      events.push(e)
    }
    for (const p of PlanStore.list()) {
      if (p.status === 'done') {
        const e = new TimelineEvent()
        e.date = p.weekEnd
        e.eventType = 'plan'
        e.title = `完成周计划：${p.title}`
        e.subtitle = `${p.weekStart} → ${p.weekEnd}`
        e.refId = p.id
        events.push(e)
      }
    }
    for (const f of FavoriteStore.list()) {
      if (f.targetType === 'record') {
        const r = SportStore.findById(f.targetId)
        if (r !== null) {
          const e = new TimelineEvent()
          e.date = f.createdAt.substring(0, 10)
          e.eventType = 'favorite'
          e.title = `收藏训练：${r.sportType}`
          e.subtitle = r.recordDate
          e.refId = r.id
          events.push(e)
        }
      }
    }
    for (const a of AchievementEngine.evaluate()) {
      if (a.unlocked && a.unlockedAt.length > 0) {
        const e = new TimelineEvent()
        e.date = a.unlockedAt
        e.eventType = 'achievement'
        e.title = `解锁成就：${a.title}`
        e.subtitle = a.description
        e.refId = a.id
        events.push(e)
      }
    }
    events.sort((a: TimelineEvent, b: TimelineEvent) => b.date.localeCompare(a.date))
    const out: TimelineEvent[] = []
    for (let i = 0; i < events.length && i < limit; i++) {
      out.push(events[i])
    }
    return out
  }
}
