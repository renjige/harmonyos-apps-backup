import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE_NAME = 'jz_compare'
const KEY_IDS = 'brochureIds'
const MAX_ITEMS = 4

/** 对比清单 — 本地 AppStorage + Preferences，最多 4 所院校。 */
export class CompareStore {
  private static pref: preferences.Preferences | null = null
  private static ids: string[] = []
  private static ready: boolean = false

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      CompareStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await CompareStore.pref.get(KEY_IDS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      CompareStore.ids = CompareStore.parseIds(text)
      CompareStore.ready = true
      CompareStore.syncAppStorage()
    } catch {
      CompareStore.ids = []
      CompareStore.ready = true
    }
  }

  static isReady(): boolean {
    return CompareStore.ready
  }

  static maxCount(): number {
    return MAX_ITEMS
  }

  static listIds(): string[] {
    const out: string[] = []
    for (let id of CompareStore.ids) {
      out.push(id)
    }
    return out
  }

  static count(): number {
    return CompareStore.ids.length
  }

  static contains(brochureId: string): boolean {
    for (let id of CompareStore.ids) {
      if (id === brochureId) {
        return true
      }
    }
    return false
  }

  static canAdd(): boolean {
    return CompareStore.ids.length < MAX_ITEMS
  }

  static async add(brochureId: string): Promise<boolean> {
    if (brochureId.length === 0) {
      return false
    }
    if (CompareStore.contains(brochureId)) {
      return true
    }
    if (!CompareStore.canAdd()) {
      return false
    }
    CompareStore.ids.push(brochureId)
    await CompareStore.persist()
    return true
  }

  static async remove(brochureId: string): Promise<void> {
    const next: string[] = []
    for (let id of CompareStore.ids) {
      if (id !== brochureId) {
        next.push(id)
      }
    }
    CompareStore.ids = next
    await CompareStore.persist()
  }

  static async clear(): Promise<void> {
    CompareStore.ids = []
    await CompareStore.persist()
  }

  private static syncAppStorage(): void {
    AppStorage.setOrCreate('compareIds', CompareStore.ids.join(','))
    const tick = AppStorage.get<number>('compareTick') ?? 0
    AppStorage.setOrCreate('compareTick', tick)
  }

  private static async persist(): Promise<void> {
    const json = JSON.stringify(CompareStore.ids)
    if (CompareStore.pref !== null) {
      await CompareStore.pref.put(KEY_IDS, json)
      await CompareStore.pref.flush()
    }
    CompareStore.syncAppStorage()
    const tick = AppStorage.get<number>('compareTick') ?? 0
    AppStorage.setOrCreate('compareTick', tick + 1)
  }

  private static parseIds(raw: string): string[] {
    try {
      const parsed = JSON.parse(raw) as string[]
      const out: string[] = []
      let i = 0
      while (i < parsed.length && out.length < MAX_ITEMS) {
        const id = parsed[i]
        if (typeof id === 'string' && id.length > 0 && !CompareStore.containsIn(out, id)) {
          out.push(id)
        }
        i = i + 1
      }
      return out
    } catch {
      return []
    }
  }

  private static containsIn(list: string[], id: string): boolean {
    for (let x of list) {
      if (x === id) {
        return true
      }
    }
    return false
  }
}
