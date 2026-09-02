import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { HistoryEntry } from '../models/BrochureModels'

const STORE_NAME = 'jz_history'
const KEY_ITEMS = 'entries'
const MAX_ITEMS = 30

/** 浏览历史 — 本地 Preferences，我的页展示。 */
export class BrowseHistoryService {
  private static pref: preferences.Preferences | null = null
  private static items: HistoryEntry[] = []
  private static ready: boolean = false

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      BrowseHistoryService.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await BrowseHistoryService.pref.get(KEY_ITEMS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      BrowseHistoryService.items = BrowseHistoryService.parseEntries(text)
      BrowseHistoryService.ready = true
    } catch {
      BrowseHistoryService.items = []
      BrowseHistoryService.ready = true
    }
  }

  static list(limit: number = 10): HistoryEntry[] {
    const out: HistoryEntry[] = []
    let i = 0
    while (i < BrowseHistoryService.items.length && out.length < limit) {
      out.push(BrowseHistoryService.items[i])
      i = i + 1
    }
    return out
  }

  static count(): number {
    return BrowseHistoryService.items.length
  }

  static async record(id: string, title: string, kind: string = 'brochure'): Promise<void> {
    if (id.length === 0) {
      return
    }
    const next: HistoryEntry[] = []
    const row = new HistoryEntry()
    row.id = id
    row.title = title
    row.kind = kind
    row.viewedAt = Date.now()
    next.push(row)
    for (let item of BrowseHistoryService.items) {
      if (item.id !== id || item.kind !== kind) {
        next.push(item)
      }
      if (next.length >= MAX_ITEMS) {
        break
      }
    }
    BrowseHistoryService.items = next
    await BrowseHistoryService.persist()
  }

  static async remove(id: string, kind: string): Promise<void> {
    const next: HistoryEntry[] = []
    for (let item of BrowseHistoryService.items) {
      if (!(item.id === id && item.kind === kind)) {
        next.push(item)
      }
    }
    BrowseHistoryService.items = next
    await BrowseHistoryService.persist()
  }

  static async clear(): Promise<void> {
    BrowseHistoryService.items = []
    await BrowseHistoryService.persist()
  }

  private static async persist(): Promise<void> {
    const payload: HistoryWire[] = []
    for (let item of BrowseHistoryService.items) {
      const w = new HistoryWire()
      w.id = item.id
      w.title = item.title
      w.kind = item.kind
      w.viewedAt = item.viewedAt
      payload.push(w)
    }
    const json = JSON.stringify(payload)
    if (BrowseHistoryService.pref !== null) {
      await BrowseHistoryService.pref.put(KEY_ITEMS, json)
      await BrowseHistoryService.pref.flush()
    }
    const tick = AppStorage.get<number>('historyTick') ?? 0
    AppStorage.setOrCreate('historyTick', tick + 1)
  }

  private static parseEntries(raw: string): HistoryEntry[] {
    try {
      const parsed = JSON.parse(raw) as HistoryWire[]
      const out: HistoryEntry[] = []
      for (let row of parsed) {
        const e = new HistoryEntry()
        e.id = row.id
        e.title = row.title
        e.kind = row.kind
        e.viewedAt = row.viewedAt
        out.push(e)
      }
      return out
    } catch {
      return []
    }
  }
}

class HistoryWire {
  id: string = ''
  title: string = ''
  kind: string = 'brochure'
  viewedAt: number = 0
}
