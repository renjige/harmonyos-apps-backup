import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { JourneyPlan, PlanTask } from '../models/SaituGrowthModels'
import { SaituRefreshSignals } from './SaituRefreshSignals'

const STORE = 'saitu_zhaji_plan_v1'
const KEY_PLANS = 'plans'

export class SaituPlanStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SaituPlanStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      SaituPlanStore.pref = null
    }
  }

  static async loadPlans(): Promise<JourneyPlan[]> {
    const list = SaituPlanStore.parse(await SaituPlanStore.getString(KEY_PLANS, ''))
    list.sort((a, b) => b.updatedAt - a.updatedAt)
    return list
  }

  static async savePlan(item: JourneyPlan): Promise<void> {
    item.updatedAt = Date.now()
    const list = await SaituPlanStore.loadPlans()
    const next: JourneyPlan[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    await SaituPlanStore.persist(next)
    SaituRefreshSignals.bumpTrackEpoch()
  }

  static async deletePlan(id: string): Promise<void> {
    const list = await SaituPlanStore.loadPlans()
    const next: JourneyPlan[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await SaituPlanStore.persist(next)
    SaituRefreshSignals.bumpTrackEpoch()
  }

  static async findPlan(id: string): Promise<JourneyPlan | undefined> {
    const list = await SaituPlanStore.loadPlans()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async activePlans(): Promise<JourneyPlan[]> {
    const list = await SaituPlanStore.loadPlans()
    const out: JourneyPlan[] = []
    for (const it of list) {
      if (it.status === 'active') {
        out.push(it)
      }
    }
    return out
  }

  static async clearAll(): Promise<void> {
    await SaituPlanStore.putString(KEY_PLANS, '')
  }

  private static async persist(items: JourneyPlan[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      const title = it.title.replace(/\t/g, ' ')
      const taskParts: string[] = []
      for (const t of it.tasks) {
        taskParts.push(`${t.id}|${t.title.replace(/\|/g, ' ')}|${t.done ? '1' : '0'}`)
      }
      lines.push([
        it.id, it.journeyId, title, `${it.targetCount}`, `${it.doneCount}`,
        it.startDate, it.endDate, it.status, taskParts.join(';'),
        `${it.createdAt}`, `${it.updatedAt}`
      ].join('\t'))
    }
    await SaituPlanStore.putString(KEY_PLANS, lines.join('\n'))
  }

  private static parse(raw: string): JourneyPlan[] {
    const out: JourneyPlan[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 11) {
        continue
      }
      const plan = new JourneyPlan()
      plan.id = p[0]
      plan.journeyId = p[1]
      plan.title = p[2]
      plan.targetCount = parseInt(p[3], 10)
      plan.doneCount = parseInt(p[4], 10)
      plan.startDate = p[5]
      plan.endDate = p[6]
      plan.status = p[7]
      plan.tasks = SaituPlanStore.parseTasks(p[8])
      plan.createdAt = parseInt(p[9], 10)
      plan.updatedAt = parseInt(p[10], 10)
      out.push(plan)
    }
    return out
  }

  private static parseTasks(raw: string): PlanTask[] {
    const out: PlanTask[] = []
    if (raw.length === 0) {
      return out
    }
    const parts = raw.split(';')
    for (const part of parts) {
      if (part.length === 0) {
        continue
      }
      const segs = part.split('|')
      if (segs.length < 3) {
        continue
      }
      const t = new PlanTask()
      t.id = segs[0]
      t.title = segs[1]
      t.done = segs[2] === '1'
      out.push(t)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (SaituPlanStore.pref === null) {
      return fallback
    }
    try {
      const v = await SaituPlanStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (SaituPlanStore.pref === null) {
      return
    }
    try {
      await SaituPlanStore.pref.put(key, value)
      await SaituPlanStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
