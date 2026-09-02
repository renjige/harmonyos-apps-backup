export class EmotionDef {
  id: string = ''
  label: string = ''
  color: string = ''
  emoji: string = ''
}

export class MoodRecord {
  id: string = ''
  dateKey: string = ''
  emotions: string[] = []
  diary: string = ''
  imagePath: string = ''
  score: number = 5
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(dateKey: string): MoodRecord {
    const r = new MoodRecord()
    r.id = `m_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    r.dateKey = dateKey
    r.createdAt = Date.now()
    r.updatedAt = r.createdAt
    return r
  }

  primaryEmotionId(): string {
    if (this.emotions.length > 0) {
      return this.emotions[0]
    }
    return ''
  }
}

export class EmotionCount {
  id: string = ''
  label: string = ''
  color: string = ''
  count: number = 0
}

export class DayScorePoint {
  day: number = 0
  dateKey: string = ''
  score: number = 0
  color: string = '#D4A574'
}

export class HighlightDay {
  dateKey: string = ''
  score: number = 0
  diary: string = ''
  imagePath: string = ''
  emotions: string[] = []
}

export class MonthlyReportData {
  year: number = 0
  month: number = 0
  recordDays: number = 0
  avgScore: number = 0
  emotionCounts: EmotionCount[] = []
  scorePoints: DayScorePoint[] = []
  highlights: HighlightDay[] = []
  monthlyMessage: string = ''
}

export class ProfileData {
  nickname: string = '月痕旅人'
  avatarPath: string = ''
}

export class MoodStats {
  totalDays: number = 0
  emotionCounts: EmotionCount[] = []
}
