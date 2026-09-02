import { HttpClient } from './HttpClient'
import { JsonChunks } from './JsonChunks'
import { PavilionStore } from './PavilionStore'
import {
  ArticleItem, CollectionItem, DailyItem, MsgWire, PavilionTime
} from '../models/PavilionModels'

export class PavilionBizService {
  private static articleCache: ArticleItem[] = []
  private static dailyCache: DailyItem[] = []
  private static collectionCache: CollectionItem[] = []
  static lastHint: string = ''

  static async loadArticles(): Promise<ArticleItem[]> {
    try {
      const res = await HttpClient.get<ArticleListPayloadDummy>('/biz/curious-pavilion/articles')
      const out = PavilionBizService.parseArticles(HttpClient.lastRaw)
      if (out.length > 0) {
        PavilionBizService.articleCache = out
        await PavilionStore.saveCatalog('articles', HttpClient.lastRaw)
        PavilionBizService.lastHint = ''
        return out
      }
      if (res.code !== 0 && res.message.length > 0) {
        PavilionBizService.lastHint = res.message
      }
    } catch {
      PavilionBizService.lastHint = '网络异常，正在展示上次内容'
    }
    const cached = PavilionBizService.parseArticles(PavilionStore.catalog('articles'))
    if (cached.length > 0) {
      PavilionBizService.articleCache = cached
      return cached
    }
    return PavilionBizService.articleCache
  }

  static async findArticle(id: string): Promise<ArticleItem | undefined> {
    const local = PavilionBizService.articleCache
    for (const item of local) {
      if (item.id === id) {
        return item
      }
    }
    const all = await PavilionBizService.loadArticles()
    for (const item of all) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static async loadDaily(): Promise<DailyItem[]> {
    try {
      const res = await HttpClient.get<ArticleListPayloadDummy>('/biz/curious-pavilion/daily')
      const out = PavilionBizService.parseDaily(HttpClient.lastRaw)
      if (out.length > 0) {
        PavilionBizService.dailyCache = out
        await PavilionStore.saveCatalog('daily', HttpClient.lastRaw)
        return out
      }
      if (res.code !== 0) {
        PavilionBizService.lastHint = res.message
      }
    } catch {
      PavilionBizService.lastHint = '网络异常'
    }
    const cached = PavilionBizService.parseDaily(PavilionStore.catalog('daily'))
    if (cached.length > 0) {
      PavilionBizService.dailyCache = cached
      return cached
    }
    return PavilionBizService.dailyCache
  }

  static async findDaily(id: string): Promise<DailyItem | undefined> {
    for (const item of PavilionBizService.dailyCache) {
      if (item.id === id) {
        return item
      }
    }
    const all = await PavilionBizService.loadDaily()
    for (const item of all) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static async loadCollections(): Promise<CollectionItem[]> {
    try {
      await HttpClient.get<ArticleListPayloadDummy>('/biz/curious-pavilion/collections')
      const out = PavilionBizService.parseCollections(HttpClient.lastRaw)
      if (out.length > 0) {
        PavilionBizService.collectionCache = out
        await PavilionStore.saveCatalog('collections', HttpClient.lastRaw)
        return out
      }
    } catch {
      PavilionBizService.lastHint = '专题暂时无法刷新'
    }
    const cached = PavilionBizService.parseCollections(PavilionStore.catalog('collections'))
    if (cached.length > 0) {
      PavilionBizService.collectionCache = cached
      return cached
    }
    return PavilionBizService.collectionCache
  }

  static findCollection(id: string): CollectionItem | undefined {
    for (const c of PavilionBizService.collectionCache) {
      if (c.id === id) {
        return c
      }
    }
    return undefined
  }

  static articlesOfCollection(col: CollectionItem, all: ArticleItem[]): ArticleItem[] {
    const out: ArticleItem[] = []
    if (col.articleIds.length === 0) {
      return PavilionBizService.filterByCategory(all, col.category)
    }
    const parts = col.articleIds.split(',')
    for (const pid of parts) {
      for (const a of all) {
        if (a.id === pid) {
          out.push(a)
        }
      }
    }
    return out
  }

  static async loadMessages(): Promise<MsgWire[]> {
    const out: MsgWire[] = []
    try {
      await HttpClient.get<ArticleListPayloadDummy>('/biz/curious-pavilion/messages')
      const chunks = JsonChunks.objectsInList(HttpClient.lastRaw)
      for (const ch of chunks) {
        const m = new MsgWire()
        m.id = JsonChunks.str(ch, 'id')
        m.title = JsonChunks.str(ch, 'title')
        m.body = JsonChunks.str(ch, 'body')
        m.type = JsonChunks.str(ch, 'type')
        m.createdAt = JsonChunks.str(ch, 'createdAt')
        if (m.id.length > 0) {
          out.push(m)
        }
      }
    } catch {
      return out
    }
    return out
  }

  static pickToday(list: DailyItem[]): DailyItem {
    if (list.length === 0) {
      return new DailyItem()
    }
    const today = PavilionTime.todayKey()
    for (const item of list) {
      if (item.dateKey === today) {
        return item
      }
    }
    const idx = PavilionBizService.dayIndex(list.length)
    return list[idx]
  }

  static filterByCategory(list: ArticleItem[], category: string): ArticleItem[] {
    if (category.length === 0 || category === 'all') {
      return list
    }
    const out: ArticleItem[] = []
    for (const item of list) {
      if (item.category === category) {
        out.push(item)
      }
    }
    return out
  }

  static filterByTag(list: ArticleItem[], tag: string): ArticleItem[] {
    if (tag.length === 0 || tag === 'all') {
      return list
    }
    const out: ArticleItem[] = []
    for (const item of list) {
      const tags = item.tagList()
      for (const t of tags) {
        if (t === tag) {
          out.push(item)
          break
        }
      }
    }
    return out
  }

  static search(list: ArticleItem[], keyword: string): ArticleItem[] {
    const q = keyword.trim()
    if (q.length === 0) {
      return list
    }
    const out: ArticleItem[] = []
    for (const item of list) {
      if (item.title.indexOf(q) >= 0 || item.summary.indexOf(q) >= 0 ||
        item.body.indexOf(q) >= 0 || item.tags.indexOf(q) >= 0) {
        out.push(item)
      }
    }
    return out
  }

  static cachedArticles(): ArticleItem[] {
    const copy: ArticleItem[] = []
    for (const item of PavilionBizService.articleCache) {
      copy.push(item)
    }
    return copy
  }

  private static parseArticles(raw: string): ArticleItem[] {
    const out: ArticleItem[] = []
    if (raw.length === 0) {
      return out
    }
    const chunks = JsonChunks.objectsInList(raw)
    for (const ch of chunks) {
      const item = ArticleItem.fromChunk(ch)
      if (item.id.length > 0 && item.title.length > 0) {
        out.push(item)
      }
    }
    return out
  }

  private static parseDaily(raw: string): DailyItem[] {
    const out: DailyItem[] = []
    if (raw.length === 0) {
      return out
    }
    const chunks = JsonChunks.objectsInList(raw)
    for (const ch of chunks) {
      const item = DailyItem.fromChunk(ch)
      if (item.id.length > 0 && item.title.length > 0) {
        out.push(item)
      }
    }
    return out
  }

  private static parseCollections(raw: string): CollectionItem[] {
    const out: CollectionItem[] = []
    if (raw.length === 0) {
      return out
    }
    const chunks = JsonChunks.objectsInList(raw)
    for (const ch of chunks) {
      const c = new CollectionItem()
      c.id = JsonChunks.str(ch, 'id')
      c.title = JsonChunks.str(ch, 'title')
      c.summary = JsonChunks.str(ch, 'summary')
      const media = JsonChunks.str(ch, 'coverMedia')
      const key = JsonChunks.str(ch, 'coverKey')
      c.coverKey = media.length > 0 ? media : key
      c.articleIds = JsonChunks.str(ch, 'articleIds')
      if (c.articleIds.length === 0) {
        c.articleIds = JsonChunks.str(ch, 'body')
      }
      c.category = JsonChunks.str(ch, 'category')
      if (c.id.length > 0 && c.title.length > 0) {
        out.push(c)
      }
    }
    return out
  }

  private static dayIndex(len: number): number {
    if (len <= 0) {
      return 0
    }
    const d = new Date()
    const n = d.getFullYear() * 400 + d.getMonth() * 32 + d.getDate()
    let idx = n % len
    if (idx < 0) {
      idx = 0
    }
    return idx
  }
}

class ArticleListPayloadDummy {
  list: string[] = []
}
