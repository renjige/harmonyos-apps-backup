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

  static yearFromKey(key: string): string {
    if (key.length >= 4) {
      return key.substring(0, 4)
    }
    return ''
  }

  static displayDate(key: string): string {
    if (key.length === 0) {
      return '未设定'
    }
    const d = DateHelper.parseKey(key)
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  }

  static displayDateFromTs(ts: number): string {
    if (ts <= 0) {
      return '—'
    }
    return DateHelper.displayDate(DateHelper.keyFromDate(new Date(ts)))
  }

  static monthKeyFromTs(ts: number): string {
    const d = new Date(ts)
    const m = d.getMonth() + 1
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${d.getFullYear()}-${ms}`
  }

  static lastNMonths(n: number): string[] {
    const out: string[] = []
    const cursor = new Date()
    for (let i = 0; i < n; i++) {
      const m = cursor.getMonth() + 1
      const ms = m < 10 ? `0${m}` : `${m}`
      out.push(`${cursor.getFullYear()}-${ms}`)
      cursor.setMonth(cursor.getMonth() - 1)
    }
    return out
  }

  static daysAgoKey(n: number): string {
    const d = new Date()
    d.setDate(d.getDate() - n)
    return DateHelper.keyFromDate(d)
  }

  static monthLabel(monthKey: string): string {
    const parts = monthKey.split('-')
    if (parts.length < 2) {
      return monthKey
    }
    return `${parseInt(parts[1], 10)}月`
  }
}
