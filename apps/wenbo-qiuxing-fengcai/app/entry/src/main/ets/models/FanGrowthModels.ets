/** 球迷成长体系 — 本地数据模型（Preferences，无新权限） */

export class FanDashboardSnapshot {
  watchedCount: number = 0
  planTotal: number = 0
  planProgress: number = 0
  noteCount: number = 0
  browseCount: number = 0
  streakDays: number = 0
  quizBest: number = 0
  quizAttempts: number = 0
  reviewCount: number = 0
  compareSetCount: number = 0
  nextPlanTitle: string = ''
  nextPlanCountdown: string = ''
}

export class TimelineEntry {
  id: string = ''
  kind: string = ''
  title: string = ''
  subtitle: string = ''
  at: number = 0
  refId: string = ''
  refKind: string = ''

  kindLabel(): string {
    if (this.kind === 'browse') {
      return '浏览'
    }
    if (this.kind === 'plan') {
      return '计划'
    }
    if (this.kind === 'note') {
      return '笔记'
    }
    if (this.kind === 'quiz') {
      return '挑战'
    }
    if (this.kind === 'review') {
      return '观赛评'
    }
    if (this.kind === 'achievement') {
      return '成就'
    }
    return '动态'
  }

  timeLabel(): string {
    const d = new Date(this.at)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const h = d.getHours()
    const min = d.getMinutes()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    const hh = h < 10 ? `0${h}` : `${h}`
    const mi = min < 10 ? `0${min}` : `${min}`
    return `${mm}-${dd} ${hh}:${mi}`
  }
}

export class QuizRecord {
  id: string = ''
  score: number = 0
  total: number = 0
  wrongIds: string[] = []
  at: number = 0

  accuracy(): number {
    if (this.total <= 0) {
      return 0
    }
    return this.score / this.total
  }
}

export class QuizStats {
  bestScore: number = 0
  bestTotal: number = 0
  totalAttempts: number = 0
  totalCorrect: number = 0
  totalQuestions: number = 0

  accuracyPercent(): number {
    if (this.totalQuestions <= 0) {
      return 0
    }
    return Math.round((this.totalCorrect / this.totalQuestions) * 100)
  }
}

export class CompareSet {
  id: string = ''
  athleteAId: string = ''
  athleteBId: string = ''
  athleteATitle: string = ''
  athleteBTitle: string = ''
  sport: string = ''
  savedAt: number = 0

  label(): string {
    return `${this.athleteATitle} vs ${this.athleteBTitle}`
  }
}

export class WatchReview {
  id: string = ''
  eventId: string = ''
  eventTitle: string = ''
  athleteName: string = ''
  rating: number = 4
  note: string = ''
  watchedAt: number = 0
}

export class StreakState {
  lastActiveDate: string = ''
  watchStreak: number = 0
  openStreak: number = 0
}

export class AchievementDef {
  id: string = ''
  title: string = ''
  caption: string = ''
  iconName: string = 'star'
}

export class AchievementUnlock {
  id: string = ''
  unlockedAt: number = 0
}

export class WeeklyReviewSnapshot {
  weekKey: string = ''
  watchedCount: number = 0
  notesCount: number = 0
  quizAttempts: number = 0
  browseCount: number = 0
}
