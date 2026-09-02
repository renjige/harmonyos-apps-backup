/** 赛事状态 — 按开赛时间校正，避免种子 status 过期 */
export class EventStatusUtil {
  static resolve(rawStatus: string, startAt: string, endAt: string): string {
    if (startAt.length < 10) {
      return rawStatus.length > 0 ? rawStatus : 'upcoming'
    }
    const start = Date.parse(startAt)
    if (start !== start) {
      return rawStatus.length > 0 ? rawStatus : 'upcoming'
    }
    const now = Date.now()
    let end = start + 3 * 3600000
    if (endAt.length >= 10) {
      const parsedEnd = Date.parse(endAt)
      if (parsedEnd === parsedEnd) {
        end = parsedEnd
      }
    }
    if (now >= end) {
      return 'finished'
    }
    if (now >= start) {
      return 'live'
    }
    return 'upcoming'
  }

  static isFuture(startAt: string): boolean {
    return EventStatusUtil.resolve('upcoming', startAt, '') === 'upcoming'
  }
}
