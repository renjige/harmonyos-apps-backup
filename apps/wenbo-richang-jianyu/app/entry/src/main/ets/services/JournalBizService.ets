import { HttpClient } from './HttpClient'
import { JournalCatalog } from './JournalCatalog'
import { JournalLocalStore } from './JournalLocalStore'
import { JournalDetailNav } from './JournalDetailNav'
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
  TagPresetItem,
  TagPresetListPayload,
  TagPresetWire,
  TopTagItem
} from '../models/JournalModels'

export class JournalBizService {
  static lastError: string = ''

  private static userId(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  private static mapItems(wires: JournalItemWire[]): JournalItem[] {
    const out: JournalItem[] = []
    if (wires === undefined || wires === null) {
      return out
    }
    for (const w of wires) {
      try {
        const item = JournalItem.fromWire(w)
        if (item.id.length > 0 || item.title.length > 0) {
          out.push(item)
        }
      } catch {
        continue
      }
    }
    return out
  }

  private static newLocalId(): string {
    return `ljlocal_${Date.now()}`
  }

  private static itemFromCreate(req: CreateDiaryRequest, localId: string): JournalItem {
    const item = new JournalItem()
    item.id = localId
    item.title = req.title
    item.body = req.body
    item.summary = req.summary
    item.tags = JournalItem.safeKeys(req.tags)
    item.recordDate = req.recordDate
    item.coverKey = req.coverKey
    item.imageKeys = JournalItem.safeKeys(req.imageKeys)
    item.photoCount = item.imageKeys.length > 0 ? item.imageKeys.length : (req.coverKey.length > 0 ? 1 : 0)
    item.userId = req.userId
    item.kind = req.kind
    item.category = req.category
    item.createdAt = req.recordDate
    return item
  }

  private static cloudCopy(req: CreateDiaryRequest): CreateDiaryRequest {
    const cloud = new CreateDiaryRequest()
    cloud.title = req.title
    cloud.body = req.body
    cloud.summary = req.summary
    cloud.tags = req.tags
    cloud.recordDate = req.recordDate
    cloud.userId = req.userId
    cloud.kind = req.kind
    cloud.category = req.category
    cloud.coverKey = JournalCatalog.cloudMediaKey(req.coverKey)
    const keys: string[] = []
    for (const k of req.imageKeys) {
      if (!k.startsWith('local:')) {
        keys.push(k)
      }
    }
    if (keys.length === 0) {
      keys.push(cloud.coverKey)
    }
    cloud.imageKeys = keys
    return cloud
  }

  static async cachedDiaries(userId: string): Promise<JournalItem[]> {
    const uid = userId.length > 0 ? userId : JournalBizService.userId()
    if (uid.length === 0) {
      return []
    }
    return await JournalLocalStore.list(uid)
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
    const cached = await JournalLocalStore.list(uid)
    try {
      const res = await HttpClient.get<JournalListPayload>(
        `/biz/life-journal/diaries?userId=${encodeURIComponent(uid)}`
      )
      if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
        const remote = JournalBizService.mapItems(res.data.list)
        const tombstones = await JournalLocalStore.deletedIds(uid)
        const merged = JournalLocalStore.mergeRemote(cached, remote, tombstones)
        await JournalLocalStore.saveAll(uid, merged)
        return merged
      }
    } catch {
      return cached
    }
    return cached
  }

  static async findDiary(id: string): Promise<JournalItem | undefined> {
    const uid = JournalBizService.userId()
    let lookup = id
    if (uid.length > 0) {
      lookup = await JournalLocalStore.resolveId(uid, id)
      const deadOld = await JournalLocalStore.isDeleted(uid, id)
      const deadNew = await JournalLocalStore.isDeleted(uid, lookup)
      if (deadOld || deadNew) {
        return undefined
      }
      const cached = await JournalLocalStore.list(uid)
      for (const row of cached) {
        if (row.id === lookup || row.id === id) {
          return row
        }
      }
    }
    if (lookup.startsWith('ljlocal_') || id.startsWith('ljlocal_')) {
      return undefined
    }
    try {
      const res = await HttpClient.get<JournalItemWire>(`/biz/life-journal/diaries/${lookup}`)
      if (res.code === 0 && res.data !== undefined) {
        return JournalItem.fromWire(res.data)
      }
    } catch {
      return undefined
    }
    return undefined
  }

  static async createDiary(req: CreateDiaryRequest): Promise<JournalItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = JournalBizService.userId()
    }
    if (req.userId.length === 0) {
      JournalBizService.lastError = '请先登录后再写笺语'
      return undefined
    }
    JournalBizService.lastError = ''
    const localId = JournalBizService.newLocalId()
    const localItem = JournalBizService.itemFromCreate(req, localId)
    await JournalLocalStore.upsert(req.userId, localItem)
    void JournalBizService.syncCreate(req, localId, localItem)
    return localItem
  }

  private static async syncCreate(req: CreateDiaryRequest, localId: string, localItem: JournalItem): Promise<void> {
    const cloudReq = JournalBizService.cloudCopy(req)
    try {
      const res = await HttpClient.post<JournalItemWire>('/biz/life-journal/diaries', cloudReq)
      if (res.code === 0 && res.data !== undefined) {
        const remote = JournalItem.fromWire(res.data)
        if (localItem.coverKey.startsWith('local:')) {
          remote.coverKey = localItem.coverKey
          remote.imageKeys = localItem.imageKeys
        }
        await JournalLocalStore.replaceId(req.userId, localId, remote)
        JournalDetailNav.notifyDiaryChanged()
      }
    } catch {
      return
    }
  }

  static async updateDiary(id: string, req: UpdateDiaryRequest): Promise<JournalItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = JournalBizService.userId()
    }
    JournalBizService.lastError = ''
    const item = new JournalItem()
    item.id = id
    item.title = req.title
    item.body = req.body
    item.summary = req.summary
    item.tags = req.tags
    item.recordDate = req.recordDate
    item.coverKey = req.coverKey
    item.imageKeys = req.imageKeys
    item.userId = req.userId
    item.kind = req.kind
    item.category = req.category
    item.photoCount = req.imageKeys.length > 0 ? req.imageKeys.length : (req.coverKey.length > 0 ? 1 : 0)
    await JournalLocalStore.upsert(req.userId, item)
    void JournalBizService.syncUpdate(id, req, item)
    return item
  }

  private static async syncUpdate(id: string, req: UpdateDiaryRequest, item: JournalItem): Promise<void> {
    if (id.startsWith('ljlocal_')) {
      return
    }
    const cloud = new UpdateDiaryRequest()
    cloud.title = req.title
    cloud.body = req.body
    cloud.summary = req.summary
    cloud.tags = req.tags
    cloud.recordDate = req.recordDate
    cloud.userId = req.userId
    cloud.kind = req.kind
    cloud.category = req.category
    cloud.coverKey = JournalCatalog.cloudMediaKey(req.coverKey)
    const keys: string[] = []
    for (const k of req.imageKeys) {
      if (!k.startsWith('local:')) {
        keys.push(k)
      }
    }
    cloud.imageKeys = keys.length > 0 ? keys : [cloud.coverKey]
    try {
      const res = await HttpClient.put<JournalItemWire>(`/biz/life-journal/diaries/${id}`, cloud)
      if (res.code === 0 && res.data !== undefined) {
        const remote = JournalItem.fromWire(res.data)
        if (item.coverKey.startsWith('local:')) {
          remote.coverKey = item.coverKey
          remote.imageKeys = item.imageKeys
        }
        await JournalLocalStore.upsert(req.userId, remote)
      }
    } catch {
      return
    }
  }

  static async deleteDiary(id: string): Promise<boolean> {
    const uid = JournalBizService.userId()
    await JournalLocalStore.remove(uid, id)
    if (id.startsWith('ljlocal_')) {
      return true
    }
    try {
      const res = await HttpClient.delete<DeleteOkPayload>(
        `/biz/life-journal/diaries/${id}?userId=${encodeURIComponent(uid)}`
      )
      return res.code === 0
    } catch {
      return true
    }
  }

  static sameDayItems(items: JournalItem[], iso: string): JournalItem[] {
    const out: JournalItem[] = []
    if (iso.length < 10) {
      return out
    }
    const md = iso.substring(5, 10)
    for (const item of items) {
      if (item.recordDate.length >= 10 && item.recordDate.substring(5, 10) === md) {
        if (item.recordDate.substring(0, 10) !== iso.substring(0, 10)) {
          out.push(item)
        }
      }
    }
    return out
  }

  static localAnnualStats(items: JournalItem[], year: number): AnnualStatsData {
    const stats = new AnnualStatsData()
    stats.year = year
    const prefix = `${year}-`
    const tops: TopTagItem[] = []
    for (const d of items) {
      if (d.recordDate.startsWith(prefix) || d.createdAt.startsWith(prefix)) {
        stats.diaryCount += 1
        stats.imageCount += d.imageKeys.length > 0 ? d.imageKeys.length : (d.coverKey.length > 0 ? 1 : 0)
        for (const t of d.tags) {
          let found = false
          for (const row of tops) {
            if (row.tag === t) {
              row.count += 1
              found = true
            }
          }
          if (!found) {
            const n = new TopTagItem()
            n.tag = t
            n.count = 1
            tops.push(n)
          }
        }
      }
    }
    stats.topTags = tops
    return stats
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
    const out: JournalItem[] = []
    for (const a of mine) {
      out.push(a)
    }
    for (const a of showcase) {
      out.push(a)
    }
    return out
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
      req.coverKey = req.imageKeys[0]
    }
    JournalBizService.lastError = ''
    const res = await HttpClient.post<JournalItemWire>('/biz/life-journal/albums', req)
    if (res.code === 0 && res.data !== undefined) {
      return JournalItem.fromWire(res.data)
    }
    JournalBizService.lastError = res.message.length > 0 ? res.message : '创建失败，请稍后重试'
    return undefined
  }

  static async updateAlbum(id: string, req: UpdateAlbumRequest): Promise<JournalItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = JournalBizService.userId()
    }
    JournalBizService.lastError = ''
    const res = await HttpClient.put<JournalItemWire>(`/biz/life-journal/albums/${id}`, req)
    if (res.code === 0 && res.data !== undefined) {
      return JournalItem.fromWire(res.data)
    }
    JournalBizService.lastError = res.message.length > 0 ? res.message : '更新失败，请稍后重试'
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
    JournalBizService.lastError = ''
    const res = await HttpClient.post<JournalItemWire>('/biz/life-journal/favorites', req)
    if (res.code === 0 && res.data !== undefined) {
      return JournalItem.fromWire(res.data)
    }
    JournalBizService.lastError = res.message.length > 0 ? res.message : '收藏失败，请稍后重试'
    return undefined
  }

  static async hasFavoriteRef(sourceRefId: string, userId: string): Promise<boolean> {
    if (sourceRefId.length === 0) {
      return false
    }
    const list = await JournalBizService.loadFavorites(userId)
    for (const item of list) {
      if (item.sourceRefId === sourceRefId) {
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
    const res = await HttpClient.get<AnnualStatsData>(path)
    if (res.code === 0 && res.data !== undefined) {
      if (uid.length > 0) {
        const local = await JournalLocalStore.list(uid)
        const localStats = JournalBizService.localAnnualStats(local, year)
        if (localStats.diaryCount > res.data.diaryCount) {
          res.data.diaryCount = localStats.diaryCount
        }
        if (localStats.imageCount > res.data.imageCount) {
          res.data.imageCount = localStats.imageCount
        }
      }
      return res.data
    }
    if (uid.length > 0) {
      const local = await JournalLocalStore.list(uid)
      return JournalBizService.localAnnualStats(local, year)
    }
    const empty = new AnnualStatsData()
    empty.year = year
    return empty
  }
}

class DeleteOkPayload {
  id: string = ''
}
