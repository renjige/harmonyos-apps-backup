import { CoachingReport } from '../models/WorkoutModels'
import { PlanStore } from './PlanStore'
import { StatsService } from './StatsService'
import { TrainingStore } from './TrainingStore'
import { WorkoutStore } from './WorkoutStore'

export class ReportService {
  static async weeklyCoaching(): Promise<CoachingReport> {
    const report = new CoachingReport()
    report.title = '本周训练复盘'
    const snap = await StatsService.weekCompareSnapshot()
    const totals = await StatsService.totals()
    const profile = await WorkoutStore.loadProfile()
    const paragraphs: string[] = []

    if (totals.totalWorkouts === 0) {
      paragraphs.push('你还没有训练记录。建议从「记录训练」开始第一笔日志，或在计划中心加入 7 天活力计划，让图志慢慢连成线。')
      report.paragraphs = paragraphs
      return report
    }

    let line1 = `本周已训练 ${snap.thisDays} 天、累计 ${snap.thisMinutes} 分钟`
    if (snap.deltaMinutes > 0) {
      line1 = `${line1}，比上周多 ${snap.deltaMinutes} 分钟，节奏在提升。`
    } else if (snap.deltaMinutes < 0) {
      line1 = `${line1}，比上周少 ${0 - snap.deltaMinutes} 分钟，可适当安排一次恢复日。`
    } else {
      line1 = `${line1}，与上周时长持平，保持稳定性同样重要。`
    }
    paragraphs.push(line1)

    if (totals.mostCommonTypeLabel.length > 0) {
      paragraphs.push(`近期最常记录的是「${totals.mostCommonTypeLabel}」。可在图鉴中补充相关动作收藏，并在清单里勾选完成项，形成「计划 → 执行 → 复盘」闭环。`)
    }

    const goalLeft = profile.weeklyGoalDays - totals.weekActiveDays
    if (goalLeft > 0) {
      paragraphs.push(`距离本周目标（${profile.weeklyGoalDays} 天）还差 ${goalLeft} 天。首页「本周活跃」可快速查看哪几天尚未记录。`)
    } else {
      paragraphs.push(`已达成本周 ${profile.weeklyGoalDays} 天训练目标。建议查看成长页个人最佳，尝试刷新单次最长时长或单日总时长。`)
    }

    const slot = await PlanStore.todaySlot()
    if (slot !== undefined && slot.enabled) {
      paragraphs.push(`今日计划：${slot.targetMinutes} 分钟主题训练。完成后可在成长热力图点击当天格子，核对当日多条日志。`)
    }

    const ch = await TrainingStore.loadChallenges()
    let activeCh = 0
    for (const c of ch) {
      if (!c.done) {
        activeCh++
      }
    }
    if (activeCh > 0) {
      paragraphs.push(`计划中心有 ${activeCh} 项进行中的挑战。坚持打卡会同步更新首页「完成目标」与成长页成就。`)
    }

    if (totals.streakDays >= 3) {
      paragraphs.push(`已连续训练 ${totals.streakDays} 天。保持节奏的同时，记得在「我的 → 状态笔记」记录体能与动力感受，便于长期对照。`)
    }

    report.paragraphs = paragraphs
    return report
  }
}
