/** 本地创作计划 / 打卡 / 成就 — Preferences 持久化模型 */

export class CraftPlanTask {
  id: string = ''
  title: string = ''
  done: boolean = false
  sourceGuideId: string = ''
}

export class CraftPlan {
  id: string = ''
  title: string = ''
  category: string = '综合'
  targetCount: number = 1
  dueDate: string = ''
  status: string = 'active'
  tasks: CraftPlanTask[] = []

  completedCount(): number {
    let n = 0
    for (const t of this.tasks) {
      if (t.done) {
        n += 1
      }
    }
    return n
  }

  progressPercent(): number {
    if (this.tasks.length === 0) {
      return 0
    }
    return Math.floor(this.completedCount() * 100 / this.tasks.length)
  }
}

export class CraftCheckIn {
  date: string = ''
  note: string = ''
  durationSec: number = 0
}

export class CraftTimelineEvent {
  id: string = ''
  kind: string = ''
  title: string = ''
  at: string = ''
  refId: string = ''
}

export class CraftAchievement {
  id: string = ''
  title: string = ''
  summary: string = ''
  unlocked: boolean = false
}

export class CraftDashboardStats {
  workCount: number = 0
  inspirationCount: number = 0
  favoriteCount: number = 0
  streakDays: number = 0
  planDone: number = 0
  planTotal: number = 0
  todayCheckedIn: boolean = false
}

export class CraftLastGuide {
  guideId: string = ''
  title: string = ''
}
