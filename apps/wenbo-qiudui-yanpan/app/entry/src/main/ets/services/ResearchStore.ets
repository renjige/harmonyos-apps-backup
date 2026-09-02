import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE = 'team_research_folder'
const KEY_PINS = 'pins'

export class ResearchPin {
  kind: string = ''
  id: string = ''
  title: string = ''
  subtitle: string = ''
}

class PinBundle {
  entries: ResearchPin[] = []
}

export class ResearchStore {
  private static pref: preferences.Preferences | null = null
  private static cache: PinBundle = new PinBundle()

  static async init(context: common.Context): Promise<void> {
    try {
      ResearchStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await ResearchStore.pref.get(KEY_PINS, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      ResearchStore.cache = ResearchStore.parse(raw)
    } catch {
      ResearchStore.cache = new PinBundle()
    }
  }

  static list(): ResearchPin[] {
    const out: ResearchPin[] = []
    for (const row of ResearchStore.cache.entries) {
      out.push(row)
    }
    return out
  }

  static has(kind: string, id: string): boolean {
    for (const row of ResearchStore.cache.entries) {
      if (row.kind === kind && row.id === id) {
        return true
      }
    }
    return false
  }

  static async add(kind: string, id: string, title: string, subtitle: string): Promise<void> {
    if (id.length === 0 || ResearchStore.has(kind, id)) {
      return
    }
    const pin = new ResearchPin()
    pin.kind = kind
    pin.id = id
    pin.title = title
    pin.subtitle = subtitle
    const next = new PinBundle()
    next.entries.push(pin)
    for (const row of ResearchStore.cache.entries) {
      next.entries.push(row)
    }
    ResearchStore.cache = next
    await ResearchStore.flush()
  }

  static async remove(kind: string, id: string): Promise<void> {
    const next = new PinBundle()
    for (const row of ResearchStore.cache.entries) {
      if (row.kind === kind && row.id === id) {
        continue
      }
      next.entries.push(row)
    }
    ResearchStore.cache = next
    await ResearchStore.flush()
  }

  private static parse(raw: string): PinBundle {
    const bundle = new PinBundle()
    if (raw.length === 0) {
      return bundle
    }
    try {
      const parsed = JSON.parse(raw) as PinBundle
      if (parsed.entries !== undefined) {
        for (const row of parsed.entries) {
          const pin = new ResearchPin()
          pin.kind = row.kind ?? ''
          pin.id = row.id ?? ''
          pin.title = row.title ?? ''
          pin.subtitle = row.subtitle ?? ''
          if (pin.kind.length > 0 && pin.id.length > 0) {
            bundle.entries.push(pin)
          }
        }
      }
    } catch {
    }
    return bundle
  }

  private static async flush(): Promise<void> {
    if (ResearchStore.pref === null) {
      return
    }
    const parts: string[] = []
    for (const row of ResearchStore.cache.entries) {
      parts.push(
        `{"kind":${JSON.stringify(row.kind)},"id":${JSON.stringify(row.id)},` +
        `"title":${JSON.stringify(row.title)},"subtitle":${JSON.stringify(row.subtitle)}}`
      )
    }
    const raw = `{"entries":[${parts.join(',')}]}`
    try {
      await ResearchStore.pref.put(KEY_PINS, raw)
      await ResearchStore.pref.flush()
    } catch {
    }
  }
}
