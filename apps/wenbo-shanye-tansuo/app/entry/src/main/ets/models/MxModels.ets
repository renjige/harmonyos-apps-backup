/** 山野探索 — 平台 Wire 与本地模型（ArkTS 严格模式） */

export class Waypoint {
  title: string = ''
  km: string = ''
  note: string = ''
}

export class TrailWire {
  id: string = ''
  title: string = ''
  region: string = ''
  mode: string = ''
  difficulty: string = ''
  distanceKm: number = 0
  durationHours: number = 0
  elevationM: number = 0
  rating: number = 0
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  waypointsJson: string = ''
  seasonHint: string = ''
  gearHint: string = ''
  tags: string[] = []
  relatedWikiIds: string = ''
}

export class TrailItem {
  id: string = ''
  title: string = ''
  region: string = ''
  mode: string = ''
  difficulty: string = ''
  distanceKm: number = 0
  durationHours: number = 0
  elevationM: number = 0
  rating: number = 0
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  waypoints: Waypoint[] = []
  seasonHint: string = ''
  gearHint: string = ''
  tags: string[] = []
  relatedWikiIds: string = ''

  static fromWire(w: TrailWire): TrailItem {
    const item = new TrailItem()
    item.id = w.id
    item.title = w.title
    item.region = w.region ?? ''
    item.mode = w.mode ?? 'hike'
    item.difficulty = w.difficulty ?? '中级'
    item.distanceKm = w.distanceKm
    item.durationHours = w.durationHours
    item.elevationM = w.elevationM
    item.rating = w.rating
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.waypoints = TrailItem.parsePoints(w.waypointsJson ?? '')
    item.seasonHint = w.seasonHint ?? ''
    item.gearHint = w.gearHint ?? ''
    item.tags = w.tags ?? []
    item.relatedWikiIds = w.relatedWikiIds ?? ''
    return item
  }

  static parsePoints(raw: string): Waypoint[] {
    const out: Waypoint[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('||')
      const n = new Waypoint()
      let i = 0
      for (const p of parts) {
        if (i === 0) {
          n.title = p
        } else if (i === 1) {
          n.km = p
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
    return '徒步'
  }

  metaLine(): string {
    return `${this.difficulty} · ${this.distanceKm}km · ${this.durationHours}h · 爬升 ${this.elevationM}m`
  }
}

export class TrailListPayload {
  list: TrailWire[] = []
}

export class TipWire {
  id: string = ''
  title: string = ''
  category: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  relatedTrailIds: string = ''
  relatedWikiIds: string = ''
}

export class TipItem {
  id: string = ''
  title: string = ''
  category: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  relatedTrailIds: string = ''
  relatedWikiIds: string = ''

  static fromWire(w: TipWire): TipItem {
    const item = new TipItem()
    item.id = w.id
    item.title = w.title
    item.category = w.category ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.relatedTrailIds = w.relatedTrailIds ?? ''
    item.relatedWikiIds = w.relatedWikiIds ?? ''
    return item
  }

  categoryLabel(): string {
    if (this.category === 'safety') {
      return '安全'
    }
    if (this.category === 'ecology') {
      return '生态'
    }
    if (this.category === 'sky') {
      return '星空'
    }
    return '技艺'
  }
}

export class TipListPayload {
  list: TipWire[] = []
}

export class WikiWire {
  id: string = ''
  title: string = ''
  category: string = ''
  latinName: string = ''
  habitat: string = ''
  observeHint: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  relatedTrailIds: string = ''
}

export class WikiItem {
  id: string = ''
  title: string = ''
  category: string = ''
  latinName: string = ''
  habitat: string = ''
  observeHint: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  relatedTrailIds: string = ''

  static fromWire(w: WikiWire): WikiItem {
    const item = new WikiItem()
    item.id = w.id
    item.title = w.title
    item.category = w.category ?? ''
    item.latinName = w.latinName ?? ''
    item.habitat = w.habitat ?? ''
    item.observeHint = w.observeHint ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.relatedTrailIds = w.relatedTrailIds ?? ''
    return item
  }
}

export class WikiListPayload {
  list: WikiWire[] = []
}

export class FavoriteWire {
  id: string = ''
  title: string = ''
  userId: string = ''
  targetKind: string = ''
  targetId: string = ''
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
    item.targetKind = w.targetKind ?? 'trail'
    item.targetId = w.targetId ?? ''
    return item
  }

  kindLabel(): string {
    if (this.targetKind === 'wiki') {
      return '百科'
    }
    if (this.targetKind === 'tip') {
      return '灵感'
    }
    return '路线'
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

export class FootprintWire {
  id: string = ''
  title: string = ''
  trailId: string = ''
  completedAt: string = ''
  remark: string = ''
}

export class FootprintItem {
  id: string = ''
  title: string = ''
  trailId: string = ''
  completedAt: string = ''
  remark: string = ''

  static fromWire(w: FootprintWire): FootprintItem {
    const item = new FootprintItem()
    item.id = w.id
    item.title = w.title
    item.trailId = w.trailId ?? ''
    item.completedAt = w.completedAt ?? ''
    item.remark = w.remark ?? ''
    return item
  }
}

export class FootprintListPayload {
  list: FootprintWire[] = []
}

export class FootprintBody {
  userId: string = ''
  title: string = ''
  trailId: string = ''
  completedAt: string = ''
  remark: string = ''

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"title":${JSON.stringify(this.title)},"trailId":${JSON.stringify(this.trailId)},"completedAt":${JSON.stringify(this.completedAt)},"remark":${JSON.stringify(this.remark)}}`
  }
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
