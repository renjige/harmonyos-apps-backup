import { ActivityEvent, CheckInRecord, GrowthPayload, RecentBrowseItem, TopicItem } from '../models/GrowthModels'
import { InspirationItem } from '../models/InspirationModels'
import { CaptureStreakService } from './CaptureStreakService'
import { GrowthStore } from './GrowthStore'
import { AchievementService } from './AchievementService'
import { InspirationBizService } from './InspirationBizService'

export class GrowthService {
  static todayIso(): string {
    return CaptureStreakService.isoOf(new Date())
  }

  static nowStamp(): string {
    return new Date().toISOString().slice(0, 16).replace('T', ' ')
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static hasCheckIn(payload: GrowthPayload, date: string): boolean {
    for (const row of payload.checkIns) {
      if (row.date === date) {
        return true
      }
    }
    return false
  }

  static weekCheckInCount(payload: GrowthPayload, weekStart: string): number {
    let n = 0
    for (const row of payload.checkIns) {
      if (row.date >= weekStart) {
        n += 1
      }
    }
    return n
  }

  static monthCheckInCount(payload: GrowthPayload, monthPrefix: string): number {
    let n = 0
    for (const row of payload.checkIns) {
      if (row.date.indexOf(monthPrefix) === 0) {
        n += 1
      }
    }
    return n
  }

  static addCheckIn(payload: GrowthPayload, date: string, note: string): GrowthPayload {
    if (GrowthService.hasCheckIn(payload, date)) {
      const next: CheckInRecord[] = []
      for (const row of payload.checkIns) {
        if (row.date === date) {
          next.push(CheckInRecord.of(date, note))
        } else {
          next.push(row)
        }
      }
      payload.checkIns = next
      return payload
    }
    const copy: CheckInRecord[] = []
    copy.push(CheckInRecord.of(date, note))
    for (const row of payload.checkIns) {
      copy.push(row)
    }
    payload.checkIns = copy
    return payload
  }

  static pushActivity(payload: GrowthPayload, type: string, title: string, refKind: string, refId: string): void {
    const ev = new ActivityEvent()
    ev.type = type
    ev.title = title
    ev.refKind = refKind
    ev.refId = refId
    ev.at = GrowthService.nowStamp()
    const next: ActivityEvent[] = []
    next.push(ev)
    let i = 0
    for (const row of payload.activity) {
      if (i >= 79) {
        break
      }
      next.push(row)
      i += 1
    }
    payload.activity = next
  }

  static pushRecent(payload: GrowthPayload, kind: string, id: string, title: string): void {
    const item = new RecentBrowseItem()
    item.kind = kind
    item.id = id
    item.title = title
    item.at = GrowthService.nowStamp()
    const next: RecentBrowseItem[] = []
    next.push(item)
    let i = 0
    for (const row of payload.recent) {
      if (row.kind === kind && row.id === id) {
        continue
      }
      if (i >= 19) {
        break
      }
      next.push(row)
      i += 1
    }
    payload.recent = next
  }

  static removeRecentRef(payload: GrowthPayload, kind: string, id: string): void {
    const next: RecentBrowseItem[] = []
    for (const row of payload.recent) {
      if (row.kind === kind && row.id === id) {
        continue
      }
      next.push(row)
    }
    payload.recent = next
  }

  static removeInspirationFromAllTopics(payload: GrowthPayload, inspirationId: string): void {
    const next: TopicItem[] = []
    for (const t of payload.topics) {
      const ids: string[] = []
      for (const old of t.inspirationIds) {
        if (old !== inspirationId) {
          ids.push(old)
        }
      }
      t.inspirationIds = ids
      next.push(t)
    }
    payload.topics = next
  }

  static async purgeInspirationRefs(username: string, inspirationId: string): Promise<void> {
    if (username.length === 0 || inspirationId.length === 0) {
      return
    }
    const data = await GrowthStore.load(username)
    GrowthService.removeRecentRef(data, 'inspiration', inspirationId)
    GrowthService.removeInspirationFromAllTopics(data, inspirationId)
    await GrowthStore.save(username, data)
  }

  static async removeRecentRefForUser(username: string, kind: string, id: string): Promise<void> {
    if (username.length === 0 || id.length === 0) {
      return
    }
    const data = await GrowthStore.load(username)
    GrowthService.removeRecentRef(data, kind, id)
    await GrowthStore.save(username, data)
  }

  private static idInList(list: InspirationItem[], id: string): boolean {
    for (const item of list) {
      if (item.id === id) {
        return true
      }
    }
    return false
  }

  private static recentStillValid(
    row: RecentBrowseItem,
    inspirations: InspirationItem[],
    boards: InspirationItem[],
    plans: InspirationItem[],
    featured: InspirationItem[]
  ): boolean {
    if (row.kind === 'inspiration') {
      return GrowthService.idInList(inspirations, row.id)
    }
    if (row.kind === 'board') {
      return GrowthService.idInList(boards, row.id)
    }
    if (row.kind === 'plan') {
      return GrowthService.idInList(plans, row.id)
    }
    if (row.kind === 'featured') {
      return GrowthService.idInList(featured, row.id)
    }
    return true
  }

  /** 剔除已删除/不存在的浏览记录，并落盘 */
  static async pruneRecent(username: string): Promise<RecentBrowseItem[]> {
    if (username.length === 0) {
      return []
    }
    const data = await GrowthStore.load(username)
    if (data.recent.length === 0) {
      return []
    }
    const inspirations = await InspirationBizService.loadInspirations(username)
    const boards = await InspirationBizService.loadMoodBoards(username)
    const plans = await InspirationBizService.loadCreativePlans(username)
    const featured = await InspirationBizService.loadFeatured()
    const kept: RecentBrowseItem[] = []
    for (const row of data.recent) {
      if (GrowthService.recentStillValid(row, inspirations, boards, plans, featured)) {
        kept.push(row)
      }
    }
    if (kept.length !== data.recent.length) {
      data.recent = kept
      await GrowthStore.save(username, data)
    }
    return kept
  }

  static async loadValidRecent(username: string, limit: number): Promise<RecentBrowseItem[]> {
    const pruned = await GrowthService.pruneRecent(username)
    const out: RecentBrowseItem[] = []
    let n = 0
    for (const row of pruned) {
      if (n >= limit) {
        break
      }
      out.push(row)
      n += 1
    }
    return out
  }

  static addTopic(payload: GrowthPayload, title: string, summary: string): TopicItem {
    const t = new TopicItem()
    t.id = GrowthService.newId('topic')
    t.title = title
    t.summary = summary
    t.createdAt = GrowthService.todayIso()
    const next: TopicItem[] = []
    next.push(t)
    for (const row of payload.topics) {
      next.push(row)
    }
    payload.topics = next
    return t
  }

  static findTopic(payload: GrowthPayload, id: string): TopicItem | undefined {
    for (const t of payload.topics) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static topicHas(topic: TopicItem, inspirationId: string): boolean {
    for (const id of topic.inspirationIds) {
      if (id === inspirationId) {
        return true
      }
    }
    return false
  }

  static addInspirationToTopic(payload: GrowthPayload, topicId: string, inspirationId: string): boolean {
    const next: TopicItem[] = []
    let ok = false
    for (const t of payload.topics) {
      if (t.id === topicId) {
        if (!GrowthService.topicHas(t, inspirationId)) {
          const ids: string[] = []
          ids.push(inspirationId)
          for (const old of t.inspirationIds) {
            ids.push(old)
          }
          t.inspirationIds = ids
          ok = true
        }
      }
      next.push(t)
    }
    payload.topics = next
    return ok
  }

  static removeInspirationFromTopic(payload: GrowthPayload, topicId: string, inspirationId: string): void {
    const next: TopicItem[] = []
    for (const t of payload.topics) {
      if (t.id === topicId) {
        const ids: string[] = []
        for (const old of t.inspirationIds) {
          if (old !== inspirationId) {
            ids.push(old)
          }
        }
        t.inspirationIds = ids
      }
      next.push(t)
    }
    payload.topics = next
  }

  static removeTopic(payload: GrowthPayload, topicId: string): void {
    const next: TopicItem[] = []
    for (const t of payload.topics) {
      if (t.id !== topicId) {
        next.push(t)
      }
    }
    payload.topics = next
  }

  static async afterEvent(
    username: string,
    type: string,
    title: string,
    refKind: string,
    refId: string,
    inspirations: InspirationItem[],
    plans: InspirationItem[],
    favorites: InspirationItem[]
  ): Promise<string[]> {
    if (username.length === 0) {
      return []
    }
    const data = await GrowthStore.load(username)
    if (type === 'capture') {
      const today = GrowthService.todayIso()
      if (!GrowthService.hasCheckIn(data, today)) {
        GrowthService.addCheckIn(data, today, '')
      }
    }
    GrowthService.pushActivity(data, type, title, refKind, refId)
    const newly = AchievementService.evaluate(data, inspirations, plans, favorites)
    await GrowthStore.save(username, data)
    return newly
  }

  static async persist(username: string, payload: GrowthPayload): Promise<void> {
    await GrowthStore.save(username, payload)
  }

  static async afterEventAuto(
    username: string,
    type: string,
    title: string,
    refKind: string,
    refId: string
  ): Promise<string[]> {
    if (username.length === 0) {
      return []
    }
    const ins = await InspirationBizService.loadInspirations(username)
    const plans = await InspirationBizService.loadCreativePlans(username)
    const fav = await InspirationBizService.loadFavorites(username)
    return GrowthService.afterEvent(username, type, title, refKind, refId, ins, plans, fav)
  }

  static async recordBrowse(username: string, kind: string, id: string, title: string): Promise<void> {
    if (username.length === 0 || id.length === 0) {
      return
    }
    const data = await GrowthStore.load(username)
    GrowthService.pushRecent(data, kind, id, title)
    await GrowthStore.save(username, data)
  }

  static recentKindLabel(kind: string): string {
    if (kind === 'inspiration') {
      return '灵感'
    }
    if (kind === 'plan') {
      return '计划'
    }
    if (kind === 'board') {
      return '画板'
    }
    if (kind === 'featured') {
      return '精选'
    }
    return kind
  }

  static typeLabel(type: string): string {
    if (type === 'capture') {
      return '捕捉'
    }
    if (type === 'pin') {
      return '钉板'
    }
    if (type === 'plan') {
      return '计划'
    }
    if (type === 'checkin') {
      return '打卡'
    }
    if (type === 'topic') {
      return '专题'
    }
    if (type === 'favorite') {
      return '收藏'
    }
    return type
  }
}
