import { DiaryEntry } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'
import { ActivityService } from './ActivityService'

export class DiaryService {
  static async list(): Promise<DiaryEntry[]> {
    const rows = JujiaLocalStore.diaries()
    rows.sort((a: DiaryEntry, b: DiaryEntry) => b.updatedAt.localeCompare(a.updatedAt))
    return rows
  }

  static async create(draft: DiaryEntry): Promise<DiaryEntry> {
    const rows = await DiaryService.list()
    const row = new DiaryEntry()
    row.id = JujiaLocalStore.newId('diary')
    row.title = draft.title.trim()
    row.body = draft.body.trim()
    row.mood = draft.mood
    row.userId = 'local'
    row.createdAt = JujiaLocalStore.nowIso()
    row.updatedAt = row.createdAt
    rows.push(row)
    await JujiaLocalStore.saveDiaries(rows)
    await ActivityService.log('create', 'diary', row.id, row.title, row.mood)
    return row
  }

  static async update(row: DiaryEntry): Promise<void> {
    const rows = await DiaryService.list()
    const next: DiaryEntry[] = []
    for (const item of rows) {
      if (item.id === row.id) {
        row.updatedAt = JujiaLocalStore.nowIso()
        next.push(row)
      } else {
        next.push(item)
      }
    }
    await JujiaLocalStore.saveDiaries(next)
  }

  static async remove(id: string): Promise<void> {
    const rows = await DiaryService.list()
    const next: DiaryEntry[] = []
    for (const row of rows) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    await JujiaLocalStore.saveDiaries(next)
  }

  static clone(row: DiaryEntry): DiaryEntry {
    const d = new DiaryEntry()
    d.id = row.id
    d.title = row.title
    d.body = row.body
    d.mood = row.mood
    d.userId = row.userId
    d.createdAt = row.createdAt
    d.updatedAt = row.updatedAt
    return d
  }

  static async countAll(): Promise<number> {
    return (await DiaryService.list()).length
  }
}
