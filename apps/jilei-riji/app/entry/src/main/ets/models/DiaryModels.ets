export class DiaryEntry {
  id: string = ''
  title: string = ''
  body: string = ''
  wordCount: number = 0
  imagePath: string = ''
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
    const plain = DiaryEntry.stripMarkup(this.body).replace(/\n/g, ' ').trim()
    if (plain.length === 0) {
      return '（无正文）'
    }
    return plain.length > 56 ? `${plain.substring(0, 56)}…` : plain
  }

  static stripMarkup(text: string): string {
    return text.replace(/\*\*/g, '').replace(/\*/g, '').replace(/^-\s/gm, '')
  }

  recomputeWordCount(): void {
    this.wordCount = DiaryEntry.stripMarkup(this.body).trim().length
  }
}

export class MonthStats {
  year: number = 2026
  month: number = 1
  diaryDays: number = 0
  totalWords: number = 0
  longestStreak: number = 0
}

export class KeywordItem {
  word: string = ''
  count: number = 0
}

export class RichTextAction {
  kind: string = ''
  label: string = ''

  static toolbar(): RichTextAction[] {
    const out: RichTextAction[] = []
    const kinds = [['bold', '粗体'], ['italic', '斜体'], ['list', '列表']]
    for (const row of kinds) {
      const a = new RichTextAction()
      a.kind = row[0]
      a.label = row[1]
      out.push(a)
    }
    return out
  }
}
