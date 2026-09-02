/** 行旅笺 — 旅迹与灵感匣数据模型 */

import { TripDateHelp } from './TripModels'

export class JournalEntry {
  id: string = ''
  title: string = ''
  body: string = ''
  location: string = ''
  tag: string = 'scenery'
  coverKey: string = 'journal_scenery'
  recordDate: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  tagLabel(): string {
    if (this.tag === 'food') {
      return '美食'
    }
    if (this.tag === 'culture') {
      return '人文'
    }
    return '风景'
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},` +
      `"body":${JSON.stringify(this.body)},"location":${JSON.stringify(this.location)},` +
      `"tag":${JSON.stringify(this.tag)},"coverKey":${JSON.stringify(this.coverKey)},` +
      `"recordDate":${JSON.stringify(this.recordDate)},"createdAt":${this.createdAt},"updatedAt":${this.updatedAt}}`
  }

  static fromWire(w: JournalWire): JournalEntry {
    const n = new JournalEntry()
    n.id = w.id
    n.title = w.title
    n.body = w.body
    n.location = w.location
    n.tag = w.tag.length > 0 ? w.tag : 'scenery'
    n.coverKey = w.coverKey.length > 0 ? w.coverKey : 'journal_scenery'
    n.recordDate = w.recordDate.length > 0 ? w.recordDate : TripDateHelp.todayIso()
    n.createdAt = w.createdAt
    n.updatedAt = w.updatedAt
    return n
  }
}

export class JournalWire {
  id: string = ''
  title: string = ''
  body: string = ''
  location: string = ''
  tag: string = ''
  coverKey: string = ''
  recordDate: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}

export class JournalFile {
  items: JournalWire[] = []
}

export class InspirationItem {
  id: string = ''
  title: string = ''
  body: string = ''
  destination: string = ''
  kind: string = 'destination'
  createdAt: number = 0
  updatedAt: number = 0

  kindLabel(): string {
    if (this.kind === 'snippet') {
      return '攻略片段'
    }
    return '想去的目的地'
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},` +
      `"body":${JSON.stringify(this.body)},"destination":${JSON.stringify(this.destination)},` +
      `"kind":${JSON.stringify(this.kind)},"createdAt":${this.createdAt},"updatedAt":${this.updatedAt}}`
  }

  static fromWire(w: InspirationWire): InspirationItem {
    const n = new InspirationItem()
    n.id = w.id
    n.title = w.title
    n.body = w.body
    n.destination = w.destination
    n.kind = w.kind.length > 0 ? w.kind : 'destination'
    n.createdAt = w.createdAt
    n.updatedAt = w.updatedAt
    return n
  }
}

export class InspirationWire {
  id: string = ''
  title: string = ''
  body: string = ''
  destination: string = ''
  kind: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}

export class InspirationFile {
  items: InspirationWire[] = []
}
