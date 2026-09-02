import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { AchievementDef, AchievementProgress, AchievementUnlock } from '../models/SaituGrowthModels'
import { SaituLocalStore } from './SaituLocalStore'
import { SaituTrackStore } from './SaituTrackStore'
import { SaituSportStore } from './SaituSportStore'
import { SaituCheckInStore } from './SaituCheckInStore'
import { SaituPlanStore } from './SaituPlanStore'

const STORE = 'saitu_zhaji_achievement_v1'
const KEY_UNLOCKS = 'unlocks'

export class SaituAchievementStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SaituAchievementStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      SaituAchievementStore.pref = null
    }
  }

  static async loadUnlocks(): Promise<AchievementUnlock[]> {
    return SaituAchievementStore.parse(await SaituAchievementStore.getString(KEY_UNLOCKS, ''))
  }

  static async isUnlocked(id: string): Promise<boolean> {
    const list = await SaituAchievementStore.loadUnlocks()
    for (const it of list) {
      if (it.achievementId === id) {
        return true
      }
    }
    return false
  }

  static async unlockedCount(): Promise<number> {
    return (await SaituAchievementStore.loadUnlocks()).length
  }

  static async evaluateAndUnlock(): Promise<string[]> {
    const newly: string[] = []
    const records = await SaituLocalStore.loadRecords()
    const milestones = await SaituTrackStore.loadMilestones()
    const events = await SaituSportStore.loadEvents()
    const plans = await SaituPlanStore.loadPlans()
    const checkStreak = await SaituCheckInStore.checkInStreak()
    const recordStreak = (await SaituLocalStore.dashboardStats()).streakDays

    let favorites = 0
    for (const r of records) {
      if (r.favorite) {
        favorites++
      }
    }
    for (const e of events) {
      if (e.favorite) {
        favorites++
      }
    }
    const insights = await SaituTrackStore.loadInsights()
    for (const s of insights) {
      if (s.favorite) {
        favorites++
      }
    }

    let milestoneDone = 0
    for (const m of milestones) {
      if (m.done) {
        milestoneDone++
      }
    }

    let hasReview = false
    for (const e of events) {
      if (e.kind === 'review') {
        hasReview = true
        break
      }
    }

    let hasDonePlan = false
    for (const p of plans) {
      if (p.status === 'done') {
        hasDonePlan = true
        break
      }
    }

    const rules: string[][] = [
      ['first_record', records.length >= 1 ? '1' : '0'],
      ['records_10', records.length >= 10 ? '1' : '0'],
      ['streak_7', (checkStreak >= 7 || recordStreak >= 7) ? '1' : '0'],
      ['first_review', hasReview ? '1' : '0'],
      ['first_plan', hasDonePlan ? '1' : '0'],
      ['favorite_5', favorites >= 5 ? '1' : '0'],
      ['milestone_5', milestoneDone >= 5 ? '1' : '0'],
      ['sport_10', events.length >= 10 ? '1' : '0']
    ]

    for (const row of rules) {
      if (row[1] === '1') {
        const ok = await SaituAchievementStore.unlock(row[0])
        if (ok) {
          newly.push(row[0])
        }
      }
    }
    return newly
  }

  static async clearAll(): Promise<void> {
    await SaituAchievementStore.putString(KEY_UNLOCKS, '')
  }

  private static async unlock(id: string): Promise<boolean> {
    if (await SaituAchievementStore.isUnlocked(id)) {
      return false
    }
    const list = await SaituAchievementStore.loadUnlocks()
    const u = new AchievementUnlock()
    u.achievementId = id
    u.unlockedAt = Date.now()
    list.push(u)
    await SaituAchievementStore.persist(list)
    return true
  }

  static defs(): AchievementDef[] {
    return AchievementDef.catalog()
  }

  static async progressFor(id: string): Promise<AchievementProgress> {
    const p = new AchievementProgress()
    const records = await SaituLocalStore.loadRecords()
    const milestones = await SaituTrackStore.loadMilestones()
    const events = await SaituSportStore.loadEvents()
    const plans = await SaituPlanStore.loadPlans()
    const checkStreak = await SaituCheckInStore.checkInStreak()
    const recordStreak = (await SaituLocalStore.dashboardStats()).streakDays

    let favorites = 0
    for (const r of records) {
      if (r.favorite) {
        favorites++
      }
    }
    for (const e of events) {
      if (e.favorite) {
        favorites++
      }
    }
    const insights = await SaituTrackStore.loadInsights()
    for (const s of insights) {
      if (s.favorite) {
        favorites++
      }
    }

    let milestoneDone = 0
    for (const m of milestones) {
      if (m.done) {
        milestoneDone++
      }
    }

    let hasReview = false
    for (const e of events) {
      if (e.kind === 'review') {
        hasReview = true
        break
      }
    }

    let hasDonePlan = false
    for (const p of plans) {
      if (p.status === 'done') {
        hasDonePlan = true
        break
      }
    }

    if (id === 'first_record') {
      p.current = records.length >= 1 ? 1 : 0
      p.target = 1
    } else if (id === 'records_10') {
      p.current = records.length
      p.target = 10
    } else if (id === 'streak_7') {
      p.current = checkStreak >= recordStreak ? checkStreak : recordStreak
      p.target = 7
    } else if (id === 'first_review') {
      p.current = hasReview ? 1 : 0
      p.target = 1
    } else if (id === 'first_plan') {
      p.current = hasDonePlan ? 1 : 0
      p.target = 1
    } else if (id === 'favorite_5') {
      p.current = favorites
      p.target = 5
    } else if (id === 'milestone_5') {
      p.current = milestoneDone
      p.target = 5
    } else if (id === 'sport_10') {
      p.current = events.length
      p.target = 10
    } else {
      p.current = 0
      p.target = 1
    }
    return p
  }

  private static async persist(items: AchievementUnlock[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push([it.achievementId, `${it.unlockedAt}`].join('\t'))
    }
    await SaituAchievementStore.putString(KEY_UNLOCKS, lines.join('\n'))
  }

  private static parse(raw: string): AchievementUnlock[] {
    const out: AchievementUnlock[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 2) {
        continue
      }
      const u = new AchievementUnlock()
      u.achievementId = p[0]
      u.unlockedAt = parseInt(p[1], 10)
      out.push(u)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (SaituAchievementStore.pref === null) {
      return fallback
    }
    try {
      const v = await SaituAchievementStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (SaituAchievementStore.pref === null) {
      return
    }
    try {
      await SaituAchievementStore.pref.put(key, value)
      await SaituAchievementStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
