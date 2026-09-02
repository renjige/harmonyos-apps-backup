/** 计划 / 专题 / 收藏匣 / 笺台快照 — ArkTS 严格模式 */

export class PlanTask {
  id: string = ''
  title: string = ''
  done: boolean = false

  static of(id: string, title: string, done: boolean): PlanTask {
    const row = new PlanTask()
    row.id = id
    row.title = title
    row.done = done
    return row
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},"done":${this.done}}`
  }
}

export class PlanItem {
  id: string = ''
  title: string = ''
  cycle: string = 'week'
  startDate: string = ''
  endDate: string = ''
  note: string = ''
  status: string = 'active'
  tasks: PlanTask[] = []

  doneCount(): number {
    let n = 0
    for (const t of this.tasks) {
      if (t.done) {
        n += 1
      }
    }
    return n
  }

  progressPct(): number {
    if (this.tasks.length === 0) {
      return 0
    }
    return Math.floor(this.doneCount() * 100 / this.tasks.length)
  }

  toJsonString(): string {
    let body = ''
    let first = true
    for (const t of this.tasks) {
      if (!first) {
        body += ','
      }
      first = false
      body += t.toJsonString()
    }
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},` +
      `"cycle":${JSON.stringify(this.cycle)},"startDate":${JSON.stringify(this.startDate)},` +
      `"endDate":${JSON.stringify(this.endDate)},"note":${JSON.stringify(this.note)},` +
      `"status":${JSON.stringify(this.status)},"tasks":[${body}]}`
  }
}

export class ThemeTopic {
  id: string = ''
  title: string = ''
  tagName: string = ''
  note: string = ''
  createdAt: string = ''

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},` +
      `"tagName":${JSON.stringify(this.tagName)},"note":${JSON.stringify(this.note)},` +
      `"createdAt":${JSON.stringify(this.createdAt)}}`
  }
}

export class QuoteFolder {
  id: string = ''
  title: string = ''
  itemIds: string[] = []

  has(id: string): boolean {
    for (const x of this.itemIds) {
      if (x === id) {
        return true
      }
    }
    return false
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},` +
      `"itemIds":${JSON.stringify(this.itemIds)}}`
  }
}

export class ActivityEvent {
  id: string = ''
  kind: string = ''
  title: string = ''
  date: string = ''
  refId: string = ''

  static of(id: string, kind: string, title: string, date: string, refId: string): ActivityEvent {
    const row = new ActivityEvent()
    row.id = id
    row.kind = kind
    row.title = title
    row.date = date
    row.refId = refId
    return row
  }
}

export class AchievementBadge {
  id: string = ''
  title: string = ''
  hint: string = ''
  unlocked: boolean = false
  detail: string = ''

  static of(id: string, title: string, hint: string, unlocked: boolean, detail: string): AchievementBadge {
    const row = new AchievementBadge()
    row.id = id
    row.title = title
    row.hint = hint
    row.unlocked = unlocked
    row.detail = detail
    return row
  }
}

export class PeriodReview {
  title: string = ''
  diaryCount: number = 0
  moodCount: number = 0
  habitHits: number = 0
  todoDone: number = 0
  summary: string = ''
}

export class HomeTaskRow {
  id: string = ''
  kind: string = ''
  title: string = ''
  done: boolean = false
  meta: string = ''

  static of(id: string, kind: string, title: string, done: boolean, meta: string): HomeTaskRow {
    const row = new HomeTaskRow()
    row.id = id
    row.kind = kind
    row.title = title
    row.done = done
    row.meta = meta
    return row
  }
}

export class SearchHit {
  id: string = ''
  kind: string = ''
  title: string = ''
  subtitle: string = ''
  refId: string = ''

  static of(id: string, kind: string, title: string, subtitle: string, refId: string): SearchHit {
    const row = new SearchHit()
    row.id = id
    row.kind = kind
    row.title = title
    row.subtitle = subtitle
    row.refId = refId
    return row
  }
}

export class DeskSnapshot {
  moodDone: boolean = false
  moodLabel: string = '尚未记录心情'
  diaryDone: boolean = false
  diaryTitle: string = ''
  coverKey: string = 'hero_morning_coffee'
  habitDone: number = 0
  habitTotal: number = 0
  todoDone: number = 0
  todoTotal: number = 0
  planDone: number = 0
  planTotal: number = 0
  progressPct: number = 0
  progressHint: string = '从心情或写一页开始今天'
  diaryCount: number = 0
  doneCount: number = 0
  favoriteCount: number = 0
  streakDays: number = 0
  unlockedCount: number = 0
  badgeTotal: number = 0
  tasks: HomeTaskRow[] = []
  recentActs: ActivityEvent[] = []
}
