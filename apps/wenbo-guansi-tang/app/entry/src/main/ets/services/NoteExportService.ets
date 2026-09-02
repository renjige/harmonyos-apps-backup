import { WisdomItem } from '../models/WisdomHallModels'
import { WisdomHallBizService } from './WisdomHallBizService'

export class NoteExportSummary {
  exportedAt: string = ''
  noteCount: number = 0
  bodyText: string = ''

  static empty(): NoteExportSummary {
    return new NoteExportSummary()
  }
}

/** 本地导出笔记摘要（纯文本，不含生成式内容） */
export class NoteExportService {
  static async buildExportSummary(): Promise<NoteExportSummary> {
    const notes = await WisdomHallBizService.loadThoughts()
    const summary = new NoteExportSummary()
    summary.exportedAt = new Date().toISOString()
    summary.noteCount = notes.length
    const lines: string[] = []
    lines.push('# 观思堂 · 笔记导出')
    lines.push(`导出时间：${summary.exportedAt}`)
    lines.push(`共 ${notes.length} 条笔记`)
    lines.push('')
    let idx = 1
    for (const n of notes) {
      lines.push(`## ${idx}. ${n.title}`)
      if (n.category.length > 0) {
        lines.push(`标签：${n.category}`)
      }
      if (n.updatedAt.length > 0) {
        lines.push(`更新：${n.updatedAt}`)
      }
      if (n.body.length > 0) {
        lines.push(n.body)
      }
      lines.push('')
      idx += 1
    }
    summary.bodyText = lines.join('\n')
    return summary
  }
}
