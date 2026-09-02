import { AchievementItem, SportSummary } from '../models/SportModels'
import { SportAnalytics } from './SportAnalytics'
import { SportStore } from './SportStore'
import { FavoriteStore } from './FavoriteStore'
import { PlanStore } from './PlanStore'

export class AchievementEngine {
  static evaluate(): AchievementItem[] {
    const summary = SportAnalytics.summarize()
    const defs = AchievementEngine.definitions()
    const out: AchievementItem[] = []
    for (const def of defs) {
      const copy = new AchievementItem()
      copy.id = def.id
      copy.title = def.title
      copy.description = def.description
      copy.emoji = def.emoji
      copy.unlocked = AchievementEngine.check(def.id, summary)
      if (copy.unlocked) {
        copy.unlockedAt = AchievementEngine.unlockDate(def.id)
      }
      out.push(copy)
    }
    return out
  }

  static unlockedCount(): number {
    let n = 0
    for (const a of AchievementEngine.evaluate()) {
      if (a.unlocked) {
        n += 1
      }
    }
    return n
  }

  private static definitions(): AchievementItem[] {
    const items: AchievementItem[] = []
    const a1 = new AchievementItem()
    a1.id = 'first_record'
    a1.title = '初露锋芒'
    a1.description = '完成首次竞技记录'
    a1.emoji = '🏅'
    items.push(a1)
    const a2 = new AchievementItem()
    a2.id = 'streak_7'
    a2.title = '七日连击'
    a2.description = '连续 7 天有运动记录'
    a2.emoji = '🔥'
    items.push(a2)
    const a3 = new AchievementItem()
    a3.id = 'distance_100'
    a3.title = '百公里'
    a3.description = '累计运动距离达 100 公里'
    a3.emoji = '🛤️'
    items.push(a3)
    const a4 = new AchievementItem()
    a4.id = 'sessions_10'
    a4.title = '十战十记'
    a4.description = '累计记录 10 次运动'
    a4.emoji = '💪'
    items.push(a4)
    const a5 = new AchievementItem()
    a5.id = 'sessions_50'
    a5.title = '半百征程'
    a5.description = '累计记录 50 次运动'
    a5.emoji = '⭐'
    items.push(a5)
    const a6 = new AchievementItem()
    a6.id = 'month_goal'
    a6.title = '月度达标'
    a6.description = '完成本月运动次数目标'
    a6.emoji = '🎯'
    items.push(a6)
    const a7 = new AchievementItem()
    a7.id = 'favorite_3'
    a7.title = '收藏达人'
    a7.description = '收藏 3 条训练记录'
    a7.emoji = '⭐'
    items.push(a7)
    const a8 = new AchievementItem()
    a8.id = 'plan_done'
    a8.title = '计划执行者'
    a8.description = '完成首个周训练计划'
    a8.emoji = '📋'
    items.push(a8)
    return items
  }

  static nextBadge(): AchievementItem | null {
    for (const a of AchievementEngine.evaluate()) {
      if (!a.unlocked) {
        return a
      }
    }
    return null
  }

  private static check(id: string, summary: SportSummary): boolean {
    if (id === 'first_record') {
      return summary.totalSessions >= 1
    }
    if (id === 'streak_7') {
      return summary.streakDays >= 7
    }
    if (id === 'distance_100') {
      return summary.totalDistanceKm >= 100
    }
    if (id === 'sessions_10') {
      return summary.totalSessions >= 10
    }
    if (id === 'sessions_50') {
      return summary.totalSessions >= 50
    }
    if (id === 'month_goal') {
      return SportAnalytics.monthProgressPercent() >= 100
    }
    if (id === 'favorite_3') {
      return FavoriteStore.count() >= 3
    }
    if (id === 'plan_done') {
      for (const p of PlanStore.list()) {
        if (p.status === 'done') {
          return true
        }
      }
    }
    return false
  }

  private static unlockDate(id: string): string {
    const list = SportStore.list()
    if (list.length === 0) {
      return ''
    }
    if (id === 'first_record') {
      return list[list.length - 1].recordDate
    }
    return list[0].recordDate
  }
}
