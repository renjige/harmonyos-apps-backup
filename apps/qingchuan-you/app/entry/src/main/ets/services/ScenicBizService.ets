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
  InspItem,
  InspListPayload,
  InspWire,
  MessageItem,
  MessageListPayload,
  NoteCreateRequest,
  NoteItem,
  NoteListPayload,
  NoteWire,
  TripCreateRequest,
  TripItem,
  TripListPayload,
  TripWire
} from '../models/ScenicModels'

export class ScenicBizService {
  static async loadDestinations(): Promise<DestItem[]> {
    const res = await HttpClient.get<DestListPayload>('/biz/scenic-travel/destinations')
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
    const res = await HttpClient.get<DestWire>(`/biz/scenic-travel/destinations/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return DestItem.fromWire(res.data)
    }
    const all = await ScenicBizService.loadDestinations()
    for (const d of all) {
      if (d.id === id) {
        return d
      }
    }
    return undefined
  }

  static wisdomRecommend(list: DestItem[]): DestItem[] {
    const month = new Date().getMonth() + 1
    const hit: DestItem[] = []
    const rest: DestItem[] = []
    for (const d of list) {
      const hint = `,${d.seasonHint},`
      if (hint.indexOf(`,${month},`) >= 0) {
        hit.push(d)
      } else if (d.featured) {
        hit.push(d)
      } else {
        rest.push(d)
      }
    }
    const out: DestItem[] = []
    for (const d of hit) {
      out.push(d)
    }
    for (const d of rest) {
      out.push(d)
    }
    if (out.length > 5) {
      return out.slice(0, 5)
    }
    return out
  }

  static featuredBanners(list: DestItem[]): DestItem[] {
    const out: DestItem[] = []
    for (const d of list) {
      if (d.featured) {
        out.push(d)
      }
    }
    if (out.length === 0) {
      return list.slice(0, 3)
    }
    return out
  }

  static filterByCategory(list: DestItem[], cat: string): DestItem[] {
    if (cat === 'all' || cat.length === 0) {
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
    const k = q.trim()
    if (k.length === 0) {
      return list
    }
    const out: DestItem[] = []
    for (const d of list) {
      if (d.title.indexOf(k) >= 0 || d.city.indexOf(k) >= 0 || d.summary.indexOf(k) >= 0) {
        out.push(d)
      }
    }
    return out
  }

  static async loadInspirations(): Promise<InspItem[]> {
    const res = await HttpClient.get<InspListPayload>('/biz/scenic-travel/inspirations')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: InspItem[] = []
      for (const w of res.data.list) {
        out.push(InspItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findInsp(id: string): Promise<InspItem | undefined> {
    const res = await HttpClient.get<InspWire>(`/biz/scenic-travel/inspirations/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return InspItem.fromWire(res.data)
    }
    const all = await ScenicBizService.loadInspirations()
    for (const g of all) {
      if (g.id === id) {
        return g
      }
    }
    return undefined
  }

  static async loadNotes(): Promise<NoteItem[]> {
    const res = await HttpClient.get<NoteListPayload>('/biz/scenic-travel/notes')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: NoteItem[] = []
      for (const w of res.data.list) {
        out.push(NoteItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findNote(id: string): Promise<NoteItem | undefined> {
    const res = await HttpClient.get<NoteWire>(`/biz/scenic-travel/notes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return NoteItem.fromWire(res.data)
    }
    const all = await ScenicBizService.loadNotes()
    for (const n of all) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static async createNote(req: NoteCreateRequest): Promise<boolean> {
    req.userId = AuthService.currentUsername()
    req.userName = AuthService.currentUsername()
    const res = await HttpClient.post<NoteWire>('/biz/scenic-travel/notes', req)
    return res.code === 0
  }

  static async likeNote(id: string): Promise<boolean> {
    const res = await HttpClient.post<NoteWire>(`/biz/scenic-travel/notes/${id}/like`, new NoteCreateRequest())
    return res.code === 0
  }

  static async loadTrips(): Promise<TripItem[]> {
    if (!AuthService.isLoggedIn()) {
      return []
    }
    const uid = AuthService.currentUsername()
    const res = await HttpClient.get<TripListPayload>(`/biz/scenic-travel/trips?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: TripItem[] = []
      for (const w of res.data.list) {
        out.push(TripItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findTrip(id: string): Promise<TripItem | undefined> {
    const uid = AuthService.currentUsername()
    const res = await HttpClient.get<TripWire>(`/biz/scenic-travel/trips/${id}?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined) {
      return TripItem.fromWire(res.data)
    }
    const all = await ScenicBizService.loadTrips()
    for (const t of all) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async createTrip(req: TripCreateRequest): Promise<boolean> {
    req.userId = AuthService.currentUsername()
    const res = await HttpClient.post<TripWire>('/biz/scenic-travel/trips', req)
    return res.code === 0
  }

  static async deleteTrip(id: string): Promise<boolean> {
    const uid = AuthService.currentUsername()
    const res = await HttpClient.delete<TripWire>(`/biz/scenic-travel/trips/${id}?userId=${uid}`)
    return res.code === 0
  }

  static async loadFavorites(): Promise<FavoriteItem[]> {
    if (!AuthService.isLoggedIn()) {
      return []
    }
    const uid = AuthService.currentUsername()
    const res = await HttpClient.get<FavoriteListPayload>(`/biz/scenic-travel/favorites?userId=${uid}`)
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
    const res = await HttpClient.post<FavoriteWire>('/biz/scenic-travel/favorites', req)
    return res.code === 0
  }

  static async removeFavorite(id: string): Promise<boolean> {
    const uid = AuthService.currentUsername()
    const res = await HttpClient.delete<FavoriteWire>(`/biz/scenic-travel/favorites/${id}?userId=${uid}`)
    return res.code === 0
  }

  static async isFavored(targetId: string): Promise<boolean> {
    const list = await ScenicBizService.loadFavorites()
    for (const f of list) {
      if (f.targetId === targetId) {
        return true
      }
    }
    return false
  }

  static async toggleFavorite(kind: string, targetId: string, title: string, coverKey: string): Promise<boolean> {
    const list = await ScenicBizService.loadFavorites()
    for (const f of list) {
      if (f.targetId === targetId) {
        await ScenicBizService.removeFavorite(f.id)
        return false
      }
    }
    await ScenicBizService.addFavorite(kind, targetId, title, coverKey)
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
}
