export class FavoriteCollection {
  id: string = ''
  title: string = ''
  tag: string = ''
  puzzleIds: string[] = []
  createdAt: string = ''
}

export class PlanGoal {
  weekKey: string = ''
  targetCorrect: number = 15
  targetFamily: number = 1
  note: string = ''
}

export class TimelineEvent {
  id: string = ''
  type: string = ''
  puzzleId: string = ''
  title: string = ''
  subtitle: string = ''
  at: string = ''
}

export class AchievementItem {
  id: string = ''
  title: string = ''
  rule: string = ''
  current: number = 0
  target: number = 1
  unlocked: boolean = false
}

export class TopicPack {
  categoryId: string = ''
  title: string = ''
  weekKey: string = ''
  done: number = 0
  total: number = 0
}

export class WeeklyReview {
  weekKey: string = ''
  correctCount: number = 0
  familyCount: number = 0
  newFavorites: number = 0
  streakDays: number = 0
}

export class CategoryStatItem {
  id: string = ''
  label: string = ''
  done: number = 0
  total: number = 0
}
