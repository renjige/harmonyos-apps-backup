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

  static displayDate(key: string): string {
    const parts = key.split('-')
    if (parts.length < 3) {
      return key
    }
    return `${parts[0]}年${parseInt(parts[1], 10)}月${parseInt(parts[2], 10)}日`
  }

  static displayWeekday(key: string): string {
    const parts = key.split('-')
    if (parts.length < 3) {
      return ''
    }
    const d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10))
    const names = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    return names[d.getDay()]
  }

  static monthLabel(year: number, month: number): string {
    return `${year}年${month}月`
  }

  static daysInMonth(year: number, month: number): number {
    return new Date(year, month, 0).getDate()
  }

  static shiftKey(key: string, deltaDays: number): string {
    const parts = key.split('-')
    if (parts.length < 3) {
      return key
    }
    const d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10))
    d.setDate(d.getDate() + deltaDays)
    return DateHelper.keyFromDate(d)
  }
}
