import { ReadingPlan } from '../models/UserKnowledgeModels'
import { WanXiangLocalStore } from './WanXiangLocalStore'
import { TimelineService } from './TimelineService'

const KEY_PLAN = 'reading_plan_active'

export class PlanStore {
  static async getActivePlan(): Promise<ReadingPlan> {
    const raw = await WanXiangLocalStore.getString(KEY_PLAN, '')
    if (raw.length === 0) {
      const plan = ReadingPlan.createWeekly(WanXiangLocalStore.newId('plan'), 5)
      await PlanStore.save(plan)
      return plan
    }
    const plan = PlanStore.deserialize(raw)
    if (plan === undefined) {
      const fresh = ReadingPlan.createWeekly(WanXiangLocalStore.newId('plan'), 5)
      await PlanStore.save(fresh)
      return fresh
    }
    const today = ReadingPlan.dateKey(new Date())
    if (today > plan.endDate && plan.status === 'active') {
      plan.status = 'done'
      await PlanStore.save(plan)
      const next = ReadingPlan.createWeekly(WanXiangLocalStore.newId('plan'), 5)
      await PlanStore.save(next)
      return next
    }
    return plan
  }

  static async markRead(infoId: string): Promise<ReadingPlan> {
    const plan = await PlanStore.getActivePlan()
    const ids = plan.completedIds.length > 0 ? plan.completedIds.split(',') : []
    if (ids.indexOf(infoId) < 0) {
      ids.push(infoId)
      plan.completedIds = ids.join(',')
      if (plan.completedCount() >= plan.targetCount) {
        plan.status = 'done'
        await TimelineService.log('plan_done', '完成本周阅读计划', plan.id)
      }
      await PlanStore.save(plan)
    }
    return plan
  }

  static async save(plan: ReadingPlan): Promise<void> {
    await WanXiangLocalStore.putString(KEY_PLAN, PlanStore.serialize(plan))
  }

  private static serialize(plan: ReadingPlan): string {
    return [
      plan.id, plan.title, `${plan.targetCount}`, plan.startDate, plan.endDate,
      plan.completedIds, plan.status
    ].join('|')
  }

  private static deserialize(raw: string): ReadingPlan | undefined {
    const parts = raw.split('|')
    if (parts.length < 7) {
      return undefined
    }
    const p = new ReadingPlan()
    p.id = parts[0]
    p.title = parts[1]
    p.targetCount = parseInt(parts[2], 10)
    p.startDate = parts[3]
    p.endDate = parts[4]
    p.completedIds = parts[5]
    p.status = parts[6]
    return p
  }
}
