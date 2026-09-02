import { DateHelper } from '../services/DateHelper'

export class WorkoutTypeOption {
  key: string = ''
  label: string = ''
  iconName: string = ''
  speedKmh: number = 0

  static all(): WorkoutTypeOption[] {
    const out: WorkoutTypeOption[] = []
    const defs: string[][] = [
      ['run', '跑步', 'figure_run', '8'],
      ['hike', '徒步', 'figure_walk', '5'],
      ['bike', '骑行', 'bicycle', '15'],
      ['yoga', '瑜伽', 'lotus', '0'],
      ['gym', '健身训练', 'dumbbell', '0']
    ]
    for (const d of defs) {
      const o = new WorkoutTypeOption()
      o.key = d[0]
      o.label = d[1]
      o.iconName = d[2]
      o.speedKmh = parseFloat(d[3])
      out.push(o)
    }
    return out
  }

  static labelFor(key: string): string {
    for (const o of WorkoutTypeOption.all()) {
      if (o.key === key) {
        return o.label
      }
    }
    if (key === 'walk') {
      return '徒步'
    }
    if (key === 'free') {
      return '健身训练'
    }
    return '运动'
  }

  static canonical(key: string): string {
    if (key === 'walk') {
      return 'hike'
    }
    if (key === 'free') {
      return 'gym'
    }
    return key
  }
}

export class TagOption {
  key: string = ''
  label: string = ''

  static all(): TagOption[] {
    const out: TagOption[] = []
    const defs: string[][] = [
      ['morning', '晨练'],
      ['weekend', '周末运动'],
      ['indoor', '室内训练'],
      ['light', '轻运动']
    ]
    for (const d of defs) {
      const o = new TagOption()
      o.key = d[0]
      o.label = d[1]
      out.push(o)
    }
    return out
  }

  static labelFor(key: string): string {
    if (key.length === 0) {
      return '未分类'
    }
    for (const o of TagOption.all()) {
      if (o.key === key) {
        return o.label
      }
    }
    return key
  }
}

export class EnergyOption {
  key: string = ''
  label: string = ''

  static all(): EnergyOption[] {
    const out: EnergyOption[] = []
    const defs: string[][] = [
      ['high', '精力充沛'],
      ['mid', '状态一般'],
      ['low', '比较疲惫']
    ]
    for (const d of defs) {
      const o = new EnergyOption()
      o.key = d[0]
      o.label = d[1]
      out.push(o)
    }
    return out
  }

  static labelFor(key: string): string {
    if (key.length === 0) {
      return '未记录'
    }
    for (const o of EnergyOption.all()) {
      if (o.key === key) {
        return o.label
      }
    }
    return key
  }
}

export class WorkoutRecord {
  id: string = ''
  typeKey: string = 'run'
  durationSeconds: number = 0
  timestamp: number = 0
  dateKey: string = ''
  note: string = ''
  distanceKm: number = 0
  tagKey: string = ''
  energyKey: string = ''
  feeling: string = ''

  static create(typeKey: string, durationSeconds: number, note: string): WorkoutRecord {
    const d = new Date()
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return WorkoutRecord.createOnDate(typeKey, durationSeconds, note, `${y}-${ms}-${ds}`)
  }

  static createOnDate(typeKey: string, durationSeconds: number, note: string, dateKey: string): WorkoutRecord {
    const r = new WorkoutRecord()
    r.id = `w_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    r.typeKey = typeKey
    r.durationSeconds = durationSeconds
    r.dateKey = DateHelper.normalizeKey(dateKey)
    r.note = note
    r.distanceKm = WorkoutRecord.estimateDistance(typeKey, durationSeconds)
    r.timestamp = Date.now()
    return r
  }

  static copyFrom(source: WorkoutRecord): WorkoutRecord {
    const r = new WorkoutRecord()
    r.id = source.id
    r.typeKey = source.typeKey
    r.durationSeconds = source.durationSeconds
    r.timestamp = source.timestamp
    r.dateKey = source.dateKey
    r.note = source.note
    r.distanceKm = source.distanceKm
    r.tagKey = source.tagKey
    r.energyKey = source.energyKey
    r.feeling = source.feeling
    return r
  }

  static estimateDistance(typeKey: string, durationSeconds: number): number {
    let speed = 0
    for (const o of WorkoutTypeOption.all()) {
      if (o.key === typeKey) {
        speed = o.speedKmh
        break
      }
    }
    if (speed <= 0) {
      return 0
    }
    const hours = durationSeconds / 3600
    return Math.round(hours * speed * 100) / 100
  }

  durationMinutes(): number {
    return Math.max(1, Math.round(this.durationSeconds / 60))
  }

  paceLabel(): string {
    if (this.distanceKm <= 0 || this.durationSeconds <= 0) {
      return '--'
    }
    const minPerKm = this.durationSeconds / 60 / this.distanceKm
    const m = Math.floor(minPerKm)
    const s = Math.round((minPerKm - m) * 60)
    const ss = s < 10 ? `0${s}` : `${s}`
    return `${m}'${ss}"`
  }

  caloriesEstimate(): number {
    const mins = this.durationMinutes()
    let factor = 6
    if (this.typeKey === 'run') {
      factor = 10
    } else if (this.typeKey === 'bike') {
      factor = 8
    } else if (this.typeKey === 'hike' || this.typeKey === 'walk') {
      factor = 5
    } else if (this.typeKey === 'yoga') {
      factor = 4
    } else {
      factor = 7
    }
    return Math.round(mins * factor)
  }
}

export class UserSettings {
  nickname: string = '运动达人'
  themeMode: string = 'system'
  weeklyGoal: number = 3
  monthTarget: number = 20
}

export class WeekStats {
  count: number = 0
  totalMinutes: number = 0
  avgMinutes: number = 0
  maxMinutes: number = 0
}

export class MonthStats {
  count: number = 0
  totalMinutes: number = 0
  totalDistanceKm: number = 0
}

export class HomePageSnapshot {
  week: WeekStats = new WeekStats()
  month: MonthStats = new MonthStats()
  latest: WorkoutRecord | undefined = undefined
  latestInWeek: boolean = false
  weekRangeLabel: string = ''
}

export class AchievementDef {
  id: string = ''
  title: string = ''
  description: string = ''
  threshold: number = 0
}

export class AchievementState {
  id: string = ''
  unlockedAt: number = 0

  isUnlocked(): boolean {
    return this.unlockedAt > 0
  }
}

export class TrendBar {
  label: string = ''
  count: number = 0
}

export class TypeShare {
  typeKey: string = ''
  label: string = ''
  count: number = 0
  minutes: number = 0
}

export class PersonalBest {
  typeKey: string = ''
  label: string = ''
  durationSeconds: number = 0
  dateKey: string = ''
  workoutId: string = ''
}

export class WeeklySnapshot {
  id: string = ''
  weekStart: string = ''
  weekLabel: string = ''
  count: number = 0
  totalMinutes: number = 0
  topType: string = ''
  insight: string = ''
  reflection: string = ''
  pinned: number = 0

  isPinned(): boolean {
    return this.pinned === 1
  }
}
