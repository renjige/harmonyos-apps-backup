export class CwDateUtil {
  static todayKey(): string {
    return CwDateUtil.keyFromDate(new Date())
  }

  static keyFromDate(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static parseKey(key: string): Date {
    const parts = key.split('-')
    if (parts.length < 3) {
      return new Date()
    }
    return new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10))
  }

  static displayDate(key: string): string {
    if (key.length === 0) {
      return '未设定'
    }
    const d = CwDateUtil.parseKey(key)
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  }

  static yearFromKey(key: string): string {
    if (key.length >= 4) {
      return key.substring(0, 4)
    }
    return ''
  }

  static daysAgoKey(n: number): string {
    const d = new Date()
    d.setDate(d.getDate() - n)
    return CwDateUtil.keyFromDate(d)
  }

  static yearsAgoKey(n: number): string {
    const d = new Date()
    d.setFullYear(d.getFullYear() - n)
    return CwDateUtil.keyFromDate(d)
  }

  static monthKey(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${y}-${ms}`
  }

  static lastNMonths(n: number): string[] {
    const out: string[] = []
    const cursor = new Date()
    for (let i = 0; i < n; i++) {
      out.push(CwDateUtil.monthKey(cursor))
      cursor.setMonth(cursor.getMonth() - 1)
    }
    return out
  }
}

export class CwGoal {
  id: string = ''
  title: string = ''
  description: string = ''
  categoryKey: string = 'learn'
  progress: number = 0
  startDate: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(title: string, categoryKey: string): CwGoal {
    const g = new CwGoal()
    g.id = `go_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    g.title = title
    g.categoryKey = categoryKey
    g.startDate = CwDateUtil.todayKey()
    g.createdAt = Date.now()
    g.updatedAt = Date.now()
    return g
  }
}

export class CwPlan {
  id: string = ''
  goalId: string = ''
  title: string = ''
  horizonType: string = 'phase'
  startDate: string = ''
  endDate: string = ''
  summary: string = ''
  status: string = 'active'
  createdAt: number = 0

  static createNew(title: string, goalId: string, horizonType: string): CwPlan {
    const p = new CwPlan()
    p.id = `pl_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    p.title = title
    p.goalId = goalId
    p.horizonType = horizonType
    p.startDate = CwDateUtil.todayKey()
    p.createdAt = Date.now()
    return p
  }
}

export class CwPhase {
  id: string = ''
  planId: string = ''
  title: string = ''
  orderIndex: number = 0
  status: string = 'pending'
  targetNote: string = ''

  static createNew(planId: string, title: string, orderIndex: number): CwPhase {
    const ph = new CwPhase()
    ph.id = `ph_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    ph.planId = planId
    ph.title = title
    ph.orderIndex = orderIndex
    return ph
  }
}

export class CwPlanTask {
  id: string = ''
  phaseId: string = ''
  title: string = ''
  done: boolean = false

  static createNew(phaseId: string, title: string): CwPlanTask {
    const t = new CwPlanTask()
    t.id = `tk_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.phaseId = phaseId
    t.title = title
    return t
  }
}

export class CwPhaseReview {
  id: string = ''
  phaseId: string = ''
  harvest: string = ''
  problems: string = ''
  nextSteps: string = ''
  createdAt: number = 0

  static createNew(phaseId: string): CwPhaseReview {
    const r = new CwPhaseReview()
    r.id = `rv_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    r.phaseId = phaseId
    r.createdAt = Date.now()
    return r
  }
}

export class CwHabit {
  id: string = ''
  title: string = ''
  categoryKey: string = 'health'
  streakDays: number = 0
  lastDateKey: string = ''
  createdAt: number = 0

  static createNew(title: string, categoryKey: string): CwHabit {
    const h = new CwHabit()
    h.id = `hb_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    h.title = title
    h.categoryKey = categoryKey
    h.createdAt = Date.now()
    return h
  }
}

export class CwHabitEntry {
  id: string = ''
  habitId: string = ''
  dateKey: string = ''
  note: string = ''
  changeNote: string = ''
  done: boolean = false
  createdAt: number = 0

  static createNew(habitId: string, dateKey: string): CwHabitEntry {
    const e = new CwHabitEntry()
    e.id = `he_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    e.habitId = habitId
    e.dateKey = dateKey
    e.createdAt = Date.now()
    return e
  }
}

export class CwJournalEntry {
  id: string = ''
  dateKey: string = ''
  doneToday: string = ''
  discovery: string = ''
  tomorrowAdjust: string = ''
  createdAt: number = 0

  static createNew(dateKey: string): CwJournalEntry {
    const j = new CwJournalEntry()
    j.id = `jn_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    j.dateKey = dateKey
    j.createdAt = Date.now()
    return j
  }
}

export class CwTimelineRow {
  id: string = ''
  kind: string = ''
  dateKey: string = ''
  title: string = ''
  subtitle: string = ''
  sourceId: string = ''
}

export class CwLookbackItem {
  title: string = ''
  body: string = ''
  dateKey: string = ''
  sourceKind: string = ''
  sourceId: string = ''
}

export class CwOrganizeHint {
  title: string = ''
  body: string = ''
  actionKind: string = ''
  targetId: string = ''
}

export class CwYearArchive {
  year: string = ''
  planCount: number = 0
  goalCount: number = 0
  habitDays: number = 0
  highlightTitle: string = ''
  topCategory: string = ''
}

export class CwStats {
  planCount: number = 0
  goalCount: number = 0
  taskDoneCount: number = 0
  habitCount: number = 0
  streakMax: number = 0
  todayPlanPct: number = 0
  /** 今日进行中计划内的已完成任务数 */
  todayTaskDone: number = 0
  /** 今日进行中计划内的任务总数 */
  todayTaskTotal: number = 0
}

export class CwTaskCountPair {
  done: number = 0
  total: number = 0
}

export class CwProfile {
  nickname: string = '晨雾人'
  themeMode: string = 'system'
}

export class CwGoalCategory {
  key: string = ''
  label: string = ''
  coverKey: string = ''

  static make(key: string, label: string, coverKey: string): CwGoalCategory {
    const c = new CwGoalCategory()
    c.key = key
    c.label = label
    c.coverKey = coverKey
    return c
  }

  static defaults(): CwGoalCategory[] {
    const out: CwGoalCategory[] = []
    out.push(CwGoalCategory.make('learn', '学习成长', 'cover_goal_learn'))
    out.push(CwGoalCategory.make('health', '健康作息', 'cover_goal_health'))
    out.push(CwGoalCategory.make('hobby', '兴趣探索', 'cover_goal_hobby'))
    out.push(CwGoalCategory.make('work', '事业精进', 'cover_goal_work'))
    out.push(CwGoalCategory.make('life', '生活平衡', 'cover_goal_life'))
    return out
  }
}

export class CwPlanTemplate {
  key: string = ''
  title: string = ''
  description: string = ''
  horizonType: string = 'phase'
  phases: string[] = []

  static make(key: string, title: string, description: string, horizonType: string, phases: string[]): CwPlanTemplate {
    const t = new CwPlanTemplate()
    t.key = key
    t.title = title
    t.description = description
    t.horizonType = horizonType
    t.phases = phases
    return t
  }

  static defaults(): CwPlanTemplate[] {
    const out: CwPlanTemplate[] = []
    const yearPhases: string[] = ['愿景梳理', '能力筑基', '阶段冲刺', '年度复盘']
    out.push(CwPlanTemplate.make('year_growth', '年度成长规划', '从愿景到复盘，分四段推进年度目标', 'long', yearPhases))
    const quarterPhases: string[] = ['目标确认', '执行推进', '阶段验收']
    out.push(CwPlanTemplate.make('quarter_sprint', '季度冲刺', '90 天聚焦一个核心目标', 'phase', quarterPhases))
    const monthPhases: string[] = ['习惯设定', '每日打卡', '周末小结']
    out.push(CwPlanTemplate.make('month_habit', '月度习惯养成', '30 天建立可坚持的小习惯', 'short', monthPhases))
    const projectPhases: string[] = ['启动准备', '核心交付', '收尾沉淀']
    out.push(CwPlanTemplate.make('project_milestone', '项目里程碑', '按里程碑拆解可交付成果', 'phase', projectPhases))
    return out
  }
}

export class CwAchievementDef {
  key: string = ''
  title: string = ''
  emojiLabel: string = ''
  thresholdKind: string = ''

  static make(key: string, title: string, emojiLabel: string, thresholdKind: string): CwAchievementDef {
    const a = new CwAchievementDef()
    a.key = key
    a.title = title
    a.emojiLabel = emojiLabel
    a.thresholdKind = thresholdKind
    return a
  }

  static catalog(): CwAchievementDef[] {
    const out: CwAchievementDef[] = []
    out.push(CwAchievementDef.make('first_goal', '立下第一个目标', '清晨启程', 'goal_count'))
    out.push(CwAchievementDef.make('first_plan', '规划已上路', '雾中明路', 'plan_count'))
    out.push(CwAchievementDef.make('tasks_10', '完成十项任务', '步步为营', 'task_done'))
    out.push(CwAchievementDef.make('streak_7', '习惯连续七天', '晨间恒心', 'habit_streak'))
    out.push(CwAchievementDef.make('first_review', '完成阶段复盘', '回望成长', 'review_count'))
    out.push(CwAchievementDef.make('journal_7', '连续晨记七天', '晨雾札记', 'journal_streak'))
    out.push(CwAchievementDef.make('year_file', '年度档案就绪', '年度晨雾', 'year_data'))
    return out
  }
}
