import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { pasteboard } from '@kit.BasicServicesKit'
import { MonthlyReportService } from './MonthlyReportService'
import { MoodStore } from './MoodStore'
import { DateHelper } from './DateHelper'
import { EmotionCatalog } from '../models/EmotionCatalog'

export class ExportService {
  static async exportAllToFile(context: common.UIAbilityContext): Promise<string> {
    const text = await MoodStore.exportAllText()
    return ExportService.writeTextFile(context, text, 'yuehen_all')
  }

  static async exportMonthlyReport(context: common.UIAbilityContext, year: number, month: number): Promise<string> {
    const report = await MonthlyReportService.buildReport(year, month)
    const lines: string[] = []
    lines.push(`月痕集 · ${DateHelper.monthLabel(year, month)} 情绪月痕报告`)
    lines.push('')
    lines.push(`记录天数：${report.recordDays}`)
    lines.push(`平均能量：${report.avgScore}/10`)
    lines.push('')
    lines.push('—— 情绪词云 ——')
    for (const ec of report.emotionCounts) {
      lines.push(`${ec.label} × ${ec.count}`)
    }
    lines.push('')
    lines.push('—— 月度寄语 ——')
    lines.push(report.monthlyMessage)
    lines.push('')
    lines.push('—— 高光时刻 ——')
    for (const h of report.highlights) {
      lines.push(`${DateHelper.displayDate(h.dateKey)} · 能量 ${h.score}`)
      if (h.emotions.length > 0) {
        const labels: string[] = []
        for (const id of h.emotions) {
          labels.push(EmotionCatalog.labelOf(id))
        }
        lines.push(`情绪：${labels.join('、')}`)
      }
      lines.push(h.diary)
      lines.push('')
    }
    return ExportService.writeTextFile(context, lines.join('\n'), `yuehen_report_${year}_${month}`)
  }

  static async copyToClipboard(text: string): Promise<boolean> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const sys = pasteboard.getSystemPasteboard()
      await sys.setData(data)
      return true
    } catch {
      return false
    }
  }

  private static writeTextFile(context: common.UIAbilityContext, text: string, prefix: string): string {
    const dir = `${context.filesDir}/exports`
    try {
      fileIo.mkdirSync(dir)
    } catch {
      // exists
    }
    const path = `${dir}/${prefix}_${Date.now()}.txt`
    let file: fileIo.File | null = null
    try {
      file = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.TRUNC)
      fileIo.writeSync(file.fd, text)
      return path
    } finally {
      if (file !== null) {
        try { fileIo.closeSync(file) } catch { /* ignore */ }
      }
    }
  }
}
