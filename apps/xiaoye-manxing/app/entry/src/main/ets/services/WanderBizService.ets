import { HttpClient } from './HttpClient'
import {
  InspirationItem,
  InspirationListPayload,
  InspirationWire,
  MessageItem,
  MessageListPayload,
  QuoteItem,
  QuoteListPayload,
  QuoteWire,
  RouteItem,
  RouteListPayload,
  RouteWire
} from '../models/WanderModels'

export class WanderBizService {
  static async loadRoutes(): Promise<RouteItem[]> {
    const res = await HttpClient.get<RouteListPayload>('/biz/summer-wander/routes')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return WanderBizService.mapRoutes(res.data.list)
    }
    return []
  }

  static async findRoute(id: string): Promise<RouteItem | undefined> {
    const res = await HttpClient.get<RouteWire>(`/biz/summer-wander/routes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return RouteItem.fromWire(res.data)
    }
    const all = await WanderBizService.loadRoutes()
    for (const r of all) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async loadInspirations(): Promise<InspirationItem[]> {
    const res = await HttpClient.get<InspirationListPayload>('/biz/summer-wander/inspirations')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: InspirationItem[] = []
      for (const w of res.data.list) {
        out.push(InspirationItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findInspiration(id: string): Promise<InspirationItem | undefined> {
    const res = await HttpClient.get<InspirationWire>(`/biz/summer-wander/inspirations/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    const all = await WanderBizService.loadInspirations()
    for (const r of all) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async loadQuotes(): Promise<QuoteItem[]> {
    const res = await HttpClient.get<QuoteListPayload>('/biz/summer-wander/quotes')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: QuoteItem[] = []
      for (const w of res.data.list) {
        out.push(QuoteItem.fromWire(w))
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

  static pickToday(routes: RouteItem[]): RouteItem | undefined {
    if (routes.length === 0) {
      return undefined
    }
    const hour = new Date().getHours()
    const day = new Date().getDay()
    let prefer = 'swr08'
    if (day === 0 || day === 6) {
      prefer = hour < 12 ? 'swr12' : 'swr02'
    } else if (hour < 8) {
      prefer = 'swr07'
    } else if (hour < 12) {
      prefer = 'swr01'
    } else if (hour < 15) {
      prefer = 'swr04'
    } else if (hour < 17) {
      prefer = 'swr03'
    } else if (hour < 19) {
      prefer = 'swr02'
    } else {
      prefer = 'swr06'
    }
    for (const r of routes) {
      if (r.id === prefer) {
        return r
      }
    }
    for (const r of routes) {
      return r
    }
    return undefined
  }

  private static mapRoutes(wires: RouteWire[]): RouteItem[] {
    const out: RouteItem[] = []
    for (const w of wires) {
      out.push(RouteItem.fromWire(w))
    }
    return out
  }
}
