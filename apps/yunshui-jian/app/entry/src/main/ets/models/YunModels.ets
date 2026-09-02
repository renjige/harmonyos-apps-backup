export class YunNoteItem {
  id: string = ''
  title: string = ''
  body: string = ''
  tags: string[] = []
  imagePaths: string[] = []
  category: string = '日常'
  mood: string = ''
  templateKey: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  static create(id: string, title: string, body: string): YunNoteItem {
    const n = new YunNoteItem()
    n.id = id
    n.title = title
    n.body = body
    n.createdAt = Date.now()
    n.updatedAt = n.createdAt
    return n
  }

  summary(maxLen: number): string {
    const raw = this.body.length > 0 ? this.body : this.title
    if (raw.length <= maxLen) {
      return raw
    }
    return `${raw.substring(0, maxLen)}…`
  }

  hasImages(): boolean {
    return this.imagePaths.length > 0
  }
}

export class YunTodoItem {
  id: string = ''
  content: string = ''
  done: boolean = false
  dueDate: string = ''
  dueTime: string = ''
  repeatType: string = 'none'
  listKind: string = 'remind'
  reminderAgentId: number = 0
  createdAt: number = 0
  completedAt: number = 0

  static create(id: string, content: string): YunTodoItem {
    const t = new YunTodoItem()
    t.id = id
    t.content = content
    t.createdAt = Date.now()
    return t
  }

  kindLabel(): string {
    if (this.listKind === 'shopping') {
      return '购物'
    }
    if (this.listKind === 'chore') {
      return '家务'
    }
    if (this.listKind === 'trip') {
      return '出行'
    }
    if (this.listKind === 'study') {
      return '学习'
    }
    return '提醒'
  }

  repeatLabel(): string {
    if (this.repeatType === 'daily') {
      return '每日'
    }
    if (this.repeatType === 'weekly') {
      return '每周'
    }
    if (this.repeatType === 'monthly') {
      return '每月'
    }
    return '不重复'
  }
}

export class YunAnniversaryItem {
  id: string = ''
  title: string = ''
  dateKey: string = ''
  yearly: boolean = true
  createdAt: number = 0

  static create(id: string, title: string, dateKey: string): YunAnniversaryItem {
    const a = new YunAnniversaryItem()
    a.id = id
    a.title = title
    a.dateKey = dateKey
    a.createdAt = Date.now()
    return a
  }
}

export class YunTagRecord {
  name: string = ''
  usageCount: number = 0

  static create(name: string, count: number): YunTagRecord {
    const r = new YunTagRecord()
    r.name = name
    r.usageCount = count
    return r
  }
}

export class YunAppStats {
  noteCount: number = 0
  streakDays: number = 0
  imageCount: number = 0
  todoActive: number = 0
  todoDone: number = 0
  anniversaryCount: number = 0
  habitCheckins: number = 0
  moodDays: number = 0
  craftCount: number = 0
  goalOpen: number = 0
  archiveDays: number = 0
}

export class YunHabitItem {
  id: string = ''
  title: string = ''
  lastDate: string = ''
  streak: number = 0
  totalDays: number = 0
  createdAt: number = 0

  static create(id: string, title: string): YunHabitItem {
    const h = new YunHabitItem()
    h.id = id
    h.title = title
    h.createdAt = Date.now()
    return h
  }

  checkedToday(todayKey: string): boolean {
    return this.lastDate === todayKey
  }
}

export class YunMoodDay {
  dateKey: string = ''
  mood: string = ''
  note: string = ''

  static create(dateKey: string, mood: string, note: string): YunMoodDay {
    const m = new YunMoodDay()
    m.dateKey = dateKey
    m.mood = mood
    m.note = note
    return m
  }
}

export class YunNoteTemplate {
  key: string = ''
  title: string = ''
  category: string = ''
  hint: string = ''
  tag: string = ''

  static create(key: string, title: string, category: string, hint: string, tag: string): YunNoteTemplate {
    const t = new YunNoteTemplate()
    t.key = key
    t.title = title
    t.category = category
    t.hint = hint
    t.tag = tag
    return t
  }

  static all(): YunNoteTemplate[] {
    const list: YunNoteTemplate[] = []
    list.push(YunNoteTemplate.create('mood', '今日心情', '家庭', '今天的心情如何？写下一句真实感受。', '温暖瞬间'))
    list.push(YunNoteTemplate.create('food', '美食记录', '美食', '吃了什么、味道如何、想不想再去。', '美食'))
    list.push(YunNoteTemplate.create('travel', '旅行见闻', '旅行', '今天走过的路、看到的风景。', '旅行'))
    list.push(YunNoteTemplate.create('family', '家庭时光', '家庭', '和家人在一起的片刻。', '家庭'))
    list.push(YunNoteTemplate.create('idea', '灵感记录', '兴趣', '突然冒出的想法，先记下来。', '灵感'))
    list.push(YunNoteTemplate.create('grow', '成长感悟', '学习', '今天学到了什么、想改变什么。', '成长'))
    return list
  }

  static find(key: string): YunNoteTemplate | undefined {
    const all = YunNoteTemplate.all()
    for (const t of all) {
      if (t.key === key) {
        return t
      }
    }
    return undefined
  }

  static categories(): string[] {
    return ['日常', '家庭', '美食', '旅行', '学习', '工作', '兴趣']
  }

  static moods(): string[] {
    return ['平静', '开心', '满足', '期待', '疲惫', '专注', '低落', '轻松']
  }
}

export class YunMonthlyReview {
  monthKey: string = ''
  noteCount: number = 0
  photoCount: number = 0
  checkinCount: number = 0
  topTag: string = ''
  summary: string = ''
}

export class YunTimelineGroup {
  dateKey: string = ''
  displayLabel: string = ''
  notes: YunNoteItem[] = []

  static create(dateKey: string, label: string): YunTimelineGroup {
    const g = new YunTimelineGroup()
    g.dateKey = dateKey
    g.displayLabel = label
    return g
  }
}

export class YunAlbumGroup {
  groupKey: string = ''
  displayLabel: string = ''
  notes: YunNoteItem[] = []

  static create(groupKey: string, label: string): YunAlbumGroup {
    const g = new YunAlbumGroup()
    g.groupKey = groupKey
    g.displayLabel = label
    return g
  }
}

export class YunTodayMemo {
  text: string = ''
  hint: string = ''

  static create(text: string, hint: string): YunTodayMemo {
    const m = new YunTodayMemo()
    m.text = text
    m.hint = hint
    return m
  }
}

export class YunCraftItem {
  id: string = ''
  kind: string = 'tip'
  title: string = ''
  body: string = ''
  extra: string = ''
  category: string = '家庭'
  pinned: boolean = false
  progress: number = 0
  createdAt: number = 0
  updatedAt: number = 0

  static create(id: string, kind: string, title: string): YunCraftItem {
    const it = new YunCraftItem()
    it.id = id
    it.kind = kind
    it.title = title
    it.createdAt = Date.now()
    it.updatedAt = it.createdAt
    return it
  }

  kindLabel(): string {
    if (this.kind === 'issue') {
      return '问题'
    }
    if (this.kind === 'goal') {
      return '目标'
    }
    if (this.kind === 'plan') {
      return '方案'
    }
    if (this.kind === 'challenge') {
      return '挑战'
    }
    if (this.kind === 'idea') {
      return '灵感'
    }
    return '经验'
  }

  progressLabel(): string {
    if (this.kind === 'goal') {
      return `进度 ${this.progress}%`
    }
    if (this.kind === 'challenge') {
      const target = this.extra.length > 0 ? this.extra : '7'
      return `已完成 ${this.progress} / ${target} 天`
    }
    return ''
  }

  summary(maxLen: number): string {
    const raw = this.body.length > 0 ? this.body : this.extra
    if (raw.length <= maxLen) {
      return raw
    }
    return `${raw.substring(0, maxLen)}…`
  }
}

export class YunCraftPreset {
  kind: string = 'tip'
  title: string = ''
  category: string = ''
  extra: string = ''
  body: string = ''

  static create(kind: string, title: string, category: string, extra: string, body: string): YunCraftPreset {
    const p = new YunCraftPreset()
    p.kind = kind
    p.title = title
    p.category = category
    p.extra = extra
    p.body = body
    return p
  }

  static kinds(): string[] {
    return ['all', 'tip', 'issue', 'goal', 'plan', 'challenge', 'idea', 'pin']
  }

  static kindLabel(kind: string): string {
    if (kind === 'tip') {
      return '经验'
    }
    if (kind === 'issue') {
      return '问题'
    }
    if (kind === 'goal') {
      return '目标'
    }
    if (kind === 'plan') {
      return '方案'
    }
    if (kind === 'challenge') {
      return '挑战'
    }
    if (kind === 'idea') {
      return '灵感'
    }
    if (kind === 'pin') {
      return '收藏'
    }
    return '全部'
  }

  static board(): string[] {
    return ['家庭', '学习', '工作', '兴趣', '成长']
  }

  static tipCats(): string[] {
    return ['清洁', '做饭', '收纳', '学习', '家庭', '出行']
  }

  static goalCycles(): string[] {
    return ['每周', '每月', '持续']
  }

  static starters(): YunCraftPreset[] {
    const list: YunCraftPreset[] = []
    list.push(YunCraftPreset.create('tip', '清洁技巧', '家庭', '', '写下你常用的清洁步骤。'))
    list.push(YunCraftPreset.create('tip', '做饭心得', '家庭', '', '记下火候、调味或省时做法。'))
    list.push(YunCraftPreset.create('tip', '收纳方法', '家庭', '', '空间怎么分、东西怎么放。'))
    list.push(YunCraftPreset.create('tip', '学习方法', '学习', '', '适合自己的复习或记录方法。'))
    list.push(YunCraftPreset.create('issue', '衣服缩水怎么办', '家庭', '记下你用过的处理方法', '描述遇到的问题'))
    list.push(YunCraftPreset.create('goal', '每周整理房间', '家庭', '每周', '本周完成一次整理即可记进度。'))
    list.push(YunCraftPreset.create('goal', '每月阅读计划', '学习', '每月', '写下本月想读完的书或页数。'))
    list.push(YunCraftPreset.create('plan', '家庭整理方案', '家庭', '', '1. 分区\n2. 断舍离\n3. 归位'))
    list.push(YunCraftPreset.create('plan', '出行准备方案', '兴趣', '', '证件、药品、充电、路线'))
    list.push(YunCraftPreset.create('plan', '节日准备方案', '家庭', '', '采购、布置、礼物、菜单'))
    list.push(YunCraftPreset.create('challenge', '连续7天整理桌面', '家庭', '7', '每天花 5 分钟清桌面。'))
    list.push(YunCraftPreset.create('idea', '生活灵感', '成长', '', '突然冒出的想法，先记下来再慢慢完善。'))
    return list
  }
}

export class YunListTemplate {
  key: string = ''
  title: string = ''
  listKind: string = 'chore'
  lines: string[] = []

  static create(key: string, title: string, listKind: string): YunListTemplate {
    const t = new YunListTemplate()
    t.key = key
    t.title = title
    t.listKind = listKind
    return t
  }

  static all(): YunListTemplate[] {
    const list: YunListTemplate[] = []
    const move = YunListTemplate.create('move', '搬家准备清单', 'chore')
    move.lines.push('纸箱与胶带')
    move.lines.push('断舍离分类')
    move.lines.push('水电燃气过户')
    move.lines.push('新居清洁')
    list.push(move)
    const weekend = YunListTemplate.create('weekend', '周末计划清单', 'remind')
    weekend.lines.push('采购食材')
    weekend.lines.push('打扫房间')
    weekend.lines.push('安排休息')
    list.push(weekend)
    const fest = YunListTemplate.create('fest', '节日准备清单', 'chore')
    fest.lines.push('采购清单')
    fest.lines.push('布置与装饰')
    fest.lines.push('礼物准备')
    list.push(fest)
    const study = YunListTemplate.create('study', '学习计划清单', 'study')
    study.lines.push('复习要点')
    study.lines.push('练习题目')
    study.lines.push('当日小结')
    list.push(study)
    return list
  }
}
