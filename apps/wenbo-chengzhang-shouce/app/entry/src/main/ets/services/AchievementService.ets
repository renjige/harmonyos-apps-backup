import { AchievementCatalog } from '../models/AchievementCatalog'
import { GrowthRecordItem, StatsData } from '../models/GrowthModels'
import { GrowthBizService } from './GrowthBizService'
import { AuthService } from './AuthService'

export class AchievementService {
  static isUnlocked(unlocked: GrowthRecordItem[], badgeId: string): boolean {
    for (const row of unlocked) {
      const key = row.content.length > 0 ? row.content : row.coverKey
      if (key === badgeId) {
        return true
      }
    }
    return false
  }

  static async tryUnlock(
    badgeId: string,
    unlocked: GrowthRecordItem[],
    userId: string
  ): Promise<GrowthRecordItem | undefined> {
    if (!AuthService.isLoggedIn()) {
      return undefined
    }
    if (AchievementService.isUnlocked(unlocked, badgeId)) {
      return undefined
    }
    return GrowthBizService.unlockAchievement(badgeId, AchievementCatalog.titleOf(badgeId), userId)
  }

  static async syncFromStats(
    stats: StatsData,
    unlocked: GrowthRecordItem[],
    userId: string,
    viewedAnnual: boolean
  ): Promise<GrowthRecordItem[]> {
    const out: GrowthRecordItem[] = []
    for (const u of unlocked) {
      out.push(u)
    }
    if (stats.recordCount >= 1) {
      const row = await AchievementService.tryUnlock('badge_sprout', out, userId)
      if (row !== undefined) {
        out.push(row)
      }
    }
    if (stats.recordCount >= 50) {
      const row = await AchievementService.tryUnlock('badge_records_50', out, userId)
      if (row !== undefined) {
        out.push(row)
      }
    }
    if (stats.streakDays >= 7) {
      const row = await AchievementService.tryUnlock('badge_week', out, userId)
      if (row !== undefined) {
        out.push(row)
      }
    }
    if (stats.streakDays >= 15) {
      const row = await AchievementService.tryUnlock('badge_half_month', out, userId)
      if (row !== undefined) {
        out.push(row)
      }
    }
    if (stats.streakDays >= 30) {
      const row = await AchievementService.tryUnlock('badge_month', out, userId)
      if (row !== undefined) {
        out.push(row)
      }
    }
    if (stats.completedGoals >= 1) {
      const row = await AchievementService.tryUnlock('badge_goal', out, userId)
      if (row !== undefined) {
        out.push(row)
      }
    }
    if (stats.completedGoals >= 2) {
      const row = await AchievementService.tryUnlock('badge_double_goal', out, userId)
      if (row !== undefined) {
        out.push(row)
      }
    }
    if (viewedAnnual) {
      const row = await AchievementService.tryUnlock('badge_annual', out, userId)
      if (row !== undefined) {
        out.push(row)
      }
    }
    return out
  }
}
