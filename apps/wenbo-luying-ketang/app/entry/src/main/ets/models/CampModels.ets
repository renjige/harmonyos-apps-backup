/** 露营课堂 — 平台 Wire 与本地模型（ArkTS 严格模式） */

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
  region: string = ''
  campType: string = ''
  facilities: string[] = []
  rating: number = 0
  city: string = ''
  season: string = ''
  tempRange: string = ''
  hint: string = ''
  extraGear: string = ''
  scene: string = ''
  itemsJson: string = ''
  totalWeightG: number = 0
  category: string = ''
  weightG: number = 0
  people: number = 0
  days: number = 0
  startAt: string = ''
  endAt: string = ''
  campId: string = ''
  tripId: string = ''
  checkedJson: string = ''
  readMinutes: number = 0
  likeCount: number = 0
  userId: string = ''
  authorName: string = ''
  createdAt: string = ''
}

export class CatalogListPayload {
  list: CatalogWire[] = []
}

export class GearLine {
  name: string = ''
  weightG: number = 0
  checked: boolean = false
}

export class GuideMeta {
  scene: string = ''
  category: string = ''
}

export class CatalogItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  region: string = ''
  campType: string = ''
  facilities: string[] = []
  rating: number = 0
  city: string = ''
  season: string = ''
  tempRange: string = ''
  hint: string = ''
  extraGear: string = ''
  scene: string = ''
  itemsJson: string = ''
  totalWeightG: number = 0
  category: string = ''
  weightG: number = 0
  people: number = 0
  days: number = 0
  startAt: string = ''
  endAt: string = ''
  campId: string = ''
  tripId: string = ''
  checkedJson: string = ''
  readMinutes: number = 0
  likeCount: number = 0
  userId: string = ''
  authorName: string = ''

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
    item.region = w.region ?? ''
    item.campType = w.campType ?? ''
    item.facilities = w.facilities ?? []
    item.rating = w.rating ?? 0
    item.city = w.city ?? ''
    item.season = w.season ?? ''
    item.tempRange = w.tempRange ?? ''
    item.hint = w.hint ?? ''
    item.extraGear = w.extraGear ?? ''
    item.scene = w.scene ?? ''
    item.itemsJson = w.itemsJson ?? ''
    item.totalWeightG = w.totalWeightG ?? 0
    item.category = w.category ?? ''
    if (item.id.startsWith('cpg') && item.scene.length === 0) {
      const meta = CatalogItem.guideMeta(item.id)
      if (meta !== undefined) {
        item.scene = meta.scene
        item.category = meta.category
      }
    }
    item.weightG = w.weightG ?? 0
    item.people = w.people ?? 0
    item.days = w.days ?? 0
    item.startAt = w.startAt ?? ''
    item.endAt = w.endAt ?? ''
    item.campId = w.campId ?? ''
    item.tripId = w.tripId ?? ''
    item.checkedJson = w.checkedJson ?? ''
    item.readMinutes = w.readMinutes ?? 0
    item.likeCount = w.likeCount ?? 0
    item.userId = w.userId ?? ''
    item.authorName = w.authorName ?? ''
    return item
  }

  static guideMeta(id: string): GuideMeta | undefined {
    if (id === 'cpg01') {
      const m = new GuideMeta()
      m.scene = '亲子露营'
      m.category = '入门'
      return m
    }
    if (id === 'cpg02') {
      const m = new GuideMeta()
      m.scene = 'solo露营'
      m.category = '进阶'
      return m
    }
    if (id === 'cpg03') {
      const m = new GuideMeta()
      m.scene = '团队露营'
      m.category = '入门'
      return m
    }
    if (id === 'cpg04') {
      const m = new GuideMeta()
      m.scene = 'solo露营'
      m.category = '专业'
      return m
    }
    if (id === 'cpg05') {
      const m = new GuideMeta()
      m.scene = '亲子露营'
      m.category = '入门'
      return m
    }
    if (id === 'cpg06') {
      const m = new GuideMeta()
      m.scene = 'solo露营'
      m.category = '专业'
      return m
    }
    return undefined
  }

  parseLines(): GearLine[] {
    const out: GearLine[] = []
    if (this.itemsJson.length === 0) {
      return out
    }
    const parts = this.itemsJson.split('|')
    for (const p of parts) {
      const t = p.trim()
      if (t.length === 0) {
        continue
      }
      const line = new GearLine()
      const sp = t.lastIndexOf(' ')
      if (sp > 0) {
        line.name = t.substring(0, sp)
        const w = t.substring(sp + 1)
        const n = Number.parseInt(w, 10)
        line.weightG = Number.isNaN(n) ? 0 : n
      } else {
        line.name = t
      }
      out.push(line)
    }
    return out
  }

  facilityText(): string {
    let s = ''
    for (const f of this.facilities) {
      if (s.length > 0) {
        s += ' · '
      }
      s += f
    }
    return s
  }

  weightLabel(): string {
    if (this.totalWeightG > 0) {
      return `${(this.totalWeightG / 1000).toFixed(1)} kg`
    }
    if (this.weightG > 0) {
      return `${this.weightG} g`
    }
    return ''
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

export class CampWriteRequest {
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  region: string = ''
  campType: string = ''
  category: string = ''
  weightG: number = 0
  people: number = 0
  days: number = 0
  startAt: string = ''
  endAt: string = ''
  campId: string = ''
  tripId: string = ''
  itemsJson: string = ''
  checkedJson: string = ''
  totalWeightG: number = 0
  userId: string = ''
  authorName: string = ''
  likeCount: number = 0

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"subtitle":${JSON.stringify(this.subtitle)},` +
      `"summary":${JSON.stringify(this.summary)},"body":${JSON.stringify(this.body)},` +
      `"coverKey":${JSON.stringify(this.coverKey)},"region":${JSON.stringify(this.region)},` +
      `"campType":${JSON.stringify(this.campType)},"category":${JSON.stringify(this.category)},` +
      `"weightG":${this.weightG},"people":${this.people},"days":${this.days},` +
      `"startAt":${JSON.stringify(this.startAt)},"endAt":${JSON.stringify(this.endAt)},` +
      `"campId":${JSON.stringify(this.campId)},"tripId":${JSON.stringify(this.tripId)},` +
      `"itemsJson":${JSON.stringify(this.itemsJson)},"checkedJson":${JSON.stringify(this.checkedJson)},` +
      `"totalWeightG":${this.totalWeightG},"userId":${JSON.stringify(this.userId)},` +
      `"authorName":${JSON.stringify(this.authorName)},"likeCount":${this.likeCount}}`
  }
}
