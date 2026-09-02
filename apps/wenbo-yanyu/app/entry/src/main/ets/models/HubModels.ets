/** 工作台 / 成长体系 — 本机数据模型 */
export class Manuscript {
  id: string = ''
  title: string = ''
  body: string = ''
  kind: string = 'polish'
  styleKey: string = ''
  sceneKey: string = ''
  modeKey: string = ''
  sourceText: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  static create(kind: string): Manuscript {
    const m = new Manuscript()
    m.id = `ms_${Date.now()}`
    m.kind = kind
    m.createdAt = Date.now()
    m.updatedAt = m.createdAt
    return m
  }
}

export class ActivityEvent {
  id: string = ''
  kind: string = ''
  title: string = ''
  summary: string = ''
  entityId: string = ''
  at: number = 0

  static of(kind: string, title: string, summary: string, entityId: string): ActivityEvent {
    const e = new ActivityEvent()
    e.id = `act_${Date.now()}_${kind}`
    e.kind = kind
    e.title = title
    e.summary = summary
    e.entityId = entityId
    e.at = Date.now()
    return e
  }
}

export class WritingGoal {
  weekKey: string = ''
  polishTarget: number = 5
  noteTarget: number = 3
  dailyTarget: number = 7
  polishDone: number = 0
  noteDone: number = 0
  dailyDone: number = 0

  polishPercent(): number {
    if (this.polishTarget <= 0) {
      return 0
    }
    const v = Math.floor((this.polishDone * 100) / this.polishTarget)
    return v > 100 ? 100 : v
  }

  notePercent(): number {
    if (this.noteTarget <= 0) {
      return 0
    }
    const v = Math.floor((this.noteDone * 100) / this.noteTarget)
    return v > 100 ? 100 : v
  }

  overallPercent(): number {
    const total = this.polishTarget + this.noteTarget + this.dailyTarget
    const done = this.polishDone + this.noteDone + this.dailyDone
    if (total <= 0) {
      return 0
    }
    const v = Math.floor((done * 100) / total)
    return v > 100 ? 100 : v
  }

  /** Preferences JSON 反序列化后须重建实例，否则类方法不可用 */
  static fromStored(json: string, weekKey: string): WritingGoal {
    const g = new WritingGoal()
    g.weekKey = weekKey
    if (json.length === 0) {
      return g
    }
    try {
      const p = JSON.parse(json) as WritingGoal
      if (p.weekKey !== weekKey) {
        return g
      }
      g.polishTarget = p.polishTarget
      g.noteTarget = p.noteTarget
      g.dailyTarget = p.dailyTarget
      g.polishDone = p.polishDone
      g.noteDone = p.noteDone
      g.dailyDone = p.dailyDone
      return g
    } catch {
      return g
    }
  }
}

export class AchievementDef {
  key: string = ''
  title: string = ''
  hint: string = ''

  static of(key: string, title: string, hint: string): AchievementDef {
    const a = new AchievementDef()
    a.key = key
    a.title = title
    a.hint = hint
    return a
  }
}

export class AchievementUnlock {
  key: string = ''
  unlockedAt: number = 0
}

export class HubDashboard {
  noteCount: number = 0
  manuscriptCount: number = 0
  favoriteCount: number = 0
  streakDays: number = 0
  polishCount: number = 0
  summaryCount: number = 0
  sparkCount: number = 0
  cardCount: number = 0
  readingCount: number = 0
  planCount: number = 0
  topicCount: number = 0
  starredNoteCount: number = 0
  weekNotes: number = 0
  weekPolish: number = 0
  weekSummary: number = 0
  planDone: number = 0
  planTotal: number = 0
  achievementCount: number = 0
  achievementTotal: number = 0
}

export class WeekReview {
  weekKey: string = ''
  noteCount: number = 0
  polishCount: number = 0
  summaryCount: number = 0
  sparkCount: number = 0
  dailyCount: number = 0
  streak: number = 0
  highlight: string = ''
}
