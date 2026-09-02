export class KnowledgeCategory {
  key: string = ''
  label: string = ''
  emoji: string = ''

  constructor(key: string, label: string, emoji: string) {
    this.key = key
    this.label = label
    this.emoji = emoji
  }

  static all(): KnowledgeCategory[] {
    return [
      new KnowledgeCategory('life', '生活', '☀'),
      new KnowledgeCategory('science', '科普', '⚡'),
      new KnowledgeCategory('reading', '阅读', '⌁'),
      new KnowledgeCategory('work', '工作', '✦'),
      new KnowledgeCategory('interest', '兴趣', '◆'),
      new KnowledgeCategory('other', '其他', '·')
    ]
  }

  static labelOf(key: string): string {
    for (const c of KnowledgeCategory.all()) {
      if (c.key === key) {
        return c.label
      }
    }
    return '其他'
  }

  static emojiOf(key: string): string {
    for (const c of KnowledgeCategory.all()) {
      if (c.key === key) {
        return c.emoji
      }
    }
    return '·'
  }
}

export class UserKnowledge {
  id: string = ''
  title: string = ''
  body: string = ''
  categoryKey: string = 'other'
  tags: string = ''
  source: string = 'user'
  linkedInfoId: string = ''
  favorited: boolean = false
  inReviewQueue: boolean = false
  createdAt: string = ''
  updatedAt: string = ''

  static create(
    id: string,
    title: string,
    body: string,
    categoryKey: string,
    tags: string,
    source: string,
    linkedInfoId: string
  ): UserKnowledge {
    const k = new UserKnowledge()
    k.id = id
    k.title = title
    k.body = body
    k.categoryKey = categoryKey
    k.tags = tags
    k.source = source
    k.linkedInfoId = linkedInfoId
    const now = UserKnowledge.nowIso()
    k.createdAt = now
    k.updatedAt = now
    return k
  }

  static nowIso(): string {
    return new Date().toISOString()
  }
}

export class Spark {
  id: string = ''
  title: string = ''
  body: string = ''
  tags: string = ''
  createdAt: string = ''

  static create(id: string, title: string, body: string, tags: string): Spark {
    const s = new Spark()
    s.id = id
    s.title = title
    s.body = body
    s.tags = tags
    s.createdAt = new Date().toISOString()
    return s
  }
}

export class ReadingPlan {
  id: string = ''
  title: string = ''
  targetCount: number = 5
  startDate: string = ''
  endDate: string = ''
  completedIds: string = ''
  status: string = 'active'

  static createWeekly(id: string, targetCount: number): ReadingPlan {
    const p = new ReadingPlan()
    p.id = id
    p.title = '本周阅读计划'
    p.targetCount = targetCount
    const now = new Date()
    const day = now.getDay()
    const diffToMon = day === 0 ? -6 : 1 - day
    const mon = new Date(now)
    mon.setDate(now.getDate() + diffToMon)
    mon.setHours(0, 0, 0, 0)
    const sun = new Date(mon)
    sun.setDate(mon.getDate() + 6)
    p.startDate = ReadingPlan.dateKey(mon)
    p.endDate = ReadingPlan.dateKey(sun)
    p.completedIds = ''
    p.status = 'active'
    return p
  }

  static dateKey(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  completedCount(): number {
    if (this.completedIds.length === 0) {
      return 0
    }
    return this.completedIds.split(',').filter((x: string) => x.length > 0).length
  }

  progressPercent(): number {
    if (this.targetCount <= 0) {
      return 0
    }
    return Math.min(100, Math.round((this.completedCount() / this.targetCount) * 100))
  }
}

export class ReviewQueueItem {
  refId: string = ''
  refType: string = 'info'

  static create(refId: string, refType: string): ReviewQueueItem {
    const r = new ReviewQueueItem()
    r.refId = refId
    r.refType = refType
    return r
  }
}

export class TimelineEvent {
  id: string = ''
  type: string = ''
  title: string = ''
  refId: string = ''
  timestamp: string = ''

  static create(id: string, type: string, title: string, refId: string): TimelineEvent {
    const e = new TimelineEvent()
    e.id = id
    e.type = type
    e.title = title
    e.refId = refId
    e.timestamp = new Date().toISOString()
    return e
  }
}

export class AchievementDef {
  id: string = ''
  title: string = ''
  description: string = ''
  emoji: string = ''

  static all(): AchievementDef[] {
    const list: AchievementDef[] = []
    const defs: string[][] = [
      ['ach_first_read', '初读成章', '完成第一次阅读', '📖'],
      ['ach_first_knowledge', '笔耕不辍', '创建第一条知识', '✍'],
      ['ach_first_spark', '灵感闪现', '记录第一条灵感', '💡'],
      ['ach_streak_3', '三日不辍', '连续打卡 3 天', '🔥'],
      ['ach_streak_7', '七日精进', '连续打卡 7 天', '⭐'],
      ['ach_read_10', '博览十篇', '累计阅读 10 篇', '📚'],
      ['ach_favorite_5', '收藏达人', '收藏 5 条内容', '♥'],
      ['ach_review_5', '温故知新', '完成 5 次复习', '🔄'],
      ['ach_plan_done', '计划达成', '完成本周阅读计划', '🎯'],
      ['ach_knowledge_5', '知识积累', '自建 5 条知识', '📝']
    ]
    for (const d of defs) {
      const a = new AchievementDef()
      a.id = d[0]
      a.title = d[1]
      a.description = d[2]
      a.emoji = d[3]
      list.push(a)
    }
    return list
  }
}

export class DashboardStats {
  readCount: number = 0
  favoriteCount: number = 0
  knowledgeCount: number = 0
  sparkCount: number = 0
  streakDays: number = 0
  reviewPending: number = 0
  planProgress: number = 0
  planTarget: number = 5
  planDone: number = 0
  todayRead: number = 0
}

export class CategoryStat {
  label: string = ''
  count: number = 0
}
