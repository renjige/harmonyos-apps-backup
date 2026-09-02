/** 晴川游 — 平台 Wire 与本地模型（ArkTS 严格模式） */

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
  region: string = ''
  bestSeason: string = ''
  recommendedDays: number = 1
  seasonHint: string = ''
  spots: string = ''
  tips: string = ''
  morningPlan: string = ''
  afternoonPlan: string = ''
  eveningPlan: string = ''
  featured: boolean = false
  rating: number = 0
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
  region: string = ''
  bestSeason: string = ''
  recommendedDays: number = 1
  seasonHint: string = ''
  spots: string = ''
  tips: string = ''
  morningPlan: string = ''
  afternoonPlan: string = ''
  eveningPlan: string = ''
  featured: boolean = false
  rating: number = 0

  categoryLabel(): string {
    if (this.category === 'nature') {
      return '自然风光'
    }
    if (this.category === 'history') {
      return '人文历史'
    }
    if (this.category === 'food') {
      return '美食之旅'
    }
    return '城市漫步'
  }

  daysLabel(): string {
    return `建议 ${this.recommendedDays} 日`
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
    item.category = w.category ?? 'city'
    item.city = w.city ?? ''
    item.region = w.region ?? ''
    item.bestSeason = w.bestSeason ?? ''
    item.recommendedDays = w.recommendedDays ?? 2
    item.seasonHint = w.seasonHint ?? ''
    item.spots = w.spots ?? ''
    item.tips = w.tips ?? ''
    item.morningPlan = w.morningPlan ?? ''
    item.afternoonPlan = w.afternoonPlan ?? ''
    item.eveningPlan = w.eveningPlan ?? ''
    item.featured = w.featured === true
    item.rating = w.rating ?? 0
    return item
  }
}

export class DestListPayload {
  list: DestWire[] = []
}

export class InspWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  destId: string = ''
  destName: string = ''
  sourceLabel: string = ''
  featured: boolean = false
}

export class InspItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  destId: string = ''
  destName: string = ''
  sourceLabel: string = ''

  static fromWire(w: InspWire): InspItem {
    const item = new InspItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.destId = w.destId ?? ''
    item.destName = w.destName ?? ''
    item.sourceLabel = w.sourceLabel ?? '晴川编辑部'
    return item
  }
}

export class InspListPayload {
  list: InspWire[] = []
}

export class NoteWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  destId: string = ''
  destName: string = ''
  coverKey: string = ''
  photoKeys: string = ''
  userId: string = ''
  userName: string = ''
  likes: number = 0
  createdAt: string = ''
}

export class NoteItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  destId: string = ''
  destName: string = ''
  coverKey: string = ''
  userId: string = ''
  userName: string = ''
  likes: number = 0
  createdAt: string = ''

  likesLabel(): string {
    return `${this.likes} 人喜欢`
  }

  static fromWire(w: NoteWire): NoteItem {
    const item = new NoteItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    item.destId = w.destId ?? ''
    item.destName = w.destName ?? ''
    item.coverKey = w.coverKey ?? ''
    item.userId = w.userId ?? ''
    item.userName = w.userName ?? '旅人'
    item.likes = w.likes ?? 0
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class NoteListPayload {
  list: NoteWire[] = []
}

export class NoteCreateRequest {
  title: string = ''
  body: string = ''
  destId: string = ''
  destName: string = ''
  coverKey: string = ''
  userId: string = ''
  userName: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"destId":${JSON.stringify(this.destId)},"destName":${JSON.stringify(this.destName)},"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)},"userName":${JSON.stringify(this.userName)}}`
  }
}

export class TripWire {
  id: string = ''
  title: string = ''
  destId: string = ''
  destName: string = ''
  days: number = 1
  preference: string = ''
  startDate: string = ''
  dailyPlanJson: string = '[]'
  coverKey: string = ''
  userId: string = ''
  createdAt: string = ''
}

export class DailyPlan {
  day: number = 1
  morning: string = ''
  afternoon: string = ''
  evening: string = ''
}

export class TripItem {
  id: string = ''
  title: string = ''
  destId: string = ''
  destName: string = ''
  days: number = 1
  preference: string = ''
  startDate: string = ''
  dailyPlanJson: string = '[]'
  coverKey: string = ''
  createdAt: string = ''

  prefLabel(): string {
    if (this.preference === 'nature') {
      return '自然风光'
    }
    if (this.preference === 'history') {
      return '人文历史'
    }
    if (this.preference === 'food') {
      return '休闲美食'
    }
    return '综合'
  }

  static fromWire(w: TripWire): TripItem {
    const item = new TripItem()
    item.id = w.id
    item.title = w.title
    item.destId = w.destId ?? ''
    item.destName = w.destName ?? ''
    item.days = w.days ?? 1
    item.preference = w.preference ?? 'mixed'
    item.startDate = w.startDate ?? ''
    item.dailyPlanJson = w.dailyPlanJson ?? '[]'
    item.coverKey = w.coverKey ?? ''
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class TripListPayload {
  list: TripWire[] = []
}

export class TripCreateRequest {
  title: string = ''
  destId: string = ''
  destName: string = ''
  days: number = 1
  preference: string = 'mixed'
  startDate: string = ''
  dailyPlanJson: string = '[]'
  coverKey: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"destId":${JSON.stringify(this.destId)},"destName":${JSON.stringify(this.destName)},"days":${this.days},"preference":${JSON.stringify(this.preference)},"startDate":${JSON.stringify(this.startDate)},"dailyPlanJson":${JSON.stringify(this.dailyPlanJson)},"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)}}`
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

export class PrefChip {
  id: string = ''
  label: string = ''

  static of(id: string, label: string): PrefChip {
    const c = new PrefChip()
    c.id = id
    c.label = label
    return c
  }
}
