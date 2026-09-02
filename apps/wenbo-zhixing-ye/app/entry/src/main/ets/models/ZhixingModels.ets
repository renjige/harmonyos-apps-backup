export class KnowledgeItem {
  id: string = ''
  kind: string = 'card'
  title: string = ''
  summary: string = ''
  body: string = ''
  tags: string = ''
  coverKey: string = 'cover_card'
  source: string = ''
  progress: number = 0
  favorite: boolean = false
  createTime: number = 0
  updateTime: number = 0
  lastReadAt: number = 0

  static create(kind: string): KnowledgeItem {
    const it = new KnowledgeItem()
    it.id = `k_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    it.kind = kind
    it.createTime = Date.now()
    it.updateTime = it.createTime
    if (kind === 'note') {
      it.coverKey = 'cover_note'
    } else if (kind === 'digest') {
      it.coverKey = 'cover_read'
    } else {
      it.coverKey = 'cover_card'
    }
    return it
  }

  kindLabel(): string {
    if (this.kind === 'note') {
      return '智慧笔记'
    }
    if (this.kind === 'digest') {
      return '阅读摘要'
    }
    return '知识卡片'
  }

  tagList(): string[] {
    const out: string[] = []
    if (this.tags.trim().length === 0) {
      return out
    }
    const parts = this.tags.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  preview(): string {
    const raw = this.summary.length > 0 ? this.summary : this.body
    const plain = raw.replace(/\n/g, ' ').trim()
    if (plain.length === 0) {
      return '尚未填写摘要'
    }
    return plain.length > 48 ? `${plain.substring(0, 48)}…` : plain
  }

  clone(): KnowledgeItem {
    const it = new KnowledgeItem()
    it.id = this.id
    it.kind = this.kind
    it.title = this.title
    it.summary = this.summary
    it.body = this.body
    it.tags = this.tags
    it.coverKey = this.coverKey
    it.source = this.source
    it.progress = this.progress
    it.favorite = this.favorite
    it.createTime = this.createTime
    it.updateTime = this.updateTime
    it.lastReadAt = this.lastReadAt
    return it
  }
}

export class PlanTask {
  id: string = ''
  title: string = ''
  done: boolean = false

  static create(title: string): PlanTask {
    const t = new PlanTask()
    t.id = `t_${Date.now()}_${Math.floor(Math.random() * 1000)}`
    t.title = title
    return t
  }
}

export class StudyPlan {
  id: string = ''
  title: string = ''
  goal: string = ''
  deadline: string = ''
  progress: number = 0
  status: string = 'active'
  createTime: number = 0
  knowledgeId: string = ''
  tasks: PlanTask[] = []

  static createNew(): StudyPlan {
    const p = new StudyPlan()
    p.id = `p_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    p.createTime = Date.now()
    return p
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

  clone(): StudyPlan {
    const p = new StudyPlan()
    p.id = this.id
    p.title = this.title
    p.goal = this.goal
    p.deadline = this.deadline
    p.progress = this.progress
    p.status = this.status
    p.createTime = this.createTime
    p.knowledgeId = this.knowledgeId
    const nextTasks: PlanTask[] = []
    for (const t of this.tasks) {
      const c = new PlanTask()
      c.id = t.id
      c.title = t.title
      c.done = t.done
      nextTasks.push(c)
    }
    p.tasks = nextTasks
    return p
  }

  syncProgressFromTasks(): void {
    if (this.tasks.length === 0) {
      return
    }
    let done = 0
    for (const t of this.tasks) {
      if (t.done) {
        done++
      }
    }
    this.progress = Math.floor(done * 100 / this.tasks.length)
    if (this.progress >= 100 && this.status === 'active') {
      this.status = 'done'
    }
  }

  taskDoneCount(): number {
    let n = 0
    for (const t of this.tasks) {
      if (t.done) {
        n++
      }
    }
    return n
  }
}

export class StudyHabit {
  id: string = ''
  title: string = ''
  lastCheckDate: string = ''
  totalChecks: number = 0
  streak: number = 0
  createTime: number = 0
  checkDates: string[] = []

  static createNew(): StudyHabit {
    const h = new StudyHabit()
    h.id = `h_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    h.createTime = Date.now()
    return h
  }

  clone(): StudyHabit {
    const h = new StudyHabit()
    h.id = this.id
    h.title = this.title
    h.lastCheckDate = this.lastCheckDate
    h.totalChecks = this.totalChecks
    h.streak = this.streak
    h.createTime = this.createTime
    h.checkDates = []
    for (const d of this.checkDates) {
      h.checkDates.push(d)
    }
    return h
  }

  /** daysAgo=0 表示今天 */
  checkedAgo(daysAgo: number): boolean {
    const today = ActionLog.formatDate(Date.now())
    const todayMs = Date.parse(`${today}T00:00:00`)
    const targetMs = todayMs - daysAgo * 24 * 60 * 60 * 1000
    const key = ActionLog.formatDate(targetMs)
    for (const d of this.checkDates) {
      if (d === key) {
        return true
      }
    }
    if (this.checkDates.length === 0 && this.streak > 0 && this.lastCheckDate.length >= 10) {
      const lastMs = Date.parse(`${this.lastCheckDate}T00:00:00`)
      if (lastMs === lastMs && todayMs === todayMs) {
        const gap = Math.floor((todayMs - lastMs) / (24 * 60 * 60 * 1000))
        const dist = daysAgo - gap
        return dist >= 0 && dist < this.streak
      }
    }
    return false
  }

  weekCheckCount(): number {
    let n = 0
    for (let i = 0; i < 7; i++) {
      if (this.checkedAgo(i)) {
        n++
      }
    }
    return n
  }
}

export class ActionLog {
  id: string = ''
  title: string = ''
  body: string = ''
  dateKey: string = ''
  relatedPlanId: string = ''
  createTime: number = 0

  static createNew(): ActionLog {
    const l = new ActionLog()
    l.id = `l_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    l.createTime = Date.now()
    const d = new Date()
    l.dateKey = ActionLog.formatDate(d.getTime())
    return l
  }

  static formatDate(ms: number): string {
    const d = new Date(ms)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  clone(): ActionLog {
    const l = new ActionLog()
    l.id = this.id
    l.title = this.title
    l.body = this.body
    l.dateKey = this.dateKey
    l.relatedPlanId = this.relatedPlanId
    l.createTime = this.createTime
    return l
  }
}

export class StudyReminder {
  enabled: boolean = false
  hour: number = 21
  minute: number = 0
  agentId: number = 0
}

export class OverviewStats {
  notes: number = 0
  cards: number = 0
  digests: number = 0
  plans: number = 0
  habits: number = 0
  logs: number = 0
  streak: number = 0
  donePlans: number = 0
  favorites: number = 0
}

export class TagNode {
  name: string = ''
  count: number = 0
}

export class RecommendItem {
  id: string = ''
  title: string = ''
  reason: string = ''
  tag: string = ''
  coverKey: string = 'cover_read'
}

export class WeeklyInsight {
  newKnowledge: number = 0
  newLogs: number = 0
  checkedHabitsToday: number = 0
  habitTotal: number = 0
  planRate: number = 0
  staleCount: number = 0
}

export class TimelineEvent {
  dateKey: string = ''
  eventType: string = ''
  refId: string = ''
  title: string = ''
  createTime: number = 0

  typeLabel(): string {
    if (this.eventType === 'create') {
      return '新建知识'
    }
    if (this.eventType === 'check') {
      return '习惯打卡'
    }
    if (this.eventType === 'done') {
      return '计划完成'
    }
    if (this.eventType === 'favorite') {
      return '收藏'
    }
    if (this.eventType === 'log') {
      return '行动日志'
    }
    if (this.eventType === 'task') {
      return '子任务完成'
    }
    if (this.eventType === 'review') {
      return '完成复习'
    }
    if (this.eventType === 'focus') {
      return '专注学习'
    }
    return '学习记录'
  }
}

export class TodayProgress {
  habitDone: number = 0
  habitTotal: number = 0
  taskDone: number = 0
  taskTotal: number = 0

  totalUnits(): number {
    return this.habitTotal + this.taskTotal
  }

  doneUnits(): number {
    return this.habitDone + this.taskDone
  }

  percent(): number {
    const t = this.totalUnits()
    if (t === 0) {
      return 0
    }
    return Math.floor(this.doneUnits() * 100 / t)
  }
}

export class AchievementItem {
  id: string = ''
  title: string = ''
  desc: string = ''
  unlocked: boolean = false
  unlockedAt: number = 0
  progress: number = 0
  target: number = 1
}

export class GrowthStats {
  knowledgeTotal: number = 0
  favoriteTotal: number = 0
  donePlans: number = 0
  maxStreak: number = 0
  logTotal: number = 0
  weekKnowledge: number = 0
  weekLogs: number = 0
  monthChecks: number = 0
}

export class WeeklyGoalProgress {
  targetKnowledge: number = 3
  targetChecks: number = 5
  targetReviews: number = 2
  doneKnowledge: number = 0
  doneChecks: number = 0
  doneReviews: number = 0

  knowledgePercent(): number {
    if (this.targetKnowledge <= 0) {
      return 0
    }
    const v = this.doneKnowledge > this.targetKnowledge ? this.targetKnowledge : this.doneKnowledge
    return Math.floor(v * 100 / this.targetKnowledge)
  }

  checksPercent(): number {
    if (this.targetChecks <= 0) {
      return 0
    }
    const v = this.doneChecks > this.targetChecks ? this.targetChecks : this.doneChecks
    return Math.floor(v * 100 / this.targetChecks)
  }

  reviewsPercent(): number {
    if (this.targetReviews <= 0) {
      return 0
    }
    const v = this.doneReviews > this.targetReviews ? this.targetReviews : this.doneReviews
    return Math.floor(v * 100 / this.targetReviews)
  }

  overallPercent(): number {
    const a = this.knowledgePercent()
    const b = this.checksPercent()
    const c = this.reviewsPercent()
    return Math.floor((a + b + c) / 3)
  }
}

export class PlanTemplate {
  id: string = ''
  title: string = ''
  goal: string = ''
  taskTitles: string[] = []
}
