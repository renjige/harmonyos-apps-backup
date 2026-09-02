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

  static displayLong(key: string): string {
    const d = DateHelper.parseKey(key)
    return `${DateHelper.displayDate(key)} ${DateHelper.weekdayLabel(d)}`
  }

  static monthTitle(year: number, month: number): string {
    return `${year}年${month + 1}月`
  }

  static timeLabel(ts: number): string {
    const d = new Date(ts)
    const h = d.getHours()
    const m = d.getMinutes()
    const hs = h < 10 ? `0${h}` : `${h}`
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${hs}:${ms}`
  }

  static daysInMonth(year: number, month: number): number {
    return new Date(year, month + 1, 0).getDate()
  }

  static addDays(key: string, delta: number): string {
    const d = DateHelper.parseKey(key)
    d.setDate(d.getDate() + delta)
    return DateHelper.keyFromDate(d)
  }

  static weekStartKey(): string {
    const d = new Date()
    const day = d.getDay()
    const diff = day === 0 ? 6 : day - 1
    d.setDate(d.getDate() - diff)
    return DateHelper.keyFromDate(d)
  }

  static lastWeekStartKey(): string {
    return DateHelper.addDays(DateHelper.weekStartKey(), -7)
  }

  static monthDay(key: string): string {
    if (key.length >= 10) {
      return key.substring(5, 10)
    }
    return ''
  }

  static usageDays(firstUseAt: number, now: number): number {
    if (firstUseAt <= 0) {
      return 1
    }
    const a = DateHelper.keyFromDate(new Date(firstUseAt))
    const b = DateHelper.keyFromDate(new Date(now))
    const da = DateHelper.parseKey(a)
    const db = DateHelper.parseKey(b)
    const diff = Math.floor((db.getTime() - da.getTime()) / 86400000)
    return diff < 0 ? 1 : diff + 1
  }

  static daysUntil(dateKey: string): number {
    const today = DateHelper.parseKey(DateHelper.todayKey())
    const target = DateHelper.parseKey(dateKey)
    today.setHours(0, 0, 0, 0)
    target.setHours(0, 0, 0, 0)
    return Math.round((target.getTime() - today.getTime()) / 86400000)
  }

  static monthDayLabel(key: string): string {
    const d = DateHelper.parseKey(key)
    return `${d.getMonth() + 1}月${d.getDate()}日`
  }
}
