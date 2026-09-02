import { AchievementDef, AchievementState } from '../models/WorkoutModels'
import { PlanStore } from './PlanStore'
import { StatsService } from './StatsService'
import { TrainingStore } from './TrainingStore'
import { WorkoutStore } from './WorkoutStore'

export class AchievementService {
  static definitions(): AchievementDef[] {
    const defs: AchievementDef[] = []
    const rows: string[][] = [
      ['first', '初次训练', '完成首次训练日志', 'check'],
      ['streak7', '坚持达人', '连续 7 天有训练', 'chart'],
      ['streak30', '月度坚持', '连续 30 天有训练', 'chart'],
      ['hours10', '十小时里程碑', '累计训练满 10 小时', 'check'],
      ['hours100', '百小时达人', '累计训练满 100 小时', 'chart'],
      ['count20', '二十次突破', '累计记录 20 次训练', 'check'],
      ['count100', '百次训练', '累计记录 100 次训练', 'check'],
      ['weekgoal', '周目标达成', '本周训练天数达标', 'check'],
      ['distance50', '五十公里', '累计距离达 50 公里', 'biz'],
      ['plan1', '自律训练者', '完成首次周训编排', 'chart'],
      ['challenge1', '活力先锋', '完成一项体能挑战', 'ai']
    ]
    for (const row of rows) {
      const d = new AchievementDef()
      d.id = row[0]
      d.title = row[1]
      d.description = row[2]
      d.iconName = row[3]
      defs.push(d)
    }
    return defs
  }

  static async evaluateAndUnlock(): Promise<string[]> {
    const newly: string[] = []
    const unlocked = await WorkoutStore.loadUnlockedAchievements()
    const totals = await StatsService.totals()
    const streak = totals.streakDays
    const totalHours = Math.floor(totals.totalMinutes / 60)
    const profile = await WorkoutStore.loadProfile()
    const hasPlan = await PlanStore.hasScheduledPlan()
    const chList = await TrainingStore.loadChallenges()
    let anyCh = false
    for (const c of chList) {
      if (c.done) {
        anyCh = true
      }
    }

    const checks: string[][] = [
      ['first', totals.totalWorkouts >= 1 ? '1' : '0'],
      ['streak7', streak >= 7 ? '1' : '0'],
      ['streak30', streak >= 30 ? '1' : '0'],
      ['hours10', totalHours >= 10 ? '1' : '0'],
      ['hours100', totalHours >= 100 ? '1' : '0'],
      ['count20', totals.totalWorkouts >= 20 ? '1' : '0'],
      ['count100', totals.totalWorkouts >= 100 ? '1' : '0'],
      ['weekgoal', totals.weekActiveDays >= profile.weeklyGoalDays ? '1' : '0'],
      ['distance50', totals.totalDistanceKm >= 50 ? '1' : '0'],
      ['plan1', hasPlan ? '1' : '0'],
      ['challenge1', anyCh ? '1' : '0']
    ]

    for (const c of checks) {
      let already = false
      for (const u of unlocked) {
        if (u === c[0]) {
          already = true
        }
      }
      if (!already && c[1] === '1') {
        await WorkoutStore.unlockAchievement(c[0])
        newly.push(c[0])
      }
    }
    return newly
  }

  static async allStates(): Promise<AchievementState[]> {
    const unlocked = await WorkoutStore.loadUnlockedAchievements()
    const out: AchievementState[] = []
    for (const d of AchievementService.definitions()) {
      const s = new AchievementState()
      s.id = d.id
      s.title = d.title
      s.description = d.description
      s.unlocked = false
      for (const u of unlocked) {
        if (u === d.id) {
          s.unlocked = true
          s.unlockedAt = Date.now()
        }
      }
      out.push(s)
    }
    return out
  }
}
