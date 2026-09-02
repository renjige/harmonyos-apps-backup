import { ChecklistLine, ChecklistPack } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'
import { ActivityService } from './ActivityService'

export class ChecklistService {
  static async list(): Promise<ChecklistPack[]> {
    const rows = JujiaLocalStore.checklists()
    rows.sort((a: ChecklistPack, b: ChecklistPack) => b.updatedAt.localeCompare(a.updatedAt))
    return rows
  }

  static templateLines(kind: string): string[] {
    if (kind === '搬家') {
      return ['打包卧室物品', '联系搬家公司', '水电燃气过户', '清理旧居']
    }
    if (kind === '清洁') {
      return ['客厅除尘', '厨房油污', '卫生间消毒', '阳台整理']
    }
    if (kind === '装修') {
      return ['量房沟通', '材料采购', '施工验收', '通风散味']
    }
    return ['纸巾', '洗衣液', '垃圾袋', '常备药']
  }

  static async create(title: string, kind: string): Promise<ChecklistPack> {
    const rows = await ChecklistService.list()
    const pack = new ChecklistPack()
    pack.id = JujiaLocalStore.newId('cl')
    pack.title = title.trim()
    pack.kind = kind
    pack.userId = 'local'
    pack.createdAt = JujiaLocalStore.nowIso()
    pack.updatedAt = pack.createdAt
    const lines: ChecklistLine[] = []
    for (const text of ChecklistService.templateLines(kind)) {
      const ln = new ChecklistLine()
      ln.id = JujiaLocalStore.newId('ln')
      ln.text = text
      ln.done = false
      lines.push(ln)
    }
    pack.lines = lines
    rows.push(pack)
    await JujiaLocalStore.saveChecklists(rows)
    await ActivityService.log('create', 'checklist', pack.id, pack.title, pack.kind)
    return pack
  }

  static async find(id: string): Promise<ChecklistPack | null> {
    for (const row of await ChecklistService.list()) {
      if (row.id === id) {
        return row
      }
    }
    return null
  }

  static async toggleLine(packId: string, lineId: string): Promise<void> {
    const rows = await ChecklistService.list()
    const next: ChecklistPack[] = []
    for (const pack of rows) {
      if (pack.id !== packId) {
        next.push(pack)
        continue
      }
      const copy = ChecklistService.clone(pack)
      const lines: ChecklistLine[] = []
      for (const ln of copy.lines) {
        const line = new ChecklistLine()
        line.id = ln.id
        line.text = ln.text
        line.done = ln.id === lineId ? !ln.done : ln.done
        lines.push(line)
      }
      copy.lines = lines
      copy.updatedAt = JujiaLocalStore.nowIso()
      next.push(copy)
    }
    await JujiaLocalStore.saveChecklists(next)
  }

  static async addLine(packId: string, text: string): Promise<void> {
    const rows = await ChecklistService.list()
    const next: ChecklistPack[] = []
    for (const pack of rows) {
      if (pack.id !== packId) {
        next.push(pack)
        continue
      }
      const copy = ChecklistService.clone(pack)
      const ln = new ChecklistLine()
      ln.id = JujiaLocalStore.newId('ln')
      ln.text = text.trim()
      ln.done = false
      copy.lines.push(ln)
      copy.updatedAt = JujiaLocalStore.nowIso()
      next.push(copy)
    }
    await JujiaLocalStore.saveChecklists(next)
  }

  static async remove(id: string): Promise<void> {
    const rows = await ChecklistService.list()
    const next: ChecklistPack[] = []
    for (const row of rows) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    await JujiaLocalStore.saveChecklists(next)
  }

  static clone(row: ChecklistPack): ChecklistPack {
    const pack = new ChecklistPack()
    pack.id = row.id
    pack.title = row.title
    pack.kind = row.kind
    pack.userId = row.userId
    pack.createdAt = row.createdAt
    pack.updatedAt = row.updatedAt
    const lines: ChecklistLine[] = []
    for (const ln of row.lines) {
      const line = new ChecklistLine()
      line.id = ln.id
      line.text = ln.text
      line.done = ln.done
      lines.push(line)
    }
    pack.lines = lines
    return pack
  }

  static async countAll(): Promise<number> {
    return (await ChecklistService.list()).length
  }
}
