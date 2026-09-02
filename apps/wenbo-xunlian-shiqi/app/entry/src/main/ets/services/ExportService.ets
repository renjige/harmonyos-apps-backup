import { pasteboard } from '@kit.BasicServicesKit'
import { FunQuestStore } from './FunQuestStore'
import { FunQuestService } from './FunQuestService'
import { TrainingStore } from './TrainingStore'
import { PracticeHubStore } from './PracticeHubStore'
import { PlanService } from './PlanService'

export class ExportService {
  static buildText(): string {
    const lines: string[] = []
    lines.push('训练拾趣 · 本机成长轨迹')
    lines.push('')
    lines.push('【训练记录】')
    const records = TrainingStore.list()
    if (records.length === 0) {
      lines.push('暂无记录')
    }
    for (const r of records) {
      lines.push(`${r.recordDate} ${r.trainingType} ${r.durationMin}分钟 ${r.completeStatus} 体感${r.feeling}`)
      if (r.note.length > 0) {
        lines.push(`  心得：${r.note}`)
      }
    }
    lines.push('')
    lines.push('【拾趣挑战】')
    const quests = FunQuestStore.list()
    if (quests.length === 0) {
      lines.push('暂无挑战')
    }
    for (const q of quests) {
      const p = FunQuestService.progress(q)
      lines.push(`${q.title} · ${q.theme} · ${p.current}/${p.target}${p.unit} · ${q.status === 'done' ? '已完成' : '进行中'}`)
    }
    lines.push('')
    lines.push('【训练计划】')
    const plans = PracticeHubStore.listPlans()
    if (plans.length === 0) {
      lines.push('暂无计划')
    }
    for (const plan of plans) {
      lines.push(`${plan.title} · ${PlanService.doneCount(plan)}/${PlanService.totalCount(plan)}`)
    }
    return lines.join('\n')
  }

  static async copyToClipboard(): Promise<boolean> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, ExportService.buildText())
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      return true
    } catch {
      return false
    }
  }
}
