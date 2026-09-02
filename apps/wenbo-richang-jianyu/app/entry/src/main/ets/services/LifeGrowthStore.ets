import { SessionStore } from './SessionStore'
import { LifeDates } from '../models/LifeHubModels'
import { LifeHubStore } from './LifeHubStore'
import { PlanItem, PlanTask, QuoteFolder, ThemeTopic } from '../models/LifeGrowthModels'

class PlanTaskWire {
  id: string = ''
  title: string = ''
  done: boolean = false
}

class PlanWire {
  id: string = ''
  title: string = ''
  cycle: string = ''
  startDate: string = ''
  endDate: string = ''
  note: string = ''
  status: string = ''
  tasks: PlanTaskWire[] = []
}

class PlanFile {
  items: PlanWire[] = []
}

class TopicWire {
  id: string = ''
  title: string = ''
  tagName: string = ''
  note: string = ''
  createdAt: string = ''
}

class TopicFile {
  items: TopicWire[] = []
}

class FolderWire {
  id: string = ''
  title: string = ''
  itemIds: string[] = []
}

class FolderFile {
  items: FolderWire[] = []
}

/** 计划 / 专题 / 语句匣 — 本机 Preferences */
export class LifeGrowthStore {
  static lastError: string = ''

  private static uid(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  private static key(kind: string): string {
    return `life_${kind}_${LifeGrowthStore.uid()}`
  }

  private static async writeItems(kind: string, jsonItems: string): Promise<void> {
    const uid = LifeGrowthStore.uid()
    if (uid.length === 0) {
      return
    }
    await SessionStore.writeRaw(LifeGrowthStore.key(kind), `{"items":[${jsonItems}]}`)
    LifeHubStore.notifyChanged()
  }

  private static joinJson(parts: string[]): string {
    let body = ''
    let first = true
    for (const p of parts) {
      if (!first) {
        body += ','
      }
      first = false
      body += p
    }
    return body
  }

  static async loadPlans(): Promise<PlanItem[]> {
    const raw = await SessionStore.readRaw(LifeGrowthStore.key('plans'))
    const out: PlanItem[] = []
    if (raw.length === 0) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as PlanFile
      if (parsed === undefined || parsed.items === undefined) {
        return out
      }
      for (const w of parsed.items) {
        const row = new PlanItem()
        row.id = w.id !== undefined && w.id !== null ? w.id : ''
        row.title = w.title !== undefined && w.title !== null ? w.title : ''
        row.cycle = w.cycle !== undefined && w.cycle !== null ? w.cycle : 'week'
        row.startDate = w.startDate !== undefined && w.startDate !== null ? w.startDate : ''
        row.endDate = w.endDate !== undefined && w.endDate !== null ? w.endDate : ''
        row.note = w.note !== undefined && w.note !== null ? w.note : ''
        row.status = w.status !== undefined && w.status !== null ? w.status : 'active'
        const tasks: PlanTask[] = []
        if (w.tasks !== undefined && w.tasks !== null) {
          for (const t of w.tasks) {
            tasks.push(PlanTask.of(
              t.id !== undefined && t.id !== null ? t.id : '',
              t.title !== undefined && t.title !== null ? t.title : '',
              t.done === true
            ))
          }
        }
        row.tasks = tasks
        if (row.id.length > 0) {
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  static async savePlans(items: PlanItem[]): Promise<void> {
    const parts: string[] = []
    for (const row of items) {
      parts.push(row.toJsonString())
    }
    await LifeGrowthStore.writeItems('plans', LifeGrowthStore.joinJson(parts))
  }

  static async upsertPlan(item: PlanItem): Promise<void> {
    const list = await LifeGrowthStore.loadPlans()
    const next: PlanItem[] = []
    let found = false
    for (const row of list) {
      if (row.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(row)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    if (item.tasks.length > 0 && item.doneCount() >= item.tasks.length) {
      item.status = 'done'
    }
    await LifeGrowthStore.savePlans(next)
  }

  static async removePlan(id: string): Promise<void> {
    const list = await LifeGrowthStore.loadPlans()
    const next: PlanItem[] = []
    for (const row of list) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    await LifeGrowthStore.savePlans(next)
  }

  static newWeekPlan(title: string): PlanItem {
    const row = new PlanItem()
    row.id = LifeHubStore.newId('plan')
    row.title = title
    row.cycle = 'week'
    row.startDate = LifeDates.weekStartIso()
    row.endDate = LifeDates.shiftIso(row.startDate, 6)
    row.status = 'active'
    return row
  }

  static newMonthPlan(title: string): PlanItem {
    const row = new PlanItem()
    row.id = LifeHubStore.newId('plan')
    row.title = title
    row.cycle = 'month'
    const today = LifeDates.todayIso()
    row.startDate = `${today.substring(0, 7)}-01`
    row.endDate = LifeDates.monthEndIso()
    row.status = 'active'
    return row
  }

  static async loadTopics(): Promise<ThemeTopic[]> {
    const raw = await SessionStore.readRaw(LifeGrowthStore.key('topics'))
    const out: ThemeTopic[] = []
    if (raw.length === 0) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as TopicFile
      if (parsed === undefined || parsed.items === undefined) {
        return out
      }
      for (const w of parsed.items) {
        const row = new ThemeTopic()
        row.id = w.id !== undefined && w.id !== null ? w.id : ''
        row.title = w.title !== undefined && w.title !== null ? w.title : ''
        row.tagName = w.tagName !== undefined && w.tagName !== null ? w.tagName : ''
        row.note = w.note !== undefined && w.note !== null ? w.note : ''
        row.createdAt = w.createdAt !== undefined && w.createdAt !== null ? w.createdAt : ''
        if (row.id.length > 0) {
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  static async saveTopics(items: ThemeTopic[]): Promise<void> {
    const parts: string[] = []
    for (const row of items) {
      parts.push(row.toJsonString())
    }
    await LifeGrowthStore.writeItems('topics', LifeGrowthStore.joinJson(parts))
  }

  static async upsertTopic(item: ThemeTopic): Promise<void> {
    const list = await LifeGrowthStore.loadTopics()
    const next: ThemeTopic[] = []
    let found = false
    for (const row of list) {
      if (row.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(row)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    await LifeGrowthStore.saveTopics(next)
  }

  static async removeTopic(id: string): Promise<void> {
    const list = await LifeGrowthStore.loadTopics()
    const next: ThemeTopic[] = []
    for (const row of list) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    await LifeGrowthStore.saveTopics(next)
  }

  static async loadFolders(): Promise<QuoteFolder[]> {
    const raw = await SessionStore.readRaw(LifeGrowthStore.key('folders'))
    const out: QuoteFolder[] = []
    if (raw.length === 0) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as FolderFile
      if (parsed === undefined || parsed.items === undefined) {
        return out
      }
      for (const w of parsed.items) {
        const row = new QuoteFolder()
        row.id = w.id !== undefined && w.id !== null ? w.id : ''
        row.title = w.title !== undefined && w.title !== null ? w.title : ''
        row.itemIds = w.itemIds !== undefined && w.itemIds !== null ? w.itemIds : []
        if (row.id.length > 0) {
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  static async saveFolders(items: QuoteFolder[]): Promise<void> {
    const parts: string[] = []
    for (const row of items) {
      parts.push(row.toJsonString())
    }
    await LifeGrowthStore.writeItems('folders', LifeGrowthStore.joinJson(parts))
  }

  static async upsertFolder(item: QuoteFolder): Promise<void> {
    const list = await LifeGrowthStore.loadFolders()
    const next: QuoteFolder[] = []
    let found = false
    for (const row of list) {
      if (row.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(row)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    await LifeGrowthStore.saveFolders(next)
  }

  static async toggleFolderItem(folderId: string, itemId: string): Promise<void> {
    const list = await LifeGrowthStore.loadFolders()
    for (const row of list) {
      if (row.id === folderId) {
        const nextIds: string[] = []
        let found = false
        for (const x of row.itemIds) {
          if (x === itemId) {
            found = true
          } else {
            nextIds.push(x)
          }
        }
        if (!found) {
          nextIds.push(itemId)
        }
        row.itemIds = nextIds
      }
    }
    await LifeGrowthStore.saveFolders(list)
  }
}
