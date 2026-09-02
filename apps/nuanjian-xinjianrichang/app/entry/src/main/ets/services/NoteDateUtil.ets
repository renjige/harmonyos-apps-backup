export class NoteDateUtil {
  static pad2(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  static todayIso(): string {
    return NoteDateUtil.toIso(new Date())
  }

  static toIso(d: Date): string {
    return `${d.getFullYear()}-${NoteDateUtil.pad2(d.getMonth() + 1)}-${NoteDateUtil.pad2(d.getDate())}`
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

  static homeTitle(d: Date): string {
    return `${d.getMonth() + 1}月${d.getDate()}日`
  }

  static cardDate(iso: string): string {
    const parts = iso.split('-')
    if (parts.length !== 3) {
      return iso
    }
    let y = ''
    let m = ''
    let day = ''
    let i = 0
    for (const p of parts) {
      if (i === 0) {
        y = p
      } else if (i === 1) {
        m = p
      } else {
        day = p
      }
      i += 1
    }
    if (y.length === 0) {
      return iso
    }
    return `${m}月${day}日`
  }

  static periodOf(d: Date): string {
    const h = d.getHours()
    if (h < 12) {
      return '上午'
    }
    if (h < 18) {
      return '下午'
    }
    return '晚上'
  }

  static monthKey(iso: string): string {
    if (iso.length >= 7) {
      return iso.substring(0, 7)
    }
    return iso
  }

  static currentMonthKey(): string {
    const d = new Date()
    return `${d.getFullYear()}-${NoteDateUtil.pad2(d.getMonth() + 1)}`
  }

  static monthTitle(key: string): string {
    const parts = key.split('-')
    if (parts.length < 2) {
      return key
    }
    let y = ''
    let m = ''
    let i = 0
    for (const p of parts) {
      if (i === 0) {
        y = p
      } else if (i === 1) {
        m = p
      }
      i += 1
    }
    return `${y}年${m}月`
  }
}
