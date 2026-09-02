export class CheckIn {
  id: string = ''
  dateKey: string = ''
  journeyId: string = ''
  milestoneId: string = ''
  note: string = ''
  createdAt: number = 0

  static create(journeyId: string): CheckIn {
    const c = new CheckIn()
    c.id = `chk_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    c.journeyId = journeyId
    c.dateKey = CheckIn.todayKey()
    c.createdAt = Date.now()
    return c
  }

  static todayKey(): string {
    const d = new Date()
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }
}

export class PlanTask {
  id: string = ''
  title: string = ''
  done: boolean = false

  static create(title: string): PlanTask {
    const t = new PlanTask()
    t.id = `pt_${Date.now()}_${Math.floor(Math.random() * 1000)}`
    t.title = title
    return t
  }
}

export class JourneyPlan {
  id: string = ''
  journeyId: string = ''
  title: string = ''
  targetCount: number = 10
  doneCount: number = 0
  startDate: string = ''
  endDate: string = ''
  status: string = 'active'
  tasks: PlanTask[] = []
  createdAt: number = 0
  updatedAt: number = 0

  static create(journeyId: string): JourneyPlan {
    const p = new JourneyPlan()
    p.id = `jpl_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    p.journeyId = journeyId
    p.startDate = CheckIn.todayKey()
    const now = Date.now()
    p.createdAt = now
    p.updatedAt = now
    return p
  }

  progressRatio(): number {
    if (this.tasks.length > 0) {
      let done = 0
      for (const t of this.tasks) {
        if (t.done) {
          done++
        }
      }
      return done / this.tasks.length
    }
    if (this.targetCount <= 0) {
      return 0
    }
    return Math.min(1, this.doneCount / this.targetCount)
  }

  progressLabel(): string {
    if (this.tasks.length > 0) {
      let done = 0
      for (const t of this.tasks) {
        if (t.done) {
          done++
        }
      }
      return `任务 ${done}/${this.tasks.length}`
    }
    return `进度 ${this.doneCount}/${this.targetCount}`
  }

  statusLabel(): string {
    if (this.status === 'done') {
      return '已完成'
    }
    if (this.status === 'paused') {
      return '已暂停'
    }
    return '进行中'
  }

  rowKey(): string {
    return `${this.id}_${this.status}_${this.updatedAt}_${this.doneCount}_${this.tasks.length}`
  }
}

export class TimelineEntry {
  id: string = ''
  kind: string = 'record'
  title: string = ''
  subtitle: string = ''
  timestamp: number = 0
  refId: string = ''
  favorite: boolean = false

  kindLabel(): string {
    if (this.kind === 'sport') {
      return '赛事'
    }
    if (this.kind === 'checkin') {
      return '打卡'
    }
    if (this.kind === 'milestone') {
      return '节点'
    }
    if (this.kind === 'insight') {
      return '小结'
    }
    if (this.kind === 'plan') {
      return '计划'
    }
    return '札记'
  }
}

export class AchievementDef {
  id: string = ''
  title: string = ''
  description: string = ''
  emoji: string = ''

  static catalog(): AchievementDef[] {
    const defs: AchievementDef[] = []
    const rows: string[][] = [
      ['first_record', '初踏赛途', '写下第一条札记', '📝'],
      ['records_10', '札记达人', '累计 10 条札记', '📚'],
      ['streak_7', '连续七天', '连续打卡或记录满 7 天', '🔥'],
      ['first_review', '复盘先锋', '完成第一条赛事复盘', '🎯'],
      ['first_plan', '计划先行', '创建并完成一项赛途计划', '📋'],
      ['favorite_5', '珍藏赛途', '收藏 5 条内容', '⭐'],
      ['milestone_5', '节点突破', '达成 5 个赛途节点', '🏁'],
      ['sport_10', '档案策展', '创建 10 条赛事档案', '🏆']
    ]
    for (const r of rows) {
      const d = new AchievementDef()
      d.id = r[0]
      d.title = r[1]
      d.description = r[2]
      d.emoji = r[3]
      defs.push(d)
    }
    return defs
  }
}

export class AchievementUnlock {
  achievementId: string = ''
  unlockedAt: number = 0
}

export class AchievementProgress {
  current: number = 0
  target: number = 1
}

export class TodoItem {
  id: string = ''
  kind: string = ''
  title: string = ''
  subtitle: string = ''
  refId: string = ''
  journeyId: string = ''
}

export class WorkbenchSnapshot {
  nickname: string = '赛途旅人'
  totalRecords: number = 0
  favoriteCount: number = 0
  checkInStreak: number = 0
  recordStreak: number = 0
  milestoneDone: number = 0
  milestoneTotal: number = 0
  sportTotal: number = 0
  achievementUnlocked: number = 0
  achievementTotal: number = 8
  todayCheckedIn: boolean = false
  focusJourneyName: string = ''
  focusJourneyId: string = ''
  focusJourneyColor: string = '#007AFF'
  focusProgress: number = 0
  focusProgressLabel: string = ''
  weekRecordCount: number = 0
  weekSportCount: number = 0
  weekTrainingCount: number = 0
  trainingTotal: number = 0
  todos: TodoItem[] = []
  recentTimeline: TimelineEntry[] = []
}

export class SearchResultItem {
  id: string = ''
  kind: string = 'record'
  title: string = ''
  subtitle: string = ''
  timestamp: number = 0
  favorite: boolean = false
}
