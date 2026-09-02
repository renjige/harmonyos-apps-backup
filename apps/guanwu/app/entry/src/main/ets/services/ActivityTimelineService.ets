import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { ActivityEvent } from '../models/ActivityModels'
import { ObserveRecord } from '../models/ObserveModels'
import { ObserveSubject } from '../models/ObserveCatalog'
import { DateHelper } from './DateHelper'

const STORE = 'guanwu_timeline_v1'
const KEY_EVENTS = 'events'
const MAX_EVENTS = 120

export class ActivityTimelineService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ActivityTimelineService.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ActivityTimelineService.pref = null
    }
  }

  static async loadRecent(limit: number = 40): Promise<ActivityEvent[]> {
    const all = await ActivityTimelineService.loadAll()
    const out: ActivityEvent[] = []
    for (let i = 0; i < all.length && i < limit; i++) {
      out.push(all[i])
    }
    return out
  }

  static async append(type: string, refId: string, title: string, summary: string): Promise<void> {
    const ev = new ActivityEvent()
    ev.id = `${Date.now()}_${Math.floor(Math.random() * 10000)}`
    ev.type = type
    ev.refId = refId
    ev.title = title
    ev.summary = summary
    ev.dateKey = DateHelper.todayKey()
    ev.timestamp = Date.now()
    const all = await ActivityTimelineService.loadAll()
    all.unshift(ev)
    while (all.length > MAX_EVENTS) {
      all.pop()
    }
    await ActivityTimelineService.persist(all)
  }

  static async onRecordAdded(record: ObserveRecord): Promise<void> {
    const title = record.kindLabel()
    const summary = record.content.length > 36 ? `${record.content.substring(0, 36)}…` : record.content
    await ActivityTimelineService.append('record', record.id, `新建${title}观察`, summary)
  }

  static async onRecordUpdated(record: ObserveRecord): Promise<void> {
    await ActivityTimelineService.append('record_edit', record.id, '更新观察记录',
      record.content.length > 36 ? `${record.content.substring(0, 36)}…` : record.content)
  }

  static async onFavorite(record: ObserveRecord, favorited: boolean): Promise<void> {
    if (favorited) {
      await ActivityTimelineService.append('favorite', record.id, '收藏观察',
        record.content.length > 28 ? `${record.content.substring(0, 28)}…` : record.content)
    }
  }

  static async onCheckIn(): Promise<void> {
    await ActivityTimelineService.append('checkin', DateHelper.todayKey(), '今日已观', '完成今日观察打卡')
  }

  static async onSubjectCreated(subject: ObserveSubject): Promise<void> {
    await ActivityTimelineService.append('atlas', subject.id, '新建图鉴', subject.name)
  }

  static async onPlanDone(label: string): Promise<void> {
    await ActivityTimelineService.append('plan', '', '完成今日计划', label)
  }

  static async onAchievement(id: string, title: string): Promise<void> {
    await ActivityTimelineService.append('achievement', id, '解锁成就', title)
  }

  private static async loadAll(): Promise<ActivityEvent[]> {
    const raw = await ActivityTimelineService.getString(KEY_EVENTS, '')
    const out: ActivityEvent[] = []
    if (raw.length === 0) {
      return out
    }
    for (const line of raw.split('\n')) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 7) {
        continue
      }
      const ev = new ActivityEvent()
      ev.id = parts[0]
      ev.type = parts[1]
      ev.refId = parts[2]
      ev.title = parts[3]
      ev.summary = parts[4]
      ev.dateKey = parts[5]
      ev.timestamp = parseInt(parts[6], 10)
      out.push(ev)
    }
    out.sort((a, b) => b.timestamp - a.timestamp)
    return out
  }

  private static async persist(items: ActivityEvent[]): Promise<void> {
    const lines: string[] = []
    for (const ev of items) {
      const sum = ev.summary.replace(/\t/g, ' ').replace(/\n/g, ' ')
      const tit = ev.title.replace(/\t/g, ' ')
      lines.push(`${ev.id}\t${ev.type}\t${ev.refId}\t${tit}\t${sum}\t${ev.dateKey}\t${ev.timestamp}`)
    }
    await ActivityTimelineService.putString(KEY_EVENTS, lines.join('\n'))
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ActivityTimelineService.pref === null) {
      return fallback
    }
    try {
      const v = await ActivityTimelineService.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ActivityTimelineService.pref === null) {
      return
    }
    try {
      await ActivityTimelineService.pref.put(key, value)
      await ActivityTimelineService.pref.flush()
    } catch {
    }
  }
}
