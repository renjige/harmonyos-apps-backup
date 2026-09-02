import { AchievementDef, GrowthPayload } from '../models/GrowthModels'
import { InspirationItem } from '../models/InspirationModels'
import { CaptureStreakService } from './CaptureStreakService'
import { GrowthService } from './GrowthService'

export class AchievementService {
  static all(): AchievementDef[] {
    const list: AchievementDef[] = []
    list.push(AchievementService.def('first_capture', '第一张备忘笺', '写下第一条灵感'))
    list.push(AchievementService.def('capture_10', '十笺在手', '累计记录 10 条灵感'))
    list.push(AchievementService.def('capture_50', '备忘达人', '累计记录 50 条灵感'))
    list.push(AchievementService.def('streak_3', '三日不断', '连续 3 天有记录或打卡'))
    list.push(AchievementService.def('streak_7', '一周节律', '连续 7 天有记录或打卡'))
    list.push(AchievementService.def('first_pin', '钉上画板', '第一次把灵感钉进画板'))
    list.push(AchievementService.def('first_plan', '做成计划', '从灵感做出第一个创意计划'))
    list.push(AchievementService.def('plan_full', '推进到底', '有一条计划进度达到 100%'))
    list.push(AchievementService.def('favorite_5', '收藏有数', '收藏满 5 条'))
    list.push(AchievementService.def('topic_1', '有了专题', '建好第一个灵感专题'))
    list.push(AchievementService.def('checkin_7', '七次看见', '累计打卡 7 天'))
    return list
  }

  private static def(id: string, title: string, hint: string): AchievementDef {
    const d = new AchievementDef()
    d.id = id
    d.title = title
    d.hint = hint
    return d
  }

  static isUnlocked(payload: GrowthPayload, id: string): boolean {
    for (const x of payload.unlocked) {
      if (x === id) {
        return true
      }
    }
    return false
  }

  static evaluate(
    payload: GrowthPayload,
    inspirations: InspirationItem[],
    plans: InspirationItem[],
    favorites: InspirationItem[]
  ): string[] {
    const earned: string[] = []
    const capture = inspirations.length
    const streak = CaptureStreakService.consecutiveDays(inspirations)
    const checkStreak = GrowthService.hasCheckIn(payload, GrowthService.todayIso()) ? Math.max(streak, 1) : streak
    if (capture >= 1) {
      earned.push('first_capture')
    }
    if (capture >= 10) {
      earned.push('capture_10')
    }
    if (capture >= 50) {
      earned.push('capture_50')
    }
    if (streak >= 3 || checkStreak >= 3) {
      earned.push('streak_3')
    }
    if (streak >= 7) {
      earned.push('streak_7')
    }
    let pinned = false
    for (const ev of payload.activity) {
      if (ev.type === 'pin') {
        pinned = true
      }
    }
    if (pinned) {
      earned.push('first_pin')
    }
    if (plans.length >= 1) {
      earned.push('first_plan')
    }
    for (const p of plans) {
      if (p.progress >= 100) {
        earned.push('plan_full')
        break
      }
    }
    if (favorites.length >= 5) {
      earned.push('favorite_5')
    }
    if (payload.topics.length >= 1) {
      earned.push('topic_1')
    }
    if (payload.checkIns.length >= 7) {
      earned.push('checkin_7')
    }
    const newly: string[] = []
    const unlocked: string[] = []
    for (const id of payload.unlocked) {
      unlocked.push(id)
    }
    for (const id of earned) {
      if (!AchievementService.isUnlocked(payload, id)) {
        newly.push(id)
        unlocked.push(id)
      }
    }
    payload.unlocked = unlocked
    return newly
  }

  static titleOf(id: string): string {
    for (const d of AchievementService.all()) {
      if (d.id === id) {
        return d.title
      }
    }
    return id
  }
}
