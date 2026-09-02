export class EssayDateUtil {
  static todayIso(): string {
    return EssayDateUtil.isoFromDate(new Date())
  }

  static isoFromDate(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static isoFromTs(ts: number): string {
    return EssayDateUtil.isoFromDate(new Date(ts))
  }

  static homeTitle(d: Date): string {
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  }

  static weekdayLabel(d: Date): string {
    const names: string[] = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
    return names[d.getDay()]
  }

  static greet(): string {
    const h = new Date().getHours()
    if (h < 11) {
      return '早安，记录今日'
    }
    if (h < 18) {
      return '午安，写下此刻'
    }
    return '晚安，把今天折进笺里'
  }

  static cardTime(ts: number): string {
    const d = new Date(ts)
    const today = EssayDateUtil.todayIso()
    const iso = EssayDateUtil.isoFromTs(ts)
    const h = d.getHours()
    const m = d.getMinutes()
    const hs = h < 10 ? `0${h}` : `${h}`
    const ms = m < 10 ? `0${m}` : `${m}`
    if (iso === today) {
      return `${hs}:${ms}`
    }
    return `${d.getMonth() + 1}月${d.getDate()}日 ${hs}:${ms}`
  }

  static newId(): string {
    return `${Date.now()}_${Math.floor(Math.random() * 100000)}`
  }
}
