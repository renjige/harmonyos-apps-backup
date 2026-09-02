export class DateHelper {
  static pad(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  static todayKey(): string {
    const d = new Date()
    return `${d.getFullYear()}-${DateHelper.pad(d.getMonth() + 1)}-${DateHelper.pad(d.getDate())}`
  }

  static keyFromTs(ts: number): string {
    const d = new Date(ts)
    return `${d.getFullYear()}-${DateHelper.pad(d.getMonth() + 1)}-${DateHelper.pad(d.getDate())}`
  }

  static displayDate(dateKey: string): string {
    const parts = dateKey.split('-')
    if (parts.length !== 3) {
      return dateKey
    }
    return `${parts[0]}年${parts[1]}月${parts[2]}日`
  }

  static monthLabel(d: Date): string {
    return `${d.getFullYear()}年${d.getMonth() + 1}月`
  }

  static buildMonthCells(cursor: Date, dotKeys: string[]): CalendarDayCell[] {
    const year = cursor.getFullYear()
    const month = cursor.getMonth()
    const first = new Date(year, month, 1)
    const startWeekday = first.getDay()
    const daysInMonth = new Date(year, month + 1, 0).getDate()
    const cells: CalendarDayCell[] = []
    const today = DateHelper.todayKey()

    for (let i = 0; i < startWeekday; i++) {
      cells.push(CalendarDayCell.make(0, '', false, false, false))
    }
    for (let day = 1; day <= daysInMonth; day++) {
      const key = `${year}-${DateHelper.pad(month + 1)}-${DateHelper.pad(day)}`
      let hasDot = false
      for (const dk of dotKeys) {
        if (dk === key) {
          hasDot = true
          break
        }
      }
      cells.push(CalendarDayCell.make(day, key, hasDot, key === today, true))
    }
    return cells
  }
}

export class CalendarDayCell {
  day: number = 0
  dateKey: string = ''
  hasDot: boolean = false
  isToday: boolean = false
  isCurrentMonth: boolean = true

  static make(day: number, dateKey: string, hasDot: boolean, isToday: boolean, isCurrentMonth: boolean): CalendarDayCell {
    const c = new CalendarDayCell()
    c.day = day
    c.dateKey = dateKey
    c.hasDot = hasDot
    c.isToday = isToday
    c.isCurrentMonth = isCurrentMonth
    return c
  }
}
