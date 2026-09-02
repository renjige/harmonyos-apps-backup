export class NoteDateUtil {
  static newId(): string {
    return `n_${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }

  static todayIso(): string {
    return NoteDateUtil.toIso(new Date())
  }

  static toIso(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${y}-${mm}-${dd}`
  }

  static timeLabel(d: Date): string {
    const h = d.getHours()
    const min = d.getMinutes()
    const hh = h < 10 ? `0${h}` : `${h}`
    const mm = min < 10 ? `0${min}` : `${min}`
    return `${hh}:${mm}`
  }

  static displayDate(iso: string): string {
    const parts = iso.split('-')
    if (parts.length !== 3) {
      return iso
    }
    return `${parts[0]}年${parseInt(parts[1])}月${parseInt(parts[2])}日`
  }

  static homeDate(d: Date): string {
    const week = ['日', '一', '二', '三', '四', '五', '六']
    const m = d.getMonth() + 1
    const day = d.getDate()
    return `${m}月${day}日 · 周${week[d.getDay()]}`
  }

  static daysInMonth(year: number, month: number): number {
    return new Date(year, month, 0).getDate()
  }
}
