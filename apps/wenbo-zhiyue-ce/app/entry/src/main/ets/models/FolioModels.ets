export class ReadingDoc {
  id: string = ''
  title: string = ''
  format: string = 'txt'
  body: string = ''
  progress: number = 0
  lastReadAt: number = 0
  folioId: string = ''
  wordCount: number = 0
  readMinutes: number = 0
  createdAt: number = 0
  updatedAt: number = 0
  filePath: string = ''

  hasPdfFile(): boolean {
    return this.format === 'pdf' && this.filePath.length > 0
  }

  needsBody(): boolean {
    if (this.hasPdfFile()) {
      return false
    }
    return this.body.trim().length === 0
  }

  progressLabel(): string {
    const p = Math.floor(this.progress * 100)
    return `${p}%`
  }

  formatLabel(): string {
    if (this.format === 'md') {
      return 'Markdown'
    }
    if (this.format === 'pdf') {
      return 'PDF'
    }
    if (this.format === 'paste') {
      return '粘贴'
    }
    return 'TXT'
  }

  static create(title: string, format: string, body: string): ReadingDoc {
    const d = new ReadingDoc()
    d.id = `d${Date.now()}`
    d.title = title
    d.format = format
    d.body = body
    d.wordCount = body.length
    d.createdAt = Date.now()
    d.updatedAt = d.createdAt
    return d
  }
}

export class ExcerptItem {
  id: string = ''
  docId: string = ''
  folioId: string = ''
  text: string = ''
  reflection: string = ''
  tags: string[] = []
  isFavorite: boolean = false
  createdAt: number = 0
  updatedAt: number = 0

  tagLine(): string {
    return this.tags.join(' · ')
  }

  hasTag(tag: string): boolean {
    for (const t of this.tags) {
      if (t === tag) {
        return true
      }
    }
    return false
  }

  static create(docId: string, text: string, reflection: string): ExcerptItem {
    const e = new ExcerptItem()
    e.id = `e${Date.now()}`
    e.docId = docId
    e.text = text
    e.reflection = reflection
    e.createdAt = Date.now()
    e.updatedAt = e.createdAt
    return e
  }
}

export class KnowledgeFolio {
  id: string = ''
  title: string = ''
  summary: string = ''
  coverKey: string = 'cover_folio_study'
  createdAt: number = 0
  updatedAt: number = 0

  static create(title: string, summary: string, coverKey: string): KnowledgeFolio {
    const f = new KnowledgeFolio()
    f.id = `f${Date.now()}`
    f.title = title
    f.summary = summary
    f.coverKey = coverKey
    f.createdAt = Date.now()
    f.updatedAt = f.createdAt
    return f
  }
}

export class FolioOverview {
  docCount: number = 0
  excerptCount: number = 0
  folioCount: number = 0
  favoriteCount: number = 0
  readMinutes: number = 0
}

export class EnsureFolioResult {
  folio: KnowledgeFolio = new KnowledgeFolio()
  created: boolean = false
}

export class RhythmPersistResult {
  folio: KnowledgeFolio = new KnowledgeFolio()
  excerpt: ExcerptItem = new ExcerptItem()
  doc: ReadingDoc = new ReadingDoc()
}
