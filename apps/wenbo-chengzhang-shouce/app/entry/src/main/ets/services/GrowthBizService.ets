import { HttpClient } from './HttpClient'
import {
  CreateBoardRequest,
  CreateFavoriteRequest,
  CreateRecordRequest,
  CreatePlanRequest,
  CreateHabitRequest,
  CheckinHabitRequest,
  CreateReviewRequest,
  GoalStepItem,
  GrowthRecordItem,
  GrowthRecordItemWire,
  GrowthListPayload,
  AnnualReportData,
  SearchResultData,
  StatsData,
  TagPresetItem,
  TagPresetListPayload,
  TagPresetWire,
  UpdatePlanRequest,
  UpdateRecordRequest,
  UnlockAchievementRequest,
  MessageItem,
  MessageListPayload
} from '../models/GrowthModels'

export class GrowthBizService {
  static lastError: string = ''

  private static userId(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  private static mapItems(wires: GrowthRecordItemWire[]): GrowthRecordItem[] {
    const out: GrowthRecordItem[] = []
    for (const w of wires) {
      out.push(GrowthRecordItem.fromWire(w))
    }
    return out
  }

  static async loadFeatured(): Promise<GrowthRecordItem[]> {
    const res = await HttpClient.get<GrowthListPayload>('/biz/growth-handbook/featured')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return GrowthBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findFeatured(id: string): Promise<GrowthRecordItem | undefined> {
    const res = await HttpClient.get<GrowthRecordItemWire>(`/biz/growth-handbook/featured/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return GrowthRecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadRecords(userId: string): Promise<GrowthRecordItem[]> {
    const uid = userId.length > 0 ? userId : GrowthBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<GrowthListPayload>(
      `/biz/growth-handbook/records?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return GrowthBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findRecord(id: string): Promise<GrowthRecordItem | undefined> {
    const res = await HttpClient.get<GrowthRecordItemWire>(`/biz/growth-handbook/records/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return GrowthRecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async createRecord(req: CreateRecordRequest): Promise<GrowthRecordItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = GrowthBizService.userId()
    }
    const res = await HttpClient.post<GrowthRecordItemWire>('/biz/growth-handbook/records', req)
    if (res.code === 0 && res.data !== undefined) {
      return GrowthRecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async updateRecord(id: string, req: UpdateRecordRequest): Promise<GrowthRecordItem | undefined> {
    GrowthBizService.lastError = ''
    if (req.userId.length === 0) {
      req.userId = GrowthBizService.userId()
    }
    const res = await HttpClient.put<GrowthRecordItemWire>(
      `/biz/growth-handbook/records/${id}`,
      req
    )
    if (res.code === 0 && res.data !== undefined) {
      return GrowthRecordItem.fromWire(res.data)
    }
    if (res.message !== undefined && res.message.length > 0) {
      GrowthBizService.lastError = res.message
    } else {
      GrowthBizService.lastError = '更新失败，请稍后重试'
    }
    return undefined
  }

  static async deleteRecord(id: string, userId: string): Promise<boolean> {
    GrowthBizService.lastError = ''
    const uid = userId.length > 0 ? userId : GrowthBizService.userId()
    const path = `/biz/growth-handbook/records/${id}?userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.delete<object>(path)
    if (res.code === 0) {
      return true
    }
    if (res.message !== undefined && res.message.length > 0) {
      GrowthBizService.lastError = res.message
    } else {
      GrowthBizService.lastError = '删除失败，请稍后重试'
    }
    return false
  }

  static async unlockAchievement(
    badgeId: string,
    title: string,
    userId: string
  ): Promise<GrowthRecordItem | undefined> {
    const req = new UnlockAchievementRequest()
    req.badgeId = badgeId
    req.title = title
    req.userId = userId.length > 0 ? userId : GrowthBizService.userId()
    const res = await HttpClient.post<GrowthRecordItemWire>(
      '/biz/growth-handbook/achievements/unlock',
      req
    )
    if (res.code === 0 && res.data !== undefined) {
      return GrowthRecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadMoodBoards(userId: string): Promise<GrowthRecordItem[]> {
    const uid = userId.length > 0 ? userId : GrowthBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const path = `/biz/growth-handbook/milestones?userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<GrowthListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return GrowthBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findMoodBoard(id: string): Promise<GrowthRecordItem | undefined> {
    const res = await HttpClient.get<GrowthRecordItemWire>(`/biz/growth-handbook/milestones/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return GrowthRecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async createMoodBoard(req: CreateBoardRequest): Promise<GrowthRecordItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = GrowthBizService.userId()
    }
    const res = await HttpClient.post<GrowthRecordItemWire>('/biz/growth-handbook/milestones', req)
    if (res.code === 0 && res.data !== undefined) {
      return GrowthRecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadCreativePlans(userId: string): Promise<GrowthRecordItem[]> {
    const uid = userId.length > 0 ? userId : GrowthBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<GrowthListPayload>(
      `/biz/growth-handbook/goals?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      try {
        return GrowthBizService.mapItems(res.data.list)
      } catch {
        return []
      }
    }
    return []
  }

  static async findCreativePlan(id: string): Promise<GrowthRecordItem | undefined> {
    const res = await HttpClient.get<GrowthRecordItemWire>(`/biz/growth-handbook/goals/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return GrowthRecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async createCreativePlan(req: CreatePlanRequest): Promise<GrowthRecordItem | undefined> {
    GrowthBizService.lastError = ''
    if (req.userId.length === 0) {
      req.userId = GrowthBizService.userId()
    }
    if (req.userId.length === 0) {
      GrowthBizService.lastError = '请先登录后再创建目标'
      return undefined
    }
    const res = await HttpClient.postJson<GrowthRecordItemWire>(
      '/biz/growth-handbook/goals',
      req.toJsonString()
    )
    if (res.code === 0) {
      try {
        if (res.data !== undefined && res.data !== null) {
          return GrowthRecordItem.fromWire(res.data)
        }
      } catch {
        // 平台已写入，字段缺省时仍视为创建成功
      }
      const fallback = new GrowthRecordItem()
      fallback.title = req.title
      fallback.goal = req.goal
      fallback.summary = req.summary
      fallback.progress = req.progress
      fallback.userId = req.userId
      return fallback
    }
    if (res.message !== undefined && res.message.length > 0) {
      GrowthBizService.lastError = res.message
    } else {
      GrowthBizService.lastError = '创建失败，请检查网络后重试'
    }
    return undefined
  }

  static async updateCreativePlan(id: string, req: UpdatePlanRequest): Promise<GrowthRecordItem | undefined> {
    GrowthBizService.lastError = ''
    if (id.length === 0) {
      GrowthBizService.lastError = '目标编号缺失，请返回列表后重试'
      return undefined
    }
    const res = await HttpClient.postJson<GrowthRecordItemWire>(
      `/biz/growth-handbook/goals/${id}/progress`,
      req.toJsonString()
    )
    if (res.code === 0) {
      try {
        if (res.data !== undefined && res.data !== null) {
          return GrowthRecordItem.fromWire(res.data)
        }
      } catch {
        // 平台已更新，字段缺省时仍视为成功
      }
      const fallback = new GrowthRecordItem()
      fallback.id = id
      fallback.title = req.title
      fallback.goal = req.goal
      fallback.summary = req.summary
      fallback.progress = req.progress
      return fallback
    }
    if (res.message !== undefined && res.message.length > 0) {
      GrowthBizService.lastError = res.message
    } else {
      GrowthBizService.lastError = '更新失败，请检查网络后重试'
    }
    return undefined
  }

  static async appendGoalStep(goal: GrowthRecordItem, stepTitle: string): Promise<GrowthRecordItem | undefined> {
    const steps = GoalStepItem.parse(goal.cardsJson)
    const extra = new GoalStepItem()
    extra.title = stepTitle
    steps.push(extra)
    const req = new UpdatePlanRequest()
    req.title = goal.title
    req.goal = goal.goal
    req.summary = goal.summary.length > 0 ? goal.summary : goal.goal
    req.cardsJson = GoalStepItem.encode(steps)
    req.progress = GoalStepItem.progressOf(steps)
    return GrowthBizService.updateCreativePlan(goal.id, req)
  }

  static async loadAchievements(userId: string): Promise<GrowthRecordItem[]> {
    const uid = userId.length > 0 ? userId : GrowthBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<GrowthListPayload>(
      `/biz/growth-handbook/achievements?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return GrowthBizService.mapItems(res.data.list)
    }
    return []
  }

  static async loadAnnualReport(userId: string): Promise<AnnualReportData> {
    const uid = userId.length > 0 ? userId : GrowthBizService.userId()
    if (uid.length === 0) {
      return new AnnualReportData()
    }
    const path = `/biz/growth-handbook/annual-report?userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<AnnualReportData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    return new AnnualReportData()
  }

  static async loadFavorites(userId: string): Promise<GrowthRecordItem[]> {
    const uid = userId.length > 0 ? userId : GrowthBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<GrowthListPayload>(
      `/biz/growth-handbook/favorites?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return GrowthBizService.mapItems(res.data.list)
    }
    return []
  }

  static async createFavorite(req: CreateFavoriteRequest): Promise<GrowthRecordItem | undefined> {
    GrowthBizService.lastError = ''
    if (req.userId.length === 0) {
      req.userId = GrowthBizService.userId()
    }
    if (req.userId.length === 0) {
      GrowthBizService.lastError = '请先登录后再收藏'
      return undefined
    }
    const res = await HttpClient.postJson<GrowthRecordItemWire>(
      '/biz/growth-handbook/favorites',
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined && res.data !== null) {
      return GrowthRecordItem.fromWire(res.data)
    }
    if (res.message !== undefined && res.message.length > 0) {
      GrowthBizService.lastError = res.message
    }
    return undefined
  }

  static async deleteFavorite(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/growth-handbook/favorites/${id}`)
    return res.code === 0
  }

  static async loadTagPresets(): Promise<TagPresetItem[]> {
    const res = await HttpClient.get<TagPresetListPayload>('/biz/growth-handbook/tag-presets')
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
    const uid = userId.length > 0 ? userId : GrowthBizService.userId()
    let path = `/biz/growth-handbook/search?q=${encodeURIComponent(q)}`
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
    const uid = userId.length > 0 ? userId : GrowthBizService.userId()
    if (uid.length === 0) {
      return new StatsData()
    }
    let path = '/biz/growth-handbook/stats'
    path += `?userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<StatsData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    return new StatsData()
  }

  static async loadMessages(): Promise<MessageItem[]> {
    const res = await HttpClient.get<MessageListPayload>('/messages')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: MessageItem[] = []
      for (const w of res.data.list) {
        out.push(MessageItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async loadHabits(userId: string): Promise<GrowthRecordItem[]> {
    const uid = userId.length > 0 ? userId : GrowthBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<GrowthListPayload>(
      `/biz/growth-handbook/habits?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return GrowthBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findHabit(id: string): Promise<GrowthRecordItem | undefined> {
    const res = await HttpClient.get<GrowthRecordItemWire>(`/biz/growth-handbook/habits/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return GrowthRecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async createHabit(req: CreateHabitRequest): Promise<GrowthRecordItem | undefined> {
    GrowthBizService.lastError = ''
    if (req.userId.length === 0) {
      req.userId = GrowthBizService.userId()
    }
    if (req.userId.length === 0) {
      GrowthBizService.lastError = '请先登录后再创建习惯'
      return undefined
    }
    const res = await HttpClient.postJson<GrowthRecordItemWire>(
      '/biz/growth-handbook/habits',
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined) {
      return GrowthRecordItem.fromWire(res.data)
    }
    GrowthBizService.lastError = res.message.length > 0 ? res.message : '创建习惯失败'
    return undefined
  }

  static async checkinHabit(id: string, req: CheckinHabitRequest): Promise<GrowthRecordItem | undefined> {
    GrowthBizService.lastError = ''
    if (req.userId.length === 0) {
      req.userId = GrowthBizService.userId()
    }
    const res = await HttpClient.postJson<GrowthRecordItemWire>(
      `/biz/growth-handbook/habits/${id}/checkin`,
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined) {
      return GrowthRecordItem.fromWire(res.data)
    }
    GrowthBizService.lastError = res.message.length > 0 ? res.message : '打卡失败'
    return undefined
  }

  static async deleteHabit(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/growth-handbook/habits/${id}`)
    return res.code === 0
  }

  static async loadReviews(userId: string): Promise<GrowthRecordItem[]> {
    const uid = userId.length > 0 ? userId : GrowthBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<GrowthListPayload>(
      `/biz/growth-handbook/reviews?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return GrowthBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findReview(id: string): Promise<GrowthRecordItem | undefined> {
    const res = await HttpClient.get<GrowthRecordItemWire>(`/biz/growth-handbook/reviews/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return GrowthRecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async createReview(req: CreateReviewRequest): Promise<GrowthRecordItem | undefined> {
    GrowthBizService.lastError = ''
    if (req.userId.length === 0) {
      req.userId = GrowthBizService.userId()
    }
    if (req.userId.length === 0) {
      GrowthBizService.lastError = '请先登录后再写复盘'
      return undefined
    }
    const res = await HttpClient.postJson<GrowthRecordItemWire>(
      '/biz/growth-handbook/reviews',
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined) {
      return GrowthRecordItem.fromWire(res.data)
    }
    GrowthBizService.lastError = res.message.length > 0 ? res.message : '保存复盘失败'
    return undefined
  }

  static async deleteReview(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/growth-handbook/reviews/${id}`)
    return res.code === 0
  }

  static habitCheckedToday(item: GrowthRecordItem): boolean {
    const d = new Date()
    const mo = d.getMonth() + 1
    const day = d.getDate()
    const moStr = mo < 10 ? `0${mo}` : `${mo}`
    const dayStr = day < 10 ? `0${day}` : `${day}`
    const today = `${d.getFullYear()}-${moStr}-${dayStr}`
    const raw = item.cardsJson
    if (raw.length === 0) {
      return false
    }
    const parts = raw.split(',')
    for (const p of parts) {
      if (p.trim() === today) {
        return true
      }
    }
    return false
  }
}

class DeleteOkPayload {
  id: string = ''
}
