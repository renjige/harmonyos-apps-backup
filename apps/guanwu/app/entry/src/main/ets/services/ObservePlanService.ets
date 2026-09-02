import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { ObserveStore } from './ObserveStore'
import { DateHelper } from './DateHelper'

const STORE = 'guanwu_plan_v1'
const KEY = 'items'

export class PlanItem {
  id: string = ''
  label: string = ''
  done: boolean = false
}

export class ObservePlanService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ObservePlanService.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ObservePlanService.pref = null
    }
  }

  static defaultItems(): PlanItem[] {
    const rows: string[][] = [
      ['p1', '记录一种此刻光线或颜色'],
      ['p2', '写下一句关于环境的观察'],
      ['p3', '为今天的心情选一个词']
    ]
    const out: PlanItem[] = []
    for (const row of rows) {
      const p = new PlanItem()
      p.id = row[0]
      p.label = row[1]
      p.done = false
      out.push(p)
    }
    return out
  }

  static async loadToday(): Promise<PlanItem[]> {
    const today = ObservePlanService.todayKey()
    const raw = await ObservePlanService.getString(KEY, '')
    if (raw.length === 0 || !raw.startsWith(`${today}|`)) {
      return ObservePlanService.defaultItems()
    }
    const body = raw.substring(today.length + 1)
    const out: PlanItem[] = []
    const lines = body.split('\n')
    for (const line of lines) {
      if (line.length === 0) continue
      const parts = line.split('\t')
      if (parts.length < 3) continue
      const p = new PlanItem()
      p.id = parts[0]
      p.label = parts[1]
      p.done = parts[2] === '1'
      out.push(p)
    }
    return out.length > 0 ? out : ObservePlanService.defaultItems()
  }

  static async saveToday(items: PlanItem[]): Promise<void> {
    const today = ObservePlanService.todayKey()
    const lines: string[] = []
    for (const p of items) {
      lines.push(`${p.id}\t${p.label}\t${p.done ? '1' : '0'}`)
    }
    await ObservePlanService.putString(KEY, `${today}|${lines.join('\n')}`)
  }

  static async toggle(id: string): Promise<PlanItem[]> {
    const items = await ObservePlanService.loadToday()
    for (const p of items) {
      if (p.id === id) {
        p.done = !p.done
      }
    }
    await ObservePlanService.saveToday(items)
    return items
  }

  static async syncFromTodayRecords(): Promise<PlanItem[]> {
    const items = await ObservePlanService.loadToday()
    const today = await ObserveStore.notesForDate(DateHelper.todayKey())
    let hasAny = false
    let hasEnv = false
    let hasMood = false
    for (const n of today) {
      hasAny = true
      if (n.kind === 'environment') {
        hasEnv = true
      }
      if (n.kind === 'mood') {
        hasMood = true
      }
    }
    for (const p of items) {
      if (p.id === 'p1' && hasAny) {
        p.done = true
      }
      if (p.id === 'p2' && hasEnv) {
        p.done = true
      }
      if (p.id === 'p3' && hasMood) {
        p.done = true
      }
    }
    await ObservePlanService.saveToday(items)
    return items
  }

  static progressPercent(items: PlanItem[]): number {
    if (items.length === 0) {
      return 0
    }
    let done = 0
    for (const p of items) {
      if (p.done) {
        done++
      }
    }
    return done / items.length
  }

  static doneCount(items: PlanItem[]): number {
    let done = 0
    for (const p of items) {
      if (p.done) {
        done++
      }
    }
    return done
  }

  private static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ObservePlanService.pref === null) return fallback
    try {
      const v = await ObservePlanService.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ObservePlanService.pref === null) return
    try {
      await ObservePlanService.pref.put(key, value)
      await ObservePlanService.pref.flush()
    } catch {
    }
  }
}
