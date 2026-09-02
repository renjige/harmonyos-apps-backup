import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { VaultRecord, VaultState } from '../models/TreasureModels'
import { TreasureNav } from './TreasureNav'

const STORE = 'wenbo_zhishi_tanbao_vault'
const KEY = 'state'

export class VaultStore {
  private static pref: preferences.Preferences | null = null
  private static cache: VaultState = new VaultState()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      VaultStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await VaultStore.pref.get(KEY, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      VaultStore.cache = VaultStore.parse(raw)
    } catch {
      VaultStore.cache = new VaultState()
    }
    VaultStore.publish()
  }

  static snapshot(): VaultState {
    return VaultStore.cache
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
      return '早安，开启今日智慧探宝'
    }
    if (h < 17) {
      return '午后好，来一题轻松闯关'
    }
    return '晚上好，碎片时间也能涨知识'
  }

  static isFavorite(id: string): boolean {
    return VaultStore.cache.favorites.indexOf(id) >= 0
  }

  static favoriteCards(): string[] {
    return VaultStore.cache.favorites
  }

  static async toggleFavorite(id: string): Promise<void> {
    const next: string[] = []
    let found = false
    for (const x of VaultStore.cache.favorites) {
      if (x === id) {
        found = true
      } else {
        next.push(x)
      }
    }
    if (!found) {
      next.push(id)
    }
    VaultStore.cache.favorites = next
    await VaultStore.flush()
  }

  static async recordAnswer(
    questionId: string,
    title: string,
    categoryLabel: string,
    correct: boolean,
    pointsEarned: number
  ): Promise<void> {
    const today = VaultStore.todayKey()
    if (VaultStore.cache.lastDate !== today) {
      if (VaultStore.isYesterday(VaultStore.cache.lastDate, today)) {
        VaultStore.cache.streak = VaultStore.cache.streak + 1
      } else {
        VaultStore.cache.streak = 1
      }
      VaultStore.cache.todayQuestionIds = []
      VaultStore.cache.lastDate = today
    }
    if (VaultStore.cache.completedQuestionIds.indexOf(questionId) < 0) {
      VaultStore.cache.completedQuestionIds.push(questionId)
    }
    if (VaultStore.cache.todayQuestionIds.indexOf(questionId) < 0) {
      VaultStore.cache.todayQuestionIds.push(questionId)
    }
    if (correct && pointsEarned > 0) {
      VaultStore.addPoints(pointsEarned)
    }
    const rec = new VaultRecord()
    rec.id = `${Date.now()}`
    rec.refId = questionId
    rec.title = title
    rec.categoryLabel = categoryLabel
    rec.correct = correct
    rec.pointsEarned = pointsEarned
    rec.at = today
    const records: VaultRecord[] = [rec]
    let n = 0
    for (const old of VaultStore.cache.records) {
      if (n >= 39) {
        break
      }
      records.push(old)
      n++
    }
    VaultStore.cache.records = records
    await VaultStore.flush()
  }

  static async recordMatchComplete(matchId: string): Promise<void> {
    if (VaultStore.cache.completedMatchIds.indexOf(matchId) < 0) {
      VaultStore.cache.completedMatchIds.push(matchId)
      VaultStore.addPoints(5)
      await VaultStore.flush()
    }
  }

  static addPoints(points: number): void {
    const week = VaultStore.weekKey()
    if (VaultStore.cache.weekKey !== week) {
      VaultStore.cache.weekKey = week
      VaultStore.cache.weekPoints = 0
    }
    VaultStore.cache.totalPoints = VaultStore.cache.totalPoints + points
    VaultStore.cache.weekPoints = VaultStore.cache.weekPoints + points
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

  private static parse(raw: string): VaultState {
    const state = new VaultState()
    if (raw.length === 0) {
      return state
    }
    try {
      const obj = JSON.parse(raw) as VaultState
      if (obj.favorites !== undefined) {
        state.favorites = obj.favorites
      }
      if (obj.completedQuestionIds !== undefined) {
        state.completedQuestionIds = obj.completedQuestionIds
      }
      if (obj.completedMatchIds !== undefined) {
        state.completedMatchIds = obj.completedMatchIds
      }
      if (obj.todayQuestionIds !== undefined) {
        state.todayQuestionIds = obj.todayQuestionIds
      }
      if (obj.lastDate !== undefined) {
        state.lastDate = obj.lastDate
      }
      state.streak = obj.streak ?? 0
      state.totalPoints = obj.totalPoints ?? 0
      state.weekPoints = obj.weekPoints ?? 0
      if (obj.weekKey !== undefined) {
        state.weekKey = obj.weekKey
      }
      if (obj.records !== undefined) {
        state.records = obj.records
      }
    } catch {
      return new VaultState()
    }
    return state
  }

  private static async flush(): Promise<void> {
    VaultStore.publish()
    if (VaultStore.pref === null) {
      return
    }
    try {
      await VaultStore.pref.put(KEY, JSON.stringify(VaultStore.cache))
      await VaultStore.pref.flush()
    } catch {
      return
    }
  }

  private static publish(): void {
    AppStorage.setOrCreate('vaultTotalPoints', VaultStore.cache.totalPoints)
    AppStorage.setOrCreate('vaultWeekPoints', VaultStore.cache.weekPoints)
    AppStorage.setOrCreate('vaultStreak', VaultStore.cache.streak)
    AppStorage.setOrCreate('vaultTodayCount', VaultStore.cache.todayQuestionIds.length)
    AppStorage.setOrCreate('vaultFavoriteCount', VaultStore.cache.favorites.length)
    TreasureNav.bump()
  }
}
