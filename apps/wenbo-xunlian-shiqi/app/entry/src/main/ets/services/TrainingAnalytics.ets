import { CalendarCell, HeatmapCell, MonthReport, TrainingSummary, TypeCount } from '../models/TrainingModels'
import { DateHelper } from './DateHelper'
import { TrainingStore } from './TrainingStore'

export class TrainingAnalytics {
  static summarize(): TrainingSummary {
    const s = new TrainingSummary()
    const today = DateHelper.todayKey()
    const all = TrainingStore.list()
    const dateSet: string[] = []
    for (const item of all) {
      s.totalCount += 1
      s.totalDurationMin += item.durationMin
      if (item.recordDate === today) {
        s.todayCount += 1
        s.todayDurationMin += item.durationMin
      }
      let hit = false
      for (const d of dateSet) {
        if (d === item.recordDate) {
          hit = true
          break
        }
      }
      if (!hit) {
        dateSet.push(item.recordDate)
      }
    }
    s.totalDays = dateSet.length
    s.streakDays = TrainingAnalytics.calcStreak(dateSet)
    s.weekTrend = TrainingAnalytics.weekTrend()
    return s
  }

  static calcStreak(sortedDatesDesc: string[]): number {
    const dates = sortedDatesDesc.slice()
    dates.sort((a: string, b: string) => b.localeCompare(a))
    if (dates.length === 0) {
      return 0
    }
    let streak = 0
    let cursor = DateHelper.todayKey()
    for (let i = 0; i < dates.length; i++) {
      let found = false
      for (const d of dates) {
        if (d === cursor) {
          found = true
          break
        }
      }
      if (!found) {
        if (streak === 0 && i === 0) {
          const y = TrainingAnalytics.shiftDateKey(cursor, -1)
          let yFound = false
          for (const d of dates) {
            if (d === y) {
              yFound = true
              break
            }
          }
          if (!yFound) {
            break
          }
          cursor = y
          continue
        }
        break
      }
      streak += 1
      cursor = TrainingAnalytics.shiftDateKey(cursor, -1)
    }
    return streak
  }

  static weekTrend(): number[] {
    const out: number[] = []
    const today = new Date()
    for (let i = 6; i >= 0; i--) {
      const d = new Date(today.getTime() - i * 86400000)
      const key = DateHelper.formatKey(d)
      let mins = 0
      for (const item of TrainingStore.byDate(key)) {
        mins += item.durationMin
      }
      out.push(mins)
    }
    return out
  }

  static monthHeatmap(year: number, month: number): HeatmapCell[] {
    const cells: HeatmapCell[] = []
    const daysInMonth = new Date(year, month, 0).getDate()
    for (let day = 1; day <= daysInMonth; day++) {
      const key = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
      const list = TrainingStore.byDate(key)
      const cell = new HeatmapCell()
      cell.dateKey = key
      for (const item of list) {
        cell.durationMin += item.durationMin
      }
      if (cell.durationMin === 0) {
        cell.level = 0
      } else if (cell.durationMin < 30) {
        cell.level = 1
      } else if (cell.durationMin < 60) {
        cell.level = 2
      } else if (cell.durationMin < 90) {
        cell.level = 3
      } else {
        cell.level = 4
      }
      cells.push(cell)
    }
    return cells
  }

  static buildCalendarCells(year: number, month: number): CalendarCell[] {
    const cells: CalendarCell[] = []
    const first = new Date(year, month - 1, 1)
    const startWeekday = first.getDay()
    const daysInMonth = new Date(year, month, 0).getDate()
    const heat = TrainingAnalytics.monthHeatmap(year, month)
    const levelMap: Record<string, number> = {}
    for (const h of heat) {
      levelMap[h.dateKey] = h.level
    }
    for (let i = 0; i < startWeekday; i++) {
      const c = new CalendarCell()
      c.inMonth = false
      cells.push(c)
    }
    for (let day = 1; day <= daysInMonth; day++) {
      const key = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`
      const c = new CalendarCell()
      c.day = day
      c.dateKey = key
      c.inMonth = true
      const lvl = levelMap[key] ?? 0
      c.dotLevel = lvl
      c.hasRecord = lvl > 0
      cells.push(c)
    }
    return cells
  }

  static countMonthSessions(year: number, month: number): number {
    let n = 0
    const prefix = `${year}-${String(month).padStart(2, '0')}-`
    for (const item of TrainingStore.list()) {
      if (item.recordDate.startsWith(prefix)) {
        n += 1
      }
    }
    return n
  }

  static distinctTypes(): number {
    const types: string[] = []
    for (const item of TrainingStore.list()) {
      let hit = false
      for (const t of types) {
        if (t === item.trainingType) {
          hit = true
          break
        }
      }
      if (!hit) {
        types.push(item.trainingType)
      }
    }
    return types.length
  }

  static totalHours(): number {
    let mins = 0
    for (const item of TrainingStore.list()) {
      mins += item.durationMin
    }
    return Math.round(mins / 6) / 10
  }

  static monthReport(year: number, month: number): MonthReport {
    const r = new MonthReport()
    const prefix = `${year}-${String(month).padStart(2, '0')}-`
    const typeMap: TypeCount[] = []
    let complete = 0
    for (const item of TrainingStore.list()) {
      if (!item.recordDate.startsWith(prefix)) {
        continue
      }
      r.sessions += 1
      r.minutes += item.durationMin
      if (item.completeStatus === '已完成') {
        complete += 1
      }
      let hit: TypeCount | null = null
      for (const row of typeMap) {
        if (row.name === item.trainingType) {
          hit = row
          break
        }
      }
      if (hit === null) {
        const row = new TypeCount()
        row.name = item.trainingType
        row.count = 1
        typeMap.push(row)
      } else {
        hit.count += 1
      }
    }
    r.completeRate = r.sessions === 0 ? 0 : Math.floor(complete * 100 / r.sessions)
    typeMap.sort((a: TypeCount, b: TypeCount) => b.count - a.count)
    if (typeMap.length > 0) {
      r.topType = typeMap[0].name
    }
    return r
  }

  static longestStreak(): number {
    return TrainingAnalytics.calcLongest(TrainingStore.datesWithRecords())
  }

  static calcLongest(dateKeys: string[]): number {
    const dates = dateKeys.slice()
    dates.sort((a: string, b: string) => a.localeCompare(b))
    if (dates.length === 0) {
      return 0
    }
    let best = 1
    let cur = 1
    for (let i = 1; i < dates.length; i++) {
      const prev = dates[i - 1]
      const expect = TrainingAnalytics.shiftDateKey(prev, 1)
      if (dates[i] === expect) {
        cur += 1
        if (cur > best) {
          best = cur
        }
      } else {
        cur = 1
      }
    }
    return best
  }

  static typeCounts(): TypeCount[] {
    const out: TypeCount[] = []
    for (const item of TrainingStore.list()) {
      let hit: TypeCount | null = null
      for (const row of out) {
        if (row.name === item.trainingType) {
          hit = row
          break
        }
      }
      if (hit === null) {
        const row = new TypeCount()
        row.name = item.trainingType
        row.count = 1
        out.push(row)
      } else {
        hit.count += 1
      }
    }
    out.sort((a: TypeCount, b: TypeCount) => b.count - a.count)
    return out
  }

  static shiftDateKey(key: string, deltaDays: number): string {
    const parts = key.split('-')
    if (parts.length !== 3) {
      return key
    }
    const d = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]))
    d.setDate(d.getDate() + deltaDays)
    return DateHelper.formatKey(d)
  }
}
