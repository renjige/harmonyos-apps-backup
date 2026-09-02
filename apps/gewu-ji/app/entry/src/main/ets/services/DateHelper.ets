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

  static displayShort(key: string): string {
    const d = DateHelper.parseKey(key)
    return `${d.getMonth() + 1}.${d.getDate()}`
  }

  static displayWeekday(key: string): string {
    return DateHelper.weekdayLabel(DateHelper.parseKey(key))
  }

  static lastNDays(n: number): string[] {
    const out: string[] = []
    const cursor = new Date()
    for (let i = 0; i < n; i++) {
      out.push(DateHelper.keyFromDate(cursor))
      cursor.setDate(cursor.getDate() - 1)
    }
    return out
  }

  static weekRangeLabel(): string {
    const end = new Date()
    const start = new Date()
    start.setDate(end.getDate() - 6)
    return `${DateHelper.displayShort(DateHelper.keyFromDate(start))} — ${DateHelper.displayShort(DateHelper.keyFromDate(end))}`
  }

  static addDays(key: string, delta: number): string {
    const d = DateHelper.parseKey(key)
    d.setDate(d.getDate() + delta)
    return DateHelper.keyFromDate(d)
  }

  static monthRangeLabel(): string {
    const end = new Date()
    const start = new Date()
    start.setDate(end.getDate() - 29)
    return `${DateHelper.displayShort(DateHelper.keyFromDate(start))} — ${DateHelper.displayShort(DateHelper.keyFromDate(end))}`
  }

  static inRange(key: string, start: string, end: string): boolean {
    if (key.length === 0 || start.length === 0 || end.length === 0) {
      return false
    }
    return key >= start && key <= end
  }

  static keysLastN(n: number): string[] {
    const out: string[] = []
    let i = n - 1
    while (i >= 0) {
      out.push(DateHelper.addDays(DateHelper.todayKey(), 0 - i))
      i--
    }
    return out
  }
}
