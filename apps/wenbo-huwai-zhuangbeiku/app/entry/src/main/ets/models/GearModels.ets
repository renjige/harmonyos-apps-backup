/** 户外装备库 — 平台 Wire 与本地模型 */

export class CatalogWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  category: string = ''
  brand: string = ''
  model: string = ''
  weightG: number = 0
  boughtAt: string = ''
  useCount: number = 0
  condition: string = ''
  remark: string = ''
  difficulty: string = ''
  distanceKm: number = 0
  durationH: number = 0
  elevationM: number = 0
  origin: string = ''
  dest: string = ''
  waypoints: string = ''
  recCategories: string = ''
  authorName: string = ''
  readMinutes: number = 0
  likeCount: number = 0
  commentCount: number = 0
  userId: string = ''
  targetKind: string = ''
  targetId: string = ''
  postId: string = ''
  readyScore: number = 0
  createdAt: string = ''
}

export class CatalogListPayload {
  list: CatalogWire[] = []
}

export class CatalogItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  category: string = ''
  brand: string = ''
  model: string = ''
  weightG: number = 0
  boughtAt: string = ''
  useCount: number = 0
  condition: string = ''
  remark: string = ''
  difficulty: string = ''
  distanceKm: number = 0
  durationH: number = 0
  elevationM: number = 0
  origin: string = ''
  dest: string = ''
  waypoints: string = ''
  recCategories: string = ''
  authorName: string = ''
  readMinutes: number = 0
  likeCount: number = 0
  commentCount: number = 0
  userId: string = ''
  targetKind: string = ''
  targetId: string = ''
  postId: string = ''
  readyScore: number = 0

  static fromWire(w: CatalogWire): CatalogItem {
    const item = new CatalogItem()
    item.id = w.id ?? ''
    item.title = w.title ?? ''
    item.subtitle = w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = (w.body !== undefined && w.body.length > 0) ? w.body : (w.description ?? '')
    if (w.coverKey !== undefined && w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else {
      item.coverKey = w.coverMedia ?? ''
    }
    item.category = w.category ?? ''
    item.brand = w.brand ?? ''
    item.model = w.model ?? ''
    item.weightG = w.weightG ?? 0
    item.boughtAt = w.boughtAt ?? ''
    item.useCount = w.useCount ?? 0
    item.condition = w.condition ?? ''
    item.remark = w.remark ?? ''
    item.difficulty = w.difficulty ?? ''
    item.distanceKm = w.distanceKm ?? 0
    item.durationH = w.durationH ?? 0
    item.elevationM = w.elevationM ?? 0
    item.origin = w.origin ?? ''
    item.dest = w.dest ?? ''
    item.waypoints = w.waypoints ?? ''
    item.recCategories = w.recCategories ?? ''
    item.authorName = w.authorName ?? ''
    item.readMinutes = w.readMinutes ?? 0
    item.likeCount = w.likeCount ?? 0
    item.commentCount = w.commentCount ?? 0
    item.userId = w.userId ?? ''
    item.targetKind = w.targetKind ?? ''
    item.targetId = w.targetId ?? ''
    item.postId = w.postId ?? ''
    item.readyScore = w.readyScore ?? 0
    return item
  }

  weightKgText(): string {
    if (this.weightG <= 0) {
      return '未称重'
    }
    const kg = this.weightG / 1000
    return `${kg.toFixed(2)} kg`
  }

  recList(): string[] {
    if (this.recCategories.length === 0) {
      return []
    }
    return this.recCategories.split(',')
  }
}

export class MessageWire {
  id: string = ''
  title: string = ''
  body: string = ''
  createdAt: string = ''
}

export class MessageListPayload {
  list: MessageWire[] = []
}

export class MessageItem {
  id: string = ''
  title: string = ''
  body: string = ''
  createdAt: string = ''

  static fromWire(w: MessageWire): MessageItem {
    const m = new MessageItem()
    m.id = w.id ?? ''
    m.title = w.title ?? ''
    m.body = w.body ?? ''
    m.createdAt = w.createdAt ?? ''
    return m
  }
}

export class GearWriteRequest {
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  category: string = ''
  brand: string = ''
  model: string = ''
  weightG: number = 0
  boughtAt: string = ''
  useCount: number = 0
  condition: string = ''
  remark: string = ''
  difficulty: string = ''
  distanceKm: number = 0
  durationH: number = 0
  elevationM: number = 0
  origin: string = ''
  dest: string = ''
  waypoints: string = ''
  recCategories: string = ''
  authorName: string = ''
  userId: string = ''
  targetKind: string = ''
  targetId: string = ''
  postId: string = ''
  readyScore: number = 0

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"subtitle":${JSON.stringify(this.subtitle)},` +
      `"summary":${JSON.stringify(this.summary)},"body":${JSON.stringify(this.body)},` +
      `"coverKey":${JSON.stringify(this.coverKey)},"category":${JSON.stringify(this.category)},` +
      `"brand":${JSON.stringify(this.brand)},"model":${JSON.stringify(this.model)},` +
      `"weightG":${this.weightG},"boughtAt":${JSON.stringify(this.boughtAt)},` +
      `"useCount":${this.useCount},"condition":${JSON.stringify(this.condition)},` +
      `"remark":${JSON.stringify(this.remark)},"difficulty":${JSON.stringify(this.difficulty)},` +
      `"distanceKm":${this.distanceKm},"durationH":${this.durationH},"elevationM":${this.elevationM},` +
      `"origin":${JSON.stringify(this.origin)},"dest":${JSON.stringify(this.dest)},` +
      `"waypoints":${JSON.stringify(this.waypoints)},"recCategories":${JSON.stringify(this.recCategories)},` +
      `"authorName":${JSON.stringify(this.authorName)},"userId":${JSON.stringify(this.userId)},` +
      `"targetKind":${JSON.stringify(this.targetKind)},"targetId":${JSON.stringify(this.targetId)},` +
      `"postId":${JSON.stringify(this.postId)},"readyScore":${this.readyScore}}`
  }
}
