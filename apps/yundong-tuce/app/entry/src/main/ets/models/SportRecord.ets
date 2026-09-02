export class SportRecord {
  id: string = ''
  sportType: string = 'running'
  customTag: string = ''
  date: string = ''
  time: string = ''
  duration: number = 0
  distance: number = 0
  calories: number = 0
  weight: number = 0
  note: string = ''
  photos: string[] = []
  favorited: boolean = false
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(): SportRecord {
    const r = new SportRecord()
    r.id = `sr_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    const now = new Date()
    r.date = SportRecord.formatDate(now)
    r.time = SportRecord.formatTime(now)
    r.createdAt = Date.now()
    r.updatedAt = r.createdAt
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

  displayTitle(): string {
    if (this.customTag.length > 0) {
      return this.customTag
    }
    return SportTypeOption.labelOf(this.sportType)
  }

  primaryMetric(): string {
    if (this.distance > 0) {
      return `${this.distance.toFixed(2)} km`
    }
    if (this.duration > 0) {
      return `${this.duration} 分钟`
    }
    if (this.calories > 0) {
      return `${this.calories} kcal`
    }
    return ''
  }

  summaryLine(): string {
    const parts: string[] = []
    if (this.duration > 0) {
      parts.push(`${this.duration} 分钟`)
    }
    if (this.distance > 0) {
      parts.push(`${this.distance} km`)
    }
    if (this.calories > 0) {
      parts.push(`${this.calories} kcal`)
    }
    if (parts.length === 0 && this.note.length > 0) {
      return this.note.substring(0, 48)
    }
    return parts.join(' · ')
  }

  static suggestTag(sportType: string, distance: number, duration: number): string {
    if (sportType === 'running' && distance > 0) {
      return `晨跑 ${distance} 公里`
    }
    if (sportType === 'cycling' && distance > 0) {
      return `骑行 ${distance} 公里`
    }
    if (sportType === 'fitness' && duration > 0) {
      return `力量训练 ${duration} 分钟`
    }
    if (sportType === 'yoga' && duration > 0) {
      return `瑜伽流 ${duration} 分钟`
    }
    if (sportType === 'swimming' && duration > 0) {
      return `泳池 ${duration} 分钟`
    }
    if (duration > 0) {
      return `${SportTypeOption.labelOf(sportType)} ${duration} 分钟`
    }
    return SportTypeOption.labelOf(sportType)
  }
}

export class SportStats {
  totalCount: number = 0
  totalMinutes: number = 0
  totalPhotos: number = 0
  monthCount: number = 0
  topSportType: string = ''
  topSportLabel: string = ''
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
  glyph: string = ''

  static all(): SportTypeOption[] {
    const out: SportTypeOption[] = []
    const defs: string[][] = [
      ['running', '跑步', '跑'],
      ['fitness', '健身', '练'],
      ['yoga', '瑜伽', '瑜'],
      ['cycling', '骑行', '骑'],
      ['swimming', '游泳', '泳'],
      ['basketball', '篮球', '篮'],
      ['other', '其他', '动']
    ]
    for (const row of defs) {
      const o = new SportTypeOption()
      o.id = row[0]
      o.label = row[1]
      o.glyph = row[2]
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
}

export class UserProfile {
  nickname: string = '运动爱好者'
  avatarPath: string = ''
}

export class SportGoal {
  monthlySessions: number = 12
  yearlySessions: number = 120
}
