import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import {
  EmptyOk,
  FavoriteBody,
  FavoriteItem,
  FavoriteListPayload,
  FavoriteWire,
  MessageItem,
  MessageListPayload,
  MessageWire,
  TipItem,
  TipListPayload,
  TipWire,
  TrailItem,
  TrailListPayload,
  TrailWire,
  WikiItem,
  WikiListPayload,
  WikiWire
} from '../models/NqModels'

export class NqBizService {
  static async loadTrails(difficulty: string, mode: string): Promise<TrailItem[]> {
    let path = '/biz/mountain-explore/trails'
    if (difficulty.length > 0 && mode.length > 0) {
      path = `/biz/mountain-explore/trails?difficulty=${difficulty}&mode=${mode}`
    } else if (difficulty.length > 0) {
      path = `/biz/mountain-explore/trails?difficulty=${difficulty}`
    } else if (mode.length > 0) {
      path = `/biz/mountain-explore/trails?mode=${mode}`
    }
    const res = await HttpClient.get<TrailListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: TrailItem[] = []
      for (const w of res.data.list) {
        out.push(TrailItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findTrail(id: string): Promise<TrailItem | undefined> {
    const res = await HttpClient.get<TrailWire>(`/biz/mountain-explore/trails/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return TrailItem.fromWire(res.data)
    }
    const all = await NqBizService.loadTrails('', '')
    for (const t of all) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async loadTips(): Promise<TipItem[]> {
    const res = await HttpClient.get<TipListPayload>('/biz/mountain-explore/tips')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: TipItem[] = []
      for (const w of res.data.list) {
        out.push(TipItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findTip(id: string): Promise<TipItem | undefined> {
    const res = await HttpClient.get<TipWire>(`/biz/mountain-explore/tips/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return TipItem.fromWire(res.data)
    }
    const all = await NqBizService.loadTips()
    for (const t of all) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async loadArticles(category: string): Promise<WikiItem[]> {
    let path = '/biz/mountain-explore/articles'
    if (category.length > 0) {
      path = `/biz/mountain-explore/articles?category=${category}`
    }
    const res = await HttpClient.get<WikiListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: WikiItem[] = []
      for (const w of res.data.list) {
        out.push(WikiItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findWiki(id: string): Promise<WikiItem | undefined> {
    const res = await HttpClient.get<WikiWire>(`/biz/mountain-explore/articles/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return WikiItem.fromWire(res.data)
    }
    const all = await NqBizService.loadArticles('')
    for (const a of all) {
      if (a.id === id) {
        return a
      }
    }
    return undefined
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

  static async loadFavorites(): Promise<FavoriteItem[]> {
    const uid = AuthService.currentUsername()
    if (!AuthService.isLoggedIn() || uid === '未登录') {
      return []
    }
    const res = await HttpClient.get<FavoriteListPayload>(`/biz/mountain-explore/favorites?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: FavoriteItem[] = []
      for (const w of res.data.list) {
        out.push(FavoriteItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async addFavorite(title: string, kind: string, targetId: string): Promise<boolean> {
    const uid = AuthService.currentUsername()
    if (!AuthService.isLoggedIn() || uid === '未登录') {
      return false
    }
    const body = new FavoriteBody()
    body.userId = uid
    body.title = title
    body.targetKind = kind
    body.targetId = targetId
    const res = await HttpClient.post<FavoriteWire>('/biz/mountain-explore/favorites', body)
    return res.code === 0
  }

  static async removeFavorite(id: string): Promise<boolean> {
    const res = await HttpClient.delete<EmptyOk>(`/biz/mountain-explore/favorites/${id}`)
    return res.code === 0
  }

  /** 发现页分类：森林徒步 / 山川风光 / 湖泊湿地 / 星空观测 / 城市公园 */
  static discoverCategory(trail: TrailItem): string {
    const blob = `${trail.title}${trail.region}${trail.summary}${trail.tags.join('')}${trail.relatedWikiIds}`
    if (blob.indexOf('星') >= 0 || blob.indexOf('夜') >= 0 || blob.indexOf('银河') >= 0 ||
      blob.indexOf('polaris') >= 0 || blob.indexOf('milky') >= 0) {
      return 'star'
    }
    if (blob.indexOf('湖') >= 0 || blob.indexOf('湿') >= 0 || blob.indexOf('溪') >= 0 ||
      blob.indexOf('creek') >= 0 || blob.indexOf('lake') >= 0) {
      return 'lake'
    }
    if (blob.indexOf('公园') >= 0 || blob.indexOf('绿道') >= 0 || blob.indexOf('城市') >= 0) {
      return 'park'
    }
    if (blob.indexOf('林') >= 0 || blob.indexOf('竹') >= 0 || blob.indexOf('forest') >= 0 ||
      blob.indexOf('bamboo') >= 0) {
      return 'forest'
    }
    return 'mountain'
  }

  static filterByDiscoverCategory(trails: TrailItem[], cat: string): TrailItem[] {
    if (cat.length === 0) {
      return trails
    }
    const out: TrailItem[] = []
    for (const t of trails) {
      if (NqBizService.discoverCategory(t) === cat) {
        out.push(t)
      }
    }
    return out
  }

  static recommendTrails(all: TrailItem[], interest: string): TrailItem[] {
    const scored: TrailItem[] = []
    for (const t of all) {
      let score = 0
      const cat = NqBizService.discoverCategory(t)
      if (interest === 'forest' && cat === 'forest') {
        score += 3
      }
      if (interest === 'mountain' && cat === 'mountain') {
        score += 3
      }
      if (interest === 'lake' && cat === 'lake') {
        score += 3
      }
      if (interest === 'star' && cat === 'star') {
        score += 3
      }
      if (interest === 'park' && cat === 'park') {
        score += 3
      }
      if (t.rating >= 4.5) {
        score += 1
      }
      if (score > 0) {
        scored.push(t)
      }
    }
    if (scored.length === 0) {
      const fallback: TrailItem[] = []
      let n = 0
      for (const t of all) {
        if (n < 6) {
          fallback.push(t)
          n += 1
        }
      }
      return fallback
    }
    const out: TrailItem[] = []
    let n = 0
    for (const t of scored) {
      if (n < 6) {
        out.push(t)
        n += 1
      }
    }
    return out
  }

  static searchWiki(wikis: WikiItem[], q: string): WikiItem[] {
    const key = q.trim()
    const hit: WikiItem[] = []
    if (key.length === 0) {
      return hit
    }
    for (const w of wikis) {
      if (w.title.indexOf(key) >= 0 || w.summary.indexOf(key) >= 0 || w.category.indexOf(key) >= 0) {
        hit.push(w)
      }
    }
    return hit
  }

  static searchTips(tips: TipItem[], q: string): TipItem[] {
    const key = q.trim()
    const hit: TipItem[] = []
    if (key.length === 0) {
      return hit
    }
    for (const t of tips) {
      if (t.title.indexOf(key) >= 0 || t.summary.indexOf(key) >= 0) {
        hit.push(t)
      }
    }
    return hit
  }

  static todayTip(tips: TipItem[]): TipItem | undefined {
    if (tips.length === 0) {
      return undefined
    }
    const d = new Date()
    const idx = d.getDate() % tips.length
    let i = 0
    for (const t of tips) {
      if (i === idx) {
        return t
      }
      i += 1
    }
    return tips[0]
  }
}
