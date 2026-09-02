export class WorkoutTypeOption {
  key: string = ''
  label: string = ''
  iconName: string = 'check'
  metFactor: number = 6

  static all(): WorkoutTypeOption[] {
    const out: WorkoutTypeOption[] = []
    const rows: string[][] = [
      ['running', '跑步', 'chart', '9'],
      ['cycling', '骑行', 'chart', '7'],
      ['swimming', '游泳', 'chart', '8'],
      ['strength', '力量', 'check', '6'],
      ['yoga', '瑜伽', 'empty', '3'],
      ['hiking', '徒步', 'biz', '5'],
      ['other', '其他', 'empty', '5']
    ]
    for (const row of rows) {
      const o = new WorkoutTypeOption()
      o.key = row[0]
      o.label = row[1]
      o.iconName = row[2]
      o.metFactor = parseInt(row[3], 10)
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
    return '运动'
  }

  static find(key: string): WorkoutTypeOption | undefined {
    for (const o of WorkoutTypeOption.all()) {
      if (o.key === key) {
        return o
      }
    }
    return undefined
  }
}

export class WorkoutRecord {
  id: string = ''
  typeKey: string = 'other'
  dateKey: string = ''
  durationMinutes: number = 0
  distanceKm: number = 0
  calories: number = 0
  caloriesManual: boolean = false
  heartRateZone: string = ''
  note: string = ''
  timestamp: number = 0
  feeling: string = ''
  tag: string = ''
  insight: string = ''
  completeState: string = 'done'
  sessionTitle: string = ''
  starRating: number = 0

  static createNew(dateKey: string): WorkoutRecord {
    const r = new WorkoutRecord()
    r.id = `${Date.now()}-${Math.floor(Math.random() * 10000)}`
    r.dateKey = dateKey
    r.timestamp = Date.now()
    return r
  }

  static estimateCalories(typeKey: string, durationMinutes: number): number {
    const opt = WorkoutTypeOption.find(typeKey)
    const met = opt !== undefined ? opt.metFactor : 5
    const weightKg = 65
    return Math.round(met * weightKg * (durationMinutes / 60))
  }
}

export class UserProfile {
  nickname: string = '运动达人'
  avatarKey: string = 'default'
  weeklyGoalDays: number = 5
  dailyGoalMinutes: number = 30
  themeMode: string = 'system'
  themeSpaceKey: string = ''
}

export class TrendPoint {
  dateKey: string = ''
  label: string = ''
  value: number = 0
}

export class HeatmapCell {
  dateKey: string = ''
  dayOfMonth: number = 0
  minutes: number = 0
  level: number = 0
}

export class WorkoutStats {
  totalWorkouts: number = 0
  totalMinutes: number = 0
  totalCalories: number = 0
  totalDistanceKm: number = 0
  streakDays: number = 0
  todayMinutes: number = 0
  weekActiveDays: number = 0
  weekGoalDays: number = 5
  mostCommonType: string = ''
  mostCommonTypeLabel: string = ''
}

export class PersonalBest {
  key: string = ''
  label: string = ''
  value: string = ''
  unit: string = ''
}

export class CoachingReport {
  title: string = ''
  paragraphs: string[] = []
}

export class AchievementDef {
  id: string = ''
  title: string = ''
  description: string = ''
  iconName: string = 'check'
}

export class AchievementState {
  id: string = ''
  title: string = ''
  description: string = ''
  unlocked: boolean = false
  unlockedAt: number = 0
}

export class WorkoutTagOption {
  key: string = ''
  label: string = ''

  static all(): WorkoutTagOption[] {
    const out: WorkoutTagOption[] = []
    const rows: string[][] = [
      ['morning', '晨练'],
      ['indoor', '室内训练'],
      ['recover', '恢复训练'],
      ['weekend', '周末训练']
    ]
    for (const row of rows) {
      const o = new WorkoutTagOption()
      o.key = row[0]
      o.label = row[1]
      out.push(o)
    }
    return out
  }

  static labelFor(key: string): string {
    for (const o of WorkoutTagOption.all()) {
      if (o.key === key) {
        return o.label
      }
    }
    return ''
  }
}

export class FeelingOption {
  key: string = ''
  label: string = ''

  static all(): FeelingOption[] {
    const out: FeelingOption[] = []
    const rows: string[][] = [
      ['easy', '轻松'],
      ['ok', '刚好'],
      ['hard', '吃力']
    ]
    for (const row of rows) {
      const o = new FeelingOption()
      o.key = row[0]
      o.label = row[1]
      out.push(o)
    }
    return out
  }

  static labelFor(key: string): string {
    for (const o of FeelingOption.all()) {
      if (o.key === key) {
        return o.label
      }
    }
    return ''
  }
}

export class CompleteStateOption {
  key: string = ''
  label: string = ''

  static all(): CompleteStateOption[] {
    const out: CompleteStateOption[] = []
    const rows: string[][] = [
      ['done', '已完成'],
      ['partial', '部分完成'],
      ['skip', '未完成']
    ]
    for (const row of rows) {
      const o = new CompleteStateOption()
      o.key = row[0]
      o.label = row[1]
      out.push(o)
    }
    return out
  }

  static labelFor(key: string): string {
    for (const o of CompleteStateOption.all()) {
      if (o.key === key) {
        return o.label
      }
    }
    return '已完成'
  }
}

export class PlanSlot {
  weekday: number = 0
  weekdayLabel: string = ''
  typeKey: string = 'running'
  targetMinutes: number = 30
  enabled: boolean = false

  static cloneOf(src: PlanSlot): PlanSlot {
    const s = new PlanSlot()
    s.weekday = src.weekday
    s.weekdayLabel = src.weekdayLabel
    s.typeKey = src.typeKey
    s.targetMinutes = src.targetMinutes
    s.enabled = src.enabled
    return s
  }
}

export class WeekPlan {
  weekKey: string = ''
  motto: string = ''
  slots: PlanSlot[] = []

  static empty(weekKey: string): WeekPlan {
    const p = new WeekPlan()
    p.weekKey = weekKey
    const names: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    for (let i = 0; i < 7; i++) {
      const s = new PlanSlot()
      s.weekday = i
      s.weekdayLabel = names[i]
      s.typeKey = 'running'
      s.targetMinutes = 30
      s.enabled = false
      p.slots.push(s)
    }
    return p
  }

  todaySlot(weekdayMon0: number): PlanSlot | undefined {
    for (const s of this.slots) {
      if (s.weekday === weekdayMon0) {
        return s
      }
    }
    return undefined
  }
}

export class MixBar {
  typeKey: string = ''
  label: string = ''
  minutes: number = 0
  ratio: number = 0
}

export class WeekCompareSnapshot {
  thisMinutes: number = 0
  lastMinutes: number = 0
  thisDays: number = 0
  lastDays: number = 0
  thisCalories: number = 0
  lastCalories: number = 0
  deltaMinutes: number = 0
}

export class AtlasReport {
  weekKey: string = ''
  title: string = ''
  rangeLabel: string = ''
  summary: string = ''
  advice: string = ''
  motto: string = ''
  peakDay: string = ''
  peakMinutes: number = 0
  mix: MixBar[] = []
  compare: WeekCompareSnapshot = new WeekCompareSnapshot()
}
