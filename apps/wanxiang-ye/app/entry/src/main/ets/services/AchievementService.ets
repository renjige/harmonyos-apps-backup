import { AchievementDef } from '../models/UserKnowledgeModels'
import { WanXiangLocalStore } from './WanXiangLocalStore'
import { UserDataStore } from './UserDataStore'
import { KnowledgeStore } from './KnowledgeStore'
import { SparkStore } from './SparkStore'
import { CheckInStore } from './CheckInStore'
import { ReviewStore } from './ReviewStore'
import { PlanStore } from './PlanStore'

const KEY_UNLOCKED = 'achievements_unlocked'

export class AchievementService {
  static async listUnlocked(): Promise<string[]> {
    const raw = await WanXiangLocalStore.getString(KEY_UNLOCKED, '')
    if (raw.length === 0) {
      return []
    }
    return raw.split(',').filter((x: string) => x.length > 0)
  }

  static async isUnlocked(id: string): Promise<boolean> {
    const list = await AchievementService.listUnlocked()
    return list.indexOf(id) >= 0
  }

  static async unlock(id: string): Promise<boolean> {
    const list = await AchievementService.listUnlocked()
    if (list.indexOf(id) >= 0) {
      return false
    }
    list.push(id)
    await WanXiangLocalStore.putString(KEY_UNLOCKED, list.join(','))
    return true
  }

  static async checkAll(): Promise<string[]> {
    const newly: string[] = []
    const readCount = await UserDataStore.getReadCount()
    const favCount = (await UserDataStore.getFavoriteIds()).length
    const knowledgeCount = await KnowledgeStore.count()
    const sparkCount = await SparkStore.count()
    const streak = await CheckInStore.getStreakDays()
    const reviewDone = await ReviewStore.getDoneCount()
    const plan = await PlanStore.getActivePlan()

    if (readCount >= 1) {
      if (await AchievementService.unlock('ach_first_read')) {
        newly.push('ach_first_read')
      }
    }
    if (knowledgeCount >= 1) {
      if (await AchievementService.unlock('ach_first_knowledge')) {
        newly.push('ach_first_knowledge')
      }
    }
    if (sparkCount >= 1) {
      if (await AchievementService.unlock('ach_first_spark')) {
        newly.push('ach_first_spark')
      }
    }
    if (streak >= 3) {
      if (await AchievementService.unlock('ach_streak_3')) {
        newly.push('ach_streak_3')
      }
    }
    if (streak >= 7) {
      if (await AchievementService.unlock('ach_streak_7')) {
        newly.push('ach_streak_7')
      }
    }
    if (readCount >= 10) {
      if (await AchievementService.unlock('ach_read_10')) {
        newly.push('ach_read_10')
      }
    }
    if (favCount >= 5) {
      if (await AchievementService.unlock('ach_favorite_5')) {
        newly.push('ach_favorite_5')
      }
    }
    if (reviewDone >= 5) {
      if (await AchievementService.unlock('ach_review_5')) {
        newly.push('ach_review_5')
      }
    }
    if (knowledgeCount >= 5) {
      if (await AchievementService.unlock('ach_knowledge_5')) {
        newly.push('ach_knowledge_5')
      }
    }
    if (plan.status === 'done') {
      if (await AchievementService.unlock('ach_plan_done')) {
        newly.push('ach_plan_done')
      }
    }
    return newly
  }

  static defById(id: string): AchievementDef | undefined {
    for (const d of AchievementDef.all()) {
      if (d.id === id) {
        return d
      }
    }
    return undefined
  }
}
