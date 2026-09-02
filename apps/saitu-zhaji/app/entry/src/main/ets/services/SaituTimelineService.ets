import { TimelineEntry } from '../models/SaituGrowthModels'
import { SaituLocalStore } from './SaituLocalStore'
import { SaituTrackStore } from './SaituTrackStore'
import { SaituSportStore } from './SaituSportStore'
import { SaituCheckInStore } from './SaituCheckInStore'
import { SaituPlanStore } from './SaituPlanStore'

export class SaituTimelineService {
  static async build(limit: number): Promise<TimelineEntry[]> {
    const entries: TimelineEntry[] = []
    const records = await SaituLocalStore.loadRecords()
    const events = await SaituSportStore.loadEvents()
    const checkins = await SaituCheckInStore.loadCheckIns()
    const milestones = await SaituTrackStore.loadMilestones()
    const insights = await SaituTrackStore.loadInsights()
    const plans = await SaituPlanStore.loadPlans()
    const journeys = await SaituLocalStore.loadJourneys()
    const journeyMap = new Map<string, string>()
    for (const j of journeys) {
      journeyMap.set(j.id, j.name)
    }

    for (const r of records) {
      const e = new TimelineEntry()
      e.id = `tl_rec_${r.id}`
      e.kind = 'record'
      e.refId = r.id
      e.title = r.summaryLine(40)
      e.subtitle = journeyMap.get(r.journeyId) ?? '未挂旅途'
      e.timestamp = r.createdAt
      e.favorite = r.favorite
      entries.push(e)
    }

    for (const ev of events) {
      const e = new TimelineEntry()
      e.id = `tl_sport_${ev.id}`
      e.kind = 'sport'
      e.refId = ev.id
      e.title = ev.title.length > 0 ? ev.title : ev.kindLabel()
      e.subtitle = `${ev.kindLabel()} · ${ev.eventDate}`
      e.timestamp = ev.createdAt
      e.favorite = ev.favorite
      entries.push(e)
    }

    for (const c of checkins) {
      const e = new TimelineEntry()
      e.id = `tl_chk_${c.id}`
      e.kind = 'checkin'
      e.refId = c.id
      e.title = '赛途打卡'
      e.subtitle = journeyMap.get(c.journeyId) ?? c.dateKey
      e.timestamp = c.createdAt
      entries.push(e)
    }

    for (const m of milestones) {
      if (!m.done) {
        continue
      }
      const e = new TimelineEntry()
      e.id = `tl_ms_${m.id}`
      e.kind = 'milestone'
      e.refId = m.id
      e.title = `达成节点 · ${m.title}`
      e.subtitle = journeyMap.get(m.journeyId) ?? ''
      e.timestamp = m.updatedAt
      entries.push(e)
    }

    for (const s of insights) {
      const e = new TimelineEntry()
      e.id = `tl_ins_${s.id}`
      e.kind = 'insight'
      e.refId = s.id
      e.title = s.summaryLine()
      e.subtitle = s.periodLabel
      e.timestamp = s.createdAt
      e.favorite = s.favorite
      entries.push(e)
    }

    for (const p of plans) {
      if (p.status !== 'done') {
        continue
      }
      const e = new TimelineEntry()
      e.id = `tl_pl_${p.id}`
      e.kind = 'plan'
      e.refId = p.id
      e.title = `完成计划 · ${p.title}`
      e.subtitle = journeyMap.get(p.journeyId) ?? ''
      e.timestamp = p.updatedAt
      entries.push(e)
    }

    entries.sort((a, b) => b.timestamp - a.timestamp)
    if (limit > 0 && entries.length > limit) {
      return entries.slice(0, limit)
    }
    return entries
  }
}
