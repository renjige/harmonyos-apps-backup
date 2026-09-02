import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { StreakState } from '../models/FanGrowthModels'

const STORE = 'star_fan_streak'

/** 连续打开 / 观赛打卡 — 本地 streak */
export class StreakService {
  private static pref: preferences.Preferences | null = null
  private static state: StreakState = new StreakState()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      StreakService.pref = await preferences.getPreferences(context, STORE)
      const raw = await StreakService.pref.get('state', '')
      const text: string = typeof raw === 'string' ? raw : ''
      StreakService.state = StreakService.parse(text)
    } catch {
      StreakService.state = new StreakState()
    }
    await StreakService.recordDailyOpen()
  }

  static openStreak(): number {
    return StreakService.state.openStreak
  }

  static watchStreak(): number {
    return StreakService.state.watchStreak
  }

  static async recordDailyOpen(): Promise<void> {
    const today = StreakService.dateKey(Date.now())
    if (StreakService.state.lastActiveDate === today) {
      return
    }
    const yesterday = StreakService.dateKey(Date.now() - 86400000)
    if (StreakService.state.lastActiveDate === yesterday) {
      StreakService.state.openStreak += 1
    } else if (StreakService.state.lastActiveDate.length === 0) {
      StreakService.state.openStreak = 1
    } else {
      StreakService.state.openStreak = 1
    }
    StreakService.state.lastActiveDate = today
    await StreakService.persist()
  }

  static async recordWatch(): Promise<void> {
    const today = StreakService.dateKey(Date.now())
    StreakService.state.lastActiveDate = today
    StreakService.state.watchStreak += 1
    if (StreakService.state.watchStreak > StreakService.state.openStreak) {
      StreakService.state.openStreak = StreakService.state.watchStreak
    }
    await StreakService.persist()
  }

  private static dateKey(ms: number): string {
    const d = new Date(ms)
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${y}-${mm}-${dd}`
  }

  private static async persist(): Promise<void> {
    const w = new StreakWire()
    w.lastActiveDate = StreakService.state.lastActiveDate
    w.watchStreak = StreakService.state.watchStreak
    w.openStreak = StreakService.state.openStreak
    try {
      if (StreakService.pref !== null) {
        await StreakService.pref.put('state', JSON.stringify(w))
        await StreakService.pref.flush()
      }
    } catch {
    }
    StreakService.bumpGrowth()
  }

  private static parse(raw: string): StreakState {
    const s = new StreakState()
    if (raw.length === 0) {
      return s
    }
    try {
      const w = JSON.parse(raw) as StreakWire
      s.lastActiveDate = w.lastActiveDate ?? ''
      s.watchStreak = w.watchStreak ?? 0
      s.openStreak = w.openStreak ?? 0
      return s
    } catch {
      return s
    }
  }

  private static bumpGrowth(): void {
    const tick = AppStorage.get<number>('growthTick') ?? 0
    AppStorage.setOrCreate('growthTick', tick + 1)
  }
}

class StreakWire {
  lastActiveDate: string = ''
  watchStreak: number = 0
  openStreak: number = 0
}
