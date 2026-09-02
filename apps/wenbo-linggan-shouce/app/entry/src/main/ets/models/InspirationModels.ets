/** 灵感手册 — 平台 /biz/inspiration-handbook Wire 模型（ArkTS strict） */

export class InspirationItemWire {
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
  milestonesJson: string = ''
  linkedIdsJson: string = ''
  startDate: string = ''
  endDate: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class InspirationItem {
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
  imageKeys: string[] = []
  goal: string = ''
  progress: number = 0
  milestonesJson: string = ''
  linkedIdsJson: string = ''
  startDate: string = ''
  endDate: string = ''
  createdAt: string = ''

  static fromWire(w: InspirationItemWire): InspirationItem {
    const item = new InspirationItem()
    item.id = InspirationItem.pickStr(w.id)
    item.title = InspirationItem.pickStr(w.title)
    item.subtitle = InspirationItem.pickStr(w.subtitle)
    item.summary = InspirationItem.pickStr(w.summary)
    item.body = InspirationItem.pickStr(w.body)
    item.description = InspirationItem.pickStr(w.description)
    const coverKey = InspirationItem.pickStr(w.coverKey)
    const coverMedia = InspirationItem.pickStr(w.coverMedia)
    if (coverKey.length > 0) {
      item.coverKey = coverKey
    } else if (coverMedia.length > 0) {
      item.coverKey = coverMedia
    }
    item.tags = w.tags !== undefined && w.tags !== null ? w.tags : []
    item.recordDate = InspirationItem.pickStr(w.recordDate)
    item.kind = InspirationItem.pickStr(w.kind)
    item.content = InspirationItem.pickStr(w.content)
    item.userId = InspirationItem.pickStr(w.userId)
    item.category = InspirationItem.pickStr(w.category)
    item.color = InspirationItem.pickStr(w.color)
    item.cardsJson = InspirationItem.pickStr(w.cardsJson)
    item.imageKeys = w.imageKeys !== undefined && w.imageKeys !== null ? w.imageKeys : []
    item.goal = InspirationItem.pickStr(w.goal)
    item.progress = w.progress !== undefined && w.progress !== null ? w.progress : 0
    item.milestonesJson = InspirationItem.pickStr(w.milestonesJson)
    item.linkedIdsJson = InspirationItem.pickStr(w.linkedIdsJson)
    item.startDate = InspirationItem.pickStr(w.startDate)
    item.endDate = InspirationItem.pickStr(w.endDate)
    item.createdAt = InspirationItem.pickStr(w.createdAt)
    return item
  }

  static displayTitle(item: InspirationItem): string {
    if (item.title.length > 0) {
      return item.title
    }
    if (item.goal.length > 0) {
      return item.goal
    }
    if (item.summary.length > 0) {
      return item.summary
    }
    if (item.description.length > 0) {
      return item.description
    }
    return '未命名'
  }

  static pickStr(v: string | undefined): string {
    if (v === undefined || v === null) {
      return ''
    }
    return v
  }
}

export class InspirationListPayload {
  list: InspirationItemWire[] = []
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
  inspirationCount: number = 0
  favoriteCount: number = 0
  topTags: TopTagItem[] = []
  boardCount: number = 0
  planCount: number = 0
}

export class SearchResultData {
  inspirations: InspirationItemWire[] = []
  featured: InspirationItemWire[] = []
  boards: InspirationItemWire[] = []
  plans: InspirationItemWire[] = []
  favorites: InspirationItemWire[] = []
  topics: InspirationItemWire[] = []
  query: string = ''
}

export class TimelineEventWire {
  date: string = ''
  kind: string = ''
  title: string = ''
  entityId: string = ''
  summary: string = ''
}

export class TimelineEvent {
  date: string = ''
  kind: string = ''
  title: string = ''
  entityId: string = ''
  summary: string = ''

  static fromWire(w: TimelineEventWire): TimelineEvent {
    const e = new TimelineEvent()
    e.date = w.date
    e.kind = w.kind
    e.title = w.title
    e.entityId = w.entityId
    e.summary = w.summary
    return e
  }
}

export class TimelineListPayload {
  list: TimelineEventWire[] = []
}

export class LinkedRef {
  kind: string = ''
  id: string = ''
}

export class LinkedRefList {
  static encode(items: LinkedRef[]): string {
    const parts: string[] = []
    for (const r of items) {
      parts.push(`{"kind":${JSON.stringify(r.kind)},"id":${JSON.stringify(r.id)}}`)
    }
    return `[${parts.join(',')}]`
  }

  static parse(raw: string): LinkedRef[] {
    const out: LinkedRef[] = []
    if (raw.length === 0 || raw === '[]') {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as LinkedRef[]
      for (const w of parsed) {
        const r = new LinkedRef()
        r.kind = w.kind !== undefined ? w.kind : ''
        r.id = w.id !== undefined ? w.id : ''
        if (r.kind.length > 0 && r.id.length > 0) {
          out.push(r)
        }
      }
    } catch {
    }
    return out
  }

  static has(refs: LinkedRef[], kind: string, id: string): boolean {
    for (const r of refs) {
      if (r.kind === kind && r.id === id) {
        return true
      }
    }
    return false
  }

  static add(raw: string, kind: string, id: string): string {
    const refs = LinkedRefList.parse(raw)
    if (LinkedRefList.has(refs, kind, id)) {
      return raw
    }
    const r = new LinkedRef()
    r.kind = kind
    r.id = id
    refs.push(r)
    return LinkedRefList.encode(refs)
  }

  static remove(raw: string, kind: string, id: string): string {
    const refs = LinkedRefList.parse(raw)
    const kept: LinkedRef[] = []
    for (const r of refs) {
      if (!(r.kind === kind && r.id === id)) {
        kept.push(r)
      }
    }
    return LinkedRefList.encode(kept)
  }

  static kindLabel(kind: string): string {
    if (kind === 'inspiration') {
      return '灵感'
    }
    if (kind === 'board') {
      return '画板'
    }
    if (kind === 'plan') {
      return '计划'
    }
    if (kind === 'topic') {
      return '专题'
    }
    return '内容'
  }
}

export class WeekReviewData {
  weekLabel: string = ''
  inspirationCount: number = 0
  boardCount: number = 0
  checkInCount: number = 0
  completedMilestones: number = 0
  inspirations: InspirationItem[] = []
  highlights: string[] = []
  reflection: string = ''
}

export class Milestone {
  id: string = ''
  title: string = ''
  done: boolean = false
}

export class MilestoneList {
  static encode(items: Milestone[]): string {
    const parts: string[] = []
    for (const m of items) {
      parts.push(
        `{"id":${JSON.stringify(m.id)},"title":${JSON.stringify(m.title)},"done":${m.done}}`
      )
    }
    return `[${parts.join(',')}]`
  }

  static parse(raw: string): Milestone[] {
    const out: Milestone[] = []
    if (raw.length === 0 || raw === '[]') {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as Milestone[]
      for (const w of parsed) {
        const m = new Milestone()
        m.id = w.id !== undefined ? w.id : `ms_${out.length}`
        m.title = w.title !== undefined ? w.title : ''
        m.done = w.done === true
        out.push(m)
      }
    } catch {
    }
    return out
  }

  static progressPercent(items: Milestone[]): number {
    if (items.length === 0) {
      return 0
    }
    let done = 0
    for (const m of items) {
      if (m.done) {
        done += 1
      }
    }
    return Math.round((done / items.length) * 100)
  }

  static defaultForPlan(title: string): Milestone[] {
    const items: Milestone[] = []
    const steps = ['明确目标与受众', '收集参考与画板', '产出初稿', '复盘并归档']
    for (let i = 0; i < steps.length; i++) {
      const m = new Milestone()
      m.id = `ms_${i + 1}`
      m.title = `${title} · ${steps[i]}`
      m.done = false
      items.push(m)
    }
    return items
  }
}

export class AchievementItem {
  id: string = ''
  title: string = ''
  description: string = ''
  unlocked: boolean = false
  iconName: string = 'star'
}

export class CreateInspirationRequest {
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

export class UpdateInspirationRequest {
  title: string = ''
  body: string = ''
  summary: string = ''
  tags: string[] = []
  recordDate: string = ''
  coverKey: string = ''
  linkedIdsJson: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"summary":${JSON.stringify(this.summary)},"tags":${JSON.stringify(this.tags)},"recordDate":${JSON.stringify(this.recordDate)},"coverKey":${JSON.stringify(this.coverKey)},"linkedIdsJson":${JSON.stringify(this.linkedIdsJson)}}`
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

export class BoardCardWire {
  type: string = ''
  text: string = ''
  imageKey: string = ''
  key: string = ''
}

export class BoardCard {
  type: string = 'image'
  text: string = ''
  imageKey: string = ''
}

export class BoardCardList {
  static encode(cards: BoardCard[]): string {
    const parts: string[] = []
    for (const c of cards) {
      parts.push(
        `{"type":${JSON.stringify(c.type)},"text":${JSON.stringify(c.text)},"imageKey":${JSON.stringify(c.imageKey)},"key":${JSON.stringify(c.imageKey)}}`
      )
    }
    return `[${parts.join(',')}]`
  }

  static parse(raw: string): BoardCard[] {
    const out: BoardCard[] = []
    if (raw.length === 0 || raw === '[]') {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as BoardCardWire[]
      for (const w of parsed) {
        const card = new BoardCard()
        const imageKey = InspirationItem.pickStr(w.imageKey).length > 0
          ? InspirationItem.pickStr(w.imageKey)
          : InspirationItem.pickStr(w.key)
        const text = InspirationItem.pickStr(w.text)
        const type = InspirationItem.pickStr(w.type)
        if (imageKey.length > 0) {
          card.type = 'image'
          card.imageKey = imageKey
          out.push(card)
        } else if (type === 'text' && text.length > 0) {
          card.type = 'text'
          card.text = text
          out.push(card)
        }
      }
    } catch {
    }
    return out
  }

  static fromItem(item: InspirationItem): BoardCard[] {
    let cards = BoardCardList.parse(item.cardsJson)
    if (cards.length === 0) {
      cards = BoardCardList.parse(item.body)
    }
    if (cards.length === 0) {
      for (const key of item.imageKeys) {
        if (key.length > 0) {
          const card = new BoardCard()
          card.type = 'image'
          card.imageKey = key
          cards.push(card)
        }
      }
    }
    if (cards.length === 0 && item.coverKey.length > 0) {
      const cover = new BoardCard()
      cover.type = 'image'
      cover.imageKey = item.coverKey
      cards.push(cover)
    }
    return cards
  }

  static imageKeysOf(cards: BoardCard[]): string[] {
    const keys: string[] = []
    for (const c of cards) {
      if (c.type === 'image' && c.imageKey.length > 0) {
        keys.push(c.imageKey)
      }
    }
    return keys
  }
}

export class UpdateBoardRequest {
  title: string = ''
  description: string = ''
  coverKey: string = ''
  imageKeys: string[] = []
  cardsJson: string = ''
  body: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"description":${JSON.stringify(this.description)},"coverKey":${JSON.stringify(this.coverKey)},"imageKeys":${JSON.stringify(this.imageKeys)},"cardsJson":${JSON.stringify(this.cardsJson)},"body":${JSON.stringify(this.body)}}`
  }
}

export class CreatePlanRequest {
  title: string = ''
  goal: string = ''
  summary: string = ''
  progress: number = 0
  milestonesJson: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"goal":${JSON.stringify(this.goal)},"summary":${JSON.stringify(this.summary)},"progress":${this.progress},"milestonesJson":${JSON.stringify(this.milestonesJson)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class UpdatePlanRequest {
  title: string = ''
  goal: string = ''
  summary: string = ''
  progress: number = 0
  milestonesJson: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"goal":${JSON.stringify(this.goal)},"summary":${JSON.stringify(this.summary)},"progress":${this.progress},"milestonesJson":${JSON.stringify(this.milestonesJson)}}`
  }
}

export class UpdatePlanProgressRequest {
  progress: number = 0

  toJsonString(): string {
    return `{"progress":${this.progress}}`
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

export class CreateTopicRequest {
  title: string = ''
  description: string = ''
  coverKey: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"description":${JSON.stringify(this.description)},"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class UpdateTopicRequest {
  title: string = ''
  description: string = ''
  coverKey: string = ''
  linkedIdsJson: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"description":${JSON.stringify(this.description)},"coverKey":${JSON.stringify(this.coverKey)},"linkedIdsJson":${JSON.stringify(this.linkedIdsJson)}}`
  }
}

export class CreateCheckInRequest {
  note: string = ''
  kind: string = 'manual'
  userId: string = ''
  recordDate: string = ''

  toJsonString(): string {
    return `{"note":${JSON.stringify(this.note)},"kind":${JSON.stringify(this.kind)},"userId":${JSON.stringify(this.userId)},"recordDate":${JSON.stringify(this.recordDate)}}`
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

class DeleteOkPayload {
  id: string = ''
}
