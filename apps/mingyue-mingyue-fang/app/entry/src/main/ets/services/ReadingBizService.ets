import { HttpClient } from './HttpClient'
import {
  BookItem,
  CreateBookRequest,
  CreateNoteRequest,
  CreatePlanRequest,
  CreateQuoteRequest,
  CreateReadingLogRequest,
  DeleteOkPayload,
  FeaturedItem,
  KpiItem,
  KpiListPayload,
  MessageItem,
  MessageListPayload,
  NoteItem,
  PatchBookRequest,
  PatchPlanRequest,
  PlanItem,
  QuoteItem,
  ReadingItemWire,
  ReadingListPayload,
  ReadingLogItem,
  ReadingReportData,
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
}
