import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { PlayRecord, ProgressState } from '../models/JigsawModels'
import { JigsawNav } from './JigsawNav'

const STORE = 'qinzi_lepin_progress'
const KEY = 'state'

export class ProgressStore {
  private static pref: preferences.Preferences | null = null
  private static cache: ProgressState = new ProgressState()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ProgressStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await ProgressStore.pref.get(KEY, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      ProgressStore.cache = ProgressStore.parse(raw)
    } catch {
      ProgressStore.cache = new ProgressState()
    }
    ProgressStore.publish()
  }

  static snapshot(): ProgressState {
    return ProgressStore.cache
  }

  static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  static greeting(): string {
    const h = new Date().getHours()
    if (h < 11) {
      return '早上好，今天想拼哪一幅？'
    }
    if (h < 17) {
      return '下午好，拖一块，拼一幅'
    }
    return '晚上好，慢慢拼完就很好'
  }

  static soundOn(): boolean {
    return ProgressStore.cache.soundOn
  }

  static defaultPieces(): number {
    const n = ProgressStore.cache.defaultPieces
    if (n === 9 || n === 16) {
      return n
    }
    return 4
  }

  static async setSound(on: boolean): Promise<void> {
    ProgressStore.cache.soundOn = on
    await ProgressStore.flush()
  }

  static async setDefaultPieces(n: number): Promise<void> {
    ProgressStore.cache.defaultPieces = n
    await ProgressStore.flush()
  }

  static async resetLocal(): Promise<void> {
    const sound = ProgressStore.cache.soundOn
    const pieces = ProgressStore.cache.defaultPieces
    ProgressStore.cache = new ProgressState()
    ProgressStore.cache.soundOn = sound
    ProgressStore.cache.defaultPieces = pieces
    await ProgressStore.flush()
  }

  static isMedalOn(id: string): boolean {
    return ProgressStore.cache.medalIds.indexOf(id) >= 0
  }

  static async recordComplete(
    jigsawId: string,
    title: string,
    themeLabel: string,
    pieces: number,
    stars: number,
    durationMs: number,
    hintsUsed: number,
    collab: boolean,
    coverKey: string
  ): Promise<void> {
    const today = ProgressStore.todayKey()
    if (ProgressStore.cache.lastDate !== today) {
      if (ProgressStore.isYesterday(ProgressStore.cache.lastDate, today)) {
        ProgressStore.cache.streak = ProgressStore.cache.streak + 1
      } else {
        ProgressStore.cache.streak = 1
      }
      ProgressStore.cache.lastDate = today
    }
    if (ProgressStore.cache.completedIds.indexOf(jigsawId) < 0) {
      ProgressStore.cache.completedIds.push(jigsawId)
    }
    ProgressStore.cache.totalStars = ProgressStore.cache.totalStars + stars
    if (hintsUsed === 0) {
      ProgressStore.cache.noHintCount = ProgressStore.cache.noHintCount + 1
    } else {
      ProgressStore.cache.hintUsedCount = ProgressStore.cache.hintUsedCount + 1
    }
    if (pieces === 16) {
      ProgressStore.cache.pieces16Count = ProgressStore.cache.pieces16Count + 1
    }
    if (collab) {
      ProgressStore.cache.collabCount = ProgressStore.cache.collabCount + 1
    }
    const rec = new PlayRecord()
    rec.id = `${Date.now()}`
    rec.jigsawId = jigsawId
    rec.title = title
    rec.themeLabel = themeLabel
    rec.pieces = pieces
    rec.stars = stars
    rec.durationMs = durationMs
    rec.hintsUsed = hintsUsed
    rec.collab = collab
    rec.coverKey = coverKey
    rec.at = today
    const records: PlayRecord[] = []
    records.push(rec)
    let n = 0
    for (const old of ProgressStore.cache.records) {
      if (n >= 39) {
        break
      }
      records.push(old)
      n++
    }
    ProgressStore.cache.records = records
    ProgressStore.refreshMedals()
    await ProgressStore.flush()
  }

  static observeScore(): number {
    const v = ProgressStore.cache.noHintCount * 20
    return v > 100 ? 100 : v
  }

  static logicScore(): number {
    const v = ProgressStore.cache.pieces16Count * 25
    return v > 100 ? 100 : v
  }

  static focusScore(): number {
    const v = ProgressStore.cache.completedIds.length * 12
    return v > 100 ? 100 : v
  }

  static coordScore(): number {
    const v = ProgressStore.cache.collabCount * 30 + ProgressStore.cache.completedIds.length * 8
    return v > 100 ? 100 : v
  }

  private static refreshMedals(): void {
    const ids: string[] = []
    if (ProgressStore.cache.completedIds.length >= 1) {
      ids.push('kj_medal_first')
    }
    if (ProgressStore.cache.collabCount >= 1) {
      ids.push('kj_medal_together')
    }
    if (ProgressStore.cache.noHintCount >= 3) {
      ids.push('kj_medal_observe')
    }
    if (ProgressStore.cache.completedIds.length >= 8) {
      ids.push('kj_medal_focus')
    }
    if (ProgressStore.cache.pieces16Count >= 1) {
      ids.push('kj_medal_challenge')
    }
    if (ProgressStore.cache.hintUsedCount >= 1) {
      ids.push('kj_medal_helper')
    }
    ProgressStore.cache.medalIds = ids
  }

  private static isYesterday(last: string, today: string): boolean {
    if (last.length === 0) {
      return false
    }
    const t = Date.parse(`${today}T00:00:00`)
    const l = Date.parse(`${last}T00:00:00`)
    if (Number.isNaN(t) || Number.isNaN(l)) {
      return false
    }
    return t - l === 24 * 60 * 60 * 1000
  }

  private static parse(raw: string): ProgressState {
    const state = new ProgressState()
    if (raw.length === 0) {
      return state
    }
    try {
      const obj = JSON.parse(raw) as ProgressState
      if (obj.completedIds !== undefined) {
        state.completedIds = obj.completedIds
      }
      if (obj.lastDate !== undefined) {
        state.lastDate = obj.lastDate
      }
      state.streak = obj.streak ?? 0
      state.totalStars = obj.totalStars ?? 0
      state.noHintCount = obj.noHintCount ?? 0
      state.pieces16Count = obj.pieces16Count ?? 0
      state.collabCount = obj.collabCount ?? 0
      state.hintUsedCount = obj.hintUsedCount ?? 0
      if (obj.records !== undefined) {
        state.records = obj.records
      }
      if (obj.medalIds !== undefined) {
        state.medalIds = obj.medalIds
      }
      state.soundOn = obj.soundOn !== false
      state.defaultPieces = obj.defaultPieces ?? 4
    } catch {
      return new ProgressState()
    }
    return state
  }

  private static async flush(): Promise<void> {
    ProgressStore.publish()
    if (ProgressStore.pref === null) {
      return
    }
    try {
      await ProgressStore.pref.put(KEY, JSON.stringify(ProgressStore.cache))
      await ProgressStore.pref.flush()
    } catch {
      return
    }
  }

  private static publish(): void {
    AppStorage.setOrCreate('doneCount', ProgressStore.cache.completedIds.length)
    AppStorage.setOrCreate('starCount', ProgressStore.cache.totalStars)
    AppStorage.setOrCreate('streakDays', ProgressStore.cache.streak)
    JigsawNav.bump()
  }
}
