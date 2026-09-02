import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import {
  AdviceItem,
  AdviceListPayload,
  AdviceWire,
  CityItem,
  CityListPayload,
  CityWire,
  EmptyOk,
  FavoriteBody,
  FavoriteItem,
  FavoriteListPayload,
  FavoriteWire,
  MessageItem,
  MessageListPayload,
  MessageWire,
  PlanBody,
  PlanItem,
  PlanListPayload,
  RouteItem,
  RouteListPayload,
  RouteWire,
  StopItem,
  StopListPayload,
  StopWire
} from '../models/CoolModels'

export class CoolBizService {
  static async loadCities(): Promise<CityItem[]> {
    const res = await HttpClient.get<CityListPayload>('/biz/cool-outing/cities')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: CityItem[] = []
      for (const w of res.data.list) {
        out.push(CityItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findCity(id: string): Promise<CityItem | undefined> {
    const res = await HttpClient.get<CityWire>(`/biz/cool-outing/cities/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CityItem.fromWire(res.data)
    }
    const all = await CoolBizService.loadCities()
    for (const c of all) {
      if (c.id === id) {
        return c
      }
    }
    return undefined
  }

  static async loadRoutes(cityId: string, mode: string): Promise<RouteItem[]> {
    let path = '/biz/cool-outing/routes'
    if (cityId.length > 0 && mode.length > 0) {
      path = `/biz/cool-outing/routes?cityId=${cityId}&mode=${mode}`
    } else if (cityId.length > 0) {
      path = `/biz/cool-outing/routes?cityId=${cityId}`
    } else if (mode.length > 0) {
      path = `/biz/cool-outing/routes?mode=${mode}`
    }
    const res = await HttpClient.get<RouteListPayload>(path)
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
    const res = await HttpClient.get<RouteWire>(`/biz/cool-outing/routes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return RouteItem.fromWire(res.data)
    }
    const all = await CoolBizService.loadRoutes('', '')
    for (const r of all) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async loadStops(cityId: string): Promise<StopItem[]> {
    let path = '/biz/cool-outing/stops'
    if (cityId.length > 0) {
      path = `/biz/cool-outing/stops?cityId=${cityId}`
    }
    const res = await HttpClient.get<StopListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: StopItem[] = []
      for (const w of res.data.list) {
        out.push(StopItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findStop(id: string): Promise<StopItem | undefined> {
    const res = await HttpClient.get<StopWire>(`/biz/cool-outing/stops/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return StopItem.fromWire(res.data)
    }
    const all = await CoolBizService.loadStops('')
    for (const s of all) {
      if (s.id === id) {
        return s
      }
    }
    return undefined
  }

  static async loadAdvices(): Promise<AdviceItem[]> {
    const res = await HttpClient.get<AdviceListPayload>('/biz/cool-outing/advices')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: AdviceItem[] = []
      for (const w of res.data.list) {
        out.push(AdviceItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findAdvice(id: string): Promise<AdviceItem | undefined> {
    const res = await HttpClient.get<AdviceWire>(`/biz/cool-outing/advices/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return AdviceItem.fromWire(res.data)
    }
    const all = await CoolBizService.loadAdvices()
    for (const a of all) {
      if (a.id === id) {
        return a
      }
    }
    return undefined
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

  static async loadFavorites(): Promise<FavoriteItem[]> {
    const uid = AuthService.currentUsername()
    if (!AuthService.isLoggedIn() || uid === '未登录') {
      return []
    }
    const res = await HttpClient.get<FavoriteListPayload>(`/biz/cool-outing/favorites?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: FavoriteItem[] = []
      for (const w of res.data.list) {
        out.push(FavoriteItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async addFavorite(title: string, kind: string, targetId: string): Promise<boolean> {
    const uid = AuthService.currentUsername()
    if (!AuthService.isLoggedIn() || uid === '未登录') {
      return false
    }
    const body = new FavoriteBody()
    body.userId = uid
    body.title = title
    body.targetKind = kind
    body.targetId = targetId
    const res = await HttpClient.post<FavoriteWire>('/biz/cool-outing/favorites', body)
    return res.code === 0
  }

  static async removeFavorite(id: string): Promise<boolean> {
    const res = await HttpClient.delete<EmptyOk>(`/biz/cool-outing/favorites/${id}`)
    return res.code === 0
  }

  static async savePlan(route: RouteItem): Promise<boolean> {
    const uid = AuthService.currentUsername()
    if (!AuthService.isLoggedIn() || uid === '未登录') {
      return false
    }
    const body = new PlanBody()
    body.userId = uid
    body.title = route.title
    body.origin = route.origin
    body.dest = route.dest
    body.mode = route.mode
    body.routeId = route.id
    const res = await HttpClient.post<FavoriteWire>('/biz/cool-outing/plans', body)
    return res.code === 0
  }

  static async loadPlans(): Promise<PlanItem[]> {
    const uid = AuthService.currentUsername()
    if (!AuthService.isLoggedIn() || uid === '未登录') {
      return []
    }
    const res = await HttpClient.get<PlanListPayload>(`/biz/cool-outing/plans?userId=${uid}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: PlanItem[] = []
      for (const w of res.data.list) {
        out.push(PlanItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static smartAdvice(city: CityItem): string {
    if (city.uv >= 8) {
      return '紫外线很强，10 点到 16 点优先走室内连廊，出门请备遮阳。'
    }
    if (city.feltTemp >= 37) {
      return '体感偏高，建议把非紧急步行推迟到傍晚，或改走空调通道。'
    }
    if (city.aqi > 80) {
      return '空气质量一般，敏感人群缩短骑行，改公共交通更稳妥。'
    }
    if (city.coolIndex >= 60) {
      return '当前清凉指数尚可，短途步行可以出门，仍建议走树荫侧。'
    }
    return '今天偏热。对比路线的树荫率与室内占比，选清凉指数更高的一条。'
  }
}
