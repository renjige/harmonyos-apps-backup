/** 避暑游记 — 平台 Wire 与本地模型（ArkTS 严格模式） */

export class DestWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  tags: string[] = []
  category: string = ''
  city: string = ''
  tempMin: number = 0
  tempMax: number = 0
  altitude: string = ''
  score: number = 0
  season: string = ''
  transport: string = ''
  foods: string = ''
  spots: string = ''
  featured: boolean = false
}

export class DestItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  tags: string[] = []
  category: string = ''
  city: string = ''
  tempMin: number = 0
  tempMax: number = 0
  altitude: string = ''
  score: number = 0
  season: string = ''
  transport: string = ''
  foods: string = ''
  spots: string = ''
  featured: boolean = false

  tempLabel(): string {
    return `${this.tempMin}–${this.tempMax}℃`
  }

  categoryLabel(): string {
    if (this.category === 'sea') {
      return '海滨避暑'
    }
    if (this.category === 'plateau') {
      return '高原避暑'
    }
    if (this.category === 'forest') {
      return '森林避暑'
    }
    return '山水避暑'
  }

  static fromWire(w: DestWire): DestItem {
    const item = new DestItem()
    item.id = w.id
    item.title = w.title
    item.subtitle = w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.tags = w.tags ?? []
    item.category = w.category ?? 'mountain'
    item.city = w.city ?? ''
    item.tempMin = w.tempMin ?? 0
    item.tempMax = w.tempMax ?? 0
    item.altitude = w.altitude ?? ''
    item.score = w.score ?? 0
    item.season = w.season ?? ''
    item.transport = w.transport ?? ''
    item.foods = w.foods ?? ''
    item.spots = w.spots ?? ''
    item.featured = w.featured === true
    return item
  }
}

export class DestListPayload {
  list: DestWire[] = []
}

export class GuideWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  kind: string = ''
  readMinutes: number = 0
  publishedAt: string = ''
  destId: string = ''
}

export class GuideItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  kind: string = ''
  readMinutes: number = 0
  publishedAt: string = ''
  destId: string = ''

  kindLabel(): string {
    if (this.kind === 'featured') {
      return '精选游记'
    }
    return '避暑攻略'
  }

  static fromWire(w: GuideWire): GuideItem {
    const item = new GuideItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.kind = w.kind ?? 'guide'
    item.readMinutes = w.readMinutes ?? 0
    item.publishedAt = w.publishedAt ?? ''
    item.destId = w.destId ?? ''
    return item
  }
}

export class GuideListPayload {
  list: GuideWire[] = []
}

export class JournalWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  destId: string = ''
  destName: string = ''
  placeLabel: string = ''
  visitDate: string = ''
  coverKey: string = ''
  photoKeys: string = ''
  userId: string = ''
  createdAt: string = ''
}

export class JournalItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  destId: string = ''
  destName: string = ''
  placeLabel: string = ''
  visitDate: string = ''
  coverKey: string = ''
  photoKeys: string = ''
  createdAt: string = ''

  static fromWire(w: JournalWire): JournalItem {
    const item = new JournalItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    item.destId = w.destId ?? ''
    item.destName = w.destName ?? ''
    item.placeLabel = w.placeLabel ?? w.destName ?? ''
    item.visitDate = w.visitDate ?? ''
    item.coverKey = w.coverKey ?? ''
    item.photoKeys = w.photoKeys ?? ''
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class JournalListPayload {
  list: JournalWire[] = []
}

export class JournalCreateRequest {
  title: string = ''
  body: string = ''
  destId: string = ''
  destName: string = ''
  placeLabel: string = ''
  visitDate: string = ''
  coverKey: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"destId":${JSON.stringify(this.destId)},"destName":${JSON.stringify(this.destName)},"placeLabel":${JSON.stringify(this.placeLabel)},"visitDate":${JSON.stringify(this.visitDate)},"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class FavoriteWire {
  id: string = ''
  title: string = ''
  kind: string = ''
  targetId: string = ''
  coverKey: string = ''
  userId: string = ''
}

export class FavoriteItem {
  id: string = ''
  title: string = ''
  kind: string = ''
  targetId: string = ''
  coverKey: string = ''

  static fromWire(w: FavoriteWire): FavoriteItem {
    const item = new FavoriteItem()
    item.id = w.id
    item.title = w.title
    item.kind = w.kind ?? 'destination'
    item.targetId = w.targetId ?? ''
    item.coverKey = w.coverKey ?? ''
    return item
  }
}

export class FavoriteListPayload {
  list: FavoriteWire[] = []
}

export class FavoriteCreateRequest {
  kind: string = 'destination'
  targetId: string = ''
  title: string = ''
  coverKey: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"kind":${JSON.stringify(this.kind)},"targetId":${JSON.stringify(this.targetId)},"title":${JSON.stringify(this.title)},"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CoverOption {
  key: string = ''
  label: string = ''
}

export class MessageWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
  createdAt: string = ''
}

export class MessageItem {
  id: string = ''
  title: string = ''
  body: string = ''
  createdAt: string = ''

  static fromWire(w: MessageWire): MessageItem {
    const item = new MessageItem()
    item.id = w.id
    item.title = w.title
    item.body = w.body
    item.createdAt = w.createdAt
    return item
  }
}

export class MessageListPayload {
  list: MessageWire[] = []
}

export class CatChip {
  id: string = ''
  label: string = ''

  static of(id: string, label: string): CatChip {
    const c = new CatChip()
    c.id = id
    c.label = label
    return c
  }
}
