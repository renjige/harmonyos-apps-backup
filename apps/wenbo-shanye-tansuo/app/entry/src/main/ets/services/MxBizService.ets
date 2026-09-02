import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import {
  EmptyOk,
  FavoriteBody,
  FavoriteItem,
  FavoriteListPayload,
  FavoriteWire,
  FootprintBody,
  FootprintItem,
  FootprintListPayload,
  FootprintWire,
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
} from '../models/MxModels'

export class MxBizService {
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
    const all = await MxBizService.loadTrails('', '')
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
    const all = await MxBizService.loadTips()
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
    const all = await MxBizService.loadArticles('')
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

  static async loadFootprints(): Promise<FootprintItem[]> {
    const uid = AuthService.currentUsername()
    if (!AuthService.isLoggedIn() || uid === '未登录') {
      return []
    }
    const res = await HttpClient.get<FootprintListPayload>(`/biz/mountain-explore/footprints?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: FootprintItem[] = []
      for (const w of res.data.list) {
        out.push(FootprintItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async markFootprint(trail: TrailItem, remark: string): Promise<boolean> {
    const uid = AuthService.currentUsername()
    if (!AuthService.isLoggedIn() || uid === '未登录') {
      return false
    }
    const body = new FootprintBody()
    body.userId = uid
    body.title = trail.title
    body.trailId = trail.id
    const d = new Date()
    body.completedAt = `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
    body.remark = remark
    const res = await HttpClient.post<FootprintWire>('/biz/mountain-explore/footprints', body)
    return res.code === 0
  }

  static async removeFootprint(id: string): Promise<boolean> {
    const res = await HttpClient.delete<EmptyOk>(`/biz/mountain-explore/footprints/${id}`)
    return res.code === 0
  }

  /** 规则匹配：按难度 / 兴趣 / 时长筛 3–5 条，非生成式 */
  static matchTrails(all: TrailItem[], difficulty: string, interest: string, duration: string): TrailItem[] {
    const scored: TrailItem[] = []
    for (const t of all) {
      let score = 0
      if (difficulty.length > 0 && t.difficulty === difficulty) {
        score += 3
      }
      if (duration === 'short' && t.durationHours <= 3) {
        score += 2
      }
      if (duration === 'half' && t.durationHours > 2 && t.durationHours <= 5) {
        score += 2
      }
      if (duration === 'long' && t.durationHours > 5) {
        score += 2
      }
      if (interest === '植物' && t.relatedWikiIds.indexOf('wiki-') >= 0 &&
        (t.relatedWikiIds.indexOf('pine') >= 0 || t.relatedWikiIds.indexOf('bamboo') >= 0 ||
          t.relatedWikiIds.indexOf('flower') >= 0 || t.relatedWikiIds.indexOf('moss') >= 0)) {
        score += 2
      }
      if (interest === '地质' && (t.relatedWikiIds.indexOf('granite') >= 0 ||
        t.relatedWikiIds.indexOf('quartz') >= 0 || t.relatedWikiIds.indexOf('danxia') >= 0 ||
        t.relatedWikiIds.indexOf('glacial') >= 0 || t.relatedWikiIds.indexOf('sandstone') >= 0)) {
        score += 2
      }
      if (interest === '天文' && (t.relatedWikiIds.indexOf('polaris') >= 0 ||
        t.relatedWikiIds.indexOf('orion') >= 0 || t.relatedWikiIds.indexOf('milky') >= 0 ||
        t.relatedWikiIds.indexOf('cloud') >= 0)) {
        score += 2
      }
      if (interest === '动物' && (t.relatedWikiIds.indexOf('fox') >= 0 ||
        t.relatedWikiIds.indexOf('woodpecker') >= 0 || t.relatedWikiIds.indexOf('macaque') >= 0)) {
        score += 2
      }
      if (score > 0) {
        scored.push(t)
      }
    }
    if (scored.length === 0) {
      const fallback: TrailItem[] = []
      let n = 0
      for (const t of all) {
        if (n < 4) {
          fallback.push(t)
          n += 1
        }
      }
      return fallback
    }
    const out: TrailItem[] = []
    let n = 0
    for (const t of scored) {
      if (n < 5) {
        out.push(t)
        n += 1
      }
    }
    return out
  }

  static search(trails: TrailItem[], tips: TipItem[], wikis: WikiItem[], q: string): TrailItem[] {
    const key = q.trim()
    const hit: TrailItem[] = []
    if (key.length === 0) {
      return hit
    }
    for (const t of trails) {
      if (t.title.indexOf(key) >= 0 || t.region.indexOf(key) >= 0 || t.summary.indexOf(key) >= 0) {
        hit.push(t)
      }
    }
    return hit
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
