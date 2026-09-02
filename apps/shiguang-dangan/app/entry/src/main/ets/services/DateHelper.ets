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

  static displayShort(key: string): string {
    if (key.length === 0) {
      return '—'
    }
    const d = DateHelper.parseKey(key)
    return `${d.getMonth() + 1}.${d.getDate()}`
  }

  static displayMonthYear(d: Date): string {
    return `${d.getFullYear()}年${d.getMonth() + 1}月`
  }

  static monthKey(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${y}-${ms}`
  }

  static lastNMonths(n: number): string[] {
    const out: string[] = []
    const cursor = new Date()
    for (let i = 0; i < n; i++) {
      out.push(DateHelper.monthKey(cursor))
      cursor.setMonth(cursor.getMonth() - 1)
    }
    return out
  }

  static compareKeys(a: string, b: string): number {
    if (a === b) {
      return 0
    }
    return a > b ? -1 : 1
  }

  static daysAgoKey(n: number): string {
    const d = new Date()
    d.setDate(d.getDate() - n)
    return DateHelper.keyFromDate(d)
  }

  static sameMonthDay(key: string, day: number, month: number): boolean {
    if (key.length < 10) {
      return false
    }
    const parts = key.split('-')
    if (parts.length < 3) {
      return false
    }
    const m = parseInt(parts[1], 10)
    const d = parseInt(parts[2], 10)
    return m === month && d === day
  }

  static formatWeekday(d: Date): string {
    const names: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    return names[d.getDay()]
  }

  /** 图表 X 轴短标签：一 … 日 */
  static weekdayShort(d: Date): string {
    const names: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return names[d.getDay()]
  }

  static dayFromKey(key: string): number {
    const parts = key.split('-')
    if (parts.length < 3) {
      return 0
    }
    return parseInt(parts[2], 10)
  }

  static displayDateFromTs(ts: number): string {
    if (ts <= 0) {
      return '—'
    }
    return DateHelper.displayDate(DateHelper.keyFromDate(new Date(ts)))
  }

  static monthFromKey(key: string): number {
    const parts = key.split('-')
    if (parts.length < 2) {
      return 0
    }
    return parseInt(parts[1], 10)
  }
}
