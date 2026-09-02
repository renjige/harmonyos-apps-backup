import { HttpClient } from './HttpClient'
import { CatalogItem, CatalogListPayload, CatalogMapper, CatalogWire, DailyPayload, MsgListPayload, MsgWire } from '../models/SlipModels'
import { MoodCatalog } from './MoodCatalog'

export class SlipBizService {
  static async loadDaily(): Promise<DailyPayload> {
    const res = await HttpClient.get<DailyPayload>('/biz/inspiration-slip/daily')
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    return new DailyPayload()
  }

  static async loadTags(): Promise<string[]> {
    const items = await SlipBizService.loadCatalog('/biz/inspiration-slip/tags')
    const out: string[] = []
    for (const it of items) {
      if (it.title.length > 0) {
        out.push(it.title)
      }
    }
    if (out.length === 0) {
      return MoodCatalog.defaultTags()
    }
    return out
  }

  static async loadTagItems(): Promise<CatalogItem[]> {
    return SlipBizService.loadCatalog('/biz/inspiration-slip/tags')
  }

  static async findTag(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/inspiration-slip/tags/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogMapper.fromWire(res.data)
    }
    return undefined
  }

  static async loadTemplates(): Promise<CatalogItem[]> {
    return SlipBizService.loadCatalog('/biz/inspiration-slip/templates')
  }

  static async findTemplate(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/inspiration-slip/templates/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogMapper.fromWire(res.data)
    }
    return undefined
  }

  static async loadQuotes(): Promise<CatalogItem[]> {
    return SlipBizService.loadCatalog('/biz/inspiration-slip/quotes')
  }

  static async findQuote(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/inspiration-slip/quotes/${id}`)
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
