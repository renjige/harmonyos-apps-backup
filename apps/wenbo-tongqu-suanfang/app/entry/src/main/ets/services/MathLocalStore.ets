import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  CustomExpr,
  CustomSet,
  DayCheckIn,
  LocalBundle,
  MathSettings,
  PracticeSession,
  StudyPack,
  WrongItem
} from '../models/MathModels'

const STORE = 'kids_math_local'
const KEY_BUNDLE = 'bundle'
const KEY_ONBOARD = 'onboardingDone'

class BundleWire {
  sessions: PracticeSession[] = []
  wrongs: WrongItem[] = []
  favorites: WrongItem[] = []
  stars: number = 0
  streak: number = 0
  lastDate: string = ''
  answered: number = 0
  correct: number = 0
  medals: string[] = []
  challengeClear: number = 0
  dailyCount: number = 10
  difficulty: string = 'easy'
  sound: boolean = true
  motion: boolean = true
  grade: string = 'age68'
  planStart: string = ''
  planPreset: string = 'balance'
  weekGoal: number = 50
  checkins: DayCheckIn[] = []
  customSets: CustomSet[] = []
  packs: StudyPack[] = []
  recentModes: string = ''
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

  static datePlus(date: string, days: number): string {
    const parts = date.split('-')
    if (parts.length !== 3) {
      return date
    }
    const dt = new Date(Number.parseInt(parts[0]), Number.parseInt(parts[1]) - 1, Number.parseInt(parts[2]))
    dt.setDate(dt.getDate() + days)
    const mm = dt.getMonth() + 1
    const dd = dt.getDate()
    const ms: string = mm < 10 ? `0${mm}` : `${mm}`
    const ds: string = dd < 10 ? `0${dd}` : `${dd}`
    return `${dt.getFullYear()}-${ms}-${ds}`
  }

  static daysBetween(from: string, to: string): number {
    const a = from.split('-')
    const b = to.split('-')
    if (a.length !== 3 || b.length !== 3) {
      return 0
    }
    const da = new Date(Number.parseInt(a[0]), Number.parseInt(a[1]) - 1, Number.parseInt(a[2]))
    const db = new Date(Number.parseInt(b[0]), Number.parseInt(b[1]) - 1, Number.parseInt(b[2]))
    return Math.floor((db.getTime() - da.getTime()) / 86400000)
  }

  static formatDay(offset: number): string {
    const d = new Date()
    d.setDate(d.getDate() + offset)
    const mm = d.getMonth() + 1
    const dd = d.getDate()
    const ms: string = mm < 10 ? `0${mm}` : `${mm}`
    const ds: string = dd < 10 ? `0${dd}` : `${dd}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  private static serialize(bundle: LocalBundle): string {
    const wire = new BundleWire()
    wire.sessions = bundle.sessions
    wire.wrongs = bundle.wrongs
    wire.favorites = bundle.favorites
    wire.stars = bundle.stars
    wire.streak = bundle.streak
    wire.lastDate = bundle.lastDate
    wire.answered = bundle.answered
    wire.correct = bundle.correct
    wire.medals = bundle.medals
    wire.challengeClear = bundle.challengeClear
    wire.dailyCount = bundle.settings.dailyCount
    wire.difficulty = bundle.settings.difficulty
    wire.sound = bundle.settings.sound
    wire.motion = bundle.settings.motion
    wire.grade = bundle.settings.grade
    wire.planStart = bundle.settings.planStart
    wire.planPreset = bundle.settings.planPreset
    wire.weekGoal = bundle.settings.weekGoal > 0 ? bundle.settings.weekGoal : 50
    wire.checkins = bundle.checkins
    wire.customSets = bundle.customSets
    wire.packs = bundle.packs
    wire.recentModes = bundle.recentModes
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
        const sess: PracticeSession[] = []
        for (const raw of parsed.sessions) {
          const p = new PracticeSession()
          p.id = raw.id
          p.kind = raw.kind
          p.mode = raw.mode
          p.total = raw.total
          p.correct = raw.correct
          p.stars = raw.stars > 0 ? raw.stars : 0
          p.durationMs = raw.durationMs
          p.date = raw.date
          sess.push(p)
        }
        out.sessions = sess
      }
      if (parsed.wrongs !== undefined) {
        const list: WrongItem[] = []
        for (const raw of parsed.wrongs) {
          list.push(MathLocalStore.hydrateWrong(raw))
        }
        out.wrongs = list
      }
      if (parsed.favorites !== undefined) {
        const list: WrongItem[] = []
        for (const raw of parsed.favorites) {
          list.push(MathLocalStore.hydrateWrong(raw))
        }
        out.favorites = list
      }
      out.stars = parsed.stars ?? 0
      out.streak = parsed.streak ?? 0
      out.lastDate = parsed.lastDate ?? ''
      out.answered = parsed.answered ?? 0
      out.correct = parsed.correct ?? 0
      out.challengeClear = parsed.challengeClear ?? 0
      if (parsed.medals !== undefined) {
        out.medals = parsed.medals
      }
      const s = new MathSettings()
      s.dailyCount = parsed.dailyCount > 0 ? parsed.dailyCount : 10
      s.difficulty = parsed.difficulty !== undefined && parsed.difficulty.length > 0 ? parsed.difficulty : 'easy'
      s.sound = parsed.sound !== false
      s.motion = parsed.motion !== false
      s.grade = parsed.grade !== undefined && parsed.grade.length > 0 ? parsed.grade : 'age68'
      s.planStart = parsed.planStart !== undefined ? parsed.planStart : ''
      s.planPreset = parsed.planPreset !== undefined && parsed.planPreset.length > 0 ? parsed.planPreset : 'balance'
      s.weekGoal = parsed.weekGoal > 0 ? parsed.weekGoal : 50
      out.settings = s
      if (parsed.checkins !== undefined) {
        const list: DayCheckIn[] = []
        for (const raw of parsed.checkins) {
          list.push(MathLocalStore.hydrateCheckIn(raw))
        }
        out.checkins = list
      }
      if (parsed.customSets !== undefined) {
        const list: CustomSet[] = []
        for (const raw of parsed.customSets) {
          list.push(MathLocalStore.hydrateSet(raw))
        }
        out.customSets = list
      }
      if (parsed.packs !== undefined) {
        const list: StudyPack[] = []
        for (const raw of parsed.packs) {
          list.push(MathLocalStore.hydratePack(raw))
        }
        out.packs = list
      }
      out.recentModes = parsed.recentModes !== undefined ? parsed.recentModes : ''
      return out
    } catch {
      return empty
    }
  }

  private static str(v: string | undefined): string {
    return v !== undefined ? v : ''
  }

  private static hydrateWrong(raw: WrongItem): WrongItem {
    const w = new WrongItem()
    w.id = MathLocalStore.str(raw.id)
    w.expression = MathLocalStore.str(raw.expression)
    w.userAnswer = MathLocalStore.str(raw.userAnswer)
    w.correctAnswer = MathLocalStore.str(raw.correctAnswer)
    w.lastAt = MathLocalStore.str(raw.lastAt)
    w.left = raw.left
    w.right = raw.right
    const op = MathLocalStore.str(raw.op)
    w.op = op.length > 0 ? op : 'add'
    const qType = MathLocalStore.str(raw.qType)
    w.qType = qType.length > 0 ? qType : 'fill'
    w.story = MathLocalStore.str(raw.story)
    w.answerLabel = MathLocalStore.str(raw.answerLabel)
    w.choiceA = MathLocalStore.str(raw.choiceA)
    w.choiceB = MathLocalStore.str(raw.choiceB)
    w.choiceC = MathLocalStore.str(raw.choiceC)
    w.tag = MathLocalStore.str(raw.tag)
    w.note = MathLocalStore.str(raw.note)
    return w
  }

  private static hydrateCheckIn(raw: DayCheckIn): DayCheckIn {
    const c = new DayCheckIn()
    c.id = MathLocalStore.str(raw.id)
    c.date = MathLocalStore.str(raw.date)
    c.note = MathLocalStore.str(raw.note)
    const source = MathLocalStore.str(raw.source)
    c.source = source.length > 0 ? source : 'auto'
    return c
  }

  private static hydrateExpr(raw: CustomExpr): CustomExpr {
    const e = new CustomExpr()
    e.id = MathLocalStore.str(raw.id)
    e.expression = MathLocalStore.str(raw.expression)
    e.left = raw.left
    e.right = raw.right
    const op = MathLocalStore.str(raw.op)
    e.op = op.length > 0 ? op : 'add'
    e.answer = raw.answer
    return e
  }

  private static hydrateSet(raw: CustomSet): CustomSet {
    const s = new CustomSet()
    s.id = MathLocalStore.str(raw.id)
    s.title = MathLocalStore.str(raw.title)
    s.createdAt = MathLocalStore.str(raw.createdAt)
    const items: CustomExpr[] = []
    if (raw.items !== undefined) {
      for (const it of raw.items) {
        items.push(MathLocalStore.hydrateExpr(it))
      }
    }
    s.items = items
    return s
  }

  private static hydratePack(raw: StudyPack): StudyPack {
    const p = new StudyPack()
    p.id = MathLocalStore.str(raw.id)
    p.title = MathLocalStore.str(raw.title)
    p.modes = MathLocalStore.str(raw.modes)
    p.createdAt = MathLocalStore.str(raw.createdAt)
    return p
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
