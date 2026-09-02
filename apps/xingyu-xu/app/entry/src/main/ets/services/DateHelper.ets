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
    if (key.length < 8) {
      return '未设定'
    }
    const d = DateHelper.parseKey(key)
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  }

  static displayMonthYear(key: string): string {
    if (key.length < 7) {
      return key
    }
    return `${key.substring(0, 4)}年${parseInt(key.substring(5, 7), 10)}月`
  }

  static monthKeyFromDateKey(key: string): string {
    if (key.length >= 7) {
      return key.substring(0, 7)
    }
    return key
  }

  static yearFromKey(key: string): string {
    if (key.length >= 4) {
      return key.substring(0, 4)
    }
    return ''
  }

  static daysAgoKey(n: number): string {
    const d = new Date()
    d.setDate(d.getDate() - n)
    return DateHelper.keyFromDate(d)
  }

  static yearsAgoSameDay(n: number): string {
    const d = new Date()
    d.setFullYear(d.getFullYear() - n)
    return DateHelper.keyFromDate(d)
  }

  static currentYear(): string {
    return `${new Date().getFullYear()}`
  }
}
