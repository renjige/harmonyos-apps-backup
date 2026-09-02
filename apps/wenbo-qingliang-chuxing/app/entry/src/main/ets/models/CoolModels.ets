/** 清凉出行 — 平台 Wire 与本地模型（ArkTS 严格模式） */

export class HourlyFelt {
  hour: string = ''
  felt: number = 0
  suitable: boolean = false
}

export class CityWire {
  id: string = ''
  title: string = ''
  cityName: string = ''
  temp: number = 0
  feltTemp: number = 0
  humidity: number = 0
  uv: number = 0
  wind: number = 0
  aqi: number = 0
  condition: string = ''
  coolIndex: number = 0
  dressHint: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  hourlyJson: string = ''
}

export class CityItem {
  id: string = ''
  title: string = ''
  temp: number = 0
  feltTemp: number = 0
  humidity: number = 0
  uv: number = 0
  wind: number = 0
  aqi: number = 0
  condition: string = ''
  coolIndex: number = 0
  dressHint: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  hours: HourlyFelt[] = []

  static fromWire(w: CityWire): CityItem {
    const item = new CityItem()
    item.id = w.id
    item.title = w.title.length > 0 ? w.title : (w.cityName ?? '')
    item.temp = w.temp
    item.feltTemp = w.feltTemp
    item.humidity = w.humidity
    item.uv = w.uv
    item.wind = w.wind
    item.aqi = w.aqi
    item.condition = w.condition ?? ''
    item.coolIndex = w.coolIndex
    item.dressHint = w.dressHint ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.hours = CityItem.parseHours(w.hourlyJson ?? '')
    return item
  }

  static parseHours(raw: string): HourlyFelt[] {
    const out: HourlyFelt[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('|')
      let hour = ''
      let feltRaw = ''
      let flag = ''
      let i = 0
      for (const p of parts) {
        if (i === 0) {
          hour = p
        } else if (i === 1) {
          feltRaw = p
        } else if (i === 2) {
          flag = p
        }
        i += 1
      }
      if (hour.length === 0 || feltRaw.length === 0) {
        continue
      }
      const h = new HourlyFelt()
      h.hour = hour
      h.felt = Number(feltRaw)
      h.suitable = flag === '1'
      out.push(h)
    }
    return out
  }
}

export class CityListPayload {
  list: CityWire[] = []
}

export class RouteNode {
  title: string = ''
  minute: string = ''
  note: string = ''
}

export class RouteWire {
  id: string = ''
  title: string = ''
  cityId: string = ''
  cityName: string = ''
  origin: string = ''
  dest: string = ''
  mode: string = ''
  durationMin: number = 0
  shadeRate: number = 0
  indoorShare: number = 0
  coolIndex: number = 0
  restStopIds: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  nodesJson: string = ''
  tags: string[] = []
}

export class RouteItem {
  id: string = ''
  title: string = ''
  cityId: string = ''
  cityName: string = ''
  origin: string = ''
  dest: string = ''
  mode: string = ''
  durationMin: number = 0
  shadeRate: number = 0
  indoorShare: number = 0
  coolIndex: number = 0
  restStopIds: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  nodes: RouteNode[] = []
  tags: string[] = []

  static fromWire(w: RouteWire): RouteItem {
    const item = new RouteItem()
    item.id = w.id
    item.title = w.title
    item.cityId = w.cityId ?? ''
    item.cityName = w.cityName ?? ''
    item.origin = w.origin ?? ''
    item.dest = w.dest ?? ''
    item.mode = w.mode ?? 'walk'
    item.durationMin = w.durationMin
    item.shadeRate = w.shadeRate
    item.indoorShare = w.indoorShare
    item.coolIndex = w.coolIndex
    item.restStopIds = w.restStopIds ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.nodes = RouteItem.parseNodes(w.nodesJson ?? '')
    item.tags = w.tags ?? []
    return item
  }

  static parseNodes(raw: string): RouteNode[] {
    const out: RouteNode[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('||')
      const n = new RouteNode()
      let i = 0
      for (const p of parts) {
        if (i === 0) {
          n.title = p
        } else if (i === 1) {
          n.minute = p
        } else if (i === 2) {
          n.note = p
        }
        i += 1
      }
      out.push(n)
    }
    return out
  }

  modeLabel(): string {
    if (this.mode === 'bike') {
      return '骑行'
    }
    if (this.mode === 'transit') {
      return '公共交通'
    }
    return '步行'
  }
}

export class RouteListPayload {
  list: RouteWire[] = []
}

export class StopWire {
  id: string = ''
  title: string = ''
  cityId: string = ''
  stopType: string = ''
  address: string = ''
  shade: boolean = false
  indoor: boolean = false
  coolScore: number = 0
  relatedRouteIds: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
}

export class StopItem {
  id: string = ''
  title: string = ''
  cityId: string = ''
  stopType: string = ''
  address: string = ''
  shade: boolean = false
  indoor: boolean = false
  coolScore: number = 0
  relatedRouteIds: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''

  static fromWire(w: StopWire): StopItem {
    const item = new StopItem()
    item.id = w.id
    item.title = w.title
    item.cityId = w.cityId ?? ''
    item.stopType = w.stopType ?? ''
    item.address = w.address ?? ''
    item.shade = w.shade === true
    item.indoor = w.indoor === true
    item.coolScore = w.coolScore
    item.relatedRouteIds = w.relatedRouteIds ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    return item
  }

  typeLabel(): string {
    if (this.stopType === 'cafe') {
      return '咖啡歇脚'
    }
    if (this.stopType === 'park') {
      return '公园树荫'
    }
    if (this.stopType === 'mall') {
      return '商场'
    }
    return '室内通道'
  }
}

export class StopListPayload {
  list: StopWire[] = []
}

export class AdviceWire {
  id: string = ''
  title: string = ''
  category: string = ''
  condition: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
}

export class AdviceItem {
  id: string = ''
  title: string = ''
  category: string = ''
  condition: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''

  static fromWire(w: AdviceWire): AdviceItem {
    const item = new AdviceItem()
    item.id = w.id
    item.title = w.title
    item.category = w.category ?? ''
    item.condition = w.condition ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    return item
  }

  categoryLabel(): string {
    if (this.category === 'dress') {
      return '穿衣'
    }
    if (this.category === 'uv') {
      return '紫外线'
    }
    if (this.category === 'aqi') {
      return '空气'
    }
    return '时段'
  }
}

export class AdviceListPayload {
  list: AdviceWire[] = []
}

export class FavoriteWire {
  id: string = ''
  title: string = ''
  userId: string = ''
  targetKind: string = ''
  targetId: string = ''
  remark: string = ''
}

export class FavoriteItem {
  id: string = ''
  title: string = ''
  targetKind: string = ''
  targetId: string = ''

  static fromWire(w: FavoriteWire): FavoriteItem {
    const item = new FavoriteItem()
    item.id = w.id
    item.title = w.title
    item.targetKind = w.targetKind ?? 'route'
    item.targetId = w.targetId ?? ''
    return item
  }
}

export class FavoriteListPayload {
  list: FavoriteWire[] = []
}

export class FavoriteBody {
  userId: string = ''
  title: string = ''
  targetKind: string = ''
  targetId: string = ''

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"title":${JSON.stringify(this.title)},"targetKind":${JSON.stringify(this.targetKind)},"targetId":${JSON.stringify(this.targetId)}}`
  }
}

export class PlanBody {
  userId: string = ''
  title: string = ''
  origin: string = ''
  dest: string = ''
  mode: string = ''
  routeId: string = ''

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"title":${JSON.stringify(this.title)},"origin":${JSON.stringify(this.origin)},"dest":${JSON.stringify(this.dest)},"mode":${JSON.stringify(this.mode)},"routeId":${JSON.stringify(this.routeId)}}`
  }
}

export class PlanWire {
  id: string = ''
  title: string = ''
  origin: string = ''
  dest: string = ''
  routeId: string = ''
}

export class PlanItem {
  id: string = ''
  title: string = ''
  origin: string = ''
  dest: string = ''
  routeId: string = ''

  static fromWire(w: PlanWire): PlanItem {
    const item = new PlanItem()
    item.id = w.id
    item.title = w.title
    item.origin = w.origin ?? ''
    item.dest = w.dest ?? ''
    item.routeId = w.routeId ?? ''
    return item
  }
}

export class PlanListPayload {
  list: PlanWire[] = []
}

export class MessageWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
}

export class MessageItem {
  id: string = ''
  title: string = ''
  body: string = ''

  static fromWire(w: MessageWire): MessageItem {
    const item = new MessageItem()
    item.id = w.id
    item.title = w.title
    item.body = w.body ?? ''
    return item
  }
}

export class MessageListPayload {
  list: MessageWire[] = []
}

export class EmptyOk {
  success: boolean = false
}
