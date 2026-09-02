export class SportEvent {
  id: string = ''
  title: string = ''
  eventDate: string = ''
  sportType: string = 'mixed'
  kind: string = 'record'
  status: string = 'done'
  highlight: string = ''
  body: string = ''
  tags: string = ''
  albumId: string = ''
  favorite: boolean = false
  homeName: string = ''
  awayName: string = ''
  homeScore: string = ''
  awayScore: string = ''
  watchMode: string = ''
  mood: number = 0
  images: string[] = []
  reviewScene: string = ''
  reviewKeyMoment: string = ''
  reviewEmotion: string = ''
  reviewTakeaway: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  static create(kind: string): SportEvent {
    const e = new SportEvent()
    e.id = `sev_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    e.kind = kind
    e.status = kind === 'plan' ? 'pending' : 'done'
    const now = Date.now()
    e.createdAt = now
    e.updatedAt = now
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    e.eventDate = `${d.getFullYear()}-${ms}-${ds}`
    return e
  }

  kindLabel(): string {
    if (this.kind === 'note') {
      return '比赛笔记'
    }
    if (this.kind === 'review') {
      return '赛事复盘'
    }
    if (this.kind === 'plan') {
      return '观赛计划'
    }
    return '赛事记录'
  }

  typeLabel(): string {
    if (this.sportType === 'football') {
      return '足球'
    }
    if (this.sportType === 'basketball') {
      return '篮球'
    }
    if (this.sportType === 'tennis') {
      return '网球'
    }
    if (this.sportType === 'esports') {
      return '电竞'
    }
    return '综合'
  }

  statusLabel(): string {
    if (this.status === 'pending') {
      return '待关注'
    }
    if (this.status === 'reviewed') {
      return '已回顾'
    }
    return '已完成'
  }

  summaryLine(): string {
    if (this.hasScore()) {
      return this.scoreLine()
    }
    const src = this.highlight.length > 0 ? this.highlight : this.body
    const t = src.replace(/\n/g, ' ').trim()
    if (t.length <= 48) {
      return t
    }
    return `${t.substring(0, 48)}…`
  }

  hasScore(): boolean {
    return this.homeName.length > 0 && this.awayName.length > 0
  }

  scoreLine(): string {
    if (!this.hasScore()) {
      return ''
    }
    const hs = this.homeScore.length > 0 ? this.homeScore : '-'
    const as = this.awayScore.length > 0 ? this.awayScore : '-'
    return `${this.homeName} ${hs} : ${as} ${this.awayName}`
  }

  watchModeLabel(): string {
    if (this.watchMode === 'live') {
      return '现场观赛'
    }
    if (this.watchMode === 'tv') {
      return '转播/屏幕'
    }
    if (this.watchMode === 'play') {
      return '亲自参赛'
    }
    return ''
  }

  moodStars(): string {
    if (this.mood <= 0) {
      return ''
    }
    let s = ''
    for (let i = 0; i < this.mood; i++) {
      s += '★'
    }
    return s
  }

  hasReviewSections(): boolean {
    return this.reviewScene.length > 0 || this.reviewKeyMoment.length > 0 ||
      this.reviewEmotion.length > 0 || this.reviewTakeaway.length > 0
  }

  reviewExportText(): string {
    const lines: string[] = []
    lines.push(`【${this.title}】${this.eventDate}`)
    if (this.scoreLine().length > 0) {
      lines.push(this.scoreLine())
    }
    if (this.reviewScene.length > 0) {
      lines.push(`场面：${this.reviewScene}`)
    }
    if (this.reviewKeyMoment.length > 0) {
      lines.push(`关键球/节点：${this.reviewKeyMoment}`)
    }
    if (this.reviewEmotion.length > 0) {
      lines.push(`情绪：${this.reviewEmotion}`)
    }
    if (this.reviewTakeaway.length > 0) {
      lines.push(`带走一句：${this.reviewTakeaway}`)
    }
    if (this.body.length > 0) {
      lines.push(this.body)
    }
    return lines.join('\n')
  }

  static sportTypes(): string[] {
    return ['football', 'basketball', 'tennis', 'esports', 'mixed']
  }

  static typeName(key: string): string {
    const e = new SportEvent()
    e.sportType = key
    return e.typeLabel()
  }
}

export class SportAlbum {
  id: string = ''
  title: string = ''
  description: string = ''
  createdAt: number = 0

  static create(): SportAlbum {
    const a = new SportAlbum()
    a.id = `alb_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    a.createdAt = Date.now()
    return a
  }
}

export class SportFollow {
  id: string = ''
  name: string = ''
  role: string = 'team'
  note: string = ''
  createdAt: number = 0

  static create(): SportFollow {
    const f = new SportFollow()
    f.id = `fol_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    f.createdAt = Date.now()
    return f
  }

  roleLabel(): string {
    return this.role === 'player' ? '选手' : '球队'
  }
}

export class SportStats {
  records: number = 0
  notes: number = 0
  reviews: number = 0
  plans: number = 0
  albums: number = 0
  follows: number = 0
  pendingPlans: number = 0
  trainings: number = 0
}

export class TrainingLog {
  id: string = ''
  title: string = ''
  logDate: string = ''
  sportType: string = 'mixed'
  durationMin: number = 30
  intensity: number = 3
  journeyId: string = ''
  body: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  static create(): TrainingLog {
    const t = new TrainingLog()
    t.id = `trn_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    t.logDate = `${d.getFullYear()}-${ms}-${ds}`
    const now = Date.now()
    t.createdAt = now
    t.updatedAt = now
    return t
  }

  typeLabel(): string {
    const e = new SportEvent()
    e.sportType = this.sportType
    return e.typeLabel()
  }

  summaryLine(): string {
    const src = this.body.replace(/\n/g, ' ').trim()
    if (src.length <= 40) {
      return `${this.durationMin}分钟 · ${src}`
    }
    return `${this.durationMin}分钟 · ${src.substring(0, 40)}…`
  }
}
