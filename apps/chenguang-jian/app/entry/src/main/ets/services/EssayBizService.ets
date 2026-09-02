import { HttpClient } from './HttpClient'
import {
  CatalogItem, CatalogListPayload, CatalogMapper, CatalogWire, DailyPayload, MsgListPayload, MsgWire
} from '../models/EssayModels'

export class EssayBizService {
  static async loadDaily(hour: number): Promise<DailyPayload> {
    const res = await HttpClient.get<DailyPayload>(`/biz/dawn-slip/daily?hour=${hour}`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    return new DailyPayload()
  }

  static quoteFromDaily(p: DailyPayload): CatalogItem | undefined {
    const w = p.quote
    if (w === undefined || w === null) {
      return undefined
    }
    const item = CatalogMapper.fromWire(w)
    if (item.id.length === 0) {
      return undefined
    }
    return item
  }

  static weatherTitle(p: DailyPayload): string {
    const w = p.weather
    if (w === undefined || w === null) {
      return ''
    }
    return CatalogMapper.fromWire(w).title
  }

  static async loadQuotes(): Promise<CatalogItem[]> {
    return EssayBizService.loadCatalog('/biz/dawn-slip/quotes')
  }

  static async findQuote(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/dawn-slip/quotes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogMapper.fromWire(res.data)
    }
    return undefined
  }

  static async loadTags(): Promise<string[]> {
    const items = await EssayBizService.loadCatalog('/biz/dawn-slip/tags')
    const out: string[] = []
    for (const it of items) {
      if (it.title.length > 0) {
        out.push(it.title)
      }
    }
    return out
  }

  static async findTag(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/dawn-slip/tags/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogMapper.fromWire(res.data)
    }
    return undefined
  }

  static async loadWeatherHints(): Promise<CatalogItem[]> {
    return EssayBizService.loadCatalog('/biz/dawn-slip/weather-hints')
  }

  static async findWeather(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/dawn-slip/weather-hints/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogMapper.fromWire(res.data)
    }
    return undefined
  }

  static async loadTagCatalog(): Promise<CatalogItem[]> {
    return EssayBizService.loadCatalog('/biz/dawn-slip/tags')
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
