export class DateUtil {
  static displayDate(dateKey: string): string {
    const parts = dateKey.split('-')
    if (parts.length !== 3) {
      return dateKey
    }
    return `${parts[0]}年${parseInt(parts[1], 10)}月${parseInt(parts[2], 10)}日`
  }

  static monthLabel(year: number, month: number): string {
    return `${year}年${month}月`
  }

  static todayKey(): string {
    const d = new Date()
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }
}
