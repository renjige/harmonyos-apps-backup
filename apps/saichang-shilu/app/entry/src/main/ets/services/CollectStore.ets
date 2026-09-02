import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { CollectItem } from '../models/CollectModels'

const STORE = 'saichang_collect_v1'
const KEY = 'items'

export class CollectStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      CollectStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      CollectStore.pref = null
    }
  }

  static async loadAll(): Promise<CollectItem[]> {
    return CollectStore.parse(await CollectStore.getString(KEY, ''))
  }

  static async loadKind(kind: string): Promise<CollectItem[]> {
    const all = await CollectStore.loadAll()
    const out: CollectItem[] = []
    for (const it of all) {
      if (it.kind === kind) {
        out.push(it)
      }
    }
    return out
  }

  static async save(item: CollectItem): Promise<void> {
    const list = await CollectStore.loadAll()
    const next: CollectItem[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    next.sort((a, b) => b.createdAt - a.createdAt)
    await CollectStore.persist(next)
  }

  static async remove(id: string): Promise<void> {
    const list = await CollectStore.loadAll()
    const next: CollectItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await CollectStore.persist(next)
  }

  static async find(id: string): Promise<CollectItem | undefined> {
    const list = await CollectStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async loadByMatchId(matchId: string): Promise<CollectItem[]> {
    const all = await CollectStore.loadAll()
    const out: CollectItem[] = []
    for (const it of all) {
      if (it.refMatchId === matchId) {
        out.push(it)
      }
    }
    return out
  }

  private static async persist(items: CollectItem[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      const body = it.body.replace(/\n/g, '\\n')
      lines.push([
        it.kind, it.id, it.title, it.sub, body, it.extra, it.tags,
        `${it.createdAt}`, it.refMatchId
      ].join('\t'))
    }
    if (CollectStore.pref === null) {
      return
    }
    try {
      await CollectStore.pref.put(KEY, lines.join('\n'))
      await CollectStore.pref.flush()
    } catch {
    }
  }

  private static parse(raw: string): CollectItem[] {
    const out: CollectItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 8) {
        continue
      }
      const it = new CollectItem()
      it.kind = p[0]
      it.id = p[1]
      it.title = p[2]
      it.sub = p[3]
      it.body = p[4].replace(/\\n/g, '\n')
      it.extra = p[5]
      it.tags = p[6]
      it.createdAt = parseInt(p[7], 10)
      if (p.length >= 9) {
        it.refMatchId = p[8]
      }
      out.push(it)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (CollectStore.pref === null) {
      return fallback
    }
    try {
      return `${await CollectStore.pref.get(key, fallback)}`
    } catch {
      return fallback
    }
  }
}
