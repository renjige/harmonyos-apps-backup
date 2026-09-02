import { HttpClient } from './HttpClient'
import {
  AnnualStatsData,
  CreateAlbumRequest,
  CreateDiaryRequest,
  CreateFavoriteRequest,
  UpdateAlbumRequest,
  UpdateDiaryRequest,
  JournalItem,
  JournalItemWire,
  JournalListPayload,
  SearchResultData,
  FootprintItem,
  FootprintListPayload,
  TagPresetItem,
  TagPresetListPayload,
  TagPresetWire,
  MonthlyStatsData,
  MonthlyStatMonth,
  TimelineListPayload
} from '../models/JournalModels'
import { PlanCodec } from './PlanCodec'

export class JournalBizService {
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
    if (req.userId.length === 0) {
      req.userId = JournalBizService.userId()
    }
    const res = await HttpClient.post<JournalItemWire>('/biz/life-journal/diaries', req)
    if (res.code === 0 && res.data !== undefined) {
      return JournalBizService.normalizePlanItem(JournalItem.fromWire(res.data))
    }
    return undefined
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

  static async loadAlbumShowcase(): Promise<JournalItem[]> {
    const res = await HttpClient.get<JournalListPayload>('/biz/life-journal/albums?showcase=1')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return JournalBizService.mapItems(res.data.list)
    }
    return []
  }

  static async loadMyAlbums(userId: string): Promise<JournalItem[]> {
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<JournalListPayload>(
      `/biz/life-journal/albums?mineOnly=1&userId=${encodeURIComponent(uid)}`
    )
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
    if (req.coverKey.length === 0 && req.imageKeys.length > 0) {
      for (const key of req.imageKeys) {
        req.coverKey = key
        break
      }
    }
    const res = await HttpClient.post<JournalItemWire>('/biz/life-journal/albums', req)
    if (res.code === 0 && res.data !== undefined) {
      return JournalItem.fromWire(res.data)
    }
    return undefined
  }

  static async updateAlbum(id: string, req: UpdateAlbumRequest): Promise<JournalItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = JournalBizService.userId()
    }
    const res = await HttpClient.put<JournalItemWire>(`/biz/life-journal/albums/${id}`, req)
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
    if (uid.length === 0) {
      const empty = new AnnualStatsData()
      empty.year = year
      return empty
    }
    const path = `/biz/life-journal/annual-stats?year=${year}&userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<AnnualStatsData>(path)
    if (res.code === 0 && res.data !== undefined) {
      const data = new AnnualStatsData()
      data.diaryCount = res.data.diaryCount ?? 0
      data.imageCount = res.data.imageCount ?? 0
      data.topTags = res.data.topTags ?? []
      data.albumCount = res.data.albumCount ?? 0
      data.favoriteCount = res.data.favoriteCount ?? 0
      data.writingDays = res.data.writingDays ?? 0
      data.year = res.data.year ?? year
      return data
    }
    const empty = new AnnualStatsData()
    empty.year = year
    return empty
  }

  static async loadFootprints(userId: string): Promise<FootprintListPayload> {
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    if (uid.length === 0) {
      return new FootprintListPayload()
    }
    const path = `/biz/life-journal/footprints?userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<FootprintListPayload>(path)
    if (res.code === 0 && res.data !== undefined) {
      const payload = new FootprintListPayload()
      payload.routeCount = res.data.routeCount ?? 0
      payload.diaryCount = res.data.diaryCount ?? 0
      const raw = res.data.list ?? []
      for (const row of raw) {
        const fp = new FootprintItem()
        fp.city = row.city ?? ''
        fp.count = row.count ?? 0
        fp.lastDate = row.lastDate ?? ''
        fp.coverKey = row.coverKey ?? ''
        fp.source = row.source ?? ''
        payload.list.push(fp)
      }
      return payload
    }
    return new FootprintListPayload()
  }

  static isPlanItem(item: JournalItem): boolean {
    if (item.kind === 'plan') {
      return true
    }
    if (item.category === 'planning' || item.category === 'active' || item.category === 'done') {
      return true
    }
    return PlanCodec.isPlanBody(item.body)
  }

  static isCheckinItem(item: JournalItem): boolean {
    return item.kind === 'checkin'
  }

  static normalizePlanItem(item: JournalItem): JournalItem {
    if (item.kind.length === 0 && JournalBizService.isPlanItem(item)) {
      item.kind = 'plan'
    }
    return item
  }

  static filterJourneys(items: JournalItem[]): JournalItem[] {
    const out: JournalItem[] = []
    for (const item of items) {
      if (JournalBizService.isPlanItem(item) || JournalBizService.isCheckinItem(item)) {
        continue
      }
      out.push(item)
    }
    return out
  }

  static filterPlans(items: JournalItem[]): JournalItem[] {
    const out: JournalItem[] = []
    for (const item of items) {
      if (JournalBizService.isPlanItem(item)) {
        out.push(JournalBizService.normalizePlanItem(item))
      }
    }
    return out
  }

  static filterCheckins(items: JournalItem[]): JournalItem[] {
    const out: JournalItem[] = []
    for (const item of items) {
      if (JournalBizService.isCheckinItem(item)) {
        out.push(item)
      }
    }
    return out
  }

  static computeCheckinStreak(checkins: JournalItem[]): number {
    if (checkins.length === 0) {
      return 0
    }
    const dates: string[] = []
    for (const c of checkins) {
      const d = c.recordDate.length > 0 ? c.recordDate : c.createdAt.slice(0, 10)
      if (d.length > 0) {
        dates.push(d)
      }
    }
    dates.sort((a, b) => b.localeCompare(a))
    let streak = 0
    const today = new Date()
    for (let i = 0; i < dates.length; i++) {
      const expect = new Date(today)
      expect.setDate(today.getDate() - i)
      const expectStr = expect.toISOString().slice(0, 10)
      if (dates.indexOf(expectStr) >= 0) {
        streak += 1
      } else {
        break
      }
    }
    return streak
  }

  static hasCheckinToday(checkins: JournalItem[]): boolean {
    const today = new Date().toISOString().slice(0, 10)
    for (const c of checkins) {
      const d = c.recordDate.length > 0 ? c.recordDate : c.createdAt.slice(0, 10)
      if (d === today) {
        return true
      }
    }
    return false
  }

  static async updateDiary(id: string, req: UpdateDiaryRequest): Promise<JournalItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = JournalBizService.userId()
    }
    const res = await HttpClient.put<JournalItemWire>(`/biz/life-journal/diaries/${id}`, req)
    if (res.code === 0 && res.data !== undefined) {
      return JournalItem.fromWire(res.data)
    }
    return undefined
  }

  static async deleteDiary(id: string, userId: string): Promise<boolean> {
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    const path = `/biz/life-journal/diaries/${id}?userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.delete<DeleteOkPayload>(path)
    return res.code === 0
  }

  static async loadTimeline(userId: string, limit: number): Promise<JournalItem[]> {
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const path = `/biz/life-journal/timeline?userId=${encodeURIComponent(uid)}&limit=${limit}`
    const res = await HttpClient.get<TimelineListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return JournalBizService.mapItems(res.data.list)
    }
    return []
  }

  static async loadMonthlyStats(userId: string, year: number): Promise<MonthlyStatsData> {
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    const empty = new MonthlyStatsData()
    empty.year = year
    if (uid.length === 0) {
      return empty
    }
    const path = `/biz/life-journal/monthly-stats?year=${year}&userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<MonthlyStatsData>(path)
    if (res.code === 0 && res.data !== undefined) {
      const data = new MonthlyStatsData()
      data.year = res.data.year ?? year
      const raw = res.data.months ?? []
      for (const m of raw) {
        const row = new MonthlyStatMonth()
        row.month = m.month ?? 0
        row.diaryCount = m.diaryCount ?? 0
        row.imageCount = m.imageCount ?? 0
        data.months.push(row)
      }
      return data
    }
    return empty
  }

  static async loadAllDiaries(userId: string): Promise<JournalItem[]> {
    return JournalBizService.loadDiaries(userId)
  }
}

class DeleteOkPayload {
  id: string = ''
}
