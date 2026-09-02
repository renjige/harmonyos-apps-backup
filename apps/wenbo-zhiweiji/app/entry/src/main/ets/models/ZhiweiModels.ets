export class CaptureItem {
  id: string = ''
  title: string = ''
  body: string = ''
  category: string = 'life_wiki'
  customTag: string = ''
  learnTag: string = 'todo'
  priority: string = 'mid'
  source: string = 'type'
  status: string = 'inbox'
  imageUri: string = ''
  collectionId: string = ''
  favored: boolean = false
  nextReviewAt: number = 0
  nextAction: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}

export class InsightDigest {
  id: string = ''
  period: string = 'day'
  dateKey: string = ''
  summary: string = ''
  keywordCsv: string = ''
  workCount: number = 0
  lifeCount: number = 0
  studyCount: number = 0
  sparkCount: number = 0
  captureCount: number = 0
  generatedAt: number = 0
}

export class QuoteCard {
  id: string = ''
  text: string = ''
  author: string = ''
  theme: string = ''
  coverKey: string = 'cover_spark'
}

export class ZhiweiSettings {
  darkMode: boolean = false
  nickname: string = ''
  lastLearnDate: string = ''
  learnDays: number = 0
  readDailyId: string = ''
  dailyGoalCount: number = 1
  weeklyDigestGoal: number = 3
  unlockedAchIds: string[] = []
  completedPathStepIds: string[] = []
  tourDone: boolean = false
}

export class LearnPlan {
  id: string = ''
  title: string = ''
  period: string = 'week'
  targetCount: number = 5
  metric: string = 'digest_done'
  startDate: string = ''
  endDate: string = ''
  status: string = 'active'
  createdAt: number = 0
}

export class TimelineEvent {
  id: string = ''
  type: string = 'capture'
  refId: string = ''
  title: string = ''
  subtitle: string = ''
  ts: number = 0
}

export class TodayProgress {
  goalCount: number = 1
  captureToday: number = 0
  dailyRead: boolean = false
  digestDoneToday: number = 0
  inboxCount: number = 0
  percent: number = 0
  hint: string = ''
}

export class AchievementItem {
  id: string = ''
  title: string = ''
  desc: string = ''
  unlocked: boolean = false
  unlockedAt: number = 0
}

export class ReviewSummary {
  period: string = 'week'
  title: string = ''
  summary: string = ''
  captureCount: number = 0
  digestCount: number = 0
  favCount: number = 0
  highlights: string[] = []
}

export class KnowledgeFolder {
  id: string = ''
  name: string = ''
  createdAt: number = 0
}

export class DailyKnowItem {
  id: string = ''
  title: string = ''
  body: string = ''
  category: string = 'life_wiki'
  coverKey: string = 'cover_life'
}

export class ZhiweiBundle {
  captures: CaptureItem[] = []
  digests: InsightDigest[] = []
  favoriteQuoteIds: string[] = []
  folders: KnowledgeFolder[] = []
  plans: LearnPlan[] = []
  settings: ZhiweiSettings = new ZhiweiSettings()
}

export class CategoryCount {
  id: string = ''
  name: string = ''
  count: number = 0
}

export class CaptureStats {
  total: number = 0
  streak: number = 0
  workCount: number = 0
  lifeCount: number = 0
  studyCount: number = 0
  sparkCount: number = 0
  favCount: number = 0
  folderCount: number = 0
  learnDays: number = 0
  masteredCount: number = 0
  digestDoneCount: number = 0
  cats: CategoryCount[] = []
}

export class KeywordHit {
  word: string = ''
  count: number = 0
}

export class DayChip {
  dateKey: string = ''
  label: string = ''
  count: number = 0
}
