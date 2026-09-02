import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { ScoutNote } from '../models/StarModels'

const STORE_NAME = 'star_scout_notes'
const KEY_ITEMS = 'notes'
const MAX_ITEMS = 40

/** 球探笔记 — 本地 Preferences，用户自建评分与备注。 */
export class ScoutNoteService {
  private static pref: preferences.Preferences | null = null
  private static items: ScoutNote[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ScoutNoteService.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await ScoutNoteService.pref.get(KEY_ITEMS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      ScoutNoteService.items = ScoutNoteService.parse(text)
    } catch {
      ScoutNoteService.items = []
    }
  }

  static list(): ScoutNote[] {
    const out: ScoutNote[] = []
    for (const item of ScoutNoteService.items) {
      out.push(item)
    }
    return out
  }

  static count(): number {
    return ScoutNoteService.items.length
  }

  static find(athleteId: string): ScoutNote | undefined {
    for (const item of ScoutNoteService.items) {
      if (item.athleteId === athleteId) {
        return item
      }
    }
    return undefined
  }

  static async save(note: ScoutNote): Promise<void> {
    const next: ScoutNote[] = []
    note.updatedAt = Date.now()
    next.push(note)
    for (const item of ScoutNoteService.items) {
      if (item.athleteId !== note.athleteId) {
        next.push(item)
      }
      if (next.length >= MAX_ITEMS) {
        break
      }
    }
    ScoutNoteService.items = next
    await ScoutNoteService.persist()
  }

  static async remove(athleteId: string): Promise<void> {
    const next: ScoutNote[] = []
    for (const item of ScoutNoteService.items) {
      if (item.athleteId !== athleteId) {
        next.push(item)
      }
    }
    ScoutNoteService.items = next
    await ScoutNoteService.persist()
  }

  private static async persist(): Promise<void> {
    const payload: ScoutNoteWire[] = []
    for (const item of ScoutNoteService.items) {
      const w = new ScoutNoteWire()
      w.athleteId = item.athleteId
      w.title = item.title
      w.sport = item.sport
      w.techScore = item.techScore
      w.formScore = item.formScore
      w.note = item.note
      w.updatedAt = item.updatedAt
      payload.push(w)
    }
    try {
      if (ScoutNoteService.pref !== null) {
        await ScoutNoteService.pref.put(KEY_ITEMS, JSON.stringify(payload))
        await ScoutNoteService.pref.flush()
      }
    } catch {
    }
    const tick = AppStorage.get<number>('scoutTick') ?? 0
    AppStorage.setOrCreate('scoutTick', tick + 1)
  }

  private static parse(raw: string): ScoutNote[] {
    try {
      const parsed = JSON.parse(raw) as ScoutNoteWire[]
      const out: ScoutNote[] = []
      for (const row of parsed) {
        const n = new ScoutNote()
        n.athleteId = row.athleteId
        n.title = row.title
        n.sport = row.sport
        n.techScore = row.techScore
        n.formScore = row.formScore
        n.note = row.note
        n.updatedAt = row.updatedAt
        out.push(n)
      }
      return out
    } catch {
      return []
    }
  }
}

class ScoutNoteWire {
  athleteId: string = ''
  title: string = ''
  sport: string = ''
  techScore: number = 3
  formScore: number = 3
  note: string = ''
  updatedAt: number = 0
}
