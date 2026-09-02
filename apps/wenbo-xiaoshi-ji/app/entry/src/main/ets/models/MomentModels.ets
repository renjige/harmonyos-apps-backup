/** 小事记本机模型 — 灵感与待办 */

export class TagPreset {
  key: string = ''
  label: string = ''
  color: string = ''

  static all(): TagPreset[] {
    const list: TagPreset[] = []
    const rows: string[][] = [
      ['daily', '日常生活', '#C44A22'],
      ['family', '家庭时光', '#9A5A2A'],
      ['learn', '学习成长', '#3D6A80'],
      ['work', '工作记录', '#0F766E'],
      ['hobby', '兴趣爱好', '#B45309'],
      ['mark', '特别纪念', '#9A3A18']
    ]
    for (const row of rows) {
      const t = new TagPreset()
      t.key = row[0]
      t.label = row[1]
      t.color = row[2]
      list.push(t)
    }
    return list
  }

  static colorOf(label: string): string {
    for (const t of TagPreset.all()) {
      if (t.label === label || t.key === label) {
        return t.color
      }
    }
    return '#C44A22'
  }

  static migrateLabel(label: string): string {
    if (label === '灵感') {
      return '学习成长'
    }
    if (label === '生活' || label === '日常') {
      return '日常生活'
    }
    if (label === '工作') {
      return '工作记录'
    }
    if (label === '小确幸') {
      return '特别纪念'
    }
    return label
  }

  static firstRow(): TagPreset[] {
    const out: TagPreset[] = []
    let n = 0
    for (const t of TagPreset.all()) {
      if (n < 3) {
        out.push(t)
      }
      n++
    }
    return out
  }

  static secondRow(): TagPreset[] {
    const out: TagPreset[] = []
    let n = 0
    for (const t of TagPreset.all()) {
      if (n >= 3) {
        out.push(t)
      }
      n++
    }
    return out
  }
}

export class MomentNote {
  id: string = ''
  content: string = ''
  tags: string[] = []
  dateKey: string = ''
  createdAt: number = 0
  updatedAt: number = 0
  pinned: boolean = false

  static createNew(dateKey: string): MomentNote {
    const n = new MomentNote()
    n.id = `n_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    n.dateKey = dateKey
    n.createdAt = Date.now()
    n.updatedAt = n.createdAt
    return n
  }

  preview(): string {
    const t = this.content.trim()
    if (t.length === 0) {
      return '（空记录）'
    }
    return t.length > 48 ? `${t.substring(0, 48)}…` : t
  }

  stripeColor(): string {
    if (this.tags.length > 0) {
      return TagPreset.colorOf(this.tags[0])
    }
    return '#C44A22'
  }
}

export class MomentTodo {
  id: string = ''
  content: string = ''
  priority: string = 'medium'
  bucket: string = 'today'
  isCompleted: boolean = false
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(): MomentTodo {
    const t = new MomentTodo()
    t.id = `t_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.createdAt = Date.now()
    t.updatedAt = t.createdAt
    return t
  }

  priorityColor(): string {
    if (this.priority === 'high') {
      return '#C44A22'
    }
    if (this.priority === 'low') {
      return '#0F766E'
    }
    return '#B45309'
  }

  priorityLabel(): string {
    if (this.priority === 'high') {
      return '高'
    }
    if (this.priority === 'low') {
      return '低'
    }
    return '中'
  }

  bucketLabel(): string {
    if (this.bucket === 'week') {
      return '本周'
    }
    if (this.bucket === 'later') {
      return '以后'
    }
    return '今日'
  }
}

export class ScenePreset {
  key: string = ''
  label: string = ''
  tag: string = ''
  seed: string = ''

  static all(): ScenePreset[] {
    const list: ScenePreset[] = []
    const rows: string[][] = [
      ['commute', '通勤', '日常生活', '通勤路上：'],
      ['table', '饭桌', '家庭时光', '饭桌上：'],
      ['night', '睡前', '特别纪念', '睡前：']
    ]
    for (const row of rows) {
      const s = new ScenePreset()
      s.key = row[0]
      s.label = row[1]
      s.tag = row[2]
      s.seed = row[3]
      list.push(s)
    }
    return list
  }
}

export class DailyPrompt {
  static today(): string {
    const list: string[] = [
      '今天哪件小事让你觉得还不错？',
      '有一句突然冒出来的灵感吗？',
      '此刻想感谢谁，或记住哪个细节？',
      '工作里有一件可以放下的小事吗？',
      '给明天的自己留一句提醒？',
      '今天的小确幸是什么？',
      '生活里有一个想再看一眼的瞬间吗？'
    ]
    const idx = new Date().getDate() % list.length
    return list[idx]
  }
}

export class WeekSummary {
  noteCount: number = 0
  todoOpen: number = 0
  todoDone: number = 0
  topTag: string = ''
  line: string = ''
}

export class TagStat {
  label: string = ''
  count: number = 0
  color: string = ''
}

export class UserProfile {
  nickname: string = '记小事的人'
  themeMode: string = 'system'
  firstUseAt: number = 0
}

export class MonthCell {
  day: number = 0
  dateKey: string = ''
  inMonth: boolean = false
  hasNote: boolean = false
  slot: number = 0
}

export class MonthShareCard {
  title: string = ''
  body: string = ''
  noteCount: number = 0
  streak: number = 0
}

export class DayActivity {
  dateKey: string = ''
  weekday: string = ''
  noteCount: number = 0
  todoDone: number = 0
}

export class WeeklyReview {
  weekKey: string = ''
  highlight: string = ''
  learned: string = ''
  nextIntent: string = ''
  updatedAt: number = 0
}

export class DailyWrap {
  dateKey: string = ''
  keep: string = ''
  mood: string = ''
  tomorrow: string = ''
  updatedAt: number = 0

  filled(): boolean {
    return this.keep.trim().length > 0 || this.mood.trim().length > 0 || this.tomorrow.trim().length > 0
  }

  preview(): string {
    if (this.keep.trim().length > 0) {
      return this.keep.trim()
    }
    if (this.mood.trim().length > 0) {
      return `心情：${this.mood}`
    }
    return '还没写今日收束'
  }
}

export class WeekCompare {
  thisNotes: number = 0
  lastNotes: number = 0
  thisDone: number = 0
  lastDone: number = 0
  starCount: number = 0
  wrapDone: boolean = false
  line: string = ''
}

export class MilestoneBadge {
  id: string = ''
  title: string = ''
  detail: string = ''
  unlocked: boolean = false
}

export class MoodPreset {
  key: string = ''
  label: string = ''

  static all(): MoodPreset[] {
    const list: MoodPreset[] = []
    const rows: string[] = ['开心', '平静', '充实', '疲惫', '低落', '惊喜']
    for (const label of rows) {
      const m = new MoodPreset()
      m.key = label
      m.label = label
      list.push(m)
    }
    return list
  }

  static firstRow(): MoodPreset[] {
    const out: MoodPreset[] = []
    let n = 0
    for (const m of MoodPreset.all()) {
      if (n < 3) {
        out.push(m)
      }
      n++
    }
    return out
  }

  static secondRow(): MoodPreset[] {
    const out: MoodPreset[] = []
    let n = 0
    for (const m of MoodPreset.all()) {
      if (n >= 3) {
        out.push(m)
      }
      n++
    }
    return out
  }
}

export class MoodDay {
  dateKey: string = ''
  mood: string = ''
  short: string = ''
}

export class CheckinCell {
  dateKey: string = ''
  day: number = 0
  done: boolean = false
}

export class LifeMemorial {
  id: string = ''
  title: string = ''
  dateKey: string = ''
  time: string = '09:00'
  note: string = ''
  enabled: boolean = true
  agentId: number = 0

  static createNew(): LifeMemorial {
    const m = new LifeMemorial()
    m.id = `m_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    m.time = '09:00'
    m.enabled = true
    return m
  }
}

export class ActivityEvent {
  id: string = ''
  type: string = ''
  refId: string = ''
  title: string = ''
  summary: string = ''
  dateKey: string = ''
  createdAt: number = 0

  static create(type: string, refId: string, title: string, summary: string, dateKey: string): ActivityEvent {
    const e = new ActivityEvent()
    e.id = `a_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    e.type = type
    e.refId = refId
    e.title = title
    e.summary = summary
    e.dateKey = dateKey
    e.createdAt = Date.now()
    return e
  }

  typeLabel(): string {
    if (this.type === 'note') {
      return '记下'
    }
    if (this.type === 'todo_done') {
      return '完成'
    }
    if (this.type === 'mood') {
      return '心情'
    }
    if (this.type === 'star') {
      return '星标'
    }
    if (this.type === 'plan_done') {
      return '计划'
    }
    return '动态'
  }
}

export class PlanTask {
  id: string = ''
  text: string = ''
  done: boolean = false

  static create(text: string): PlanTask {
    const t = new PlanTask()
    t.id = `pt_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.text = text
    return t
  }
}

export class LifePlan {
  id: string = ''
  title: string = ''
  description: string = ''
  startDate: string = ''
  endDate: string = ''
  status: string = 'active'
  tasks: PlanTask[] = []
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(): LifePlan {
    const p = new LifePlan()
    p.id = `p_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    p.startDate = new Date().toISOString().slice(0, 10)
    p.createdAt = Date.now()
    p.updatedAt = p.createdAt
    return p
  }

  progress(): number {
    if (this.tasks.length === 0) {
      return 0
    }
    let done = 0
    for (let i = 0; i < this.tasks.length; i++) {
      if (this.tasks[i].done) {
        done++
      }
    }
    return Math.round((done / this.tasks.length) * 100)
  }

  doneCount(): number {
    let n = 0
    for (let i = 0; i < this.tasks.length; i++) {
      if (this.tasks[i].done) {
        n++
      }
    }
    return n
  }
}

export class TopicCollection {
  id: string = ''
  title: string = ''
  coverColor: string = '#C44A22'
  noteIds: string[] = []
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(): TopicCollection {
    const t = new TopicCollection()
    t.id = `tp_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.createdAt = Date.now()
    t.updatedAt = t.createdAt
    return t
  }
}

export class HomeDashboard {
  noteCount: number = 0
  todoDoneToday: number = 0
  todoTotalToday: number = 0
  starCount: number = 0
  streak: number = 0
  todayDone: boolean = false
  todayMood: string = ''
  progressPct: number = 0
}

export class SearchHit {
  kind: string = ''
  refId: string = ''
  title: string = ''
  subtitle: string = ''
}
