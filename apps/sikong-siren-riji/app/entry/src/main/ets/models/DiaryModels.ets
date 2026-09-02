export class MoodOption {
  key: string = ''
  label: string = ''
  color: string = ''
  tag: string = ''

  static all(): MoodOption[] {
    const list: MoodOption[] = []
    const items: string[][] = [
      ['happy', '开心', '#E74C3C', '😊'],
      ['calm', '平静', '#3498DB', '😌'],
      ['think', '思考', '#9B59B6', '🤔'],
      ['sad', '感伤', '#7F8C8D', '😢'],
      ['hope', '期待', '#F39C12', '✨']
    ]
    for (const row of items) {
      const o = new MoodOption()
      o.key = row[0]
      o.label = row[1]
      o.color = row[2]
      o.tag = row[3]
      list.push(o)
    }
    return list
  }

  static find(key: string): MoodOption | undefined {
    for (const o of MoodOption.all()) {
      if (o.key === key) {
        return o
      }
    }
    return undefined
  }
}

export class DiaryEntry {
  id: string = ''
  title: string = ''
  body: string = ''
  moodKey: string = 'calm'
  moodLabel: string = '平静'
  weather: string = ''
  wordCount: number = 0
  isFavorite: boolean = false
  imagePaths: string = ''
  audioPath: string = ''
  createdAt: number = 0
  updatedAt: number = 0
  dateKey: string = ''

  static createNew(dateKey: string): DiaryEntry {
    const e = new DiaryEntry()
    e.id = `d_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    e.dateKey = dateKey
    e.createdAt = Date.now()
    e.updatedAt = e.createdAt
    return e
  }

  previewLine(): string {
    if (this.title.trim().length > 0) {
      return this.title.trim()
    }
    const plain = this.body.replace(/\*\*/g, '').replace(/\*/g, '').replace(/\n/g, ' ').trim()
    if (plain.length === 0) {
      return '（无正文）'
    }
    return plain.length > 48 ? `${plain.substring(0, 48)}…` : plain
  }

  firstImagePath(): string {
    if (this.imagePaths.length === 0) {
      return ''
    }
    const parts = this.imagePaths.split('|')
    return parts.length > 0 ? parts[0] : ''
  }

  imageList(): string[] {
    if (this.imagePaths.length === 0) {
      return []
    }
    const out: string[] = []
    const parts = this.imagePaths.split('|')
    for (const p of parts) {
      if (p.length > 0) {
        out.push(p)
      }
    }
    return out
  }

  recomputeWordCount(): void {
    const plain = this.body.replace(/\*\*/g, '').replace(/\*/g, '').replace(/#/g, '').replace(/>/g, '')
    this.wordCount = plain.trim().length
  }
}

export class DiaryFilter {
  keyword: string = ''
  moodKey: string = ''
  favoritesOnly: boolean = false
  startDateKey: string = ''
  endDateKey: string = ''
}

export class MonthStats {
  year: number = 2026
  month: number = 1
  diaryDays: number = 0
  totalWords: number = 0
  longestStreak: number = 0
  moodCounts: Map<string, number> = new Map()
}

export class KeywordItem {
  word: string = ''
  count: number = 0
}

export class WeekSummary {
  weekLabel: string = ''
  summaryText: string = ''
  entryCount: number = 0
}

export class AppSettings {
  themeMode: string = 'system'
  fontScale: string = 'medium'
  appLockEnabled: boolean = false
  appLockType: string = 'pin'
  appLockPin: string = ''
}
