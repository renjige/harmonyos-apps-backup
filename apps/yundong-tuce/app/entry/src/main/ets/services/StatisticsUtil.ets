import { SportRecord, SportStats, SportTypeCount, SportTypeOption } from '../models/SportRecord'
import { RecordStore } from './RecordStore'

export class StatisticsUtil {
  static async computeStats(year?: number, month?: number): Promise<SportStats> {
    const stats = new SportStats()
    const list = await RecordStore.loadAll()
    stats.totalCount = list.length
    const typeMap = new Map<string, number>()
    const now = new Date()
    const y = year ?? now.getFullYear()
    const m = month ?? now.getMonth() + 1
    const prefix = `${y}-${m < 10 ? `0${m}` : `${m}`}`

    for (const it of list) {
      stats.totalMinutes += it.duration
      stats.totalPhotos += it.photos.length
      const prev = typeMap.get(it.sportType) ?? 0
      typeMap.set(it.sportType, prev + 1)
      if (it.date.indexOf(prefix) === 0) {
        stats.monthCount++
      }
    }

    let topCount = 0
    typeMap.forEach((count, sportType) => {
      const tc = new SportTypeCount()
      tc.sportType = sportType
      tc.label = SportTypeOption.labelOf(sportType)
      tc.count = count
      tc.percent = list.length > 0 ? Math.round((count / list.length) * 100) : 0
      stats.typeCounts.push(tc)
      if (count > topCount) {
        topCount = count
        stats.topSportType = sportType
        stats.topSportLabel = tc.label
      }
    })
    stats.typeCounts.sort((a, b) => b.count - a.count)
    return stats
  }

  static monthActivityMap(list: SportRecord[], year: number): MonthDayMap[] {
    const out: MonthDayMap[] = []
    for (let m = 1; m <= 12; m++) {
      const item = new MonthDayMap()
      item.month = m
      item.activeDays = StatisticsUtil.activeDaysInMonth(list, year, m)
      out.push(item)
    }
    return out
  }

  static activeDaysInMonth(list: SportRecord[], year: number, month: number): number {
    const prefix = `${year}-${month < 10 ? `0${month}` : `${month}`}`
    const days = new Set<string>()
    for (const it of list) {
      if (it.date.indexOf(prefix) === 0) {
        days.add(it.date)
      }
    }
    return days.size
  }

  static heatLevel(activeDays: number): number {
    if (activeDays <= 0) {
      return 0
    }
    if (activeDays <= 3) {
      return 1
    }
    if (activeDays <= 7) {
      return 2
    }
    if (activeDays <= 12) {
      return 3
    }
    return 4
  }

  static filterByType(list: SportRecord[], sportType: string): SportRecord[] {
    if (sportType.length === 0 || sportType === 'all') {
      return list
    }
    const out: SportRecord[] = []
    for (const it of list) {
      if (it.sportType === sportType) {
        out.push(it)
      }
    }
    return out
  }

  static favorites(list: SportRecord[]): SportRecord[] {
    const out: SportRecord[] = []
    for (const it of list) {
      if (it.favorited) {
        out.push(it)
      }
    }
    return out
  }

  static monthCells(list: SportRecord[], year: number, month: number): CalendarCell[] {
    const countMap = new Map<string, number>()
    const prefix = `${year}-${month < 10 ? `0${month}` : `${month}`}`
    for (const it of list) {
      if (it.date.indexOf(prefix) === 0) {
        countMap.set(it.date, (countMap.get(it.date) ?? 0) + 1)
      }
    }
    const first = new Date(year, month - 1, 1)
    const pad = first.getDay()
    const days = new Date(year, month, 0).getDate()
    const out: CalendarCell[] = []
    for (let i = 0; i < pad; i++) {
      const c = new CalendarCell()
      c.inMonth = false
      out.push(c)
    }
    for (let d = 1; d <= days; d++) {
      const c = new CalendarCell()
      c.inMonth = true
      c.day = d
      const ds = d < 10 ? `0${d}` : `${d}`
      c.dateKey = `${prefix}-${ds}`
      c.count = countMap.get(c.dateKey) ?? 0
      out.push(c)
    }
    return out
  }
}

export class MonthDayMap {
  month: number = 0
  activeDays: number = 0
}

export class CalendarCell {
  dateKey: string = ''
  day: number = 0
  count: number = 0
  inMonth: boolean = false
}
