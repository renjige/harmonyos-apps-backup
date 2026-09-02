import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { PlanItem } from './ObservePlanService'

const STORE = 'guanwu_weekly_plan_v1'
const KEY = 'items'

export class ObserveWeeklyPlanService {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ObserveWeeklyPlanService.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ObserveWeeklyPlanService.pref = null
    }
  }

  static defaultItems(): PlanItem[] {
    const rows: string[][] = [
      ['w1', '为 1 件物品建立图鉴条目'],
      ['w2', '同一对象记录 2 次成长变化'],
      ['w3', '完成 3 条探索任务记录'],
      ['w4', '整理本周观察照片到图集']
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

  static weekKey(): string {
    const d = new Date()
    const day = d.getDay()
    const diff = day === 0 ? 6 : day - 1
    const monday = new Date(d)
    monday.setDate(d.getDate() - diff)
    const y = monday.getFullYear()
    const m = monday.getMonth() + 1
    const dd = monday.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = dd < 10 ? `0${dd}` : `${dd}`
    return `${y}-${ms}-${ds}`
  }

  static async loadWeek(): Promise<PlanItem[]> {
    const week = ObserveWeeklyPlanService.weekKey()
    const raw = await ObserveWeeklyPlanService.getString(KEY, '')
    if (raw.length === 0 || !raw.startsWith(`${week}|`)) {
      return ObserveWeeklyPlanService.defaultItems()
    }
    const body = raw.substring(week.length + 1)
    const out: PlanItem[] = []
    for (const line of body.split('\n')) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 3) {
        continue
      }
      const p = new PlanItem()
      p.id = parts[0]
      p.label = parts[1]
      p.done = parts[2] === '1'
      out.push(p)
    }
    return out.length > 0 ? out : ObserveWeeklyPlanService.defaultItems()
  }

  static async saveWeek(items: PlanItem[]): Promise<void> {
    const week = ObserveWeeklyPlanService.weekKey()
    const lines: string[] = []
    for (const p of items) {
      lines.push(`${p.id}\t${p.label}\t${p.done ? '1' : '0'}`)
    }
    await ObserveWeeklyPlanService.putString(KEY, `${week}|${lines.join('\n')}`)
  }

  static async toggle(id: string): Promise<PlanItem[]> {
    const items = await ObserveWeeklyPlanService.loadWeek()
    for (const p of items) {
      if (p.id === id) {
        p.done = !p.done
      }
    }
    await ObserveWeeklyPlanService.saveWeek(items)
    return items
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ObserveWeeklyPlanService.pref === null) {
      return fallback
    }
    try {
      const v = await ObserveWeeklyPlanService.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ObserveWeeklyPlanService.pref === null) {
      return
    }
    try {
      await ObserveWeeklyPlanService.pref.put(key, value)
      await ObserveWeeklyPlanService.pref.flush()
    } catch {
    }
  }
}
