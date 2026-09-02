import { SportRecord, SportStats, SportTypeCount, SportTypeOption } from '../models/SportRecord'
import { CalendarDay, MonthBar, RivalStat } from '../models/SportExtra'
import { RecordStore } from './RecordStore'

export class StatisticsUtil {
  static async computeStats(year?: number, month?: number): Promise<SportStats> {
    const stats = new SportStats()
    const list = await RecordStore.loadAll()
    stats.totalCount = list.length
    const typeMap = new Map<string, number>()
    const now = new Date()
    const y = year ?? now.getFullYear()
    const m = month
    const yearPrefix = `${y}-`
    const monthPrefix = m !== undefined ? `${y}-${m < 10 ? `0${m}` : `${m}`}` : ''

    for (const it of list) {
      stats.totalMinutes += it.duration
      const prev = typeMap.get(it.sportType) ?? 0
      typeMap.set(it.sportType, prev + 1)
      if (monthPrefix.length > 0) {
        if (it.date.indexOf(monthPrefix) === 0) {
          stats.monthCount++
        }
      } else if (it.date.indexOf(yearPrefix) === 0) {
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

  static monthRecords(list: SportRecord[], year: number, month: number): SportRecord[] {
    const prefix = `${year}-${month < 10 ? `0${month}` : `${month}`}`
    const out: SportRecord[] = []
    for (const it of list) {
      if (it.date.indexOf(prefix) === 0) {
        out.push(it)
      }
    }
    return out
  }

  static datesWithRecords(list: SportRecord[]): Set<string> {
    const set = new Set<string>()
    for (const it of list) {
      set.add(it.date)
    }
    return set
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

  static allPhotos(list: SportRecord[]): string[] {
    const out: string[] = []
    for (const it of list) {
      for (const p of it.photos) {
        if (p.length > 0) {
          out.push(p)
        }
      }
    }
    return out
  }

  static previousSameSport(list: SportRecord[], current: SportRecord): SportRecord | undefined {
    let best: SportRecord | undefined = undefined
    for (const it of list) {
      if (it.id === current.id || it.sportType !== current.sportType) {
        continue
      }
      const earlier = it.date < current.date || (it.date === current.date && it.time < current.time)
      if (!earlier) {
        continue
      }
      if (best === undefined) {
        best = it
      } else if (it.date > best.date || (it.date === best.date && it.time > best.time)) {
        best = it
      }
    }
    return best
  }

  static rivalStats(list: SportRecord[]): RivalStat[] {
    const map = new Map<string, RivalStat>()
    for (const it of list) {
      const name = it.opponent.trim()
      if (name.length === 0) {
        continue
      }
      let row = map.get(name)
      if (row === undefined) {
        row = new RivalStat()
        row.name = name
        map.set(name, row)
      }
      row.matches++
      if (it.result === 'win') {
        row.wins++
      }
      if (it.date > row.lastDate) {
        row.lastDate = it.date
      }
    }
    const out: RivalStat[] = []
    map.forEach((row) => {
      out.push(row)
    })
    out.sort((a, b) => b.matches - a.matches)
    if (out.length <= 5) {
      return out
    }
    return out.slice(0, 5)
  }

  static lastSixMonthBars(list: SportRecord[]): MonthBar[] {
    const out: MonthBar[] = []
    const now = new Date()
    for (let i = 5; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1)
      const y = d.getFullYear()
      const m = d.getMonth() + 1
      const prefix = `${y}-${m < 10 ? `0${m}` : `${m}`}`
      const bar = new MonthBar()
      bar.label = `${m}月`
      bar.value = 0
      for (const it of list) {
        if (it.date.indexOf(prefix) === 0) {
          bar.value++
        }
      }
      out.push(bar)
    }
    return out
  }

  static monthGrid(year: number, month: number, marked: string[]): CalendarDay[] {
    const out: CalendarDay[] = []
    const first = new Date(year, month - 1, 1)
    const pad = first.getDay()
    for (let i = 0; i < pad; i++) {
      const d = new CalendarDay()
      d.blank = true
      out.push(d)
    }
    const lastDate = new Date(year, month, 0).getDate()
    const today = SportRecord.formatDate(new Date())
    const ms = month < 10 ? `0${month}` : `${month}`
    for (let day = 1; day <= lastDate; day++) {
      const ds = day < 10 ? `0${day}` : `${day}`
      const key = `${year}-${ms}-${ds}`
      const d = new CalendarDay()
      d.dateKey = key
      d.dayNum = day
      d.isToday = key === today
      for (const mk of marked) {
        if (mk === key) {
          d.hasMark = true
          break
        }
      }
      out.push(d)
    }
    return out
  }

  static yearTotals(list: SportRecord[], year: number): SportStats {
    const stats = new SportStats()
    const prefix = `${year}-`
    for (const it of list) {
      if (it.date.indexOf(prefix) !== 0) {
        continue
      }
      stats.totalCount++
      stats.totalMinutes += it.duration
    }
    return stats
  }
}
