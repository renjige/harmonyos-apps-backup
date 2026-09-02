import { HttpClient } from './HttpClient'
import {
  FeihuaItem,
  FeihuaListData,
  KpiItem,
  KpiListData,
  MsgItem,
  MsgListData,
  PoemItem,
  PoemListData,
  QuestionItem,
  QuestionListData,
  ThemeItem,
  ThemeListData
} from '../models/PoetryModels'

const BASE = '/biz/poetry-challenge'
const CACHE_POEM = 'poemCacheJson'
const CACHE_Q = 'questionCacheJson'

export class PoetryBizService {
  private static memPoems: PoemItem[] = []
  private static memQuestions: QuestionItem[] = []

  static lastHint(): string {
    if (HttpClient.lastError.length > 0) {
      return HttpClient.lastError
    }
    return '请检查网络后重试。答题进度仍保存在本机。'
  }

  static async loadPoems(): Promise<PoemItem[]> {
    const res = await HttpClient.get<PoemListData>(`${BASE}/poems`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      PoetryBizService.memPoems = res.data.list
      AppStorage.setOrCreate(CACHE_POEM, JSON.stringify(res.data.list))
      return res.data.list
    }
    return PoetryBizService.fromPoemCache()
  }

  static async loadPoem(id: string): Promise<PoemItem | undefined> {
    const found = PoetryBizService.findPoem(PoetryBizService.memPoems, id)
    if (found !== undefined) {
      return found
    }
    const res = await HttpClient.get<PoemItem>(`${BASE}/poems/${id}`)
    if (res.code === 0 && res.data !== undefined && res.data.id.length > 0) {
      return res.data
    }
    const list = await PoetryBizService.loadPoems()
    return PoetryBizService.findPoem(list, id)
  }

  static async loadDailyQuestions(): Promise<QuestionItem[]> {
    return PoetryBizService.fetchQuestions(`${BASE}/questions?daily=1`)
  }

  static async loadQuestions(): Promise<QuestionItem[]> {
    if (PoetryBizService.memQuestions.length > 0) {
      return PoetryBizService.memQuestions
    }
    const daily = await PoetryBizService.loadDailyQuestions()
    if (daily.length > 0) {
      return daily
    }
    return PoetryBizService.fromQuestionCache()
  }

  static async resolveQueue(ids: string[]): Promise<QuestionItem[]> {
    const out: QuestionItem[] = []
    for (const id of ids) {
      let found = PoetryBizService.findQuestion(PoetryBizService.memQuestions, id)
      if (found === undefined) {
        const res = await HttpClient.get<QuestionItem>(`${BASE}/questions/${id}`)
        if (res.code === 0 && res.data !== undefined) {
          found = res.data
          PoetryBizService.rememberQuestion(found)
        }
      }
      if (found !== undefined) {
        out.push(found)
      }
    }
    return out
  }

  static async loadFeihua(): Promise<FeihuaItem[]> {
    const res = await HttpClient.get<FeihuaListData>(`${BASE}/feihua`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadFeihuaItem(id: string): Promise<FeihuaItem | undefined> {
    const list = await PoetryBizService.loadFeihua()
    for (const f of list) {
      if (f.id === id) {
        return f
      }
    }
    const res = await HttpClient.get<FeihuaItem>(`${BASE}/feihua/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    return undefined
  }

  static async loadThemes(): Promise<ThemeItem[]> {
    const res = await HttpClient.get<ThemeListData>(`${BASE}/themes`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadKpis(): Promise<KpiItem[]> {
    const res = await HttpClient.get<KpiListData>(`${BASE}/kpis`)
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

  static findQuestion(list: QuestionItem[], id: string): QuestionItem | undefined {
    for (const q of list) {
      if (q.id === id) {
        return q
      }
    }
    return undefined
  }

  static findFeihua(list: FeihuaItem[], id: string): FeihuaItem | undefined {
    for (const f of list) {
      if (f.id === id) {
        return f
      }
    }
    return undefined
  }

  static idsOf(list: QuestionItem[], count: number): string[] {
    const ids: string[] = []
    for (const q of list) {
      ids.push(q.id)
      if (ids.length >= count) {
        break
      }
    }
    return ids
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
    if (questionType === 'sort') {
      return '排序'
    }
    return '选择'
  }

  static validateFeihuaAnswer(item: FeihuaItem, userText: string): boolean {
    const text = userText.trim()
    if (text.length === 0) {
      return false
    }
    if (item.keyword.length > 0 && text.indexOf(item.keyword) < 0) {
      return false
    }
    const answers = item.answerText.split('|')
    for (const a of answers) {
      const ref = a.trim()
      if (ref.length === 0) {
        continue
      }
      if (text === ref || text.indexOf(ref) >= 0 || ref.indexOf(text) >= 0) {
        return true
      }
    }
    return false
  }

  static systemLinePool(item: FeihuaItem): string[] {
    const raw = item.systemLines.length > 0 ? item.systemLines : item.answerText
    const parts = raw.split('|')
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
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

  static uniqueKeywords(list: FeihuaItem[]): string[] {
    const seen: string[] = []
    for (const f of list) {
      if (f.keyword.length === 0) {
        continue
      }
      if (seen.indexOf(f.keyword) < 0) {
        seen.push(f.keyword)
      }
    }
    return seen
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

  private static async fetchQuestions(path: string): Promise<QuestionItem[]> {
    const res = await HttpClient.get<QuestionListData>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      for (const q of res.data.list) {
        PoetryBizService.rememberQuestion(q)
      }
      AppStorage.setOrCreate(CACHE_Q, JSON.stringify(res.data.list))
      return res.data.list
    }
    return PoetryBizService.fromQuestionCache()
  }

  private static rememberQuestion(q: QuestionItem): void {
    let found = false
    for (let i = 0; i < PoetryBizService.memQuestions.length; i++) {
      if (PoetryBizService.memQuestions[i].id === q.id) {
        PoetryBizService.memQuestions[i] = q
        found = true
        break
      }
    }
    if (!found) {
      PoetryBizService.memQuestions.push(q)
    }
  }

  private static fromPoemCache(): PoemItem[] {
    const raw = AppStorage.get<string>(CACHE_POEM) ?? ''
    if (raw.length === 0) {
      return []
    }
    try {
      return JSON.parse(raw) as PoemItem[]
    } catch {
      return []
    }
  }

  private static fromQuestionCache(): QuestionItem[] {
    const raw = AppStorage.get<string>(CACHE_Q) ?? ''
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as QuestionItem[]
      PoetryBizService.memQuestions = parsed
      return parsed
    } catch {
      return []
    }
  }
}
