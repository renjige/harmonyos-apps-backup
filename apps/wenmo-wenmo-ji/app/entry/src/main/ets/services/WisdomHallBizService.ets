import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import {
  FavoriteCreateBody,
  HistoryCreateBody,
  KpiListPayload,
  KpiWire,
  LikeFeaturedBody,
  LikeFeaturedPayload,
  MsgListPayload,
  MsgWire,
  QuotesPayload,
  ThoughtCreateBody,
  ThoughtUpdateBody,
  WisdomItem,
  WisdomListPayload,
  WisdomMapper,
  WisdomWire
} from '../models/WisdomHallModels'

export class AuthorRow {
  name: string = ''
  count: number = 0
}

export class WisdomHallBizService {
  static async loadAllQuotes(): Promise<WisdomItem[]> {
    const res = await HttpClient.get<QuotesPayload>('/biz/wisdom-hall/quotes')
    if (res.code === 0 && res.data !== undefined) {
      return WisdomMapper.mapList(res.data.list)
    }
    return []
  }

  static filterQuotes(all: WisdomItem[], category: string, keyword: string, author: string = ''): WisdomItem[] {
    const out: WisdomItem[] = []
    const kw = keyword.trim().toLowerCase()
    const authorKw = author.trim()
    for (const item of all) {
      if (category.length > 0 && category !== '全部' && item.category !== category) {
        continue
      }
      if (authorKw.length > 0 && item.authorName !== authorKw) {
        continue
      }
      if (kw.length > 0) {
        const hay = `${item.title}${item.authorName}${item.summary}${item.body}`.toLowerCase()
        if (hay.indexOf(kw) < 0) {
          continue
        }
      }
      out.push(item)
    }
    return out
  }

  static extractAuthors(all: WisdomItem[]): AuthorRow[] {
    const rows: AuthorRow[] = []
    for (const item of all) {
      const name = item.authorName.trim()
      if (name.length === 0) {
        continue
      }
      let matched: AuthorRow | undefined = undefined
      for (const row of rows) {
        if (row.name === name) {
          row.count += 1
          matched = row
          break
        }
      }
      if (matched === undefined) {
        const row = new AuthorRow()
        row.name = name
        row.count = 1
        rows.push(row)
      }
    }
    return WisdomHallBizService.sortAuthorsByCount(rows)
  }

  private static sortAuthorsByCount(input: AuthorRow[]): AuthorRow[] {
    let pending: AuthorRow[] = []
    for (const row of input) {
      pending.push(row)
    }
    const sorted: AuthorRow[] = []
    while (pending.length > 0) {
      let best: AuthorRow | undefined = undefined
      const rest: AuthorRow[] = []
      for (const row of pending) {
        if (best === undefined || row.count > best.count) {
          if (best !== undefined) {
            rest.push(best)
          }
          best = row
        } else {
          rest.push(row)
        }
      }
      if (best !== undefined) {
        sorted.push(best)
      }
      pending = rest
    }
    return sorted
  }

  static async loadQuotesToday(): Promise<WisdomItem | undefined> {
    const res = await HttpClient.get<QuotesPayload>('/biz/wisdom-hall/quotes')
    if (res.code === 0 && res.data !== undefined && res.data.today.id.length > 0) {
      return WisdomMapper.fromWire(res.data.today)
    }
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      return WisdomMapper.fromWire(res.data.list[0])
    }
    return undefined
  }

  static async loadTopics(): Promise<WisdomItem[]> {
    return WisdomHallBizService.loadList('/biz/wisdom-hall/topics')
  }

  static async loadReads(): Promise<WisdomItem[]> {
    return WisdomHallBizService.loadList('/biz/wisdom-hall/reads')
  }

  static async loadFeatured(): Promise<WisdomItem[]> {
    return WisdomHallBizService.loadList('/biz/wisdom-hall/featured')
  }

  static async loadTags(): Promise<WisdomItem[]> {
    return WisdomHallBizService.loadList('/biz/wisdom-hall/tags')
  }

  static async loadFriends(): Promise<WisdomItem[]> {
    return WisdomHallBizService.loadList('/biz/wisdom-hall/friends')
  }

  static async loadThoughts(): Promise<WisdomItem[]> {
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return []
    }
    const path = `/biz/wisdom-hall/thoughts?userId=${encodeURIComponent(user)}`
    return WisdomHallBizService.loadList(path)
  }

  static async loadFavorites(): Promise<WisdomItem[]> {
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return []
    }
    const path = `/biz/wisdom-hall/favorites?userId=${encodeURIComponent(user)}`
    return WisdomHallBizService.loadList(path)
  }

  static async loadHistory(): Promise<WisdomItem[]> {
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return []
    }
    const path = `/biz/wisdom-hall/history?userId=${encodeURIComponent(user)}`
    return WisdomHallBizService.loadList(path)
  }

  static async loadMessages(): Promise<MsgWire[]> {
    const res = await HttpClient.get<MsgListPayload>('/biz/wisdom-hall/messages')
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadKpis(): Promise<KpiWire[]> {
    const res = await HttpClient.get<KpiListPayload>('/biz/wisdom-hall/kpis')
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async findQuote(id: string): Promise<WisdomItem | undefined> {
    return WisdomHallBizService.findOne('/biz/wisdom-hall/quotes', id)
  }

  static async findRead(id: string): Promise<WisdomItem | undefined> {
    return WisdomHallBizService.findOne('/biz/wisdom-hall/reads', id)
  }

  static async findTopic(id: string): Promise<WisdomItem | undefined> {
    return WisdomHallBizService.findOne('/biz/wisdom-hall/topics', id)
  }

  static async findFeatured(id: string): Promise<WisdomItem | undefined> {
    return WisdomHallBizService.findOne('/biz/wisdom-hall/featured', id)
  }

  static async findThought(id: string): Promise<WisdomItem | undefined> {
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return undefined
    }
    const path = `/biz/wisdom-hall/thoughts/${id}?userId=${encodeURIComponent(user)}`
    return WisdomHallBizService.findOne(path, '')
  }

  static async createThought(title: string, body: string, tag: string): Promise<WisdomItem | undefined> {
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return undefined
    }
    const req = new ThoughtCreateBody()
    req.title = title.trim()
    req.body = body.trim()
    req.content = body.trim()
    req.category = tag.length > 0 ? tag : '其他'
    req.tags = tag
    req.userId = user
    const res = await HttpClient.post<WisdomWire>('/biz/wisdom-hall/thoughts', req)
    if (res.code === 0 && res.data !== undefined) {
      WisdomHallBizService.bumpRefresh()
      return WisdomMapper.fromWire(res.data)
    }
    return undefined
  }

  static async updateThought(id: string, title: string, body: string, tag: string): Promise<boolean> {
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return false
    }
    const req = new ThoughtUpdateBody()
    req.title = title.trim()
    req.body = body.trim()
    req.content = body.trim()
    req.category = tag.length > 0 ? tag : '其他'
    req.tags = tag
    req.userId = user
    const res = await HttpClient.put<WisdomWire>(`/biz/wisdom-hall/thoughts/${id}`, req)
    if (res.code === 0) {
      WisdomHallBizService.bumpRefresh()
      return true
    }
    return false
  }

  static async deleteThought(id: string): Promise<boolean> {
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return false
    }
    const path = `/biz/wisdom-hall/thoughts/${id}?userId=${encodeURIComponent(user)}`
    const res = await HttpClient.delete<WisdomWire>(path)
    if (res.code === 0) {
      WisdomHallBizService.bumpRefresh()
      return true
    }
    return false
  }

  static async likeFeatured(id: string): Promise<LikeFeaturedPayload | undefined> {
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return undefined
    }
    const body = new LikeFeaturedBody()
    body.userId = user
    const res = await HttpClient.post<LikeFeaturedPayload>(`/biz/wisdom-hall/featured/${id}/like`, body)
    if (res.code === 0 && res.data !== undefined) {
      WisdomHallBizService.bumpRefresh()
      return res.data
    }
    return undefined
  }

  static async addFavorite(targetKind: string, targetId: string, title: string): Promise<boolean> {
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return false
    }
    const body = new FavoriteCreateBody()
    body.userId = user
    body.title = title
    body.targetKind = targetKind
    body.targetId = targetId
    const res = await HttpClient.post<WisdomWire>('/biz/wisdom-hall/favorites', body)
    if (res.code === 0) {
      WisdomHallBizService.bumpRefresh()
      return true
    }
    return false
  }

  static async recordHistory(targetKind: string, targetId: string, title: string): Promise<boolean> {
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return false
    }
    const body = new HistoryCreateBody()
    body.userId = user
    body.title = title
    body.targetKind = targetKind
    body.targetId = targetId
    body.action = 'read'
    const res = await HttpClient.post<WisdomWire>('/biz/wisdom-hall/history', body)
    return res.code === 0
  }

  static bumpRefresh(): void {
    const cur = AppStorage.get<number>('whRefresh') ?? 0
    AppStorage.setOrCreate('whRefresh', cur + 1)
  }

  private static async loadList(path: string): Promise<WisdomItem[]> {
    const res = await HttpClient.get<WisdomListPayload>(path)
    if (res.code === 0 && res.data !== undefined) {
      return WisdomMapper.mapList(res.data.list)
    }
    return []
  }

  private static async findOne(basePath: string, id: string): Promise<WisdomItem | undefined> {
    const path = id.length > 0 ? `${basePath}/${id}` : basePath
    const res = await HttpClient.get<WisdomWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return WisdomMapper.fromWire(res.data)
    }
    return undefined
  }
}
