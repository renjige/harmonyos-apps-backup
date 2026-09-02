import { TaskDates } from '../models/FamilyTaskModels'
import { MaintenanceJob } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'

export class MaintenanceService {
  static async list(): Promise<MaintenanceJob[]> {
    const rows = JujiaLocalStore.maintenanceJobs()
    rows.sort((a: MaintenanceJob, b: MaintenanceJob) => a.nextDueDate.localeCompare(b.nextDueDate))
    return rows
  }

  static nextDueFrom(lastDone: string, cycleDays: number): string {
    if (lastDone.length < 8) {
      const d = new Date()
      d.setDate(d.getDate() + cycleDays)
      return TaskDates.ymd(d)
    }
    const d = TaskDates.parse(lastDone)
    d.setDate(d.getDate() + cycleDays)
    return TaskDates.ymd(d)
  }

  static async create(draft: MaintenanceJob): Promise<MaintenanceJob> {
    const rows = await MaintenanceService.list()
    const row = new MaintenanceJob()
    row.id = JujiaLocalStore.newId('maint')
    row.title = draft.title.trim()
    row.room = draft.room
    row.cycleDays = draft.cycleDays
    row.lastDoneDate = draft.lastDoneDate
    row.nextDueDate = MaintenanceService.nextDueFrom(row.lastDoneDate, row.cycleDays)
    row.remark = draft.remark.trim()
    row.userId = 'local'
    row.createdAt = JujiaLocalStore.nowIso()
    row.updatedAt = row.createdAt
    rows.push(row)
    await JujiaLocalStore.saveMaintenance(rows)
    return row
  }

  static async update(row: MaintenanceJob): Promise<void> {
    const rows = await MaintenanceService.list()
    const next: MaintenanceJob[] = []
    for (const item of rows) {
      if (item.id === row.id) {
        row.updatedAt = JujiaLocalStore.nowIso()
        next.push(row)
      } else {
        next.push(item)
      }
    }
    await JujiaLocalStore.saveMaintenance(next)
  }

  static async markDone(id: string): Promise<void> {
    const rows = await MaintenanceService.list()
    const next: MaintenanceJob[] = []
    const today = TaskDates.today()
    for (const item of rows) {
      if (item.id !== id) {
        next.push(item)
        continue
      }
      const copy = MaintenanceService.clone(item)
      copy.lastDoneDate = today
      copy.nextDueDate = MaintenanceService.nextDueFrom(today, copy.cycleDays)
      copy.updatedAt = JujiaLocalStore.nowIso()
      next.push(copy)
    }
    await JujiaLocalStore.saveMaintenance(next)
  }

  static async remove(id: string): Promise<void> {
    const rows = await MaintenanceService.list()
    const next: MaintenanceJob[] = []
    for (const row of rows) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    await JujiaLocalStore.saveMaintenance(next)
  }

  static clone(row: MaintenanceJob): MaintenanceJob {
    const job = new MaintenanceJob()
    job.id = row.id
    job.title = row.title
    job.room = row.room
    job.cycleDays = row.cycleDays
    job.lastDoneDate = row.lastDoneDate
    job.nextDueDate = row.nextDueDate
    job.remark = row.remark
    job.reminderAgentId = row.reminderAgentId
    job.userId = row.userId
    job.createdAt = row.createdAt
    job.updatedAt = row.updatedAt
    return job
  }

  static async countAll(): Promise<number> {
    return (await MaintenanceService.list()).length
  }
}
