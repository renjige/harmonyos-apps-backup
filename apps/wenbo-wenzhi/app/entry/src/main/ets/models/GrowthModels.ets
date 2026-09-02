/** 问知成长体系 — 时间轴 / 计划 / 成就 / 打卡 */

export class ActivityEvent {
  id: string = ''
  type: string = ''
  title: string = ''
  refId: string = ''
  category: string = ''
  createdAt: number = 0
}

export class StudyTask {
  id: string = ''
  title: string = ''
  sourceType: string = 'custom'
  sourceId: string = ''
  done: boolean = false
  weekKey: string = ''
  createdAt: number = 0
}

export class UserNote {
  id: string = ''
  title: string = ''
  body: string = ''
  category: string = '学习笔记'
  userTag: string = '待了解'
  createdAt: number = 0
  updatedAt: number = 0
}

export class AchievementItem {
  id: string = ''
  title: string = ''
  hint: string = ''
  unlocked: boolean = false
  unlockedAt: number = 0
}

export class CheckinRecord {
  dayKey: string = ''
  note: string = ''
  createdAt: number = 0
}

export class DayCountItem {
  dayKey: string = ''
  label: string = ''
  count: number = 0
}

export class GrowthStats {
  asks: number = 0
  collects: number = 0
  reads: number = 0
  quizzes: number = 0
  cards: number = 0
  notes: number = 0
  streak: number = 0
  todayLearn: number = 0
  dailyGoal: number = 3
}
