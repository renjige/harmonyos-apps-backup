import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { DisplayPrefs, ExploreRecord, ProgressState } from '../models/ProgressModels'
import { ElementCatalog } from '../data/ElementCatalog'
import { BadgeBank } from '../data/BadgeBank'
import { TopicBank } from '../data/TopicBank'
import { ElementNav } from './ElementNav'

const STORE = 'element_explorer_progress'
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
    await ProgressStore.touchOpenDay()
    ProgressStore.refreshBadges()
    ProgressStore.publish()
  }

  static snapshot(): ProgressState {
    return ProgressStore.cache
  }

  static computeLevel(): number {
    const s = ProgressStore.cache
    const xp = s.exploredSymbols.length * 10 + s.challengeCorrect * 3 + s.scenarioDone * 5
    if (xp < 20) {
      return 1
    }
    if (xp < 50) {
      return 2
    }
    if (xp < 100) {
      return 3
    }
    if (xp < 180) {
      return 4
    }
    if (xp < 280) {
      return 5
    }
    if (xp < 400) {
      return 6
    }
    if (xp < 550) {
      return 7
    }
    if (xp < 720) {
      return 8
    }
    if (xp < 900) {
      return 9
    }
    return 10
  }

  static levelTitle(): string {
    const lv = ProgressStore.computeLevel()
    if (lv <= 2) {
      return '元素学徒'
    }
    if (lv <= 4) {
      return '周期旅人'
    }
    if (lv <= 6) {
      return '科学探索者'
    }
    if (lv <= 8) {
      return '元素达人'
    }
    return '周期表大师'
  }

  static xpProgress(): number {
    const s = ProgressStore.cache
    const xp = s.exploredSymbols.length * 10 + s.challengeCorrect * 3 + s.scenarioDone * 5
    const thresholds: number[] = [0, 20, 50, 100, 180, 280, 400, 550, 720, 900, 1100]
    const lv = ProgressStore.computeLevel()
    const lo = thresholds[lv - 1]
    const hi = thresholds[lv]
    if (hi <= lo) {
      return 100
    }
    return Math.min(100, Math.round((xp - lo) * 100 / (hi - lo)))
  }

  static isExplored(symbol: string): boolean {
    return ProgressStore.cache.exploredSymbols.indexOf(symbol) >= 0
  }

  static isFavoriteElement(symbol: string): boolean {
    return ProgressStore.cache.favoriteElements.indexOf(symbol) >= 0
  }

  static isFavoriteTopic(id: string): boolean {
    return ProgressStore.cache.favoriteTopics.indexOf(id) >= 0
  }

  static isWishlist(symbol: string): boolean {
    return ProgressStore.cache.wishlist.indexOf(symbol) >= 0
  }

  static async exploreSymbol(symbol: string, title: string): Promise<void> {
    if (ProgressStore.cache.exploredSymbols.indexOf(symbol) < 0) {
      ProgressStore.cache.exploredSymbols.push(symbol)
    }
    ProgressStore.pushRecent(symbol)
    ProgressStore.pushRecord(symbol, title, 'explore', '阅读元素档案')
    ProgressStore.refreshBadges()
    await ProgressStore.flush()
  }

  static async toggleFavoriteElement(symbol: string): Promise<boolean> {
    const next: string[] = []
    let found = false
    for (const x of ProgressStore.cache.favoriteElements) {
      if (x === symbol) {
        found = true
      } else {
        next.push(x)
      }
    }
    if (!found) {
      next.push(symbol)
    }
    ProgressStore.cache.favoriteElements = next
    ProgressStore.refreshBadges()
    await ProgressStore.flush()
    return !found
  }

  static async toggleFavoriteTopic(id: string): Promise<boolean> {
    const next: string[] = []
    let found = false
    for (const x of ProgressStore.cache.favoriteTopics) {
      if (x === id) {
        found = true
      } else {
        next.push(x)
      }
    }
    if (!found) {
      next.push(id)
    }
    ProgressStore.cache.favoriteTopics = next
    ProgressStore.refreshBadges()
    await ProgressStore.flush()
    return !found
  }

  static async toggleWishlist(symbol: string): Promise<boolean> {
    const next: string[] = []
    let found = false
    for (const x of ProgressStore.cache.wishlist) {
      if (x === symbol) {
        found = true
      } else {
        next.push(x)
      }
    }
    if (!found) {
      next.push(symbol)
    }
    ProgressStore.cache.wishlist = next
    await ProgressStore.flush()
    return !found
  }

  static async viewTopic(id: string, title: string): Promise<void> {
    if (ProgressStore.cache.topicViewedIds.indexOf(id) < 0) {
      ProgressStore.cache.topicViewedIds.push(id)
    }
    ProgressStore.pushRecord('', title, 'topic', '浏览探索专题')
    ProgressStore.refreshBadges()
    await ProgressStore.flush()
  }

  static async recordChallenge(correctCount: number, total: number, perfect: boolean): Promise<void> {
    ProgressStore.cache.challengeDone = ProgressStore.cache.challengeDone + total
    ProgressStore.cache.challengeCorrect = ProgressStore.cache.challengeCorrect + correctCount
    ProgressStore.pushRecord('', '探索挑战', 'challenge',
      `完成 ${total} 题，答对 ${correctCount} 题`)
    if (perfect && ProgressStore.cache.badgeIds.indexOf('badge_perfect') < 0) {
      ProgressStore.cache.badgeIds.push('badge_perfect')
    }
    ProgressStore.refreshBadges()
    await ProgressStore.flush()
  }

  static async completeScenario(scenarioId: string, title: string): Promise<void> {
    if (ProgressStore.cache.scenarioDoneIds.indexOf(scenarioId) < 0) {
      ProgressStore.cache.scenarioDoneIds.push(scenarioId)
      ProgressStore.cache.scenarioDone = ProgressStore.cache.scenarioDone + 1
    }
    ProgressStore.pushRecord('', title, 'scenario', '完成科学推演')
    ProgressStore.refreshBadges()
    await ProgressStore.flush()
  }

  static async pushSearchHistory(keyword: string): Promise<void> {
    const q = keyword.trim()
    if (q.length === 0) {
      return
    }
    const next: string[] = [q]
    for (const old of ProgressStore.cache.searchHistory) {
      if (old !== q && next.length < 8) {
        next.push(old)
      }
    }
    ProgressStore.cache.searchHistory = next
    await ProgressStore.flush()
  }

  static async saveThemeMode(mode: string): Promise<void> {
    ProgressStore.cache.displayPrefs.themeMode = mode
    await ProgressStore.flush()
  }

  static themeMode(): string {
    const m = ProgressStore.cache.displayPrefs.themeMode
    if (m.length > 0) {
      return m
    }
    return 'system'
  }

  static async savePrivacyAccepted(accepted: boolean): Promise<void> {
    ProgressStore.cache.displayPrefs.privacyAccepted = accepted
    AppStorage.setOrCreate('privacyAccepted', accepted)
    await ProgressStore.flush()
  }

  static privacyAccepted(): boolean {
    return ProgressStore.cache.displayPrefs.privacyAccepted
  }

  static async clearCache(): Promise<void> {
    AppStorage.setOrCreate('localCacheEpoch', Date.now())
  }

  private static pushRecent(symbol: string): void {
    const next: string[] = [symbol]
    for (const old of ProgressStore.cache.recentSymbols) {
      if (old !== symbol && next.length < 12) {
        next.push(old)
      }
    }
    ProgressStore.cache.recentSymbols = next
  }

  private static pushRecord(symbol: string, title: string, action: string, detail: string): void {
    const rec = ExploreRecord.make(`${Date.now()}`, symbol, title, action, detail, ProgressStore.todayKey())
    const records: ExploreRecord[] = [rec]
    let n = 0
    for (const old of ProgressStore.cache.records) {
      if (n >= 49) {
        break
      }
      records.push(old)
      n++
    }
    ProgressStore.cache.records = records
  }

  private static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  private static async touchOpenDay(): Promise<void> {
    const today = ProgressStore.todayKey()
    if (ProgressStore.cache.lastOpenDate === today) {
      return
    }
    if (ProgressStore.isYesterday(ProgressStore.cache.lastOpenDate, today)) {
      ProgressStore.cache.streakDays = ProgressStore.cache.streakDays + 1
    } else if (ProgressStore.cache.lastOpenDate.length === 0) {
      ProgressStore.cache.streakDays = 1
    } else {
      ProgressStore.cache.streakDays = 1
    }
    ProgressStore.cache.lastOpenDate = today
    await ProgressStore.flush()
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

  private static countMetalExplored(): number {
    let n = 0
    for (const sym of ProgressStore.cache.exploredSymbols) {
      const el = ElementCatalog.findBySymbol(sym)
      if (el !== undefined && el.filterGroup === 'metal') {
        n++
      }
    }
    return n
  }

  private static familyAllExplored(familyFilter: string, symbols: string[]): boolean {
    for (const sym of symbols) {
      const el = ElementCatalog.findBySymbol(sym)
      if (el === undefined) {
        continue
      }
      if (el.filterGroup !== familyFilter && familyFilter !== 'halogen') {
        continue
      }
      if (ProgressStore.cache.exploredSymbols.indexOf(sym) < 0) {
        return false
      }
    }
    return true
  }

  static refreshBadges(): void {
    const ids: string[] = []
    const explored = ProgressStore.cache.exploredSymbols.length
    if (explored >= 1) {
      ids.push('badge_first')
    }
    if (explored >= 10) {
      ids.push('badge_ten')
    }
    if (explored >= 59) {
      ids.push('badge_half')
    }
    if (explored >= 118) {
      ids.push('badge_full')
    }
    if (ProgressStore.cache.challengeDone >= 5) {
      ids.push('badge_challenge5')
    }
    if (ProgressStore.cache.challengeDone >= 20) {
      ids.push('badge_challenge20')
    }
    if (ProgressStore.cache.badgeIds.indexOf('badge_perfect') >= 0) {
      ids.push('badge_perfect')
    }
    if (ProgressStore.countMetalExplored() >= 20) {
      ids.push('badge_metal')
    }
    const nobleSyms: string[] = ['He', 'Ne', 'Ar', 'Kr', 'Xe', 'Rn', 'Og']
    if (ProgressStore.familyAllExplored('noble_gas', nobleSyms)) {
      ids.push('badge_noble')
    }
    const halogenSyms: string[] = ['F', 'Cl', 'Br', 'I', 'At']
    let halogenOk = true
    for (const sym of halogenSyms) {
      if (ProgressStore.cache.exploredSymbols.indexOf(sym) < 0) {
        halogenOk = false
      }
    }
    if (halogenOk) {
      ids.push('badge_halogen')
    }
    if (ProgressStore.cache.scenarioDone >= 3) {
      ids.push('badge_scenario3')
    }
    const favTotal = ProgressStore.cache.favoriteElements.length + ProgressStore.cache.favoriteTopics.length
    if (favTotal >= 10) {
      ids.push('badge_favorite10')
    }
    if (ProgressStore.cache.topicViewedIds.length >= TopicBank.all().length) {
      ids.push('badge_topic_all')
    }
    if (ProgressStore.cache.streakDays >= 7) {
      ids.push('badge_streak7')
    }
    ProgressStore.cache.badgeIds = ids
  }

  private static parse(raw: string): ProgressState {
    const state = new ProgressState()
    if (raw.length === 0) {
      return state
    }
    try {
      const obj = JSON.parse(raw) as ProgressState
      if (obj.exploredSymbols !== undefined) {
        state.exploredSymbols = obj.exploredSymbols
      }
      state.challengeDone = obj.challengeDone ?? 0
      state.challengeCorrect = obj.challengeCorrect ?? 0
      if (obj.badgeIds !== undefined) {
        state.badgeIds = obj.badgeIds
      }
      if (obj.favoriteElements !== undefined) {
        state.favoriteElements = obj.favoriteElements
      }
      if (obj.favoriteTopics !== undefined) {
        state.favoriteTopics = obj.favoriteTopics
      }
      if (obj.wishlist !== undefined) {
        state.wishlist = obj.wishlist
      }
      if (obj.recentSymbols !== undefined) {
        state.recentSymbols = obj.recentSymbols
      }
      if (obj.records !== undefined) {
        state.records = obj.records
      }
      if (obj.scenarioDoneIds !== undefined) {
        state.scenarioDoneIds = obj.scenarioDoneIds
      }
      if (obj.topicViewedIds !== undefined) {
        state.topicViewedIds = obj.topicViewedIds
      }
      if (obj.searchHistory !== undefined) {
        state.searchHistory = obj.searchHistory
      }
      if (obj.lastOpenDate !== undefined) {
        state.lastOpenDate = obj.lastOpenDate
      }
      state.streakDays = obj.streakDays ?? 0
      state.scenarioDone = obj.scenarioDone ?? 0
      if (obj.displayPrefs !== undefined) {
        const dp = new DisplayPrefs()
        dp.showMass = obj.displayPrefs.showMass !== false
        dp.compactTable = obj.displayPrefs.compactTable === true
        dp.themeMode = obj.displayPrefs.themeMode ?? 'system'
        dp.privacyAccepted = obj.displayPrefs.privacyAccepted === true
        state.displayPrefs = dp
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
    AppStorage.setOrCreate('exploreCount', ProgressStore.cache.exploredSymbols.length)
    AppStorage.setOrCreate('challengeDone', ProgressStore.cache.challengeDone)
    AppStorage.setOrCreate('challengeCorrect', ProgressStore.cache.challengeCorrect)
    AppStorage.setOrCreate('explorerLevel', ProgressStore.computeLevel())
    AppStorage.setOrCreate('explorerLevelTitle', ProgressStore.levelTitle())
    AppStorage.setOrCreate('explorerXpPct', ProgressStore.xpProgress())
    AppStorage.setOrCreate('streakDays', ProgressStore.cache.streakDays)
    AppStorage.setOrCreate('badgeCount', ProgressStore.cache.badgeIds.length)
    AppStorage.setOrCreate('privacyAccepted', ProgressStore.cache.displayPrefs.privacyAccepted)
    ElementNav.bump()
  }
}
