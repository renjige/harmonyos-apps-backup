import { HttpClient } from './HttpClient'
import {
  CreateBoardRequest,
  CreateFavoriteRequest,
  CreateInspirationRequest,
  CreatePlanRequest,
  InspirationItem,
  InspirationItemWire,
  InspirationListPayload,
  SearchResultData,
  StatsData,
  TagPresetItem,
  TagPresetListPayload,
  TagPresetWire,
  UpdateBoardRequest,
  UpdateInspirationRequest,
  UpdatePlanRequest,
  UpdatePlanProgressRequest
} from '../models/InspirationModels'

export class InspirationBizService {
  static lastError: string = ''

  private static userId(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  private static markFail(message: string): void {
    InspirationBizService.lastError = message.length > 0 ? message : '操作失败，请稍后重试'
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
    const res = await HttpClient.get<InspirationItemWire>(`/biz/inspiration-handbook/inspirations/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    return undefined
  }

  static async createInspiration(req: CreateInspirationRequest): Promise<InspirationItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = InspirationBizService.userId()
    }
    const res = await HttpClient.post<InspirationItemWire>('/biz/inspiration-handbook/inspirations', req)
    if (res.code === 0 && res.data !== undefined) {
      InspirationBizService.lastError = ''
      return InspirationItem.fromWire(res.data)
    }
    InspirationBizService.markFail(res.message)
    return undefined
  }

  static async updateInspiration(id: string, req: UpdateInspirationRequest): Promise<InspirationItem | undefined> {
    const res = await HttpClient.post<InspirationItemWire>(
      `/biz/inspiration-handbook/inspirations/${id}/update`,
      req
    )
    if (res.code === 0 && res.data !== undefined) {
      InspirationBizService.lastError = ''
      return InspirationItem.fromWire(res.data)
    }
    if (res.code === 0) {
      InspirationBizService.lastError = ''
      const fallback = new InspirationItem()
      fallback.id = id
      fallback.title = req.title
      fallback.body = req.body
      fallback.summary = req.summary
      fallback.tags = req.tags
      fallback.recordDate = req.recordDate
      fallback.coverKey = req.coverKey
      return fallback
    }
    InspirationBizService.markFail(res.message)
    return undefined
  }

  static async deleteInspiration(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/inspiration-handbook/inspirations/${id}`)
    if (res.code === 0) {
      InspirationBizService.lastError = ''
      return true
    }
    InspirationBizService.markFail(res.message)
    return false
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
    const res = await HttpClient.get<InspirationItemWire>(`/biz/inspiration-handbook/mood-boards/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    return undefined
  }

  static async createMoodBoard(req: CreateBoardRequest): Promise<InspirationItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = InspirationBizService.userId()
    }
    const res = await HttpClient.post<InspirationItemWire>('/biz/inspiration-handbook/mood-boards', req)
    if (res.code === 0 && res.data !== undefined) {
      InspirationBizService.lastError = ''
      return InspirationItem.fromWire(res.data)
    }
    InspirationBizService.markFail(res.message)
    return undefined
  }

  static async updateMoodBoard(id: string, req: UpdateBoardRequest): Promise<InspirationItem | undefined> {
    const res = await HttpClient.post<InspirationItemWire>(
      `/biz/inspiration-handbook/mood-boards/${id}/update`,
      req
    )
    if (res.code === 0) {
      InspirationBizService.lastError = ''
      if (res.data !== undefined) {
        return InspirationItem.fromWire(res.data)
      }
      const fallback = new InspirationItem()
      fallback.id = id
      fallback.cardsJson = req.cardsJson
      fallback.body = req.body
      return fallback
    }
    InspirationBizService.markFail(res.message)
    return undefined
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
    // 详情 GET 失败时回退列表匹配，避免「刚做成计划却打不开」
    const list = await InspirationBizService.loadCreativePlans(InspirationBizService.userId())
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static async createCreativePlan(req: CreatePlanRequest): Promise<InspirationItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = InspirationBizService.userId()
    }
    const res = await HttpClient.post<InspirationItemWire>('/biz/inspiration-handbook/creative-plans', req)
    if (res.code === 0 && res.data !== undefined) {
      InspirationBizService.lastError = ''
      return InspirationItem.fromWire(res.data)
    }
    InspirationBizService.markFail(res.message)
    return undefined
  }

  static async updateCreativePlan(id: string, req: UpdatePlanRequest): Promise<InspirationItem | undefined> {
    const res = await HttpClient.post<InspirationItemWire>(
      `/biz/inspiration-handbook/creative-plans/${id}/update`,
      req
    )
    if (res.code === 0 && res.data !== undefined) {
      InspirationBizService.lastError = ''
      return InspirationItem.fromWire(res.data)
    }
    InspirationBizService.markFail(res.message)
    return undefined
  }

  static async updateCreativePlanProgress(id: string, progress: number): Promise<InspirationItem | undefined> {
    const req = new UpdatePlanProgressRequest()
    req.progress = progress
    const res = await HttpClient.post<InspirationItemWire>(
      `/biz/inspiration-handbook/creative-plans/${id}/progress`,
      req
    )
    if (res.code === 0 && res.data !== undefined) {
      InspirationBizService.lastError = ''
      return InspirationItem.fromWire(res.data)
    }
    InspirationBizService.markFail(res.message)
    return undefined
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
      InspirationBizService.lastError = ''
      return InspirationItem.fromWire(res.data)
    }
    InspirationBizService.markFail(res.message)
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
}

class DeleteOkPayload {
  id: string = ''
}
