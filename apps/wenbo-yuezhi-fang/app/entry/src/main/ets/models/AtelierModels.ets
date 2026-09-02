/** 悦知坊数据模型（ArkTS 严格模式） */

/** JSON.parse 字段可能缺省，禁止直接 .length */
export class AtelierText {
  static read(value: string): string {
    if (value === undefined) {
      return ''
    }
    if (value === null) {
      return ''
    }
    const s = `${value}`
    if (s === 'undefined' || s === 'null') {
      return ''
    }
    return s
  }

  static num(value: number): number {
    if (value === undefined) {
      return 0
    }
    if (value === null) {
      return 0
    }
    return value
  }

  static first(a: string, b: string): string {
    const left = AtelierText.read(a)
    if (left.length > 0) {
      return left
    }
    return AtelierText.read(b)
  }
}

export class CardWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  category: string = ''
  kind: string = ''
  type: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  publishDate: string = ''
  readMinutes: number = 2
  likes: number = 0
  favorites: number = 0
  comments: number = 0
  authorName: string = ''
  userId: string = ''
  authorId: string = ''
}

export class CardListPayload {
  list: CardWire[] = []
}

export class DailyWire {
  id: string = ''
  title: string = ''
  quote: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  dateKey: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  likes: number = 0
  favorites: number = 0
  comments: number = 0
}

export class DailyListPayload {
  list: DailyWire[] = []
}

export class PostWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  category: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  authorName: string = ''
  userId: string = ''
  authorId: string = ''
  likes: number = 0
  favorites: number = 0
  comments: number = 0
  kind: string = ''
  type: string = ''
}

export class PostListPayload {
  list: PostWire[] = []
}

export class FavoriteWire {
  id: string = ''
  title: string = ''
  userId: string = ''
  contentId: string = ''
  contentType: string = ''
  tags: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  category: string = ''
}

export class FavoriteListPayload {
  list: FavoriteWire[] = []
}

export class CommentWire {
  id: string = ''
  title: string = ''
  body: string = ''
  description: string = ''
  userId: string = ''
  authorName: string = ''
  contentId: string = ''
  contentType: string = ''
}

export class CommentListPayload {
  list: CommentWire[] = []
}

export class LikeWire {
  id: string = ''
  title: string = ''
  userId: string = ''
  contentId: string = ''
  contentType: string = ''
}

export class LikeListPayload {
  list: LikeWire[] = []
}

export class LikeResult {
  liked: boolean = false
  id: string = ''
}

export class MsgWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  createdAt: string = ''
}

export class MsgListPayload {
  list: MsgWire[] = []
}

export class CardItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  category: string = 'life'
  kind: string = 'card'
  type: string = 'official'
  coverKey: string = 'cover_life_01'
  publishDate: string = ''
  readMinutes: number = 2
  likes: number = 0
  favorites: number = 0
  comments: number = 0
  authorName: string = ''
  userId: string = ''

  categoryLabel(): string {
    if (this.category === 'business') {
      return '商业'
    }
    if (this.category === 'humanity') {
      return '人文'
    }
    if (this.category === 'tech') {
      return '科技'
    }
    if (this.category === 'art') {
      return '艺术'
    }
    return '生活'
  }

  isPost(): boolean {
    return this.kind === 'post' || this.type === 'user'
  }

  static create(id: string, title: string, summary: string, body: string, category: string,
    coverKey: string, readMinutes: number, publishDate: string): CardItem {
    const item = new CardItem()
    item.id = id
    item.title = title
    item.summary = summary
    item.body = body
    item.category = category
    item.coverKey = coverKey
    item.readMinutes = readMinutes
    item.publishDate = publishDate
    item.kind = 'card'
    item.type = 'official'
    item.authorName = '悦知坊精选'
    return item
  }

  static fromWire(w: CardWire): CardItem {
    const item = new CardItem()
    item.id = AtelierText.read(w.id)
    item.title = AtelierText.read(w.title)
    item.summary = AtelierText.first(w.summary, w.description)
    item.body = AtelierText.first(w.body, w.description)
    const cat = AtelierText.read(w.category)
    item.category = cat.length > 0 ? cat : 'life'
    const kind = AtelierText.read(w.kind)
    item.kind = kind.length > 0 ? kind : 'card'
    const typ = AtelierText.read(w.type)
    item.type = typ.length > 0 ? typ : 'official'
    item.coverKey = AtelierText.first(w.coverMedia, w.coverKey)
    if (item.coverKey.length === 0) {
      item.coverKey = 'cover_life_01'
    }
    item.publishDate = AtelierText.read(w.publishDate)
    const mins = AtelierText.num(w.readMinutes)
    item.readMinutes = mins > 0 ? mins : 2
    item.likes = AtelierText.num(w.likes)
    item.favorites = AtelierText.num(w.favorites)
    item.comments = AtelierText.num(w.comments)
    item.authorName = AtelierText.read(w.authorName)
    item.userId = AtelierText.first(w.userId, w.authorId)
    return item
  }
}

export class DailyItem {
  id: string = ''
  title: string = ''
  quote: string = ''
  body: string = ''
  dateKey: string = ''
  coverKey: string = 'cover_daily_01'
  likes: number = 0
  favorites: number = 0
  comments: number = 0

  static create(id: string, title: string, quote: string, body: string, dateKey: string,
    coverKey: string): DailyItem {
    const item = new DailyItem()
    item.id = id
    item.title = title
    item.quote = quote
    item.body = body
    item.dateKey = dateKey
    item.coverKey = coverKey
    return item
  }

  static fromWire(w: DailyWire): DailyItem {
    const item = new DailyItem()
    item.id = AtelierText.read(w.id)
    item.title = AtelierText.read(w.title)
    item.quote = AtelierText.first(w.quote, w.summary)
    item.body = AtelierText.first(w.body, w.description)
    item.dateKey = AtelierText.read(w.dateKey)
    item.coverKey = AtelierText.first(w.coverMedia, w.coverKey)
    if (item.coverKey.length === 0) {
      item.coverKey = 'cover_daily_01'
    }
    item.likes = AtelierText.num(w.likes)
    item.favorites = AtelierText.num(w.favorites)
    item.comments = AtelierText.num(w.comments)
    return item
  }
}

export class PostItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  category: string = 'life'
  coverKey: string = 'cover_plaza_01'
  authorName: string = ''
  userId: string = ''
  likes: number = 0
  favorites: number = 0
  comments: number = 0

  categoryLabel(): string {
    if (this.category === 'business') {
      return '商业'
    }
    if (this.category === 'humanity') {
      return '人文'
    }
    if (this.category === 'tech') {
      return '科技'
    }
    if (this.category === 'art') {
      return '艺术'
    }
    return '生活'
  }

  static fromWire(w: PostWire): PostItem {
    const item = new PostItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary.length > 0 ? w.summary : w.description
    item.body = w.body.length > 0 ? w.body : w.description
    item.category = w.category.length > 0 ? w.category : 'life'
    if (w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    } else if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    }
    item.authorName = w.authorName.length > 0 ? w.authorName : w.userId
    item.userId = w.userId.length > 0 ? w.userId : w.authorId
    item.likes = w.likes
    item.favorites = w.favorites
    item.comments = w.comments
    return item
  }
}

export class FavoriteItem {
  id: string = ''
  title: string = ''
  userId: string = ''
  contentId: string = ''
  contentType: string = ''
  tags: string = ''
  coverKey: string = 'cover_life_01'
  category: string = 'life'

  tagList(): string[] {
    const out: string[] = []
    const parts = this.tags.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  static fromWire(w: FavoriteWire): FavoriteItem {
    const item = new FavoriteItem()
    item.id = AtelierText.read(w.id)
    item.title = AtelierText.read(w.title)
    item.userId = AtelierText.read(w.userId)
    item.contentId = AtelierText.read(w.contentId)
    const ctype = AtelierText.read(w.contentType)
    item.contentType = ctype.length > 0 ? ctype : 'card'
    item.tags = AtelierText.read(w.tags)
    item.coverKey = AtelierText.first(w.coverMedia, w.coverKey)
    if (item.coverKey.length === 0) {
      item.coverKey = 'cover_life_01'
    }
    item.category = AtelierText.read(w.category)
    return item
  }

  static localOf(userId: string, contentId: string, contentType: string, title: string,
    tags: string, coverMedia: string, category: string): FavoriteItem {
    const item = new FavoriteItem()
    item.id = `local_${contentType}_${contentId}`
    item.title = title
    item.userId = userId
    item.contentId = contentId
    item.contentType = contentType
    item.tags = tags
    item.coverKey = coverMedia
    item.category = category
    return item
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},` +
      `"userId":${JSON.stringify(this.userId)},"contentId":${JSON.stringify(this.contentId)},` +
      `"contentType":${JSON.stringify(this.contentType)},"tags":${JSON.stringify(this.tags)},` +
      `"coverKey":${JSON.stringify(this.coverKey)},"coverMedia":${JSON.stringify(this.coverKey)},` +
      `"category":${JSON.stringify(this.category)}}`
  }
}

export class CommentItem {
  id: string = ''
  body: string = ''
  userId: string = ''
  authorName: string = ''
  contentId: string = ''

  static fromWire(w: CommentWire): CommentItem {
    const item = new CommentItem()
    item.id = w.id
    item.body = w.body.length > 0 ? w.body : w.description
    item.userId = w.userId
    item.authorName = w.authorName.length > 0 ? w.authorName : w.userId
    item.contentId = w.contentId
    return item
  }
}

export class AtelierStats {
  favorites: number = 0
  minutes: number = 0
  works: number = 0
}

export class AtelierTime {
  static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }
}

export class PostCreateBody {
  userId: string = ''
  authorName: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  category: string = 'life'
  coverMedia: string = 'cover_plaza_01'

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"authorName":${JSON.stringify(this.authorName)},` +
      `"title":${JSON.stringify(this.title)},"summary":${JSON.stringify(this.summary)},` +
      `"body":${JSON.stringify(this.body)},"category":${JSON.stringify(this.category)},` +
      `"coverMedia":${JSON.stringify(this.coverMedia)}}`
  }
}

export class FavoriteCreateBody {
  userId: string = ''
  contentId: string = ''
  contentType: string = 'card'
  title: string = ''
  tags: string = ''
  coverMedia: string = ''
  category: string = ''

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"contentId":${JSON.stringify(this.contentId)},` +
      `"contentType":${JSON.stringify(this.contentType)},"title":${JSON.stringify(this.title)},` +
      `"tags":${JSON.stringify(this.tags)},"coverMedia":${JSON.stringify(this.coverMedia)},` +
      `"category":${JSON.stringify(this.category)}}`
  }
}

export class FavoriteTagsBody {
  userId: string = ''
  tags: string = ''

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"tags":${JSON.stringify(this.tags)}}`
  }
}

export class CommentCreateBody {
  userId: string = ''
  authorName: string = ''
  contentId: string = ''
  contentType: string = 'card'
  body: string = ''

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"authorName":${JSON.stringify(this.authorName)},` +
      `"contentId":${JSON.stringify(this.contentId)},"contentType":${JSON.stringify(this.contentType)},` +
      `"body":${JSON.stringify(this.body)}}`
  }
}

export class LikeToggleBody {
  userId: string = ''
  contentId: string = ''
  contentType: string = 'card'
  title: string = ''

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"contentId":${JSON.stringify(this.contentId)},` +
      `"contentType":${JSON.stringify(this.contentType)},"title":${JSON.stringify(this.title)}}`
  }
}

export class ReportCreateBody {
  userId: string = ''
  contentId: string = ''
  contentType: string = 'post'
  reason: string = ''
  title: string = '举报'

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"contentId":${JSON.stringify(this.contentId)},` +
      `"contentType":${JSON.stringify(this.contentType)},"reason":${JSON.stringify(this.reason)},` +
      `"title":${JSON.stringify(this.title)}}`
  }
}
