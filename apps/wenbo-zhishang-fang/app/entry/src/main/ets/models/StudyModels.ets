import { WeekDayStat } from './BookNoteModels'

export class ReadingPlan {
  id: string = ''
  title: string = ''
  bookName: string = ''
  targetCount: number = 10
  doneCount: number = 0
  deadline: number = 0
  status: string = 'active'
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(): ReadingPlan {
    const p = new ReadingPlan()
    p.id = `p_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    p.createdAt = Date.now()
    p.updatedAt = p.createdAt
    p.status = 'active'
    return p
  }

  progressPercent(): number {
    if (this.targetCount <= 0) {
      return 0
    }
    const p = Math.floor((this.doneCount * 100) / this.targetCount)
    return p > 100 ? 100 : p
  }

  isDone(): boolean {
    return this.doneCount >= this.targetCount && this.targetCount > 0
  }
}

export class DailyCheckIn {
  dateKey: string = ''
  checked: boolean = false
  moodNote: string = ''
  excerptCount: number = 0
}

export class TopicShelf {
  id: string = ''
  title: string = ''
  summary: string = ''
  noteIds: string[] = []
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(): TopicShelf {
    const t = new TopicShelf()
    t.id = `t_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.createdAt = Date.now()
    t.updatedAt = t.createdAt
    return t
  }

  noteCount(): number {
    return this.noteIds.length
  }
}

export class AchievementDef {
  id: string = ''
  title: string = ''
  description: string = ''
  emoji: string = ''

  static catalog(): AchievementDef[] {
    const out: AchievementDef[] = []
    const a1 = new AchievementDef()
    a1.id = 'first_note'
    a1.title = '初次摘录'
    a1.description = '写下第一条书摘'
    a1.emoji = '📖'
    out.push(a1)
    const a2 = new AchievementDef()
    a2.id = 'notes_10'
    a2.title = '摘录达人'
    a2.description = '累计 10 条书摘'
    a2.emoji = '✨'
    out.push(a2)
    const a3 = new AchievementDef()
    a3.id = 'notes_50'
    a3.title = '阅读收藏家'
    a3.description = '累计 50 条书摘'
    a3.emoji = '🏆'
    out.push(a3)
    const a4 = new AchievementDef()
    a4.id = 'streak_7'
    a4.title = '连续阅读 7 天'
    a4.description = '连续 7 天打卡或摘录'
    a4.emoji = '🔥'
    out.push(a4)
    const a5 = new AchievementDef()
    a5.id = 'favorite_5'
    a5.title = '金句收藏者'
    a5.description = '收藏 5 条书摘'
    a5.emoji = '💛'
    out.push(a5)
    const a6 = new AchievementDef()
    a6.id = 'recall_10'
    a6.title = '复习能手'
    a6.description = '抽卡回顾累计 10 次'
    a6.emoji = '🧠'
    out.push(a6)
    const a7 = new AchievementDef()
    a7.id = 'plan_done'
    a7.title = '计划达成'
    a7.description = '完成第一个阅读计划'
    a7.emoji = '🎯'
    out.push(a7)
    const a8 = new AchievementDef()
    a8.id = 'topic_1'
    a8.title = '专题策展人'
    a8.description = '创建第一个专题书架'
    a8.emoji = '📚'
    out.push(a8)
    const a9 = new AchievementDef()
    a9.id = 'session_3'
    a9.title = '专注阅读者'
    a9.description = '完成 3 次专注阅读'
    a9.emoji = '⏱'
    out.push(a9)
    const a10 = new AchievementDef()
    a10.id = 'library_5'
    a10.title = '书架主人'
    a10.description = '书架收录 5 本书'
    a10.emoji = '📕'
    out.push(a10)
    return out
  }
}

export class AchievementRecord {
  id: string = ''
  unlockedAt: number = 0
}

export class CategoryStat {
  name: string = ''
  count: number = 0
  percent: number = 0
}

export class BookRankItem {
  bookName: string = ''
  count: number = 0
}

export class StatsSnapshot {
  categoryStats: CategoryStat[] = []
  weekDays: WeekDayStat[] = []
  topBooks: BookRankItem[] = []
  checkInStreak: number = 0
  unlockedAchievements: number = 0
  totalAchievements: number = 0
}

export class TimelineDayGroup {
  dateLabel: string = ''
  items: TimelineDayItem[] = []
}

export class TimelineDayItem {
  id: string = ''
  bookName: string = ''
  excerptPreview: string = ''
  tagLabel: string = ''
}

export class WeeklyRecap {
  weekLabel: string = ''
  newNotes: number = 0
  recallCount: number = 0
  checkInDays: number = 0
  topTag: string = ''
  highlightQuote: string = ''
  highlightBook: string = ''
}

export class WorkbenchSnapshot {
  monthGoalTarget: number = 10
  monthGoalProgress: number = 0
  todayCheckedIn: boolean = false
  checkInStreak: number = 0
  recentNotes: BookNoteRef[] = []
  activePlans: PlanRef[] = []
}

export class BookNoteRef {
  id: string = ''
  bookName: string = ''
  excerptPreview: string = ''
}

export class PlanRef {
  id: string = ''
  title: string = ''
  progressPercent: number = 0
  doneCount: number = 0
  targetCount: number = 0
}

/** 书架实体 — 独立于书摘条目，管理阅读状态与进度 */
export class BookLibraryItem {
  id: string = ''
  title: string = ''
  author: string = ''
  status: string = 'reading'
  coverImage: string = ''
  totalPages: number = 0
  currentPage: number = 0
  memo: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(): BookLibraryItem {
    const b = new BookLibraryItem()
    b.id = `bk_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    b.createdAt = Date.now()
    b.updatedAt = b.createdAt
    b.status = 'reading'
    return b
  }

  progressPercent(): number {
    if (this.totalPages <= 0) {
      return 0
    }
    const p = Math.floor((this.currentPage * 100) / this.totalPages)
    return p > 100 ? 100 : p
  }

  statusLabel(): string {
    if (this.status === 'finished') {
      return '已读完'
    }
    if (this.status === 'wish') {
      return '想读'
    }
    return '在读'
  }
}

/** 专注阅读场次 — 计时结束后记录 */
export class ReadingSession {
  id: string = ''
  bookId: string = ''
  bookTitle: string = ''
  durationMinutes: number = 0
  pagesRead: number = 0
  moodNote: string = ''
  createdAt: number = 0

  static createNew(): ReadingSession {
    const s = new ReadingSession()
    s.id = `rs_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    s.createdAt = Date.now()
    return s
  }
}

export class LibraryShelfSnapshot {
  totalBooks: number = 0
  readingCount: number = 0
  finishedCount: number = 0
  wishCount: number = 0
  totalExcerpts: number = 0
  totalSessionMinutes: number = 0
}

export class ReadingDiagnosisReport {
  readerType: string = ''
  summary: string = ''
  strengths: string[] = []
  suggestions: string[] = []
  featureTips: string[] = []
}
