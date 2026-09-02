/** 轻知阁数据模型（ArkTS 严格模式） */

export class KnowledgeItem {
  id: string = ''
  title: string = ''
  body: string = ''
  category: string = '其他'
  tags: string = ''
  coverKey: string = 'cover_other'
  source: string = 'user'
  favorited: boolean = false
  inReview: boolean = false
  readAt: number = 0
  rememberedAt: number = 0
  createdAt: number = 0
  updatedAt: number = 0

  summaryLine(): string {
    if (this.body.length <= 42) {
      return this.body
    }
    return this.body.substring(0, 42) + '…'
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

  toJsonString(): string {
    const fav = this.favorited ? 'true' : 'false'
    const rev = this.inReview ? 'true' : 'false'
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},` +
      `"body":${JSON.stringify(this.body)},"category":${JSON.stringify(this.category)},` +
      `"tags":${JSON.stringify(this.tags)},"coverKey":${JSON.stringify(this.coverKey)},` +
      `"source":${JSON.stringify(this.source)},"favorited":${fav},"inReview":${rev},` +
      `"readAt":${this.readAt},"rememberedAt":${this.rememberedAt},` +
      `"createdAt":${this.createdAt},"updatedAt":${this.updatedAt}}`
  }

  static fromWire(w: KnowledgeWire): KnowledgeItem {
    const n = new KnowledgeItem()
    n.id = w.id
    n.title = w.title
    n.body = w.body
    n.category = w.category.length > 0 ? w.category : '其他'
    n.tags = w.tags
    n.coverKey = w.coverKey.length > 0 ? w.coverKey : 'cover_other'
    n.source = w.source.length > 0 ? w.source : 'user'
    n.favorited = w.favorited
    n.inReview = w.inReview
    n.readAt = w.readAt
    n.rememberedAt = w.rememberedAt
    n.createdAt = w.createdAt
    n.updatedAt = w.updatedAt
    return n
  }
}

export class KnowledgeWire {
  id: string = ''
  title: string = ''
  body: string = ''
  category: string = ''
  tags: string = ''
  coverKey: string = ''
  source: string = ''
  favorited: boolean = false
  inReview: boolean = false
  readAt: number = 0
  rememberedAt: number = 0
  createdAt: number = 0
  updatedAt: number = 0
}

export class KnowledgeFile {
  items: KnowledgeWire[] = []
}

export class SparkItem {
  id: string = ''
  title: string = ''
  body: string = ''
  tags: string = ''
  createdAt: number = 0

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},` +
      `"body":${JSON.stringify(this.body)},"tags":${JSON.stringify(this.tags)},` +
      `"createdAt":${this.createdAt}}`
  }

  static fromWire(w: SparkWire): SparkItem {
    const n = new SparkItem()
    n.id = w.id
    n.title = w.title
    n.body = w.body
    n.tags = w.tags
    n.createdAt = w.createdAt
    return n
  }
}

export class SparkWire {
  id: string = ''
  title: string = ''
  body: string = ''
  tags: string = ''
  createdAt: number = 0
}

export class SparkFile {
  items: SparkWire[] = []
}

export class CatalogItem {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  coverKey: string = ''
  category: string = ''
  tags: string = ''
}

export class CatalogWire {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  category: string = ''
  tags: string = ''
}

export class CatalogListPayload {
  list: CatalogWire[] = []
}

export class CatalogMapper {
  static fromWire(w: CatalogWire): CatalogItem {
    const n = new CatalogItem()
    n.id = w.id
    n.title = w.title
    n.body = w.body.length > 0 ? w.body : (w.description.length > 0 ? w.description : w.summary)
    n.summary = w.summary.length > 0 ? w.summary : n.body
    n.coverKey = w.coverKey.length > 0 ? w.coverKey : w.coverMedia
    n.category = w.category
    n.tags = w.tags
    return n
  }
}

export class KnowledgeSyncBody {
  title: string = ''
  content: string = ''
  category: string = ''
  tags: string = ''
  coverKey: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"content":${JSON.stringify(this.content)},` +
      `"category":${JSON.stringify(this.category)},"tags":${JSON.stringify(this.tags)},` +
      `"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class SparkSyncBody {
  title: string = ''
  content: string = ''
  tags: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"content":${JSON.stringify(this.content)},` +
      `"tags":${JSON.stringify(this.tags)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class MsgWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
  createdAt: string = ''
}

export class MsgListPayload {
  list: MsgWire[] = []
}

export class CategoryOption {
  title: string = ''
  coverKey: string = ''
}
