export class QgEntry {
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

  static createNew(title: string, templateKey: string): QgEntry {
    const e = new QgEntry()
    e.id = `en_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    e.title = title
    e.dateKey = QgDateUtil.todayKey()
    e.categoryKey = 'daily'
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

export class QgClip {
  id: string = ''
  text: string = ''
  clipKind: string = 'moment'
  dateKey: string = ''
  tagCsv: string = ''
  themeCsv: string = ''
  treasured: boolean = false
  createdAt: number = 0

  static createNew(text: string, clipKind: string): QgClip {
    const c = new QgClip()
    c.id = `cl_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    c.text = text
    c.clipKind = clipKind
    c.dateKey = QgDateUtil.todayKey()
    c.createdAt = Date.now()
    return c
  }
}

export class QgTheme {
  id: string = ''
  title: string = ''
  summary: string = ''
  coverKey: string = 'paper'
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(title: string): QgTheme {
    const t = new QgTheme()
    t.id = `th_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.title = title
    t.coverKey = 'paper'
    t.createdAt = Date.now()
    t.updatedAt = Date.now()
    return t
  }
}

export class QgCategory {
  key: string = ''
  label: string = ''
  sortOrder: number = 0

  static make(key: string, label: string, order: number): QgCategory {
    const c = new QgCategory()
    c.key = key
    c.label = label
    c.sortOrder = order
    return c
  }

  static defaults(): QgCategory[] {
    const out: QgCategory[] = []
    out.push(QgCategory.make('daily', '日常', 0))
    out.push(QgCategory.make('read', '阅读', 1))
    out.push(QgCategory.make('travel', '旅行', 2))
    out.push(QgCategory.make('food', '美食', 3))
    out.push(QgCategory.make('idea', '灵感', 4))
    out.push(QgCategory.make('learn', '学习', 5))
    out.push(QgCategory.make('family', '家庭', 6))
    out.push(QgCategory.make('hobby', '兴趣', 7))
    return out
  }
}

export class QgProfile {
  nickname: string = '栖光人'
  themeMode: string = 'system'
}

export class QgStats {
  entryCount: number = 0
  clipCount: number = 0
  treasureCount: number = 0
  themeCount: number = 0
  inboxCount: number = 0
  streakDays: number = 0
}

export class QgLookbackItem {
  title: string = ''
  body: string = ''
  dateKey: string = ''
  sourceKind: string = ''
  sourceId: string = ''
}

export class QgYearArchive {
  year: string = ''
  entryCount: number = 0
  clipCount: number = 0
  themeCount: number = 0
  topTheme: string = ''
  topTag: string = ''
  highlightTitle: string = ''
}

export class QgAchievement {
  id: string = ''
  title: string = ''
  hint: string = ''

  static make(id: string, title: string, hint: string): QgAchievement {
    const a = new QgAchievement()
    a.id = id
    a.title = title
    a.hint = hint
    return a
  }

  static catalog(): QgAchievement[] {
    const out: QgAchievement[] = []
    out.push(QgAchievement.make('first_entry', '第一篇札记', '留下第一条生活片段'))
    out.push(QgAchievement.make('streak_7', '连续记录 7 天', '连续七天都有足迹'))
    out.push(QgAchievement.make('clips_50', '收藏 50 道光影', '光影收藏达到 50 条'))
    out.push(QgAchievement.make('themes_10', '十个主题空间', '创建 10 个主题册'))
    out.push(QgAchievement.make('year_file', '年度档案', '本年已有记录可生成档案'))
    return out
  }
}

export class QgTimelineRow {
  id: string = ''
  kind: string = ''
  dateKey: string = ''
  title: string = ''
  subtitle: string = ''
}

export class QgDateUtil {
  static todayKey(): string {
    return QgDateUtil.keyFromDate(new Date())
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
    const d = QgDateUtil.parseKey(key)
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
    return QgDateUtil.keyFromDate(d)
  }

  static yearsAgoKey(n: number): string {
    const d = new Date()
    d.setFullYear(d.getFullYear() - n)
    return QgDateUtil.keyFromDate(d)
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
      out.push(QgDateUtil.monthKey(cursor))
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

export class QgLabels {
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
      return '今日记录'
    }
    if (key === 'idea') {
      return '灵感记录'
    }
    if (key === 'travel') {
      return '旅行记录'
    }
    if (key === 'read') {
      return '阅读记录'
    }
    return '空白档案'
  }

  static fieldALabel(key: string): string {
    if (key === 'today') {
      return '今天发生'
    }
    if (key === 'idea') {
      return '想法'
    }
    if (key === 'travel') {
      return '地点'
    }
    if (key === 'read') {
      return '书名'
    }
    return '摘要'
  }

  static fieldBLabel(key: string): string {
    if (key === 'today') {
      return '我的感受'
    }
    if (key === 'idea') {
      return '来源'
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
      return '值得保存'
    }
    if (key === 'idea') {
      return '下一步'
    }
    if (key === 'travel') {
      return '收获'
    }
    if (key === 'read') {
      return '收获'
    }
    return '备注'
  }

  static clipKindLabel(kind: string): string {
    if (kind === 'quote') {
      return '一句话'
    }
    if (kind === 'idea') {
      return '想法'
    }
    if (kind === 'spark') {
      return '计划火花'
    }
    if (kind === 'find') {
      return '生活发现'
    }
    return '瞬间'
  }

  static promptOfDay(): string {
    const list: string[] = [
      '今天值得留下什么？',
      '哪一道光还停在心里？',
      '有一句想收藏的话吗？',
      '此刻想记住哪一个细节？',
      '哪件小事不想被明天冲淡？'
    ]
    const start = new Date(2026, 0, 1).getTime()
    const diff = new Date().getTime() - start
    const day = Math.floor(diff / 86400000)
    const idx = day % list.length
    return list[idx < 0 ? idx + list.length : idx]
  }
}
