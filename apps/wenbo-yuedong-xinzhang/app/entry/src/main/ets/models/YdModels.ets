export class YdTaskItem {
  id: string = ''
  title: string = ''
  timeSlot: string = ''
  priority: string = 'medium'
  done: boolean = false
  dateKey: string = ''
  createdAt: number = 0
  domain: string = 'work'
  durationMin: number = 30
  note: string = ''

  domainLabel(): string {
    if (this.domain === 'study') {
      return '学习'
    }
    if (this.domain === 'life') {
      return '生活'
    }
    return '工作'
  }

  hourKey(): number {
    if (this.timeSlot.length < 2) {
      return 9
    }
    const n = parseInt(this.timeSlot.substring(0, 2), 10)
    return Number.isNaN(n) ? 9 : n
  }

  static newId(): string {
    return `t_${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }

  static todayKey(): string {
    const d = new Date()
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const ds = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const dd = ds < 10 ? `0${ds}` : `${ds}`
    return `${y}-${ms}-${dd}`
  }

  priorityLabel(): string {
    if (this.priority === 'high') {
      return '高'
    }
    if (this.priority === 'low') {
      return '低'
    }
    return '中'
  }

  priorityColor(): string {
    if (this.priority === 'high') {
      return '#E53935'
    }
    if (this.priority === 'low') {
      return '#43A047'
    }
    return '#007DFF'
  }
}

export class YdMilestoneItem {
  id: string = ''
  title: string = ''
  done: boolean = false

  static newId(): string {
    return `m_${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }
}

export class YdGoalItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  milestones: YdMilestoneItem[] = []
  archived: boolean = false
  createdAt: number = 0

  static newId(): string {
    return `g_${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }

  progressPercent(): number {
    if (this.milestones.length === 0) {
      return 0
    }
    let done = 0
    for (const m of this.milestones) {
      if (m.done) {
        done++
      }
    }
    return Math.floor((done * 100) / this.milestones.length)
  }

  doneCount(): number {
    let n = 0
    for (const m of this.milestones) {
      if (m.done) {
        n++
      }
    }
    return n
  }
}

export class YdUserProfile {
  nickname: string = '跃动用户'
  avatarKey: string = 'default'
}

export class YdBadgeItem {
  id: string = ''
  title: string = ''
  desc: string = ''
  unlocked: boolean = false
  thresholdDays: number = 0
}

export class YdReviewStats {
  todayTotal: number = 0
  todayDone: number = 0
  weekDone: number = 0
  monthDone: number = 0
  streakDays: number = 0
  completionRate: number = 0
  workMin: number = 0
  studyMin: number = 0
  lifeMin: number = 0
  leapIndex: number = 0
  chapterClosed: number = 0
}

/** 人生篇章：一段有主题、有期限、须写章末复盘的成长单元（非系统日历） */
export class YdChapterItem {
  id: string = ''
  title: string = ''
  theme: string = 'career'
  startKey: string = ''
  endKey: string = ''
  recap: string = ''
  closed: boolean = false
  createdAt: number = 0

  static newId(): string {
    return `c_${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }

  themeLabel(): string {
    if (this.theme === 'exam') {
      return '备考冲刺'
    }
    if (this.theme === 'health') {
      return '生活节律'
    }
    if (this.theme === 'reading') {
      return '阅读新章'
    }
    return '职场跃升'
  }

  remainDays(): number {
    if (this.closed || this.endKey.length === 0) {
      return 0
    }
    const today = YdTaskItem.todayKey()
    if (today > this.endKey) {
      return 0
    }
    const a = YdChapterItem.parseKey(today)
    const b = YdChapterItem.parseKey(this.endKey)
    const diff = Math.floor((b - a) / 86400000)
    return diff < 0 ? 0 : diff
  }

  totalDays(): number {
    if (this.startKey.length === 0 || this.endKey.length === 0) {
      return 1
    }
    const a = YdChapterItem.parseKey(this.startKey)
    const b = YdChapterItem.parseKey(this.endKey)
    const diff = Math.floor((b - a) / 86400000) + 1
    return diff < 1 ? 1 : diff
  }

  elapsedDays(): number {
    if (this.startKey.length === 0) {
      return 0
    }
    const today = YdTaskItem.todayKey()
    const a = YdChapterItem.parseKey(this.startKey)
    const b = YdChapterItem.parseKey(today)
    const diff = Math.floor((b - a) / 86400000) + 1
    if (diff < 1) {
      return 0
    }
    const total = this.totalDays()
    return diff > total ? total : diff
  }

  chapterProgressPercent(): number {
    const total = this.totalDays()
    if (total <= 0) {
      return 0
    }
    return Math.min(100, Math.floor((this.elapsedDays() * 100) / total))
  }

  themeQuote(): string {
    if (this.theme === 'exam') {
      return '把每一天变成可累积的分数，而不是可拖延的明天。'
    }
    if (this.theme === 'health') {
      return '节律比强度更重要，小步持续胜过一次爆发。'
    }
    if (this.theme === 'reading') {
      return '读一页，记一步，让新知在复盘里落地。'
    }
    return '把行动写进时间账，让跃升可被看见。'
  }

  static parseKey(key: string): number {
    const p = key.split('-')
    if (p.length !== 3) {
      return Date.now()
    }
    return new Date(parseInt(p[0], 10), parseInt(p[1], 10) - 1, parseInt(p[2], 10)).getTime()
  }
}

export class YdHourSlot {
  hour: number = 0
  label: string = ''
  items: YdTaskItem[] = []
}

export class YdWeekDayStat {
  dateKey: string = ''
  weekday: string = ''
  doneCount: number = 0
  totalCount: number = 0

  completionPercent(): number {
    if (this.totalCount === 0) {
      return 0
    }
    return Math.floor((this.doneCount * 100) / this.totalCount)
  }
}

export class YdFavoriteRef {
  id: string = ''
  entityType: string = 'task'
  entityId: string = ''
  title: string = ''
  createdAt: number = 0

  static newId(): string {
    return `fav_${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }

  typeLabel(): string {
    if (this.entityType === 'chapter') {
      return '篇章'
    }
    if (this.entityType === 'goal') {
      return '目标'
    }
    if (this.entityType === 'note') {
      return '微记'
    }
    return '任务'
  }
}

export class YdCheckIn {
  dateKey: string = ''
  note: string = ''
  createdAt: number = 0
}

export class YdTag {
  id: string = ''
  label: string = ''
  colorKey: string = 'blue'

  static newId(): string {
    return `tag_${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }

  colorHex(): string {
    if (this.colorKey === 'green') {
      return '#0F766E'
    }
    if (this.colorKey === 'purple') {
      return '#6366F1'
    }
    if (this.colorKey === 'orange') {
      return '#EA580C'
    }
    return '#007DFF'
  }
}

export class YdTimelineEvent {
  id: string = ''
  dateKey: string = ''
  timeMs: number = 0
  kind: string = ''
  title: string = ''
  refType: string = ''
  refId: string = ''

  kindLabel(): string {
    if (this.kind === 'task_done') {
      return '完成任务'
    }
    if (this.kind === 'task_create') {
      return '新建任务'
    }
    if (this.kind === 'chapter_open') {
      return '开启篇章'
    }
    if (this.kind === 'chapter_close') {
      return '篇章收官'
    }
    if (this.kind === 'goal_archive') {
      return '目标达成'
    }
    if (this.kind === 'checkin') {
      return '今日跃动'
    }
    if (this.kind === 'note') {
      return '今日微记'
    }
    if (this.kind === 'favorite') {
      return '加入收藏'
    }
    return '动态'
  }
}

export class YdSearchHit {
  entityType: string = ''
  entityId: string = ''
  title: string = ''
  subtitle: string = ''
  dateKey: string = ''
}

export class YdHomeSummary {
  taskTotal: number = 0
  taskDoneAll: number = 0
  favoriteCount: number = 0
  streakDays: number = 0
  leapIndex: number = 0
  todayDone: number = 0
  todayTotal: number = 0
  checkInToday: boolean = false
}
