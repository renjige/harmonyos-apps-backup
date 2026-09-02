import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { PlanTask, TrainingPlan } from '../models/SportModels'
import { SportRecordService } from './SportRecordService'
import { SportModelClone } from './SportModelClone'

const STORE_NAME = 'sport_plan_v1'
const KEY_PLANS = 'training_plans_json'

export class PlanStore {
  private static pref: preferences.Preferences | null = null
  private static plans: TrainingPlan[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      PlanStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await PlanStore.pref.get(KEY_PLANS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      PlanStore.plans = PlanStore.parsePlans(text)
    } catch {
      PlanStore.plans = []
    }
  }

  static list(): TrainingPlan[] {
    const copy: TrainingPlan[] = []
    for (const plan of PlanStore.plans) {
      copy.push(SportModelClone.plan(plan))
    }
    copy.sort((a: TrainingPlan, b: TrainingPlan) => b.createdAt.localeCompare(a.createdAt))
    return copy
  }

  static active(): TrainingPlan[] {
    const out: TrainingPlan[] = []
    for (const p of PlanStore.list()) {
      if (p.status === 'active') {
        out.push(p)
      }
    }
    return out
  }

  static findById(id: string): TrainingPlan | null {
    for (const p of PlanStore.plans) {
      if (p.id === id) {
        return SportModelClone.plan(p)
      }
    }
    return null
  }

  static async save(plan: TrainingPlan): Promise<void> {
    let found = false
    const next: TrainingPlan[] = []
    for (const p of PlanStore.plans) {
      if (p.id === plan.id) {
        next.push(plan)
        found = true
      } else {
        next.push(p)
      }
    }
    if (!found) {
      next.push(plan)
    }
    PlanStore.plans = next
    await PlanStore.flush()
  }

  static async remove(id: string): Promise<void> {
    const next: TrainingPlan[] = []
    for (const p of PlanStore.plans) {
      if (p.id !== id) {
        next.push(p)
      }
    }
    PlanStore.plans = next
    await PlanStore.flush()
  }

  static progress(plan: TrainingPlan): number {
    let total = 0
    let done = 0
    for (const t of plan.tasks) {
      total += t.targetCount
      done += t.doneCount > t.targetCount ? t.targetCount : t.doneCount
    }
    if (total <= 0) {
      return 0
    }
    return Math.round((done / total) * 100)
  }

  static createDefault(title: string, tasks: PlanTask[]): TrainingPlan {
    const p = new TrainingPlan()
    p.id = `plan_${Date.now()}`
    p.title = title
    p.weekStart = SportRecordService.todayKey()
    p.weekEnd = SportRecordService.addDays(p.weekStart, 6)
    p.status = 'active'
    p.note = ''
    p.createdAt = new Date().toISOString()
    p.tasks = tasks
    return p
  }

  private static async flush(): Promise<void> {
    if (PlanStore.pref === null) {
      return
    }
    await PlanStore.pref.put(KEY_PLANS, JSON.stringify(PlanStore.plans))
    await PlanStore.pref.flush()
  }

  private static parsePlans(text: string): TrainingPlan[] {
    try {
      const arr = JSON.parse(text) as object[]
      const out: TrainingPlan[] = []
      for (const raw of arr) {
        const p = PlanStore.mapPlan(raw)
        if (p.id.length > 0) {
          out.push(p)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static mapPlan(raw: object): TrainingPlan {
    const p = new TrainingPlan()
    const o = raw as Record<string, string | object[]>
    p.id = typeof o['id'] === 'string' ? o['id'] : ''
    p.title = typeof o['title'] === 'string' ? o['title'] : ''
    p.weekStart = typeof o['weekStart'] === 'string' ? o['weekStart'] : ''
    p.weekEnd = typeof o['weekEnd'] === 'string' ? o['weekEnd'] : ''
    p.status = typeof o['status'] === 'string' ? o['status'] : 'active'
    p.note = typeof o['note'] === 'string' ? o['note'] : ''
    p.createdAt = typeof o['createdAt'] === 'string' ? o['createdAt'] : ''
    const tasksRaw = o['tasks']
    if (Array.isArray(tasksRaw)) {
      for (const tr of tasksRaw) {
        const t = PlanStore.mapTask(tr as object)
        if (t.id.length > 0) {
          p.tasks.push(t)
        }
      }
    }
    return p
  }

  private static mapTask(raw: object): PlanTask {
    const t = new PlanTask()
    const o = raw as Record<string, string | number>
    t.id = typeof o['id'] === 'string' ? o['id'] : ''
    t.sportType = typeof o['sportType'] === 'string' ? o['sportType'] : '跑步'
    t.title = typeof o['title'] === 'string' ? o['title'] : ''
    t.targetCount = typeof o['targetCount'] === 'number' ? o['targetCount'] : 1
    t.doneCount = typeof o['doneCount'] === 'number' ? o['doneCount'] : 0
    t.status = typeof o['status'] === 'string' ? o['status'] : 'pending'
    return t
  }
}
