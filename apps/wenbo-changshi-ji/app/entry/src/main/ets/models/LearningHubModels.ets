/** 学习工作台：计划 / 任务 / 时间轴 / 成就 / 专题 / 笔记 */

export class LearningEvent {
  id: string = ''
  type: string = 'read'
  refId: string = ''
  title: string = ''
  summary: string = ''
  createdAt: string = ''
}

export class DailyTaskState {
  dateKey: string = ''
  readDone: boolean = false
  quizDone: boolean = false
  checkInDone: boolean = false
  checklistDone: boolean = false

  doneCount(): number {
    let n = 0
    if (this.readDone) {
      n = n + 1
    }
    if (this.quizDone) {
      n = n + 1
    }
    if (this.checkInDone) {
      n = n + 1
    }
    if (this.checklistDone) {
      n = n + 1
    }
    return n
  }

  progressPercent(): number {
    return Math.round(this.doneCount() * 100 / 4)
  }
}

export class LearningPlan {
  weekKey: string = ''
  targetCount: number = 7
  completedCount: number = 0

  progressPercent(): number {
    if (this.targetCount <= 0) {
      return 0
    }
    const p = this.completedCount / this.targetCount
    return p > 1 ? 100 : Math.round(p * 100)
  }
}

export class AchievementDef {
  key: string = ''
  title: string = ''
  desc: string = ''
  unlocked: boolean = false
  unlockedAt: string = ''
}

export class UserTopic {
  id: string = ''
  title: string = ''
  desc: string = ''
  factIds: string[] = []
  createdAt: string = ''
}

export class UserNote {
  id: string = ''
  title: string = ''
  body: string = ''
  tags: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class WorkbenchSnapshot {
  plan: LearningPlan = new LearningPlan()
  tasks: DailyTaskState = new DailyTaskState()
  readCount: number = 0
  masterCount: number = 0
  favCount: number = 0
  streak: number = 0
  recentEvents: LearningEvent[] = []
  newAchievements: string[] = []
}

export class WeekReviewSummary {
  weekKey: string = ''
  readCount: number = 0
  quizCount: number = 0
  favoriteCount: number = 0
  masterCount: number = 0
  checkInDays: number = 0
  listLearnCount: number = 0
}

export class CategoryStat {
  category: string = ''
  label: string = ''
  count: number = 0
}

export class DayStat {
  label: string = ''
  count: number = 0
}
