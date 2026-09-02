/** 书页漫游数据模型（ArkTS 严格模式） */

export class ExcerptWire {
  id: string = ''
  title: string = ''
  bookTitle: string = ''
  author: string = ''
  theme: string = ''
  coverKey: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
}

export class ExcerptListPayload {
  list: ExcerptWire[] = []
}

export class BookListWire {
  id: string = ''
  title: string = ''
  month: string = ''
  coverKey: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  booksJson: string = ''
}

export class BookListListPayload {
  list: BookListWire[] = []
}

export class ListBookWire {
  title: string = ''
  author: string = ''
  coverKey: string = ''
  summary: string = ''
  reason: string = ''
}

export class ExcerptItem {
  id: string = ''
  title: string = ''
  bookTitle: string = ''
  author: string = ''
  theme: string = ''
  coverKey: string = 'cover_literature'
  summary: string = ''
  body: string = ''

  summaryLine(): string {
    if (this.summary.length > 0) {
      return this.summary
    }
    if (this.body.length <= 48) {
      return this.body
    }
    return this.body.substring(0, 48) + '…'
  }

  static fromWire(w: ExcerptWire): ExcerptItem {
    const item = new ExcerptItem()
    item.id = w.id
    item.title = w.title
    item.bookTitle = w.bookTitle
    item.author = w.author
    item.theme = w.theme
    item.coverKey = w.coverKey.length > 0 ? w.coverKey : 'cover_literature'
    item.summary = w.summary.length > 0 ? w.summary : w.description
    item.body = w.body.length > 0 ? w.body : w.description
    return item
  }
}

export class ListBookItem {
  title: string = ''
  author: string = ''
  coverKey: string = 'cover_literature'
  summary: string = ''
  reason: string = ''

  static fromWire(w: ListBookWire): ListBookItem {
    const item = new ListBookItem()
    item.title = w.title
    item.author = w.author
    item.coverKey = w.coverKey.length > 0 ? w.coverKey : 'cover_literature'
    item.summary = w.summary
    item.reason = w.reason
    return item
  }
}

export class BookListItem {
  id: string = ''
  title: string = ''
  month: string = ''
  coverKey: string = 'banner_city'
  summary: string = ''
  books: ListBookItem[] = []

  static fromWire(w: BookListWire): BookListItem {
    const item = new BookListItem()
    item.id = w.id
    item.title = w.title
    item.month = w.month
    item.coverKey = w.coverKey.length > 0 ? w.coverKey : 'banner_city'
    item.summary = w.summary.length > 0 ? w.summary : w.description
    item.books = BookListItem.parseBooks(w.booksJson)
    return item
  }

  static parseBooks(raw: string): ListBookItem[] {
    const out: ListBookItem[] = []
    if (raw.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as ListBookWire[]
      for (const w of parsed) {
        out.push(ListBookItem.fromWire(w))
      }
    } catch {
      return out
    }
    return out
  }
}

export class RoamNoteWire {
  id: string = ''
  excerptId: string = ''
  excerptTitle: string = ''
  bookTitle: string = ''
  body: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}

export class RoamNoteFile {
  items: RoamNoteWire[] = []
}

export class RoamNote {
  id: string = ''
  excerptId: string = ''
  excerptTitle: string = ''
  bookTitle: string = ''
  body: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  previewLine(): string {
    if (this.body.length <= 36) {
      return this.body
    }
    return this.body.substring(0, 36) + '…'
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"excerptId":${JSON.stringify(this.excerptId)},` +
      `"excerptTitle":${JSON.stringify(this.excerptTitle)},"bookTitle":${JSON.stringify(this.bookTitle)},` +
      `"body":${JSON.stringify(this.body)},"createdAt":${this.createdAt},"updatedAt":${this.updatedAt}}`
  }

  static fromWire(w: RoamNoteWire): RoamNote {
    const n = new RoamNote()
    n.id = w.id
    n.excerptId = w.excerptId
    n.excerptTitle = w.excerptTitle
    n.bookTitle = w.bookTitle
    n.body = w.body
    n.createdAt = w.createdAt
    n.updatedAt = w.updatedAt
    return n
  }
}

export class ReadLogWire {
  id: string = ''
  excerptId: string = ''
  bookTitle: string = ''
  theme: string = ''
  action: string = ''
  at: number = 0
}

export class ReadLogFile {
  items: ReadLogWire[] = []
}

/** 用户阅读轨迹条目（本机） */
export class ReadLogEntry {
  id: string = ''
  excerptId: string = ''
  bookTitle: string = ''
  theme: string = ''
  action: string = ''
  at: number = 0

  actionLabel(): string {
    if (this.action === 'favorite') {
      return '收藏'
    }
    if (this.action === 'readLater') {
      return '稍后读'
    }
    if (this.action === 'finished') {
      return '读完'
    }
    return '阅读'
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"excerptId":${JSON.stringify(this.excerptId)},` +
      `"bookTitle":${JSON.stringify(this.bookTitle)},"theme":${JSON.stringify(this.theme)},` +
      `"action":${JSON.stringify(this.action)},"at":${this.at}}`
  }

  static fromWire(w: ReadLogWire): ReadLogEntry {
    const e = new ReadLogEntry()
    e.id = w.id
    e.excerptId = w.excerptId
    e.bookTitle = w.bookTitle
    e.theme = w.theme
    e.action = w.action
    e.at = w.at
    return e
  }
}

export class ThemeTagCount {
  tag: string = ''
  count: number = 0
}

export class RoamStats {
  favorites: number = 0
  readLater: number = 0
  finished: number = 0
  notes: number = 0
  readDays: number = 0
}

export class RoamTime {
  static dayOfYear(): number {
    const now = new Date()
    const start = new Date(now.getFullYear(), 0, 0)
    const diff = now.getTime() - start.getTime()
    return Math.floor(diff / 86400000)
  }

  static formatDate(ts: number): string {
    const d = new Date(ts)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static formatDateTime(ts: number): string {
    const d = new Date(ts)
    const h = d.getHours()
    const min = d.getMinutes()
    const hs = h < 10 ? `0${h}` : `${h}`
    const mins = min < 10 ? `0${min}` : `${min}`
    return `${RoamTime.formatDate(ts)} ${hs}:${mins}`
  }
}
