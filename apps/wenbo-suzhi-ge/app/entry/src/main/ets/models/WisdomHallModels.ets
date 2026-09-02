/** 思见堂 wisdom-hall 数据模型（ArkTS 严格模式） */

export class WisdomItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = 'cover_wisdom'
  category: string = ''
  tags: string = ''
  authorName: string = ''
  userId: string = ''
  readMinutes: number = 0
  likeCount: number = 0
  targetKind: string = ''
  targetId: string = ''
  action: string = ''
  status: string = 'published'
  createdAt: string = ''
  updatedAt: string = ''

  summaryLine(): string {
    const text = this.summary.length > 0 ? this.summary : this.body
    if (text.length <= 48) {
      return text
    }
    return text.substring(0, 48) + '…'
  }

  tagList(): string[] {
    const out: string[] = []
    if (this.tags.length === 0) {
      return out
    }
    const parts = this.tags.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  charCount(): number {
    return this.body.length
  }
}

export class WisdomWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  category: string = ''
  tags: string = ''
  authorName: string = ''
  userId: string = ''
  readMinutes: number = 0
  likeCount: number = 0
  targetKind: string = ''
  targetId: string = ''
  action: string = ''
  status: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class WisdomListPayload {
  list: WisdomWire[] = []
}

export class QuotesPayload {
  list: WisdomWire[] = []
  today: WisdomWire = new WisdomWire()
}

export class LikeFeaturedPayload {
  row: WisdomWire = new WisdomWire()
  liked: boolean = false
}

export class ThoughtCreateBody {
  title: string = ''
  body: string = ''
  content: string = ''
  category: string = '其他'
  tags: string = ''
  coverKey: string = 'cover_wisdom'
  userId: string = ''

  toJsonString(): string {
    const text = this.body.length > 0 ? this.body : this.content
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(text)},` +
      `"content":${JSON.stringify(text)},"category":${JSON.stringify(this.category)},` +
      `"tags":${JSON.stringify(this.tags)},"coverKey":${JSON.stringify(this.coverKey)},` +
      `"userId":${JSON.stringify(this.userId)}}`
  }
}

export class ThoughtUpdateBody {
  title: string = ''
  body: string = ''
  content: string = ''
  category: string = ''
  tags: string = ''
  userId: string = ''

  toJsonString(): string {
    const text = this.body.length > 0 ? this.body : this.content
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(text)},` +
      `"content":${JSON.stringify(text)},"category":${JSON.stringify(this.category)},` +
      `"tags":${JSON.stringify(this.tags)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class FavoriteCreateBody {
  userId: string = ''
  title: string = ''
  targetKind: string = 'read'
  targetId: string = ''

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"title":${JSON.stringify(this.title)},` +
      `"targetKind":${JSON.stringify(this.targetKind)},"targetId":${JSON.stringify(this.targetId)}}`
  }
}

export class HistoryCreateBody {
  userId: string = ''
  title: string = ''
  targetKind: string = 'read'
  targetId: string = ''
  action: string = 'read'

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"title":${JSON.stringify(this.title)},` +
      `"targetKind":${JSON.stringify(this.targetKind)},"targetId":${JSON.stringify(this.targetId)},` +
      `"action":${JSON.stringify(this.action)}}`
  }
}

export class LikeFeaturedBody {
  userId: string = ''

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)}}`
  }
}

export class MsgWire {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  createdAt: string = ''
}

export class MsgListPayload {
  list: MsgWire[] = []
}

export class KpiWire {
  id: string = ''
  label: string = ''
  value: string = ''
  unit: string = ''
}

export class KpiListPayload {
  list: KpiWire[] = []
}

export class WisdomMapper {
  static safeText(value: string): string {
    if (value === undefined || value === null) {
      return ''
    }
    return value
  }

  static fromWire(w: WisdomWire): WisdomItem {
    const n = new WisdomItem()
    n.id = WisdomMapper.safeText(w.id)
    n.title = WisdomMapper.safeText(w.title)
    n.subtitle = WisdomMapper.safeText(w.subtitle)
    const summary = WisdomMapper.safeText(w.summary)
    const body = WisdomMapper.safeText(w.body)
    const description = WisdomMapper.safeText(w.description)
    n.summary = summary.length > 0 ? summary : description
    n.body = body.length > 0 ? body : description
    n.description = description.length > 0 ? description : n.body
    const coverKey = WisdomMapper.safeText(w.coverKey)
    const coverMedia = WisdomMapper.safeText(w.coverMedia)
    n.coverKey = coverKey.length > 0 ? coverKey : (coverMedia.length > 0 ? coverMedia : 'cover_wisdom')
    n.category = WisdomMapper.safeText(w.category)
    n.tags = WisdomMapper.safeText(w.tags)
    n.authorName = WisdomMapper.safeText(w.authorName)
    n.userId = WisdomMapper.safeText(w.userId)
    n.readMinutes = w.readMinutes !== undefined ? w.readMinutes : 0
    n.likeCount = w.likeCount !== undefined ? w.likeCount : 0
    n.targetKind = WisdomMapper.safeText(w.targetKind)
    n.targetId = WisdomMapper.safeText(w.targetId)
    n.action = WisdomMapper.safeText(w.action)
    n.status = WisdomMapper.safeText(w.status)
    n.createdAt = WisdomMapper.safeText(w.createdAt)
    n.updatedAt = WisdomMapper.safeText(w.updatedAt)
    return n
  }

  static mapList(list: WisdomWire[]): WisdomItem[] {
    const out: WisdomItem[] = []
    for (const w of list) {
      out.push(WisdomMapper.fromWire(w))
    }
    return out
  }
}
