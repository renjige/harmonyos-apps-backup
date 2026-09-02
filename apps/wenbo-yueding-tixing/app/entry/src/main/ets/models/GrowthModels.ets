/** 约定提醒 — 成长 / 计划 / 收藏 / 时间轴本地模型 */

export class ActivityLogItem {
  id: string = ''
  /** create | complete | postpone | favorite | checkin | plan_done | delete */
  type: string = ''
  refId: string = ''
  title: string = ''
  summary: string = ''
  scene: string = ''
  occurredAt: string = ''
}

export class CheckInRecord {
  date: string = ''
  done: boolean = false
  note: string = ''
}

export class AchievementDef {
  key: string = ''
  title: string = ''
  description: string = ''
  iconLabel: string = ''
  target: number = 1
}

export class AchievementState {
  key: string = ''
  unlockedAt: string = ''
  progress: number = 0
}

export class CommitmentPlan {
  id: string = ''
  title: string = ''
  description: string = ''
  targetCount: number = 10
  doneCount: number = 0
  scene: string = ''
  startDate: string = ''
  endDate: string = ''
  /** active | done | archived */
  status: string = 'active'
  linkedAppointmentIds: string[] = []
  createdAt: string = ''
  updatedAt: string = ''

  progressPercent(): number {
    if (this.targetCount <= 0) {
      return 0
    }
    const pct = Math.floor((this.doneCount / this.targetCount) * 100)
    return pct > 100 ? 100 : pct
  }

  statusLabel(): string {
    if (this.status === 'done') {
      return '已完成'
    }
    if (this.status === 'archived') {
      return '已归档'
    }
    return '进行中'
  }
}

export class UserCollection {
  id: string = ''
  title: string = ''
  iconKey: string = 'folder'
  color: string = '#1677FF'
  appointmentIds: string[] = []
  sortOrder: number = 0
  createdAt: string = ''
}

export class UserTag {
  id: string = ''
  name: string = ''
  color: string = '#64748B'
}

export class FavoriteTemplate {
  templateId: string = ''
  savedAt: string = ''
}

export class PlanFormDraft {
  id: string = ''
  title: string = ''
  description: string = ''
  targetCount: string = '10'
  scene: string = ''
  startDate: string = ''
  endDate: string = ''
}

export class GrowthSnapshot {
  streakDays: number = 0
  favoriteCount: number = 0
  activePlanCount: number = 0
  todayDone: number = 0
  todayTotal: number = 0
  totalDone: number = 0
  achievementUnlocked: number = 0
  achievementTotal: number = 0
}

export class SearchResultRow {
  kind: string = ''
  id: string = ''
  title: string = ''
  meta: string = ''
}

export class ActivityBundle {
  logs: ActivityLogItem[] = []
}

export class PlanBundle {
  plans: CommitmentPlan[] = []
}

export class CollectionBundle {
  collections: UserCollection[] = []
}

export class TagBundle {
  tags: UserTag[] = []
}

export class CheckInBundle {
  records: CheckInRecord[] = []
}

export class AchievementBundle {
  states: AchievementState[] = []
}

export class FavoriteTemplateBundle {
  items: FavoriteTemplate[] = []
}
