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
    if (d.getDay() === 0) { return '星期日' }
    if (d.getDay() === 1) { return '星期一' }
    if (d.getDay() === 2) { return '星期二' }
    if (d.getDay() === 3) { return '星期三' }
    if (d.getDay() === 4) { return '星期四' }
    if (d.getDay() === 5) { return '星期五' }
    return '星期六'
  }

  static displayDate(key: string): string {
    const d = DateHelper.parseKey(key)
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日 · ${DateHelper.weekdayLabel(d)}`
  }

  static monthKey(dateKey: string): string {
    if (dateKey.length < 7) {
      return dateKey
    }
    return dateKey.substring(0, 7)
  }

  static monthLabel(monthKey: string): string {
    const parts = monthKey.split('-')
    if (parts.length < 2) {
      return monthKey
    }
    return `${parts[0]}年${parseInt(parts[1], 10)}月`
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

  static clockLabel(ts: number): string {
    const d = new Date(ts)
    const h = d.getHours()
    const m = d.getMinutes()
    const hs = h < 10 ? `0${h}` : `${h}`
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${hs}:${ms}`
  }

  static weekKey(dateKey?: string): string {
    const d = dateKey !== undefined && dateKey.length >= 10 ?
      DateHelper.parseKey(dateKey) : new Date()
    const y = d.getFullYear()
    const start = new Date(y, 0, 1)
    const diff = d.getTime() - start.getTime()
    const w = Math.floor(diff / 604800000) + 1
    const ws = w < 10 ? `0${w}` : `${w}`
    return `${y}-W${ws}`
  }
}
