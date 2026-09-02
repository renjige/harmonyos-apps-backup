/** 墨香小筑数据模型（ArkTS 严格模式） */

export class CatalogWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  source: string = ''
  author: string = ''
  authorName: string = ''
  dynasty: string = ''
  theme: string = ''
  matchTags: string = ''
  annotation: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  booksJson: string = ''
  excerptId: string = ''
  userId: string = ''
  category: string = ''
  dateKey: string = ''
  mood: string = ''
  remark: string = ''
  createdAt: string = ''
}

export class CatalogListPayload {
  list: CatalogWire[] = []
}

export class ListBookItem {
  title: string = ''
  hint: string = ''
}

export class ExcerptItem {
  id: string = ''
  title: string = ''
  source: string = ''
  author: string = ''
  dynasty: string = ''
  theme: string = ''
  matchTags: string = ''
  annotation: string = ''
  coverKey: string = 'cover_ex_lunyu'
  summary: string = ''
  body: string = ''

  static fromWire(w: CatalogWire): ExcerptItem {
    const item = new ExcerptItem()
    item.id = w.id
    item.title = w.title
    item.source = w.source.length > 0 ? w.source : w.subtitle
    item.author = w.author
    item.dynasty = w.dynasty
    item.theme = w.theme
    item.matchTags = w.matchTags
    item.annotation = w.annotation
    item.coverKey = w.coverKey.length > 0 ? w.coverKey : (w.coverMedia.length > 0 ? w.coverMedia : 'cover_ex_lunyu')
    item.summary = w.summary.length > 0 ? w.summary : w.description
    item.body = w.body.length > 0 ? w.body : w.description
    return item
  }
}

export class BookListItem {
  id: string = ''
  title: string = ''
  theme: string = ''
  matchTags: string = ''
  coverKey: string = 'cover_list_xiushen'
  summary: string = ''
  description: string = ''
  books: ListBookItem[] = []

  static fromWire(w: CatalogWire): BookListItem {
    const item = new BookListItem()
    item.id = w.id
    item.title = w.title
    item.theme = w.theme.length > 0 ? w.theme : w.subtitle
    item.matchTags = w.matchTags
    item.coverKey = w.coverKey.length > 0 ? w.coverKey : 'cover_list_xiushen'
    item.summary = w.summary.length > 0 ? w.summary : w.description
    item.description = w.description.length > 0 ? w.description : w.body
    item.books = BookListItem.parseBooks(w.booksJson)
    return item
  }

  static parseBooks(raw: string): ListBookItem[] {
    const out: ListBookItem[] = []
    if (raw.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as ListBookItem[]
      for (const row of parsed) {
        const b = new ListBookItem()
        b.title = row.title
        b.hint = row.hint
        out.push(b)
      }
    } catch {
      return out
    }
    return out
  }
}

export class EssayItem {
  id: string = ''
  title: string = ''
  authorName: string = ''
  excerptId: string = ''
  coverKey: string = 'cover_essay_01'
  summary: string = ''
  body: string = ''

  static fromWire(w: CatalogWire): EssayItem {
    const item = new EssayItem()
    item.id = w.id
    item.title = w.title
    item.authorName = w.authorName.length > 0 ? w.authorName : w.subtitle
    item.excerptId = w.excerptId
    item.coverKey = w.coverKey.length > 0 ? w.coverKey : 'cover_essay_01'
    item.summary = w.summary
    item.body = w.body.length > 0 ? w.body : w.description
    return item
  }
}

export class UserRecordItem {
  id: string = ''
  title: string = ''
  body: string = ''
  excerptId: string = ''
  category: string = ''
  dateKey: string = ''
  mood: string = ''
  remark: string = ''
  createdAt: string = ''

  previewLine(): string {
    const src = this.body.length > 0 ? this.body : this.remark
    if (src.length <= 36) {
      return src
    }
    return src.substring(0, 36) + '…'
  }

  static fromWire(w: CatalogWire): UserRecordItem {
    const item = new UserRecordItem()
    item.id = w.id
    item.title = w.title
    item.body = w.body.length > 0 ? w.body : w.description
    item.excerptId = w.excerptId
    item.category = w.category
    item.dateKey = w.dateKey
    item.mood = w.mood
    item.remark = w.remark
    item.createdAt = w.createdAt
    return item
  }
}

export class InkWriteRequest {
  userId: string = ''
  title: string = ''
  body: string = ''
  excerptId: string = ''
  category: string = ''
  dateKey: string = ''
  mood: string = ''
  remark: string = ''

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"title":${JSON.stringify(this.title)},` +
      `"body":${JSON.stringify(this.body)},"excerptId":${JSON.stringify(this.excerptId)},` +
      `"category":${JSON.stringify(this.category)},"dateKey":${JSON.stringify(this.dateKey)},` +
      `"mood":${JSON.stringify(this.mood)},"remark":${JSON.stringify(this.remark)}}`
  }
}

export class MessageWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  createdAt: string = ''
}

export class MessageListPayload {
  list: MessageWire[] = []
}

export class InkTime {
  static dayOfYear(): number {
    const now = new Date()
    const start = new Date(now.getFullYear(), 0, 0)
    return Math.floor((now.getTime() - start.getTime()) / 86400000)
  }

  static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }
}
