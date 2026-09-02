export class XdEntry {
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

  static createNew(title: string, templateKey: string): XdEntry {
    const e = new XdEntry()
    e.id = `en_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    e.title = title
    e.dateKey = XdDateUtil.todayKey()
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

export class XdClip {
  id: string = ''
  text: string = ''
  clipKind: string = 'moment'
  dateKey: string = ''
  tagCsv: string = ''
  themeCsv: string = ''
  treasured: boolean = false
  createdAt: number = 0

  static createNew(text: string, clipKind: string): XdClip {
    const c = new XdClip()
    c.id = `cl_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    c.text = text
    c.clipKind = clipKind
    c.dateKey = XdDateUtil.todayKey()
    c.createdAt = Date.now()
    return c
  }
}

export class XdTheme {
  id: string = ''
  title: string = ''
  summary: string = ''
  coverKey: string = 'paper'
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(title: string): XdTheme {
    const t = new XdTheme()
    t.id = `th_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.title = title
    t.coverKey = 'paper'
    t.createdAt = Date.now()
    t.updatedAt = Date.now()
    return t
  }
}

export class XdCategory {
  key: string = ''
  label: string = ''
  sortOrder: number = 0

  static make(key: string, label: string, order: number): XdCategory {
    const c = new XdCategory()
    c.key = key
    c.label = label
    c.sortOrder = order
    return c
  }

  static defaults(): XdCategory[] {
    const out: XdCategory[] = []
    out.push(XdCategory.make('daily', '日常', 0))
    out.push(XdCategory.make('read', '阅读', 1))
    out.push(XdCategory.make('travel', '旅行', 2))
    out.push(XdCategory.make('food', '美食', 3))
    out.push(XdCategory.make('idea', '灵感', 4))
    out.push(XdCategory.make('learn', '学习', 5))
    out.push(XdCategory.make('family', '家庭', 6))
    out.push(XdCategory.make('hobby', '兴趣', 7))
    return out
  }
}

export class XdMoodLog {
  dateKey: string = ''
  moodKey: string = 'calm'
  note: string = ''

  static createForToday(moodKey: string, note: string): XdMoodLog {
    const m = new XdMoodLog()
    m.dateKey = XdDateUtil.todayKey()
    m.moodKey = moodKey
    m.note = note
    return m
  }
}

export class XdWishItem {
  id: string = ''
  title: string = ''
  note: string = ''
  status: string = 'wish'
  themeId: string = ''

  static createNew(title: string): XdWishItem {
    const w = new XdWishItem()
    w.id = `wi_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    w.title = title
    w.status = 'wish'
    return w
  }
}

export class XdTidySuggestion {
  id: string = ''
  title: string = ''
  hint: string = ''
  actionKind: string = ''
  targetId: string = ''
}

export class XdMemoryAlbumItem {
  id: string = ''
  kind: string = ''
  dateKey: string = ''
  title: string = ''
  subtitle: string = ''
}

export class XdProfile {
  nickname: string = '岛民'
  themeMode: string = 'system'
}

export class XdStats {
  entryCount: number = 0
  clipCount: number = 0
  treasureCount: number = 0
  themeCount: number = 0
  inboxCount: number = 0
  streakDays: number = 0
}

export class XdLookbackItem {
  title: string = ''
  body: string = ''
  dateKey: string = ''
  sourceKind: string = ''
  sourceId: string = ''
}

export class XdYearArchive {
  year: string = ''
  entryCount: number = 0
  clipCount: number = 0
  themeCount: number = 0
  topTheme: string = ''
  topTag: string = ''
  highlightTitle: string = ''
}

export class XdAchievement {
  id: string = ''
  title: string = ''
  hint: string = ''

  static make(id: string, title: string, hint: string): XdAchievement {
    const a = new XdAchievement()
    a.id = id
    a.title = title
    a.hint = hint
    return a
  }

  static catalog(): XdAchievement[] {
    const out: XdAchievement[] = []
    out.push(XdAchievement.make('first_entry', '登岛首记', '在小岛留下第一条生活片段'))
    out.push(XdAchievement.make('streak_7', '七日守岛', '连续七天都有慢记足迹'))
    out.push(XdAchievement.make('clips_50', '瞬间收藏家', '瞬间收藏达到 50 条'))
    out.push(XdAchievement.make('themes_10', '十座主题岛', '创建 10 个主题岛'))
    out.push(XdAchievement.make('year_file', '年度岛志', '本年已有记录可生成档案'))
    return out
  }
}

export class XdTimelineRow {
  id: string = ''
  kind: string = ''
  dateKey: string = ''
  title: string = ''
  subtitle: string = ''
}

export class XdDateUtil {
  static todayKey(): string {
    return XdDateUtil.keyFromDate(new Date())
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
    const d = XdDateUtil.parseKey(key)
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
    return XdDateUtil.keyFromDate(d)
  }

  static yearsAgoKey(n: number): string {
    const d = new Date()
    d.setFullYear(d.getFullYear() - n)
    return XdDateUtil.keyFromDate(d)
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
      out.push(XdDateUtil.monthKey(cursor))
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

export class XdLabels {
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
    if (status === 'memory') {
      return '回忆'
    }
    return '普通'
  }

  static moodLabel(key: string): string {
    if (key === 'happy') {
      return '开心'
    }
    if (key === 'full') {
      return '充实'
    }
    if (key === 'tired') {
      return '疲惫'
    }
    return '平静'
  }

  static wishStatusLabel(status: string): string {
    if (status === 'active') {
      return '进行中'
    }
    if (status === 'done') {
      return '已实现'
    }
    return '心愿'
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
      '今天值得在小岛留下什么？',
      '哪一刻还想慢慢回味？',
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
