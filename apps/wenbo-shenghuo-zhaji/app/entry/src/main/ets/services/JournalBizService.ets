import { HttpClient } from './HttpClient'
import {
  AnnualStatsData,
  AnnualStatsWire,
  CreateAlbumRequest,
  CreateDiaryRequest,
  CreateFavoriteRequest,
  UpdateAlbumRequest,
  UpdateDiaryRequest,
  JournalItem,
  JournalItemWire,
  JournalListPayload,
  MonthlyStatsData,
  SearchResultData,
  TagPresetItem,
  TagPresetListPayload,
  TagPresetWire,
  TimelineListPayload
} from '../models/JournalModels'
import { LocalPhotoStore } from './LocalPhotoStore'
import { JournalImageCatalog } from './JournalImageCatalog'

export class JournalBizService {
  private static userId(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  private static mapItems(wires: JournalItemWire[]): JournalItem[] {
    const out: JournalItem[] = []
    for (const w of wires) {
      out.push(LocalPhotoStore.apply(JournalItem.fromWire(w)))
    }
    return out
  }

  private static onlyJournals(items: JournalItem[]): JournalItem[] {
    const out: JournalItem[] = []
    for (const item of items) {
      if (!JournalItem.isUtilityKind(item.kind)) {
        out.push(item)
      }
    }
    return out
  }

  private static onlyKind(items: JournalItem[], kind: string): JournalItem[] {
    const out: JournalItem[] = []
    for (const item of items) {
      if (item.kind === kind) {
        out.push(item)
      }
    }
    return out
  }

  static async loadAllRaw(userId: string): Promise<JournalItem[]> {
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
    const all = await JournalBizService.loadAllRaw(userId)
    return JournalBizService.onlyJournals(all)
  }

  static async loadByKind(userId: string, kind: string): Promise<JournalItem[]> {
    const all = await JournalBizService.loadAllRaw(userId)
    return JournalBizService.onlyKind(all, kind)
  }

  static async findDiary(id: string): Promise<JournalItem | undefined> {
    const res = await HttpClient.get<JournalItemWire>(`/biz/life-journal/diaries/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return LocalPhotoStore.apply(JournalItem.fromWire(res.data))
    }
    return undefined
  }

  static async createDiary(req: CreateDiaryRequest): Promise<JournalItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = JournalBizService.userId()
    }
    const sentKeys: string[] = []
    for (let i = 0; i < req.imageKeys.length; i++) {
      sentKeys.push(req.imageKeys[i])
    }
    if (req.coverKey.length > 0 && JournalImageCatalog.isLocalKey(req.coverKey)) {
      let found = false
      for (let j = 0; j < sentKeys.length; j++) {
        if (sentKeys[j] === req.coverKey) {
          found = true
        }
      }
      if (!found) {
        sentKeys.unshift(req.coverKey)
      }
    }
    const res = await HttpClient.post<JournalItemWire>('/biz/life-journal/diaries', req)
    if (res.code === 0 && res.data !== undefined) {
      await LocalPhotoStore.save(res.data.id, sentKeys)
      return LocalPhotoStore.apply(JournalItem.fromWire(res.data))
    }
    return undefined
  }

  static async updateDiary(id: string, req: UpdateDiaryRequest): Promise<JournalItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = JournalBizService.userId()
    }
    const res = await HttpClient.put<JournalItemWire>(`/biz/life-journal/diaries/${id}`, req)
    if (res.code === 0 && res.data !== undefined) {
      if (req.imageKeys.length > 0) {
        await LocalPhotoStore.save(id, req.imageKeys)
      }
      return LocalPhotoStore.apply(JournalItem.fromWire(res.data))
    }
    return undefined
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
      `/biz/life-journal/albums?userId=${encodeURIComponent(uid)}&mineOnly=1`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return JournalBizService.mapItems(res.data.list)
    }
    return []
  }

  static async loadAlbums(userId: string): Promise<JournalItem[]> {
    const showcase = await JournalBizService.loadAlbumShowcase()
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    if (uid.length === 0) {
      return showcase
    }
    const mine = await JournalBizService.loadMyAlbums(uid)
    return [...mine, ...showcase]
  }

  static async findAlbum(id: string): Promise<JournalItem | undefined> {
    const res = await HttpClient.get<JournalItemWire>(`/biz/life-journal/albums/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return LocalPhotoStore.apply(JournalItem.fromWire(res.data))
    }
    return undefined
  }

  static async createAlbum(req: CreateAlbumRequest): Promise<JournalItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = JournalBizService.userId()
    }
    if (req.coverKey.length === 0 && req.imageKeys.length > 0) {
      req.coverKey = req.imageKeys[0]
    }
    const res = await HttpClient.post<JournalItemWire>('/biz/life-journal/albums', req)
    if (res.code === 0 && res.data !== undefined) {
      await LocalPhotoStore.save(res.data.id, req.imageKeys)
      return LocalPhotoStore.apply(JournalItem.fromWire(res.data))
    }
    return undefined
  }

  static async updateAlbum(id: string, req: UpdateAlbumRequest): Promise<JournalItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = JournalBizService.userId()
    }
    const res = await HttpClient.put<JournalItemWire>(`/biz/life-journal/albums/${id}`, req)
    if (res.code === 0 && res.data !== undefined) {
      const extra: string[] = []
      for (let i = 0; i < req.appendImageKeys.length; i++) {
        extra.push(req.appendImageKeys[i])
      }
      await LocalPhotoStore.save(id, extra)
      return LocalPhotoStore.apply(JournalItem.fromWire(res.data))
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

  static async isFavorited(sourceRefId: string): Promise<boolean> {
    if (sourceRefId.length === 0) {
      return false
    }
    const uid = JournalBizService.userId()
    if (uid.length === 0) {
      return false
    }
    const favs = await JournalBizService.loadFavorites(uid)
    for (let i = 0; i < favs.length; i++) {
      if (favs[i].sourceRefId === sourceRefId) {
        return true
      }
    }
    return false
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
    const res = await HttpClient.get<AnnualStatsWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      const stats = AnnualStatsData.fromWire(res.data)
      if (uid.length > 0 && stats.imageCount === 0) {
        const reconciled = await JournalBizService.reconcileImageCount(uid, stats)
        return reconciled
      }
      return stats
    }
    const empty = new AnnualStatsData()
    empty.year = year
    return empty
  }

  /** API 统计异常时，用本地列表兜底图片数 */
  private static async reconcileImageCount(uid: string, stats: AnnualStatsData): Promise<AnnualStatsData> {
    const diaries = await JournalBizService.loadDiaries(uid)
    const albums = await JournalBizService.loadMyAlbums(uid)
    let count = 0
    for (const d of diaries) {
      count += JournalItem.displayPhotoKeys(d).length
    }
    for (const a of albums) {
      count += JournalItem.displayPhotoKeys(a).length
    }
    if (count > stats.imageCount) {
      stats.imageCount = count
    }
    if (stats.albumCount === 0 && albums.length > 0) {
      stats.albumCount = albums.length
    }
    return stats
  }

  static async loadMonthlyStats(userId: string, year: number): Promise<MonthlyStatsData> {
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    if (uid.length === 0) {
      const empty = new MonthlyStatsData()
      empty.year = year
      return empty
    }
    const path =
      `/biz/life-journal/monthly-stats?year=${year}&userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<MonthlyStatsData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    const empty = new MonthlyStatsData()
    empty.year = year
    return empty
  }

  static async loadTimeline(userId: string, limit: number): Promise<JournalItem[]> {
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const path =
      `/biz/life-journal/timeline?userId=${encodeURIComponent(uid)}&limit=${limit}`
    const res = await HttpClient.get<TimelineListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return JournalBizService.mapItems(res.data.list)
    }
    return []
  }

  static async loadFootprints(userId: string): Promise<FootprintListData> {
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    if (uid.length === 0) {
      return new FootprintListData()
    }
    const path = `/biz/life-journal/footprints?userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<FootprintListData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    return new FootprintListData()
  }
}

export class FootprintItem {
  city: string = ''
  count: number = 0
  lastDate: string = ''
  coverKey: string = ''
  source: string = ''
}

export class FootprintListData {
  list: FootprintItem[] = []
  routeCount: number = 0
  diaryCount: number = 0
}

class DeleteOkPayload {
  id: string = ''
}
