import { TimelineEvent } from '../models/UserKnowledgeModels'
import { WanXiangLocalStore } from './WanXiangLocalStore'

const KEY_TIMELINE = 'timeline_events'
const MAX_EVENTS = 80

export class TimelineService {
  static async log(type: string, title: string, refId: string): Promise<void> {
    const id = WanXiangLocalStore.newId('tl')
    const event = TimelineEvent.create(id, type, title, refId)
    const list = await TimelineService.listAll()
    list.unshift(event)
    if (list.length > MAX_EVENTS) {
      list.length = MAX_EVENTS
    }
    const parts: string[] = []
    for (const e of list) {
      parts.push(`${e.id}|${e.type}|${e.title}|${e.refId}|${e.timestamp}`)
    }
    await WanXiangLocalStore.putString(KEY_TIMELINE, parts.join('||'))
  }

  static async listAll(): Promise<TimelineEvent[]> {
    const raw = await WanXiangLocalStore.getString(KEY_TIMELINE, '')
    const out: TimelineEvent[] = []
    if (raw.length === 0) {
      return out
    }
    const chunks = raw.split('||')
    for (const chunk of chunks) {
      const parts = chunk.split('|')
      if (parts.length >= 5) {
        const e = new TimelineEvent()
        e.id = parts[0]
        e.type = parts[1]
        e.title = parts[2]
        e.refId = parts[3]
        e.timestamp = parts[4]
        out.push(e)
      }
    }
    return out
  }

  static async recent(limit: number): Promise<TimelineEvent[]> {
    const all = await TimelineService.listAll()
    if (all.length <= limit) {
      return all
    }
    return all.slice(0, limit)
  }

  static formatTime(iso: string): string {
    if (iso.length < 16) {
      return iso
    }
    const d = new Date(iso)
    const h = d.getHours()
    const m = d.getMinutes()
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${h}:${ms}`
  }

  static formatDay(iso: string): string {
    if (iso.length < 10) {
      return iso
    }
    const d = new Date(iso)
    const now = new Date()
    const today = ReadingPlanDateKey(now)
    const yesterday = new Date(now)
    yesterday.setDate(now.getDate() - 1)
    const yKey = ReadingPlanDateKey(yesterday)
    const key = ReadingPlanDateKey(d)
    if (key === today) {
      return '今天'
    }
    if (key === yKey) {
      return '昨天'
    }
    return `${d.getMonth() + 1}月${d.getDate()}日`
  }
}

function ReadingPlanDateKey(d: Date): string {
  const y = d.getFullYear()
  const m = d.getMonth() + 1
  const day = d.getDate()
  const ms = m < 10 ? `0${m}` : `${m}`
  const ds = day < 10 ? `0${day}` : `${day}`
  return `${y}-${ms}-${ds}`
}
