export class MicroEssay {
  id: string = ''
  title: string = ''
  body: string = ''
  tagsCsv: string = ''
  imagePath: string = ''
  wordCount: number = 0
  createdAt: number = 0
  updatedAt: number = 0
  dateKey: string = ''
  favorite: boolean = false
  senseKey: string = ''
  albumId: string = ''
  themeId: string = ''
  kind: string = ''
  lastOpenedAt: number = 0
  contrastSourceIdsCsv: string = ''

  contrastSourceIds(): string[] {
    return MicroEssay.parseIds(this.contrastSourceIdsCsv)
  }

  setContrastSourceIds(ids: string[]): void {
    const out: string[] = []
    for (const id of ids) {
      const s = id.trim()
      if (s.length > 0) {
        out.push(s)
      }
    }
    this.contrastSourceIdsCsv = out.join(',')
  }

  static parseIds(csv: string): string[] {
    const out: string[] = []
    if (csv.length === 0) {
      return out
    }
    const parts = csv.split(',')
    for (const p of parts) {
      const s = p.trim()
      if (s.length > 0) {
        out.push(s)
      }
    }
    return out
  }

  static createNew(): MicroEssay {
    const e = new MicroEssay()
    e.id = `e_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    const now = new Date()
    e.dateKey = MicroEssay.keyFromDate(now)
    e.createdAt = Date.now()
    e.updatedAt = e.createdAt
    return e
  }

  static keyFromDate(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  tagList(): string[] {
    return MicroEssay.parseTags(this.tagsCsv)
  }

  static parseTags(csv: string): string[] {
    const out: string[] = []
    if (csv.length === 0) {
      return out
    }
    const parts = csv.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  static joinTags(tags: string[]): string {
    const out: string[] = []
    for (const t of tags) {
      const s = t.trim()
      if (s.length > 0) {
        out.push(s)
      }
    }
    return out.join(',')
  }

  previewSummary(maxLen: number): string {
    const plain = MicroEssay.stripMarkup(this.body).replace(/\n/g, ' ').trim()
    const base = plain.length > 0 ? plain : this.title.trim()
    if (base.length === 0) {
      return '（无正文）'
    }
    return base.length > maxLen ? `${base.substring(0, maxLen)}…` : base
  }

  static stripMarkup(text: string): string {
    return text.replace(/\*\*/g, '').replace(/\*/g, '').replace(/__/g, '').replace(/_/g, '')
      .replace(/^-\s/gm, '').replace(/^•\s/gm, '')
  }

  recomputeWordCount(): void {
    const titleLen = this.title.trim().length
    const bodyLen = MicroEssay.stripMarkup(this.body).trim().length
    this.wordCount = titleLen + bodyLen
  }
}

export class TagCloudItem {
  name: string = ''
  count: number = 0
}

export class EssayStats {
  essayCount: number = 0
  totalWords: number = 0
  streakDays: number = 0
  favoriteCount: number = 0
  weekCount: number = 0
  weekWords: number = 0
  topTag: string = ''
}

export class SenseOption {
  key: string = ''
  label: string = ''

  static all(): SenseOption[] {
    const keys: string[] = ['light', 'sound', 'scent', 'touch', 'color', 'people', 'space']
    const labels: string[] = ['光影', '声音', '气味', '触感', '颜色', '人物', '空白']
    const out: SenseOption[] = []
    for (let i = 0; i < keys.length; i++) {
      const s = new SenseOption()
      s.key = keys[i]
      s.label = labels[i]
      out.push(s)
    }
    return out
  }

  static labelOf(key: string): string {
    const all = SenseOption.all()
    for (const s of all) {
      if (s.key === key) {
        return s.label
      }
    }
    return ''
  }
}

export class CalDayCell {
  key: string = ''
  day: number = 0
  inMonth: boolean = false
  count: number = 0
}

export class EssayFormatSegment {
  text: string = ''
  bold: boolean = false
  italic: boolean = false
  underline: boolean = false
  isList: boolean = false
}
