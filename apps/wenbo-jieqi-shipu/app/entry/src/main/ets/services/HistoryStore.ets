import { SessionStore } from './SessionStore'

const KEY_HISTORY = 'recipeBrowseHistory'

/** 本地浏览历史（非栏目种子；按 id 逗号分隔，最多 20） */
export class HistoryStore {
  static ids(): string[] {
    const raw = AppStorage.get<string>(KEY_HISTORY) ?? ''
    if (raw.length === 0) {
      const out: string[] = []
      return out
    }
    return raw.split(',').filter((x: string) => x.length > 0)
  }

  static async push(id: string): Promise<void> {
    if (id.length === 0) {
      return
    }
    const next: string[] = [id]
    const prev = HistoryStore.ids()
    for (const p of prev) {
      if (p !== id) {
        next.push(p)
      }
    }
    const clipped: string[] = []
    for (const n of next) {
      if (clipped.length < 20) {
        clipped.push(n)
      }
    }
    await SessionStore.saveHistory(clipped.join(','))
  }
}
