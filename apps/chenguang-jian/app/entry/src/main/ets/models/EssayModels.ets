/** 晨光笺 — 本机随笔与栏目模型（ArkTS 严格模式） */

export class EssayItem {
  id: string = ''
  title: string = ''
  content: string = ''
  tagsCsv: string = ''
  weather: string = ''
  coverKey: string = ''
  align: string = 'start'
  isArchived: boolean = false
  createdAt: number = 0
  updatedAt: number = 0

  displayTitle(): string {
    if (this.title.trim().length > 0) {
      return this.title
    }
    return EssayItem.timeTitle(this.createdAt)
  }

  preview(): string {
    const raw = this.content
    if (raw.length <= 50) {
      return raw
    }
    return raw.substring(0, 50)
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

  wordCount(): number {
    let n = 0
    const s = this.content
    for (let i = 0; i < s.length; i++) {
      const ch = s.charAt(i)
      if (ch !== ' ' && ch !== '\n' && ch !== '\t') {
        n += 1
      }
    }
    return n
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},` +
      `"content":${JSON.stringify(this.content)},"tagsCsv":${JSON.stringify(this.tagsCsv)},` +
      `"weather":${JSON.stringify(this.weather)},"coverKey":${JSON.stringify(this.coverKey)},` +
      `"align":${JSON.stringify(this.align)},"isArchived":${this.isArchived ? 'true' : 'false'},` +
      `"createdAt":${this.createdAt},"updatedAt":${this.updatedAt}}`
  }

  static timeTitle(ts: number): string {
    const d = new Date(ts)
    const h = d.getHours()
    const m = d.getMinutes()
    const hs = h < 10 ? `0${h}` : `${h}`
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${d.getMonth() + 1}月${d.getDate()}日 ${hs}:${ms}`
  }

  static fromWire(w: EssayWire): EssayItem {
    const n = new EssayItem()
    n.id = w.id
    n.title = w.title
    n.content = w.content
    n.tagsCsv = w.tagsCsv
    n.weather = w.weather
    n.coverKey = w.coverKey
    n.align = w.align.length > 0 ? w.align : 'start'
    n.isArchived = w.isArchived
    n.createdAt = w.createdAt
    n.updatedAt = w.updatedAt
    return n
  }
}

export class EssayWire {
  id: string = ''
  title: string = ''
  content: string = ''
  tagsCsv: string = ''
  weather: string = ''
  coverKey: string = ''
  align: string = 'start'
  isArchived: boolean = false
  createdAt: number = 0
  updatedAt: number = 0
}

export class EssayFile {
  items: EssayWire[] = []
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
  quote: CatalogWire | null = null
  weather: CatalogWire | null = null
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

export class QuoteFav {
  id: string = ''
  title: string = ''
  body: string = ''
}

export class CatalogMapper {
  static fromWire(w: CatalogWire): CatalogItem {
    const item = new CatalogItem()
    item.id = CatalogMapper.text(w.id)
    item.title = CatalogMapper.text(w.title)
    const body = CatalogMapper.text(w.body)
    const summary = CatalogMapper.text(w.summary)
    const desc = CatalogMapper.text(w.description)
    item.body = body.length > 0 ? body : (summary.length > 0 ? summary : desc)
    item.summary = summary.length > 0 ? summary : item.body
    const cover = CatalogMapper.text(w.coverKey)
    item.coverKey = cover.length > 0 ? cover : CatalogMapper.text(w.coverMedia)
    return item
  }

  private static text(v: string): string {
    if (v === undefined) {
      return ''
    }
    return v
  }
}

export class TagStat {
  name: string = ''
  count: number = 0
}
