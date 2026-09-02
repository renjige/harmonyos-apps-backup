import { HttpClient } from './HttpClient'
import { ProgressStore } from './ProgressStore'
import {
  BadgeItem,
  BadgeListData,
  ChapterItem,
  ChapterListData,
  IdiomQuestion,
  IdiomListData,
  MsgItem,
  MsgListData,
  ThemeItem,
  ThemeListData
} from '../models/IdiomModels'

const BASE = '/biz/idiom-challenge'
const CACHE_Q = 'idiomQuestionCache'

export class IdiomBizService {
  private static mem: IdiomQuestion[] = []

  static lastHint(): string {
    if (HttpClient.lastError.length > 0) {
      return HttpClient.lastError
    }
    return '请检查网络后重试。答题进度仍保存在本机。'
  }

  static async loadDaily(): Promise<IdiomQuestion[]> {
    return IdiomBizService.fetchList(`${BASE}/questions?daily=1`, 'catalog_daily')
  }

  static async loadLevelQuestions(chapter: number, level: number): Promise<IdiomQuestion[]> {
    return IdiomBizService.fetchList(
      `${BASE}/questions?chapter=${chapter}&level=${level}`,
      `catalog_lv_${chapter}_${level}`
    )
  }

  static async loadThemeQuestions(theme: string, count: number): Promise<IdiomQuestion[]> {
    const list = await IdiomBizService.fetchList(
      `${BASE}/questions?theme=${theme}`,
      `catalog_theme_${theme}`
    )
    if (list.length <= count) {
      return list
    }
    const cut: IdiomQuestion[] = []
    for (const q of list) {
      cut.push(q)
      if (cut.length >= count) {
        break
      }
    }
    return cut
  }

  static async loadQuestions(): Promise<IdiomQuestion[]> {
    if (IdiomBizService.mem.length > 0) {
      return IdiomBizService.mem
    }
    const daily = await IdiomBizService.loadDaily()
    if (daily.length > 0) {
      return IdiomBizService.mem
    }
    return IdiomBizService.fromCache()
  }

  static async resolveQueue(ids: string[]): Promise<IdiomQuestion[]> {
    const out: IdiomQuestion[] = []
    for (const id of ids) {
      let found = IdiomBizService.findQuestion(IdiomBizService.mem, id)
      if (found === undefined) {
        found = await IdiomBizService.loadOne(id)
      }
      if (found !== undefined) {
        out.push(found)
      }
    }
    return out
  }

  static async loadOne(id: string): Promise<IdiomQuestion | undefined> {
    const res = await HttpClient.get<IdiomQuestion>(`${BASE}/questions/${id}`)
    if (res.code === 0 && res.data !== undefined && res.data.id.length > 0) {
      IdiomBizService.remember([res.data])
      return res.data
    }
    return undefined
  }

  static async loadChapters(): Promise<ChapterItem[]> {
    const res = await HttpClient.get<ChapterListData>(`${BASE}/chapters`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      const raw = IdiomBizService.safeStringifyChapters(res.data.list)
      if (raw.length > 0) {
        void ProgressStore.saveCatalog('catalog_chapters', raw)
      }
      return res.data.list
    }
    return IdiomBizService.fromChapterCache()
  }

  static async loadThemes(): Promise<ThemeItem[]> {
    const res = await HttpClient.get<ThemeListData>(`${BASE}/themes`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      return res.data.list
    }
    return []
  }

  static async loadBadges(): Promise<BadgeItem[]> {
    const res = await HttpClient.get<BadgeListData>(`${BASE}/badges`)
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
    return []
  }

  static findQuestion(list: IdiomQuestion[], id: string): IdiomQuestion | undefined {
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static findChapter(list: ChapterItem[], id: string): ChapterItem | undefined {
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static findTheme(list: ThemeItem[], id: string): ThemeItem | undefined {
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static findBadge(list: BadgeItem[], id: string): BadgeItem | undefined {
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static optionAt(p: IdiomQuestion, index: number): string {
    if (index === 0) {
      return p.optionA
    }
    if (index === 1) {
      return p.optionB
    }
    if (index === 2) {
      return p.optionC
    }
    return p.optionD
  }

  static idsOf(list: IdiomQuestion[]): string[] {
    const ids: string[] = []
    for (const q of list) {
      ids.push(q.id)
    }
    return ids
  }

  static dailyIds(list: IdiomQuestion[], count: number): string[] {
    if (list.length === 0) {
      return []
    }
    const ids: string[] = []
    for (const q of list) {
      ids.push(q.id)
      if (ids.length >= count) {
        break
      }
    }
    return ids
  }

  static levelIds(list: IdiomQuestion[], chapter: number, level: number): string[] {
    const ids: string[] = []
    for (const q of list) {
      if (q.chapterIndex === chapter && q.levelIndex === level) {
        ids.push(q.id)
      }
    }
    return ids
  }

  static themeIds(list: IdiomQuestion[], theme: string, count: number): string[] {
    const ids: string[] = []
    for (const q of list) {
      if (q.theme === theme || q.category === theme) {
        ids.push(q.id)
      }
      if (ids.length >= count) {
        break
      }
    }
    return ids
  }

  private static async fetchList(path: string, catalogKey: string): Promise<IdiomQuestion[]> {
    const res = await HttpClient.get<IdiomListData>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      IdiomBizService.remember(res.data.list)
      try {
        const raw = JSON.stringify(res.data.list)
        AppStorage.setOrCreate(CACHE_Q, raw)
        void ProgressStore.saveCatalog(catalogKey, raw)
      } catch {
      }
      return res.data.list
    }
    const cached = await IdiomBizService.fromNamedCache(catalogKey)
    if (cached.length > 0) {
      IdiomBizService.remember(cached)
      return cached
    }
    return IdiomBizService.fromCache()
  }

  private static remember(list: IdiomQuestion[]): void {
    for (const q of list) {
      let found = false
      for (let i = 0; i < IdiomBizService.mem.length; i++) {
        if (IdiomBizService.mem[i].id === q.id) {
          IdiomBizService.mem[i] = q
          found = true
          break
        }
      }
      if (!found) {
        IdiomBizService.mem.push(q)
      }
    }
  }

  private static fromCache(): IdiomQuestion[] {
    const raw = AppStorage.get<string>(CACHE_Q) ?? ''
    return IdiomBizService.parseQuestions(raw)
  }

  private static async fromNamedCache(key: string): Promise<IdiomQuestion[]> {
    let raw = ProgressStore.catalog(key)
    if (raw.length === 0) {
      raw = await ProgressStore.hydrateCatalog(key)
    }
    return IdiomBizService.parseQuestions(raw)
  }

  private static parseQuestions(raw: string): IdiomQuestion[] {
    if (raw.length === 0) {
      return []
    }
    try {
      return JSON.parse(raw) as IdiomQuestion[]
    } catch {
      return []
    }
  }

  private static fromChapterCache(): ChapterItem[] {
    const raw = ProgressStore.catalog('catalog_chapters')
    if (raw.length === 0) {
      return []
    }
    try {
      return JSON.parse(raw) as ChapterItem[]
    } catch {
      return []
    }
  }

  private static safeStringifyChapters(list: ChapterItem[]): string {
    try {
      return JSON.stringify(list)
    } catch {
      return ''
    }
  }
}
