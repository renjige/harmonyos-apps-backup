import { AchievementDef } from '../models/GrowthModels'
import { InsightEntry } from '../models/InsightModels'
import { GrowthStore } from './GrowthStore'
import { InsightStore } from './InsightStore'
import { DateHelper } from './DateHelper'

export class AchievementService {
  static async evaluateAll(): Promise<string[]> {
    const unlocked = await GrowthStore.unlockedIds()
    const set = new Set<string>()
    for (const id of unlocked) {
      set.add(id)
    }
    const fresh: string[] = []
    const all = await InsightStore.loadAll()
    const streak = await InsightStore.streakDays()
    const stars = await InsightStore.starred()
    const judges = await InsightStore.judgments()

    if (all.length >= 1) {
      fresh.push(...await AchievementService.tryUnlock(set, 'first_entry'))
    }
    if (all.length >= 10) {
      fresh.push(...await AchievementService.tryUnlock(set, 'entries_10'))
    }
    if (streak >= 3) {
      fresh.push(...await AchievementService.tryUnlock(set, 'streak_3'))
    }
    if (streak >= 7) {
      fresh.push(...await AchievementService.tryUnlock(set, 'streak_7'))
    }
    if (stars.length >= 5) {
      fresh.push(...await AchievementService.tryUnlock(set, 'star_5'))
    }
    if (judges.length >= 3) {
      fresh.push(...await AchievementService.tryUnlock(set, 'judge_3'))
    }
    let hasVerdict = false
    for (const n of all) {
      if (n.verdict === 'hit' || n.verdict === 'miss' || n.verdict === 'revised') {
        hasVerdict = true
      }
    }
    if (hasVerdict) {
      fresh.push(...await AchievementService.tryUnlock(set, 'verdict_1'))
    }
    for (const n of all) {
      if (n.tags.indexOf('本周三问') >= 0 || n.title === '本周三问') {
        fresh.push(...await AchievementService.tryUnlock(set, 'week_review'))
        break
      }
    }
    return fresh
  }

  static async onEntryCreated(entry: InsightEntry): Promise<string[]> {
    await GrowthStore.logActivity('create', entry.id, `写下「${entry.title}」`)
    const today = DateHelper.todayKey()
    let count = 0
    const all = await InsightStore.loadAll()
    for (const n of all) {
      if (n.dateKey === today) {
        count++
      }
    }
    await GrowthStore.touchCheckIn(count)
    if (entry.tags.indexOf('今日一问') >= 0 || entry.title === '今日一问') {
      await GrowthStore.markPlanDone(0)
    }
    if (entry.tags.indexOf('本周三问') >= 0 || entry.title === '本周三问') {
      await GrowthStore.markPlanDone(2)
    }
    return AchievementService.evaluateAll()
  }

  static async onStarChanged(starred: boolean, entry: InsightEntry): Promise<string[]> {
    if (starred) {
      await GrowthStore.logActivity('star', entry.id, `星标「${entry.title}」`)
    }
    return AchievementService.evaluateAll()
  }

  static async onVerdictChanged(entry: InsightEntry): Promise<string[]> {
    await GrowthStore.logActivity('verdict', entry.id, `验收「${entry.title}」`)
    await GrowthStore.markPlanDone(1)
    return AchievementService.evaluateAll()
  }

  static labelForKind(kind: string): string {
    if (kind === 'create') {
      return '写下见解'
    }
    if (kind === 'star') {
      return '星标'
    }
    if (kind === 'verdict') {
      return '判断验收'
    }
    if (kind === 'plan') {
      return '周计划'
    }
    if (kind === 'checkin') {
      return '书写打卡'
    }
    if (kind === 'achievement') {
      return '徽章'
    }
    return '动态'
  }

  private static async tryUnlock(set: Set<string>, id: string): Promise<string[]> {
    if (set.has(id)) {
      return []
    }
    const ok = await GrowthStore.unlock(id)
    if (ok) {
      set.add(id)
      return [id]
    }
    return []
  }

  static nameForId(id: string): string {
    const defs = AchievementDef.all()
    for (const d of defs) {
      if (d.id === id) {
        return d.name
      }
    }
    return id
  }
}
