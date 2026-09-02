export class ThinkNote {
  id: string = ''
  title: string = ''
  body: string = ''
  category: string = '学习思考'
  createdAt: number = 0
  updatedAt: number = 0
}

export class BreakdownItem {
  id: string = ''
  question: string = ''
  current: string = ''
  causes: string = ''
  solutions: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}

export class OpinionItem {
  id: string = ''
  title: string = ''
  viewpoint: string = ''
  remark: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}

export class DailyItem {
  id: string = ''
  dateKey: string = ''
  prompt: string = ''
  answer: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}

export class ThemeMapItem {
  id: string = ''
  title: string = ''
  center: string = ''
  branchesCsv: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  branches(): string[] {
    if (this.branchesCsv.length === 0) {
      return []
    }
    const out: string[] = []
    const parts = this.branchesCsv.split(';;')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }
}

@Observed
export class GrowthStat {
  sparks: number = 0
  notes: number = 0
  breakdowns: number = 0
  opinions: number = 0
  dailies: number = 0
  goals: number = 0
  reviews: number = 0
  streak: number = 0
}

export class GoalItem {
  id: string = ''
  title: string = ''
  target: string = ''
  stepsCsv: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  steps(): string[] {
    if (this.stepsCsv.length === 0) {
      return []
    }
    const out: string[] = []
    const parts = this.stepsCsv.split(';;')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }
}

export class ReviewItem {
  id: string = ''
  title: string = ''
  subject: string = ''
  beforeText: string = ''
  afterText: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}
