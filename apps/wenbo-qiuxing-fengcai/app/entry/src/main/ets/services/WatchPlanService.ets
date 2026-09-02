import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { EventItem, WatchPlanItem } from '../models/StarModels'

const STORE_NAME = 'star_watch_plan'
const KEY_ITEMS = 'plans'
const MAX_ITEMS = 30

/** 观赛计划 — 用户自建赛程清单，可标记已看。 */
export class WatchPlanService {
  private static pref: preferences.Preferences | null = null
  private static items: WatchPlanItem[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      WatchPlanService.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await WatchPlanService.pref.get(KEY_ITEMS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      WatchPlanService.items = WatchPlanService.parse(text)
    } catch {
      WatchPlanService.items = []
    }
  }

  static list(): WatchPlanItem[] {
    const out: WatchPlanItem[] = []
    for (const item of WatchPlanService.items) {
      out.push(item)
    }
    return out
  }

  static count(): number {
    return WatchPlanService.items.length
  }

  static watchedCount(): number {
    let n = 0
    for (const item of WatchPlanService.items) {
      if (item.watched) {
        n += 1
      }
    }
    return n
  }

  static has(eventId: string): boolean {
    for (const item of WatchPlanService.items) {
      if (item.eventId === eventId) {
        return true
      }
    }
    return false
  }

  static async addEvent(event: EventItem): Promise<boolean> {
    if (WatchPlanService.has(event.id)) {
      return true
    }
    const row = new WatchPlanItem()
    row.eventId = event.id
    row.title = event.title
    row.startAt = event.startAt
    row.venue = event.venue
    row.athleteName = event.athleteName
    row.watched = false
    row.addedAt = Date.now()
    const next: WatchPlanItem[] = []
    next.push(row)
    for (const item of WatchPlanService.items) {
      next.push(item)
      if (next.length >= MAX_ITEMS) {
        break
      }
    }
    WatchPlanService.items = next
    await WatchPlanService.persist()
    return true
  }

  static async toggleWatched(eventId: string): Promise<boolean> {
    let nowWatched = false
    for (const item of WatchPlanService.items) {
      if (item.eventId === eventId) {
        item.watched = !item.watched
        nowWatched = item.watched
        break
      }
    }
    await WatchPlanService.persist()
    return nowWatched
  }

  static find(eventId: string): WatchPlanItem | undefined {
    for (const item of WatchPlanService.items) {
      if (item.eventId === eventId) {
        return item
      }
    }
    return undefined
  }

  static async remove(eventId: string): Promise<void> {
    const next: WatchPlanItem[] = []
    for (const item of WatchPlanService.items) {
      if (item.eventId !== eventId) {
        next.push(item)
      }
    }
    WatchPlanService.items = next
    await WatchPlanService.persist()
  }

  private static async persist(): Promise<void> {
    const payload: WatchPlanWire[] = []
    for (const item of WatchPlanService.items) {
      const w = new WatchPlanWire()
      w.eventId = item.eventId
      w.title = item.title
      w.startAt = item.startAt
      w.venue = item.venue
      w.athleteName = item.athleteName
      w.watched = item.watched
      w.addedAt = item.addedAt
      payload.push(w)
    }
    try {
      if (WatchPlanService.pref !== null) {
        await WatchPlanService.pref.put(KEY_ITEMS, JSON.stringify(payload))
        await WatchPlanService.pref.flush()
      }
    } catch {
    }
    const tick = AppStorage.get<number>('planTick') ?? 0
    AppStorage.setOrCreate('planTick', tick + 1)
  }

  private static parse(raw: string): WatchPlanItem[] {
    try {
      const parsed = JSON.parse(raw) as WatchPlanWire[]
      const out: WatchPlanItem[] = []
      for (const row of parsed) {
        const n = new WatchPlanItem()
        n.eventId = row.eventId
        n.title = row.title
        n.startAt = row.startAt
        n.venue = row.venue
        n.athleteName = row.athleteName
        n.watched = row.watched === true
        n.addedAt = row.addedAt
        out.push(n)
      }
      return out
    } catch {
      return []
    }
  }
}

class WatchPlanWire {
  eventId: string = ''
  title: string = ''
  startAt: string = ''
  venue: string = ''
  athleteName: string = ''
  watched: boolean = false
  addedAt: number = 0
}
