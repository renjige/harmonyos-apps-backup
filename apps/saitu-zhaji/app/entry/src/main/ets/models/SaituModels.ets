export class RecordLocation {
  lat: number = 0
  lng: number = 0
  address: string = ''

  static fromParts(lat: number, lng: number, address: string): RecordLocation {
    const loc = new RecordLocation()
    loc.lat = lat
    loc.lng = lng
    loc.address = address
    return loc
  }
}

export class SaituRecord {
  id: string = ''
  content: string = ''
  images: string[] = []
  location: RecordLocation | null = null
  journeyId: string = ''
  tags: string[] = []
  favorite: boolean = false
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(): SaituRecord {
    const r = new SaituRecord()
    r.id = `rec_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    const now = Date.now()
    r.createdAt = now
    r.updatedAt = now
    return r
  }

  summaryLine(maxLen: number): string {
    const trimmed = this.content.trim().replace(/\n/g, ' ')
    if (trimmed.length <= maxLen) {
      return trimmed
    }
    return `${trimmed.substring(0, maxLen)}…`
  }

  dateKey(): string {
    const d = new Date(this.createdAt)
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }
}

export class Journey {
  id: string = ''
  name: string = ''
  description: string = ''
  startDate: string = ''
  endDate: string = ''
  color: string = '#007AFF'
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(name: string): Journey {
    const j = new Journey()
    j.id = `jny_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    j.name = name
    const now = Date.now()
    j.createdAt = now
    j.updatedAt = now
    j.startDate = Journey.todayKey()
    return j
  }

  rowKey(): string {
    return `${this.id}_${this.name}_${this.color}_${this.updatedAt}`
  }

  static todayKey(): string {
    const d = new Date()
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static presetColors(): string[] {
    return ['#007AFF', '#34C759', '#FF9500', '#AF52DE', '#FF3B30']
  }
}

export class UserProfile {
  nickname: string = '赛途旅人'
  themeMode: string = 'system'
}

export class KeywordItem {
  word: string = ''
  count: number = 0
}

export class TrendPoint {
  dateKey: string = ''
  label: string = ''
  count: number = 0
}

export class DashboardStats {
  totalRecords: number = 0
  totalJourneys: number = 0
  streakDays: number = 0
  weekRecords: number = 0
  monthRecords: number = 0
  photoCount: number = 0
  taggedCount: number = 0
  milestoneDone: number = 0
  milestoneTotal: number = 0
  savedReports: number = 0
}

export class JourneyProgress {
  journeyId: string = ''
  name: string = ''
  color: string = '#007AFF'
  recordCount: number = 0
  milestoneDone: number = 0
  milestoneTotal: number = 0
  ratio: number = 0
  progressLabel: string = ''

  rowKey(): string {
    return `${this.journeyId}_${this.name}_${this.color}_${this.milestoneDone}_${this.recordCount}`
  }
}

export class InsightReport {
  periodKind: string = 'week'
  periodLabel: string = ''
  recordCount: number = 0
  topTag: string = ''
  topTagRatio: number = 0
  peakHourLabel: string = ''
  keywords: string[] = []
  wisdomMessage: string = ''
}

export class JourneyMilestone {
  id: string = ''
  journeyId: string = ''
  title: string = ''
  note: string = ''
  dueDate: string = ''
  done: boolean = false
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(journeyId: string): JourneyMilestone {
    const m = new JourneyMilestone()
    m.id = `ms_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    m.journeyId = journeyId
    const now = Date.now()
    m.createdAt = now
    m.updatedAt = now
    return m
  }

  statusLabel(): string {
    return this.done ? '已达成' : '进行中'
  }

  rowKey(): string {
    return `${this.id}_${this.done}_${this.updatedAt}`
  }
}

export class SavedInsight {
  id: string = ''
  periodKind: string = 'week'
  periodLabel: string = ''
  body: string = ''
  recordCount: number = 0
  topTag: string = ''
  keywords: string = ''
  favorite: boolean = false
  createdAt: number = 0

  static fromReport(report: InsightReport): SavedInsight {
    const s = new SavedInsight()
    s.id = `ins_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    s.periodKind = report.periodKind
    s.periodLabel = report.periodLabel
    s.recordCount = report.recordCount
    s.topTag = report.topTag
    s.keywords = report.keywords.join(' · ')
    s.body = SavedInsight.buildBody(report)
    s.createdAt = Date.now()
    return s
  }

  static buildBody(report: InsightReport): string {
    const kind = report.periodKind === 'month' ? '月度成长小结' : '周度成长小结'
    const words = report.keywords.length > 0 ? report.keywords.join('、') : '暂无关键词'
    return `${kind}（${report.periodLabel}）\n` +
      `本周期札记 ${report.recordCount} 条。\n` +
      `高频标签：${report.topTag}（${report.topTagRatio}%）。\n` +
      `活跃时段：${report.peakHourLabel}。\n` +
      `成长关键词：${words}。\n` +
      `${report.wisdomMessage}`
  }

  summaryLine(): string {
    const kind = this.periodKind === 'month' ? '月报' : '周报'
    return `${kind} · ${this.recordCount} 条 · ${this.topTag}`
  }
}

export class DateGroup {
  dateKey: string = ''
  label: string = ''
  records: SaituRecord[] = []

  static build(key: string, items: SaituRecord[]): DateGroup {
    const g = new DateGroup()
    g.dateKey = key
    g.records = items
    const parts = key.split('-')
    if (parts.length >= 3) {
      g.label = `${parts[1]}月${parts[2]}日`
    } else {
      g.label = key
    }
    return g
  }

  static groupRecords(list: SaituRecord[]): DateGroup[] {
    const map = new Map<string, SaituRecord[]>()
    for (const r of list) {
      const key = r.dateKey()
      const bucket = map.get(key)
      if (bucket === undefined) {
        const arr: SaituRecord[] = [r]
        map.set(key, arr)
      } else {
        bucket.push(r)
      }
    }
    const out: DateGroup[] = []
    map.forEach((items, key) => {
      out.push(DateGroup.build(key, items))
    })
    out.sort((a, b) => b.dateKey.localeCompare(a.dateKey))
    return out
  }
}
