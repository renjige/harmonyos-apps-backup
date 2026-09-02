import { HttpClient } from './HttpClient'
import {
  CottageItem,
  CottageKpi,
  CottageKpiPayload,
  CottageListData,
  CottageMessage,
  CottageMsgPayload,
  CottageWriteBody
} from '../models/CottageModels'

const BASE = '/biz/study-cottage'

export class CottageBizService {
  static async loadDomains(): Promise<CottageItem[]> {
    const res = await HttpClient.get<CottageListData>(`${BASE}/domains`)
    if (res.code === 0 && res.data !== undefined) {
      return CottageBizService.mapList(res.data.list)
    }
    return []
  }

  static async loadPaths(domain: string = ''): Promise<CottageItem[]> {
    let path = `${BASE}/paths`
    if (domain.length > 0) {
      path = `${path}?domain=${domain}`
    }
    const res = await HttpClient.get<CottageListData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return CottageBizService.mapList(res.data.list)
    }
    return []
  }

  static async findPath(id: string): Promise<CottageItem | undefined> {
    const res = await HttpClient.get<CottageItem>(`${BASE}/paths/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CottageBizService.mapItem(res.data)
    }
    const list = await CottageBizService.loadPaths()
    return CottageBizService.findIn(list, id)
  }

  static async loadLessons(pathId: string = ''): Promise<CottageItem[]> {
    let path = `${BASE}/lessons`
    if (pathId.length > 0) {
      path = `${path}?pathId=${pathId}`
    }
    const res = await HttpClient.get<CottageListData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return CottageBizService.mapList(res.data.list)
    }
    return []
  }

  static async findLesson(id: string): Promise<CottageItem | undefined> {
    const res = await HttpClient.get<CottageItem>(`${BASE}/lessons/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CottageBizService.mapItem(res.data)
    }
    const list = await CottageBizService.loadLessons()
    return CottageBizService.findIn(list, id)
  }

  static async loadCards(category: string = ''): Promise<CottageItem[]> {
    let path = `${BASE}/cards`
    if (category.length > 0) {
      path = `${path}?category=${category}`
    }
    const res = await HttpClient.get<CottageListData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return CottageBizService.mapList(res.data.list)
    }
    return []
  }

  static async findCard(id: string): Promise<CottageItem | undefined> {
    const res = await HttpClient.get<CottageItem>(`${BASE}/cards/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CottageBizService.mapItem(res.data)
    }
    const list = await CottageBizService.loadCards()
    return CottageBizService.findIn(list, id)
  }

  static async loadDaily(): Promise<CottageItem[]> {
    const res = await HttpClient.get<CottageListData>(`${BASE}/daily`)
    if (res.code === 0 && res.data !== undefined) {
      return CottageBizService.mapList(res.data.list)
    }
    return []
  }

  static async findDaily(id: string): Promise<CottageItem | undefined> {
    const res = await HttpClient.get<CottageItem>(`${BASE}/daily/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CottageBizService.mapItem(res.data)
    }
    const list = await CottageBizService.loadDaily()
    return CottageBizService.findIn(list, id)
  }

  static async ask(query: string): Promise<CottageItem[]> {
    let path = `${BASE}/qa`
    if (query.length > 0) {
      path = `${path}?q=${encodeURIComponent(query)}`
    }
    const res = await HttpClient.get<CottageListData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return CottageBizService.mapList(res.data.list)
    }
    return []
  }

  static async loadBadges(): Promise<CottageItem[]> {
    const res = await HttpClient.get<CottageListData>(`${BASE}/badges`)
    if (res.code === 0 && res.data !== undefined) {
      return CottageBizService.mapList(res.data.list)
    }
    return []
  }

  static async loadProgress(userId: string): Promise<CottageItem[]> {
    if (userId.length === 0) {
      return []
    }
    const res = await HttpClient.get<CottageListData>(`${BASE}/progress?userId=${encodeURIComponent(userId)}`)
    if (res.code === 0 && res.data !== undefined) {
      return CottageBizService.mapList(res.data.list)
    }
    return []
  }

  static async completeLesson(userId: string, lesson: CottageItem): Promise<boolean> {
    const body = new CottageWriteBody()
    body.userId = userId
    body.lessonId = lesson.id
    body.pathId = lesson.pathId
    body.title = lesson.title
    body.minutesLogged = lesson.minutes
    const res = await HttpClient.post<CottageItem>(`${BASE}/progress`, body)
    return res.code === 0
  }

  static async loadFavorites(userId: string): Promise<CottageItem[]> {
    if (userId.length === 0) {
      return []
    }
    const res = await HttpClient.get<CottageListData>(`${BASE}/favorites?userId=${encodeURIComponent(userId)}`)
    if (res.code === 0 && res.data !== undefined) {
      return CottageBizService.mapList(res.data.list)
    }
    return []
  }

  static async addFavorite(userId: string, card: CottageItem): Promise<boolean> {
    const body = new CottageWriteBody()
    body.userId = userId
    body.cardId = card.id
    body.title = card.title
    const res = await HttpClient.post<CottageItem>(`${BASE}/favorites`, body)
    return res.code === 0
  }

  static async removeFavorite(id: string): Promise<boolean> {
    const res = await HttpClient.delete<CottageItem>(`${BASE}/favorites/${id}`)
    return res.code === 0
  }

  static async loadMessages(): Promise<CottageMsgPayload> {
    const res = await HttpClient.get<CottageMsgPayload>(`${BASE}/messages`)
    const out = new CottageMsgPayload()
    out.list = []
    if (res.code === 0 && res.data !== undefined) {
      for (const m of res.data.list) {
        const msg = new CottageMessage()
        msg.id = m.id ?? ''
        msg.title = m.title ?? ''
        msg.body = m.body ?? ''
        msg.createdAt = m.createdAt ?? ''
        out.list.push(msg)
      }
    }
    return out
  }

  static async loadKpis(): Promise<CottageKpiPayload> {
    const res = await HttpClient.get<CottageKpiPayload>(`${BASE}/kpis`)
    const out = new CottageKpiPayload()
    out.list = []
    if (res.code === 0 && res.data !== undefined) {
      for (const k of res.data.list) {
        const row = new CottageKpi()
        row.key = k.key ?? ''
        row.label = k.label ?? ''
        row.value = `${k.value ?? ''}`
        out.list.push(row)
      }
    }
    return out
  }

  static findIn(list: CottageItem[], id: string): CottageItem | undefined {
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static pickToday(list: CottageItem[]): CottageItem {
    if (list.length === 0) {
      return new CottageItem()
    }
    const idx = new Date().getDate() % list.length
    return list[idx]
  }

  private static mapList(raw: CottageItem[]): CottageItem[] {
    const out: CottageItem[] = []
    for (const r of raw) {
      out.push(CottageBizService.mapItem(r))
    }
    return out
  }

  private static mapItem(r: CottageItem): CottageItem {
    const item = new CottageItem()
    item.id = r.id ?? ''
    item.title = r.title ?? ''
    item.subtitle = r.subtitle ?? ''
    item.summary = r.summary ?? ''
    item.body = r.body ?? ''
    item.description = r.description ?? r.body ?? ''
    item.coverKey = r.coverKey ?? ''
    item.category = r.category ?? r.domain ?? ''
    item.categoryLabel = r.categoryLabel ?? ''
    item.tags = r.tags ?? ''
    item.pathId = r.pathId ?? ''
    item.domain = r.domain ?? r.category ?? ''
    item.days = r.days ?? 0
    item.minutes = r.minutes ?? 0
    item.difficulty = r.difficulty ?? ''
    item.keywords = r.keywords ?? ''
    item.disclaimer = r.disclaimer ?? '仅供参考，建议进一步核实。'
    item.lessonId = r.lessonId ?? ''
    item.cardId = r.cardId ?? ''
    item.minutesLogged = r.minutesLogged ?? 0
    item.sortOrder = r.sortOrder ?? 0
    item.createdAt = r.createdAt ?? ''
    return item
  }
}
