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

  static weekdayLabel(d: Date): string {
    const names: string[] = ['日', '一', '二', '三', '四', '五', '六']
    let label = '日'
    let i = 0
    for (const n of names) {
      if (i === d.getDay()) {
        label = n
      }
      i += 1
    }
    return `星期${label}`
  }

  static homeDate(d: Date): string {
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日 · ${SlipDateUtil.weekdayLabel(d)}`
  }

  static timeLabel(d: Date): string {
    return `${SlipDateUtil.pad2(d.getHours())}:${SlipDateUtil.pad2(d.getMinutes())}`
  }

  static cardDate(iso: string): string {
    const parts = iso.split('-')
    if (parts.length !== 3) {
      return iso
    }
    return `${parts[0]}.${parts[1]}.${parts[2]}`
  }

  static longDate(iso: string): string {
    const parts = iso.split('-')
    if (parts.length !== 3) {
      return iso
    }
    return `${parts[0]}年${Number(parts[1])}月${Number(parts[2])}日`
  }

  static sameMonth(iso: string): boolean {
    const today = SlipDateUtil.todayIso()
    if (iso.length < 7 || today.length < 7) {
      return false
    }
    return iso.substring(0, 7) === today.substring(0, 7)
  }

  static inLastDays(iso: string, days: number): boolean {
    const d = new Date()
    d.setDate(d.getDate() - days)
    return iso >= SlipDateUtil.toIso(d)
  }

  static newId(): string {
    return `isp_${Date.now()}`
  }
}
