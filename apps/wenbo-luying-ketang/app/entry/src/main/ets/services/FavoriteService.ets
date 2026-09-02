import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE_NAME = 'camp_class_favorites'
const KEY_ENTRIES = 'entries'

export class FavoriteEntry {
  targetId: string = ''
  kind: string = 'guide'
  title: string = ''
  coverKey: string = ''
}

class FavoriteWire {
  targetId: string = ''
  kind: string = ''
  title: string = ''
  coverKey: string = ''
}

/** 课程 / 社区笔记收藏 — 本地 Preferences，游客可用 */
export class FavoriteService {
  private static pref: preferences.Preferences | null = null
  private static entries: FavoriteEntry[] = []
  private static ready: boolean = false

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      FavoriteService.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await FavoriteService.pref.get(KEY_ENTRIES, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      FavoriteService.entries = FavoriteService.parse(text)
      FavoriteService.ready = true
      AppStorage.setOrCreate('favoriteTick', 0)
    } catch {
      FavoriteService.entries = []
      FavoriteService.ready = true
    }
  }

  static list(): FavoriteEntry[] {
    const out: FavoriteEntry[] = []
    for (const e of FavoriteService.entries) {
      out.push(e)
    }
    return out
  }

  static count(): number {
    return FavoriteService.entries.length
  }

  static isFavorite(targetId: string): boolean {
    for (const e of FavoriteService.entries) {
      if (e.targetId === targetId) {
        return true
      }
    }
    return false
  }

  static async toggle(targetId: string, kind: string, title: string, coverKey: string): Promise<boolean> {
    if (targetId.length === 0) {
      return false
    }
    if (FavoriteService.isFavorite(targetId)) {
      await FavoriteService.remove(targetId)
      return false
    }
    const entry = new FavoriteEntry()
    entry.targetId = targetId
    entry.kind = kind
    entry.title = title
    entry.coverKey = coverKey.length > 0 ? coverKey : 'guide_tent'
    FavoriteService.entries.unshift(entry)
    await FavoriteService.persist()
    return true
  }

  static async remove(targetId: string): Promise<void> {
    const next: FavoriteEntry[] = []
    for (const e of FavoriteService.entries) {
      if (e.targetId !== targetId) {
        next.push(e)
      }
    }
    FavoriteService.entries = next
    await FavoriteService.persist()
  }

  private static async persist(): Promise<void> {
    const payload: FavoriteWire[] = []
    for (const e of FavoriteService.entries) {
      const w = new FavoriteWire()
      w.targetId = e.targetId
      w.kind = e.kind
      w.title = e.title
      w.coverKey = e.coverKey
      payload.push(w)
    }
    const json = JSON.stringify(payload)
    if (FavoriteService.pref !== null) {
      await FavoriteService.pref.put(KEY_ENTRIES, json)
      await FavoriteService.pref.flush()
    }
    const tick = AppStorage.get<number>('favoriteTick') ?? 0
    AppStorage.setOrCreate('favoriteTick', tick + 1)
  }

  private static parse(raw: string): FavoriteEntry[] {
    try {
      const parsed = JSON.parse(raw) as FavoriteWire[]
      const out: FavoriteEntry[] = []
      for (const w of parsed) {
        if (w.targetId.length === 0) {
          continue
        }
        const e = new FavoriteEntry()
        e.targetId = w.targetId
        e.kind = w.kind.length > 0 ? w.kind : 'guide'
        e.title = w.title
        e.coverKey = w.coverKey.length > 0 ? w.coverKey : 'guide_tent'
        out.push(e)
      }
      return out
    } catch {
      return []
    }
  }
}
