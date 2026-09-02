export class TrainingRecord {
  id: string = ''
  trainingType: string = '跑步'
  recordDate: string = ''
  durationMin: number = 0
  feeling: string = '刚好'
  intensity: string = '中'
  note: string = ''
  harvest: string = ''
  completeStatus: string = '已完成'
  createdAt: string = ''
}

export class TrainingDraft {
  trainingType: string = '跑步'
  recordDate: string = ''
  durationMin: string = '30'
  feeling: string = '刚好'
  intensity: string = '中'
  note: string = ''
  harvest: string = ''
  completeStatus: string = '已完成'
}

export class TypeCount {
  name: string = ''
  count: number = 0
}

export class PlanTask {
  title: string = ''
  done: boolean = false
  seq: number = 0
}

export class TrainPlan {
  id: string = ''
  title: string = ''
  summary: string = ''
  templateKey: string = 'custom'
  tasksPacked: string = ''
  status: string = 'active'
  createdAt: string = ''
}

export class MoveItem {
  id: string = ''
  title: string = ''
  category: string = '热身'
  tips: string = ''
  purpose: string = ''
  combo: string = ''
  favorited: string = '0'
  createdAt: string = ''
}

export class StageGoal {
  id: string = ''
  title: string = ''
  targetCount: number = 20
  currentCount: number = 0
  unit: string = '次'
  syncKind: string = 'sessions'
  createdAt: string = ''
}

export class CheckLine {
  title: string = ''
  done: boolean = false
  seq: number = 0
}

export class CheckState {
  beforePacked: string = ''
  afterPacked: string = ''
}

export class KnowledgeCard {
  id: string = ''
  title: string = ''
  body: string = ''
  tag: string = '动作要点'
  createdAt: string = ''
}

export class MoveDraft {
  title: string = ''
  category: string = '热身'
  tips: string = ''
  purpose: string = ''
  combo: string = ''
}

export class GoalDraft {
  title: string = ''
  targetCount: string = '20'
  unit: string = '次'
  syncKind: string = 'sessions'
}

export class CardDraft {
  title: string = ''
  body: string = ''
  tag: string = '动作要点'
}

export class PlanDraft {
  title: string = ''
  summary: string = ''
}

export class TrainingSummary {
  todayCount: number = 0
  todayDurationMin: number = 0
  totalCount: number = 0
  totalDurationMin: number = 0
  totalDays: number = 0
  streakDays: number = 0
  weekTrend: number[] = []
}

export class HeatmapCell {
  dateKey: string = ''
  level: number = 0
  durationMin: number = 0
}

export class VitalityState {
  points: number = 0
  skinId: string = 'dawn'
  taskDate: string = ''
  warmDone: boolean = false
  trainDone: boolean = false
  noteDone: boolean = false
}

export class StoryBeat {
  title: string = ''
  dateKey: string = ''
  detail: string = ''
}

export class MonthReport {
  sessions: number = 0
  topType: string = '暂无'
  completeRate: number = 0
  minutes: number = 0
}

export class UserProfile {
  nickname: string = '训练者'
  firstUseAt: number = 0
  themeMode: string = 'system'
  featureTourSeen: number = 0
  experiencePackLoaded: number = 0
}

export class AchievementItem {
  id: string = ''
  title: string = ''
  description: string = ''
  emoji: string = ''
  unlocked: boolean = false
  unlockedAt: string = ''
}

export class TrainingFormResult {
  ok: boolean = false
  message: string = ''
  record: TrainingRecord = new TrainingRecord()
}

export class FeedbackPayload {
  quote: string = ''
  newBadge: AchievementItem = new AchievementItem()
  hasNewBadge: boolean = false
}

export class CalendarCell {
  day: number = 0
  dateKey: string = ''
  inMonth: boolean = false
  hasRecord: boolean = false
  dotLevel: number = 0
}

export class FunQuest {
  id: string = ''
  title: string = ''
  theme: string = '随心练'
  sportType: string = '全部'
  targetKind: string = 'sessions'
  targetValue: number = 3
  weekStart: string = ''
  note: string = ''
  status: string = 'active'
  createdAt: string = ''
}

export class FunQuestDraft {
  title: string = ''
  theme: string = '随心练'
  sportType: string = '全部'
  targetKind: string = 'sessions'
  targetValue: string = '3'
  note: string = ''
}

export class FunQuestProgress {
  current: number = 0
  target: number = 0
  percent: number = 0
  done: boolean = false
  unit: string = '次'
}

export class FunQuestFormResult {
  ok: boolean = false
  message: string = ''
  quest: FunQuest = new FunQuest()
}
