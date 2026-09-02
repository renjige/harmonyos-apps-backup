import { HttpClient } from './HttpClient'
import {
  AnnualStatsData,
  CreateAlbumRequest,
  CreateDiaryRequest,
  CreateFavoriteRequest,
  JournalItem,
  JournalItemWire,
  JournalListPayload,
  SearchResultData,
  TagPresetItem,
  TagPresetListPayload,
  TagPresetWire
} from '../models/JournalModels'

export class JournalBizService {
  static lastError: string = ''

  private static userId(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  private static mapItems(wires: JournalItemWire[]): JournalItem[] {
    const out: JournalItem[] = []
    for (const w of wires) {
      out.push(JournalItem.fromWire(w))
    }
    return out
  }

  static async loadFeatured(): Promise<JournalItem[]> {
    const res = await HttpClient.get<JournalListPayload>('/biz/life-journal/featured')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return JournalBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findFeatured(id: string): Promise<JournalItem | undefined> {
    const res = await HttpClient.get<JournalItemWire>(`/biz/life-journal/featured/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return JournalItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadDiaries(userId: string): Promise<JournalItem[]> {
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<JournalListPayload>(
      `/biz/life-journal/diaries?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return JournalBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findDiary(id: string): Promise<JournalItem | undefined> {
    const res = await HttpClient.get<JournalItemWire>(`/biz/life-journal/diaries/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return JournalItem.fromWire(res.data)
    }
    return undefined
  }

  static async createDiary(req: CreateDiaryRequest): Promise<JournalItem | undefined> {
    JournalBizService.lastError = ''
    if (req.userId.length === 0) {
      req.userId = JournalBizService.userId()
    }
    const res = await HttpClient.post<JournalItemWire>('/biz/life-journal/diaries', req)
    if (res.code === 0 && res.data !== undefined) {
      return JournalItem.fromWire(res.data)
    }
    JournalBizService.lastError = res.message.length > 0 ? res.message : '保存失败，请稍后重试'
    return undefined
  }

  static async deleteDiary(id: string): Promise<boolean> {
    const uid = JournalBizService.userId()
    let path = `/biz/life-journal/diaries/${id}`
    if (uid.length > 0) {
      path += `?userId=${encodeURIComponent(uid)}`
    }
    const res = await HttpClient.delete<DeleteOkPayload>(path)
    return res.code === 0
  }

  static async loadAlbums(userId: string): Promise<JournalItem[]> {
    let path = '/biz/life-journal/albums'
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    if (uid.length > 0) {
      path += `?userId=${encodeURIComponent(uid)}`
    }
    const res = await HttpClient.get<JournalListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return JournalBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findAlbum(id: string): Promise<JournalItem | undefined> {
    const res = await HttpClient.get<JournalItemWire>(`/biz/life-journal/albums/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return JournalItem.fromWire(res.data)
    }
    return undefined
  }

  static async createAlbum(req: CreateAlbumRequest): Promise<JournalItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = JournalBizService.userId()
    }
    const res = await HttpClient.post<JournalItemWire>('/biz/life-journal/albums', req)
    if (res.code === 0 && res.data !== undefined) {
      return JournalItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadFavorites(userId: string): Promise<JournalItem[]> {
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<JournalListPayload>(
      `/biz/life-journal/favorites?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return JournalBizService.mapItems(res.data.list)
    }
    return []
  }

  static async createFavorite(req: CreateFavoriteRequest): Promise<JournalItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = JournalBizService.userId()
    }
    const res = await HttpClient.post<JournalItemWire>('/biz/life-journal/favorites', req)
    if (res.code === 0 && res.data !== undefined) {
      return JournalItem.fromWire(res.data)
    }
    return undefined
  }

  static async deleteFavorite(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/life-journal/favorites/${id}`)
    return res.code === 0
  }

  static async loadTagPresets(): Promise<TagPresetItem[]> {
    const res = await HttpClient.get<TagPresetListPayload>('/biz/life-journal/tag-presets')
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
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    let path = `/biz/life-journal/search?q=${encodeURIComponent(q)}`
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

  static async loadAnnualStats(userId: string, year: number): Promise<AnnualStatsData> {
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    let path = `/biz/life-journal/annual-stats?year=${year}`
    if (uid.length > 0) {
      path += `&userId=${encodeURIComponent(uid)}`
    }
    const res = await HttpClient.get<AnnualStatsData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    const empty = new AnnualStatsData()
    empty.year = year
    return empty
  }
}

class DeleteOkPayload {
  id: string = ''
}
