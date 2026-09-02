/** 心笺日常 — 本机心笺模型（ArkTS 严格模式） */

export class NoteItem {
  id: string = ''
  title: string = ''
  body: string = ''
  mood: string = ''
  tagsCsv: string = ''
  photoUri0: string = ''
  photoUri1: string = ''
  photoUri2: string = ''
  noteDate: string = ''
  period: string = ''
  coverKey: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  summary(): string {
    if (this.body.length <= 42) {
      return this.body
    }
    return this.body.substring(0, 42)
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

  photoCount(): number {
    let n = 0
    if (this.photoUri0.length > 0) {
      n += 1
    }
    if (this.photoUri1.length > 0) {
      n += 1
    }
    if (this.photoUri2.length > 0) {
      n += 1
    }
    return n
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},` +
      `"body":${JSON.stringify(this.body)},"mood":${JSON.stringify(this.mood)},` +
      `"tagsCsv":${JSON.stringify(this.tagsCsv)},"photoUri0":${JSON.stringify(this.photoUri0)},` +
      `"photoUri1":${JSON.stringify(this.photoUri1)},"photoUri2":${JSON.stringify(this.photoUri2)},` +
      `"noteDate":${JSON.stringify(this.noteDate)},"period":${JSON.stringify(this.period)},` +
      `"coverKey":${JSON.stringify(this.coverKey)},"createdAt":${this.createdAt},"updatedAt":${this.updatedAt}}`
  }

  static fromWire(w: NoteWire): NoteItem {
    const n = new NoteItem()
    n.id = w.id
    n.title = w.title
    n.body = w.body
    n.mood = w.mood
    n.tagsCsv = w.tagsCsv
    n.photoUri0 = w.photoUri0
    n.photoUri1 = w.photoUri1
    n.photoUri2 = w.photoUri2
    n.noteDate = w.noteDate
    n.period = w.period
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
  photoUri0: string = ''
  photoUri1: string = ''
  photoUri2: string = ''
  noteDate: string = ''
  period: string = ''
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
}

export class CatalogWire {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
}

export class CatalogListPayload {
  list: CatalogWire[] = []
}

export class DailyPayload {
  prompt: CatalogWire | null = null
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
    return item
  }
}
