import { HttpClient } from './HttpClient'
import { EmptyPayload, JsonStringBody } from '../models/ApiModels'
import {
  AtelierTime, CardItem, CardListPayload, CardWire, DailyItem, DailyWire,
  FavoriteCreateBody, FavoriteItem, FavoriteListPayload, FavoriteTagsBody, FavoriteWire,
  MsgListPayload, MsgWire
} from '../models/AtelierModels'
import { AtelierCatalog } from './AtelierCatalog'
import { AtelierJson } from './AtelierJson'
import { AtelierShelf } from './AtelierShelf'

const BASE = '/biz/delight-atelier'

export class AtelierBizService {
  private static cardCache: CardItem[] = []
  private static dailyCache: DailyItem[] = []
  static lastError: string = ''

  static userId(): string {
    const u = AppStorage.get<string>('currentUsername')
    if (u !== undefined && u.length > 0) {
      return u
    }
    return ''
  }

  static packCards(): CardItem[] {
    return AtelierCatalog.cards()
  }

  static packDaily(): DailyItem[] {
    return AtelierCatalog.daily()
  }

  static async loadCards(): Promise<CardItem[]> {
    AtelierBizService.lastError = ''
    try {
      const raw = await HttpClient.getText(`${BASE}/cards`)
      const out = AtelierJson.parseCards(raw)
      if (out.length > 0) {
        AtelierBizService.cardCache = out
        return out
      }
    } catch {
      AtelierBizService.lastError = '知识卡加载失败，请检查网络后重试'
    }
    if (AtelierBizService.cardCache.length > 0) {
      return AtelierBizService.cachedCards()
    }
    const pack = AtelierCatalog.cards()
    AtelierBizService.cardCache = pack
    AtelierBizService.lastError = ''
    return pack
  }

  static async findCard(id: string): Promise<CardItem | undefined> {
    for (const item of AtelierBizService.cardCache) {
      if (item.id === id) {
        return item
      }
    }
    try {
      const raw = await HttpClient.getText(`${BASE}/cards/${id}`)
      const parsed = AtelierJson.parseOneCard(raw)
      if (parsed !== undefined) {
        AtelierBizService.mergeCard(parsed)
        return parsed
      }
      const res = await HttpClient.get<CardWire>(`${BASE}/cards/${id}`)
      if (res.code === 0 && res.data !== undefined) {
        const item = CardItem.fromWire(res.data)
        if (item.id.length > 0 && item.title.length > 0) {
          AtelierBizService.mergeCard(item)
          return item
        }
      }
    } catch {
      // 走官方工坊目录
    }
    return AtelierCatalog.cardById(id)
  }

  static async loadDaily(): Promise<DailyItem[]> {
    try {
      const raw = await HttpClient.getText(`${BASE}/daily`)
      const out = AtelierJson.parseDaily(raw)
      if (out.length > 0) {
        AtelierBizService.dailyCache = out
        return out
      }
    } catch {
      // 走缓存或官方工坊目录
    }
    if (AtelierBizService.dailyCache.length > 0) {
      return AtelierBizService.cachedDaily()
    }
    const pack = AtelierCatalog.daily()
    AtelierBizService.dailyCache = pack
    return pack
  }

  static async findDaily(id: string): Promise<DailyItem | undefined> {
    for (const item of AtelierBizService.dailyCache) {
      if (item.id === id) {
        return item
      }
    }
    try {
      const raw = await HttpClient.getText(`${BASE}/daily/${id}`)
      const parsed = AtelierJson.parseOneDaily(raw)
      if (parsed !== undefined) {
        AtelierBizService.mergeDaily(parsed)
        return parsed
      }
      const res = await HttpClient.get<DailyWire>(`${BASE}/daily/${id}`)
      if (res.code === 0 && res.data !== undefined) {
        const item = DailyItem.fromWire(res.data)
        if (item.id.length > 0) {
          AtelierBizService.mergeDaily(item)
          return item
        }
      }
    } catch {
      // 走官方工坊目录
    }
    return AtelierCatalog.dailyById(id)
  }

  static async loadFavorites(userId: string): Promise<FavoriteItem[]> {
    if (userId.length === 0) {
      return []
    }
    const remote: FavoriteItem[] = []
    try {
      const res = await HttpClient.get<FavoriteListPayload>(`${BASE}/favorites?userId=${userId}`)
      if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
        for (const w of res.data.list) {
          try {
            const item = FavoriteItem.fromWire(w)
            if (item.contentId.length > 0 && item.contentType !== 'post') {
              remote.push(item)
              await AtelierShelf.upsert(item)
            }
          } catch {
            continue
          }
        }
      }
    } catch {
      // 走本机书坊
    }
    return AtelierBizService.mergeFavs(remote, AtelierShelf.allForUser(userId))
  }

  static async addFavorite(contentId: string, contentType: string, title: string, tags: string,
    coverMedia: string, category: string): Promise<FavoriteItem | undefined> {
    const uid = AtelierBizService.userId()
    if (uid.length === 0) {
      return undefined
    }
    let remote: FavoriteItem | undefined = undefined
    try {
      const req = new FavoriteCreateBody()
      req.userId = uid
      req.contentId = contentId
      req.contentType = contentType
      req.title = title
      req.tags = tags
      req.coverMedia = coverMedia
      req.category = category
      const res = await HttpClient.post<FavoriteWire>(`${BASE}/favorites`, JsonStringBody.of(req.toJsonString()))
      if (res.code === 0 && res.data !== undefined) {
        remote = FavoriteItem.fromWire(res.data)
      }
    } catch {
      remote = undefined
    }
    const item = remote !== undefined && remote.contentId.length > 0 ?
      remote : FavoriteItem.localOf(uid, contentId, contentType, title, tags, coverMedia, category)
    await AtelierShelf.upsert(item)
    return item
  }

  static async removeFavorite(id: string, contentId: string): Promise<boolean> {
    const uid = AtelierBizService.userId()
    try {
      const res = await HttpClient.delete<EmptyPayload>(`${BASE}/favorites/${id}?userId=${uid}`)
      await AtelierShelf.removeById(id, contentId, uid)
      return res.code === 0 || id.indexOf('local_') === 0
    } catch {
      await AtelierShelf.removeById(id, contentId, uid)
      return true
    }
  }

  static async updateFavoriteTags(id: string, tags: string): Promise<boolean> {
    try {
      const req = new FavoriteTagsBody()
      req.userId = AtelierBizService.userId()
      req.tags = tags
      const res = await HttpClient.patch<EmptyPayload>(`${BASE}/favorites/${id}`, JsonStringBody.of(req.toJsonString()))
      const uid = AtelierBizService.userId()
      const list = AtelierShelf.allForUser(uid)
      for (const row of list) {
        if (row.id === id) {
          row.tags = tags
          await AtelierShelf.upsert(row)
        }
      }
      return res.code === 0 || id.indexOf('local_') === 0
    } catch {
      return id.indexOf('local_') === 0
    }
  }

  static async loadHot(period: string = 'week'): Promise<CardItem[]> {
    try {
      const raw = await HttpClient.getText(`${BASE}/hot?period=${period}`)
      const parsed = AtelierJson.parseCards(raw)
      if (parsed.length > 0) {
        return parsed
      }
      const res = await HttpClient.get<CardListPayload>(`${BASE}/hot?period=${period}`)
      const out: CardItem[] = []
      if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
        for (const w of res.data.list) {
          try {
            const item = CardItem.fromWire(w)
            if (item.id.length > 0 && item.type !== 'user' && item.kind !== 'post') {
              out.push(item)
            }
          } catch {
            continue
          }
        }
      }
      if (out.length > 0) {
        return out
      }
    } catch {
      // fallthrough
    }
    const cached = AtelierBizService.cachedCards()
    if (cached.length > 0) {
      return cached
    }
    return AtelierCatalog.cards()
  }

  static async loadMessages(): Promise<MsgWire[]> {
    try {
      const res = await HttpClient.get<MsgListPayload>(`${BASE}/messages`)
      if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
        return res.data.list
      }
    } catch {
      return []
    }
    return []
  }

  static pickToday(list: DailyItem[]): DailyItem {
    if (list.length === 0) {
      return new DailyItem()
    }
    const today = AtelierTime.todayKey()
    let latest: DailyItem = new DailyItem()
    for (const item of list) {
      if (latest.id.length === 0) {
        latest = item
      }
      if (item.dateKey === today) {
        return item
      }
      latest = item
    }
    return latest
  }

  static filterByCategory(list: CardItem[], category: string): CardItem[] {
    if (category.length === 0 || category === 'all') {
      return list
    }
    const out: CardItem[] = []
    for (const item of list) {
      if (item.category === category) {
        out.push(item)
      }
    }
    return out
  }

  static relatedCards(list: CardItem[], item: CardItem, limit: number): CardItem[] {
    const out: CardItem[] = []
    for (const row of list) {
      if (row.id === item.id) {
        continue
      }
      if (row.category === item.category) {
        out.push(row)
      }
      if (out.length >= limit) {
        break
      }
    }
    return out
  }

  static search(list: CardItem[], keyword: string): CardItem[] {
    const q = keyword.trim()
    if (q.length === 0) {
      return list
    }
    const out: CardItem[] = []
    for (const item of list) {
      if (item.title.indexOf(q) >= 0 || item.summary.indexOf(q) >= 0 || item.body.indexOf(q) >= 0) {
        out.push(item)
      }
    }
    return out
  }

  static cachedCards(): CardItem[] {
    const copy: CardItem[] = []
    for (const item of AtelierBizService.cardCache) {
      copy.push(item)
    }
    return copy
  }

  private static cachedDaily(): DailyItem[] {
    const copy: DailyItem[] = []
    for (const item of AtelierBizService.dailyCache) {
      copy.push(item)
    }
    return copy
  }

  private static mergeFavs(remote: FavoriteItem[], local: FavoriteItem[]): FavoriteItem[] {
    const out: FavoriteItem[] = []
    for (const r of remote) {
      out.push(r)
    }
    for (const l of local) {
      let found = false
      for (const r of out) {
        if (r.contentId === l.contentId) {
          found = true
        }
      }
      if (!found && l.contentType !== 'post') {
        out.push(l)
      }
    }
    return out
  }

  private static mergeCard(item: CardItem): void {
    AtelierBizService.cardCache = AtelierBizService.replaceById(AtelierBizService.cardCache, item)
  }

  private static mergeDaily(item: DailyItem): void {
    const next: DailyItem[] = []
    let replaced = false
    for (const row of AtelierBizService.dailyCache) {
      if (row.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(row)
      }
    }
    if (!replaced) {
      next.push(item)
    }
    AtelierBizService.dailyCache = next
  }

  private static replaceById(list: CardItem[], item: CardItem): CardItem[] {
    const next: CardItem[] = []
    let replaced = false
    for (const row of list) {
      if (row.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(row)
      }
    }
    if (!replaced) {
      next.push(item)
    }
    return next
  }
}
