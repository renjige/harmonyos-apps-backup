import { HttpClient } from './HttpClient'
import {
  BookItem,
  BooklistItem,
  CheckinFeedData,
  CheckinItem,
  CreateBooklistRequest,
  CreateBookRequest,
  CreateCheckinRequest,
  CreateCustomTagRequest,
  CreateInspirationRequest,
  CreateNoteRequest,
  CreatePlanRequest,
  CreateQuoteRequest,
  CreateReadingLogRequest,
  CreateReviewRequest,
  DeleteOkPayload,
  FeaturedItem,
  InspirationItem,
  KpiItem,
  KpiListPayload,
  MessageItem,
  MessageListPayload,
  MonthlyReviewData,
  NoteItem,
  PatchBookRequest,
  PatchNoteRequest,
  PatchPlanRequest,
  PatchQuoteRequest,
  PlanItem,
  QuoteItem,
  ReadingItemWire,
  ReadingListPayload,
  ReadingLogItem,
  ReadingReportData,
  ReviewItem,
  SearchResultData,
  TagPresetItem
} from '../models/ReadingModels'

export class ReadingBizService {
  static lastError: string = ''

  private static userId(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  private static mapFeatured(wires: ReadingItemWire[]): FeaturedItem[] {
    const out: FeaturedItem[] = []
    for (const w of wires) {
      out.push(FeaturedItem.fromWire(w))
    }
    return out
  }

  private static mapBooks(wires: ReadingItemWire[]): BookItem[] {
    const out: BookItem[] = []
    for (const w of wires) {
      out.push(BookItem.fromWire(w))
    }
    return out
  }

  private static mapNotes(wires: ReadingItemWire[]): NoteItem[] {
    const out: NoteItem[] = []
    for (const w of wires) {
      out.push(NoteItem.fromWire(w))
    }
    return out
  }

  private static mapQuotes(wires: ReadingItemWire[]): QuoteItem[] {
    const out: QuoteItem[] = []
    for (const w of wires) {
      out.push(QuoteItem.fromWire(w))
    }
    return out
  }

  private static mapPlans(wires: ReadingItemWire[]): PlanItem[] {
    const out: PlanItem[] = []
    for (const w of wires) {
      out.push(PlanItem.fromWire(w))
    }
    return out
  }

  private static mapLogs(wires: ReadingItemWire[]): ReadingLogItem[] {
    const out: ReadingLogItem[] = []
    for (const w of wires) {
      out.push(ReadingLogItem.fromWire(w))
    }
    return out
  }

  static async loadFeatured(): Promise<FeaturedItem[]> {
    const res = await HttpClient.get<ReadingListPayload>('/biz/reading-journal/featured')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return ReadingBizService.mapFeatured(res.data.list)
    }
    return []
  }

  static async findFeatured(id: string): Promise<FeaturedItem | undefined> {
    const res = await HttpClient.get<ReadingItemWire>(`/biz/reading-journal/featured/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return FeaturedItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadBookShowcase(): Promise<BookItem[]> {
    const res = await HttpClient.get<ReadingListPayload>('/biz/reading-journal/book-showcase')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return ReadingBizService.mapBooks(res.data.list)
    }
    return []
  }

  static async findBookShowcase(id: string): Promise<BookItem | undefined> {
    const res = await HttpClient.get<ReadingItemWire>(`/biz/reading-journal/book-showcase/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return BookItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadBooks(userId: string): Promise<BookItem[]> {
    const uid = userId.length > 0 ? userId : ReadingBizService.userId()
    let path = '/biz/reading-journal/books'
    if (uid.length > 0) {
      path += `?userId=${encodeURIComponent(uid)}`
    }
    const res = await HttpClient.get<ReadingListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return ReadingBizService.mapBooks(res.data.list)
    }
    return []
  }

  static async findBook(id: string): Promise<BookItem | undefined> {
    const res = await HttpClient.get<ReadingItemWire>(`/biz/reading-journal/books/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return BookItem.fromWire(res.data)
    }
    return undefined
  }

  static async createBook(req: CreateBookRequest): Promise<BookItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = ReadingBizService.userId()
    }
    const res = await HttpClient.post<ReadingItemWire>('/biz/reading-journal/books', req)
    if (res.code === 0 && res.data !== undefined) {
      return BookItem.fromWire(res.data)
    }
    return undefined
  }

  static async patchBook(id: string, req: PatchBookRequest): Promise<BookItem | undefined> {
    ReadingBizService.lastError = ''
    const res = await HttpClient.postJson<ReadingItemWire>(
      `/biz/reading-journal/books/${id}/progress`,
      req.toJsonString()
    )
    if (res.code === 0) {
      try {
        if (res.data !== undefined && res.data !== null) {
          return BookItem.fromWire(res.data)
        }
      } catch {
        const fallback = new BookItem()
        fallback.id = id
        fallback.progress = req.progress >= 0 ? req.progress : 0
        fallback.readStatus = req.readStatus
        return fallback
      }
    }
    if (res.message !== undefined && res.message.length > 0) {
      ReadingBizService.lastError = res.message
    } else {
      ReadingBizService.lastError = '更新失败，请稍后重试'
    }
    return undefined
  }

  static async removeFromShelf(id: string): Promise<boolean> {
    ReadingBizService.lastError = ''
    const uid = ReadingBizService.userId()
    const res = await HttpClient.postJson<DeleteOkPayload>(
      `/biz/reading-journal/books/${id}/remove`,
      `{"userId":${JSON.stringify(uid)}}`
    )
    if (res.code === 0) {
      return true
    }
    if (res.message !== undefined && res.message.length > 0) {
      ReadingBizService.lastError = res.message
    } else {
      ReadingBizService.lastError = '移除失败，请稍后重试'
    }
    return false
  }

  static async loadNotes(userId: string, tag: string, bookId: string): Promise<NoteItem[]> {
    const uid = userId.length > 0 ? userId : ReadingBizService.userId()
    if (uid.length === 0) {
      return []
    }
    let path = `/biz/reading-journal/notes?userId=${encodeURIComponent(uid)}`
    if (tag.length > 0) {
      path += `&tag=${encodeURIComponent(tag)}`
    }
    if (bookId.length > 0) {
      path += `&bookId=${encodeURIComponent(bookId)}`
    }
    const res = await HttpClient.get<ReadingListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return ReadingBizService.mapNotes(res.data.list)
    }
    return []
  }

  static async findNote(id: string): Promise<NoteItem | undefined> {
    const res = await HttpClient.get<ReadingItemWire>(`/biz/reading-journal/notes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return NoteItem.fromWire(res.data)
    }
    return undefined
  }

  static async createNote(req: CreateNoteRequest): Promise<NoteItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = ReadingBizService.userId()
    }
    const res = await HttpClient.post<ReadingItemWire>('/biz/reading-journal/notes', req)
    if (res.code === 0 && res.data !== undefined) {
      return NoteItem.fromWire(res.data)
    }
    return undefined
  }

  static async patchNote(id: string, req: PatchNoteRequest): Promise<NoteItem | undefined> {
    ReadingBizService.lastError = ''
    const res = await HttpClient.postJson<ReadingItemWire>(
      `/biz/reading-journal/notes/${id}/update`,
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined) {
      return NoteItem.fromWire(res.data)
    }
    if (res.message !== undefined && res.message.length > 0) {
      ReadingBizService.lastError = res.message
    }
    return undefined
  }

  static async deleteNote(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/reading-journal/notes/${id}`)
    return res.code === 0
  }

  static async loadQuotes(userId: string, bookId: string): Promise<QuoteItem[]> {
    const uid = userId.length > 0 ? userId : ReadingBizService.userId()
    if (uid.length === 0) {
      return []
    }
    let path = `/biz/reading-journal/quotes?userId=${encodeURIComponent(uid)}`
    if (bookId.length > 0) {
      path += `&bookId=${encodeURIComponent(bookId)}`
    }
    const res = await HttpClient.get<ReadingListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return ReadingBizService.mapQuotes(res.data.list)
    }
    return []
  }

  static async findQuote(id: string): Promise<QuoteItem | undefined> {
    const res = await HttpClient.get<ReadingItemWire>(`/biz/reading-journal/quotes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return QuoteItem.fromWire(res.data)
    }
    return undefined
  }

  static async createQuote(req: CreateQuoteRequest): Promise<QuoteItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = ReadingBizService.userId()
    }
    const res = await HttpClient.post<ReadingItemWire>('/biz/reading-journal/quotes', req)
    if (res.code === 0 && res.data !== undefined) {
      return QuoteItem.fromWire(res.data)
    }
    return undefined
  }

  static async deleteQuote(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/reading-journal/quotes/${id}`)
    return res.code === 0
  }

  static async loadPlans(userId: string): Promise<PlanItem[]> {
    const uid = userId.length > 0 ? userId : ReadingBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<ReadingListPayload>(
      `/biz/reading-journal/plans?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return ReadingBizService.mapPlans(res.data.list)
    }
    return []
  }

  static async findPlan(id: string): Promise<PlanItem | undefined> {
    const res = await HttpClient.get<ReadingItemWire>(`/biz/reading-journal/plans/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return PlanItem.fromWire(res.data)
    }
    return undefined
  }

  static async createPlan(req: CreatePlanRequest): Promise<PlanItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = ReadingBizService.userId()
    }
    const res = await HttpClient.post<ReadingItemWire>('/biz/reading-journal/plans', req)
    if (res.code === 0 && res.data !== undefined) {
      return PlanItem.fromWire(res.data)
    }
    return undefined
  }

  static async patchPlan(id: string, req: PatchPlanRequest): Promise<PlanItem | undefined> {
    ReadingBizService.lastError = ''
    const res = await HttpClient.postJson<ReadingItemWire>(
      `/biz/reading-journal/plans/${id}/progress`,
      req.toJsonString()
    )
    if (res.code === 0) {
      try {
        if (res.data !== undefined && res.data !== null) {
          return PlanItem.fromWire(res.data)
        }
      } catch {
        const fallback = new PlanItem()
        fallback.id = id
        fallback.progress = req.progress >= 0 ? req.progress : 0
        return fallback
      }
    }
    if (res.message !== undefined && res.message.length > 0) {
      ReadingBizService.lastError = res.message
    } else {
      ReadingBizService.lastError = '更新失败，请稍后重试'
    }
    return undefined
  }

  static async deletePlan(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/reading-journal/plans/${id}`)
    return res.code === 0
  }

  static async loadReadingLogs(userId: string, bookId: string): Promise<ReadingLogItem[]> {
    const uid = userId.length > 0 ? userId : ReadingBizService.userId()
    if (uid.length === 0) {
      return []
    }
    let path = `/biz/reading-journal/reading-logs?userId=${encodeURIComponent(uid)}`
    if (bookId.length > 0) {
      path += `&bookId=${encodeURIComponent(bookId)}`
    }
    const res = await HttpClient.get<ReadingListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return ReadingBizService.mapLogs(res.data.list)
    }
    return []
  }

  static async createReadingLog(req: CreateReadingLogRequest): Promise<ReadingLogItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = ReadingBizService.userId()
    }
    const res = await HttpClient.post<ReadingItemWire>('/biz/reading-journal/reading-logs', req)
    if (res.code === 0 && res.data !== undefined) {
      return ReadingLogItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadReadingReport(userId: string, year: number): Promise<ReadingReportData> {
    const uid = userId.length > 0 ? userId : ReadingBizService.userId()
    let path = `/biz/reading-journal/reading-report?year=${year}`
    if (uid.length > 0) {
      path += `&userId=${encodeURIComponent(uid)}`
    }
    const res = await HttpClient.get<ReadingReportData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    const empty = new ReadingReportData()
    empty.year = year
    return empty
  }

  static async search(q: string, userId: string): Promise<SearchResultData> {
    const uid = userId.length > 0 ? userId : ReadingBizService.userId()
    let path = `/biz/reading-journal/search?q=${encodeURIComponent(q)}`
    if (uid.length > 0) {
      path += `&userId=${encodeURIComponent(uid)}`
    }
    const res = await HttpClient.get<SearchResultData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    const empty = new SearchResultData()
    empty.query = q
    return empty
  }

  static async loadTagPresets(): Promise<TagPresetItem[]> {
    const res = await HttpClient.get<ReadingListPayload>('/biz/reading-journal/tag-presets')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: TagPresetItem[] = []
      for (const w of res.data.list) {
        out.push(TagPresetItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async loadKpis(): Promise<KpiItem[]> {
    const res = await HttpClient.get<KpiListPayload>('/biz/reading-journal/kpis')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadMessages(): Promise<MessageItem[]> {
    const res = await HttpClient.get<MessageListPayload>('/messages')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: MessageItem[] = []
      for (const w of res.data.list) {
        out.push(MessageItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async loadCheckinFeed(): Promise<CheckinFeedData> {
    const uid = ReadingBizService.userId()
    let path = '/biz/reading-journal/checkins'
    if (uid.length > 0) {
      path += `?userId=${encodeURIComponent(uid)}`
    }
    const res = await HttpClient.get<CheckinFeedData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    return new CheckinFeedData()
  }

  static mapCheckins(wires: ReadingItemWire[]): CheckinItem[] {
    const out: CheckinItem[] = []
    for (const w of wires) {
      out.push(CheckinItem.fromWire(w))
    }
    return out
  }

  static async createCheckin(req: CreateCheckinRequest): Promise<CheckinItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = ReadingBizService.userId()
    }
    const res = await HttpClient.postJson<ReadingItemWire>(
      '/biz/reading-journal/checkins',
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined) {
      return CheckinItem.fromWire(res.data)
    }
    return undefined
  }

  static async findCheckin(id: string): Promise<CheckinItem | undefined> {
    const res = await HttpClient.get<ReadingItemWire>(`/biz/reading-journal/checkins/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CheckinItem.fromWire(res.data)
    }
    return undefined
  }

  static async deleteCheckin(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/reading-journal/checkins/${id}`)
    return res.code === 0
  }

  static async loadReviews(bookId: string): Promise<ReviewItem[]> {
    const uid = ReadingBizService.userId()
    if (uid.length === 0) {
      return []
    }
    let path = `/biz/reading-journal/reviews?userId=${encodeURIComponent(uid)}`
    if (bookId.length > 0) {
      path += `&bookId=${encodeURIComponent(bookId)}`
    }
    const res = await HttpClient.get<ReadingListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: ReviewItem[] = []
      for (const w of res.data.list) {
        out.push(ReviewItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findReview(id: string): Promise<ReviewItem | undefined> {
    const res = await HttpClient.get<ReadingItemWire>(`/biz/reading-journal/reviews/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return ReviewItem.fromWire(res.data)
    }
    return undefined
  }

  static async createReview(req: CreateReviewRequest): Promise<ReviewItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = ReadingBizService.userId()
    }
    const res = await HttpClient.postJson<ReadingItemWire>(
      '/biz/reading-journal/reviews',
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined) {
      return ReviewItem.fromWire(res.data)
    }
    return undefined
  }

  static async deleteReview(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/reading-journal/reviews/${id}`)
    return res.code === 0
  }

  static async loadBooklists(): Promise<BooklistItem[]> {
    const uid = ReadingBizService.userId()
    let path = '/biz/reading-journal/booklists'
    if (uid.length > 0) {
      path += `?userId=${encodeURIComponent(uid)}`
    }
    const res = await HttpClient.get<ReadingListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: BooklistItem[] = []
      for (const w of res.data.list) {
        out.push(BooklistItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findBooklist(id: string): Promise<BooklistItem | undefined> {
    const res = await HttpClient.get<ReadingItemWire>(`/biz/reading-journal/booklists/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return BooklistItem.fromWire(res.data)
    }
    return undefined
  }

  static async createBooklist(req: CreateBooklistRequest): Promise<BooklistItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = ReadingBizService.userId()
    }
    const res = await HttpClient.postJson<ReadingItemWire>(
      '/biz/reading-journal/booklists',
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined) {
      return BooklistItem.fromWire(res.data)
    }
    return undefined
  }

  static async collectBooklist(id: string): Promise<BooklistItem | undefined> {
    const uid = ReadingBizService.userId()
    const res = await HttpClient.postJson<ReadingItemWire>(
      `/biz/reading-journal/booklists/${id}/collect`,
      `{"userId":${JSON.stringify(uid)}}`
    )
    if (res.code === 0 && res.data !== undefined) {
      return BooklistItem.fromWire(res.data)
    }
    return undefined
  }

  static async deleteBooklist(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/reading-journal/booklists/${id}`)
    return res.code === 0
  }

  static async loadInspirations(bookId: string): Promise<InspirationItem[]> {
    const uid = ReadingBizService.userId()
    if (uid.length === 0) {
      return []
    }
    let path = `/biz/reading-journal/inspirations?userId=${encodeURIComponent(uid)}`
    if (bookId.length > 0) {
      path += `&bookId=${encodeURIComponent(bookId)}`
    }
    const res = await HttpClient.get<ReadingListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: InspirationItem[] = []
      for (const w of res.data.list) {
        out.push(InspirationItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findInspiration(id: string): Promise<InspirationItem | undefined> {
    const res = await HttpClient.get<ReadingItemWire>(`/biz/reading-journal/inspirations/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    return undefined
  }

  static async createInspiration(req: CreateInspirationRequest): Promise<InspirationItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = ReadingBizService.userId()
    }
    const res = await HttpClient.postJson<ReadingItemWire>(
      '/biz/reading-journal/inspirations',
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined) {
      return InspirationItem.fromWire(res.data)
    }
    return undefined
  }

  static async deleteInspiration(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/reading-journal/inspirations/${id}`)
    return res.code === 0
  }

  static async loadCustomTags(): Promise<TagPresetItem[]> {
    const uid = ReadingBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<ReadingListPayload>(
      `/biz/reading-journal/custom-tags?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: TagPresetItem[] = []
      for (const w of res.data.list) {
        out.push(TagPresetItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async createCustomTag(req: CreateCustomTagRequest): Promise<TagPresetItem | undefined> {
    if (req.userId.length === 0) {
      req.userId = ReadingBizService.userId()
    }
    const res = await HttpClient.postJson<ReadingItemWire>(
      '/biz/reading-journal/custom-tags',
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined) {
      return TagPresetItem.fromWire(res.data)
    }
    return undefined
  }

  static async deleteCustomTag(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteOkPayload>(`/biz/reading-journal/custom-tags/${id}`)
    return res.code === 0
  }

  static async loadMonthlyReview(month: string): Promise<MonthlyReviewData> {
    const uid = ReadingBizService.userId()
    let path = `/biz/reading-journal/monthly-review?month=${encodeURIComponent(month)}`
    if (uid.length > 0) {
      path += `&userId=${encodeURIComponent(uid)}`
    }
    const res = await HttpClient.get<MonthlyReviewData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    const empty = new MonthlyReviewData()
    empty.month = month
    empty.summary = '本月还没有阅读记录。打卡、写笔记或摘金句后，这里会生成月度回顾。'
    return empty
  }

  static async patchQuote(id: string, req: PatchQuoteRequest): Promise<QuoteItem | undefined> {
    const res = await HttpClient.postJson<ReadingItemWire>(
      `/biz/reading-journal/quotes/${id}/update`,
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined) {
      return QuoteItem.fromWire(res.data)
    }
    return undefined
  }
}
