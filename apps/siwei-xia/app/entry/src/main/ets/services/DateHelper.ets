export class DateHelper {
  static formatTime(ts: number): string {
    const d = new Date(ts)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const hh = d.getHours()
    const mm = d.getMinutes()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    const hs = hh < 10 ? `0${hh}` : `${hh}`
    const mins = mm < 10 ? `0${mm}` : `${mm}`
    return `${d.getFullYear()}-${ms}-${ds} ${hs}:${mins}`
  }

  static formatShort(ts: number): string {
    const d = new Date(ts)
    return `${d.getMonth() + 1}月${d.getDate()}日`
  }

  static dateKey(ts: number): string {
    const d = new Date(ts)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static todayKey(): string {
    return DateHelper.dateKey(Date.now())
  }

  static prevKey(key: string): string {
    const parts = key.split('-')
    if (parts.length < 3) {
      return key
    }
    const y = parseInt(parts[0], 10)
    const m = parseInt(parts[1], 10) - 1
    const d = parseInt(parts[2], 10)
    const dt = new Date(y, m, d)
    dt.setDate(dt.getDate() - 1)
    return DateHelper.dateKey(dt.getTime())
  }

  static streakFromKeys(keys: string[]): number {
    const uniq: string[] = []
    for (const k of keys) {
      let found = false
      for (const u of uniq) {
        if (u === k) {
          found = true
          break
        }
      }
      if (!found && k.length > 0) {
        uniq.push(k)
      }
    }
    const today = DateHelper.todayKey()
    const yest = DateHelper.prevKey(today)
    let cursor = ''
    for (const u of uniq) {
      if (u === today) {
        cursor = today
        break
      }
    }
    if (cursor.length === 0) {
      for (const u of uniq) {
        if (u === yest) {
          cursor = yest
          break
        }
      }
    }
    if (cursor.length === 0) {
      return 0
    }
    let n = 0
    while (cursor.length > 0) {
      let hit = false
      for (const u of uniq) {
        if (u === cursor) {
          hit = true
          break
        }
      }
      if (!hit) {
        break
      }
      n = n + 1
      cursor = DateHelper.prevKey(cursor)
    }
    return n
  }
}
