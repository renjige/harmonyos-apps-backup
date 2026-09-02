import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE = 'naoli_tanmi_progress'
const KEY = 'state'

export class BrainState {
  lastDate: string = ''
  streak: number = 0
  memoryScore: number = 0
  focusScore: number = 0
  speedScore: number = 0
  logicScore: number = 0
  sessionCount: number = 0
  dailyDate: string = ''
  dailyTypes: string = ''
  assessDone: boolean = false
  readIds: string = ''
  badges: string = ''
  weekScores: string = ''
  colorMode: string = 'dark'
  lastScore: number = 0
}

export class BrainProgress {
  private static pref: preferences.Preferences | null = null
  private static cache: BrainState = new BrainState()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      BrainProgress.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await BrainProgress.pref.get(KEY, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      BrainProgress.cache = BrainProgress.parse(raw)
    } catch {
      BrainProgress.cache = new BrainState()
    }
    BrainProgress.publish()
  }

  static snapshot(): BrainState {
    return BrainProgress.cache
  }

  static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  static wisdomIndex(): number {
    const s = BrainProgress.cache
    const n = s.memoryScore + s.focusScore + s.speedScore + s.logicScore
    if (n <= 0) {
      return 0
    }
    return Math.round(n / 4)
  }

  static dailyDoneCount(): number {
    if (BrainProgress.cache.dailyDate !== BrainProgress.todayKey()) {
      return 0
    }
    if (BrainProgress.cache.dailyTypes.length === 0) {
      return 0
    }
    return BrainProgress.cache.dailyTypes.split(',').length
  }

  static hasBadge(id: string): boolean {
    if (BrainProgress.cache.badges.length === 0) {
      return false
    }
    const parts = BrainProgress.cache.badges.split(',')
    for (const p of parts) {
      if (p === id) {
        return true
      }
    }
    return false
  }

  static async recordSession(gameType: string, dimension: string, score: number): Promise<void> {
    const s = BrainProgress.cache
    const today = BrainProgress.todayKey()
    if (s.lastDate !== today) {
      if (BrainProgress.isYesterday(s.lastDate)) {
        s.streak = s.streak + 1
      } else {
        s.streak = 1
      }
      s.lastDate = today
    }
    if (s.dailyDate !== today) {
      s.dailyDate = today
      s.dailyTypes = ''
    }
    if (s.dailyTypes.indexOf(gameType) < 0) {
      if (s.dailyTypes.length === 0) {
        s.dailyTypes = gameType
      } else {
        s.dailyTypes = `${s.dailyTypes},${gameType}`
      }
    }
    s.sessionCount = s.sessionCount + 1
    s.lastScore = score
    BrainProgress.blendDim(dimension, score)
    BrainProgress.appendWeek(score)
    BrainProgress.unlockBadges()
    await BrainProgress.flush()
    BrainProgress.publish()
  }

  static async markAssess(memory: number, focus: number, speed: number, logic: number): Promise<void> {
    const s = BrainProgress.cache
    s.assessDone = true
    s.memoryScore = memory
    s.focusScore = focus
    s.speedScore = speed
    s.logicScore = logic
    BrainProgress.unlockBadges()
    await BrainProgress.flush()
    BrainProgress.publish()
  }

  static async markRead(id: string): Promise<void> {
    const s = BrainProgress.cache
    if (s.readIds.indexOf(id) >= 0) {
      return
    }
    if (s.readIds.length === 0) {
      s.readIds = id
    } else {
      s.readIds = `${s.readIds},${id}`
    }
    BrainProgress.unlockBadges()
    await BrainProgress.flush()
    BrainProgress.publish()
  }

  static weekPoints(): number[] {
    if (BrainProgress.cache.weekScores.length === 0) {
      return []
    }
    const parts = BrainProgress.cache.weekScores.split(',')
    const out: number[] = []
    for (const p of parts) {
      const n = Number(p)
      if (!Number.isNaN(n)) {
        out.push(n)
      }
    }
    return out
  }

  static readCount(): number {
    if (BrainProgress.cache.readIds.length === 0) {
      return 0
    }
    return BrainProgress.cache.readIds.split(',').length
  }

  private static blendDim(dimension: string, score: number): void {
    const s = BrainProgress.cache
    if (dimension === 'memory') {
      s.memoryScore = BrainProgress.blend(s.memoryScore, score)
    } else if (dimension === 'focus') {
      s.focusScore = BrainProgress.blend(s.focusScore, score)
    } else if (dimension === 'speed') {
      s.speedScore = BrainProgress.blend(s.speedScore, score)
    } else {
      s.logicScore = BrainProgress.blend(s.logicScore, score)
    }
  }

  private static blend(oldV: number, next: number): number {
    if (oldV <= 0) {
      return next
    }
    return Math.round(oldV * 0.6 + next * 0.4)
  }

  private static appendWeek(score: number): void {
    const s = BrainProgress.cache
    if (s.weekScores.length === 0) {
      s.weekScores = `${score}`
      return
    }
    const parts = s.weekScores.split(',')
    parts.push(`${score}`)
    while (parts.length > 7) {
      parts.shift()
    }
    s.weekScores = parts.join(',')
  }

  private static unlockBadges(): void {
    const s = BrainProgress.cache
    BrainProgress.addBadge('be_ach_first', s.sessionCount >= 1)
    BrainProgress.addBadge('be_ach_daily5', BrainProgress.dailyDoneCount() >= 5)
    BrainProgress.addBadge('be_ach_streak7', s.streak >= 7)
    BrainProgress.addBadge('be_ach_memory90', s.memoryScore >= 90)
    BrainProgress.addBadge('be_ach_assess', s.assessDone)
    BrainProgress.addBadge('be_ach_read3', BrainProgress.readCount() >= 3)
    BrainProgress.addBadge('be_ach_sudoku', s.dailyTypes.indexOf('sudoku') >= 0 || s.logicScore >= 1)
    BrainProgress.addBadge('be_ach_focus', s.focusScore >= 80)
  }

  private static addBadge(id: string, ok: boolean): void {
    if (!ok || BrainProgress.hasBadge(id)) {
      return
    }
    const s = BrainProgress.cache
    if (s.badges.length === 0) {
      s.badges = id
    } else {
      s.badges = `${s.badges},${id}`
    }
  }

  private static isYesterday(dateKey: string): boolean {
    if (dateKey.length === 0) {
      return false
    }
    const d = new Date()
    d.setDate(d.getDate() - 1)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}` === dateKey
  }

  private static parse(raw: string): BrainState {
    const s = new BrainState()
    if (raw.length === 0) {
      return s
    }
    try {
      const o = JSON.parse(raw) as BrainState
      s.lastDate = o.lastDate ?? ''
      s.streak = o.streak ?? 0
      s.memoryScore = o.memoryScore ?? 0
      s.focusScore = o.focusScore ?? 0
      s.speedScore = o.speedScore ?? 0
      s.logicScore = o.logicScore ?? 0
      s.sessionCount = o.sessionCount ?? 0
      s.dailyDate = o.dailyDate ?? ''
      s.dailyTypes = o.dailyTypes ?? ''
      s.assessDone = o.assessDone === true
      s.readIds = o.readIds ?? ''
      s.badges = o.badges ?? ''
      s.weekScores = o.weekScores ?? ''
      s.colorMode = o.colorMode ?? 'dark'
      s.lastScore = o.lastScore ?? 0
    } catch {
      return new BrainState()
    }
    return s
  }

  private static async flush(): Promise<void> {
    if (BrainProgress.pref === null) {
      return
    }
    const raw = JSON.stringify(BrainProgress.cache)
    await BrainProgress.pref.put(KEY, raw)
    await BrainProgress.pref.flush()
  }

  private static publish(): void {
    AppStorage.setOrCreate('wisdomIndex', BrainProgress.wisdomIndex())
    AppStorage.setOrCreate('streakDays', BrainProgress.cache.streak)
    AppStorage.setOrCreate('sessionCount', BrainProgress.cache.sessionCount)
    AppStorage.setOrCreate('assessDoneFlag', BrainProgress.cache.assessDone ? 1 : 0)
    AppStorage.setOrCreate('progressTick', Date.now())
  }
}
