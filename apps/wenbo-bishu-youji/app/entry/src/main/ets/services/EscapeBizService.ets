import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import {
  DestItem,
  DestListPayload,
  DestWire,
  FavoriteCreateRequest,
  FavoriteItem,
  FavoriteListPayload,
  FavoriteWire,
  GuideItem,
  GuideListPayload,
  GuideWire,
  JournalCreateRequest,
  JournalItem,
  JournalListPayload,
  JournalWire,
  MessageItem,
  MessageListPayload
} from '../models/EscapeModels'

export class EscapeBizService {
  static async loadDestinations(): Promise<DestItem[]> {
    const res = await HttpClient.get<DestListPayload>('/biz/cool-escape/destinations')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: DestItem[] = []
      for (const w of res.data.list) {
        out.push(DestItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findDest(id: string): Promise<DestItem | undefined> {
    const res = await HttpClient.get<DestWire>(`/biz/cool-escape/destinations/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return DestItem.fromWire(res.data)
    }
    const all = await EscapeBizService.loadDestinations()
    for (const d of all) {
      if (d.id === id) {
        return d
      }
    }
    return undefined
  }

  static async loadGuides(): Promise<GuideItem[]> {
    const res = await HttpClient.get<GuideListPayload>('/biz/cool-escape/guides')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: GuideItem[] = []
      for (const w of res.data.list) {
        out.push(GuideItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findGuide(id: string): Promise<GuideItem | undefined> {
    const res = await HttpClient.get<GuideWire>(`/biz/cool-escape/guides/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return GuideItem.fromWire(res.data)
    }
    const all = await EscapeBizService.loadGuides()
    for (const g of all) {
      if (g.id === id) {
        return g
      }
    }
    return undefined
  }

  static async loadJournals(): Promise<JournalItem[]> {
    const uid = AuthService.currentUsername()
    if (!AuthService.isLoggedIn()) {
      return []
    }
    const res = await HttpClient.get<JournalListPayload>(`/biz/cool-escape/journals?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: JournalItem[] = []
      for (const w of res.data.list) {
        out.push(JournalItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findJournal(id: string): Promise<JournalItem | undefined> {
    const uid = AuthService.currentUsername()
    const res = await HttpClient.get<JournalWire>(`/biz/cool-escape/journals/${id}?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined) {
      return JournalItem.fromWire(res.data)
    }
    const all = await EscapeBizService.loadJournals()
    for (const j of all) {
      if (j.id === id) {
        return j
      }
    }
    return undefined
  }

  static async createJournal(req: JournalCreateRequest): Promise<boolean> {
    req.userId = AuthService.currentUsername()
    const res = await HttpClient.post<JournalWire>('/biz/cool-escape/journals', req)
    return res.code === 0
  }

  static async deleteJournal(id: string): Promise<boolean> {
    const uid = AuthService.currentUsername()
    const res = await HttpClient.delete<JournalWire>(`/biz/cool-escape/journals/${id}?userId=${uid}`)
    return res.code === 0
  }

  static async loadFavorites(): Promise<FavoriteItem[]> {
    if (!AuthService.isLoggedIn()) {
      return []
    }
    const uid = AuthService.currentUsername()
    const res = await HttpClient.get<FavoriteListPayload>(`/biz/cool-escape/favorites?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: FavoriteItem[] = []
      for (const w of res.data.list) {
        out.push(FavoriteItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async addFavorite(kind: string, targetId: string, title: string, coverKey: string): Promise<boolean> {
    const req = new FavoriteCreateRequest()
    req.kind = kind
    req.targetId = targetId
    req.title = title
    req.coverKey = coverKey
    req.userId = AuthService.currentUsername()
    const res = await HttpClient.post<FavoriteWire>('/biz/cool-escape/favorites', req)
    return res.code === 0
  }

  static async removeFavorite(id: string): Promise<boolean> {
    const uid = AuthService.currentUsername()
    const res = await HttpClient.delete<FavoriteWire>(`/biz/cool-escape/favorites/${id}?userId=${uid}`)
    return res.code === 0
  }

  static async isFavored(targetId: string): Promise<boolean> {
    const list = await EscapeBizService.loadFavorites()
    for (const f of list) {
      if (f.targetId === targetId) {
        return true
      }
    }
    return false
  }

  static async toggleFavorite(kind: string, targetId: string, title: string, coverKey: string): Promise<boolean> {
    const list = await EscapeBizService.loadFavorites()
    for (const f of list) {
      if (f.targetId === targetId) {
        await EscapeBizService.removeFavorite(f.id)
        return false
      }
    }
    await EscapeBizService.addFavorite(kind, targetId, title, coverKey)
    return true
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

  static pickToday(list: DestItem[]): DestItem | undefined {
    if (list.length === 0) {
      return undefined
    }
    for (const d of list) {
      if (d.featured) {
        return d
      }
    }
    return list[0]
  }

  static filterByCategory(list: DestItem[], cat: string): DestItem[] {
    if (cat.length === 0 || cat === 'all') {
      return list
    }
    const out: DestItem[] = []
    for (const d of list) {
      if (d.category === cat) {
        out.push(d)
      }
    }
    return out
  }

  static searchDest(list: DestItem[], q: string): DestItem[] {
    const key = q.trim()
    if (key.length === 0) {
      return list
    }
    const out: DestItem[] = []
    for (const d of list) {
      if (d.title.indexOf(key) >= 0 || d.city.indexOf(key) >= 0 || d.summary.indexOf(key) >= 0) {
        out.push(d)
      }
    }
    return out
  }
}
