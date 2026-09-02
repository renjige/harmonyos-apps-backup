import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  LocalBundle,
  MathSettings,
  PracticeSession,
  WrongItem
} from '../models/MathModels'

const STORE = 'kids_math_local'
const KEY_BUNDLE = 'bundle'
const KEY_ONBOARD = 'onboardingDone'

class BundleWire {
  sessions: PracticeSession[] = []
  wrongs: WrongItem[] = []
  stars: number = 0
  streak: number = 0
  lastDate: string = ''
  answered: number = 0
  correct: number = 0
  medals: string[] = []
  dailyCount: number = 10
  practiceCount: number = 10
  difficulty: string = 'easy'
  sound: boolean = true
  motion: boolean = true
  timedMode: boolean = false
  remindStudy: boolean = false
}

export class MathLocalStore {
  private static pref: preferences.Preferences | null = null
  private static cache: LocalBundle = new LocalBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      MathLocalStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await MathLocalStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      MathLocalStore.cache = MathLocalStore.parseBundle(raw)
      const onboardValue = await MathLocalStore.pref.get(KEY_ONBOARD, false)
      AppStorage.setOrCreate(KEY_ONBOARD, onboardValue === true)
    } catch {
      MathLocalStore.cache = new LocalBundle()
      AppStorage.setOrCreate(KEY_ONBOARD, false)
    }
  }

  static snapshot(): LocalBundle {
    return MathLocalStore.cache
  }

  static settings(): MathSettings {
    return MathLocalStore.cache.settings
  }

  static async saveBundle(next: LocalBundle): Promise<void> {
    MathLocalStore.cache = next
    await MathLocalStore.putString(KEY_BUNDLE, MathLocalStore.serialize(next))
  }

  static async setOnboardingDone(): Promise<void> {
    AppStorage.setOrCreate(KEY_ONBOARD, true)
    await MathLocalStore.putBool(KEY_ONBOARD, true)
  }

  static today(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms: string = m < 10 ? `0${m}` : `${m}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
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
    wire.wrongs = bundle.wrongs
    wire.stars = bundle.stars
    wire.streak = bundle.streak
    wire.lastDate = bundle.lastDate
    wire.answered = bundle.answered
    wire.correct = bundle.correct
    wire.medals = bundle.medals
    wire.dailyCount = bundle.settings.dailyCount
    wire.practiceCount = bundle.settings.practiceCount
    wire.difficulty = bundle.settings.difficulty
    wire.sound = bundle.settings.sound
    wire.motion = bundle.settings.motion
    wire.timedMode = bundle.settings.timedMode
    wire.remindStudy = bundle.settings.remindStudy
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
      if (parsed.wrongs !== undefined) {
        out.wrongs = parsed.wrongs
      }
      out.stars = parsed.stars ?? 0
      out.streak = parsed.streak ?? 0
      out.lastDate = parsed.lastDate ?? ''
      out.answered = parsed.answered ?? 0
      out.correct = parsed.correct ?? 0
      if (parsed.medals !== undefined) {
        out.medals = parsed.medals
      }
      const s = new MathSettings()
      s.dailyCount = parsed.dailyCount > 0 ? parsed.dailyCount : 10
      s.practiceCount = parsed.practiceCount > 0 ? parsed.practiceCount : 10
      s.difficulty = parsed.difficulty.length > 0 ? parsed.difficulty : 'easy'
      s.sound = parsed.sound !== false
      s.motion = parsed.motion !== false
      s.timedMode = parsed.timedMode === true
      s.remindStudy = parsed.remindStudy === true
      out.settings = s
      return out
    } catch {
      return empty
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (MathLocalStore.pref === null) {
      return
    }
    try {
      await MathLocalStore.pref.put(key, value)
      await MathLocalStore.pref.flush()
    } catch {
    }
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (MathLocalStore.pref === null) {
      return
    }
    try {
      await MathLocalStore.pref.put(key, value)
      await MathLocalStore.pref.flush()
    } catch {
    }
  }
}
