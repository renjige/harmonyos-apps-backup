/** 灵感笺 — 本机灵感模型（ArkTS 严格模式） */

export class NoteItem {
  id: string = ''
  title: string = ''
  body: string = ''
  mood: string = ''
  tagsCsv: string = ''
  favorited: boolean = false
  cardTemplate: string = 'plain'
  noteDate: string = ''
  timeLabel: string = ''
  coverKey: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  summary(): string {
    if (this.body.length <= 48) {
      return this.body
    }
    return this.body.substring(0, 48)
  }

  displayTitle(): string {
    if (this.title.length > 0) {
      return this.title
    }
    return this.summary()
  }

  tagList(): string[] {
    const out: string[] = []
    if (this.tagsCsv.length === 0) {
      return out
    }
    const parts = this.tagsCsv.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},` +
      `"body":${JSON.stringify(this.body)},"mood":${JSON.stringify(this.mood)},` +
      `"tagsCsv":${JSON.stringify(this.tagsCsv)},"favorited":${this.favorited ? 'true' : 'false'},` +
      `"cardTemplate":${JSON.stringify(this.cardTemplate)},"noteDate":${JSON.stringify(this.noteDate)},` +
      `"timeLabel":${JSON.stringify(this.timeLabel)},"coverKey":${JSON.stringify(this.coverKey)},` +
      `"createdAt":${this.createdAt},"updatedAt":${this.updatedAt}}`
  }

  static fromWire(w: NoteWire): NoteItem {
    const n = new NoteItem()
    n.id = w.id
    n.title = w.title
    n.body = w.body
    n.mood = w.mood
    n.tagsCsv = w.tagsCsv
    n.favorited = w.favorited
    n.cardTemplate = w.cardTemplate.length > 0 ? w.cardTemplate : 'plain'
    n.noteDate = w.noteDate
    n.timeLabel = w.timeLabel
    n.coverKey = w.coverKey
    n.createdAt = w.createdAt
    n.updatedAt = w.updatedAt
    return n
  }
}

export class NoteWire {
  id: string = ''
  title: string = ''
  body: string = ''
  mood: string = ''
  tagsCsv: string = ''
  favorited: boolean = false
  cardTemplate: string = 'plain'
  noteDate: string = ''
  timeLabel: string = ''
  coverKey: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}

export class NoteFile {
  items: NoteWire[] = []
}

export class CatalogItem {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  coverKey: string = ''
  templateKey: string = ''
}

export class CatalogWire {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  subtitle: string = ''
  templateKey: string = ''
}

export class CatalogListPayload {
  list: CatalogWire[] = []
}

export class DailyPayload {
  quote: CatalogWire | null = null
}

export class MsgWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
  createdAt: string = ''
}

export class MsgListPayload {
  list: MsgWire[] = []
}

export class OrganizeHint {
  todayCount: number = 0
  topTag: string = ''
  topCount: number = 0
  message: string = ''
  actionLabel: string = ''
}

export class CatalogMapper {
  static fromWire(w: CatalogWire): CatalogItem {
    const item = new CatalogItem()
    item.id = w.id
    item.title = w.title
    item.body = w.body.length > 0 ? w.body : (w.summary.length > 0 ? w.summary : w.description)
    item.summary = w.summary.length > 0 ? w.summary : item.body
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else {
      item.coverKey = w.coverMedia
    }
    item.templateKey = w.templateKey.length > 0 ? w.templateKey : w.subtitle
    return item
  }
}
