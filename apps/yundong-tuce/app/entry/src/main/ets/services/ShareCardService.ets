import { pasteboard } from '@kit.BasicServicesKit'
import { SportRecord } from '../models/SportRecord'
import { SportTypeOption } from '../models/SportRecord'

export class ShareCardService {
  static buildCard(record: SportRecord): string {
    const lines: string[] = []
    lines.push('运动图册 · 成就卡片')
    lines.push('')
    lines.push(`${record.displayTitle()} · ${SportTypeOption.labelOf(record.sportType)}`)
    lines.push(`${record.date} ${record.time}`)
    if (record.primaryMetric().length > 0) {
      lines.push(record.primaryMetric())
    }
    if (record.summaryLine().length > 0) {
      lines.push(record.summaryLine())
    }
    if (record.note.length > 0) {
      lines.push('')
      lines.push(record.note)
    }
    lines.push('')
    lines.push('— 蜕变影像 · 运动图册')
    return lines.join('\n')
  }

  static async copyCard(record: SportRecord): Promise<boolean> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, ShareCardService.buildCard(record))
      await pasteboard.getSystemPasteboard().setData(data)
      return true
    } catch {
      return false
    }
  }
}
