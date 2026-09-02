export class MemoryRecord {
  id: string = ''
  content: string = ''
  tags: string[] = []
  createTime: number = 0
  updateTime: number = 0
  pinned: boolean = false
  favorite: boolean = false
  archived: boolean = false
  templateKey: string = ''
  reviewCount: number = 0
  lastReviewAt: number = 0

  static createNew(): MemoryRecord {
    const r = new MemoryRecord()
    r.id = `m_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    r.createTime = Date.now()
    r.updateTime = r.createTime
    return r
  }

  previewLine(): string {
    const plain = this.content.replace(/\n/g, ' ').trim()
    if (plain.length === 0) {
      return '（空白记忆）'
    }
    return plain.length > 72 ? `${plain.substring(0, 72)}…` : plain
  }

  tagLine(): string {
    if (this.tags.length === 0) {
      return '未分类'
    }
    return this.tags.join(' · ')
  }

  hasTag(name: string): boolean {
    for (const t of this.tags) {
      if (t === name) {
        return true
      }
    }
    return false
  }

  isUnclassified(): boolean {
    return this.tags.length === 0
  }

  primaryTag(): string {
    if (this.tags.length === 0) {
      return '未分类'
    }
    return this.tags[0]
  }

  dueReview(now: number): boolean {
    if (this.archived) {
      return false
    }
    const day = 24 * 60 * 60 * 1000
    if (now - this.createTime < day) {
      return false
    }
    if (this.lastReviewAt === 0) {
      return true
    }
    return now - this.lastReviewAt >= 7 * day
  }
}

export class MemoryBooklet {
  id: string = ''
  title: string = ''
  summary: string = ''
  createdAt: number = 0
  recordIds: string[] = []

  static createNew(): MemoryBooklet {
    const b = new MemoryBooklet()
    b.id = `b_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    b.createdAt = Date.now()
    return b
  }

  countLabel(): string {
    return `${this.recordIds.length} 条记忆`
  }
}

export class CaptureTemplate {
  key: string = ''
  title: string = ''
  starter: string = ''
  tag: string = ''

  static all(): CaptureTemplate[] {
    const list: CaptureTemplate[] = []
    list.push(CaptureTemplate.make('work', '工作纪要', '【工作纪要】\n事项：\n结论：\n下一步：', '工作'))
    list.push(CaptureTemplate.make('idea', '灵感快记', '【灵感】\n', '灵感'))
    list.push(CaptureTemplate.make('trip', '旅行见闻', '【旅行】\n地点：\n见闻：', '旅行'))
    list.push(CaptureTemplate.make('read', '阅读摘记', '【阅读】\n书名：\n摘记：', '阅读'))
    list.push(CaptureTemplate.make('life', '生活备忘', '【生活】\n', '生活'))
    return list
  }

  static make(key: string, title: string, starter: string, tag: string): CaptureTemplate {
    const t = new CaptureTemplate()
    t.key = key
    t.title = title
    t.starter = starter
    t.tag = tag
    return t
  }
}

export class DayCell {
  dateKey: string = ''
  dayNum: number = 0
  hasEntry: boolean = false
  isToday: boolean = false
  isPad: boolean = false
}

export class WeekDigest {
  weekCount: number = 0
  topTag: string = ''
  dueCount: number = 0
  streak: number = 0

  summaryText(): string {
    const tag = this.topTag.length > 0 ? this.topTag : '暂无'
    return `本周写下 ${this.weekCount} 条，最常用标签「${tag}」。连续记录 ${this.streak} 天，待温习 ${this.dueCount} 条。`
  }
}

export class TagCloudItem {
  name: string = ''
  count: number = 0
  fontSize: number = 14
}

export class ClassifyHint {
  recordId: string = ''
  preview: string = ''
  suggested: string = ''
}

export class MemoryOverview {
  total: number = 0
  monthNew: number = 0
  top1: string = ''
  top2: string = ''
  top3: string = ''
  favoriteCount: number = 0
  bookletCount: number = 0
  dueCount: number = 0
  streakDays: number = 0
}
