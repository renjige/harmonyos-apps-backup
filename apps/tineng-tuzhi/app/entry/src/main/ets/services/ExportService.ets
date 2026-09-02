import { pasteboard } from '@kit.BasicServicesKit'
import { WorkoutTypeOption } from '../models/WorkoutModels'
import { StatsService } from './StatsService'
import { WorkoutStore } from './WorkoutStore'

export class ExportService {
  static async buildSummaryText(): Promise<string> {
    const profile = await WorkoutStore.loadProfile()
    const totals = await StatsService.totals()
    const list = await WorkoutStore.loadAll()
    const lines: string[] = []
    lines.push('体能图志 · 运动数据导出')
    lines.push(`昵称：${profile.nickname}`)
    lines.push(`导出时间：${new Date().toLocaleString()}`)
    lines.push('---')
    lines.push(`累计运动：${totals.totalWorkouts} 次 · ${totals.totalMinutes} 分钟 · ${totals.totalCalories} 千卡`)
    lines.push(`累计距离：${totals.totalDistanceKm} 公里 · 连续 ${totals.streakDays} 天`)
    lines.push(`本周活跃：${totals.weekActiveDays}/${totals.weekGoalDays} 天`)
    lines.push('---')
    for (const w of list) {
      lines.push(`日期：${w.dateKey}`)
      lines.push(`  类型：${WorkoutTypeOption.labelFor(w.typeKey)} · ${w.durationMinutes} 分钟 · ${w.calories} 千卡`)
      if (w.distanceKm > 0) {
        lines.push(`  距离：${w.distanceKm} 公里`)
      }
      if (w.note.length > 0) {
        lines.push(`  训练内容：${w.note}`)
      }
      if (w.insight.length > 0) {
        lines.push(`  心得：${w.insight}`)
      }
      if (w.tag.length > 0) {
        lines.push(`  标签：${w.tag}`)
      }
      lines.push('')
    }
    return lines.join('\n')
  }

  static async copyToClipboard(): Promise<boolean> {
    const text = await ExportService.buildSummaryText()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      return true
    } catch {
      return false
    }
  }
}
