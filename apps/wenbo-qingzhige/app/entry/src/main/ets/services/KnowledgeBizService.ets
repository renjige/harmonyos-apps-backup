import { HttpClient } from './HttpClient'
import {
  CatalogItem, CatalogListPayload, CatalogMapper, CatalogWire,
  KnowledgeItem, KnowledgeSyncBody, MsgListPayload, MsgWire, SparkItem, SparkSyncBody
} from '../models/KnowledgeModels'
import { AuthService } from './AuthService'

export class KnowledgeBizService {
  static async loadCategories(): Promise<CatalogItem[]> {
    return KnowledgeBizService.loadCatalog('/biz/light-knowledge/categories')
  }

  static async loadFeatured(): Promise<CatalogItem[]> {
    return KnowledgeBizService.loadCatalog('/biz/light-knowledge/featured')
  }

  static async loadCovers(): Promise<CatalogItem[]> {
    return KnowledgeBizService.loadCatalog('/biz/light-knowledge/covers')
  }

  static async findFeatured(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/light-knowledge/featured/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogMapper.fromWire(res.data)
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

  static async syncKnowledge(item: KnowledgeItem): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return
    }
    const body = new KnowledgeSyncBody()
    body.title = item.title
    body.content = item.body
    body.category = item.category
    body.tags = item.tags
    body.coverKey = item.coverKey
    body.userId = user
    await HttpClient.post<CatalogWire>('/biz/light-knowledge/entries', body)
  }

  static async syncSpark(item: SparkItem): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const user = AuthService.currentUsername()
    if (user.length === 0 || user === '未登录') {
      return
    }
    const body = new SparkSyncBody()
    body.title = item.title
    body.content = item.body
    body.tags = item.tags
    body.userId = user
    await HttpClient.post<CatalogWire>('/biz/light-knowledge/sparks', body)
  }

  private static async loadCatalog(path: string): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListPayload>(path)
    const out: CatalogItem[] = []
    if (res.code === 0 && res.data !== undefined) {
      for (const w of res.data.list) {
        out.push(CatalogMapper.fromWire(w))
      }
    }
    return out
  }
}
