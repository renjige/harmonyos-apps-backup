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

  static displayDateTime(ts: number): string {
    const d = new Date(ts)
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const h = d.getHours()
    const min = d.getMinutes()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    const hs = h < 10 ? `0${h}` : `${h}`
    const mins = min < 10 ? `0${min}` : `${min}`
    return `${y}年${m}月${day}日 ${hs}:${mins}`
  }

  static displayDate(key: string): string {
    const d = DateHelper.parseKey(key)
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  }

  static normalizeKey(raw: string): string {
    const t = raw.trim().replace(/\//g, '-').replace(/\./g, '-')
    if (t.length === 0) {
      return ''
    }
    const parts = t.split('-')
    if (parts.length !== 3) {
      return ''
    }
    const y = parseInt(parts[0], 10)
    const m = parseInt(parts[1], 10)
    const d = parseInt(parts[2], 10)
    if (Number.isNaN(y) || Number.isNaN(m) || Number.isNaN(d) || m < 1 || m > 12 || d < 1 || d > 31) {
      return ''
    }
    return DateHelper.keyFromDate(new Date(y, m - 1, d))
  }

  static addDaysKey(key: string, days: number): string {
    const d = DateHelper.parseKey(key)
    d.setDate(d.getDate() + days)
    return DateHelper.keyFromDate(d)
  }

  static monthTitle(year: number, month: number): string {
    return `${year}年${month}月`
  }
}
