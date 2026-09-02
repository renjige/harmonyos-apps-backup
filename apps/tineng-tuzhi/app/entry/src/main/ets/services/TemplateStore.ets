import { QuickTemplate } from '../models/TrainingModels'
import { WorkoutRecord, WorkoutTypeOption } from '../models/WorkoutModels'
import { DateHelper } from './DateHelper'
import { WorkoutStore } from './WorkoutStore'

const KEY_TEMPLATES = 'quick_templates'

export class TemplateStore {
  static async list(): Promise<QuickTemplate[]> {
    const raw = await WorkoutStore.readRaw(KEY_TEMPLATES)
    if (raw.length === 0) {
      return []
    }
    const out: QuickTemplate[] = []
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 5) {
        continue
      }
      const t = new QuickTemplate()
      t.id = parts[0]
      t.title = parts[1]
      t.typeKey = parts[2]
      t.durationMinutes = parseInt(parts[3], 10)
      t.sessionTitle = parts[4]
      t.lastUsedAt = parts.length >= 6 ? parseInt(parts[5], 10) : 0
      out.push(t)
    }
    TemplateStore.sortByUsed(out)
    return out
  }

  private static sortByUsed(list: QuickTemplate[]): void {
    for (let i = 0; i < list.length; i++) {
      for (let j = i + 1; j < list.length; j++) {
        if (list[j].lastUsedAt > list[i].lastUsedAt) {
          const tmp = list[i]
          list[i] = list[j]
          list[j] = tmp
        }
      }
    }
  }

  static async rememberFromRecord(rec: WorkoutRecord): Promise<void> {
    const title = rec.sessionTitle.length > 0 ?
      rec.sessionTitle : WorkoutTypeOption.labelFor(rec.typeKey)
    const list = await TemplateStore.list()
    const next: QuickTemplate[] = []
    let replaced = false
    for (const t of list) {
      if (t.title === title && t.typeKey === rec.typeKey) {
        const u = new QuickTemplate()
        u.id = t.id
        u.title = title
        u.typeKey = rec.typeKey
        u.durationMinutes = rec.durationMinutes
        u.sessionTitle = rec.sessionTitle
        u.lastUsedAt = Date.now()
        next.push(u)
        replaced = true
      } else {
        next.push(t)
      }
    }
    if (!replaced) {
      const u = new QuickTemplate()
      u.id = `${Date.now()}-${Math.floor(Math.random() * 10000)}`
      u.title = title
      u.typeKey = rec.typeKey
      u.durationMinutes = rec.durationMinutes
      u.sessionTitle = rec.sessionTitle
      u.lastUsedAt = Date.now()
      next.unshift(u)
    }
    while (next.length > 5) {
      next.pop()
    }
    await TemplateStore.persist(next)
  }

  static async toRecord(t: QuickTemplate, dateKey?: string): Promise<WorkoutRecord> {
    const rec = WorkoutRecord.createNew(dateKey !== undefined && dateKey.length >= 8 ?
      dateKey : DateHelper.todayKey())
    rec.typeKey = t.typeKey
    rec.durationMinutes = t.durationMinutes
    rec.sessionTitle = t.sessionTitle.length > 0 ? t.sessionTitle : t.title
    rec.calories = WorkoutRecord.estimateCalories(t.typeKey, t.durationMinutes)
    rec.completeState = 'done'
    return rec
  }

  static async lastWorkout(): Promise<WorkoutRecord | undefined> {
    const list = await WorkoutStore.loadAll()
    if (list.length === 0) {
      return undefined
    }
    let top: WorkoutRecord | undefined = undefined
    for (const w of list) {
      if (top === undefined || w.timestamp > top.timestamp) {
        top = w
      }
    }
    return top
  }

  private static async persist(list: QuickTemplate[]): Promise<void> {
    const lines: string[] = []
    for (const t of list) {
      lines.push([
        t.id,
        t.title.replace(/\t/g, ' '),
        t.typeKey,
        `${t.durationMinutes}`,
        t.sessionTitle.replace(/\t/g, ' '),
        `${t.lastUsedAt}`
      ].join('\t'))
    }
    await WorkoutStore.writeRaw(KEY_TEMPLATES, lines.join('\n'))
  }
}
