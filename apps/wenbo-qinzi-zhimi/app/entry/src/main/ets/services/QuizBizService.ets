import { HttpClient } from './HttpClient'
import { GuideItem, GuideListData, MedalItem, MedalListData, PuzzleItem, PuzzleListData, CategoryChip } from '../models/PuzzleModels'
import { ProgressStore } from './ProgressStore'

const BASE = '/biz/parent-child-quiz'
const CACHE_KEY = 'puzzleCacheJson'

export class CategoryStat {
  id: string = ''
  label: string = ''
  done: number = 0
  total: number = 0
}

export class QuizBizService {
  static async loadPuzzles(): Promise<PuzzleItem[]> {
    let list: PuzzleItem[] = []
    const res = await HttpClient.get<PuzzleListData>(`${BASE}/puzzles`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      AppStorage.setOrCreate(CACHE_KEY, JSON.stringify(res.data.list))
      list = res.data.list
    } else {
      list = QuizBizService.fromCache()
    }
    const out: PuzzleItem[] = []
    for (const p of list) {
      out.push(QuizBizService.enrich(p))
    }
    for (const c of ProgressStore.customPuzzles()) {
      out.unshift(QuizBizService.enrich(c))
    }
    return out
  }

  static async loadMedals(): Promise<MedalItem[]> {
    const res = await HttpClient.get<MedalListData>(`${BASE}/medals`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadGuides(): Promise<GuideItem[]> {
    const res = await HttpClient.get<GuideListData>(`${BASE}/guides`)
    if (res.code === 0 && res.data !== undefined) {
      return res.data.list
    }
    return []
  }

  static find(list: PuzzleItem[], id: string): PuzzleItem | undefined {
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static optionAt(p: PuzzleItem, index: number): string {
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

  static dailyIds(list: PuzzleItem[], count: number): string[] {
    if (list.length === 0) {
      return []
    }
    const d = new Date()
    const seed = d.getFullYear() * 400 + (d.getMonth() + 1) * 32 + d.getDate()
    const ids: string[] = []
    const used: boolean[] = []
    for (let i = 0; i < list.length; i++) {
      used.push(false)
    }
    let n = 0
    let step = 0
    while (n < count && n < list.length && step < list.length * 3) {
      const idx = Math.abs(seed + step * 17) % list.length
      if (!used[idx]) {
        used[idx] = true
        ids.push(list[idx].id)
        n++
      }
      step++
    }
    return ids
  }

  static familyIds(list: PuzzleItem[], count: number): string[] {
    const daily = QuizBizService.dailyIds(list, count)
    const ids: string[] = []
    for (const p of list) {
      if (daily.indexOf(p.id) < 0) {
        ids.push(p.id)
      }
      if (ids.length >= count) {
        break
      }
    }
    if (ids.length < count) {
      return daily
    }
    return ids
  }

  static recommend(list: PuzzleItem[]): PuzzleItem[] {
    const cats: string[] = ['riddle', 'math', 'visual', 'animal']
    const out: PuzzleItem[] = []
    for (const c of cats) {
      for (const p of list) {
        if (p.category === c) {
          out.push(p)
          break
        }
      }
    }
    return out
  }

  static search(list: PuzzleItem[], keyword: string): PuzzleItem[] {
    const q = keyword.trim()
    if (q.length === 0) {
      return list
    }
    const out: PuzzleItem[] = []
    for (const p of list) {
      if (p.title.indexOf(q) >= 0 || p.summary.indexOf(q) >= 0 || p.question.indexOf(q) >= 0) {
        out.push(p)
      }
    }
    return out
  }

  static filterAge(list: PuzzleItem[], band: string): PuzzleItem[] {
    if (band.length === 0 || band === 'all') {
      return list
    }
    const out: PuzzleItem[] = []
    for (const p of list) {
      if (p.ageBand === band) {
        out.push(p)
      }
    }
    return out
  }

  static enrich(p: PuzzleItem): PuzzleItem {
    const hasAge = p.ageBand && p.ageBand.length > 0
    if (!hasAge) {
      if (p.difficulty === '进阶' || p.category === 'logic') {
        p.ageBand = 'age912'
        p.ageLabel = '9-12岁'
      } else if (p.category === 'math' || p.category === 'visual') {
        p.ageBand = 'age68'
        p.ageLabel = '6-8岁'
      } else {
        p.ageBand = 'age35'
        p.ageLabel = '3-5岁'
      }
    }
    const hasLabel = p.ageLabel && p.ageLabel.length > 0
    if (!hasLabel) {
      if (p.ageBand === 'age912') {
        p.ageLabel = '9-12岁'
      } else if (p.ageBand === 'age68') {
        p.ageLabel = '6-8岁'
      } else {
        p.ageLabel = '3-5岁'
      }
    }
    const hasKnow = p.knowledge && p.knowledge.length > 0
    if (!hasKnow) {
      p.knowledge = p.summary && p.summary.length > 0 ? p.summary : p.explanation
    }
    return p
  }

  static ageChips(): CategoryChip[] {
    const out: CategoryChip[] = []
    const ids: string[] = ['all', 'age35', 'age68', 'age912']
    const labels: string[] = ['全部年龄', '3-5岁启蒙', '6-8岁思维', '9-12岁逻辑']
    for (let i = 0; i < ids.length; i++) {
      const c = new CategoryChip()
      c.id = ids[i]
      c.label = labels[i]
      out.push(c)
    }
    return out
  }

  static randomId(list: PuzzleItem[]): string {
    if (list.length === 0) {
      return ''
    }
    const idx = Math.floor(Math.random() * list.length)
    return list[idx].id
  }

  static dailyTip(guides: GuideItem[]): GuideItem {
    if (guides.length === 0) {
      return new GuideItem()
    }
    const d = new Date()
    const seed = d.getFullYear() * 400 + (d.getMonth() + 1) * 32 + d.getDate()
    const idx = Math.abs(seed) % guides.length
    return guides[idx]
  }

  static categoryStats(list: PuzzleItem[]): CategoryStat[] {
    const ids: string[] = ['riddle', 'math', 'visual', 'life', 'logic', 'animal']
    const labels: string[] = ['脑筋急转弯', '趣味数学', '图形观察', '生活常识', '逻辑推理', '动物世界']
    const totals: Map<string, number> = new Map<string, number>()
    for (const p of list) {
      const n = totals.get(p.category) ?? 0
      totals.set(p.category, n + 1)
    }
    const doneIds = ProgressStore.snapshot().completedIds
    const out: CategoryStat[] = []
    for (let i = 0; i < ids.length; i++) {
      const stat = new CategoryStat()
      stat.id = ids[i]
      stat.label = labels[i]
      stat.total = totals.get(stat.id) ?? 0
      stat.done = QuizBizService.countDone(stat.id, list, doneIds)
      out.push(stat)
    }
    return out
  }

  private static countDone(category: string, list: PuzzleItem[], doneIds: string[]): number {
    let n = 0
    for (const id of doneIds) {
      const found = QuizBizService.find(list, id)
      if (found !== undefined && found.category === category) {
        n++
      }
    }
    return n
  }

  private static fromCache(): PuzzleItem[] {
    const raw = AppStorage.get<string>(CACHE_KEY) ?? ''
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as PuzzleItem[]
      return parsed
    } catch {
      return []
    }
  }
}
