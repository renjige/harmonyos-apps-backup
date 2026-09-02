import { CheckInRecord } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'
import { TaskDates } from '../models/FamilyTaskModels'

export class CheckInService {
  static async recordTaskDone(): Promise<void> {
    const today = TaskDates.today()
    const rows = JujiaLocalStore.checkins().slice()
    let found = false
    for (const row of rows) {
      if (row.date === today) {
        row.taskDoneCount += 1
        found = true
        break
      }
    }
    if (!found) {
      const rec = new CheckInRecord()
      rec.date = today
      rec.taskDoneCount = 1
      rows.unshift(rec)
    }
    await JujiaLocalStore.saveCheckins(rows)
  }

  static streakDays(): number {
    const rows = JujiaLocalStore.checkins()
    if (rows.length === 0) {
      return 0
    }
    let streak = 0
    let cursor = TaskDates.today()
    for (let i = 0; i < 366; i++) {
      let hit = false
      for (const row of rows) {
        if (row.date === cursor && row.taskDoneCount > 0) {
          hit = true
          break
        }
      }
      if (!hit) {
        break
      }
      streak += 1
      cursor = TaskDates.addDays(cursor, -1)
    }
    return streak
  }

  static todayDoneCount(): number {
    const today = TaskDates.today()
    for (const row of JujiaLocalStore.checkins()) {
      if (row.date === today) {
        return row.taskDoneCount
      }
    }
    return 0
  }
}
