import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { AchievementDef, AchievementUnlock } from '../models/FanGrowthModels'
import { BrowseHistoryService } from './BrowseHistoryService'
import { ScoutNoteService } from './ScoutNoteService'
import { WatchPlanService } from './WatchPlanService'
import { QuizRecordService } from './QuizRecordService'
import { CompareSetService } from './CompareSetService'
import { WatchReviewService } from './WatchReviewService'
import { StreakService } from './StreakService'

const STORE = 'star_achievements'

export class AchievementService {
  private static pref: preferences.Preferences | null = null
  private static unlocked: AchievementUnlock[] = []
  private static lastToast: string = ''

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      AchievementService.pref = await preferences.getPreferences(context, STORE)
      const raw = await AchievementService.pref.get('unlocked', '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      AchievementService.unlocked = AchievementService.parse(text)
    } catch {
      AchievementService.unlocked = []
    }
  }

  static definitions(): AchievementDef[] {
    const out: AchievementDef[] = []
    const defs: string[][] = [
      ['first_note', '球探初稿', '写下第一条球探笔记', 'star'],
      ['first_plan', '计划起步', '加入第一场观赛计划', 'check'],
      ['first_review', '赛后点评', '完成第一次观赛后评', 'heart'],
      ['quiz_perfect', '满分挑战', '知识挑战一轮全对', 'star'],
      ['streak_7', '连续一周', '连续 7 天打开 App', 'chart'],
      ['watch_5', '观赛达人', '累计标记 5 场已看', 'sport'],
      ['compare_3', '研究型球迷', '保存 3 组对比研究', 'biz'],
      ['browse_10', '足迹十连', '浏览记录达到 10 条', 'search']
    ]
    for (const row of defs) {
      const d = new AchievementDef()
      d.id = row[0]
      d.title = row[1]
      d.caption = row[2]
      d.iconName = row[3]
      out.push(d)
    }
    return out
  }

  static isUnlocked(id: string): boolean {
    for (const u of AchievementService.unlocked) {
      if (u.id === id) {
        return true
      }
    }
    return false
  }

  static unlockedCount(): number {
    return AchievementService.unlocked.length
  }

  static listUnlocked(): AchievementUnlock[] {
    const out: AchievementUnlock[] = []
    for (const u of AchievementService.unlocked) {
      out.push(u)
    }
    return out
  }

  static consumeToast(): string {
    const t = AchievementService.lastToast
    AchievementService.lastToast = ''
    return t
  }

  static defById(id: string): AchievementDef | undefined {
    for (const def of AchievementService.definitions()) {
      if (def.id === id) {
        return def
      }
    }
    return undefined
  }

  static async evaluateAll(): Promise<void> {
    await AchievementService.tryUnlock('first_note', ScoutNoteService.count() >= 1)
    await AchievementService.tryUnlock('first_plan', WatchPlanService.count() >= 1)
    await AchievementService.tryUnlock('first_review', WatchReviewService.count() >= 1)
    const stats = QuizRecordService.statsSnapshot()
    await AchievementService.tryUnlock('quiz_perfect',
      stats.bestScore > 0 && stats.bestTotal > 0 && stats.bestScore === stats.bestTotal)
    await AchievementService.tryUnlock('streak_7', StreakService.openStreak() >= 7)
    await AchievementService.tryUnlock('watch_5', WatchPlanService.watchedCount() >= 5)
    await AchievementService.tryUnlock('compare_3', CompareSetService.count() >= 3)
    await AchievementService.tryUnlock('browse_10', BrowseHistoryService.count() >= 10)
  }

  private static async tryUnlock(id: string, ok: boolean): Promise<void> {
    if (!ok || AchievementService.isUnlocked(id)) {
      return
    }
    const row = new AchievementUnlock()
    row.id = id
    row.unlockedAt = Date.now()
    AchievementService.unlocked.push(row)
    for (const def of AchievementService.definitions()) {
      if (def.id === id) {
        AchievementService.lastToast = `解锁成就：${def.title}`
        break
      }
    }
    await AchievementService.persist()
  }

  private static async persist(): Promise<void> {
    const payload: AchievementUnlockWire[] = []
    for (const u of AchievementService.unlocked) {
      const w = new AchievementUnlockWire()
      w.id = u.id
      w.unlockedAt = u.unlockedAt
      payload.push(w)
    }
    try {
      if (AchievementService.pref !== null) {
        await AchievementService.pref.put('unlocked', JSON.stringify(payload))
        await AchievementService.pref.flush()
      }
    } catch {
    }
    const tick = AppStorage.get<number>('growthTick') ?? 0
    AppStorage.setOrCreate('growthTick', tick + 1)
  }

  private static parse(raw: string): AchievementUnlock[] {
    try {
      const parsed = JSON.parse(raw) as AchievementUnlockWire[]
      const out: AchievementUnlock[] = []
      for (const w of parsed) {
        const u = new AchievementUnlock()
        u.id = w.id
        u.unlockedAt = w.unlockedAt
        out.push(u)
      }
      return out
    } catch {
      return []
    }
  }
}

class AchievementUnlockWire {
  id: string = ''
  unlockedAt: number = 0
}
