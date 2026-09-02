import { FamilyGoal } from '../models/JujiaModels'
import { JujiaLocalStore } from './JujiaLocalStore'
import { TaskDates } from '../models/FamilyTaskModels'
import { ActivityService } from './ActivityService'

export class GoalService {
  static active(): FamilyGoal[] {
    const out: FamilyGoal[] = []
    for (const row of JujiaLocalStore.goals()) {
      if (row.status === 'active') {
        out.push(row)
      }
    }
    return out
  }

  static async create(title: string, target: number, unit: string): Promise<FamilyGoal> {
    const rows = JujiaLocalStore.goals().slice()
    const g = new FamilyGoal()
    g.id = JujiaLocalStore.newId('goal')
    g.title = title.trim()
    g.targetCount = target > 0 ? target : 10
    g.currentCount = 0
    g.unit = unit.length > 0 ? unit : '项'
    g.status = 'active'
    g.startDate = TaskDates.today()
    g.endDate = TaskDates.addMonths(g.startDate, 1)
    g.createdAt = JujiaLocalStore.nowIso()
    g.updatedAt = g.createdAt
    rows.unshift(g)
    await JujiaLocalStore.saveGoals(rows)
    await ActivityService.log('create', 'goal', g.id, g.title, '新建家庭目标')
    return g
  }

  static async bumpProgress(id: string, delta: number = 1): Promise<void> {
    const rows = JujiaLocalStore.goals().slice()
    for (const g of rows) {
      if (g.id === id && g.status === 'active') {
        g.currentCount += delta
        g.updatedAt = JujiaLocalStore.nowIso()
        if (g.currentCount >= g.targetCount) {
          g.status = 'done'
          await ActivityService.log('complete', 'goal', g.id, g.title, '目标已达成')
        }
        break
      }
    }
    await JujiaLocalStore.saveGoals(rows)
  }

  static async bumpProgressForTask(): Promise<void> {
    for (const g of GoalService.active()) {
      if (g.unit === '项' || g.unit === '计划') {
        await GoalService.bumpProgress(g.id, 1)
      }
    }
  }

  static async remove(id: string): Promise<void> {
    const next: FamilyGoal[] = []
    for (const g of JujiaLocalStore.goals()) {
      if (g.id !== id) {
        next.push(g)
      }
    }
    await JujiaLocalStore.saveGoals(next)
  }
}
