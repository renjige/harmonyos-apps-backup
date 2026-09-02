import { HttpClient } from './HttpClient'
import {
  LevelItem,
  LevelListData,
  MedalItem,
  MedalListData,
  MsgItem,
  MsgListData,
  PlaceItem,
  PlaceListData,
  PoemItem,
  PoemListData,
  QuestionItem,
  QuestionListData
} from '../models/PoetryModels'

const BASE = '/biz/poetry-hunt'
const POEM_CACHE = 'poemCacheJson'
const PLACE_CACHE = 'placeCacheJson'
const LEVEL_CACHE = 'levelCacheJson'

export class PoetryBizService {
  static async loadPoems(): Promise<PoemItem[]> {
    const res = await HttpClient.get<PoemListData>(`${BASE}/poems`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      AppStorage.setOrCreate(POEM_CACHE, JSON.stringify(res.data.list))
      return res.data.list
    }
    return PoetryBizService.fromCache<PoemItem>(POEM_CACHE)
  }

  static async loadPlaces(): Promise<PlaceItem[]> {
    const res = await HttpClient.get<PlaceListData>(`${BASE}/places`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      AppStorage.setOrCreate(PLACE_CACHE, JSON.stringify(res.data.list))
      return res.data.list
    }
    return PoetryBizService.fromCache<PlaceItem>(PLACE_CACHE)
  }

  static async loadLevels(): Promise<LevelItem[]> {
    const res = await HttpClient.get<LevelListData>(`${BASE}/levels`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      AppStorage.setOrCreate(LEVEL_CACHE, JSON.stringify(res.data.list))
      return res.data.list
    }
    return PoetryBizService.fromCache<LevelItem>(LEVEL_CACHE)
  }

  static async loadQuestions(levelId: string): Promise<QuestionItem[]> {
    const res = await HttpClient.get<QuestionListData>(`${BASE}/questions?levelId=${levelId}`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadMedals(): Promise<MedalItem[]> {
    const res = await HttpClient.get<MedalListData>(`${BASE}/medals`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadMessages(): Promise<MsgItem[]> {
    const res = await HttpClient.get<MsgListData>('/messages')
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    const alt = await HttpClient.get<MsgListData>(`${BASE}/messages`)
    if (alt.code === 0 && alt.data !== undefined) {
      return alt.data.list
    }
    return []
  }

  static findPoem(list: PoemItem[], id: string): PoemItem | undefined {
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static findPlace(list: PlaceItem[], id: string): PlaceItem | undefined {
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static findLevel(list: LevelItem[], id: string): LevelItem | undefined {
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static poemsByPlace(list: PoemItem[], placeId: string): PoemItem[] {
    const out: PoemItem[] = []
    for (const p of list) {
      if (p.placeId === placeId) {
        out.push(p)
      }
    }
    return out
  }

  static optionAt(q: QuestionItem, index: number): string {
    if (index === 0) {
      return q.optionA
    }
    if (index === 1) {
      return q.optionB
    }
    if (index === 2) {
      return q.optionC
    }
    return q.optionD
  }

  static typeLabel(questionType: string): string {
    if (questionType === 'fill') {
      return '填空'
    }
    if (questionType === 'match') {
      return '配对'
    }
    if (questionType === 'order') {
      return '排序'
    }
    return '选择'
  }

  static dailyPoem(list: PoemItem[]): PoemItem {
    if (list.length === 0) {
      return new PoemItem()
    }
    const d = new Date()
    const seed = d.getFullYear() * 400 + (d.getMonth() + 1) * 32 + d.getDate()
    const idx = Math.abs(seed) % list.length
    return list[idx]
  }

  static dailyQuote(list: PoemItem[]): string {
    const p = PoetryBizService.dailyPoem(list)
    if (p.body.length === 0) {
      return '诗卷初开，墨香未散'
    }
    const line = p.body.split('\n')[0]
    return line.length > 0 ? line : p.title
  }

  static filterPoems(list: PoemItem[], dynasty: string, author: string, theme: string, q: string): PoemItem[] {
    const key = q.trim()
    const out: PoemItem[] = []
    for (const p of list) {
      if (dynasty.length > 0 && p.dynasty !== dynasty) {
        continue
      }
      if (author.length > 0 && p.author.indexOf(author) < 0) {
        continue
      }
      if (theme.length > 0 && p.theme !== theme) {
        continue
      }
      if (key.length > 0) {
        const blob = `${p.title}${p.author}${p.body}${p.summary}${p.theme}`
        if (blob.indexOf(key) < 0) {
          continue
        }
      }
      out.push(p)
    }
    return out
  }

  static uniqueDynasties(list: PoemItem[]): string[] {
    return PoetryBizService.uniqueField(list, 'dynasty')
  }

  static uniqueAuthors(list: PoemItem[]): string[] {
    return PoetryBizService.uniqueField(list, 'author')
  }

  static uniqueThemes(list: PoemItem[]): string[] {
    return PoetryBizService.uniqueField(list, 'theme')
  }

  private static uniqueField(list: PoemItem[], field: string): string[] {
    const seen: string[] = []
    for (const p of list) {
      let v = ''
      if (field === 'dynasty') {
        v = p.dynasty
      } else if (field === 'author') {
        v = p.author
      } else {
        v = p.theme
      }
      if (v.length === 0) {
        continue
      }
      if (seen.indexOf(v) < 0) {
        seen.push(v)
      }
    }
    return seen
  }

  static clearCatalogCache(): void {
    AppStorage.setOrCreate(POEM_CACHE, '')
    AppStorage.setOrCreate(PLACE_CACHE, '')
    AppStorage.setOrCreate(LEVEL_CACHE, '')
  }

  private static fromCache<T>(key: string): T[] {
    const raw = AppStorage.get<string>(key) ?? ''
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as T[]
      return parsed
    } catch {
      return []
    }
  }
}
