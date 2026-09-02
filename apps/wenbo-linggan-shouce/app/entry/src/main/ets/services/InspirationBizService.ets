import { HttpClient } from './HttpClient'
import {
  CreateBoardRequest,
  CreateFavoriteRequest,
  CreateInspirationRequest,
  CreatePlanRequest,
  CreateTopicRequest,
  CreateCheckInRequest,
  InspirationItem,
  InspirationItemWire,
  InspirationListPayload,
  MilestoneList,
  SearchResultData,
  StatsData,
  TagPresetItem,
  TagPresetListPayload,
  TagPresetWire,
  TimelineEvent,
  TimelineEventWire,
  TimelineListPayload,
  UpdateBoardRequest,
  UpdateInspirationRequest,
  UpdatePlanProgressRequest,
  UpdatePlanRequest,
  UpdateTopicRequest,
  WeekReviewData,
  LinkedRef,
  LinkedRefList,
  MsgWire,
  MsgListPayload
} from '../models/InspirationModels'

export class InspirationBizService {
  static lastError: string = ''

  private static userId(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  private static mapItems(wires: InspirationItemWire[]): InspirationItem[] {
    const out: InspirationItem[] = []
    for (const w of wires) {
      out.push(InspirationItem.fromWire(w))
    }
    return out
  }

  static async loadFeatured(): Promise<InspirationItem[]> {
    const res = await HttpClient.get<InspirationListPayload>('/biz/inspiration-handbook/featured')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return InspirationBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findFeatured(id: string): Promise<InspirationItem | undefined> {
    const res = await HttpClient.get<InspirationItemWire>(`/biz/inspiration-handbook/featured/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadInspirations(userId: string): Promise<InspirationItem[]> {
    const uid = userId.length > 0 ? userId : InspirationBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<InspirationListPayload>(
      `/biz/inspiration-handbook/inspirations?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return InspirationBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findInspiration(id: string): Promise<InspirationItem | undefined> {
    if (id.length === 0) {
      return undefined
    }
    const res = await HttpClient.get<InspirationItemWire>(`/biz/inspiration-handbook/inspirations/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    const uid = InspirationBizService.userId()
    if (uid.length > 0) {
      const list = await InspirationBizService.loadInspirations(uid)
      for (const item of list) {
        if (item.id === id) {
          return item
        }
      }
    }
    return undefined
  }

  static async createInspiration(req: CreateInspirationRequest): Promise<InspirationItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = InspirationBizService.userId()
    }
    const res = await HttpClient.post<InspirationItemWire>('/biz/inspiration-handbook/inspirations', req)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    return undefined
  }

  static async updateInspiration(id: string, req: UpdateInspirationRequest): Promise<InspirationItem | undefined> {
    InspirationBizService.lastError = ''
    let res = await HttpClient.post<InspirationItemWire>(`/biz/inspiration-handbook/inspirations/${id}/update`, req)
    if (res.code !== 0 || res.data === undefined) {
      res = await HttpClient.patch<InspirationItemWire>(`/biz/inspiration-handbook/inspirations/${id}`, req)
    }
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    InspirationBizService.lastError = res.message.length > 0 ? res.message : '更新失败'
    return undefined
  }

  static async deleteInspiration(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/inspiration-handbook/inspirations/${id}`)
    return res.code === 0
  }

  static async loadMoodBoards(userId: string): Promise<InspirationItem[]> {
    let path = '/biz/inspiration-handbook/mood-boards'
    const uid = userId.length > 0 ? userId : InspirationBizService.userId()
    if (uid.length > 0) {
      path += `?userId=${encodeURIComponent(uid)}`
    }
    const res = await HttpClient.get<InspirationListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return InspirationBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findMoodBoard(id: string): Promise<InspirationItem | undefined> {
    if (id.length === 0) {
      return undefined
    }
    const res = await HttpClient.get<InspirationItemWire>(`/biz/inspiration-handbook/mood-boards/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    const uid = InspirationBizService.userId()
    if (uid.length > 0) {
      const list = await InspirationBizService.loadMoodBoards(uid)
      for (const item of list) {
        if (item.id === id) {
          return item
        }
      }
    }
    return undefined
  }

  static async createMoodBoard(req: CreateBoardRequest): Promise<InspirationItem | undefined> {
    InspirationBizService.lastError = ''
    if (req.userId.length === 0) {
      req.userId = InspirationBizService.userId()
    }
    const res = await HttpClient.post<InspirationItemWire>('/biz/inspiration-handbook/mood-boards', req)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    InspirationBizService.lastError = res.message.length > 0 ? res.message : '创建失败'
    return undefined
  }

  static async updateMoodBoard(id: string, req: UpdateBoardRequest): Promise<InspirationItem | undefined> {
    InspirationBizService.lastError = ''
    let res = await HttpClient.post<InspirationItemWire>(`/biz/inspiration-handbook/mood-boards/${id}/update`, req)
    if (res.code !== 0 || res.data === undefined) {
      res = await HttpClient.patch<InspirationItemWire>(`/biz/inspiration-handbook/mood-boards/${id}`, req)
    }
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    InspirationBizService.lastError = res.message.length > 0 ? res.message : '更新失败'
    return undefined
  }

  static async deleteMoodBoard(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/inspiration-handbook/mood-boards/${id}`)
    return res.code === 0
  }

  static async loadCreativePlans(userId: string): Promise<InspirationItem[]> {
    const uid = userId.length > 0 ? userId : InspirationBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<InspirationListPayload>(
      `/biz/inspiration-handbook/creative-plans?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return InspirationBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findCreativePlan(id: string): Promise<InspirationItem | undefined> {
    if (id.length === 0) {
      return undefined
    }
    const res = await HttpClient.get<InspirationItemWire>(`/biz/inspiration-handbook/creative-plans/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    const uid = InspirationBizService.userId()
    if (uid.length > 0) {
      const list = await InspirationBizService.loadCreativePlans(uid)
      for (const item of list) {
        if (item.id === id) {
          return item
        }
      }
    }
    return undefined
  }

  static async createCreativePlan(req: CreatePlanRequest): Promise<InspirationItem | undefined> {
    InspirationBizService.lastError = ''
    if (req.userId.length === 0) {
      req.userId = InspirationBizService.userId()
    }
    const res = await HttpClient.post<InspirationItemWire>('/biz/inspiration-handbook/creative-plans', req)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    InspirationBizService.lastError = res.message.length > 0 ? res.message : '创建失败'
    return undefined
  }

  static async updateCreativePlan(id: string, req: UpdatePlanRequest): Promise<InspirationItem | undefined> {
    InspirationBizService.lastError = ''
    let res = await HttpClient.post<InspirationItemWire>(
      `/biz/inspiration-handbook/creative-plans/${id}/update`,
      req
    )
    if (res.code !== 0 || res.data === undefined) {
      res = await HttpClient.patch<InspirationItemWire>(
        `/biz/inspiration-handbook/creative-plans/${id}`,
        req
      )
    }
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    InspirationBizService.lastError = res.message.length > 0 ? res.message : '更新失败'
    return undefined
  }

  static async updatePlanProgress(id: string, progress: number): Promise<InspirationItem | undefined> {
    InspirationBizService.lastError = ''
    const req = new UpdatePlanProgressRequest()
    req.progress = progress
    const res = await HttpClient.post<InspirationItemWire>(
      `/biz/inspiration-handbook/creative-plans/${id}/progress`,
      req
    )
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    InspirationBizService.lastError = res.message.length > 0 ? res.message : '更新失败'
    return undefined
  }

  static async deleteCreativePlan(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/inspiration-handbook/creative-plans/${id}`)
    return res.code === 0
  }

  static async loadFavorites(userId: string): Promise<InspirationItem[]> {
    const uid = userId.length > 0 ? userId : InspirationBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<InspirationListPayload>(
      `/biz/inspiration-handbook/favorites?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return InspirationBizService.mapItems(res.data.list)
    }
    return []
  }

  static async createFavorite(req: CreateFavoriteRequest): Promise<InspirationItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = InspirationBizService.userId()
    }
    const res = await HttpClient.post<InspirationItemWire>('/biz/inspiration-handbook/favorites', req)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    return undefined
  }

  static async deleteFavorite(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/inspiration-handbook/favorites/${id}`)
    return res.code === 0
  }

  static async loadTagPresets(): Promise<TagPresetItem[]> {
    const res = await HttpClient.get<TagPresetListPayload>('/biz/inspiration-handbook/tag-presets')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: TagPresetItem[] = []
      for (const w of res.data.list) {
        out.push(TagPresetItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async search(q: string, userId: string): Promise<SearchResultData> {
    const uid = userId.length > 0 ? userId : InspirationBizService.userId()
    let path = `/biz/inspiration-handbook/search?q=${encodeURIComponent(q)}`
    if (uid.length > 0) {
      path += `&userId=${encodeURIComponent(uid)}`
    }
    const res = await HttpClient.get<SearchResultData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    const empty = new SearchResultData()
    empty.query = q
    return empty
  }

  static async loadStats(userId: string): Promise<StatsData> {
    const uid = userId.length > 0 ? userId : InspirationBizService.userId()
    let path = '/biz/inspiration-handbook/stats'
    if (uid.length > 0) {
      path += `?userId=${encodeURIComponent(uid)}`
    }
    const res = await HttpClient.get<StatsData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    return new StatsData()
  }

  static async loadMessages(): Promise<MsgWire[]> {
    const res = await HttpClient.get<MsgListPayload>('/messages')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadTimeline(userId: string, limit: number = 20): Promise<TimelineEvent[]> {
    const uid = userId.length > 0 ? userId : InspirationBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<TimelineListPayload>(
      `/biz/inspiration-handbook/timeline?userId=${encodeURIComponent(uid)}&limit=${limit}`
    )
    const out: TimelineEvent[] = []
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      for (const w of res.data.list) {
        out.push(TimelineEvent.fromWire(w))
      }
    }
    return out
  }

  static async loadCheckIns(userId: string): Promise<InspirationItem[]> {
    const uid = userId.length > 0 ? userId : InspirationBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<InspirationListPayload>(
      `/biz/inspiration-handbook/check-ins?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return InspirationBizService.mapItems(res.data.list)
    }
    return []
  }

  static async checkInToday(note: string = ''): Promise<boolean> {
    InspirationBizService.lastError = ''
    const req = new CreateCheckInRequest()
    req.note = note.length > 0 ? note : '今日已创作'
    req.kind = 'manual'
    req.userId = InspirationBizService.userId()
    req.recordDate = new Date().toISOString().slice(0, 10)
    const res = await HttpClient.post<InspirationItemWire>('/biz/inspiration-handbook/check-ins', req)
    if (res.code === 0 && res.data !== undefined) {
      AppStorage.setOrCreate('checkInEpoch', (AppStorage.get<number>('checkInEpoch') ?? 0) + 1)
      return true
    }
    InspirationBizService.lastError = res.message.length > 0 ? res.message : '打卡失败'
    return false
  }

  static async loadTopics(userId: string): Promise<InspirationItem[]> {
    const uid = userId.length > 0 ? userId : InspirationBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<InspirationListPayload>(
      `/biz/inspiration-handbook/topics?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return InspirationBizService.mapItems(res.data.list)
    }
    return []
  }

  static async createTopic(req: CreateTopicRequest): Promise<InspirationItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = InspirationBizService.userId()
    }
    const res = await HttpClient.post<InspirationItemWire>('/biz/inspiration-handbook/topics', req)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    return undefined
  }

  static async findTopic(id: string): Promise<InspirationItem | undefined> {
    const res = await HttpClient.get<InspirationItemWire>(`/biz/inspiration-handbook/topics/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    return undefined
  }

  static async updateTopic(id: string, req: UpdateTopicRequest): Promise<InspirationItem | undefined> {
    InspirationBizService.lastError = ''
    let res = await HttpClient.post<InspirationItemWire>(`/biz/inspiration-handbook/topics/${id}/update`, req)
    if (res.code !== 0 || res.data === undefined) {
      res = await HttpClient.patch<InspirationItemWire>(`/biz/inspiration-handbook/topics/${id}`, req)
    }
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    InspirationBizService.lastError = res.message.length > 0 ? res.message : '更新失败'
    return undefined
  }

  static async linkInspiration(inspirationId: string, kind: string, targetId: string): Promise<boolean> {
    const item = await InspirationBizService.findInspiration(inspirationId)
    if (item === undefined) {
      return false
    }
    const req = new UpdateInspirationRequest()
    req.title = item.title
    req.body = item.body
    req.summary = item.summary
    req.tags = item.tags
    req.recordDate = item.recordDate
    req.coverKey = item.coverKey
    req.linkedIdsJson = LinkedRefList.add(item.linkedIdsJson, kind, targetId)
    const updated = await InspirationBizService.updateInspiration(inspirationId, req)
    return updated !== undefined
  }

  static async inspirationsLinkedToPlan(userId: string, planId: string): Promise<InspirationItem[]> {
    const all = await InspirationBizService.loadInspirations(userId)
    const out: InspirationItem[] = []
    for (const item of all) {
      const refs = LinkedRefList.parse(item.linkedIdsJson)
      if (LinkedRefList.has(refs, 'plan', planId)) {
        out.push(item)
      }
    }
    return out
  }

  static async resolveLinkedItems(
    userId: string,
    raw: string
  ): Promise<InspirationItem[]> {
    const refs = LinkedRefList.parse(raw)
    const out: InspirationItem[] = []
    for (const ref of refs) {
      let row: InspirationItem | undefined = undefined
      if (ref.kind === 'inspiration') {
        row = await InspirationBizService.findInspiration(ref.id)
      } else if (ref.kind === 'board') {
        row = await InspirationBizService.findMoodBoard(ref.id)
      } else if (ref.kind === 'plan') {
        row = await InspirationBizService.findCreativePlan(ref.id)
      } else if (ref.kind === 'topic') {
        row = await InspirationBizService.findTopic(ref.id)
      }
      if (row !== undefined) {
        out.push(row)
      }
    }
    return out
  }

  static weekRange(): string[] {
    const now = new Date()
    const day = now.getDay()
    const diff = day === 0 ? 6 : day - 1
    const monday = new Date(now.getFullYear(), now.getMonth(), now.getDate() - diff)
    const labels: string[] = []
    for (let i = 0; i < 7; i++) {
      const d = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + i)
      const m = d.getMonth() + 1
      const dd = d.getDate()
      labels.push(`${d.getFullYear()}-${m < 10 ? '0' : ''}${m}-${dd < 10 ? '0' : ''}${dd}`)
    }
    return labels
  }

  static async loadWeekReview(userId: string): Promise<WeekReviewData> {
    const data = new WeekReviewData()
    const range = InspirationBizService.weekRange()
    data.weekLabel = `${range[0].slice(5)} ~ ${range[6].slice(5)}`
    const uid = userId.length > 0 ? userId : InspirationBizService.userId()
    if (uid.length === 0) {
      return data
    }
    const inspirations = await InspirationBizService.loadInspirations(uid)
    const boards = await InspirationBizService.loadMoodBoards(uid)
    const checkIns = await InspirationBizService.loadCheckIns(uid)
    const plans = await InspirationBizService.loadCreativePlans(uid)
    const weekSet: string[] = []
    for (const d of range) {
      weekSet.push(d)
    }
    const inWeek = (iso: string): boolean => {
      if (iso.length < 10) {
        return false
      }
      const key = iso.slice(0, 10)
      for (const d of weekSet) {
        if (d === key) {
          return true
        }
      }
      return false
    }
    for (const item of inspirations) {
      if (inWeek(item.recordDate) || inWeek(item.createdAt)) {
        data.inspirations.push(item)
        data.inspirationCount += 1
        if (item.title.length > 0) {
          data.highlights.push(item.title)
        }
      }
    }
    for (const item of boards) {
      if (inWeek(item.createdAt)) {
        data.boardCount += 1
      }
    }
    for (const item of checkIns) {
      if (item.kind === 'weekly_review') {
        if (inWeek(item.recordDate) || inWeek(item.createdAt)) {
          const note = item.body.length > 0 ? item.body : item.summary
          if (note.length > 0) {
            data.reflection = note
          }
        }
      } else if (inWeek(item.recordDate) || inWeek(item.createdAt)) {
        data.checkInCount += 1
      }
    }
    for (const plan of plans) {
      const milestones = MilestoneList.parse(plan.milestonesJson)
      for (const m of milestones) {
        if (m.done) {
          data.completedMilestones += 1
        }
      }
    }
    return data
  }

  static async saveWeeklyReflection(note: string): Promise<boolean> {
    const req = new CreateCheckInRequest()
    req.note = note
    req.kind = 'weekly_review'
    req.userId = InspirationBizService.userId()
    req.recordDate = new Date().toISOString().slice(0, 10)
    const res = await HttpClient.post<InspirationItemWire>('/biz/inspiration-handbook/check-ins', req)
    return res.code === 0
  }

  static async createInspirationFromFeatured(item: InspirationItem): Promise<InspirationItem | undefined> {
    const req = new CreateInspirationRequest()
    req.title = item.title
    req.body = item.body.length > 0 ? item.body : item.summary
    req.summary = item.summary
    req.tags = item.tags
    req.recordDate = new Date().toISOString().slice(0, 10)
    req.coverKey = item.coverKey.length > 0 ? item.coverKey : 'hero_latest_inspiration'
    req.userId = InspirationBizService.userId()
    return InspirationBizService.createInspiration(req)
  }

  static async deleteTopic(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/inspiration-handbook/topics/${id}`)
    return res.code === 0
  }

  static checkInDates(items: InspirationItem[]): string[] {
    const out: string[] = []
    for (const item of items) {
      if (item.recordDate.length >= 10) {
        out.push(item.recordDate.slice(0, 10))
      } else if (item.createdAt.length >= 10) {
        out.push(item.createdAt.slice(0, 10))
      }
    }
    return out
  }

  static todayCheckedIn(items: InspirationItem[]): boolean {
    const today = new Date().toISOString().slice(0, 10)
    for (const item of items) {
      const d = item.recordDate.length >= 10 ? item.recordDate.slice(0, 10) : item.createdAt.slice(0, 10)
      if (d === today) {
        return true
      }
    }
    return false
  }
}

class DeleteOkPayload {
  id: string = ''
}
