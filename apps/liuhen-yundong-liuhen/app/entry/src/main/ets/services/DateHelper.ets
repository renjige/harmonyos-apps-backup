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

  static normalizeKey(key: string): string {
    const trimmed = key.trim()
    return DateHelper.keyFromDate(DateHelper.parseKey(trimmed))
  }

  static monthDayToken(key: string): string {
    const d = DateHelper.parseKey(DateHelper.normalizeKey(key))
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${ms}-${ds}`
  }

  static isSameMonthDay(dateKey: string, weekKeys: string[]): boolean {
    if (dateKey.length < 8) {
      return false
    }
    const token = DateHelper.monthDayToken(dateKey)
    for (const wk of weekKeys) {
      if (DateHelper.monthDayToken(wk) === token) {
        return true
      }
    }
    return false
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

  static mondayKey(fromKey: string): string {
    const d = DateHelper.parseKey(fromKey)
    const day = d.getDay()
    const diff = day === 0 ? 6 : day - 1
    d.setDate(d.getDate() - diff)
    return DateHelper.keyFromDate(d)
  }

  static weekKeysFromMonday(mondayKey: string): string[] {
    const out: string[] = []
    const d = DateHelper.parseKey(mondayKey)
    for (let i = 0; i < 7; i++) {
      out.push(DateHelper.keyFromDate(d))
      d.setDate(d.getDate() + 1)
    }
    return out
  }

  static formatDuration(seconds: number): string {
    const m = Math.floor(seconds / 60)
    const s = seconds % 60
    const ms = m < 10 ? `0${m}` : `${m}`
    const ss = s < 10 ? `0${s}` : `${s}`
    return `${ms}:${ss}`
  }

  static isDateInWeek(dateKey: string, mondayKey?: string): boolean {
    const monday = mondayKey !== undefined && mondayKey.length > 0 ?
      mondayKey : DateHelper.mondayKey(DateHelper.todayKey())
    const bounds = DateHelper.weekTimeBounds(monday)
    const nk = DateHelper.normalizeKey(dateKey)
    const weekKeys = DateHelper.weekKeysFromMonday(monday)
    for (const wk of weekKeys) {
      if (wk === nk) {
        return true
      }
    }
    const t = DateHelper.parseKey(nk).getTime()
    return t >= bounds.startMs && t <= bounds.endMs
  }

  static weekTimeBounds(mondayKey?: string): WeekTimeBounds {
    const monday = mondayKey !== undefined && mondayKey.length > 0 ?
      mondayKey : DateHelper.mondayKey(DateHelper.todayKey())
    const keys = DateHelper.weekKeysFromMonday(monday)
    const startDate = DateHelper.parseKey(keys[0])
    startDate.setHours(0, 0, 0, 0)
    const endDate = DateHelper.parseKey(keys[keys.length - 1])
    endDate.setHours(23, 59, 59, 999)
    const b = new WeekTimeBounds()
    b.startMs = startDate.getTime()
    b.endMs = endDate.getTime()
    b.mondayKey = monday
    return b
  }

  static isRecordInWeek(dateKey: string, timestamp: number, mondayKey?: string): boolean {
    const monday = mondayKey !== undefined && mondayKey.length > 0 ?
      mondayKey : DateHelper.mondayKey(DateHelper.todayKey())
    const weekKeys = DateHelper.weekKeysFromMonday(monday)
    const bounds = DateHelper.weekTimeBounds(monday)
    if (dateKey.length >= 8) {
      const nk = DateHelper.normalizeKey(dateKey)
      for (const wk of weekKeys) {
        if (wk === nk) {
          return true
        }
      }
      const t = DateHelper.parseKey(nk).getTime()
      if (t >= bounds.startMs && t <= bounds.endMs) {
        return true
      }
      if (DateHelper.isSameMonthDay(dateKey, weekKeys)) {
        return true
      }
    }
    if (timestamp > 0 && timestamp >= bounds.startMs && timestamp <= bounds.endMs) {
      return true
    }
    return false
  }

  static isRecordInMonth(dateKey: string, timestamp: number, ref: Date): boolean {
    const keys = DateHelper.monthKeys(ref.getFullYear(), ref.getMonth() + 1)
    const startDate = DateHelper.parseKey(keys[0])
    startDate.setHours(0, 0, 0, 0)
    const endDate = DateHelper.parseKey(keys[keys.length - 1])
    endDate.setHours(23, 59, 59, 999)
    const startMs = startDate.getTime()
    const endMs = endDate.getTime()
    if (dateKey.length >= 8) {
      const t = DateHelper.parseKey(DateHelper.normalizeKey(dateKey)).getTime()
      if (t >= startMs && t <= endMs) {
        return true
      }
    }
    if (timestamp > 0) {
      return timestamp >= startMs && timestamp <= endMs
    }
    return false
  }

  static clampRecordDates(dateKey: string, timestamp: number): DateClampResult {
    const result = new DateClampResult()
    const now = new Date()
    let dk = DateHelper.normalizeKey(dateKey)
    const parsed = DateHelper.parseKey(dk)
    if (parsed.getFullYear() > now.getFullYear()) {
      dk = DateHelper.keyFromDate(new Date(now.getFullYear(), parsed.getMonth(), parsed.getDate()))
      result.dateKey = dk
      result.fixed = true
    } else {
      result.dateKey = dk
    }
    if (timestamp > 0) {
      const ts = new Date(timestamp)
      if (ts.getFullYear() > now.getFullYear()) {
        result.timestamp = new Date(
          now.getFullYear(), ts.getMonth(), ts.getDate(), ts.getHours(), ts.getMinutes(), ts.getSeconds()
        ).getTime()
        result.fixed = true
      } else {
        result.timestamp = timestamp
      }
    } else {
      result.timestamp = timestamp
    }
    return result
  }

  static weekRangeLabel(mondayKey: string): string {
    const keys = DateHelper.weekKeysFromMonday(mondayKey)
    const y = DateHelper.parseKey(mondayKey).getFullYear()
    return `${y}.${DateHelper.displayShort(mondayKey)}–${DateHelper.displayShort(keys[6])}`
  }
}

export class WeekTimeBounds {
  startMs: number = 0
  endMs: number = 0
  mondayKey: string = ''
}

export class DateClampResult {
  dateKey: string = ''
  timestamp: number = 0
  fixed: boolean = false
}
