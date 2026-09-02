import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import {
  AchieveItem,
  AchieveListData,
  ArticleItem,
  ArticleListData,
  BrainMappers,
  DrillItem,
  DrillListData,
  MsgItem,
  MsgListData,
  ProbeItem,
  ProbeListData,
  SessionRequest
} from '../models/BrainModels'

const BASE = '/biz/brain-explore'

export class BrainBizService {
  private static drills: DrillItem[] = []
  private static articles: ArticleItem[] = []
  private static achieves: AchieveItem[] = []

  static lastHint(): string {
    if (HttpClient.lastError.length > 0) {
      return HttpClient.lastError
    }
    return '请检查网络后重试。训练进度仍保存在本机。'
  }

  static async loadDrills(): Promise<DrillItem[]> {
    const res = await HttpClient.get<DrillListData>(`${BASE}/drills`)
    if (res.code === 0 && res.data !== undefined) {
      const list: DrillItem[] = []
      for (const row of res.data.list) {
        list.push(BrainMappers.drill(row))
      }
      BrainBizService.drills = list
      return list
    }
    if (res.message.length > 0) {
      HttpClient.lastError = res.message
    }
    return []
  }

  static findDrill(id: string): DrillItem | undefined {
    for (const d of BrainBizService.drills) {
      if (d.id === id) {
        return d
      }
    }
    return undefined
  }

  static async resolveDrill(id: string): Promise<DrillItem | undefined> {
    const local = BrainBizService.findDrill(id)
    if (local !== undefined) {
      return local
    }
    const res = await HttpClient.get<DrillItem>(`${BASE}/drills/${id}`)
    if (res.code === 0 && res.data !== undefined && res.data.id.length > 0) {
      return BrainMappers.drill(res.data)
    }
    return undefined
  }

  static async loadArticles(): Promise<ArticleItem[]> {
    const res = await HttpClient.get<ArticleListData>(`${BASE}/articles`)
    if (res.code === 0 && res.data !== undefined) {
      const list: ArticleItem[] = []
      for (const row of res.data.list) {
        list.push(BrainMappers.article(row))
      }
      BrainBizService.articles = list
      return list
    }
    if (res.message.length > 0) {
      HttpClient.lastError = res.message
    }
    return []
  }

  static findArticle(id: string): ArticleItem | undefined {
    for (const a of BrainBizService.articles) {
      if (a.id === id) {
        return a
      }
    }
    return undefined
  }

  static async resolveArticle(id: string): Promise<ArticleItem | undefined> {
    const local = BrainBizService.findArticle(id)
    if (local !== undefined) {
      return local
    }
    const res = await HttpClient.get<ArticleItem>(`${BASE}/articles/${id}`)
    if (res.code === 0 && res.data !== undefined && res.data.id.length > 0) {
      return BrainMappers.article(res.data)
    }
    return undefined
  }

  static async loadAchievements(): Promise<AchieveItem[]> {
    const res = await HttpClient.get<AchieveListData>(`${BASE}/achievements`)
    if (res.code === 0 && res.data !== undefined) {
      const list: AchieveItem[] = []
      for (const row of res.data.list) {
        list.push(BrainMappers.achieve(row))
      }
      BrainBizService.achieves = list
      return list
    }
    if (res.message.length > 0) {
      HttpClient.lastError = res.message
    }
    return []
  }

  static findAchieve(id: string): AchieveItem | undefined {
    for (const a of BrainBizService.achieves) {
      if (a.id === id) {
        return a
      }
    }
    return undefined
  }

  static async resolveAchieve(id: string): Promise<AchieveItem | undefined> {
    const local = BrainBizService.findAchieve(id)
    if (local !== undefined) {
      return local
    }
    const res = await HttpClient.get<AchieveItem>(`${BASE}/achievements/${id}`)
    if (res.code === 0 && res.data !== undefined && res.data.id.length > 0) {
      return BrainMappers.achieve(res.data)
    }
    return undefined
  }

  static async loadProbes(): Promise<ProbeItem[]> {
    const res = await HttpClient.get<ProbeListData>(`${BASE}/probes`)
    if (res.code === 0 && res.data !== undefined) {
      const list: ProbeItem[] = []
      for (const row of res.data.list) {
        list.push(BrainMappers.probe(row))
      }
      return list
    }
    if (res.message.length > 0) {
      HttpClient.lastError = res.message
    }
    return []
  }

  static async loadMessages(): Promise<MsgItem[]> {
    const res = await HttpClient.get<MsgListData>('/messages')
    if (res.code === 0 && res.data !== undefined) {
      const list: MsgItem[] = []
      for (const row of res.data.list) {
        list.push(BrainMappers.message(row))
      }
      return list
    }
    if (res.message.length > 0) {
      HttpClient.lastError = res.message
    }
    return []
  }

  static async postSession(drillId: string, gameType: string, score: number, durationSec: number, title: string): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const body = new SessionRequest()
    body.drillId = drillId
    body.gameType = gameType
    body.score = score
    body.durationSec = durationSec
    body.dateKey = BrainBizService.todayKey()
    body.username = AppStorage.get<string>('currentUsername') ?? ''
    body.title = title
    await HttpClient.post<SessionRequest>(`${BASE}/sessions`, body)
  }

  private static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }
}
