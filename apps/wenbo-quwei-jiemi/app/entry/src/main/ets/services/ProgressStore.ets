import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { PlayRecord, ProgressState } from '../models/PuzzleModels'
import { QuizBizService } from './QuizBizService'
import { QuizNav } from './QuizNav'

const STORE = 'quwei_jiemi_progress'
const KEY = 'state'

export class ProgressStore {
  private static pref: preferences.Preferences | null = null
  private static cache: ProgressState = new ProgressState()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ProgressStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await ProgressStore.pref.get(KEY, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      ProgressStore.cache = ProgressStore.parse(raw)
    } catch {
      ProgressStore.cache = new ProgressState()
    }
    ProgressStore.publish()
  }

  static snapshot(): ProgressState {
    return ProgressStore.cache
  }

  static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  static weekKey(): string {
    const d = new Date()
    const day = d.getDay()
    const diff = day === 0 ? -6 : 1 - day
    const monday = new Date(d.getTime())
    monday.setDate(d.getDate() + diff)
    const m = monday.getMonth() + 1
    const dd = monday.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const ddStr = dd < 10 ? `0${dd}` : `${dd}`
    return `${monday.getFullYear()}-${mm}-${ddStr}`
  }

  static greeting(): string {
    const h = new Date().getHours()
    if (h < 11) {
      return '早上好，来一题智慧挑战吧'
    }
    if (h < 17) {
      return '下午好，动动脑放松一下'
    }
    return '晚上好，碎片时间解一谜'
  }

  static isFavorite(id: string): boolean {
    return ProgressStore.cache.favorites.indexOf(id) >= 0
  }

  static isMedalOn(id: string): boolean {
    return ProgressStore.cache.medalIds.indexOf(id) >= 0
  }

  static async toggleFavorite(id: string): Promise<void> {
    const next: string[] = []
    let found = false
    for (const x of ProgressStore.cache.favorites) {
      if (x === id) {
        found = true
      } else {
        next.push(x)
      }
    }
    if (!found) {
      next.push(id)
    }
    ProgressStore.cache.favorites = next
    await ProgressStore.flush()
  }

  static async recordAnswer(
    puzzleId: string,
    title: string,
    category: string,
    categoryLabel: string,
    correct: boolean,
    wisdomEarned: number
  ): Promise<void> {
    const today = ProgressStore.todayKey()
    if (ProgressStore.cache.lastDate !== today) {
      if (ProgressStore.isYesterday(ProgressStore.cache.lastDate, today)) {
        ProgressStore.cache.streak = ProgressStore.cache.streak + 1
      } else {
        ProgressStore.cache.streak = 1
      }
      ProgressStore.cache.todayIds = []
      ProgressStore.cache.lastDate = today
    }
    if (ProgressStore.cache.completedIds.indexOf(puzzleId) < 0) {
      ProgressStore.cache.completedIds.push(puzzleId)
    }
    if (ProgressStore.cache.todayIds.indexOf(puzzleId) < 0) {
      ProgressStore.cache.todayIds.push(puzzleId)
    }
    if (category === 'visual') {
      ProgressStore.cache.visualCount = ProgressStore.cache.visualCount + 1
    }
    if (category === 'math') {
      ProgressStore.cache.mathCount = ProgressStore.cache.mathCount + 1
    }
    if (correct && wisdomEarned > 0) {
      ProgressStore.addWisdomPoints(wisdomEarned)
    }
    const rec = new PlayRecord()
    rec.id = `${Date.now()}`
    rec.puzzleId = puzzleId
    rec.title = title
    rec.categoryLabel = categoryLabel
    rec.correct = correct
    rec.wisdomEarned = wisdomEarned
    rec.at = today
    const records: PlayRecord[] = []
    records.push(rec)
    let n = 0
    for (const old of ProgressStore.cache.records) {
      if (n >= 39) {
        break
      }
      records.push(old)
      n++
    }
    ProgressStore.cache.records = records
    ProgressStore.refreshMedals()
    await ProgressStore.flush()
  }

  static addWisdomPoints(points: number): void {
    const week = ProgressStore.weekKey()
    if (ProgressStore.cache.wisdomWeekKey !== week) {
      ProgressStore.cache.wisdomWeekKey = week
      ProgressStore.cache.wisdomPointsWeek = 0
    }
    ProgressStore.cache.wisdomPointsTotal = ProgressStore.cache.wisdomPointsTotal + points
    ProgressStore.cache.wisdomPointsWeek = ProgressStore.cache.wisdomPointsWeek + points
  }

  static computeWisdomEarned(basePoints: number, hintLevelUsed: number): number {
    const mult = QuizBizService.wisdomMultiplier(hintLevelUsed)
    return Math.max(1, Math.round(basePoints * mult))
  }

  private static refreshMedals(): void {
    const ids: string[] = []
    if (ProgressStore.cache.completedIds.length >= 1) {
      ids.push('pcq_medal_first')
    }
    if (ProgressStore.cache.streak >= 3) {
      ids.push('pcq_medal_streak3')
    }
    if (ProgressStore.cache.completedIds.length >= 30) {
      ids.push('pcq_medal_puzzler')
    }
    if (ProgressStore.cache.wisdomPointsTotal >= 100) {
      ids.push('pcq_medal_wisdom')
    }
    if (ProgressStore.cache.visualCount >= 5) {
      ids.push('pcq_medal_observe')
    }
    if (ProgressStore.cache.mathCount >= 8) {
      ids.push('pcq_medal_math')
    }
    ProgressStore.cache.medalIds = ids
  }

  private static isYesterday(last: string, today: string): boolean {
    if (last.length === 0) {
      return false
    }
    const t = Date.parse(`${today}T00:00:00`)
    const l = Date.parse(`${last}T00:00:00`)
    if (Number.isNaN(t) || Number.isNaN(l)) {
      return false
    }
    return t - l === 24 * 60 * 60 * 1000
  }

  private static parse(raw: string): ProgressState {
    const state = new ProgressState()
    if (raw.length === 0) {
      return state
    }
    try {
      const obj = JSON.parse(raw) as ProgressState
      if (obj.completedIds !== undefined) {
        state.completedIds = obj.completedIds
      }
      if (obj.todayIds !== undefined) {
        state.todayIds = obj.todayIds
      }
      if (obj.lastDate !== undefined) {
        state.lastDate = obj.lastDate
      }
      state.streak = obj.streak ?? 0
      if (obj.favorites !== undefined) {
        state.favorites = obj.favorites
      }
      if (obj.records !== undefined) {
        state.records = obj.records
      }
      state.wisdomPointsTotal = obj.wisdomPointsTotal ?? 0
      state.wisdomPointsWeek = obj.wisdomPointsWeek ?? 0
      if (obj.wisdomWeekKey !== undefined) {
        state.wisdomWeekKey = obj.wisdomWeekKey
      }
      state.visualCount = obj.visualCount ?? 0
      state.mathCount = obj.mathCount ?? 0
      if (obj.medalIds !== undefined) {
        state.medalIds = obj.medalIds
      }
    } catch {
      return new ProgressState()
    }
    return state
  }

  private static async flush(): Promise<void> {
    ProgressStore.publish()
    if (ProgressStore.pref === null) {
      return
    }
    try {
      await ProgressStore.pref.put(KEY, JSON.stringify(ProgressStore.cache))
      await ProgressStore.pref.flush()
    } catch {
      return
    }
  }

  private static publish(): void {
    AppStorage.setOrCreate('doneCount', ProgressStore.cache.completedIds.length)
    AppStorage.setOrCreate('streakDays', ProgressStore.cache.streak)
    AppStorage.setOrCreate('todayCount', ProgressStore.cache.todayIds.length)
    AppStorage.setOrCreate('wisdomPointsTotal', ProgressStore.cache.wisdomPointsTotal)
    AppStorage.setOrCreate('wisdomPointsWeek', ProgressStore.cache.wisdomPointsWeek)
    QuizNav.bump()
  }
}
