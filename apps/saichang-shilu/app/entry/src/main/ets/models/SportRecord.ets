export class SportRecord {
  id: string = ''
  sportType: string = 'running'
  title: string = ''
  date: string = ''
  time: string = ''
  location: string = ''
  opponent: string = ''
  duration: number = 0
  distance: number = 0
  score: string = ''
  heartRate: string = ''
  note: string = ''
  photos: string[] = []
  result: string = ''
  momentsPacked: string = ''
  recapSummary: string = ''
  recapScore: string = ''
  status: string = 'want'
  rating: number = 0
  season: string = ''
  tagsPacked: string = ''
  homeTeam: string = ''
  recapPhases: string = ''
  mvpName: string = ''
  prediction: string = ''
  checklistPacked: string = ''
  pinned: boolean = false
  rateQuality: number = 0
  rateIntensity: number = 0
  rateAtmosphere: number = 0
  watchPlan: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(): SportRecord {
    const r = new SportRecord()
    r.id = `sr_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    const now = new Date()
    r.date = SportRecord.formatDate(now)
    r.time = SportRecord.formatTime(now)
    r.season = `${now.getFullYear()}`
    r.status = 'want'
    r.createdAt = Date.now()
    r.updatedAt = r.createdAt
    return r
  }

  static cloneFrom(source: SportRecord): SportRecord {
    const r = new SportRecord()
    r.id = source.id
    r.sportType = source.sportType
    r.title = source.title
    r.date = source.date
    r.time = source.time
    r.location = source.location
    r.opponent = source.opponent
    r.duration = source.duration
    r.distance = source.distance
    r.score = source.score
    r.heartRate = source.heartRate
    r.note = source.note
    r.photos = source.photos
    r.result = source.result
    r.momentsPacked = source.momentsPacked
    r.recapSummary = source.recapSummary
    r.recapScore = source.recapScore
    r.status = source.status
    r.rating = source.rating
    r.season = source.season
    r.tagsPacked = source.tagsPacked
    r.homeTeam = source.homeTeam
    r.recapPhases = source.recapPhases
    r.mvpName = source.mvpName
    r.prediction = source.prediction
    r.checklistPacked = source.checklistPacked
    r.pinned = source.pinned
    r.rateQuality = source.rateQuality
    r.rateIntensity = source.rateIntensity
    r.rateAtmosphere = source.rateAtmosphere
    r.watchPlan = source.watchPlan
    r.createdAt = source.createdAt
    r.updatedAt = source.updatedAt
    return r
  }

  static formatDate(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static formatTime(d: Date): string {
    const h = d.getHours()
    const min = d.getMinutes()
    const hs = h < 10 ? `0${h}` : `${h}`
    const mins = min < 10 ? `0${min}` : `${min}`
    return `${hs}:${mins}`
  }

  coverPhoto(): string {
    if (this.photos.length > 0) {
      return this.photos[0]
    }
    return ''
  }

  summaryLine(): string {
    const parts: string[] = []
    if (this.status === 'want') {
      parts.push('待看')
    } else if (this.status === 'focus') {
      parts.push('重点关注')
    }
    if (this.homeTeam.length > 0 && this.opponent.length > 0) {
      parts.push(`${this.homeTeam} vs ${this.opponent}`)
    } else if (this.location.length > 0) {
      parts.push(this.location)
    }
    if (this.duration > 0) {
      parts.push(`${this.duration} 分钟`)
    }
    if (this.distance > 0) {
      parts.push(`${this.distance} 公里`)
    }
    if (parts.length === 0) {
      return this.note.length > 0 ? this.note.substring(0, 40) : '点击查看详情'
    }
    return parts.join(' · ')
  }
}

export class SportStats {
  totalCount: number = 0
  totalMinutes: number = 0
  topSportType: string = ''
  topSportLabel: string = ''
  monthCount: number = 0
  typeCounts: SportTypeCount[] = []
}

export class SportTypeCount {
  sportType: string = ''
  label: string = ''
  count: number = 0
  percent: number = 0
}

export class SportTypeOption {
  id: string = ''
  label: string = ''
  emoji: string = ''

  static all(): SportTypeOption[] {
    const out: SportTypeOption[] = []
    const defs: string[][] = [
      ['running', '跑步', '🏃'],
      ['basketball', '篮球', '🏀'],
      ['football', '足球', '⚽'],
      ['badminton', '羽毛球', '🏸'],
      ['swimming', '游泳', '🏊'],
      ['fitness', '健身', '💪'],
      ['other', '其他', '🎯']
    ]
    for (const row of defs) {
      const o = new SportTypeOption()
      o.id = row[0]
      o.label = row[1]
      o.emoji = row[2]
      out.push(o)
    }
    return out
  }

  static labelOf(id: string): string {
    for (const o of SportTypeOption.all()) {
      if (o.id === id) {
        return o.label
      }
    }
    return '其他'
  }

  static emojiOf(id: string): string {
    for (const o of SportTypeOption.all()) {
      if (o.id === id) {
        return o.emoji
      }
    }
    return '🎯'
  }
}

export class UserProfile {
  nickname: string = '运动爱好者'
  avatarPath: string = ''
  preferredSports: string[] = []
}
