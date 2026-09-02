export class Archive {
  id: string = ''
  title: string = ''
  categoryKey: string = ''
  startDate: string = ''
  endDate: string = ''
  summary: string = ''
  tags: string[] = []
  status: string = 'organized'
  createdAt: number = 0
  updatedAt: number = 0
  isFavorite: boolean = false
  mood: string = ''
  oneLineSummary: string = ''

  static createNew(title: string, categoryKey: string): Archive {
    const a = new Archive()
    a.id = `arc_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    a.title = title
    a.categoryKey = categoryKey
    a.startDate = ''
    a.endDate = ''
    a.summary = ''
    a.tags = []
    a.status = 'pending'
    a.createdAt = Date.now()
    a.updatedAt = Date.now()
    return a
  }

  yearLabel(): string {
    if (this.startDate.length >= 4) {
      return this.startDate.substring(0, 4)
    }
    return '—'
  }

  rangeLabel(): string {
    if (this.startDate.length === 0) {
      return '未设定时间'
    }
    if (this.endDate.length === 0 || this.endDate === this.startDate) {
      return this.startDate
    }
    return `${this.startDate} — ${this.endDate}`
  }
}

export class TimelineNode {
  id: string = ''
  archiveId: string = ''
  dateKey: string = ''
  title: string = ''
  whatHappened: string = ''
  whyImportant: string = ''
  feeling: string = ''
  afterChange: string = ''
  tags: string[] = []
  createdAt: number = 0
  isImportant: boolean = false

  static createNew(archiveId: string, dateKey: string, title: string): TimelineNode {
    const n = new TimelineNode()
    n.id = `node_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    n.archiveId = archiveId
    n.dateKey = dateKey
    n.title = title
    n.whatHappened = ''
    n.whyImportant = ''
    n.feeling = ''
    n.afterChange = ''
    n.tags = []
    n.createdAt = Date.now()
    return n
  }
}

export class ArchiveCategory {
  key: string = ''
  label: string = ''
  sortOrder: number = 0

  static make(key: string, label: string, order: number): ArchiveCategory {
    const c = new ArchiveCategory()
    c.key = key
    c.label = label
    c.sortOrder = order
    return c
  }

  static defaults(): ArchiveCategory[] {
    const out: ArchiveCategory[] = []
    out.push(ArchiveCategory.make('growth', '成长经历', 0))
    out.push(ArchiveCategory.make('family', '家庭记忆', 1))
    out.push(ArchiveCategory.make('career', '职业阶段', 2))
    out.push(ArchiveCategory.make('travel', '旅行足迹', 3))
    out.push(ArchiveCategory.make('milestone', '人生里程碑', 4))
    return out
  }
}

export class UserProfile {
  nickname: string = '档案守护者'
  themeMode: string = 'system'
}

export class MonthlyBar {
  monthLabel: string = ''
  count: number = 0

  static make(label: string, count: number): MonthlyBar {
    const b = new MonthlyBar()
    b.monthLabel = label
    b.count = count
    return b
  }
}

export class ArchiveStats {
  totalArchives: number = 0
  totalNodes: number = 0
  topCategory: string = ''
  topCategoryLabel: string = ''
  richestYear: string = ''
  richestYearCount: number = 0
  pendingCount: number = 0
  monthlyBars: MonthlyBar[] = []
  completionAvg: number = 0
}

export class ReviewSummary {
  title: string = ''
  body: string = ''
  highlights: string[] = []
}
