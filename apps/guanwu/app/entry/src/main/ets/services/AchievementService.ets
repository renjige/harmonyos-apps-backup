import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { AchievementItem } from '../models/ActivityModels'
import { ObserveStore } from './ObserveStore'
import { ObserveAtlasStore } from './ObserveAtlasStore'
import { CheckInService } from './CheckInService'
import { ActivityTimelineService } from './ActivityTimelineService'

const STORE = 'guanwu_achievement_v1'
const KEY_UNLOCKED = 'unlocked'

export class AchievementService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      AchievementService.pref = await preferences.getPreferences(context, STORE)
    } catch {
      AchievementService.pref = null
    }
  }

  static async listAll(): Promise<AchievementItem[]> {
    const unlocked = await AchievementService.loadUnlockedMap()
    const all = await ObserveStore.loadAll()
    const favs = await ObserveStore.filterFavorites()
    const atlas = await ObserveAtlasStore.loadAll()
    const streak = await ObserveStore.streakDays()
    const days = await ObserveStore.uniqueDays()
    const monthCheckIns = await CheckInService.countInMonth()

    const defs: string[][] = [
      ['first_record', '初观者', '写下第一条观察', '1', `${all.length}`],
      ['streak_7', '七日之象', '连续 7 天有观察', '7', `${streak}`],
      ['streak_30', '三旬留痕', '连续 30 天有观察', '30', `${streak}`],
      ['records_10', '十物记', '累计 10 条观察', '10', `${all.length}`],
      ['records_50', '五十物象', '累计 50 条观察', '50', `${all.length}`],
      ['fav_10', '收藏达人', '收藏 10 条观察', '10', `${favs.length}`],
      ['atlas_5', '图鉴建档', '创建 5 个图鉴条目', '5', `${atlas.length}`],
      ['days_14', '双周活跃', '累计活跃 14 天', '14', `${days}`],
      ['checkin_7', '本周打卡', '本月打卡 7 次', '7', `${monthCheckIns}`]
    ]

    const out: AchievementItem[] = []
    for (const d of defs) {
      const a = new AchievementItem()
      a.id = d[0]
      a.title = d[1]
      a.description = d[2]
      a.target = parseInt(d[3], 10)
      a.progress = parseInt(d[4], 10)
      if (a.progress > a.target) {
        a.progress = a.target
      }
      a.unlocked = a.progress >= a.target
      const ts = unlocked.get(a.id) ?? 0
      a.unlockedAt = ts
      if (a.unlocked && ts === 0) {
        a.unlockedAt = Date.now()
      }
      out.push(a)
    }
    return out
  }

  static async evaluateAll(): Promise<string[]> {
    const items = await AchievementService.listAll()
    const unlocked = await AchievementService.loadUnlockedMap()
    const newly: string[] = []
    for (const a of items) {
      if (a.unlocked && !unlocked.has(a.id)) {
        unlocked.set(a.id, Date.now())
        newly.push(a.title)
        await ActivityTimelineService.onAchievement(a.id, a.title)
      }
    }
    if (newly.length > 0) {
      await AchievementService.saveUnlockedMap(unlocked)
    }
    return newly
  }

  static async unlockedCount(): Promise<number> {
    const items = await AchievementService.listAll()
    let n = 0
    for (const a of items) {
      if (a.unlocked) {
        n++
      }
    }
    return n
  }

  private static async loadUnlockedMap(): Promise<Map<string, number>> {
    const raw = await AchievementService.getString(KEY_UNLOCKED, '')
    const map = new Map<string, number>()
    if (raw.length === 0) {
      return map
    }
    for (const line of raw.split('\n')) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length >= 2) {
        map.set(parts[0], parseInt(parts[1], 10))
      }
    }
    return map
  }

  private static async saveUnlockedMap(map: Map<string, number>): Promise<void> {
    const lines: string[] = []
    map.forEach((ts, id) => {
      lines.push(`${id}\t${ts}`)
    })
    await AchievementService.putString(KEY_UNLOCKED, lines.join('\n'))
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (AchievementService.pref === null) {
      return fallback
    }
    try {
      const v = await AchievementService.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (AchievementService.pref === null) {
      return
    }
    try {
      await AchievementService.pref.put(key, value)
      await AchievementService.pref.flush()
    } catch {
    }
  }
}
