import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { KingdomSettings, LevelProgress, LocalBundle, PracticeSession } from '../models/KingdomModels'

const STORE = 'kids_kingdom_local'
const KEY_BUNDLE = 'bundle'

class BundleWire {
  sessions: PracticeSession[] = []
  levels: LevelProgress[] = []
  stars: number = 0
  streak: number = 0
  lastDate: string = ''
  dailiesDone: number = 0
  lastDailyDate: string = ''
  relics: string[] = []
  observe: number = 0
  logic: number = 0
  memory: number = 0
  create: number = 0
  answered: number = 0
  correct: number = 0
  sound: boolean = true
  fontScale: number = 1
}

export class KingdomLocalStore {
  private static pref: preferences.Preferences | null = null
  private static cache: LocalBundle = new LocalBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      KingdomLocalStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await KingdomLocalStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      KingdomLocalStore.cache = KingdomLocalStore.parseBundle(raw)
    } catch {
      KingdomLocalStore.cache = new LocalBundle()
    }
  }

  static snapshot(): LocalBundle {
    return KingdomLocalStore.cache
  }

  static settings(): KingdomSettings {
    return KingdomLocalStore.cache.settings
  }

  static async saveBundle(next: LocalBundle): Promise<void> {
    KingdomLocalStore.cache = next
    await KingdomLocalStore.putString(KEY_BUNDLE, KingdomLocalStore.serialize(next))
  }

  static today(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms: string = m < 10 ? `0${m}` : `${m}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static dayIndex(): number {
    const now = new Date()
    const start = new Date(now.getFullYear(), 0, 0)
    const diff = now.getTime() - start.getTime()
    return Math.floor(diff / 86400000)
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static yesterday(date: string): string {
    const parts = date.split('-')
    if (parts.length !== 3) {
      return ''
    }
    const y = Number.parseInt(parts[0])
    const m = Number.parseInt(parts[1])
    const d = Number.parseInt(parts[2])
    const dt = new Date(y, m - 1, d)
    dt.setDate(dt.getDate() - 1)
    const mm = dt.getMonth() + 1
    const dd = dt.getDate()
    const ms: string = mm < 10 ? `0${mm}` : `${mm}`
    const ds: string = dd < 10 ? `0${dd}` : `${dd}`
    return `${dt.getFullYear()}-${ms}-${ds}`
  }

  private static serialize(bundle: LocalBundle): string {
    const wire = new BundleWire()
    wire.sessions = bundle.sessions
    wire.levels = bundle.levels
    wire.stars = bundle.stars
    wire.streak = bundle.streak
    wire.lastDate = bundle.lastDate
    wire.dailiesDone = bundle.dailiesDone
    wire.lastDailyDate = bundle.lastDailyDate
    wire.relics = bundle.relics
    wire.observe = bundle.observe
    wire.logic = bundle.logic
    wire.memory = bundle.memory
    wire.create = bundle.create
    wire.answered = bundle.answered
    wire.correct = bundle.correct
    wire.sound = bundle.settings.sound
    wire.fontScale = bundle.settings.fontScale
    return JSON.stringify(wire)
  }

  private static parseBundle(raw: string): LocalBundle {
    const empty = new LocalBundle()
    if (raw.length === 0) {
      return empty
    }
    try {
      const parsed = JSON.parse(raw) as BundleWire
      const out = new LocalBundle()
      if (parsed.sessions !== undefined) {
        out.sessions = parsed.sessions
      }
      if (parsed.levels !== undefined) {
        out.levels = parsed.levels
      }
      out.stars = parsed.stars
      out.streak = parsed.streak
      out.lastDate = parsed.lastDate
      out.dailiesDone = parsed.dailiesDone
      out.lastDailyDate = parsed.lastDailyDate
      if (parsed.relics !== undefined) {
        out.relics = parsed.relics
      }
      out.observe = parsed.observe
      out.logic = parsed.logic
      out.memory = parsed.memory
      out.create = parsed.create
      out.answered = parsed.answered
      out.correct = parsed.correct
      out.settings.sound = parsed.sound !== false
      if (parsed.fontScale > 0) {
        out.settings.fontScale = parsed.fontScale
      }
      return out
    } catch {
      return empty
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (KingdomLocalStore.pref === null) {
      return
    }
    await KingdomLocalStore.pref.put(key, value)
    await KingdomLocalStore.pref.flush()
  }
}
