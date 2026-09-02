import { ApiResponse } from '../models/ApiModels'
import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import {
  BookListItem,
  CatalogListPayload,
  CatalogWire,
  EssayItem,
  ExcerptItem,
  InkTime,
  InkWriteRequest,
  MessageListPayload,
  MessageWire,
  UserRecordItem
} from '../models/InkModels'

export class InkBizService {
  private static excerptCache: ExcerptItem[] = []
  private static listCache: BookListItem[] = []
  private static essayCache: EssayItem[] = []

  static uid(): string {
    if (!AuthService.isLoggedIn()) {
      return ''
    }
    const name = AppStorage.get<string>('currentUsername') ?? ''
    return name
  }

  static async loadExcerpts(): Promise<ExcerptItem[]> {
    const res = await HttpClient.get<CatalogListPayload>('/biz/ink-cottage/excerpts')
    const out: ExcerptItem[] = []
    if (res.code === 0 && res.data !== undefined) {
      for (const w of res.data.list) {
        out.push(ExcerptItem.fromWire(w))
      }
    }
    if (out.length > 0) {
      InkBizService.excerptCache = out
    }
    return out.length > 0 ? out : InkBizService.excerptCache
  }

  static async findExcerpt(id: string): Promise<ExcerptItem | undefined> {
    for (const item of InkBizService.excerptCache) {
      if (item.id === id) {
        return item
      }
    }
    const res = await HttpClient.get<CatalogWire>(`/biz/ink-cottage/excerpts/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      const item = ExcerptItem.fromWire(res.data)
      InkBizService.excerptCache.push(item)
      return item
    }
    return undefined
  }

  static pickDaily(list: ExcerptItem[]): ExcerptItem {
    if (list.length === 0) {
      return new ExcerptItem()
    }
    return list[InkTime.dayOfYear() % list.length]
  }

  static async loadLists(): Promise<BookListItem[]> {
    const res = await HttpClient.get<CatalogListPayload>('/biz/ink-cottage/lists')
    const out: BookListItem[] = []
    if (res.code === 0 && res.data !== undefined) {
      for (const w of res.data.list) {
        out.push(BookListItem.fromWire(w))
      }
    }
    if (out.length > 0) {
      InkBizService.listCache = out
    }
    return out.length > 0 ? out : InkBizService.listCache
  }

  static async findList(id: string): Promise<BookListItem | undefined> {
    for (const item of InkBizService.listCache) {
      if (item.id === id) {
        return item
      }
    }
    const res = await HttpClient.get<CatalogWire>(`/biz/ink-cottage/lists/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      const item = BookListItem.fromWire(res.data)
      InkBizService.listCache.push(item)
      return item
    }
    return undefined
  }

  static matchLists(tag: string, lists: BookListItem[]): BookListItem[] {
    const out: BookListItem[] = []
    for (const item of lists) {
      if (item.matchTags.indexOf(tag) >= 0 || item.theme.indexOf(tag) >= 0) {
        out.push(item)
      }
    }
    if (out.length === 0) {
      return lists
    }
    return out
  }

  static async loadEssays(): Promise<EssayItem[]> {
    const res = await HttpClient.get<CatalogListPayload>('/biz/ink-cottage/essays')
    const out: EssayItem[] = []
    if (res.code === 0 && res.data !== undefined) {
      for (const w of res.data.list) {
        out.push(EssayItem.fromWire(w))
      }
    }
    if (out.length > 0) {
      InkBizService.essayCache = out
    }
    return out.length > 0 ? out : InkBizService.essayCache
  }

  static async findEssay(id: string): Promise<EssayItem | undefined> {
    for (const item of InkBizService.essayCache) {
      if (item.id === id) {
        return item
      }
    }
    const res = await HttpClient.get<CatalogWire>(`/biz/ink-cottage/essays/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      const item = EssayItem.fromWire(res.data)
      InkBizService.essayCache.push(item)
      return item
    }
    return undefined
  }

  static async loadNotes(): Promise<UserRecordItem[]> {
    const uid = InkBizService.uid()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<CatalogListPayload>(`/biz/ink-cottage/notes?userId=${encodeURIComponent(uid)}`)
    return InkBizService.mapUsers(res)
  }

  static async findNote(id: string): Promise<UserRecordItem | undefined> {
    const list = await InkBizService.loadNotes()
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    const res = await HttpClient.get<CatalogWire>(`/biz/ink-cottage/notes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return UserRecordItem.fromWire(res.data)
    }
    return undefined
  }

  static async saveNote(req: InkWriteRequest): Promise<boolean> {
    req.userId = InkBizService.uid()
    if (req.userId.length === 0) {
      return false
    }
    const res = await HttpClient.post<CatalogWire>('/biz/ink-cottage/notes', req)
    return res.code === 0
  }

  static async updateNote(id: string, req: InkWriteRequest): Promise<boolean> {
    req.userId = InkBizService.uid()
    const res = await HttpClient.put<CatalogWire>(`/biz/ink-cottage/notes/${id}`, req)
    return res.code === 0
  }

  static async deleteNote(id: string): Promise<boolean> {
    const uid = InkBizService.uid()
    const res = await HttpClient.delete<CatalogWire>(`/biz/ink-cottage/notes/${id}?userId=${encodeURIComponent(uid)}`)
    return res.code === 0
  }

  static async loadReviews(): Promise<UserRecordItem[]> {
    const uid = InkBizService.uid()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<CatalogListPayload>(`/biz/ink-cottage/reviews?userId=${encodeURIComponent(uid)}`)
    return InkBizService.mapUsers(res)
  }

  static async findReview(id: string): Promise<UserRecordItem | undefined> {
    const list = await InkBizService.loadReviews()
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static async saveReview(req: InkWriteRequest): Promise<boolean> {
    req.userId = InkBizService.uid()
    if (req.userId.length === 0) {
      return false
    }
    const res = await HttpClient.post<CatalogWire>('/biz/ink-cottage/reviews', req)
    return res.code === 0
  }

  static async updateReview(id: string, req: InkWriteRequest): Promise<boolean> {
    req.userId = InkBizService.uid()
    const res = await HttpClient.put<CatalogWire>(`/biz/ink-cottage/reviews/${id}`, req)
    return res.code === 0
  }

  static async deleteReview(id: string): Promise<boolean> {
    const uid = InkBizService.uid()
    const res = await HttpClient.delete<CatalogWire>(`/biz/ink-cottage/reviews/${id}?userId=${encodeURIComponent(uid)}`)
    return res.code === 0
  }

  static async loadCheckins(): Promise<UserRecordItem[]> {
    const uid = InkBizService.uid()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<CatalogListPayload>(`/biz/ink-cottage/checkins?userId=${encodeURIComponent(uid)}`)
    return InkBizService.mapUsers(res)
  }

  static async saveCheckin(excerptId: string, remark: string): Promise<boolean> {
    const req = new InkWriteRequest()
    req.userId = InkBizService.uid()
    if (req.userId.length === 0) {
      return false
    }
    req.excerptId = excerptId
    req.dateKey = InkTime.todayKey()
    req.title = `读书打卡 ${req.dateKey}`
    req.remark = remark
    req.body = remark
    req.mood = '安然'
    const res = await HttpClient.post<CatalogWire>('/biz/ink-cottage/checkins', req)
    return res.code === 0
  }

  static async deleteCheckin(id: string): Promise<boolean> {
    const uid = InkBizService.uid()
    const res = await HttpClient.delete<CatalogWire>(`/biz/ink-cottage/checkins/${id}?userId=${encodeURIComponent(uid)}`)
    return res.code === 0
  }

  static async loadMessages(): Promise<MessageWire[]> {
    const res = await HttpClient.get<MessageListPayload>('/biz/ink-cottage/messages')
    const out: MessageWire[] = []
    if (res.code === 0 && res.data !== undefined) {
      for (const w of res.data.list) {
        out.push(w)
      }
    }
    return out
  }

  private static mapUsers(res: ApiResponse<CatalogListPayload>): UserRecordItem[] {
    const out: UserRecordItem[] = []
    if (res.code === 0 && res.data !== undefined) {
      for (const w of res.data.list) {
        out.push(UserRecordItem.fromWire(w))
      }
    }
    return out
  }
}
