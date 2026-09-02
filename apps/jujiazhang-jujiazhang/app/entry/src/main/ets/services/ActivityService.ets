import { ActivityEvent } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'
import { TaskDates } from '../models/FamilyTaskModels'

export class ActivityService {
  private static readonly MAX = 200

  static async log(kind: string, entityType: string, entityId: string, title: string, summary: string): Promise<void> {
    const rows = JujiaLocalStore.activities().slice()
    const ev = new ActivityEvent()
    ev.id = JujiaLocalStore.newId('act')
    ev.kind = kind
    ev.entityType = entityType
    ev.entityId = entityId
    ev.title = title
    ev.summary = summary
    ev.occurredAt = JujiaLocalStore.nowIso()
    rows.unshift(ev)
    const capped: ActivityEvent[] = []
    const limit = rows.length > ActivityService.MAX ? ActivityService.MAX : rows.length
    for (let i = 0; i < limit; i++) {
      capped.push(rows[i])
    }
    await JujiaLocalStore.saveActivities(capped)
  }

  static recent(limit: number): ActivityEvent[] {
    const rows = JujiaLocalStore.activities()
    const out: ActivityEvent[] = []
    const n = rows.length > limit ? limit : rows.length
    for (let i = 0; i < n; i++) {
      out.push(rows[i])
    }
    return out
  }

  static byDate(ymd: string): ActivityEvent[] {
    const out: ActivityEvent[] = []
    for (const row of JujiaLocalStore.activities()) {
      if (row.occurredAt.substring(0, 10) === ymd) {
        out.push(row)
      }
    }
    return out
  }

  static groupByDate(): string[] {
    const keys: string[] = []
    for (const row of JujiaLocalStore.activities()) {
      const day = row.occurredAt.substring(0, 10)
      let hit = false
      for (const k of keys) {
        if (k === day) {
          hit = true
          break
        }
      }
      if (!hit) {
        keys.push(day)
      }
    }
    return keys
  }

  static formatTime(iso: string): string {
    if (iso.length < 16) {
      return ''
    }
    return iso.substring(11, 16)
  }

  static todayLabel(): string {
    return TaskDates.displayDate(TaskDates.today())
  }
}
