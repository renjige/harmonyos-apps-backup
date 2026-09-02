import { CalCell } from '../models/SlipModels'

export class SlipDateUtil {
  static pad2(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  static todayIso(): string {
    return SlipDateUtil.toIso(new Date())
  }

  static toIso(d: Date): string {
    return `${d.getFullYear()}-${SlipDateUtil.pad2(d.getMonth() + 1)}-${SlipDateUtil.pad2(d.getDate())}`
  }

  static tomorrowIso(): string {
    const d = new Date()
    d.setDate(d.getDate() + 1)
    return SlipDateUtil.toIso(d)
  }

  static parseIso(text: string): Date {
    const parts = text.split('-')
    if (parts.length === 3) {
      const y = Number.parseInt(parts[0], 10)
      const m = Number.parseInt(parts[1], 10)
      const day = Number.parseInt(parts[2], 10)
      if (!Number.isNaN(y) && !Number.isNaN(m) && !Number.isNaN(day)) {
        return new Date(y, m - 1, day)
      }
    }
    return new Date()
  }

  static weekdayLabel(d: Date): string {
    const names: string[] = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
    const i = d.getDay()
    if (i >= 0 && i < names.length) {
      return names[i]
    }
    return ''
  }

  static homeTitle(d: Date): string {
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  }

  static monthTitle(year: number, month: number): string {
    return `${year}年${month}月`
  }

  static shortDate(iso: string): string {
    const d = SlipDateUtil.parseIso(iso)
    return `${d.getMonth() + 1}月${d.getDate()}日`
  }

  static greetingFallback(iso: string, done: number, total: number): string {
    if (total > 0 && done >= total) {
      return '做完的事情，也值得被看见。'
    }
    const d = SlipDateUtil.parseIso(iso)
    const day = d.getDay()
    if (day === 0 || day === 6) {
      return '周末把节奏放慢一点。'
    }
    if (day === 1) {
      return '新的一周，从一件小事开始。'
    }
    return '今天也把生活安排得刚刚好。'
  }

  static buildMonth(year: number, month: number, selectedIso: string, marked: string[]): CalCell[] {
    const out: CalCell[] = []
    const first = new Date(year, month - 1, 1)
    let lead = first.getDay() - 1
    if (lead < 0) {
      lead = 6
    }
    const start = new Date(first.getTime())
    start.setDate(1 - lead)
    const today = SlipDateUtil.todayIso()
    for (let i = 0; i < 42; i++) {
      const d = new Date(start.getTime())
      d.setDate(start.getDate() + i)
      const cell = new CalCell()
      cell.iso = SlipDateUtil.toIso(d)
      cell.day = d.getDate()
      cell.inMonth = d.getMonth() + 1 === month
      cell.isToday = cell.iso === today
      cell.isSelected = cell.iso === selectedIso
      cell.hasItems = SlipDateUtil.contains(marked, cell.iso)
      out.push(cell)
    }
    return out
  }

  static contains(list: string[], value: string): boolean {
    for (const v of list) {
      if (v === value) {
        return true
      }
    }
    return false
  }

  static weekHeaders(): string[] {
    return ['一', '二', '三', '四', '五', '六', '日']
  }
}
