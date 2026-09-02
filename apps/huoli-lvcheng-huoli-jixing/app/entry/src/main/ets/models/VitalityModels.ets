export class DimensionOption {
  key: string = ''
  label: string = ''
  score: number = 2

  static exerciseOptions(): DimensionOption[] {
    const opts: DimensionOption[] = []
    const defs: string[][] = [
      ['easy', '轻松', '1'],
      ['moderate', '适中', '2'],
      ['full', '充足', '3']
    ]
    for (const d of defs) {
      const o = new DimensionOption()
      o.key = d[0]
      o.label = d[1]
      o.score = parseInt(d[2], 10)
      opts.push(o)
    }
    return opts
  }

  static moodOptions(): DimensionOption[] {
    const opts: DimensionOption[] = []
    const defs: string[][] = [
      ['happy', '愉悦', '3'],
      ['calm', '平静', '2'],
      ['tired', '疲惫', '1']
    ]
    for (const d of defs) {
      const o = new DimensionOption()
      o.key = d[0]
      o.label = d[1]
      o.score = parseInt(d[2], 10)
      opts.push(o)
    }
    return opts
  }

  static energyOptions(): DimensionOption[] {
    const opts: DimensionOption[] = []
    const defs: string[][] = [
      ['high', '充沛', '3'],
      ['normal', '一般', '2'],
      ['low', '不足', '1']
    ]
    for (const d of defs) {
      const o = new DimensionOption()
      o.key = d[0]
      o.label = d[1]
      o.score = parseInt(d[2], 10)
      opts.push(o)
    }
    return opts
  }

  static labelFor(kind: string, key: string): string {
    let list: DimensionOption[] = []
    if (kind === 'exercise') {
      list = DimensionOption.exerciseOptions()
    } else if (kind === 'mood') {
      list = DimensionOption.moodOptions()
    } else {
      list = DimensionOption.energyOptions()
    }
    for (const o of list) {
      if (o.key === key) {
        return o.label
      }
    }
    return key
  }
}

export class VitalityRecord {
  dateKey: string = ''
  exerciseKey: string = ''
  moodKey: string = ''
  energyKey: string = ''
  note: string = ''
  timestamp: number = 0
  tagKeys: string = ''

  static createNew(dateKey: string): VitalityRecord {
    const r = new VitalityRecord()
    r.dateKey = dateKey
    r.timestamp = Date.now()
    return r
  }

  vitalityScore(): number {
    const ex = DimensionOption.exerciseOptions()
    const mo = DimensionOption.moodOptions()
    const en = DimensionOption.energyOptions()
    let s = 0
    let c = 0
    for (const o of ex) {
      if (o.key === this.exerciseKey) {
        s += o.score
        c++
      }
    }
    for (const o of mo) {
      if (o.key === this.moodKey) {
        s += o.score
        c++
      }
    }
    for (const o of en) {
      if (o.key === this.energyKey) {
        s += o.score
        c++
      }
    }
    if (c === 0) {
      return 0
    }
    return Math.round((s / c) * 33.3)
  }

  isComplete(): boolean {
    return this.exerciseKey.length > 0 && this.moodKey.length > 0 && this.energyKey.length > 0
  }
}

export class UserProfile {
  nickname: string = '活力旅人'
  avatarKey: string = 'default'
  reminderHour: number = 20
  reminderMinute: number = 0
  reminderEnabled: boolean = false
  themeMode: string = 'system'
  weeklyGoalDays: number = 5
}

export class TrendPoint {
  dateKey: string = ''
  label: string = ''
  score: number = 0
}

export class DimensionStat {
  key: string = ''
  label: string = ''
  count: number = 0
  ratio: number = 0
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

export class MonthReport {
  monthLabel: string = ''
  checkInDays: number = 0
  avgScore: number = 0
  topMood: string = ''
  summary: string = ''
}

export class MicroAction {
  id: string = ''
  dateKey: string = ''
  title: string = ''
  hint: string = ''
  done: boolean = false
}

export class WeekCompare {
  thisAvg: number = 0
  lastAvg: number = 0
  delta: number = 0
  thisDays: number = 0
  lastDays: number = 0
}

export class VitalityNote {
  id: string = ''
  title: string = ''
  body: string = ''
  dateKey: string = ''
  createdAt: number = 0
  favorite: boolean = false
  tagKeys: string = ''
  topicIds: string = ''
}

export class SavedActionItem {
  id: string = ''
  title: string = ''
  hint: string = ''
  category: string = ''
  source: string = 'builtin'
  usageCount: number = 0
}

export class VitalityPlan {
  id: string = ''
  title: string = ''
  planType: string = 'checkin'
  targetValue: number = 5
  currentValue: number = 0
  startKey: string = ''
  endKey: string = ''
  status: string = 'active'

  copy(): VitalityPlan {
    const c = new VitalityPlan()
    c.id = this.id
    c.title = this.title
    c.planType = this.planType
    c.targetValue = this.targetValue
    c.currentValue = this.currentValue
    c.startKey = this.startKey
    c.endKey = this.endKey
    c.status = this.status
    return c
  }
}

export class PrescriptionStats {
  done: number = 0
  total: number = 0
}

export class TimelineEvent {
  id: string = ''
  eventType: string = ''
  dateKey: string = ''
  title: string = ''
  summary: string = ''
  refId: string = ''
  timestamp: number = 0
}

export class DashboardStats {
  totalRecords: number = 0
  monthRecords: number = 0
  prescriptionDone: number = 0
  prescriptionTotal: number = 0
  favoriteCount: number = 0
  noteCount: number = 0
}

export class VitalityTagOption {
  key: string = ''
  label: string = ''

  static all(): VitalityTagOption[] {
    const opts: VitalityTagOption[] = []
    const defs: string[][] = [
      ['restore', '恢复'],
      ['move', '运动'],
      ['social', '社交'],
      ['work', '工作'],
      ['travel', '出行']
    ]
    for (const d of defs) {
      const o = new VitalityTagOption()
      o.key = d[0]
      o.label = d[1]
      opts.push(o)
    }
    return opts
  }

  static labelFor(key: string): string {
    for (const o of VitalityTagOption.all()) {
      if (o.key === key) {
        return o.label
      }
    }
    return key
  }
}

export class VitalityTopic {
  id: string = ''
  title: string = ''
  emoji: string = ''
  noteIds: string = ''
  recordKeys: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}

export class YearReport {
  year: number = 0
  checkInDays: number = 0
  avgScore: number = 0
  topMood: string = ''
  summary: string = ''
}

export class TodayProgress {
  percent: number = 0
  checkedIn: boolean = false
  prescriptionDone: number = 0
  prescriptionTotal: number = 0
  weekDone: number = 0
  weekGoal: number = 5
}

export class AchievementProgress {
  id: string = ''
  title: string = ''
  description: string = ''
  unlocked: boolean = false
  current: number = 0
  target: number = 1
  hint: string = ''
}
