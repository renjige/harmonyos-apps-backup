export class DateHelper {
  static todayKey(): string {
    return DateHelper.keyFromDate(new Date())
  }

  static keyFromDate(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static parseKey(key: string): Date {
    const parts = key.split('-')
    if (parts.length < 3) {
      return new Date()
    }
    return new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10))
  }

  static displayDate(key: string): string {
    const d = DateHelper.parseKey(key)
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  }

  static displayShort(key: string): string {
    const d = DateHelper.parseKey(key)
    return `${d.getMonth() + 1}月${d.getDate()}日`
  }

  static monthLabel(year: number, month: number): string {
    return `${year}年${month}月`
  }

  static buildMonthGrid(year: number, month: number): number[] {
    const first = new Date(year, month - 1, 1)
    const startWeekday = first.getDay()
    const daysInMonth = new Date(year, month, 0).getDate()
    const cells: number[] = []
    for (let i = 0; i < startWeekday; i++) {
      cells.push(0)
    }
    for (let d = 1; d <= daysInMonth; d++) {
      cells.push(d)
    }
    while (cells.length % 7 !== 0) {
      cells.push(0)
    }
    return cells
  }

  static keyFromParts(year: number, month: number, day: number): string {
    const ms = month < 10 ? `0${month}` : `${month}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${year}-${ms}-${ds}`
  }
}
