import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { CompareSet } from '../models/FanGrowthModels'

const STORE = 'star_compare_sets'
const MAX = 12

export class CompareSetService {
  private static pref: preferences.Preferences | null = null
  private static items: CompareSet[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      CompareSetService.pref = await preferences.getPreferences(context, STORE)
      const raw = await CompareSetService.pref.get('sets', '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      CompareSetService.items = CompareSetService.parse(text)
    } catch {
      CompareSetService.items = []
    }
  }

  static list(): CompareSet[] {
    const out: CompareSet[] = []
    for (const item of CompareSetService.items) {
      out.push(item)
    }
    return out
  }

  static count(): number {
    return CompareSetService.items.length
  }

  static async save(leftId: string, rightId: string, leftTitle: string, rightTitle: string, sport: string): Promise<boolean> {
    if (leftId.length === 0 || rightId.length === 0 || leftId === rightId) {
      return false
    }
    for (const item of CompareSetService.items) {
      if ((item.athleteAId === leftId && item.athleteBId === rightId) ||
        (item.athleteAId === rightId && item.athleteBId === leftId)) {
        return true
      }
    }
    const row = new CompareSet()
    row.id = `cs_${Date.now()}`
    row.athleteAId = leftId
    row.athleteBId = rightId
    row.athleteATitle = leftTitle
    row.athleteBTitle = rightTitle
    row.sport = sport
    row.savedAt = Date.now()
    const next: CompareSet[] = []
    next.push(row)
    for (const item of CompareSetService.items) {
      next.push(item)
      if (next.length >= MAX) {
        break
      }
    }
    CompareSetService.items = next
    await CompareSetService.persist()
    return true
  }

  static async remove(id: string): Promise<void> {
    const next: CompareSet[] = []
    for (const item of CompareSetService.items) {
      if (item.id !== id) {
        next.push(item)
      }
    }
    CompareSetService.items = next
    await CompareSetService.persist()
  }

  private static async persist(): Promise<void> {
    const payload: CompareSetWire[] = []
    for (const item of CompareSetService.items) {
      const w = new CompareSetWire()
      w.id = item.id
      w.athleteAId = item.athleteAId
      w.athleteBId = item.athleteBId
      w.athleteATitle = item.athleteATitle
      w.athleteBTitle = item.athleteBTitle
      w.sport = item.sport
      w.savedAt = item.savedAt
      payload.push(w)
    }
    try {
      if (CompareSetService.pref !== null) {
        await CompareSetService.pref.put('sets', JSON.stringify(payload))
        await CompareSetService.pref.flush()
      }
    } catch {
    }
    const tick = AppStorage.get<number>('growthTick') ?? 0
    AppStorage.setOrCreate('growthTick', tick + 1)
  }

  private static parse(raw: string): CompareSet[] {
    try {
      const parsed = JSON.parse(raw) as CompareSetWire[]
      const out: CompareSet[] = []
      for (const w of parsed) {
        const s = new CompareSet()
        s.id = w.id
        s.athleteAId = w.athleteAId
        s.athleteBId = w.athleteBId
        s.athleteATitle = w.athleteATitle
        s.athleteBTitle = w.athleteBTitle
        s.sport = w.sport
        s.savedAt = w.savedAt
        out.push(s)
      }
      return out
    } catch {
      return []
    }
  }
}

class CompareSetWire {
  id: string = ''
  athleteAId: string = ''
  athleteBId: string = ''
  athleteATitle: string = ''
  athleteBTitle: string = ''
  sport: string = ''
  savedAt: number = 0
}
