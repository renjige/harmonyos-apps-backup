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
    return `${d.getMonth() + 1}.${d.getDate()}`
  }

  static displayDateTime(ts: number): string {
    const d = new Date(ts)
    const h = d.getHours()
    const m = d.getMinutes()
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${d.getMonth() + 1}月${d.getDate()}日 ${h}:${ms}`
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

  static monthRangeLabel(): string {
    const end = new Date()
    const start = new Date()
    start.setDate(end.getDate() - 29)
    return `${DateHelper.displayShort(DateHelper.keyFromDate(start))} — ${DateHelper.displayShort(DateHelper.keyFromDate(end))}`
  }
}
