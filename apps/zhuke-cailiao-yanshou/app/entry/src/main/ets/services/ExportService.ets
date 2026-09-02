import { pasteboard } from '@kit.BasicServicesKit'
import { InspectRecord, InspectStatus } from '../models/InspectModels'
import { InspectGuide } from '../models/InspectGuide'
import { InspectLocalStore } from './InspectLocalStore'
import { InspectService } from './InspectService'

export class ExportService {
  static textOf(row: InspectRecord): string {
    const g = InspectGuide.of(row.category)
    const lines: string[] = []
    lines.push('筑科材料验收记录')
    lines.push(`材料：${row.materialName}`)
    lines.push(`类别：${row.category}`)
    lines.push(`工点：${row.projectName.length > 0 ? row.projectName : '未填写'}`)
    lines.push(`批次/送货单：${row.batchNo.length > 0 ? row.batchNo : '未填写'}`)
    lines.push(`规格：${row.spec.length > 0 ? row.spec : '未填写'}`)
    lines.push(`数量：${row.quantity} ${row.unit}`)
    lines.push(`供应商：${row.supplier.length > 0 ? row.supplier : '未填写'}`)
    lines.push(`进场日期：${row.arrivalDate}`)
    lines.push(`结论：${InspectStatus.label(row.result)}`)
    lines.push(`外观：${InspectStatus.checkLabel('look', row.checkAppearance)}`)
    lines.push(`包装：${InspectStatus.checkLabel('pack', row.checkPacking)}`)
    lines.push(`数量检查：${InspectStatus.checkLabel('qty', row.checkQty)}`)
    lines.push(`资料：${InspectStatus.checkLabel('docs', row.checkDocs)}`)
    if (g.extraA.length > 0) {
      lines.push(`${g.extraA}：${InspectStatus.checkLabel('look', row.extraA)}`)
    }
    if (g.extraB.length > 0) {
      lines.push(`${g.extraB}：${InspectStatus.checkLabel('look', row.extraB)}`)
    }
    lines.push(`备注：${row.remark.length > 0 ? row.remark : '无'}`)
    if (row.followUpNote.length > 0) {
      lines.push(`异常跟进：${row.followUpNote}`)
    }
    lines.push(`记录时间：${InspectLocalStore.displayTime(row.updatedAt)}`)
    return lines.join('\n')
  }

  static async copyRecord(row: InspectRecord): Promise<boolean> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, ExportService.textOf(row))
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      return true
    } catch {
      return false
    }
  }

  static todayReportText(): string {
    const s = InspectService.stats()
    const lines: string[] = []
    lines.push('筑科材料验收 · 今日日报')
    lines.push(`日期：${InspectLocalStore.today()}`)
    lines.push(`今日验收：${s.todayTotal} 条`)
    lines.push(`已通过：${s.todayDone} 条`)
    lines.push(`待验收：${s.todayPending} 条`)
    lines.push(`待跟进：${InspectService.pendingFollow().length} 条`)
    lines.push('')
    let n = 0
    for (const row of InspectService.todayRecords()) {
      if (n >= 8) {
        lines.push('…')
        break
      }
      lines.push(`· ${row.materialName}（${InspectStatus.label(row.result)}）${row.projectName.length > 0 ? ' @ ' + row.projectName : ''}`)
      n += 1
    }
    return lines.join('\n')
  }

  static async copyTodayReport(): Promise<boolean> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, ExportService.todayReportText())
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      return true
    } catch {
      return false
    }
  }
}
