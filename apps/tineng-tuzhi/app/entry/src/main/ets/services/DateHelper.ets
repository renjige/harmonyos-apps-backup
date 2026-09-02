export class DateHelper {
  static todayKey(): string {
    return DateHelper.keyFromDate(new Date())
  }

  static safeInt(text: string, fallback: number): number {
    const n = parseInt(text, 10)
    if (isNaN(n)) {
      return fallback
    }
    return n
  }

  static keyFromDate(d: Date): string {
    let y = d.getFullYear()
    let m = d.getMonth() + 1
    let day = d.getDate()
    if (isNaN(y) || isNaN(m) || isNaN(day) || y < 2000) {
      y = 2026
      m = 1
      day = 1
    }
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static parseKey(key: string): Date {
    const today = new Date()
    if (key === undefined || key === null) {
      return today
    }
    const raw = `${key}`
    if (raw.length < 8) {
      return today
    }
    let ymd = raw
    if (raw.startsWith('w-') && raw.length >= 12) {
      ymd = raw.substring(2)
    }
    const parts = ymd.split('-')
    if (parts.length < 3) {
      return today
    }
    const y = DateHelper.safeInt(parts[0], 0)
    const m = DateHelper.safeInt(parts[1], 0)
    const day = DateHelper.safeInt(parts[2], 0)
    if (y < 2000 || y > 2100 || m < 1 || m > 12 || day < 1 || day > 31) {
      return today
    }
    const parsed = new Date(y, m - 1, day)
    if (isNaN(parsed.getTime())) {
      return today
    }
    return parsed
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
    const idx = d.getDay()
    if (idx < 0 || idx > 6 || isNaN(idx)) {
      return '周—'
    }
    return `周${names[idx]}`
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
    if (year < 2000 || month < 1 || month > 12) {
      return out
    }
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

  static mondayFromWeekKey(weekKey: string): string {
    const raw = `${weekKey}`
    if (raw.length > 2 && raw.startsWith('w-')) {
      return raw.substring(2)
    }
    return DateHelper.mondayKey(DateHelper.todayKey())
  }

  static weekDateKeys(fromKey: string): string[] {
    const monday = DateHelper.parseKey(DateHelper.mondayKey(fromKey))
    const out: string[] = []
    for (let i = 0; i < 7; i++) {
      const d = new Date(monday.getTime())
      d.setDate(monday.getDate() + i)
      out.push(DateHelper.keyFromDate(d))
    }
    return out
  }

  static weekdayIndexMon0(key: string): number {
    const day = DateHelper.parseKey(key).getDay()
    if (isNaN(day) || day < 0 || day > 6) {
      return 0
    }
    return day === 0 ? 6 : day - 1
  }

  static lastWeekMondayKey(fromKey: string): string {
    const d = DateHelper.parseKey(DateHelper.mondayKey(fromKey))
    d.setDate(d.getDate() - 7)
    return DateHelper.keyFromDate(d)
  }

  static weekRangeLabel(weekKey: string): string {
    const mondayKey = DateHelper.mondayFromWeekKey(weekKey)
    const keys = DateHelper.weekDateKeys(mondayKey)
    if (keys.length < 7) {
      return ''
    }
    return `${DateHelper.displayShort(keys[0])} – ${DateHelper.displayShort(keys[6])}`
  }
}
