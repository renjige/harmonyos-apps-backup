import { HttpClient } from './HttpClient'
import {
  ArticleItem,
  ArticleListWire,
  ArticleWire,
  BrochureItem,
  BrochureListWire,
  BrochureWire,
  DeleteOkWire,
  FavoriteCreateBody,
  FavoriteListWire,
  FavoriteRecord,
  FavoriteWire,
  MessageItem,
  MessageListWire,
  MessageWire,
  WatchListWire,
  WatchRecord
} from '../models/BrochureModels'

/** 栏目数据走平台 /biz/enrollment-guide/*；失败返回空列表，禁止 localSeed。 */
export class BrochureBizService {
  static async loadBrochures(
    level: string = '',
    type: string = '',
    province: string = '',
    q: string = ''
  ): Promise<BrochureItem[]> {
    const params: string[] = []
    if (level.length > 0) {
      params.push(`level=${encodeURIComponent(level)}`)
    }
    if (type.length > 0) {
      params.push(`type=${encodeURIComponent(type)}`)
    }
    if (province.length > 0) {
      params.push(`province=${encodeURIComponent(province)}`)
    }
    if (q.length > 0) {
      params.push(`q=${encodeURIComponent(q)}`)
    }
    let path = '/biz/enrollment-guide/brochures'
    if (params.length > 0) {
      path = `${path}?${params.join('&')}`
    }
    const res = await HttpClient.get<BrochureListWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return BrochureBizService.mapBrochures(res.data.list)
    }
    return []
  }

  static async loadBrochureById(id: string): Promise<BrochureItem | undefined> {
    const res = await HttpClient.get<BrochureWire>(`/biz/enrollment-guide/brochures/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return BrochureBizService.mapBrochure(res.data)
    }
    const list = await BrochureBizService.loadBrochures()
    return BrochureBizService.findBrochure(list, id)
  }

  static async loadArticles(): Promise<ArticleItem[]> {
    const res = await HttpClient.get<ArticleListWire>('/biz/enrollment-guide/articles')
    if (res.code === 0 && res.data !== undefined) {
      return BrochureBizService.mapArticles(res.data.list)
    }
    return []
  }

  static async loadArticleById(id: string): Promise<ArticleItem | undefined> {
    const res = await HttpClient.get<ArticleWire>(`/biz/enrollment-guide/articles/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return BrochureBizService.mapArticle(res.data)
    }
    const list = await BrochureBizService.loadArticles()
    return BrochureBizService.findArticle(list, id)
  }

  static async loadMessages(): Promise<MessageItem[]> {
    const res = await HttpClient.get<MessageListWire>('/messages')
    if (res.code === 0 && res.data !== undefined) {
      return BrochureBizService.mapMessages(res.data.list)
    }
    return []
  }

  static async loadFavorites(userId: string): Promise<FavoriteRecord[]> {
    if (userId.length === 0) {
      return []
    }
    const path = `/biz/enrollment-guide/favorites?userId=${encodeURIComponent(userId)}`
    const res = await HttpClient.get<FavoriteListWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return BrochureBizService.mapFavorites(res.data.list)
    }
    return []
  }

  static async addFavorite(userId: string, title: string, targetId: string): Promise<FavoriteRecord | undefined> {
    const body = new FavoriteCreateBody()
    body.userId = userId
    body.title = title
    body.targetKind = 'brochure'
    body.targetId = targetId
    const res = await HttpClient.post<FavoriteWire>('/biz/enrollment-guide/favorites', body)
    if (res.code === 0 && res.data !== undefined) {
      return BrochureBizService.mapFavorite(res.data)
    }
    return undefined
  }

  static async removeFavorite(id: string, userId: string): Promise<boolean> {
    const path = `/biz/enrollment-guide/favorites/${id}?userId=${encodeURIComponent(userId)}`
    const res = await HttpClient.delete<DeleteOkWire>(path)
    return res.code === 0
  }

  static async loadWatchlist(userId: string): Promise<WatchRecord[]> {
    if (userId.length === 0) {
      return []
    }
    const path = `/biz/enrollment-guide/watchlist?userId=${encodeURIComponent(userId)}`
    const res = await HttpClient.get<WatchListWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return BrochureBizService.mapWatchlist(res.data.list)
    }
    return []
  }

  static async addWatchlist(userId: string, title: string, targetId: string): Promise<WatchRecord | undefined> {
    const body = new FavoriteCreateBody()
    body.userId = userId
    body.title = title
    body.targetKind = 'brochure'
    body.targetId = targetId
    const res = await HttpClient.post<FavoriteWire>('/biz/enrollment-guide/watchlist', body)
    if (res.code === 0 && res.data !== undefined) {
      return BrochureBizService.mapWatch(res.data)
    }
    return undefined
  }

  static async removeWatchlist(id: string, userId: string): Promise<boolean> {
    const path = `/biz/enrollment-guide/watchlist/${id}?userId=${encodeURIComponent(userId)}`
    const res = await HttpClient.delete<DeleteOkWire>(path)
    return res.code === 0
  }

  static findBrochure(list: BrochureItem[], id: string): BrochureItem | undefined {
    for (let row of list) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  static findArticle(list: ArticleItem[], id: string): ArticleItem | undefined {
    for (let row of list) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  static filterClient(list: BrochureItem[], chip: string): BrochureItem[] {
    if (chip === 'all' || chip.length === 0) {
      return list
    }
    if (chip === '本科' || chip === '硕士' || chip === '博士') {
      const out: BrochureItem[] = []
      for (let row of list) {
        if (row.level === chip) {
          out.push(row)
        }
      }
      return out
    }
    if (chip === '985') {
      const out: BrochureItem[] = []
      for (let row of list) {
        if (row.type.indexOf('985') >= 0) {
          out.push(row)
        }
      }
      return out
    }
    if (chip === '211') {
      const out: BrochureItem[] = []
      for (let row of list) {
        if (row.type.indexOf('211') >= 0) {
          out.push(row)
        }
      }
      return out
    }
    return list
  }

  private static mapBrochures(rows: BrochureWire[]): BrochureItem[] {
    const out: BrochureItem[] = []
    for (let row of rows) {
      out.push(BrochureBizService.mapBrochure(row))
    }
    return out
  }

  private static mapBrochure(row: BrochureWire): BrochureItem {
    const item = new BrochureItem()
    item.id = row.id
    item.title = row.title
    item.subtitle = row.subtitle ?? ''
    item.summary = row.summary ?? ''
    item.body = row.body ?? row.description ?? ''
    item.description = row.description ?? row.body ?? row.summary ?? ''
    item.coverKey = row.coverKey ?? row.coverMedia ?? ''
    item.level = row.level ?? ''
    item.type = row.type ?? ''
    item.province = row.province ?? ''
    item.enrollmentTotal = row.enrollmentTotal ?? 0
    item.majors = row.majors ?? ''
    item.scoreLine = row.scoreLine ?? ''
    item.registrationStart = row.registrationStart ?? ''
    item.registrationEnd = row.registrationEnd ?? ''
    item.contactPhone = row.contactPhone ?? ''
    item.contactEmail = row.contactEmail ?? ''
    item.contactWebsite = row.contactWebsite ?? ''
    item.note = row.note ?? ''
    item.status = row.status ?? 'published'
    item.tags = row.tags ?? ''
    item.tuition = row.tuition ?? ''
    item.examRequirement = row.examRequirement ?? ''
    item.scholarship = row.scholarship ?? ''
    return item
  }

  private static mapArticles(rows: ArticleWire[]): ArticleItem[] {
    const out: ArticleItem[] = []
    for (let row of rows) {
      out.push(BrochureBizService.mapArticle(row))
    }
    return out
  }

  private static mapArticle(row: ArticleWire): ArticleItem {
    const item = new ArticleItem()
    item.id = row.id
    item.title = row.title
    item.summary = row.summary ?? row.description ?? ''
    item.body = row.body ?? row.description ?? row.summary ?? ''
    item.coverKey = row.coverKey ?? row.coverMedia ?? ''
    item.tags = row.tags ?? ''
    item.readMinutes = row.readMinutes ?? 0
    item.updatedAt = row.updatedAt ?? ''
    return item
  }

  private static mapFavorites(rows: FavoriteWire[]): FavoriteRecord[] {
    const out: FavoriteRecord[] = []
    for (let row of rows) {
      out.push(BrochureBizService.mapFavorite(row))
    }
    return out
  }

  private static mapFavorite(row: FavoriteWire): FavoriteRecord {
    const item = new FavoriteRecord()
    item.id = row.id
    item.title = row.title
    item.userId = row.userId ?? ''
    item.targetKind = row.targetKind ?? 'brochure'
    item.targetId = row.targetId ?? ''
    item.status = row.status ?? 'active'
    return item
  }

  private static mapWatchlist(rows: FavoriteWire[]): WatchRecord[] {
    const out: WatchRecord[] = []
    for (let row of rows) {
      out.push(BrochureBizService.mapWatch(row))
    }
    return out
  }

  private static mapWatch(row: FavoriteWire): WatchRecord {
    const item = new WatchRecord()
    item.id = row.id
    item.title = row.title
    item.userId = row.userId ?? ''
    item.targetKind = row.targetKind ?? 'brochure'
    item.targetId = row.targetId ?? ''
    item.status = row.status ?? 'active'
    return item
  }

  private static mapMessages(rows: MessageWire[]): MessageItem[] {
    const out: MessageItem[] = []
    for (let row of rows) {
      const item = new MessageItem()
      item.id = row.id
      item.title = row.title
      item.body = row.body
      item.type = row.type
      item.read = row.read
      item.createdAt = row.createdAt
      out.push(item)
    }
    return out
  }
}
