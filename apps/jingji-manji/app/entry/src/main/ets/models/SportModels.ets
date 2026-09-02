export class SportRecord {
  id: string = ''
  sportType: string = '跑步'
  recordDate: string = ''
  durationMin: number = 0
  distanceKm: number = 0
  paceMinPerKm: number = 0
  heartRate: number = 0
  calories: number = 0
  tags: string = ''
  note: string = ''
  feeling: string = ''
  weather: string = ''
  takeaway: string = ''
  nextFocus: string = ''
  createdAt: string = ''
}

export class SportDraft {
  sportType: string = '跑步'
  recordDate: string = ''
  durationMin: string = ''
  distanceKm: string = ''
  heartRate: string = ''
  calories: string = ''
  tags: string = ''
  note: string = ''
  feeling: string = '正常'
  weather: string = '室内'
  takeaway: string = ''
  nextFocus: string = ''
}

export class WeekCompare {
  thisWeekSessions: number = 0
  lastWeekSessions: number = 0
  thisWeekDurationMin: number = 0
  lastWeekDurationMin: number = 0
  deltaSessions: number = 0
}

export class PersonalBestItem {
  sportType: string = ''
  metricLabel: string = ''
  metricValue: string = ''
  distanceKm: number = 0
  durationMin: number = 0
  paceMinPerKm: number = 0
  recordDate: string = ''
}

export class SessionCompareHint {
  sportType: string = ''
  deltaDurationMin: number = 0
  deltaDistanceKm: number = 0
  message: string = ''
}

export class SportChallenge {
  id: string = ''
  title: string = ''
  sportType: string = '全部'
  targetSessions: number = 8
  targetDistanceKm: number = 0
  startDate: string = ''
  endDate: string = ''
  note: string = ''
  status: string = 'active'
  createdAt: string = ''
}

export class ChallengeProgress {
  sessions: number = 0
  distanceKm: number = 0
  sessionPct: number = 0
  done: boolean = false
}

export class TypeMixItem {
  sportType: string = ''
  sessions: number = 0
  percent: number = 0
}

export class FeelingStat {
  label: string = ''
  count: number = 0
  percent: number = 0
}

export class MonthlyReportSnapshot {
  monthLabel: string = ''
  sessions: number = 0
  durationMin: number = 0
  distanceKm: number = 0
  topSport: string = ''
  bestDistanceKm: number = 0
  bestDate: string = ''
  avgDurationMin: number = 0
  highlights: string[] = []
}

export class SportSummary {
  monthSessions: number = 0
  monthDurationMin: number = 0
  monthDistanceKm: number = 0
  totalSessions: number = 0
  totalDurationMin: number = 0
  totalDistanceKm: number = 0
  bestDistanceKm: number = 0
  streakDays: number = 0
  monthTrend: number[] = []
  weekTrend: number[] = []
  typeMix: TypeMixItem[] = []
}

export class UserProfile {
  nickname: string = '运动者'
  bio: string = ''
  sportPref: string = '跑步'
  monthlyGoalSessions: number = 12
  useKm: boolean = true
}

export class AchievementItem {
  id: string = ''
  title: string = ''
  description: string = ''
  emoji: string = ''
  unlocked: boolean = false
  unlockedAt: string = ''
}

export class SportFormResult {
  ok: boolean = false
  message: string = ''
  record: SportRecord = new SportRecord()
}

export class FavoriteItem {
  id: string = ''
  targetType: string = 'record'
  targetId: string = ''
  collectionId: string = 'default'
  createdAt: string = ''
}

export class FavoriteCollection {
  id: string = ''
  name: string = '我的收藏'
  createdAt: string = ''
}

export class PlanTask {
  id: string = ''
  sportType: string = '跑步'
  title: string = ''
  targetCount: number = 1
  doneCount: number = 0
  status: string = 'pending'
}

export class TrainingPlan {
  id: string = ''
  title: string = ''
  weekStart: string = ''
  weekEnd: string = ''
  status: string = 'active'
  note: string = ''
  createdAt: string = ''
  tasks: PlanTask[] = []
}

export class TimelineEvent {
  date: string = ''
  eventType: string = 'record'
  title: string = ''
  subtitle: string = ''
  refId: string = ''
}

export class ReviewSnapshot {
  period: string = 'month'
  periodLabel: string = ''
  sessions: number = 0
  durationMin: number = 0
  distanceKm: number = 0
  highlights: string[] = []
}

export class WorkbenchStats {
  todayHasRecord: boolean = false
  todaySessions: number = 0
  totalRecords: number = 0
  favoriteCount: number = 0
  streakDays: number = 0
  activePlanTasksDone: number = 0
  activePlanTasksTotal: number = 0
  planProgressPct: number = 0
}
