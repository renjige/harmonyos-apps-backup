import { CalCell, CalWeek, JournalEntry, MonthInsight } from '../models/ShiyiModels'
import { MoodCatalog } from './MoodCatalog'
import { ShiyiStore } from './ShiyiStore'

export class CalendarUtil {
  static weeksOf(year: number, month: number, marked: string[]): CalWeek[] {
    const first = new Date(year, month - 1, 1)
    const startWeekday = first.getDay()
    const daysInMonth = new Date(year, month, 0).getDate()
    const today = ShiyiStore.today()
    const cells: CalCell[] = []
    for (let i = 0; i < startWeekday; i++) {
      cells.push(new CalCell())
    }
    for (let day = 1; day <= daysInMonth; day++) {
      const cell = new CalCell()
      cell.day = day
      cell.inMonth = true
      cell.date = CalendarUtil.iso(year, month, day)
      cell.isToday = cell.date === today
      cell.hasEntry = CalendarUtil.hasDate(marked, cell.date)
      cells.push(cell)
    }
    while (cells.length % 7 !== 0) {
      cells.push(new CalCell())
    }
    const weeks: CalWeek[] = []
    let week = new CalWeek()
    let count = 0
    let weekIndex = 0
    for (const cell of cells) {
      if (count === 0) {
        week = new CalWeek()
        week.id = `w_${year}_${month}_${weekIndex}`
      }
      week.cells.push(cell)
      count += 1
      if (count === 7) {
        weeks.push(week)
        count = 0
        weekIndex += 1
      }
    }
    return weeks
  }

  static insight(year: number, month: number, journals: JournalEntry[]): MonthInsight {
    const info = new MonthInsight()
    info.year = year
    info.month = month
    const prefix = CalendarUtil.monthPrefix(year, month)
    const moodCount: string[] = []
    const tagCount: string[] = []
    let n = 0
    for (const item of journals) {
      if (item.entryDate.indexOf(prefix) === 0) {
        n += 1
        if (item.mood.length > 0) {
          moodCount.push(item.mood)
        }
        for (const tag of item.tags) {
          tagCount.push(tag)
        }
      }
    }
    info.journalCount = n
    info.topMoodLabel = MoodCatalog.labelOf(CalendarUtil.mostCommon(moodCount))
    if (info.topMoodLabel === '未选') {
      info.topMoodLabel = ''
    }
    info.topTag = CalendarUtil.mostCommon(tagCount)
    return info
  }

  static monthTitle(year: number, month: number): string {
    return `${year}年${month}月`
  }

  static weekdayLabels(): string[] {
    return ['日', '一', '二', '三', '四', '五', '六']
  }

  private static iso(year: number, month: number, day: number): string {
    const ms: string = month < 10 ? `0${month}` : `${month}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    return `${year}-${ms}-${ds}`
  }

  private static monthPrefix(year: number, month: number): string {
    const ms: string = month < 10 ? `0${month}` : `${month}`
    return `${year}-${ms}`
  }

  private static hasDate(marked: string[], date: string): boolean {
    for (const item of marked) {
      if (item === date) {
        return true
      }
    }
    return false
  }

  private static mostCommon(values: string[]): string {
    if (values.length === 0) {
      return ''
    }
    let best = ''
    let bestCount = 0
    for (const value of values) {
      let count = 0
      for (const other of values) {
        if (other === value) {
          count += 1
        }
      }
      if (count > bestCount) {
        best = value
        bestCount = count
      }
    }
    return best
  }
}
