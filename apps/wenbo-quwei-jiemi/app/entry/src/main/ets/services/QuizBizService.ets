import { HttpClient } from './HttpClient'
import {
  GuideItem,
  GuideListData,
  LeaderboardEntry,
  LeaderboardListData,
  MedalItem,
  MedalListData,
  PuzzleItem,
  PuzzleListData
} from '../models/PuzzleModels'

const BASE = '/biz/parent-child-quiz'
const CACHE_KEY = 'puzzleCacheJson'

export class QuizBizService {
  static async loadPuzzles(): Promise<PuzzleItem[]> {
    const res = await HttpClient.get<PuzzleListData>(`${BASE}/puzzles`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      const mapped: PuzzleItem[] = []
      for (const raw of res.data.list) {
        mapped.push(QuizBizService.mapPuzzle(raw))
      }
      AppStorage.setOrCreate(CACHE_KEY, JSON.stringify(mapped))
      return mapped
    }
    return QuizBizService.fromCache()
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

  static async loadLeaderboard(scope: string): Promise<LeaderboardEntry[]> {
    const res = await HttpClient.get<LeaderboardListData>(`${BASE}/leaderboard?scope=${scope}`)
    if (res.code === 0 && res.data !== undefined && res.data.list.length > 0) {
      return res.data.list
    }
    return QuizBizService.simulatedLeaderboard(scope)
  }

  static simulatedLeaderboard(scope: string): LeaderboardEntry[] {
    const weekly: LeaderboardEntry[] = []
    const total: LeaderboardEntry[] = []
    const names: string[] = ['智慧达人', '逻辑高手', '观察先锋', '数学之星', '文字玩家', '探索者']
    const weeklyPts: number[] = [320, 285, 260, 240, 210, 190]
    const totalPts: number[] = [1860, 1720, 1580, 1490, 1320, 1180]
    const pts = scope === 'weekly' ? weeklyPts : totalPts
    const out = scope === 'weekly' ? weekly : total
    for (let i = 0; i < names.length; i++) {
      const e = new LeaderboardEntry()
      e.rank = i + 1
      e.userId = `demo_${i + 1}`
      e.displayName = names[i]
      e.wisdomPoints = pts[i]
      e.isSelf = false
      out.push(e)
    }
    return out
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

  static wisdomPointsOf(p: PuzzleItem): number {
    if (p.wisdomPoints > 0) {
      return p.wisdomPoints
    }
    if (p.difficulty === '进阶') {
      return 15
    }
    if (p.difficulty === '挑战') {
      return 20
    }
    return 10
  }

  static wisdomMultiplier(hintLevelUsed: number): number {
    if (hintLevelUsed <= 0) {
      return 1
    }
    if (hintLevelUsed === 1) {
      return 0.7
    }
    if (hintLevelUsed === 2) {
      return 0.4
    }
    return 0.15
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

  static recommend(list: PuzzleItem[]): PuzzleItem[] {
    const cats: string[] = ['riddle', 'math', 'visual', 'logic']
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

  private static mapPuzzle(raw: PuzzleItem): PuzzleItem {
    const p = new PuzzleItem()
    p.id = raw.id
    p.title = raw.title
    p.subtitle = raw.subtitle
    p.category = raw.category
    p.categoryLabel = raw.categoryLabel
    p.difficulty = raw.difficulty
    p.question = raw.question
    p.optionA = raw.optionA
    p.optionB = raw.optionB
    p.optionC = raw.optionC
    p.optionD = raw.optionD
    p.answerIndex = raw.answerIndex
    p.hint = raw.hint
    p.explanation = raw.explanation
    p.summary = raw.summary
    p.coverKey = raw.coverKey
    p.wisdomPoints = QuizBizService.wisdomPointsOf(raw)
    return p
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
