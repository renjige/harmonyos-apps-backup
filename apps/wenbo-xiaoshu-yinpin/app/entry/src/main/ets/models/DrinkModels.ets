/** 消暑饮品 — 平台 Wire 与本地模型 */

export class DrinkWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  tags: string[] = []
  category: string = ''
  ingredients: string[] = []
  steps: string[] = []
  effect: string = ''
  timeMin: number = 0
  difficulty: string = ''
  iceLevel: string = ''
  sweetness: string = ''
  slot: string = ''
  tempMin: number = 0
  tempMax: number = 0
  humidityHint: string = ''
  isHot: boolean = false
  featured: boolean = false
}

export class DrinkItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  tags: string[] = []
  category: string = ''
  ingredients: string[] = []
  steps: string[] = []
  effect: string = ''
  timeMin: number = 0
  difficulty: string = ''
  iceLevel: string = ''
  sweetness: string = ''
  slot: string = ''
  tempMin: number = 0
  tempMax: number = 0
  humidityHint: string = ''
  isHot: boolean = false
  featured: boolean = false

  slotLabel(): string {
    if (this.slot === 'morning') {
      return '清晨'
    }
    if (this.slot === 'noon') {
      return '正午'
    }
    if (this.slot === 'evening') {
      return '晚间'
    }
    return '午后'
  }

  metaLine(): string {
    return `${this.category} · ${this.timeMin}分钟 · ${this.difficulty}`
  }

  static fromWire(w: DrinkWire): DrinkItem {
    const item = new DrinkItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary ?? ''
    item.body = w.body !== undefined && w.body !== null && w.body.length > 0 ? w.body : (w.description ?? '')
    item.coverKey = ''
    if (w.coverKey !== undefined && w.coverKey !== null && w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia !== null && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.tags = w.tags ?? []
    item.category = w.category ?? '冰饮'
    item.ingredients = w.ingredients ?? []
    item.steps = w.steps ?? []
    item.effect = w.effect ?? ''
    item.timeMin = w.timeMin ?? 0
    item.difficulty = w.difficulty ?? '简单'
    item.iceLevel = w.iceLevel ?? ''
    item.sweetness = w.sweetness ?? ''
    item.slot = w.slot ?? 'afternoon'
    item.tempMin = w.tempMin ?? 0
    item.tempMax = w.tempMax ?? 40
    item.humidityHint = w.humidityHint ?? 'any'
    item.isHot = w.isHot === true
    item.featured = w.featured === true
    return item
  }
}

export class DrinkListPayload {
  list: DrinkWire[] = []
}

export class TipWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  kind: string = ''
  readMinutes: number = 0
}

export class TipItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  kind: string = ''
  readMinutes: number = 0

  static fromWire(w: TipWire): TipItem {
    const item = new TipItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary ?? ''
    item.body = w.body !== undefined && w.body !== null && w.body.length > 0 ? w.body : (w.description ?? '')
    item.coverKey = ''
    if (w.coverKey !== undefined && w.coverKey !== null && w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia !== null && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.kind = w.kind ?? '功效'
    item.readMinutes = w.readMinutes ?? 2
    return item
  }
}

export class TipListPayload {
  list: TipWire[] = []
}

export class TryWire {
  id: string = ''
  title: string = ''
  drinkId: string = ''
  drinkName: string = ''
  coverKey: string = ''
  note: string = ''
  tryDate: string = ''
  userId: string = ''
}

export class TryItem {
  id: string = ''
  title: string = ''
  drinkId: string = ''
  coverKey: string = ''
  note: string = ''
  tryDate: string = ''

  static fromWire(w: TryWire): TryItem {
    const item = new TryItem()
    item.id = w.id
    item.title = w.title.length > 0 ? w.title : (w.drinkName ?? '')
    item.drinkId = w.drinkId ?? ''
    item.coverKey = w.coverKey ?? ''
    item.note = w.note ?? ''
    item.tryDate = w.tryDate ?? ''
    return item
  }
}

export class TryListPayload {
  list: TryWire[] = []
}

export class TryCreateRequest {
  title: string = ''
  drinkId: string = ''
  drinkName: string = ''
  coverKey: string = ''
  note: string = ''
  tryDate: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"drinkId":${JSON.stringify(this.drinkId)},"drinkName":${JSON.stringify(this.drinkName)},"coverKey":${JSON.stringify(this.coverKey)},"note":${JSON.stringify(this.note)},"tryDate":${JSON.stringify(this.tryDate)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class FavoriteWire {
  id: string = ''
  title: string = ''
  kind: string = ''
  targetId: string = ''
  coverKey: string = ''
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
    item.kind = w.kind ?? 'drink'
    item.targetId = w.targetId ?? ''
    item.coverKey = w.coverKey ?? ''
    return item
  }
}

export class FavoriteListPayload {
  list: FavoriteWire[] = []
}

export class FavoriteCreateRequest {
  kind: string = 'drink'
  targetId: string = ''
  title: string = ''
  coverKey: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"kind":${JSON.stringify(this.kind)},"targetId":${JSON.stringify(this.targetId)},"title":${JSON.stringify(this.title)},"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class MessageWire {
  id: string = ''
  title: string = ''
  body: string = ''
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
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class MessageListPayload {
  list: MessageWire[] = []
}

export class KpiWire {
  key: string = ''
  label: string = ''
  value: number = 0
}

export class KpiListPayload {
  list: KpiWire[] = []
}
