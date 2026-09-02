import { SessionStore } from './SessionStore'

/**
 * 预约打卡/取消的本机覆盖层。
 * 公网对 PUT /status 返回 404 时，仍保证「到场打卡 / 取消」对用户可见。
 */
export class CourtBookingStatusStore {
  static overlayOf(id: string): string {
    if (id.length === 0) {
      return ''
    }
    const pairs = CourtBookingStatusStore.parse()
    for (let i = 0; i < pairs.length; i++) {
      if (pairs[i].id === id) {
        return pairs[i].status
      }
    }
    return ''
  }

  static async set(id: string, status: string): Promise<void> {
    if (id.length === 0 || status.length === 0) {
      return
    }
    const next: StatusPair[] = []
    let found = false
    const pairs = CourtBookingStatusStore.parse()
    for (let i = 0; i < pairs.length; i++) {
      if (pairs[i].id === id) {
        const p = new StatusPair()
        p.id = id
        p.status = status
        next.push(p)
        found = true
      } else {
        next.push(pairs[i])
      }
    }
    if (!found) {
      const p = new StatusPair()
      p.id = id
      p.status = status
      next.push(p)
    }
    const raw = CourtBookingStatusStore.serialize(next)
    AppStorage.setOrCreate('courtBookingStatus', raw)
    await SessionStore.saveBookingStatus(raw)
  }

  static applyTo(id: string, serverStatus: string): string {
    const local = CourtBookingStatusStore.overlayOf(id)
    if (local.length > 0) {
      return local
    }
    return serverStatus
  }

  private static parse(): StatusPair[] {
    const raw = AppStorage.get<string>('courtBookingStatus') ?? ''
    const out: StatusPair[] = []
    if (raw.length === 0) {
      return out
    }
    const chunks = raw.split('|')
    for (let i = 0; i < chunks.length; i++) {
      const part = chunks[i]
      const eq = part.indexOf('=')
      if (eq <= 0) {
        continue
      }
      const p = new StatusPair()
      p.id = part.substring(0, eq)
      p.status = part.substring(eq + 1)
      if (p.id.length > 0 && p.status.length > 0) {
        out.push(p)
      }
    }
    return out
  }

  private static serialize(pairs: StatusPair[]): string {
    const bits: string[] = []
    for (let i = 0; i < pairs.length; i++) {
      bits.push(`${pairs[i].id}=${pairs[i].status}`)
    }
    return bits.join('|')
  }
}

class StatusPair {
  id: string = ''
  status: string = ''
}
