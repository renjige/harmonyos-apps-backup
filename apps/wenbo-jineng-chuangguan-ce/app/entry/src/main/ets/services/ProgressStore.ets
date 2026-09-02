import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { SkillNav } from './SkillNav'
import { RadarDimension, BadgeRule } from '../models/SkillModels'

const STORE = 'jineng_chuangguan_progress'
const KEY = 'state'

export class ProgressState {
  lastDate: string = ''
  streak: number = 0
  growthValue: number = 0
  completedIds: string = ''
  unlockedBadges: string = ''
  radarWorkplace: number = 0
  radarLife: number = 0
  radarCreative: number = 0
  radarThinking: number = 0
  radarOverall: number = 0
  colorMode: string = 'system'
  soundOn: boolean = true
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
      return '早安，今日五关等你挑战'
    }
    if (h < 17) {
      return '午后片刻，完成一关成长值 +'
    }
    return '晚间复盘，坚持打卡续 streak'
  }

  static growthRank(): string {
    const g = ProgressStore.cache.growthValue
    if (g >= 500) {
      return '全能闯关者'
    }
    if (g >= 250) {
      return '精进达人'
    }
    if (g >= 100) {
      return '成长新星'
    }
    if (g >= 30) {
      return '初踏阶梯'
    }
    return '技能学徒'
  }

  static growthLevel(): number {
    const g = ProgressStore.cache.growthValue
    if (g >= 500) {
      return 5
    }
    if (g >= 250) {
      return 4
    }
    if (g >= 100) {
      return 3
    }
    if (g >= 30) {
      return 2
    }
    return 1
  }

  static growthProgress(): number {
    const g = ProgressStore.cache.growthValue
    if (g >= 500) {
      return 1
    }
    if (g >= 250) {
      return (g - 250) / 250
    }
    if (g >= 100) {
      return (g - 100) / 150
    }
    if (g >= 30) {
      return (g - 30) / 70
    }
    return g / 30
  }

  static completedCount(): number {
    return ProgressStore.completedList().length
  }

  static completedList(): string[] {
    if (ProgressStore.cache.completedIds.length === 0) {
      return []
    }
    return ProgressStore.cache.completedIds.split(',')
  }

  static isCompleted(id: string): boolean {
    const parts = ProgressStore.completedList()
    for (const p of parts) {
      if (p === id) {
        return true
      }
    }
    return false
  }

  static isUnlocked(levelId: string, prerequisiteId?: string): boolean {
    if (ProgressStore.isCompleted(levelId)) {
      return true
    }
    if (prerequisiteId === undefined || prerequisiteId === null || prerequisiteId.length === 0) {
      return true
    }
    return ProgressStore.isCompleted(prerequisiteId)
  }

  static categoryCompletedCount(category: string, allIds: string[]): number {
    let n = 0
    for (const id of allIds) {
      if (id.includes(`_${category}_`) && ProgressStore.isCompleted(id)) {
        n++
      }
    }
    return n
  }

  static badgeLit(rule: string, categoryLevelIds: string[]): boolean {
    if (rule === 'complete>=1') {
      return ProgressStore.completedCount() >= 1
    }
    if (rule === 'complete>=5') {
      return ProgressStore.completedCount() >= 5
    }
    if (rule === 'complete>=10') {
      return ProgressStore.completedCount() >= 10
    }
    if (rule === 'complete>=20') {
      return ProgressStore.completedCount() >= 20
    }
    if (rule === 'streak>=3') {
      return ProgressStore.cache.streak >= 3
    }
    if (rule === 'streak>=7') {
      return ProgressStore.cache.streak >= 7
    }
    if (rule === 'streak>=30') {
      return ProgressStore.cache.streak >= 30
    }
    if (rule === 'growth>=500') {
      return ProgressStore.cache.growthValue >= 500
    }
    if (rule.length > 4 && rule.substring(0, 4) === 'cat:') {
      const cat = rule.substring(4)
      const total = ProgressStore.categoryTotal(cat, categoryLevelIds)
      const done = ProgressStore.categoryCompletedCount(cat, categoryLevelIds)
      return total > 0 && done >= total
    }
    return false
  }

  private static categoryTotal(category: string, allIds: string[]): number {
    let n = 0
    for (const id of allIds) {
      if (id.includes(`_${category}_`)) {
        n++
      }
    }
    return n
  }

  static isBadgeUnlocked(badgeId: string): boolean {
    const parts = ProgressStore.cache.unlockedBadges.split(',')
    for (const p of parts) {
      if (p === badgeId) {
        return true
      }
    }
    return false
  }

  static async completeLevel(
    levelId: string,
    category: string,
    growth: number,
    selfRating: number
  ): Promise<void> {
    if (!ProgressStore.isCompleted(levelId)) {
      if (ProgressStore.cache.completedIds.length === 0) {
        ProgressStore.cache.completedIds = levelId
      } else {
        ProgressStore.cache.completedIds = `${ProgressStore.cache.completedIds},${levelId}`
      }
      ProgressStore.cache.growthValue = ProgressStore.cache.growthValue + growth
    }
    const today = ProgressStore.todayKey()
    if (ProgressStore.cache.lastDate !== today) {
      if (ProgressStore.isYesterday(ProgressStore.cache.lastDate, today)) {
        ProgressStore.cache.streak = ProgressStore.cache.streak + 1
      } else {
        ProgressStore.cache.streak = 1
      }
      ProgressStore.cache.lastDate = today
    }
    ProgressStore.bumpRadar(category, selfRating)
    ProgressStore.bumpRadar('overall', selfRating)
    await ProgressStore.flush()
  }

  static async unlockBadge(badgeId: string): Promise<void> {
    if (ProgressStore.isBadgeUnlocked(badgeId)) {
      return
    }
    if (ProgressStore.cache.unlockedBadges.length === 0) {
      ProgressStore.cache.unlockedBadges = badgeId
    } else {
      ProgressStore.cache.unlockedBadges = `${ProgressStore.cache.unlockedBadges},${badgeId}`
    }
    await ProgressStore.flush()
  }

  static async syncBadges(allLevelIds: string[], badges: BadgeRule[]): Promise<void> {
    for (const b of badges) {
      if (ProgressStore.badgeLit(b.rule, allLevelIds)) {
        await ProgressStore.unlockBadge(b.id)
      }
    }
  }

  static radarDimensions(): RadarDimension[] {
    const list: RadarDimension[] = []
    const w = new RadarDimension()
    w.key = 'workplace'
    w.label = '职场'
    w.value = ProgressStore.cache.radarWorkplace
    list.push(w)
    const l = new RadarDimension()
    l.key = 'life'
    l.label = '生活'
    l.value = ProgressStore.cache.radarLife
    list.push(l)
    const c = new RadarDimension()
    c.key = 'creative'
    c.label = '创意'
    c.value = ProgressStore.cache.radarCreative
    list.push(c)
    const t = new RadarDimension()
    t.key = 'thinking'
    t.label = '思维'
    t.value = ProgressStore.cache.radarThinking
    list.push(t)
    const o = new RadarDimension()
    o.key = 'overall'
    o.label = '综合'
    o.value = ProgressStore.cache.radarOverall
    list.push(o)
    return list
  }

  static async clearLocalProgress(): Promise<void> {
    ProgressStore.cache = new ProgressState()
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

  private static bumpRadar(category: string, rating: number): void {
    const add = rating * 4
    if (category === 'workplace') {
      ProgressStore.cache.radarWorkplace = Math.min(100, ProgressStore.cache.radarWorkplace + add)
    } else if (category === 'life') {
      ProgressStore.cache.radarLife = Math.min(100, ProgressStore.cache.radarLife + add)
    } else if (category === 'creative') {
      ProgressStore.cache.radarCreative = Math.min(100, ProgressStore.cache.radarCreative + add)
    } else if (category === 'thinking') {
      ProgressStore.cache.radarThinking = Math.min(100, ProgressStore.cache.radarThinking + add)
    } else if (category === 'overall') {
      ProgressStore.cache.radarOverall = Math.min(100, ProgressStore.cache.radarOverall + add)
    }
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
      s.growthValue = obj.growthValue ?? 0
      s.completedIds = obj.completedIds ?? ''
      s.unlockedBadges = obj.unlockedBadges ?? ''
      s.radarWorkplace = obj.radarWorkplace ?? 0
      s.radarLife = obj.radarLife ?? 0
      s.radarCreative = obj.radarCreative ?? 0
      s.radarThinking = obj.radarThinking ?? 0
      s.radarOverall = obj.radarOverall ?? 0
      s.colorMode = obj.colorMode ?? 'system'
      s.soundOn = obj.soundOn !== false
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
    AppStorage.setOrCreate('growthValue', ProgressStore.cache.growthValue)
    AppStorage.setOrCreate('completedCount', ProgressStore.completedCount())
    AppStorage.setOrCreate('growthRank', ProgressStore.growthRank())
    AppStorage.setOrCreate('growthLevel', ProgressStore.growthLevel())
    SkillNav.bump()
  }
}
