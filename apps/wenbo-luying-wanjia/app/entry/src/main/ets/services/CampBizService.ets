import { HttpClient } from './HttpClient'
import {
  CampWriteRequest,
  CatalogItem,
  CatalogListPayload,
  CatalogWire,
  MessageItem,
  MessageListPayload,
  MessageWire
} from '../models/CampModels'

export class CampBizService {
  static username(): string {
    return AppStorage.get<string>('currentUsername') ?? ''
  }

  static mapList(list: CatalogWire[]): CatalogItem[] {
    const out: CatalogItem[] = []
    for (const w of list) {
      out.push(CatalogItem.fromWire(w))
    }
    return out
  }

  static async loadCamps(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListPayload>('/biz/camp-player/camps')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return CampBizService.mapList(res.data.list)
    }
    return []
  }

  static async findCamp(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/camp-player/camps/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogItem.fromWire(res.data)
    }
    const all = await CampBizService.loadCamps()
    for (const r of all) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async loadTemplates(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListPayload>('/biz/camp-player/templates')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return CampBizService.mapList(res.data.list)
    }
    return []
  }

  static async findTemplate(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/camp-player/templates/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogItem.fromWire(res.data)
    }
    const all = await CampBizService.loadTemplates()
    for (const r of all) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async loadGuides(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListPayload>('/biz/camp-player/guides')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return CampBizService.mapList(res.data.list)
    }
    return []
  }

  static async findGuide(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/camp-player/guides/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogItem.fromWire(res.data)
    }
    const all = await CampBizService.loadGuides()
    for (const r of all) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async loadWeather(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListPayload>('/biz/camp-player/weather')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return CampBizService.mapList(res.data.list)
    }
    return []
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

  static async loadMine(path: string): Promise<CatalogItem[]> {
    const uid = CampBizService.username()
    const q = uid.length > 0 ? `?userId=${encodeURIComponent(uid)}` : ''
    const res = await HttpClient.get<CatalogListPayload>(`/biz/camp-player/${path}${q}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return CampBizService.mapList(res.data.list)
    }
    return []
  }

  static async create(path: string, body: CampWriteRequest): Promise<boolean> {
    body.userId = CampBizService.username()
    const res = await HttpClient.post<CatalogWire>(`/biz/camp-player/${path}`, body)
    return res.code === 0
  }

  static async update(path: string, id: string, body: CampWriteRequest): Promise<boolean> {
    body.userId = CampBizService.username()
    const res = await HttpClient.put<CatalogWire>(`/biz/camp-player/${path}/${id}`, body)
    return res.code === 0
  }

  static async remove(path: string, id: string): Promise<boolean> {
    const res = await HttpClient.delete<CatalogWire>(`/biz/camp-player/${path}/${id}`)
    return res.code === 0
  }

  static async findTrip(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/camp-player/trips/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogItem.fromWire(res.data)
    }
    return undefined
  }

  static async findJournal(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/camp-player/journals/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogItem.fromWire(res.data)
    }
    return undefined
  }

  static async findPost(id: string): Promise<CatalogItem | undefined> {
    const res = await HttpClient.get<CatalogWire>(`/biz/camp-player/posts/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CatalogItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadPosts(): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListPayload>('/biz/camp-player/posts')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return CampBizService.mapList(res.data.list)
    }
    return []
  }

  static async loadComments(guideId: string): Promise<CatalogItem[]> {
    const q = guideId.length > 0 ? `?guideId=${encodeURIComponent(guideId)}` : ''
    const res = await HttpClient.get<CatalogListPayload>(`/biz/camp-player/comments${q}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return CampBizService.mapList(res.data.list)
    }
    return []
  }
}
