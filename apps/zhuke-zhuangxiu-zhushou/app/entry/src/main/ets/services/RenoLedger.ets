import { pasteboard } from '@kit.BasicServicesKit'
import { AuthService } from './AuthService'
import {
  RenoDates,
  RenoEvent,
  RenoExpense,
  RenoProject
} from '../models/RenoModels'
import { RenoLocalStore } from './RenoLocalStore'
import { RenoService } from './RenoService'

export class RenoLedger {
  static expenses(projectId: string): RenoExpense[] {
    const out: RenoExpense[] = []
    for (const row of RenoLocalStore.expenses()) {
      if (projectId.length === 0 || row.projectId === projectId) {
        out.push(RenoLocalStore.mapExpense(row))
      }
    }
    return out
  }

  static findExpense(id: string): RenoExpense {
    for (const row of RenoLocalStore.expenses()) {
      if (row.id === id) {
        return RenoLocalStore.mapExpense(row)
      }
    }
    return new RenoExpense()
  }

  static spent(projectId: string): number {
    let total = 0
    for (const row of RenoLedger.expenses(projectId)) {
      total += RenoDates.money(row.amount)
    }
    return total
  }

  static async saveExpense(draft: RenoExpense, isEdit: boolean): Promise<string> {
    const row = RenoLocalStore.mapExpense(draft)
    row.title = row.title.trim()
    row.userId = AuthService.isLoggedIn() ? RenoService.actorId() : 'local'
    row.updatedAt = RenoLocalStore.nowIso()
    if (row.date.length === 0) {
      row.date = RenoDates.today()
    }
    const next: RenoExpense[] = []
    if (!isEdit || row.id.length === 0) {
      row.id = RenoLocalStore.newId('exp')
      next.push(row)
      for (const it of RenoLocalStore.expenses()) {
        next.push(it)
      }
    } else {
      for (const it of RenoLocalStore.expenses()) {
        next.push(it.id === row.id ? row : it)
      }
    }
    const bundle = RenoLocalStore.snapshot()
    bundle.expenses = next
    await RenoLocalStore.replaceAll(bundle)
    return row.id
  }

  static async removeExpense(id: string): Promise<void> {
    const next: RenoExpense[] = []
    for (const it of RenoLocalStore.expenses()) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    const bundle = RenoLocalStore.snapshot()
    bundle.expenses = next
    await RenoLocalStore.replaceAll(bundle)
  }

  static timeline(projectId: string): RenoEvent[] {
    const rows: RenoEvent[] = []
    for (const it of RenoService.syncTasks(projectId)) {
      rows.push(RenoLedger.eventOf(`task_${it.id}`, it.title, `${it.stage} · ${RenoDates.taskLabel(it.status)}`,
        it.date.length > 0 ? it.date : it.updatedAt, 'task', it.id))
    }
    for (const it of RenoService.syncMaterials(projectId)) {
      rows.push(RenoLedger.eventOf(`mat_${it.id}`, it.title, `${it.room} · ${RenoDates.materialLabel(it.status)}`,
        it.updatedAt, 'material', it.id))
    }
    for (const it of RenoService.syncNotes(projectId)) {
      rows.push(RenoLedger.eventOf(`note_${it.id}`, it.title, it.kind, it.date, 'note', it.id))
    }
    for (const it of RenoLedger.expenses(projectId)) {
      rows.push(RenoLedger.eventOf(`exp_${it.id}`, it.title, `${it.category} · ¥${it.amount}`, it.date, 'expense', it.id))
    }
    return RenoLedger.sortEvents(rows)
  }

  static async exportProject(project: RenoProject): Promise<boolean> {
    const pid = project.id
    const lines: string[] = []
    lines.push('筑科装修助手 · 项目纪要')
    lines.push(`项目：${project.title}`)
    lines.push(`户型：${project.houseType}  阶段：${project.stage}  进度：${project.progress}%`)
    lines.push(`开工：${project.startDate}`)
    if (project.budget.length > 0) {
      lines.push(`预算：¥${project.budget}  已记费用：¥${RenoLedger.spent(pid)}`)
    } else {
      lines.push(`已记费用：¥${RenoLedger.spent(pid)}`)
    }
    lines.push('')
    lines.push('事项')
    const tasks = RenoService.syncTasks(pid)
    if (tasks.length === 0) {
      lines.push('（暂无）')
    }
    for (const it of tasks) {
      lines.push(`- ${it.title}（${it.stage} · ${RenoDates.taskLabel(it.status)}）`)
    }
    lines.push('')
    lines.push('材料')
    const mats = RenoService.syncMaterials(pid)
    if (mats.length === 0) {
      lines.push('（暂无）')
    }
    for (const it of mats) {
      lines.push(`- ${it.title} ${it.spec} ${it.room}（${RenoDates.materialLabel(it.status)}）`)
    }
    lines.push('')
    lines.push('现场记录')
    const notes = RenoService.syncNotes(pid)
    if (notes.length === 0) {
      lines.push('（暂无）')
    }
    for (const it of notes) {
      lines.push(`- ${it.date} ${it.title}（${it.kind}）`)
    }
    lines.push('')
    lines.push('费用')
    const exp = RenoLedger.expenses(pid)
    if (exp.length === 0) {
      lines.push('（暂无）')
    }
    for (const it of exp) {
      lines.push(`- ${it.date} ${it.title} ${it.category} ¥${it.amount}`)
    }
    lines.push('')
    lines.push('说明：本纪要仅供业主个人对照，不构成工程鉴定。')
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, lines.join('\n'))
      await pasteboard.getSystemPasteboard().setData(data)
      return true
    } catch {
      return false
    }
  }

  private static eventOf(id: string, title: string, summary: string, date: string, kind: string, targetId: string): RenoEvent {
    const row = new RenoEvent()
    row.id = id
    row.title = title
    row.summary = summary
    row.date = date.length >= 10 ? date.substring(0, 10) : date
    row.kind = kind
    row.targetId = targetId
    return row
  }

  private static sortEvents(rows: RenoEvent[]): RenoEvent[] {
    const out: RenoEvent[] = []
    const used: boolean[] = []
    for (let i = 0; i < rows.length; i++) {
      used.push(false)
    }
    for (let n = 0; n < rows.length; n++) {
      let best = -1
      for (let i = 0; i < rows.length; i++) {
        if (used[i]) {
          continue
        }
        if (best < 0 || rows[i].date > rows[best].date) {
          best = i
        }
      }
      if (best >= 0) {
        used[best] = true
        out.push(rows[best])
      }
    }
    return out
  }
}
