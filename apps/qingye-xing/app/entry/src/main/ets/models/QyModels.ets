export class QyEntry {
  id: string = ''
  title: string = ''
  dateKey: string = ''
  categoryKey: string = ''
  tagCsv: string = ''
  status: string = 'inbox'
  templateKey: string = 'blank'
  fieldA: string = ''
  fieldB: string = ''
  fieldC: string = ''
  body: string = ''
  themeCsv: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(title: string, templateKey: string): QyEntry {
    const e = new QyEntry()
    e.id = `en_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    e.title = title
    e.dateKey = QyDateUtil.todayKey()
    e.categoryKey = 'park'
    e.tagCsv = ''
    e.status = 'inbox'
    e.templateKey = templateKey
    e.createdAt = Date.now()
    e.updatedAt = Date.now()
    return e
  }

  summaryText(): string {
    if (this.fieldA.length > 0) {
      return this.fieldA
    }
    if (this.body.length > 0) {
      return this.body
    }
    return '尚未写下内容'
  }

  isTreasure(): boolean {
    return this.status === 'treasure'
  }
}

export class QyClip {
  id: string = ''
  text: string = ''
  clipKind: string = 'moment'
  dateKey: string = ''
  tagCsv: string = ''
  themeCsv: string = ''
  treasured: boolean = false
  createdAt: number = 0

  static createNew(text: string, clipKind: string): QyClip {
    const c = new QyClip()
    c.id = `cl_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    c.text = text
    c.clipKind = clipKind
    c.dateKey = QyDateUtil.todayKey()
    c.createdAt = Date.now()
    return c
  }
}

export class QyTheme {
  id: string = ''
  title: string = ''
  summary: string = ''
  coverKey: string = 'paper'
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(title: string): QyTheme {
    const t = new QyTheme()
    t.id = `th_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.title = title
    t.coverKey = 'paper'
    t.createdAt = Date.now()
    t.updatedAt = Date.now()
    return t
  }
}

export class QyCategory {
  key: string = ''
  label: string = ''
  sortOrder: number = 0

  static make(key: string, label: string, order: number): QyCategory {
    const c = new QyCategory()
    c.key = key
    c.label = label
    c.sortOrder = order
    return c
  }

  static defaults(): QyCategory[] {
    const out: QyCategory[] = []
    out.push(QyCategory.make('park', '公园散步', 0))
    out.push(QyCategory.make('suburb', '郊外观察', 1))
    out.push(QyCategory.make('nature', '自然探索', 2))
    out.push(QyCategory.make('city', '城市漫游', 3))
    out.push(QyCategory.make('trail', '徒步记录', 4))
    out.push(QyCategory.make('season', '四季观察', 5))
    return out
  }
}

export class QyProfile {
  nickname: string = '探索者'
  themeMode: string = 'system'
}

export class QyStats {
  entryCount: number = 0
  clipCount: number = 0
  treasureCount: number = 0
  themeCount: number = 0
  inboxCount: number = 0
  streakDays: number = 0
}

export class QyLookbackItem {
  title: string = ''
  body: string = ''
  dateKey: string = ''
  sourceKind: string = ''
  sourceId: string = ''
}

export class QyYearArchive {
  year: string = ''
  entryCount: number = 0
  clipCount: number = 0
  themeCount: number = 0
  topTheme: string = ''
  topTag: string = ''
  highlightTitle: string = ''
}

export class QyAchievement {
  id: string = ''
  title: string = ''
  hint: string = ''

  static make(id: string, title: string, hint: string): QyAchievement {
    const a = new QyAchievement()
    a.id = id
    a.title = title
    a.hint = hint
    return a
  }

  static catalog(): QyAchievement[] {
    const out: QyAchievement[] = []
    out.push(QyAchievement.make('first_entry', '初次探索', '完成第一次探索记录'))
    out.push(QyAchievement.make('streak_7', '连续探索 7 天', '连续七天都有探索足迹'))
    out.push(QyAchievement.make('clips_20', '自然观察者', '自然观察达到 20 条'))
    out.push(QyAchievement.make('themes_5', '主题收藏家', '创建 5 个探索主题'))
    out.push(QyAchievement.make('year_file', '年度档案', '本年已有记录可生成报告'))
    return out
  }
}

export class QyTimelineRow {
  id: string = ''
  kind: string = ''
  dateKey: string = ''
  title: string = ''
  subtitle: string = ''
}

export class QyDateUtil {
  static todayKey(): string {
    return QyDateUtil.keyFromDate(new Date())
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
    const d = QyDateUtil.parseKey(key)
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日`
  }

  static displayMonthYear(key: string): string {
    if (key.length < 7) {
      return ''
    }
    return `${key.substring(0, 4)}年${parseInt(key.substring(5, 7), 10)}月`
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
    return QyDateUtil.keyFromDate(d)
  }

  static yearsAgoKey(n: number): string {
    const d = new Date()
    d.setFullYear(d.getFullYear() - n)
    return QyDateUtil.keyFromDate(d)
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
      out.push(QyDateUtil.monthKey(cursor))
      cursor.setMonth(cursor.getMonth() - 1)
    }
    return out
  }

  static sameMonthDay(key: string, ref: string): boolean {
    if (key.length < 10 || ref.length < 10) {
      return false
    }
    return key.substring(5) === ref.substring(5) && key.substring(0, 4) !== ref.substring(0, 4)
  }
}

export class QyLabels {
  static statusLabel(status: string): string {
    if (status === 'inbox') {
      return '待整理'
    }
    if (status === 'important') {
      return '重要'
    }
    if (status === 'treasure') {
      return '珍藏'
    }
    return '普通'
  }

  static templateLabel(key: string): string {
    if (key === 'today') {
      return '今日探索'
    }
    if (key === 'idea') {
      return '自然发现'
    }
    if (key === 'travel') {
      return '户外探索'
    }
    if (key === 'read') {
      return '观察记录'
    }
    return '空白探索'
  }

  static fieldALabel(key: string): string {
    if (key === 'today') {
      return '发现'
    }
    if (key === 'idea') {
      return '观察对象'
    }
    if (key === 'travel') {
      return '地点名称'
    }
    if (key === 'read') {
      return '观察内容'
    }
    return '摘要'
  }

  static fieldBLabel(key: string): string {
    if (key === 'today') {
      return '感受'
    }
    if (key === 'idea') {
      return '观察细节'
    }
    if (key === 'travel') {
      return '经历'
    }
    if (key === 'read') {
      return '感受'
    }
    return '说明'
  }

  static fieldCLabel(key: string): string {
    if (key === 'today') {
      return '收获'
    }
    if (key === 'idea') {
      return '备注'
    }
    if (key === 'travel') {
      return '收获'
    }
    if (key === 'read') {
      return '备注'
    }
    return '备注'
  }

  static clipKindLabel(kind: string): string {
    if (kind === 'quote') {
      return '一句话'
    }
    if (kind === 'idea') {
      return '植物观察'
    }
    if (kind === 'spark') {
      return '天气观察'
    }
    if (kind === 'find') {
      return '景色记录'
    }
    return '自然发现'
  }

  static promptOfDay(): string {
    const list: string[] = [
      '今天发现了什么？',
      '哪一处风景还留在心里？',
      '想记下哪一个自然瞬间？',
      '此刻户外有什么值得留下？',
      '哪次漫步不想被明天冲淡？'
    ]
    const start = new Date(2026, 0, 1).getTime()
    const diff = new Date().getTime() - start
    const day = Math.floor(diff / 86400000)
    const idx = day % list.length
    return list[idx < 0 ? idx + list.length : idx]
  }
}
