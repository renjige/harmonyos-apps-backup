import { HttpClient } from './HttpClient'
import {
  ArticleItem,
  CipaiItem,
  CourtyardListPayload,
  CourtyardWire,
  MessageListPayload,
  MessageWire,
  PoemItem,
  RhymeItem
} from '../models/CourtyardModels'

export class CourtyardBizService {
  static async loadPoems(q: string, dynasty: string, form: string, theme: string): Promise<PoemItem[]> {
    let path = '/biz/poetry-courtyard/poems'
    const parts: string[] = []
    if (q.length > 0) {
      parts.push(`q=${encodeURIComponent(q)}`)
    }
    if (dynasty.length > 0) {
      parts.push(`dynasty=${encodeURIComponent(dynasty)}`)
    }
    if (form.length > 0) {
      parts.push(`form=${encodeURIComponent(form)}`)
    }
    if (theme.length > 0) {
      parts.push(`theme=${encodeURIComponent(theme)}`)
    }
    if (parts.length > 0) {
      path = `${path}?${parts.join('&')}`
    }
    const res = await HttpClient.get<CourtyardListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return CourtyardBizService.mapPoems(res.data.list)
    }
    return []
  }

  static async findPoem(id: string): Promise<PoemItem | undefined> {
    const res = await HttpClient.get<CourtyardWire>(`/biz/poetry-courtyard/poems/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return PoemItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadDaily(): Promise<PoemItem | undefined> {
    const res = await HttpClient.get<CourtyardWire>('/biz/poetry-courtyard/daily')
    if (res.code === 0 && res.data !== undefined) {
      return PoemItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadRandom(): Promise<PoemItem | undefined> {
    const res = await HttpClient.get<CourtyardWire>('/biz/poetry-courtyard/random')
    if (res.code === 0 && res.data !== undefined) {
      return PoemItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadCipai(): Promise<CipaiItem[]> {
    const res = await HttpClient.get<CourtyardListPayload>('/biz/poetry-courtyard/cipai')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: CipaiItem[] = []
      for (const w of res.data.list) {
        out.push(CipaiItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findCipai(id: string): Promise<CipaiItem | undefined> {
    const res = await HttpClient.get<CourtyardWire>(`/biz/poetry-courtyard/cipai/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CipaiItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadRhymes(book: string): Promise<RhymeItem[]> {
    let path = '/biz/poetry-courtyard/rhymes'
    if (book.length > 0) {
      path = `${path}?book=${encodeURIComponent(book)}`
    }
    const res = await HttpClient.get<CourtyardListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: RhymeItem[] = []
      for (const w of res.data.list) {
        out.push(RhymeItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findRhyme(id: string): Promise<RhymeItem | undefined> {
    const res = await HttpClient.get<CourtyardWire>(`/biz/poetry-courtyard/rhymes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return RhymeItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadArticles(): Promise<ArticleItem[]> {
    const res = await HttpClient.get<CourtyardListPayload>('/biz/poetry-courtyard/articles')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: ArticleItem[] = []
      for (const w of res.data.list) {
        out.push(ArticleItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findArticle(id: string): Promise<ArticleItem | undefined> {
    const res = await HttpClient.get<CourtyardWire>(`/biz/poetry-courtyard/articles/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return ArticleItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadMessages(): Promise<MessageWire[]> {
    const res = await HttpClient.get<MessageListPayload>('/messages')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return res.data.list
    }
    return []
  }

  static guessCipai(text: string, cipai: CipaiItem[]): CipaiItem | undefined {
    const n = CourtyardBizService.hanCount(text)
    let best: CipaiItem | undefined = undefined
    let bestDiff = 999
    for (const c of cipai) {
      const target = CourtyardBizService.parseZiCount(c.formHint)
      if (target > 0) {
        const diff = Math.abs(target - n)
        if (diff < bestDiff) {
          bestDiff = diff
          best = c
        }
      }
    }
    if (bestDiff <= 8) {
      return best
    }
    return undefined
  }

  private static parseZiCount(hint: string): number {
    const idx = hint.indexOf('字')
    if (idx < 1) {
      return 0
    }
    let start = idx - 1
    while (start >= 0) {
      const ch = hint.substring(start, start + 1)
      if (ch < '0' || ch > '9') {
        break
      }
      start -= 1
    }
    const num = hint.substring(start + 1, idx)
    if (num.length === 0) {
      return 0
    }
    return Number.parseInt(num, 10)
  }

  private static hanCount(text: string): number {
    let n = 0
    for (let i = 0; i < text.length; i++) {
      const code = text.charCodeAt(i)
      if (code >= 0x4e00 && code <= 0x9fff) {
        n += 1
      }
    }
    return n
  }

  private static mapPoems(list: CourtyardWire[]): PoemItem[] {
    const out: PoemItem[] = []
    for (const w of list) {
      out.push(PoemItem.fromWire(w))
    }
    return out
  }
}
