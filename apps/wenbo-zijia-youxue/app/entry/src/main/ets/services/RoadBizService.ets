import { HttpClient } from './HttpClient'
import {
  MessageItem,
  MessageListPayload,
  QuizItem,
  QuizListPayload,
  QuizWire,
  RecordItem,
  RecordListPayload,
  RecordWire,
  RouteItem,
  RouteListPayload,
  RouteWire,
  SpotItem,
  SpotListPayload,
  SpotWire,
  StudyWriteRequest,
  WeatherItem,
  WeatherListPayload
} from '../models/RoadModels'

export class RoadBizService {
  static async loadRoutes(): Promise<RouteItem[]> {
    const res = await HttpClient.get<RouteListPayload>('/biz/study-roadtrip/routes')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: RouteItem[] = []
      for (const w of res.data.list) {
        out.push(RouteItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findRoute(id: string): Promise<RouteItem | undefined> {
    const res = await HttpClient.get<RouteWire>(`/biz/study-roadtrip/routes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return RouteItem.fromWire(res.data)
    }
    const all = await RoadBizService.loadRoutes()
    for (const r of all) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async loadSpots(): Promise<SpotItem[]> {
    const res = await HttpClient.get<SpotListPayload>('/biz/study-roadtrip/spots')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: SpotItem[] = []
      for (const w of res.data.list) {
        out.push(SpotItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findSpot(id: string): Promise<SpotItem | undefined> {
    const res = await HttpClient.get<SpotWire>(`/biz/study-roadtrip/spots/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return SpotItem.fromWire(res.data)
    }
    const all = await RoadBizService.loadSpots()
    for (const r of all) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async loadQuizzes(): Promise<QuizItem[]> {
    const res = await HttpClient.get<QuizListPayload>('/biz/study-roadtrip/quizzes')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: QuizItem[] = []
      for (const w of res.data.list) {
        out.push(QuizItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findQuizBySpot(spotId: string): Promise<QuizItem | undefined> {
    const all = await RoadBizService.loadQuizzes()
    for (const q of all) {
      if (q.spotId === spotId) {
        return q
      }
    }
    return undefined
  }

  static async findQuiz(id: string): Promise<QuizItem | undefined> {
    const res = await HttpClient.get<QuizWire>(`/biz/study-roadtrip/quizzes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return QuizItem.fromWire(res.data)
    }
    const all = await RoadBizService.loadQuizzes()
    for (const q of all) {
      if (q.id === id) {
        return q
      }
    }
    return undefined
  }

  static async loadWeather(): Promise<WeatherItem[]> {
    const res = await HttpClient.get<WeatherListPayload>('/biz/study-roadtrip/weather')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: WeatherItem[] = []
      for (const w of res.data.list) {
        out.push(WeatherItem.fromWire(w))
      }
      return out
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

  static currentUserId(): string {
    return AppStorage.get<string>('currentUsername') ?? ''
  }

  static async loadItineraries(): Promise<RecordItem[]> {
    const uid = RoadBizService.currentUserId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<RecordListPayload>(`/biz/study-roadtrip/itineraries?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return RoadBizService.mapRecords(res.data.list)
    }
    return []
  }

  static async findItinerary(id: string): Promise<RecordItem | undefined> {
    const res = await HttpClient.get<RecordWire>(`/biz/study-roadtrip/itineraries/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return RecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async createItinerary(body: StudyWriteRequest): Promise<RecordItem | undefined> {
    body.userId = RoadBizService.currentUserId()
    const res = await HttpClient.post<RecordWire>('/biz/study-roadtrip/itineraries', body)
    if (res.code === 0 && res.data !== undefined) {
      return RecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async updateItinerary(id: string, body: StudyWriteRequest): Promise<boolean> {
    const res = await HttpClient.put<RecordWire>(`/biz/study-roadtrip/itineraries/${id}`, body)
    return res.code === 0
  }

  static async deleteItinerary(id: string): Promise<boolean> {
    const res = await HttpClient.delete<RecordWire>(`/biz/study-roadtrip/itineraries/${id}`)
    return res.code === 0
  }

  static async loadJournals(): Promise<RecordItem[]> {
    const uid = RoadBizService.currentUserId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<RecordListPayload>(`/biz/study-roadtrip/journals?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return RoadBizService.mapRecords(res.data.list)
    }
    return []
  }

  static async findJournal(id: string): Promise<RecordItem | undefined> {
    const res = await HttpClient.get<RecordWire>(`/biz/study-roadtrip/journals/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return RecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async createJournal(body: StudyWriteRequest): Promise<RecordItem | undefined> {
    body.userId = RoadBizService.currentUserId()
    const res = await HttpClient.post<RecordWire>('/biz/study-roadtrip/journals', body)
    if (res.code === 0 && res.data !== undefined) {
      return RecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async updateJournal(id: string, body: StudyWriteRequest): Promise<boolean> {
    const res = await HttpClient.put<RecordWire>(`/biz/study-roadtrip/journals/${id}`, body)
    return res.code === 0
  }

  static async deleteJournal(id: string): Promise<boolean> {
    const res = await HttpClient.delete<RecordWire>(`/biz/study-roadtrip/journals/${id}`)
    return res.code === 0
  }

  static async loadCheckins(): Promise<RecordItem[]> {
    const uid = RoadBizService.currentUserId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<RecordListPayload>(`/biz/study-roadtrip/checkins?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return RoadBizService.mapRecords(res.data.list)
    }
    return []
  }

  static async createCheckin(body: StudyWriteRequest): Promise<boolean> {
    body.userId = RoadBizService.currentUserId()
    const res = await HttpClient.post<RecordWire>('/biz/study-roadtrip/checkins', body)
    return res.code === 0
  }

  static async loadFavorites(): Promise<RecordItem[]> {
    const uid = RoadBizService.currentUserId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<RecordListPayload>(`/biz/study-roadtrip/favorites?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return RoadBizService.mapRecords(res.data.list)
    }
    return []
  }

  static async isFavorite(targetId: string): Promise<boolean> {
    const all = await RoadBizService.loadFavorites()
    for (const f of all) {
      if (f.targetId === targetId) {
        return true
      }
    }
    return false
  }

  static async favoriteId(targetId: string): Promise<string> {
    const all = await RoadBizService.loadFavorites()
    for (const f of all) {
      if (f.targetId === targetId) {
        return f.id
      }
    }
    return ''
  }

  static async addFavorite(title: string, targetId: string, kind: string): Promise<boolean> {
    const body = new StudyWriteRequest()
    body.title = title
    body.targetId = targetId
    body.targetKind = kind
    body.userId = RoadBizService.currentUserId()
    const res = await HttpClient.post<RecordWire>('/biz/study-roadtrip/favorites', body)
    return res.code === 0
  }

  static async removeFavorite(id: string): Promise<boolean> {
    const res = await HttpClient.delete<RecordWire>(`/biz/study-roadtrip/favorites/${id}`)
    return res.code === 0
  }

  static filterByTheme(routes: RouteItem[], theme: string): RouteItem[] {
    if (theme.length === 0 || theme === 'all') {
      return routes
    }
    const out: RouteItem[] = []
    for (const r of routes) {
      if (r.theme === theme) {
        out.push(r)
      }
    }
    return out
  }

  static searchRoutes(routes: RouteItem[], keyword: string): RouteItem[] {
    const k = keyword.trim()
    if (k.length === 0) {
      return routes
    }
    const out: RouteItem[] = []
    for (const r of routes) {
      if (r.title.indexOf(k) >= 0 || r.city.indexOf(k) >= 0 || r.summary.indexOf(k) >= 0) {
        out.push(r)
      }
    }
    return out
  }

  static searchSpots(spots: SpotItem[], keyword: string): SpotItem[] {
    const k = keyword.trim()
    if (k.length === 0) {
      return spots
    }
    const out: SpotItem[] = []
    for (const s of spots) {
      if (s.title.indexOf(k) >= 0 || s.city.indexOf(k) >= 0 || s.summary.indexOf(k) >= 0) {
        out.push(s)
      }
    }
    return out
  }

  private static mapRecords(list: RecordWire[]): RecordItem[] {
    const out: RecordItem[] = []
    for (const w of list) {
      out.push(RecordItem.fromWire(w))
    }
    return out
  }
}
