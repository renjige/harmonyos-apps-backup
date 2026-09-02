import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { IdiomNav } from './IdiomNav'

const STORE = 'chengyu_tiaozhan_progress'
const KEY = 'state'

export class ProgressState {
  lastDate: string = ''
  streak: number = 0
  totalAnswered: number = 0
  correctCount: number = 0
  maxCombo: number = 0
  totalScore: number = 0
  passedGates: string = ''
  dailyDate: string = ''
  dailyScore: number = 0
  themeWrong: string = ''
  colorMode: string = 'system'
  soundOn: boolean = true
  fontScale: number = 1
}

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
    await ProgressStore.hydrateCatalog('catalog_daily')
    await ProgressStore.hydrateCatalog('catalog_chapters')
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
    return '灯下五题，收一枚金印'
  }

  static titleRank(): string {
    const s = ProgressStore.cache.totalScore
    if (s >= 4000) {
      return '成语状元'
    }
    if (s >= 1500) {
      return '成语进士'
    }
    if (s >= 600) {
      return '成语举人'
    }
    if (s >= 200) {
      return '成语秀才'
    }
    return '成语童生'
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

  static isGatePassed(chapter: number, level: number): boolean {
    const token = `${chapter}_${level}`
    const parts = ProgressStore.cache.passedGates.split(',')
    for (const p of parts) {
      if (p === token) {
        return true
      }
    }
    return false
  }

  static isGateOpen(chapter: number, level: number): boolean {
    if (chapter === 1 && level === 1) {
      return true
    }
    if (level > 1) {
      return ProgressStore.isGatePassed(chapter, level - 1)
    }
    return ProgressStore.isGatePassed(chapter - 1, 10)
  }

  static chapterCleared(chapter: number): boolean {
    for (let lv = 1; lv <= 10; lv++) {
      if (!ProgressStore.isGatePassed(chapter, lv)) {
        return false
      }
    }
    return true
  }

  static async recordAnswer(theme: string, correct: boolean, addScore: number): Promise<void> {
    ProgressStore.cache.totalAnswered = ProgressStore.cache.totalAnswered + 1
    if (correct) {
      ProgressStore.cache.correctCount = ProgressStore.cache.correctCount + 1
      ProgressStore.cache.totalScore = ProgressStore.cache.totalScore + addScore
    } else if (theme.length > 0) {
      ProgressStore.bumpThemeWrong(theme)
    }
    await ProgressStore.flush()
  }

  static async finishDaily(score: number, maxCombo: number): Promise<void> {
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
    await ProgressStore.flush()
  }

  static async passGate(chapter: number, level: number, maxCombo: number): Promise<void> {
    const token = `${chapter}_${level}`
    if (!ProgressStore.isGatePassed(chapter, level)) {
      if (ProgressStore.cache.passedGates.length === 0) {
        ProgressStore.cache.passedGates = token
      } else {
        ProgressStore.cache.passedGates = `${ProgressStore.cache.passedGates},${token}`
      }
    }
    if (maxCombo > ProgressStore.cache.maxCombo) {
      ProgressStore.cache.maxCombo = maxCombo
    }
    await ProgressStore.flush()
  }

  static async setColorMode(mode: string): Promise<void> {
    ProgressStore.cache.colorMode = mode
    await ProgressStore.flush()
  }

  static async setSound(on: boolean): Promise<void> {
    ProgressStore.cache.soundOn = on
    await ProgressStore.flush()
  }

  static async cycleFont(): Promise<void> {
    if (ProgressStore.cache.fontScale < 1.05) {
      ProgressStore.cache.fontScale = 1.15
    } else if (ProgressStore.cache.fontScale < 1.2) {
      ProgressStore.cache.fontScale = 0.9
    } else {
      ProgressStore.cache.fontScale = 1
    }
    await ProgressStore.flush()
  }

  static async clearLocalProgress(): Promise<void> {
    ProgressStore.cache = new ProgressState()
    await ProgressStore.flush()
  }

  static badgeLit(rule: string): boolean {
    if (rule === 'answered>=1') {
      return ProgressStore.cache.totalAnswered >= 1
    }
    if (rule === 'streak>=7') {
      return ProgressStore.cache.streak >= 7
    }
    if (rule === 'combo>=10') {
      return ProgressStore.cache.maxCombo >= 10
    }
    if (rule.length >= 8 && rule.substring(0, 7) === 'chapter') {
      const n = Number.parseInt(rule.substring(7))
      if (n >= 1 && n <= 10) {
        return ProgressStore.chapterCleared(n)
      }
    }
    return false
  }

  static fontScaleLabel(): string {
    const s = ProgressStore.cache.fontScale
    if (s < 0.95) {
      return '小号'
    }
    if (s > 1.05) {
      return '大号'
    }
    return '标准'
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
    ProgressStore.cache.colorMode = next
    if (next === 'dark') {
      Theme.setColorMode('dark')
    } else if (next === 'light') {
      Theme.setColorMode('light')
    } else {
      Theme.setColorMode('system')
    }
    await ProgressStore.flush()
  }

  static weakTheme(): string {
    const raw = ProgressStore.cache.themeWrong
    if (raw.length === 0) {
      return 'history'
    }
    let best = 'history'
    let bestN = 0
    const parts = raw.split(',')
    for (const p of parts) {
      const kv = p.split(':')
      if (kv.length === 2) {
        const n = Number.parseInt(kv[1])
        if (n > bestN) {
          bestN = n
          best = kv[0]
        }
      }
    }
    return best
  }

  private static bumpThemeWrong(theme: string): void {
    const parts = ProgressStore.cache.themeWrong.split(',')
    const next: string[] = []
    let found = false
    for (const p of parts) {
      if (p.length === 0) {
        continue
      }
      const kv = p.split(':')
      if (kv.length === 2 && kv[0] === theme) {
        const n = Number.parseInt(kv[1]) + 1
        next.push(`${theme}:${n}`)
        found = true
      } else {
        next.push(p)
      }
    }
    if (!found) {
      next.push(`${theme}:1`)
    }
    ProgressStore.cache.themeWrong = next.join(',')
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
      s.passedGates = obj.passedGates ?? ''
      s.dailyDate = obj.dailyDate ?? ''
      s.dailyScore = obj.dailyScore ?? 0
      s.themeWrong = obj.themeWrong ?? ''
      s.colorMode = obj.colorMode ?? 'system'
      s.soundOn = obj.soundOn !== false
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

  static async saveCatalog(key: string, raw: string): Promise<void> {
    if (ProgressStore.pref === null) {
      AppStorage.setOrCreate(key, raw)
      return
    }
    try {
      await ProgressStore.pref.put(key, raw)
      await ProgressStore.pref.flush()
    } catch {
      AppStorage.setOrCreate(key, raw)
    }
  }

  static catalog(key: string): string {
    const mem = AppStorage.get<string>(key)
    if (mem !== undefined && mem.length > 0) {
      return mem
    }
    return ''
  }

  static async hydrateCatalog(key: string): Promise<string> {
    if (ProgressStore.pref === null) {
      return ProgressStore.catalog(key)
    }
    try {
      const rawValue = await ProgressStore.pref.get(key, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      if (raw.length > 0) {
        AppStorage.setOrCreate(key, raw)
      }
      return raw
    } catch {
      return ProgressStore.catalog(key)
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
    IdiomNav.bump()
  }
}
