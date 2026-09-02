import { ActionLog, GrowthStats } from '../models/ZhixingModels'
import { ZhixingStore } from './ZhixingStore'

export class ReviewService {
  static async weekSummary(): Promise<string> {
    const g = await ZhixingQuery.weekGrowth()
    const lines: string[] = []
    lines.push('【本周学习回顾】')
    lines.push(`新增知识 ${g.weekKnowledge} 条 · 行动日志 ${g.weekLogs} 条`)
    lines.push(`累计知识 ${g.knowledgeTotal} · 完成计划 ${g.donePlans} · 最长连续 ${g.maxStreak} 天`)
    const stale = await ZhixingStore.staleItems()
    if (stale.length > 0) {
      lines.push(`待复习 ${stale.length} 条，建议本周至少更新 2 条卡片摘要。`)
    } else {
      lines.push('知识库更新及时，继续保持「知→行」转化节奏。')
    }
    return lines.join('\n')
  }

  static async monthSummary(): Promise<string> {
    const g = await ZhixingQuery.monthGrowth()
    const lines: string[] = []
    lines.push('【本月学习回顾】')
    lines.push(`本月习惯打卡 ${g.monthChecks} 次 · 行动日志 ${g.logTotal} 条`)
    lines.push(`收藏 ${g.favoriteTotal} 条 · 完成计划 ${g.donePlans} 个`)
    lines.push('建议：把高频标签整理成专题，在行录中设对应计划。')
    return lines.join('\n')
  }
}

class ZhixingQuery {
  static async weekGrowth(): Promise<GrowthStats> {
    const g = new GrowthStats()
    const start = ZhixingStore.weekStartMs()
    const items = await ZhixingStore.loadItems()
    for (const it of items) {
      g.knowledgeTotal++
      if (it.favorite) {
        g.favoriteTotal++
      }
      if (it.createTime >= start) {
        g.weekKnowledge++
      }
    }
    const logs = await ZhixingStore.loadLogs()
    g.logTotal = logs.length
    for (const l of logs) {
      if (l.createTime >= start) {
        g.weekLogs++
      }
    }
    const plans = await ZhixingStore.loadPlans()
    for (const p of plans) {
      if (p.status === 'done') {
        g.donePlans++
      }
    }
    const habits = await ZhixingStore.loadHabits()
    for (const h of habits) {
      if (h.streak > g.maxStreak) {
        g.maxStreak = h.streak
      }
    }
    return g
  }

  static async monthGrowth(): Promise<GrowthStats> {
    const g = await ZhixingQuery.weekGrowth()
    const now = new Date()
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1).getTime()
    const habits = await ZhixingStore.loadHabits()
    let checks = 0
    for (const h of habits) {
      for (const d of h.checkDates) {
        const ms = Date.parse(`${d}T00:00:00`)
        if (ms >= monthStart) {
          checks++
        }
      }
    }
    g.monthChecks = checks
    return g
  }
}
