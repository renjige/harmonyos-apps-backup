import { HttpClient } from './HttpClient'
import { CatalogItem, CatalogListPayload, CatalogMapper, CatalogWire, DailyPayload, MsgListPayload, MsgWire } from '../models/NoteModels'
import { MoodCatalog } from './MoodCatalog'

export class HeartNoteBizService {
  static async loadDaily(): Promise<DailyPayload> {
    const res = await HttpClient.get<DailyPayload>('/biz/heart-note/daily')
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    return new DailyPayload()
  }

  static async loadPrompts(): Promise<CatalogItem[]> {
    return HeartNoteBizService.loadCatalog('/biz/heart-note/prompts')
  }

  static async findPrompt(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/heart-note/prompts/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogMapper.fromWire(res.data)
    }
    return undefined
  }

  static async loadTags(): Promise<string[]> {
    const items = await HeartNoteBizService.loadCatalog('/biz/heart-note/tags')
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

  static async loadQuotes(): Promise<CatalogItem[]> {
    return HeartNoteBizService.loadCatalog('/biz/heart-note/quotes')
  }

  static async findQuote(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/heart-note/quotes/${id}`)
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
