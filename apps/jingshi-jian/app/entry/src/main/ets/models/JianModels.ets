export class JianEntry {
  id: string = ''
  dateKey: string = ''
  timeStr: string = ''
  body: string = ''
  moodId: string = ''
  isFavorite: boolean = false
  wordCount: number = 0
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(dateKey: string): JianEntry {
    const e = new JianEntry()
    e.id = `j_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    e.dateKey = dateKey
    const now = new Date()
    const h = now.getHours()
    const m = now.getMinutes()
    const hs = h < 10 ? `0${h}` : `${h}`
    const ms = m < 10 ? `0${m}` : `${m}`
    e.timeStr = `${hs}:${ms}`
    e.createdAt = Date.now()
    e.updatedAt = e.createdAt
    return e
  }

  previewLine(): string {
    const plain = JianEntry.stripText(this.body).replace(/\n/g, ' ').trim()
    if (plain.length === 0) {
      return '（空白笺页）'
    }
    return plain.length > 48 ? `${plain.substring(0, 48)}…` : plain
  }

  static stripText(text: string): string {
    return text.replace(/\*\*/g, '').replace(/\*/g, '')
  }

  recomputeWordCount(): void {
    this.wordCount = JianEntry.stripText(this.body).trim().length
  }
}

export class WisdomQuote {
  id: string = ''
  text: string = ''
  hint: string = ''
  period: string = ''

  static create(id: string, text: string, hint: string, period: string): WisdomQuote {
    const q = new WisdomQuote()
    q.id = id
    q.text = text
    q.hint = hint
    q.period = period
    return q
  }
}

export class MoodStatItem {
  moodId: string = ''
  label: string = ''
  count: number = 0
  color: string = ''
}

export class MonthMoodCell {
  dateKey: string = ''
  moodId: string = ''
  hasEntry: boolean = false
}

export class JianOverview {
  totalCount: number = 0
  streakDays: number = 0
  favoriteCount: number = 0
}
