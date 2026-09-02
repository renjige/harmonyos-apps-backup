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

  static weekdayLabel(d: Date): string {
    const names: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return `周${names[d.getDay()]}`
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

  static monthKeys(year: number, month: number): string[] {
    const out: string[] = []
    const d = new Date(year, month - 1, 1)
    while (d.getMonth() === month - 1) {
      out.push(DateHelper.keyFromDate(d))
      d.setDate(d.getDate() + 1)
    }
    return out
  }

  static currentMonthLabel(): string {
    const d = new Date()
    return `${d.getFullYear()}年${d.getMonth() + 1}月`
  }

  static greeting(): string {
    const h = new Date().getHours()
    if (h < 12) {
      return '早安'
    }
    if (h < 18) {
      return '下午好'
    }
    return '晚上好'
  }

  static mondayKey(fromKey: string): string {
    const d = DateHelper.parseKey(fromKey)
    const day = d.getDay()
    const diff = day === 0 ? 6 : day - 1
    d.setDate(d.getDate() - diff)
    return DateHelper.keyFromDate(d)
  }

  static weekKey(fromKey: string): string {
    return `w-${DateHelper.mondayKey(fromKey)}`
  }
}
