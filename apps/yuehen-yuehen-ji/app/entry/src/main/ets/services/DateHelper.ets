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

  static weekdayLabel(d: Date): string {
    const names: string[] = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
    return names[d.getDay()]
  }

  static displayDate(key: string): string {
    const d = DateHelper.parseKey(key)
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  }

  static displayWeekday(key: string): string {
    return DateHelper.weekdayLabel(DateHelper.parseKey(key))
  }

  static monthLabel(year: number, month: number): string {
    return `${year}年${month}月`
  }

  static daysInMonth(year: number, month: number): number {
    return new Date(year, month, 0).getDate()
  }

  static dateKey(year: number, month: number, day: number): string {
    const ms = month < 10 ? `0${month}` : `${month}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${year}-${ms}-${ds}`
  }
}
