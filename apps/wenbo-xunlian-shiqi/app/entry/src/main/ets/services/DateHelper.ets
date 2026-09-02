export class DateHelper {
  static todayKey(): string {
    const d = new Date()
    return DateHelper.formatKey(d)
  }

  static formatKey(d: Date): string {
    const y = d.getFullYear()
    const m = String(d.getMonth() + 1).padStart(2, '0')
    const day = String(d.getDate()).padStart(2, '0')
    return `${y}-${m}-${day}`
  }

  static greeting(): string {
    const h = new Date().getHours()
    if (h >= 5 && h < 11) {
      return '早上好'
    }
    if (h >= 11 && h < 14) {
      return '中午好'
    }
    if (h >= 14 && h < 18) {
      return '下午好'
    }
    return '晚上好'
  }

  static usageDays(firstUseAt: number, nowMs: number): number {
    if (firstUseAt <= 0) {
      return 1
    }
    const diff = nowMs - firstUseAt
    return Math.max(1, Math.floor(diff / 86400000) + 1)
  }

  static monthLabel(year: number, month: number): string {
    return `${year} 年 ${month} 月`
  }

  static mondayKey(): string {
    const d = new Date()
    const day = d.getDay()
    const delta = day === 0 ? -6 : 1 - day
    d.setDate(d.getDate() + delta)
    return DateHelper.formatKey(d)
  }

  static isOnOrAfter(dateKey: string, startKey: string): boolean {
    return dateKey >= startKey
  }
}
