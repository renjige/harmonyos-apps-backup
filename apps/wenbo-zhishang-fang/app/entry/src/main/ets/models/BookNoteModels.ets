export class BookNote {
  id: string = ''
  bookName: string = ''
  pageNumber: number = 0
  excerpt: string = ''
  reflection: string = ''
  coverImage: string = ''
  tags: string[] = []
  isFavorite: boolean = false
  recallCount: number = 0
  lastRecalledAt: number = 0
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(): BookNote {
    const n = new BookNote()
    n.id = `n_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    n.createdAt = Date.now()
    n.updatedAt = n.createdAt
    return n
  }

  excerptPreview(): string {
    const plain = this.excerpt.replace(/\n/g, ' ').trim()
    if (plain.length === 0) {
      return '（空白摘录）'
    }
    return plain.length > 80 ? `${plain.substring(0, 80)}…` : plain
  }

  tagLine(): string {
    if (this.tags.length === 0) {
      return '未分类'
    }
    return this.tags.join(' · ')
  }

  primaryTag(): string {
    if (this.tags.length === 0) {
      return '未分类'
    }
    return this.tags[0]
  }

  hasTag(name: string): boolean {
    for (const t of this.tags) {
      if (t === name) {
        return true
      }
    }
    return false
  }

  pageLabel(): string {
    if (this.pageNumber <= 0) {
      return ''
    }
    return `p.${this.pageNumber}`
  }
}

export class NoteOverview {
  totalNotes: number = 0
  bookCount: number = 0
  favoriteCount: number = 0
}

export class TagCloudItem {
  name: string = ''
  count: number = 0
  fontSize: number = 12
}

export class WeekDayStat {
  label: string = ''
  count: number = 0
}

export class ReadingInsight {
  streakDays: number = 0
  topTag: string = ''
  weekTotal: number = 0
  weekDays: WeekDayStat[] = []
}

export class BookShelfGroup {
  bookName: string = ''
  noteCount: number = 0
  latestExcerpt: string = ''
}

export class BookProfile {
  bookName: string = ''
  noteCount: number = 0
  favoriteCount: number = 0
  topTag: string = ''
  firstDate: string = ''
  latestDate: string = ''
}

export class MonthlyReadingReport {
  monthLabel: string = ''
  newNotes: number = 0
  recallTotal: number = 0
  topBook: string = ''
  topTag: string = ''
  goalTarget: number = 10
  goalProgress: number = 0
}

export class TimelineItem {
  id: string = ''
  bookName: string = ''
  excerptPreview: string = ''
  tagLabel: string = ''
  dateLabel: string = ''
}
