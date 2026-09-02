import { HttpClient } from './HttpClient'
import {
  BookListItem, BookListListPayload, BookListWire, ExcerptItem, ExcerptListPayload, ExcerptWire, RoamTime
} from '../models/RoamModels'

export class RoamBizService {
  private static excerptCache: ExcerptItem[] = []
  private static listCache: BookListItem[] = []

  static async loadExcerpts(): Promise<ExcerptItem[]> {
    const res = await HttpClient.get<ExcerptListPayload>('/biz/book-roam/excerpts')
    const out: ExcerptItem[] = []
    if (res.code === 0 && res.data !== undefined) {
      for (const w of res.data.list) {
        out.push(ExcerptItem.fromWire(w))
      }
    }
    if (out.length > 0) {
      RoamBizService.excerptCache = out
    }
    return out
  }

  static async findExcerpt(id: string): Promise<ExcerptItem | undefined> {
    for (const item of RoamBizService.excerptCache) {
      if (item.id === id) {
        return item
      }
    }
    const res = await HttpClient.get<ExcerptWire>(`/biz/book-roam/excerpts/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      const item = ExcerptItem.fromWire(res.data)
      RoamBizService.mergeExcerpt(item)
      return item
    }
    return undefined
  }

  static async loadLists(): Promise<BookListItem[]> {
    const res = await HttpClient.get<BookListListPayload>('/biz/book-roam/lists')
    const out: BookListItem[] = []
    if (res.code === 0 && res.data !== undefined) {
      for (const w of res.data.list) {
        out.push(BookListItem.fromWire(w))
      }
    }
    if (out.length > 0) {
      RoamBizService.listCache = out
    }
    return out
  }

  static async findList(id: string): Promise<BookListItem | undefined> {
    for (const item of RoamBizService.listCache) {
      if (item.id === id) {
        return item
      }
    }
    const res = await HttpClient.get<BookListWire>(`/biz/book-roam/lists/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      const item = BookListItem.fromWire(res.data)
      RoamBizService.mergeList(item)
      return item
    }
    return undefined
  }

  static pickDailyExcerpt(list: ExcerptItem[]): ExcerptItem {
    if (list.length === 0) {
      return new ExcerptItem()
    }
    const idx = RoamTime.dayOfYear() % list.length
    return list[idx]
  }

  static cachedExcerpts(): ExcerptItem[] {
    const copy: ExcerptItem[] = []
    for (const item of RoamBizService.excerptCache) {
      copy.push(item)
    }
    return copy
  }

  static findCachedExcerpt(id: string): ExcerptItem | undefined {
    for (const item of RoamBizService.excerptCache) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  private static mergeExcerpt(item: ExcerptItem): void {
    const next: ExcerptItem[] = []
    let replaced = false
    for (const row of RoamBizService.excerptCache) {
      if (row.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(row)
      }
    }
    if (!replaced) {
      next.push(item)
    }
    RoamBizService.excerptCache = next
  }

  private static mergeList(item: BookListItem): void {
    const next: BookListItem[] = []
    let replaced = false
    for (const row of RoamBizService.listCache) {
      if (row.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(row)
      }
    }
    if (!replaced) {
      next.push(item)
    }
    RoamBizService.listCache = next
  }
}
