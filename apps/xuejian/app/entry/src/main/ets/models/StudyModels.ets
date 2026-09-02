export class StudySession {
  id: string = ''
  minutes: number = 0
  plannedMinutes: number = 25
  startedAt: number = 0
  endedAt: number = 0
  completed: boolean = false

  static create(planned: number, minutes: number, completed: boolean): StudySession {
    const s = new StudySession()
    s.id = `ss_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    s.plannedMinutes = planned
    s.minutes = minutes
    s.startedAt = Date.now() - minutes * 60000
    s.endedAt = Date.now()
    s.completed = completed
    return s
  }
}

export class StudyNote {
  id: string = ''
  title: string = ''
  body: string = ''
  tags: string = ''
  coverKey: string = 'hero_desk'
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(): StudyNote {
    const n = new StudyNote()
    n.id = `nt_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    n.createdAt = Date.now()
    n.updatedAt = n.createdAt
    n.coverKey = 'hero_desk'
    return n
  }

  preview(): string {
    const plain = this.body.replace(/\n/g, ' ').trim()
    if (plain.length === 0) {
      return '尚未填写正文'
    }
    return plain.length > 72 ? `${plain.substring(0, 72)}…` : plain
  }

  /** 1.0.2 一键写入遗留的占位笔记 */
  isPlaceholder(): boolean {
    if (this.title !== '学习笔记') {
      return false
    }
    const b = this.body.trim()
    return b.length === 0 || b === '今日学习记录'
  }
}

export class KnowledgeCardItem {
  id: string = ''
  title: string = ''
  body: string = ''
  category: string = '其他'
  mastery: string = 'review'
  coverKey: string = 'texture_paper'
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(): KnowledgeCardItem {
    const c = new KnowledgeCardItem()
    c.id = `kc_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    c.createdAt = Date.now()
    c.updatedAt = c.createdAt
    c.category = '其他'
    c.mastery = 'review'
    c.coverKey = 'texture_paper'
    return c
  }

  isMastered(): boolean {
    return this.mastery === 'mastered'
  }

  /** 1.0.2 一键写入遗留的占位卡片，复习时应跳过或允许删除 */
  isPlaceholder(): boolean {
    if (this.title === '新知识') {
      const b = this.body.trim()
      return b.length === 0 || b === '可在下方补充解释'
    }
    return false
  }

  preview(): string {
    const plain = this.body.replace(/\n/g, ' ').trim()
    if (plain.length === 0) {
      return '尚未填写说明'
    }
    return plain.length > 64 ? `${plain.substring(0, 64)}…` : plain
  }
}

export class StudySettings {
  nickname: string = '学习者'
  dailyGoalMinutes: number = 90
  reminderHour: number = 21
}

export class StudyTask {
  id: string = ''
  title: string = ''
  done: boolean = false
  createdAt: number = 0

  static create(title: string): StudyTask {
    const t = new StudyTask()
    t.id = `tk_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.title = title
    t.done = false
    t.createdAt = Date.now()
    return t
  }
}

export class HeatCell {
  dateKey: string = ''
  minutes: number = 0
  dayLabel: string = ''
}

export class DayStudyLine {
  id: string = ''
  kind: string = ''
  title: string = ''
  subtitle: string = ''
  at: number = 0
}

export class DayStudySummary {
  dateKey: string = ''
  dateLabel: string = ''
  totalMinutes: number = 0
  checkinLine: string = ''
  lines: DayStudyLine[] = []
}

export class WeeklyPlanItem {
  id: string = ''
  title: string = ''
  done: boolean = false

  static create(title: string): WeeklyPlanItem {
    const w = new WeeklyPlanItem()
    w.id = `wp_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    w.title = title
    w.done = false
    return w
  }
}

export class WeeklyPlan {
  weekKey: string = ''
  items: WeeklyPlanItem[] = []
}

export class CatalogItem {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  coverKey: string = ''
  category: string = ''
  tags: string = ''
}

export class CatalogWire {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  category: string = ''
  tags: string = ''
}

export class CatalogListPayload {
  list: CatalogWire[] = []
}

export class CatalogMapper {
  static fromWire(w: CatalogWire): CatalogItem {
    const n = new CatalogItem()
    n.id = w.id
    n.title = w.title
    n.body = w.body.length > 0 ? w.body : (w.description.length > 0 ? w.description : w.summary)
    n.summary = w.summary.length > 0 ? w.summary : n.body
    n.coverKey = w.coverKey.length > 0 ? w.coverKey : w.coverMedia
    n.category = w.category
    n.tags = w.tags
    return n
  }
}

export class MsgWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
  createdAt: string = ''
}

export class MsgListPayload {
  list: MsgWire[] = []
}

export class TimelineItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  timeLabel: string = ''
  kind: string = ''
  at: number = 0
}

export class InsightBundle {
  totalMinutes: number = 0
  studyDays: number = 0
  cardCount: number = 0
  noteCount: number = 0
  streak: number = 0
  advice: string = ''
  peakHint: string = ''
}

export class SlotBar {
  label: string = ''
  value: number = 0
}
