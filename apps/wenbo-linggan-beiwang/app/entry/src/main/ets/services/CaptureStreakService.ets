import { InspirationItem } from '../models/InspirationModels'

export class CaptureStreakService {
  static isoOf(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static itemDay(item: InspirationItem): string {
    if (item.recordDate.length >= 10) {
      return item.recordDate.substring(0, 10)
    }
    if (item.createdAt.length >= 10) {
      return item.createdAt.substring(0, 10)
    }
    return ''
  }

  static consecutiveDays(items: InspirationItem[]): number {
    const dates: string[] = []
    for (const it of items) {
      const day = CaptureStreakService.itemDay(it)
      if (day.length === 0) {
        continue
      }
      let seen = false
      for (const x of dates) {
        if (x === day) {
          seen = true
          break
        }
      }
      if (!seen) {
        dates.push(day)
      }
    }
    if (dates.length === 0) {
      return 0
    }
    const cursor = new Date()
    let streak = 0
    let skippedToday = false
    while (streak < 366) {
      const iso = CaptureStreakService.isoOf(cursor)
      let found = false
      for (const x of dates) {
        if (x === iso) {
          found = true
          break
        }
      }
      if (!found) {
        if (streak === 0 && !skippedToday) {
          skippedToday = true
          cursor.setDate(cursor.getDate() - 1)
          continue
        }
        break
      }
      streak += 1
      cursor.setDate(cursor.getDate() - 1)
    }
    return streak
  }
}
