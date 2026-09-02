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

  static greeting(): string {
    const h = new Date().getHours()
    if (h < 11) {
      return '早安，愿你今日自在'
    }
    if (h < 14) {
      return '午安，记得稍作休息'
    }
    if (h < 18) {
      return '下午好，保持从容节奏'
    }
    return '晚安，感谢今天的自己'
  }

  static monthGrid(year: number, month: number): string[] {
    const first = new Date(year, month - 1, 1)
    const last = new Date(year, month, 0)
    const cells: string[] = []
    const pad = first.getDay()
    for (let i = 0; i < pad; i++) {
      cells.push('')
    }
    for (let d = 1; d <= last.getDate(); d++) {
      const dk = DateHelper.keyFromDate(new Date(year, month - 1, d))
      cells.push(dk)
    }
    return cells
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
}
