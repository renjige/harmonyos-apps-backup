import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { QuestNav } from './QuestNav'

const STORE = 'zhishi_xunbao_progress'
const KEY = 'state'

export class ProgressState {
  lastCheckin: string = ''
  streak: number = 0
  wisdom: number = 0
  completedMaps: string = ''
  unlockedTreasures: string = ''
  unlockedBadges: string = ''
  totalCorrect: number = 0
  totalAttempts: number = 0
  colorMode: string = 'system'
  perfectMaps: string = ''
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
    ProgressStore.applyColor()
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

  static hasCheckedInToday(): boolean {
    return ProgressStore.cache.lastCheckin === ProgressStore.todayKey()
  }

  static async checkIn(): Promise<boolean> {
    if (ProgressStore.hasCheckedInToday()) {
      return false
    }
    const today = ProgressStore.todayKey()
    const y = new Date()
    y.setDate(y.getDate() - 1)
    const ym = y.getMonth() + 1
    const yd = y.getDate()
    const ymm = ym < 10 ? `0${ym}` : `${ym}`
    const ydd = yd < 10 ? `0${yd}` : `${yd}`
    const yesterday = `${y.getFullYear()}-${ymm}-${ydd}`
    if (ProgressStore.cache.lastCheckin === yesterday) {
      ProgressStore.cache.streak = ProgressStore.cache.streak + 1
    } else {
      ProgressStore.cache.streak = 1
    }
    ProgressStore.cache.lastCheckin = today
    ProgressStore.cache.wisdom = ProgressStore.cache.wisdom + 8
    await ProgressStore.flush()
    ProgressStore.publish()
    return true
  }

  static isCompleted(mapId: string): boolean {
    return ProgressStore.contains(ProgressStore.cache.completedMaps, mapId)
  }

  static isTreasureUnlocked(id: string): boolean {
    return ProgressStore.contains(ProgressStore.cache.unlockedTreasures, id)
  }

  static isBadgeUnlocked(id: string): boolean {
    return ProgressStore.contains(ProgressStore.cache.unlockedBadges, id)
  }

  static accuracyText(): string {
    const a = ProgressStore.cache.totalAttempts
    if (a <= 0) {
      return '暂无答题'
    }
    const p = Math.floor((ProgressStore.cache.totalCorrect * 100) / a)
    return `${p}%`
  }

  static async recordAnswer(correct: boolean): Promise<void> {
    ProgressStore.cache.totalAttempts = ProgressStore.cache.totalAttempts + 1
    if (correct) {
      ProgressStore.cache.totalCorrect = ProgressStore.cache.totalCorrect + 1
    }
    await ProgressStore.flush()
    ProgressStore.publish()
  }

  static async completeMap(mapId: string, treasureId: string, reward: number, perfect: boolean): Promise<void> {
    if (!ProgressStore.isCompleted(mapId)) {
      ProgressStore.cache.completedMaps = ProgressStore.append(ProgressStore.cache.completedMaps, mapId)
      ProgressStore.cache.wisdom = ProgressStore.cache.wisdom + reward
    }
    ProgressStore.cache.unlockedTreasures = ProgressStore.append(ProgressStore.cache.unlockedTreasures, treasureId)
    if (perfect) {
      ProgressStore.cache.perfectMaps = ProgressStore.append(ProgressStore.cache.perfectMaps, mapId)
    }
    await ProgressStore.evalBadges()
    await ProgressStore.flush()
    ProgressStore.publish()
  }

  static async evalBadges(): Promise<void> {
    const done = ProgressStore.split(ProgressStore.cache.completedMaps)
    if (done.length >= 1) {
      ProgressStore.cache.unlockedBadges = ProgressStore.append(ProgressStore.cache.unlockedBadges, 'badge_first')
    }
    if (ProgressStore.cache.streak >= 3) {
      ProgressStore.cache.unlockedBadges = ProgressStore.append(ProgressStore.cache.unlockedBadges, 'badge_checkin3')
    }
    if (done.length >= 5) {
      ProgressStore.cache.unlockedBadges = ProgressStore.append(ProgressStore.cache.unlockedBadges, 'badge_maps5')
    }
    if (ProgressStore.cache.wisdom >= 200) {
      ProgressStore.cache.unlockedBadges = ProgressStore.append(ProgressStore.cache.unlockedBadges, 'badge_wisdom200')
    }
    if (ProgressStore.split(ProgressStore.cache.perfectMaps).length >= 1) {
      ProgressStore.cache.unlockedBadges = ProgressStore.append(ProgressStore.cache.unlockedBadges, 'badge_perfect')
    }
  }

  static async markFiveThemes(hasAll: boolean): Promise<void> {
    if (hasAll) {
      ProgressStore.cache.unlockedBadges = ProgressStore.append(ProgressStore.cache.unlockedBadges, 'badge_cat_all')
      await ProgressStore.flush()
      ProgressStore.publish()
    }
  }

  static async cycleColorMode(): Promise<void> {
    const cur = ProgressStore.cache.colorMode
    if (cur === 'system') {
      ProgressStore.cache.colorMode = 'light'
    } else if (cur === 'light') {
      ProgressStore.cache.colorMode = 'dark'
    } else {
      ProgressStore.cache.colorMode = 'system'
    }
    ProgressStore.applyColor()
    await ProgressStore.flush()
    ProgressStore.publish()
  }

  static colorModeLabel(): string {
    if (ProgressStore.cache.colorMode === 'light') {
      return '浅色'
    }
    if (ProgressStore.cache.colorMode === 'dark') {
      return '深色'
    }
    return '跟随系统'
  }

  static async clearLocalProgress(): Promise<void> {
    ProgressStore.cache = new ProgressState()
    ProgressStore.cache.colorMode = 'system'
    ProgressStore.applyColor()
    await ProgressStore.flush()
    ProgressStore.publish()
  }

  private static applyColor(): void {
    const m = ProgressStore.cache.colorMode
    if (m === 'light') {
      Theme.setColorMode('light')
    } else if (m === 'dark') {
      Theme.setColorMode('dark')
    } else {
      Theme.setColorMode('system')
    }
  }

  private static publish(): void {
    AppStorage.setOrCreate('wisdomValue', ProgressStore.cache.wisdom)
    AppStorage.setOrCreate('streakDays', ProgressStore.cache.streak)
    AppStorage.setOrCreate('completedCount', ProgressStore.split(ProgressStore.cache.completedMaps).length)
    AppStorage.setOrCreate('treasureCount', ProgressStore.split(ProgressStore.cache.unlockedTreasures).length)
    QuestNav.bump()
  }

  private static async flush(): Promise<void> {
    if (ProgressStore.pref === null) {
      return
    }
    try {
      await ProgressStore.pref.put(KEY, ProgressStore.stringify(ProgressStore.cache))
      await ProgressStore.pref.flush()
    } catch {
    }
  }

  private static contains(csv: string, id: string): boolean {
    const parts = ProgressStore.split(csv)
    for (const p of parts) {
      if (p === id) {
        return true
      }
    }
    return false
  }

  private static append(csv: string, id: string): string {
    if (id.length === 0 || ProgressStore.contains(csv, id)) {
      return csv
    }
    if (csv.length === 0) {
      return id
    }
    return `${csv},${id}`
  }

  private static split(csv: string): string[] {
    if (csv.length === 0) {
      return []
    }
    return csv.split(',')
  }

  private static parse(raw: string): ProgressState {
    const s = new ProgressState()
    if (raw.length === 0) {
      return s
    }
    try {
      const o = JSON.parse(raw) as ProgressState
      s.lastCheckin = o.lastCheckin ?? ''
      s.streak = o.streak ?? 0
      s.wisdom = o.wisdom ?? 0
      s.completedMaps = o.completedMaps ?? ''
      s.unlockedTreasures = o.unlockedTreasures ?? ''
      s.unlockedBadges = o.unlockedBadges ?? ''
      s.totalCorrect = o.totalCorrect ?? 0
      s.totalAttempts = o.totalAttempts ?? 0
      s.colorMode = o.colorMode ?? 'system'
      s.perfectMaps = o.perfectMaps ?? ''
      return s
    } catch {
      return s
    }
  }

  private static stringify(s: ProgressState): string {
    return JSON.stringify(s)
  }
}
