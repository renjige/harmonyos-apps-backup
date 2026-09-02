import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { DailyRecordItem, ProgressState } from '../models/PoetryModels'
import { PoetryNav } from './PoetryNav'

const STORE = 'shici_tiaozhan_progress'
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

  static dateLabel(): string {
    const d = new Date()
    return `${d.getMonth() + 1}月${d.getDate()}日`
  }

  static greeting(): string {
    const h = new Date().getHours()
    if (h < 11) {
      return '晨光正好，来五题热身'
    }
    if (h < 17) {
      return '午后片刻，墨韵开题'
    }
    return '灯下五题，收一枚诗印'
  }

  static titleRank(): string {
    const s = ProgressStore.cache.totalScore
    if (s >= 3000) {
      return '诗坛宗师'
    }
    if (s >= 1200) {
      return '飞花高手'
    }
    if (s >= 500) {
      return '诗词秀才'
    }
    if (s >= 150) {
      return '入门诗生'
    }
    return '诗词童生'
  }

  static accuracyText(): string {
    if (ProgressStore.cache.totalAnswered <= 0) {
      return '—'
    }
    const n = Math.floor((ProgressStore.cache.correctCount * 100) / ProgressStore.cache.totalAnswered)
    return `${n}%`
  }

  static dailyDone(): boolean {
    return ProgressStore.cache.dailyDate === ProgressStore.todayKey()
  }

  static isFavorite(poemId: string): boolean {
    const parts = ProgressStore.cache.favorites.split(',')
    for (const p of parts) {
      if (p === poemId) {
        return true
      }
    }
    return false
  }

  static async toggleFavorite(poemId: string): Promise<void> {
    const parts = ProgressStore.cache.favorites.split(',').filter((x) => x.length > 0)
    const next: string[] = []
    let removed = false
    for (const p of parts) {
      if (p === poemId) {
        removed = true
      } else {
        next.push(p)
      }
    }
    if (!removed) {
      next.push(poemId)
    }
    ProgressStore.cache.favorites = next.join(',')
    await ProgressStore.flush()
  }

  static favoriteCount(): number {
    if (ProgressStore.cache.favorites.length === 0) {
      return 0
    }
    return ProgressStore.cache.favorites.split(',').filter((x) => x.length > 0).length
  }

  static dailyRecords(): DailyRecordItem[] {
    const raw = ProgressStore.cache.dailyRecords
    if (raw.length === 0) {
      return []
    }
    try {
      return JSON.parse(raw) as DailyRecordItem[]
    } catch {
      return []
    }
  }

  static async recordAnswer(correct: boolean, addScore: number): Promise<void> {
    ProgressStore.cache.totalAnswered = ProgressStore.cache.totalAnswered + 1
    if (correct) {
      ProgressStore.cache.correctCount = ProgressStore.cache.correctCount + 1
      ProgressStore.cache.totalScore = ProgressStore.cache.totalScore + addScore
    }
    await ProgressStore.flush()
  }

  static async finishDaily(score: number, maxCombo: number, correct: number, total: number): Promise<void> {
    const today = ProgressStore.todayKey()
    if (ProgressStore.cache.lastDate !== today) {
      if (ProgressStore.isYesterday(ProgressStore.cache.lastDate, today)) {
        ProgressStore.cache.streak = ProgressStore.cache.streak + 1
      } else {
        ProgressStore.cache.streak = 1
      }
      ProgressStore.cache.lastDate = today
    }
    ProgressStore.cache.dailyDate = today
    ProgressStore.cache.dailyScore = score
    if (maxCombo > ProgressStore.cache.maxCombo) {
      ProgressStore.cache.maxCombo = maxCombo
    }
    const rec = new DailyRecordItem()
    rec.date = today
    rec.score = score
    rec.maxCombo = maxCombo
    rec.correct = correct
    rec.total = total
    const list = ProgressStore.dailyRecords()
    const next: DailyRecordItem[] = []
    let replaced = false
    for (const r of list) {
      if (r.date === today) {
        next.push(rec)
        replaced = true
      } else {
        next.push(r)
      }
    }
    if (!replaced) {
      next.unshift(rec)
    }
    while (next.length > 14) {
      next.pop()
    }
    ProgressStore.cache.dailyRecords = JSON.stringify(next)
    await ProgressStore.flush()
  }

  static async recordFeihuaRound(won: boolean): Promise<void> {
    ProgressStore.cache.feihuaRounds = ProgressStore.cache.feihuaRounds + 1
    if (won) {
      ProgressStore.cache.feihuaWins = ProgressStore.cache.feihuaWins + 1
    }
    await ProgressStore.flush()
  }

  static async setColorMode(mode: string): Promise<void> {
    ProgressStore.cache.colorMode = mode
    if (mode === 'dark') {
      Theme.setColorMode('dark')
    } else if (mode === 'light') {
      Theme.setColorMode('light')
    } else {
      Theme.setColorMode('system')
    }
    await ProgressStore.flush()
  }

  static colorModeLabel(): string {
    const m = ProgressStore.cache.colorMode
    if (m === 'dark') {
      return '深色'
    }
    if (m === 'light') {
      return '浅色'
    }
    return '跟随系统'
  }

  static async cycleColorMode(): Promise<void> {
    const cur = ProgressStore.cache.colorMode
    let next = 'system'
    if (cur === 'system') {
      next = 'light'
    } else if (cur === 'light') {
      next = 'dark'
    } else {
      next = 'system'
    }
    await ProgressStore.setColorMode(next)
  }

  static async clearLocalProgress(): Promise<void> {
    ProgressStore.cache = new ProgressState()
    await ProgressStore.flush()
  }

  private static isYesterday(prev: string, today: string): boolean {
    if (prev.length === 0) {
      return false
    }
    const d = new Date()
    d.setDate(d.getDate() - 1)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    const y = `${d.getFullYear()}-${mm}-${dd}`
    return prev === y && today === ProgressStore.todayKey()
  }

  private static parse(raw: string): ProgressState {
    const s = new ProgressState()
    if (raw.length === 0) {
      return s
    }
    try {
      const obj = JSON.parse(raw) as ProgressState
      s.lastDate = obj.lastDate ?? ''
      s.streak = obj.streak ?? 0
      s.totalAnswered = obj.totalAnswered ?? 0
      s.correctCount = obj.correctCount ?? 0
      s.maxCombo = obj.maxCombo ?? 0
      s.totalScore = obj.totalScore ?? 0
      s.dailyDate = obj.dailyDate ?? ''
      s.dailyScore = obj.dailyScore ?? 0
      s.feihuaRounds = obj.feihuaRounds ?? 0
      s.feihuaWins = obj.feihuaWins ?? 0
      s.favorites = obj.favorites ?? ''
      s.dailyRecords = obj.dailyRecords ?? ''
      s.colorMode = obj.colorMode ?? 'system'
      s.fontScale = obj.fontScale > 0 ? obj.fontScale : 1
      return s
    } catch {
      return s
    }
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
    }
  }

  static publish(): void {
    AppStorage.setOrCreate('streakDays', ProgressStore.cache.streak)
    AppStorage.setOrCreate('totalAnswered', ProgressStore.cache.totalAnswered)
    AppStorage.setOrCreate('correctCount', ProgressStore.cache.correctCount)
    AppStorage.setOrCreate('maxCombo', ProgressStore.cache.maxCombo)
    AppStorage.setOrCreate('totalScore', ProgressStore.cache.totalScore)
    AppStorage.setOrCreate('titleRank', ProgressStore.titleRank())
    AppStorage.setOrCreate('dailyDoneFlag', ProgressStore.dailyDone() ? 1 : 0)
    AppStorage.setOrCreate('dailyScore', ProgressStore.cache.dailyScore)
    AppStorage.setOrCreate('feihuaRounds', ProgressStore.cache.feihuaRounds)
    AppStorage.setOrCreate('feihuaWins', ProgressStore.cache.feihuaWins)
    AppStorage.setOrCreate('favoriteCount', ProgressStore.favoriteCount())
    PoetryNav.bump()
  }
}
