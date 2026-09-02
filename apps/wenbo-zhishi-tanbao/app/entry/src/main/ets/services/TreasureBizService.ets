import { HttpClient } from './HttpClient'
import {
  KpiListPayload,
  MsgListPayload,
  TreasureCard,
  TreasureListData,
  TreasureMatch,
  TreasureMessage,
  TreasureQuestion,
  TreasureTheme
} from '../models/TreasureModels'

const BASE = '/biz/knowledge-treasure'

export class TreasureBizService {
  static async loadCards(category: string = ''): Promise<TreasureCard[]> {
    let path = `${BASE}/cards`
    if (category.length > 0) {
      path = `${path}?category=${category}`
    }
    const res = await HttpClient.get<TreasureListData<TreasureCard>>(path)
    if (res.code === 0 && res.data !== undefined) {
      return TreasureBizService.mapCards(res.data.list)
    }
    return []
  }

  static async findCard(id: string): Promise<TreasureCard | undefined> {
    const res = await HttpClient.get<TreasureCard>(`${BASE}/cards/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return TreasureBizService.mapCard(res.data)
    }
    const list = await TreasureBizService.loadCards()
    return TreasureBizService.findInList(list, id)
  }

  static async loadQuestions(category: string = '', dailyOnly: boolean = false): Promise<TreasureQuestion[]> {
    let path = `${BASE}/questions`
    const params: string[] = []
    if (category.length > 0) {
      params.push(`category=${category}`)
    }
    if (dailyOnly) {
      params.push('daily=1')
    }
    if (params.length > 0) {
      path = `${path}?${params.join('&')}`
    }
    const res = await HttpClient.get<TreasureListData<TreasureQuestion>>(path)
    if (res.code === 0 && res.data !== undefined) {
      return TreasureBizService.mapQuestions(res.data.list)
    }
    return []
  }

  static async findQuestion(id: string): Promise<TreasureQuestion | undefined> {
    const res = await HttpClient.get<TreasureQuestion>(`${BASE}/questions/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return TreasureBizService.mapQuestion(res.data)
    }
    return undefined
  }

  static async loadThemes(): Promise<TreasureTheme[]> {
    const res = await HttpClient.get<TreasureListData<TreasureTheme>>(`${BASE}/themes`)
    if (res.code === 0 && res.data !== undefined) {
      return TreasureBizService.mapThemes(res.data.list)
    }
    return []
  }

  static async loadMatches(category: string = ''): Promise<TreasureMatch[]> {
    let path = `${BASE}/matches`
    if (category.length > 0) {
      path = `${path}?category=${category}`
    }
    const res = await HttpClient.get<TreasureListData<TreasureMatch>>(path)
    if (res.code === 0 && res.data !== undefined) {
      return TreasureBizService.mapMatches(res.data.list)
    }
    return []
  }

  static async loadKpis(): Promise<KpiListPayload> {
    const res = await HttpClient.get<KpiListPayload>(`${BASE}/kpis`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    const empty = new KpiListPayload()
    empty.list = []
    return empty
  }

  static async loadMessages(): Promise<MsgListPayload> {
    const res = await HttpClient.get<MsgListPayload>(`${BASE}/messages`)
    if (res.code === 0 && res.data !== undefined) {
      const out = new MsgListPayload()
      out.list = []
      let i = 0
      for (const m of res.data.list) {
        const msg = new TreasureMessage()
        msg.id = m.id !== undefined && m.id.length > 0 ? m.id : `msg_${i}`
        msg.title = m.title ?? ''
        msg.body = m.body ?? ''
        msg.createdAt = m.createdAt ?? ''
        out.list.push(msg)
        i++
      }
      return out
    }
    const empty = new MsgListPayload()
    empty.list = []
    return empty
  }

  static dailyQuestionIds(list: TreasureQuestion[], count: number): string[] {
    if (list.length === 0) {
      return []
    }
    const daily: TreasureQuestion[] = []
    for (const q of list) {
      if (q.daily) {
        daily.push(q)
      }
    }
    const pool = daily.length >= count ? daily : list
    const d = new Date()
    const seed = d.getFullYear() * 400 + (d.getMonth() + 1) * 32 + d.getDate()
    const ids: string[] = []
    const used: boolean[] = []
    for (let i = 0; i < pool.length; i++) {
      used.push(false)
    }
    let n = 0
    let step = 0
    while (n < count && n < pool.length && step < pool.length * 3) {
      const idx = Math.abs(seed + step * 13) % pool.length
      if (!used[idx]) {
        used[idx] = true
        ids.push(pool[idx].id)
        n++
      }
      step++
    }
    return ids
  }

  static optionAt(q: TreasureQuestion, index: number): string {
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

  static pointsPerQuestion(): number {
    return 10
  }

  static findInList(list: TreasureCard[], id: string): TreasureCard | undefined {
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static findQuestionInList(list: TreasureQuestion[], id: string): TreasureQuestion | undefined {
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static todayPublishDate(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  static pickTodayCard(list: TreasureCard[]): TreasureCard {
    const today = TreasureBizService.todayPublishDate()
    for (const c of list) {
      if (c.publishDate === today) {
        return c
      }
    }
    if (list.length === 0) {
      return new TreasureCard()
    }
    const idx = new Date().getDate() % list.length
    return list[idx]
  }

  private static mapCards(raw: TreasureCard[]): TreasureCard[] {
    const out: TreasureCard[] = []
    for (const r of raw) {
      out.push(TreasureBizService.mapCard(r))
    }
    return out
  }

  private static mapCard(raw: TreasureCard): TreasureCard {
    const c = new TreasureCard()
    c.id = raw.id ?? ''
    c.title = raw.title ?? ''
    c.subtitle = raw.subtitle ?? ''
    c.summary = raw.summary ?? ''
    c.body = raw.body ?? raw.description ?? ''
    c.description = raw.description ?? raw.body ?? ''
    c.coverKey = raw.coverKey ?? ''
    c.category = raw.category ?? ''
    c.categoryLabel = raw.categoryLabel ?? ''
    c.tags = raw.tags ?? ''
    c.publishDate = raw.publishDate ?? ''
    c.daily = raw.daily === true
    return c
  }

  private static mapQuestions(raw: TreasureQuestion[]): TreasureQuestion[] {
    const out: TreasureQuestion[] = []
    for (const r of raw) {
      out.push(TreasureBizService.mapQuestion(r))
    }
    return out
  }

  private static mapQuestion(raw: TreasureQuestion): TreasureQuestion {
    const q = new TreasureQuestion()
    q.id = raw.id ?? ''
    q.title = raw.title ?? ''
    q.question = raw.question ?? ''
    q.optionA = raw.optionA ?? ''
    q.optionB = raw.optionB ?? ''
    q.optionC = raw.optionC ?? ''
    q.optionD = raw.optionD ?? ''
    q.answerIndex = raw.answerIndex ?? 0
    q.tip = raw.tip ?? ''
    q.explanation = raw.explanation ?? raw.tip ?? ''
    q.difficulty = raw.difficulty ?? ''
    q.category = raw.category ?? ''
    q.categoryLabel = raw.categoryLabel ?? ''
    q.daily = raw.daily === true
    return q
  }

  private static mapThemes(raw: TreasureTheme[]): TreasureTheme[] {
    const out: TreasureTheme[] = []
    for (const r of raw) {
      const t = new TreasureTheme()
      t.id = r.id ?? ''
      t.title = r.title ?? ''
      t.subtitle = r.subtitle ?? ''
      t.summary = r.summary ?? ''
      t.body = r.body ?? r.summary ?? ''
      t.category = r.category ?? ''
      t.categoryLabel = r.categoryLabel ?? ''
      t.coverKey = r.coverKey ?? ''
      out.push(t)
    }
    return out
  }

  private static mapMatches(raw: TreasureMatch[]): TreasureMatch[] {
    const out: TreasureMatch[] = []
    for (const r of raw) {
      const m = new TreasureMatch()
      m.id = r.id ?? ''
      m.title = r.title ?? ''
      m.summary = r.summary ?? ''
      m.pairLeft = r.pairLeft ?? ''
      m.pairRight = r.pairRight ?? ''
      m.category = r.category ?? ''
      out.push(m)
    }
    return out
  }
}
