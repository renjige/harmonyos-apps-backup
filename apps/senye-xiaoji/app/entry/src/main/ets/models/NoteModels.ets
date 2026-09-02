/** 森野小记 — 本机记录模型 */

export class NoteItem {
  id: string = ''
  body: string = ''
  mood: string = 'calm'
  tagsCsv: string = ''
  locationLabel: string = ''
  noteDate: string = ''
  timeLabel: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  preview(): string {
    const t = this.body.trim()
    if (t.length <= 72) {
      return t
    }
    return t.substring(0, 72) + '…'
  }

  tagList(): string[] {
    const out: string[] = []
    if (this.tagsCsv.length === 0) {
      return out
    }
    const parts = this.tagsCsv.split(',')
    for (const p of parts) {
      const s = p.trim()
      if (s.length > 0) {
        out.push(s)
      }
    }
    return out
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"body":${JSON.stringify(this.body)},` +
      `"mood":${JSON.stringify(this.mood)},"tagsCsv":${JSON.stringify(this.tagsCsv)},` +
      `"locationLabel":${JSON.stringify(this.locationLabel)},"noteDate":${JSON.stringify(this.noteDate)},` +
      `"timeLabel":${JSON.stringify(this.timeLabel)},"createdAt":${this.createdAt},"updatedAt":${this.updatedAt}}`
  }

  static fromWire(w: NoteWire): NoteItem {
    const n = new NoteItem()
    n.id = w.id
    n.body = w.body
    n.mood = w.mood.length > 0 ? w.mood : 'calm'
    n.tagsCsv = w.tagsCsv
    n.locationLabel = w.locationLabel
    n.noteDate = w.noteDate
    n.timeLabel = w.timeLabel
    n.createdAt = w.createdAt
    n.updatedAt = w.updatedAt
    return n
  }
}

export class NoteWire {
  id: string = ''
  body: string = ''
  mood: string = 'calm'
  tagsCsv: string = ''
  locationLabel: string = ''
  noteDate: string = ''
  timeLabel: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}

export class NoteFile {
  items: NoteWire[] = []
}

export class TagStat {
  name: string = ''
  count: number = 0
}

export class SimilarGroup {
  tag: string = ''
  items: NoteItem[] = []
}
