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
  pageCount: number = 0
  currentPage: number = 0
  comment: string = ''
  deadline: string = ''
  rating: number = 0
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
  category: string = ''
  pageCount: number = 0
  currentPage: number = 0

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
    item.category = w.category ?? ''
    item.pageCount = w.pageCount ?? 0
    item.currentPage = w.currentPage ?? 0
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
  coverKey: string = ''
  kind: string = ''

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
    item.coverKey = w.coverKey ?? w.coverMedia ?? 'note_scene_desk'
    item.kind = w.kind ?? 'note'
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
  comment: string = ''

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
    item.comment = w.comment ?? ''
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
  deadline: string = ''
  dailyMinutes: number = 0

  static fromWire(w: ReadingItemWire): PlanItem {
    const item = new PlanItem()
    item.id = w.id
    item.title = w.title
    item.goal = w.goal ?? ''
    item.summary = w.summary ?? item.goal
    item.progress = w.progress ?? 0
    item.status = w.status ?? 'published'
    item.userId = w.userId ?? ''
    item.deadline = w.deadline ?? w.recordDate ?? ''
    item.dailyMinutes = w.readingMinutes ?? 0
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
  checkinDays: number = 0
  streakDays: number = 0
  reviewCount: number = 0
  inspirationCount: number = 0
}

export class SearchResultData {
  notes: ReadingItemWire[] = []
  quotes: ReadingItemWire[] = []
  featured: ReadingItemWire[] = []
  reviews: ReadingItemWire[] = []
  inspirations: ReadingItemWire[] = []
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
  category: string = ''
  pageCount: number = 0
  currentPage: number = 0

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"author":${JSON.stringify(this.author)},"summary":${JSON.stringify(this.summary)},"coverKey":${JSON.stringify(this.coverKey)},"progress":${this.progress},"readStatus":${JSON.stringify(this.readStatus)},"tags":${JSON.stringify(this.tags)},"userId":${JSON.stringify(this.userId)},"category":${JSON.stringify(this.category)},"pageCount":${this.pageCount},"currentPage":${this.currentPage}}`
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
  category: string = ''
  pageCount: number = -1
  currentPage: number = -1

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
      first = false
    }
    if (this.category.length > 0) {
      if (!first) { json += ',' }
      json += `"category":${JSON.stringify(this.category)}`
      first = false
    }
    if (this.pageCount >= 0) {
      if (!first) { json += ',' }
      json += `"pageCount":${this.pageCount}`
      first = false
    }
    if (this.currentPage >= 0) {
      if (!first) { json += ',' }
      json += `"currentPage":${this.currentPage}`
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
  coverKey: string = 'note_scene_desk'
  kind: string = 'note'

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"summary":${JSON.stringify(this.summary)},"tags":${JSON.stringify(this.tags)},"bookId":${JSON.stringify(this.bookId)},"recordDate":${JSON.stringify(this.recordDate)},"userId":${JSON.stringify(this.userId)},"coverKey":${JSON.stringify(this.coverKey)},"kind":${JSON.stringify(this.kind)}}`
  }
}

export class PatchNoteRequest {
  title: string = ''
  body: string = ''
  summary: string = ''
  tags: string[] = []
  recordDate: string = ''
  coverKey: string = ''
  kind: string = ''

  toJsonString(): string {
    let json = '{'
    let first = true
    if (this.title.length > 0) {
      json += `"title":${JSON.stringify(this.title)}`
      first = false
    }
    if (this.body.length > 0) {
      if (!first) { json += ',' }
      json += `"body":${JSON.stringify(this.body)}`
      first = false
    }
    if (this.summary.length > 0) {
      if (!first) { json += ',' }
      json += `"summary":${JSON.stringify(this.summary)}`
      first = false
    }
    if (this.tags.length > 0) {
      if (!first) { json += ',' }
      json += `"tags":${JSON.stringify(this.tags)}`
      first = false
    }
    if (this.recordDate.length > 0) {
      if (!first) { json += ',' }
      json += `"recordDate":${JSON.stringify(this.recordDate)}`
      first = false
    }
    if (this.coverKey.length > 0) {
      if (!first) { json += ',' }
      json += `"coverKey":${JSON.stringify(this.coverKey)}`
      first = false
    }
    if (this.kind.length > 0) {
      if (!first) { json += ',' }
      json += `"kind":${JSON.stringify(this.kind)}`
    }
    json += '}'
    return json
  }
}

export class CreateQuoteRequest {
  title: string = ''
  content: string = ''
  source: string = ''
  bookId: string = ''
  tags: string[] = []
  userId: string = ''
  comment: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"content":${JSON.stringify(this.content)},"source":${JSON.stringify(this.source)},"bookId":${JSON.stringify(this.bookId)},"tags":${JSON.stringify(this.tags)},"userId":${JSON.stringify(this.userId)},"comment":${JSON.stringify(this.comment)}}`
  }
}

export class CreatePlanRequest {
  title: string = ''
  goal: string = ''
  summary: string = ''
  progress: number = 0
  userId: string = ''
  deadline: string = ''
  readingMinutes: number = 0

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"goal":${JSON.stringify(this.goal)},"summary":${JSON.stringify(this.summary)},"progress":${this.progress},"userId":${JSON.stringify(this.userId)},"deadline":${JSON.stringify(this.deadline)},"readingMinutes":${this.readingMinutes}}`
  }
}

export class PatchPlanRequest {
  title: string = ''
  goal: string = ''
  summary: string = ''
  progress: number = -1
  status: string = ''
  deadline: string = ''
  readingMinutes: number = -1

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
      first = false
    }
    if (this.deadline.length > 0) {
      if (!first) { json += ',' }
      json += `"deadline":${JSON.stringify(this.deadline)}`
      first = false
    }
    if (this.readingMinutes >= 0) {
      if (!first) { json += ',' }
      json += `"readingMinutes":${this.readingMinutes}`
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

export class CheckinItem {
  id: string = ''
  title: string = ''
  bookId: string = ''
  readingMinutes: number = 0
  recordDate: string = ''
  comment: string = ''
  userId: string = ''

  static fromWire(w: ReadingItemWire): CheckinItem {
    const item = new CheckinItem()
    item.id = w.id
    item.title = w.title.length > 0 ? w.title : '阅读打卡'
    item.bookId = w.bookId ?? ''
    item.readingMinutes = w.readingMinutes ?? 0
    item.recordDate = w.recordDate ?? ''
    item.comment = w.comment ?? ''
    item.userId = w.userId ?? ''
    return item
  }
}

export class CheckinFeedData {
  list: ReadingItemWire[] = []
  streakDays: number = 0
  checkedToday: boolean = false
  checkinCount: number = 0
}

export class ReviewItem {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  bookId: string = ''
  rating: number = 5
  coverKey: string = 'review_cover'
  userId: string = ''
  recordDate: string = ''

  static fromWire(w: ReadingItemWire): ReviewItem {
    const item = new ReviewItem()
    item.id = w.id
    item.title = w.title
    item.body = w.body ?? ''
    item.summary = w.summary ?? ''
    item.bookId = w.bookId ?? ''
    item.rating = w.rating ?? 5
    item.coverKey = w.coverKey ?? 'review_cover'
    item.userId = w.userId ?? ''
    item.recordDate = w.recordDate ?? ''
    return item
  }
}

export class BooklistItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  category: string = ''
  coverKey: string = 'booklist_growth'
  tags: string[] = []
  kind: string = ''
  userId: string = ''

  static fromWire(w: ReadingItemWire): BooklistItem {
    const item = new BooklistItem()
    item.id = w.id
    item.title = w.title
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    item.category = w.category ?? ''
    item.coverKey = w.coverKey ?? w.coverMedia ?? 'booklist_growth'
    item.tags = w.tags ?? []
    item.kind = w.kind ?? ''
    item.userId = w.userId ?? ''
    return item
  }
}

export class InspirationItem {
  id: string = ''
  title: string = ''
  content: string = ''
  bookId: string = ''
  tags: string[] = []
  coverKey: string = 'inspiration_cover'
  userId: string = ''
  recordDate: string = ''

  static fromWire(w: ReadingItemWire): InspirationItem {
    const item = new InspirationItem()
    item.id = w.id
    item.title = w.title.length > 0 ? w.title : '阅读灵感'
    item.content = w.content ?? w.body ?? ''
    item.bookId = w.bookId ?? ''
    item.tags = w.tags ?? []
    item.coverKey = w.coverKey ?? 'inspiration_cover'
    item.userId = w.userId ?? ''
    item.recordDate = w.recordDate ?? ''
    return item
  }
}

export class MonthlyReviewData {
  month: string = ''
  checkinDays: number = 0
  logCount: number = 0
  totalMinutes: number = 0
  noteCount: number = 0
  quoteCount: number = 0
  reviewCount: number = 0
  inspirationCount: number = 0
  completedBooks: number = 0
  summary: string = ''
}

export class CreateCheckinRequest {
  title: string = ''
  bookId: string = ''
  readingMinutes: number = 25
  recordDate: string = ''
  userId: string = ''
  comment: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"bookId":${JSON.stringify(this.bookId)},"readingMinutes":${this.readingMinutes},"recordDate":${JSON.stringify(this.recordDate)},"userId":${JSON.stringify(this.userId)},"comment":${JSON.stringify(this.comment)}}`
  }
}

export class CreateReviewRequest {
  title: string = ''
  body: string = ''
  summary: string = ''
  bookId: string = ''
  rating: number = 5
  userId: string = ''
  coverKey: string = 'review_cover'

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"summary":${JSON.stringify(this.summary)},"bookId":${JSON.stringify(this.bookId)},"rating":${this.rating},"userId":${JSON.stringify(this.userId)},"coverKey":${JSON.stringify(this.coverKey)}}`
  }
}

export class CreateBooklistRequest {
  title: string = ''
  summary: string = ''
  body: string = ''
  category: string = '兴趣阅读'
  tags: string[] = []
  coverKey: string = 'booklist_growth'
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"summary":${JSON.stringify(this.summary)},"body":${JSON.stringify(this.body)},"category":${JSON.stringify(this.category)},"tags":${JSON.stringify(this.tags)},"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateInspirationRequest {
  title: string = ''
  content: string = ''
  bookId: string = ''
  tags: string[] = []
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"content":${JSON.stringify(this.content)},"bookId":${JSON.stringify(this.bookId)},"tags":${JSON.stringify(this.tags)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateCustomTagRequest {
  title: string = ''
  color: string = '#2D5A4A'
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"color":${JSON.stringify(this.color)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class PatchQuoteRequest {
  title: string = ''
  content: string = ''
  source: string = ''
  comment: string = ''

  toJsonString(): string {
    let json = '{'
    let first = true
    if (this.title.length > 0) {
      json += `"title":${JSON.stringify(this.title)}`
      first = false
    }
    if (this.content.length > 0) {
      if (!first) { json += ',' }
      json += `"content":${JSON.stringify(this.content)}`
      first = false
    }
    if (this.source.length > 0) {
      if (!first) { json += ',' }
      json += `"source":${JSON.stringify(this.source)}`
      first = false
    }
    if (this.comment.length > 0) {
      if (!first) { json += ',' }
      json += `"comment":${JSON.stringify(this.comment)}`
    }
    json += '}'
    return json
  }
}

export class BookCategoryUtil {
  static all(): string[] {
    const list: string[] = []
    list.push('文学作品')
    list.push('历史文化')
    list.push('科普知识')
    list.push('学习提升')
    list.push('兴趣阅读')
    return list
  }

  static insightTags(): string[] {
    const list: string[] = []
    list.push('成长')
    list.push('思考')
    list.push('感悟')
    list.push('灵感')
    list.push('推荐')
    return list
  }

  static noteScenes(): string[] {
    const list: string[] = []
    list.push('note_scene_desk')
    list.push('note_scene_window')
    list.push('note_scene_lamp')
    return list
  }

  static sceneLabel(key: string): string {
    if (key === 'note_scene_window') {
      return '窗边'
    }
    if (key === 'note_scene_lamp') {
      return '灯下'
    }
    return '书桌'
  }
}
