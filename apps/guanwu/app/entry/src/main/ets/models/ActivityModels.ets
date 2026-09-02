export class ActivityEvent {
  id: string = ''
  type: string = ''
  refId: string = ''
  title: string = ''
  summary: string = ''
  dateKey: string = ''
  timestamp: number = 0
}

export class AchievementItem {
  id: string = ''
  title: string = ''
  description: string = ''
  target: number = 1
  progress: number = 0
  unlocked: boolean = false
  unlockedAt: number = 0
}

export class DailyDashboard {
  planDone: number = 0
  planTotal: number = 3
  checkedIn: boolean = false
  progressPercent: number = 0
  totalRecords: number = 0
  favoriteCount: number = 0
  streakDays: number = 0
  todayRecords: number = 0
}
