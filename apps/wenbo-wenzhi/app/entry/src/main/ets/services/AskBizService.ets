import { HttpClient } from './HttpClient'
import {
  CatalogListPayload, CatalogMapper, CatalogWire, CollectionSyncBody,
  InsightItem, MsgListPayload, MsgWire
} from '../models/AskModels'
import { AuthService } from './AuthService'

export class AskBizService {
  private static insightCache: InsightItem[] = []
  static async loadTopics(): Promise<InsightItem[]> {
    return AskBizService.loadList('/biz/wisdom-ask/topics')
  }

  static async loadInsights(): Promise<InsightItem[]> {
    if (AskBizService.insightCache.length > 0) {
      return AskBizService.insightCache
    }
    const list = await AskBizService.loadList('/biz/wisdom-ask/insights')
    AskBizService.insightCache = list
    return list
  }

  static async loadDaily(): Promise<InsightItem[]> {
    return AskBizService.loadList('/biz/wisdom-ask/daily')
  }

  static async search(query: string): Promise<InsightItem[]> {
    const all = await AskBizService.loadInsights()
    if (all.length === 0) {
      return []
    }
    return AskBizService.rank(all, query)
  }

  static rank(all: InsightItem[], query: string): InsightItem[] {
    const q = query.trim()
    if (q.length === 0) {
      return all
    }
    const hits: InsightItem[] = []
    for (const row of all) {
      const hay = `${row.title}${row.keywords}${row.tags}${row.summary}${row.body}${row.category}${row.topic}`
      if (hay.indexOf(q) >= 0 || q.indexOf(row.title) >= 0) {
        hits.push(row)
      }
    }
    if (hits.length > 0) {
      return hits
    }
    for (const row of all) {
      if (q.indexOf(row.category) >= 0 || row.category.indexOf(q) >= 0) {
        hits.push(row)
      }
    }
    if (hits.length > 0) {
      return hits
    }
    return all
  }

  static filterCategory(all: InsightItem[], category: string): InsightItem[] {
    if (category.length === 0 || category === '全部') {
      return all
    }
    const out: InsightItem[] = []
    for (const row of all) {
      if (row.category === category) {
        out.push(row)
      }
    }
    return out
  }

  static filterTopic(all: InsightItem[], topic: string): InsightItem[] {
    if (topic.length === 0 || topic === '全部') {
      return all
    }
    const out: InsightItem[] = []
    for (const row of all) {
      if (row.topic === topic) {
        out.push(row)
      }
    }
    return out
  }

  static quizPool(all: InsightItem[]): InsightItem[] {
    const out: InsightItem[] = []
    for (const row of all) {
      if (row.hasQuiz()) {
        out.push(row)
      }
    }
    return out
  }

  static async findInsight(id: string): Promise<InsightItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/wisdom-ask/insights/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogMapper.toInsight(res.data)
    }
    return undefined
  }

  static async findDaily(id: string): Promise<InsightItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/wisdom-ask/daily/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogMapper.toInsight(res.data)
    }
    return undefined
  }

  static async loadMessages(): Promise<MsgWire[]> {
    const res = await HttpClient.get<MsgListPayload>('/messages')
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async syncCollection(
    question: string,
    insight: InsightItem,
    folder: string,
    note: string
  ): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return
    }
    const body = new CollectionSyncBody()
    body.title = question
    body.question = question
    body.insightId = insight.id
    body.note = note
    body.folder = folder
    body.tags = insight.tags
    body.summary = insight.summary
    body.body = insight.body
    body.description = insight.description
    body.further = insight.further
    body.coverMedia = insight.coverKey
    body.userId = user
    await HttpClient.post<CatalogWire>('/biz/wisdom-ask/collections', body)
  }

  private static async loadList(path: string): Promise<InsightItem[]> {
    const res = await HttpClient.get<CatalogListPayload>(path)
    const out: InsightItem[] = []
    if (res.code === 0 && res.data !== undefined) {
      const wires = res.data.list
      if (wires !== undefined) {
        for (const w of wires) {
          out.push(CatalogMapper.toInsight(w))
        }
      }
    }
    return out
  }
}
