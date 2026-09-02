import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { WatchReview } from '../models/FanGrowthModels'

const STORE = 'star_watch_reviews'
const MAX = 30

export class WatchReviewService {
  private static pref: preferences.Preferences | null = null
  private static items: WatchReview[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      WatchReviewService.pref = await preferences.getPreferences(context, STORE)
      const raw = await WatchReviewService.pref.get('reviews', '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      WatchReviewService.items = WatchReviewService.parse(text)
    } catch {
      WatchReviewService.items = []
    }
  }

  static list(): WatchReview[] {
    const out: WatchReview[] = []
    for (const item of WatchReviewService.items) {
      out.push(item)
    }
    return out
  }

  static count(): number {
    return WatchReviewService.items.length
  }

  static findByEvent(eventId: string): WatchReview | undefined {
    for (const item of WatchReviewService.items) {
      if (item.eventId === eventId) {
        return item
      }
    }
    return undefined
  }

  static async save(review: WatchReview): Promise<void> {
    const next: WatchReview[] = []
    review.watchedAt = Date.now()
    if (review.id.length === 0) {
      review.id = `wr_${Date.now()}`
    }
    next.push(review)
    for (const item of WatchReviewService.items) {
      if (item.eventId !== review.eventId) {
        next.push(item)
      }
      if (next.length >= MAX) {
        break
      }
    }
    WatchReviewService.items = next
    await WatchReviewService.persist()
  }

  private static async persist(): Promise<void> {
    const payload: WatchReviewWire[] = []
    for (const item of WatchReviewService.items) {
      const w = new WatchReviewWire()
      w.id = item.id
      w.eventId = item.eventId
      w.eventTitle = item.eventTitle
      w.athleteName = item.athleteName
      w.rating = item.rating
      w.note = item.note
      w.watchedAt = item.watchedAt
      payload.push(w)
    }
    try {
      if (WatchReviewService.pref !== null) {
        await WatchReviewService.pref.put('reviews', JSON.stringify(payload))
        await WatchReviewService.pref.flush()
      }
    } catch {
    }
    const tick = AppStorage.get<number>('growthTick') ?? 0
    AppStorage.setOrCreate('growthTick', tick + 1)
  }

  private static parse(raw: string): WatchReview[] {
    try {
      const parsed = JSON.parse(raw) as WatchReviewWire[]
      const out: WatchReview[] = []
      for (const w of parsed) {
        const r = new WatchReview()
        r.id = w.id
        r.eventId = w.eventId
        r.eventTitle = w.eventTitle
        r.athleteName = w.athleteName
        r.rating = w.rating
        r.note = w.note
        r.watchedAt = w.watchedAt
        out.push(r)
      }
      return out
    } catch {
      return []
    }
  }
}

class WatchReviewWire {
  id: string = ''
  eventId: string = ''
  eventTitle: string = ''
  athleteName: string = ''
  rating: number = 4
  note: string = ''
  watchedAt: number = 0
}
