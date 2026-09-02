/** 成长手册 — 平台 /biz/growth-handbook Wire 模型（ArkTS strict） */

export class GrowthRecordItemWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  imageKeys: string[] = []
  tags: string[] = []
  recordDate: string = ''
  kind: string = ''
  content: string = ''
  userId: string = ''
  category: string = ''
  color: string = ''
  cardsJson: string = ''
  goal: string = ''
  progress: number = 0
  createdAt: string = ''
  updatedAt: string = ''
}

export class GrowthRecordItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  tags: string[] = []
  recordDate: string = ''
  kind: string = ''
  content: string = ''
  userId: string = ''
  category: string = ''
  color: string = ''
  cardsJson: string = ''
  goal: string = ''
  progress: number = 0
  createdAt: string = ''

  static textOf(v: string | undefined): string {
    if (v === undefined || v === null) {
      return ''
    }
    return v
  }

  static fromWire(w: GrowthRecordItemWire): GrowthRecordItem {
    const item = new GrowthRecordItem()
    if (w === undefined || w === null) {
      return item
    }
    item.id = GrowthRecordItem.textOf(w.id)
    item.title = GrowthRecordItem.textOf(w.title)
    item.subtitle = GrowthRecordItem.textOf(w.subtitle)
    item.summary = GrowthRecordItem.textOf(w.summary)
    item.body = GrowthRecordItem.textOf(w.body)
    item.description = GrowthRecordItem.textOf(w.description)
    const cover = GrowthRecordItem.textOf(w.coverKey)
    const media = GrowthRecordItem.textOf(w.coverMedia)
    if (cover.length > 0) {
      item.coverKey = cover
    } else {
      item.coverKey = media
    }
    if (w.tags !== undefined && w.tags !== null) {
      item.tags = w.tags
    }
    item.recordDate = GrowthRecordItem.textOf(w.recordDate)
    item.kind = GrowthRecordItem.textOf(w.kind)
    item.content = GrowthRecordItem.textOf(w.content)
    item.userId = GrowthRecordItem.textOf(w.userId)
    item.category = GrowthRecordItem.textOf(w.category)
    item.color = GrowthRecordItem.textOf(w.color)
    item.cardsJson = GrowthRecordItem.textOf(w.cardsJson)
    item.goal = GrowthRecordItem.textOf(w.goal)
    if (w.progress !== undefined && w.progress !== null) {
      item.progress = w.progress
    }
    item.createdAt = GrowthRecordItem.textOf(w.createdAt)
    return item
  }
}

export class GrowthListPayload {
  list: GrowthRecordItemWire[] = []
}

export class TagPresetWire {
  id: string = ''
  title: string = ''
  color: string = ''
  category: string = ''
}

export class TagPresetItem {
  id: string = ''
  title: string = ''
  color: string = ''

  static fromWire(w: TagPresetWire): TagPresetItem {
    const item = new TagPresetItem()
    item.id = w.id
    item.title = w.title
    item.color = w.color ?? '#F5C842'
    return item
  }
}

export class TagPresetListPayload {
  list: TagPresetWire[] = []
}

export class TopTagItem {
  tag: string = ''
  count: number = 0
}

export class StatsData {
  recordCount: number = 0
  goalCount: number = 0
  completedGoals: number = 0
  topTags: TopTagItem[] = []
  milestoneCount: number = 0
  streakDays: number = 0
}

export class AnnualReportData {
  recordCount: number = 0
  goalCount: number = 0
  completedGoals: number = 0
  topTags: TopTagItem[] = []
  streakDays: number = 0
  keywords: string[] = []
}

export class SearchResultData {
  records: GrowthRecordItemWire[] = []
  featured: GrowthRecordItemWire[] = []
  query: string = ''
}

export class CreateRecordRequest {
  title: string = ''
  body: string = ''
  summary: string = ''
  tags: string[] = []
  recordDate: string = ''
  coverKey: string = ''
  imageKeys: string[] = []
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"summary":${JSON.stringify(this.summary)},"tags":${JSON.stringify(this.tags)},"recordDate":${JSON.stringify(this.recordDate)},"coverKey":${JSON.stringify(this.coverKey)},"imageKeys":${JSON.stringify(this.imageKeys)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class UpdateRecordRequest {
  title: string = ''
  body: string = ''
  summary: string = ''
  tags: string[] = []
  recordDate: string = ''
  coverKey: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"summary":${JSON.stringify(this.summary)},"tags":${JSON.stringify(this.tags)},"recordDate":${JSON.stringify(this.recordDate)},"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class UnlockAchievementRequest {
  badgeId: string = ''
  title: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"badgeId":${JSON.stringify(this.badgeId)},"title":${JSON.stringify(this.title)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateBoardRequest {
  title: string = ''
  description: string = ''
  coverKey: string = ''
  imageKeys: string[] = []
  cardsJson: string = ''
  body: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"description":${JSON.stringify(this.description)},"coverKey":${JSON.stringify(this.coverKey)},"imageKeys":${JSON.stringify(this.imageKeys)},"cardsJson":${JSON.stringify(this.cardsJson)},"body":${JSON.stringify(this.body)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class GoalStepItem {
  id: string = ''
  title: string = ''
  done: boolean = false

  static parse(raw: string): GoalStepItem[] {
    const out: GoalStepItem[] = []
    if (raw.length === 0) {
      return out
    }
    const parts = raw.split('|')
    let i = 0
    for (const p of parts) {
      if (p.length === 0) {
        continue
      }
      const item = new GoalStepItem()
      item.id = `s${i}`
      i += 1
      const head = p.length >= 2 ? p.substring(0, 2) : ''
      if (head === '1#') {
        item.done = true
        item.title = p.substring(2)
      } else if (head === '0#') {
        item.done = false
        item.title = p.substring(2)
      } else {
        item.title = p
      }
      if (item.title.length > 0) {
        out.push(item)
      }
    }
    return out
  }

  static encode(steps: GoalStepItem[]): string {
    const parts: string[] = []
    for (const s of steps) {
      parts.push(`${s.done ? '1' : '0'}#${s.title}`)
    }
    return parts.join('|')
  }

  static progressOf(steps: GoalStepItem[]): number {
    if (steps.length === 0) {
      return 0
    }
    let done = 0
    for (const s of steps) {
      if (s.done) {
        done += 1
      }
    }
    return Math.round((done * 100) / steps.length)
  }
}

export class CreatePlanRequest {
  title: string = ''
  goal: string = ''
  summary: string = ''
  progress: number = 0
  cardsJson: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"goal":${JSON.stringify(this.goal)},"summary":${JSON.stringify(this.summary)},"progress":${this.progress},"cardsJson":${JSON.stringify(this.cardsJson)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class UpdatePlanRequest {
  title: string = ''
  goal: string = ''
  summary: string = ''
  progress: number = 0
  cardsJson: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"goal":${JSON.stringify(this.goal)},"summary":${JSON.stringify(this.summary)},"progress":${this.progress},"cardsJson":${JSON.stringify(this.cardsJson)}}`
  }
}

export class CreateFavoriteRequest {
  kind: string = ''
  content: string = ''
  title: string = ''
  coverKey: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"kind":${JSON.stringify(this.kind)},"content":${JSON.stringify(this.content)},"title":${JSON.stringify(this.title)},"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateHabitRequest {
  title: string = ''
  category: string = ''
  summary: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"category":${JSON.stringify(this.category)},"summary":${JSON.stringify(this.summary)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CheckinHabitRequest {
  userId: string = ''
  date: string = ''

  toJsonString(): string {
    return `{"userId":${JSON.stringify(this.userId)},"date":${JSON.stringify(this.date)}}`
  }
}

export class CreateReviewRequest {
  title: string = ''
  win: string = ''
  block: string = ''
  nextGoal: string = ''
  thanks: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"win":${JSON.stringify(this.win)},"block":${JSON.stringify(this.block)},"nextGoal":${JSON.stringify(this.nextGoal)},"thanks":${JSON.stringify(this.thanks)},"userId":${JSON.stringify(this.userId)}}`
  }
}

class DeleteOkPayload {
  id: string = ''
}

export class MessageWire {
  id: string = ''
  title: string = ''
  body: string = ''
  createdAt: string = ''
}

export class MessageItem {
  id: string = ''
  title: string = ''
  body: string = ''
  createdAt: string = ''

  static fromWire(w: MessageWire): MessageItem {
    const item = new MessageItem()
    if (w === undefined || w === null) {
      return item
    }
    item.id = w.id ?? ''
    item.title = w.title ?? ''
    item.body = w.body ?? ''
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class MessageListPayload {
  list: MessageWire[] = []
}
