import { TimelineEvent } from '../models/VitalityModels'
import { VitalityStore } from './VitalityStore'
import { DateHelper } from './DateHelper'
import { DimensionOption } from '../models/VitalityModels'
import { AchievementService } from './StatsService'

export class TimelineService {
  static async buildEvents(limit: number): Promise<TimelineEvent[]> {
    const events: TimelineEvent[] = []
    const records = await VitalityStore.loadAll()
    const actions = await VitalityStore.loadActions()
    const notes = await VitalityStore.loadNotes()
    const pins = await VitalityStore.loadPins()
    const achievements = await VitalityStore.loadUnlockedAchievements()

    for (const r of records) {
      if (!r.isComplete()) {
        continue
      }
      const e = new TimelineEvent()
      e.id = `rec-${r.dateKey}`
      e.eventType = 'checkin'
      e.dateKey = r.dateKey
      e.title = '活力记录'
      e.summary = `运动${DimensionOption.labelFor('exercise', r.exerciseKey)} · 心情${DimensionOption.labelFor('mood', r.moodKey)} · 活力${r.vitalityScore()}`
      e.refId = r.dateKey
      e.timestamp = r.timestamp
      events.push(e)
    }

    for (const a of actions) {
      if (!a.done) {
        continue
      }
      const e = new TimelineEvent()
      e.id = `act-${a.id}`
      e.eventType = 'action'
      e.dateKey = a.dateKey
      e.title = '完成行动'
      e.summary = a.title
      e.refId = a.id
      e.timestamp = DateHelper.parseKey(a.dateKey).getTime()
      events.push(e)
    }

    for (const n of notes) {
      const e = new TimelineEvent()
      e.id = `note-${n.id}`
      e.eventType = 'note'
      e.dateKey = n.dateKey.length > 0 ? n.dateKey : DateHelper.todayKey()
      e.title = n.title.length > 0 ? n.title : '纪行笔记'
      e.summary = n.body.length > 28 ? `${n.body.substring(0, 28)}…` : n.body
      e.refId = n.id
      e.timestamp = n.createdAt
      events.push(e)
    }

    for (const p of pins) {
      const e = new TimelineEvent()
      e.id = `pin-${p}`
      e.eventType = 'highlight'
      e.dateKey = p
      e.title = '高光日'
      e.summary = DateHelper.displayDate(p)
      e.refId = p
      e.timestamp = DateHelper.parseKey(p).getTime()
      events.push(e)
    }

    for (const ach of achievements) {
      const e = new TimelineEvent()
      e.id = `ach-${ach}`
      e.eventType = 'achievement'
      e.dateKey = DateHelper.todayKey()
      e.title = '解锁成就'
      e.summary = `「${AchievementService.titleFor(ach)}」${AchievementService.descriptionFor(ach)}`
      e.refId = ach
      e.timestamp = Date.now()
      events.push(e)
    }

    events.sort((a: TimelineEvent, b: TimelineEvent): number => b.timestamp - a.timestamp)
    const out: TimelineEvent[] = []
    for (let i = 0; i < events.length && i < limit; i++) {
      out.push(events[i])
    }
    return out
  }
}
