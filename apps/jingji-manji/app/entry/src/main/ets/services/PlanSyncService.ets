import { PlanTask, SportRecord, TrainingPlan } from '../models/SportModels'
import { PlanStore } from './PlanStore'

/** 训练记录保存后，自动计入本周匹配的周计划任务 */
export class PlanSyncService {
  static normalizeSportType(sportType: string): string {
    if (sportType === '力量') {
      return '健身'
    }
    if (sportType === '拉伸') {
      return '其他'
    }
    return sportType
  }

  static sportTypeMatches(taskType: string, recordType: string): boolean {
    const taskNorm = PlanSyncService.normalizeSportType(taskType)
    const recordNorm = PlanSyncService.normalizeSportType(recordType)
    if (taskNorm === recordNorm) {
      return true
    }
    if (taskType === '全部' || taskNorm === '全部') {
      return true
    }
    return false
  }

  static async applyRecord(record: SportRecord): Promise<number> {
    let touched = 0
    for (const plan of PlanStore.active()) {
      if (record.recordDate < plan.weekStart || record.recordDate > plan.weekEnd) {
        continue
      }
      let changed = false
      const nextTasks: PlanTask[] = []
      for (const task of plan.tasks) {
        const t = new PlanTask()
        t.id = task.id
        t.sportType = task.sportType
        t.title = task.title
        t.targetCount = task.targetCount
        t.doneCount = task.doneCount
        t.status = task.status
        if (PlanSyncService.sportTypeMatches(task.sportType, record.sportType) &&
          t.doneCount < t.targetCount) {
          t.doneCount += 1
          if (t.doneCount >= t.targetCount) {
            t.status = 'done'
          }
          changed = true
        }
        nextTasks.push(t)
      }
      if (changed) {
        plan.tasks = nextTasks
        const allDone = PlanSyncService.allTasksDone(nextTasks)
        if (allDone) {
          plan.status = 'done'
        }
        await PlanStore.save(plan)
        touched += 1
      }
    }
    return touched
  }

  private static allTasksDone(tasks: PlanTask[]): boolean {
    if (tasks.length === 0) {
      return false
    }
    for (const t of tasks) {
      if (t.doneCount < t.targetCount) {
        return false
      }
    }
    return true
  }

  static defaultTasks(): PlanTask[] {
    const tasks: PlanTask[] = []
    const specs: string[][] = [
      ['跑步', '跑步训练', '2'],
      ['健身', '力量训练', '1'],
      ['其他', '恢复拉伸', '1']
    ]
    const base = Date.now()
    for (let i = 0; i < specs.length; i++) {
      const t = new PlanTask()
      t.id = `task_${base}_${i}`
      t.sportType = specs[i][0]
      t.title = specs[i][1]
      t.targetCount = parseInt(specs[i][2], 10)
      t.doneCount = 0
      t.status = 'pending'
      tasks.push(t)
    }
    return tasks
  }
}
