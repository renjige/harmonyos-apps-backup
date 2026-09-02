export class RmChecklist {
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

  static createNew(title: string, templateKey: string): RmChecklist {
    const e = new RmChecklist()
    e.id = `en_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    e.title = title
    e.dateKey = RmDateUtil.todayKey()
    e.categoryKey = 'experience'
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

export class RmWish {
  id: string = ''
  text: string = ''
  clipKind: string = 'moment'
  dateKey: string = ''
  tagCsv: string = ''
  themeCsv: string = ''
  treasured: boolean = false
  createdAt: number = 0

  static createNew(text: string, clipKind: string): RmWish {
    const c = new RmWish()
    c.id = `cl_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    c.text = text
    c.clipKind = clipKind
    c.dateKey = RmDateUtil.todayKey()
    c.createdAt = Date.now()
    return c
  }
}

export class RmCheckItem {
  id: string = ''
  checklistId: string = ''
  title: string = ''
  status: string = 'pending'
  feeling: string = ''
  harvest: string = ''
  note: string = ''
  starred: boolean = false
  completedAt: number = 0
  sortOrder: number = 0

  static createNew(checklistId: string, title: string): RmCheckItem {
    const i = new RmCheckItem()
    i.id = `it_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    i.checklistId = checklistId
    i.title = title
    i.status = 'pending'
    i.sortOrder = Date.now()
    return i
  }

  isDone(): boolean {
    return this.status === 'done'
  }
}

export class RmPlan {
  id: string = ''
  title: string = ''
  planKind: string = '30d'
  startDate: string = ''
  endDate: string = ''
  checklistCsv: string = ''
  createdAt: number = 0

  static createNew(title: string, planKind: string): RmPlan {
    const p = new RmPlan()
    p.id = `pl_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    p.title = title
    p.planKind = planKind
    p.startDate = RmDateUtil.todayKey()
    const d = new Date()
    if (planKind === '7d') {
      d.setDate(d.getDate() + 7)
    } else if (planKind === '365d') {
      d.setFullYear(d.getFullYear() + 1)
    } else {
      d.setDate(d.getDate() + 30)
    }
    p.endDate = RmDateUtil.keyFromDate(d)
    p.createdAt = Date.now()
    return p
  }
}

export class RmTheme {
  id: string = ''
  title: string = ''
  summary: string = ''
  coverKey: string = 'paper'
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(title: string): RmTheme {
    const t = new RmTheme()
    t.id = `th_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.title = title
    t.coverKey = 'paper'
    t.createdAt = Date.now()
    t.updatedAt = Date.now()
    return t
  }
}

export class RmCategory {
  key: string = ''
  label: string = ''
  sortOrder: number = 0

  static make(key: string, label: string, order: number): RmCategory {
    const c = new RmCategory()
    c.key = key
    c.label = label
    c.sortOrder = order
    return c
  }

  static defaults(): RmCategory[] {
    const out: RmCategory[] = []
    out.push(RmCategory.make('experience', '想去体验', 0))
    out.push(RmCategory.make('goal', '想完成', 1))
    out.push(RmCategory.make('city', '城市探索', 2))
    out.push(RmCategory.make('read', '阅读漫游', 3))
    out.push(RmCategory.make('food', '美食探索', 4))
    out.push(RmCategory.make('grow', '成长计划', 5))
    out.push(RmCategory.make('hobby', '兴趣收藏', 6))
    return out
  }
}

export class RmProfile {
  nickname: string = '漫游者'
  themeMode: string = 'system'
}

export class RmStats {
  entryCount: number = 0
  clipCount: number = 0
  treasureCount: number = 0
  themeCount: number = 0
  inboxCount: number = 0
  streakDays: number = 0
  doneItemCount: number = 0
  itemCount: number = 0
}

export class RmLookbackItem {
  title: string = ''
  body: string = ''
  dateKey: string = ''
  sourceKind: string = ''
  sourceId: string = ''
}

export class RmYearArchive {
  year: string = ''
  entryCount: number = 0
  clipCount: number = 0
  themeCount: number = 0
  topTheme: string = ''
  topTag: string = ''
  highlightTitle: string = ''
}

export class RmAchievement {
  id: string = ''
  title: string = ''
  hint: string = ''

  static make(id: string, title: string, hint: string): RmAchievement {
    const a = new RmAchievement()
    a.id = id
    a.title = title
    a.hint = hint
    return a
  }

  static catalog(): RmAchievement[] {
    const out: RmAchievement[] = []
    out.push(RmAchievement.make('first_entry', '初次漫游', '完成第一个体验目标'))
    out.push(RmAchievement.make('streak_7', '长期行动者', '连续记录 7 天'))
    out.push(RmAchievement.make('clips_20', '体验收藏家', '完成 20 项体验'))
    out.push(RmAchievement.make('themes_5', '生活探索者', '创建 5 个主题空间'))
    out.push(RmAchievement.make('year_file', '年度漫游', '本年可生成年度报告'))
    return out
  }
}

export class RmTimelineRow {
  id: string = ''
  kind: string = ''
  dateKey: string = ''
  title: string = ''
  subtitle: string = ''
}

export class RmDateUtil {
  static todayKey(): string {
    return RmDateUtil.keyFromDate(new Date())
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
    const d = RmDateUtil.parseKey(key)
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
    return RmDateUtil.keyFromDate(d)
  }

  static yearsAgoKey(n: number): string {
    const d = new Date()
    d.setFullYear(d.getFullYear() - n)
    return RmDateUtil.keyFromDate(d)
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
      out.push(RmDateUtil.monthKey(cursor))
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

export class RmLabels {
  static statusLabel(status: string): string {
    if (status === 'inbox') {
      return '进行中'
    }
    if (status === 'important') {
      return '重点'
    }
    if (status === 'treasure') {
      return '已归档'
    }
    if (status === 'done') {
      return '已完成'
    }
    return '普通'
  }

  static templateLabel(key: string): string {
    if (key === 'today') {
      return '体验清单'
    }
    if (key === 'idea') {
      return '兴趣目标'
    }
    if (key === 'travel') {
      return '城市探索'
    }
    if (key === 'read') {
      return '阅读计划'
    }
    return '空白清单'
  }

  static fieldALabel(key: string): string {
    return '清单总结'
  }

  static fieldBLabel(key: string): string {
    return '补充说明'
  }

  static fieldCLabel(key: string): string {
    return '备注'
  }

  static clipKindLabel(kind: string): string {
    if (kind === 'learn') {
      return '想学习'
    }
    if (kind === 'try') {
      return '想尝试'
    }
    if (kind === 'experience') {
      return '想体验'
    }
    return '愿望'
  }

  static itemStatusLabel(status: string): string {
    if (status === 'done') {
      return '已完成'
    }
    return '待完成'
  }

  static promptOfDay(): string {
    const list: string[] = [
      '今天完成一个小目标。',
      '哪件想体验的事可以开始？',
      '给生活清单添一项新体验。',
      '完成一项，就离经历更近一步。',
      '把愿望变成今天的行动。'
    ]
    const start = new Date(2026, 0, 1).getTime()
    const diff = new Date().getTime() - start
    const day = Math.floor(diff / 86400000)
    const idx = day % list.length
    return list[idx < 0 ? idx + list.length : idx]
  }
}
