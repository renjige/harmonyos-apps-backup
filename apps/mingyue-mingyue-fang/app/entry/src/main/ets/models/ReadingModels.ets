/** 读书札语 — 平台 /biz/reading-journal Wire 模型（ArkTS strict） */

export class ReadingItemWire {
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
  recordDate: string = ''
  kind: string = ''
  content: string = ''
  userId: string = ''
  category: string = ''
  color: string = ''
  author: string = ''
  progress: number = 0
  source: string = ''
  bookId: string = ''
  readingMinutes: number = 0
  readStatus: string = ''
  goal: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class FeaturedItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  tags: string[] = []
  recordDate: string = ''
  author: string = ''
  source: string = ''

  static fromWire(w: ReadingItemWire): FeaturedItem {
    const item = new FeaturedItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    const coverKey = w.coverKey ?? ''
    const coverMedia = w.coverMedia ?? ''
    if (coverKey.length > 0) {
      item.coverKey = coverKey
    } else if (coverMedia.length > 0) {
      item.coverKey = coverMedia
    }
    item.tags = w.tags ?? []
    item.recordDate = w.recordDate ?? ''
    item.author = w.author ?? ''
    item.source = w.source ?? ''
    return item
  }
}

export class BookItem {
  id: string = ''
  title: string = ''
  author: string = ''
  summary: string = ''
  description: string = ''
  coverKey: string = ''
  progress: number = 0
  readStatus: string = ''
  tags: string[] = []
  userId: string = ''
  kind: string = ''

  static fromWire(w: ReadingItemWire): BookItem {
    const item = new BookItem()
    item.id = w.id
    item.title = w.title
    item.author = w.author ?? ''
    item.summary = w.summary ?? ''
    item.description = w.description ?? item.summary
    const coverKey = w.coverKey ?? ''
    const coverMedia = w.coverMedia ?? ''
    if (coverKey.length > 0) {
      item.coverKey = coverKey
    } else if (coverMedia.length > 0) {
      item.coverKey = coverMedia
    }
    item.progress = w.progress ?? 0
    item.readStatus = w.readStatus ?? 'reading'
    item.tags = w.tags ?? []
    item.userId = w.userId ?? ''
    item.kind = w.kind ?? ''
    return item
  }
}

export class NoteItem {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  tags: string[] = []
  bookId: string = ''
  recordDate: string = ''
  userId: string = ''

  static fromWire(w: ReadingItemWire): NoteItem {
    const item = new NoteItem()
    item.id = w.id
    item.title = w.title
    item.body = w.body ?? ''
    item.summary = w.summary ?? ''
    item.tags = w.tags ?? []
    item.bookId = w.bookId ?? ''
    item.recordDate = w.recordDate ?? ''
    item.userId = w.userId ?? ''
    return item
  }
}

export class QuoteItem {
  id: string = ''
  title: string = ''
  content: string = ''
  source: string = ''
  bookId: string = ''
  tags: string[] = []
  userId: string = ''
  recordDate: string = ''

  static fromWire(w: ReadingItemWire): QuoteItem {
    const item = new QuoteItem()
    item.id = w.id
    item.title = w.title.length > 0 ? w.title : '札语摘录'
    item.content = w.content ?? ''
    item.source = w.source ?? ''
    item.bookId = w.bookId ?? ''
    item.tags = w.tags ?? []
    item.userId = w.userId ?? ''
    item.recordDate = w.recordDate ?? ''
    return item
  }
}

export class PlanItem {
  id: string = ''
  title: string = ''
  goal: string = ''
  summary: string = ''
  progress: number = 0
  status: string = ''
  userId: string = ''

  static fromWire(w: ReadingItemWire): PlanItem {
    const item = new PlanItem()
    item.id = w.id
    item.title = w.title
    item.goal = w.goal ?? ''
    item.summary = w.summary ?? item.goal
    item.progress = w.progress ?? 0
    item.status = w.status ?? 'published'
    item.userId = w.userId ?? ''
    return item
  }
}

export class ReadingLogItem {
  id: string = ''
  title: string = ''
  bookId: string = ''
  readingMinutes: number = 0
  recordDate: string = ''
  userId: string = ''

  static fromWire(w: ReadingItemWire): ReadingLogItem {
    const item = new ReadingLogItem()
    item.id = w.id
    item.title = w.title.length > 0 ? w.title : '阅读记录'
    item.bookId = w.bookId ?? ''
    item.readingMinutes = w.readingMinutes ?? 0
    item.recordDate = w.recordDate ?? ''
    item.userId = w.userId ?? ''
    return item
  }
}

export class TagPresetItem {
  id: string = ''
  title: string = ''
  color: string = ''

  static fromWire(w: ReadingItemWire): TagPresetItem {
    const item = new TagPresetItem()
    item.id = w.id
    item.title = w.title
    item.color = w.color ?? '#2D5A4A'
    return item
  }
}

export class KpiItem {
  key: string = ''
  label: string = ''
  value: number = 0
}

export class KpiListPayload {
  list: KpiItem[] = []
}

export class MessageItemWire {
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
  type: string = ''
  read: boolean = false
  createdAt: string = ''

  static fromWire(w: MessageItemWire): MessageItem {
    const item = new MessageItem()
    item.id = w.id
    item.title = w.title
    item.body = w.body ?? ''
    item.type = w.type ?? 'system'
    item.read = w.read ?? false
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class MessageListPayload {
  list: MessageItemWire[] = []
}

export class ReadingListPayload {
  list: ReadingItemWire[] = []
}

export class TopTagItem {
  tag: string = ''
  count: number = 0
}

export class ReadingReportData {
  bookCount: number = 0
  noteCount: number = 0
  quoteCount: number = 0
  planCount: number = 0
  totalReadingMinutes: number = 0
  completedBooks: number = 0
  topTags: TopTagItem[] = []
  year: number = 2026
}

export class SearchResultData {
  notes: ReadingItemWire[] = []
  quotes: ReadingItemWire[] = []
  featured: ReadingItemWire[] = []
  query: string = ''
}

export class CreateBookRequest {
  title: string = ''
  author: string = ''
  summary: string = ''
  coverKey: string = 'book_default'
  progress: number = 0
  readStatus: string = 'reading'
  tags: string[] = []
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"author":${JSON.stringify(this.author)},"summary":${JSON.stringify(this.summary)},"coverKey":${JSON.stringify(this.coverKey)},"progress":${this.progress},"readStatus":${JSON.stringify(this.readStatus)},"tags":${JSON.stringify(this.tags)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class PatchBookRequest {
  title: string = ''
  author: string = ''
  summary: string = ''
  coverKey: string = ''
  progress: number = -1
  readStatus: string = ''
  tags: string[] = []

  toJsonString(): string {
    let json = '{'
    let first = true
    if (this.title.length > 0) {
      json += `"title":${JSON.stringify(this.title)}`
      first = false
    }
    if (this.author.length > 0) {
      if (!first) { json += ',' }
      json += `"author":${JSON.stringify(this.author)}`
      first = false
    }
    if (this.summary.length > 0) {
      if (!first) { json += ',' }
      json += `"summary":${JSON.stringify(this.summary)}`
      first = false
    }
    if (this.coverKey.length > 0) {
      if (!first) { json += ',' }
      json += `"coverKey":${JSON.stringify(this.coverKey)}`
      first = false
    }
    if (this.progress >= 0) {
      if (!first) { json += ',' }
      json += `"progress":${this.progress}`
      first = false
    }
    if (this.readStatus.length > 0) {
      if (!first) { json += ',' }
      json += `"readStatus":${JSON.stringify(this.readStatus)}`
    }
    json += '}'
    return json
  }
}

export class CreateNoteRequest {
  title: string = ''
  body: string = ''
  summary: string = ''
  tags: string[] = []
  bookId: string = ''
  recordDate: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"summary":${JSON.stringify(this.summary)},"tags":${JSON.stringify(this.tags)},"bookId":${JSON.stringify(this.bookId)},"recordDate":${JSON.stringify(this.recordDate)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateQuoteRequest {
  title: string = ''
  content: string = ''
  source: string = ''
  bookId: string = ''
  tags: string[] = []
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"content":${JSON.stringify(this.content)},"source":${JSON.stringify(this.source)},"bookId":${JSON.stringify(this.bookId)},"tags":${JSON.stringify(this.tags)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreatePlanRequest {
  title: string = ''
  goal: string = ''
  summary: string = ''
  progress: number = 0
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"goal":${JSON.stringify(this.goal)},"summary":${JSON.stringify(this.summary)},"progress":${this.progress},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class PatchPlanRequest {
  title: string = ''
  goal: string = ''
  summary: string = ''
  progress: number = -1
  status: string = ''

  toJsonString(): string {
    let json = '{'
    let first = true
    if (this.title.length > 0) {
      json += `"title":${JSON.stringify(this.title)}`
      first = false
    }
    if (this.goal.length > 0) {
      if (!first) { json += ',' }
      json += `"goal":${JSON.stringify(this.goal)}`
      first = false
    }
    if (this.summary.length > 0) {
      if (!first) { json += ',' }
      json += `"summary":${JSON.stringify(this.summary)}`
      first = false
    }
    if (this.progress >= 0) {
      if (!first) { json += ',' }
      json += `"progress":${this.progress}`
      first = false
    }
    if (this.status.length > 0) {
      if (!first) { json += ',' }
      json += `"status":${JSON.stringify(this.status)}`
    }
    json += '}'
    return json
  }
}

export class CreateReadingLogRequest {
  title: string = ''
  bookId: string = ''
  readingMinutes: number = 0
  recordDate: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"bookId":${JSON.stringify(this.bookId)},"readingMinutes":${this.readingMinutes},"recordDate":${JSON.stringify(this.recordDate)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class DeleteOkPayload {
  id: string = ''
}
