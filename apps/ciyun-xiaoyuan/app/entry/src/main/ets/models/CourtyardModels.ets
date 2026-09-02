/** 词韵小院 — 平台 Wire 与业务模型（ArkTS 严格模式） */

export class CourtyardWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  author: string = ''
  dynasty: string = ''
  form: string = ''
  theme: string = ''
  annotation: string = ''
  translation: string = ''
  appreciation: string = ''
  comments: string = ''
  background: string = ''
  relatedIds: string = ''
  pingzeHint: string = ''
  rhymeHint: string = ''
  cipai: string = ''
  alias: string = ''
  formHint: string = ''
  pattern: string = ''
  example: string = ''
  book: string = ''
  tone: string = ''
  examples: string = ''
  category: string = ''
  poemId: string = ''
}

export class CourtyardListPayload {
  list: CourtyardWire[] = []
}

export class PoemItem {
  id: string = ''
  title: string = ''
  author: string = ''
  dynasty: string = ''
  form: string = ''
  theme: string = ''
  summary: string = ''
  body: string = ''
  annotation: string = ''
  translation: string = ''
  appreciation: string = ''
  comments: string = ''
  background: string = ''
  relatedIds: string = ''
  coverKey: string = ''
  pingzeHint: string = ''
  rhymeHint: string = ''
  cipai: string = ''

  static fromWire(w: CourtyardWire): PoemItem {
    const item = new PoemItem()
    item.id = w.id
    item.title = w.title
    item.author = w.author ?? ''
    item.dynasty = w.dynasty ?? ''
    item.form = w.form ?? ''
    item.theme = w.theme ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    item.annotation = w.annotation ?? ''
    item.translation = w.translation ?? ''
    item.appreciation = w.appreciation ?? ''
    item.comments = w.comments ?? ''
    item.background = w.background ?? ''
    item.relatedIds = w.relatedIds ?? ''
    const ck = w.coverKey ?? ''
    const cm = w.coverMedia ?? ''
    item.coverKey = ck.length > 0 ? ck : cm
    item.pingzeHint = w.pingzeHint ?? ''
    item.rhymeHint = w.rhymeHint ?? ''
    item.cipai = w.cipai ?? ''
    return item
  }

  metaLine(): string {
    return `${this.dynasty} · ${this.author} · ${this.form}`
  }
}

export class CipaiItem {
  id: string = ''
  title: string = ''
  alias: string = ''
  formHint: string = ''
  pattern: string = ''
  example: string = ''
  body: string = ''
  summary: string = ''
  coverKey: string = ''

  static fromWire(w: CourtyardWire): CipaiItem {
    const item = new CipaiItem()
    item.id = w.id
    item.title = w.title
    item.alias = w.alias ?? ''
    item.formHint = w.formHint ?? ''
    item.pattern = w.pattern ?? ''
    item.example = w.example ?? ''
    item.body = w.body ?? ''
    item.summary = w.summary ?? ''
    const ck = w.coverKey ?? ''
    const cm = w.coverMedia ?? ''
    item.coverKey = ck.length > 0 ? ck : cm
    return item
  }
}

export class RhymeItem {
  id: string = ''
  title: string = ''
  book: string = ''
  tone: string = ''
  examples: string = ''
  body: string = ''
  summary: string = ''
  coverKey: string = ''

  static fromWire(w: CourtyardWire): RhymeItem {
    const item = new RhymeItem()
    item.id = w.id
    item.title = w.title
    item.book = w.book ?? ''
    item.tone = w.tone ?? ''
    item.examples = w.examples ?? ''
    item.body = w.body ?? ''
    item.summary = w.summary ?? ''
    const ck = w.coverKey ?? ''
    const cm = w.coverMedia ?? ''
    item.coverKey = ck.length > 0 ? ck : cm
    return item
  }
}

export class ArticleItem {
  id: string = ''
  title: string = ''
  category: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''

  static fromWire(w: CourtyardWire): ArticleItem {
    const item = new ArticleItem()
    item.id = w.id
    item.title = w.title
    item.category = w.category ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    const ck = w.coverKey ?? ''
    const cm = w.coverMedia ?? ''
    item.coverKey = ck.length > 0 ? ck : cm
    return item
  }
}

export class WorkItem {
  id: string = ''
  title: string = ''
  body: string = ''
  meterSummary: string = ''
  createdAt: string = ''
}

export class FavoriteItem {
  poemId: string = ''
  tags: string = ''
  createdAt: string = ''
}

export class PingzeCell {
  idx: number = 0
  ch: string = ''
  mark: string = ''
  isRhyme: boolean = false
}

export class MessageWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
  createdAt: string = ''
}

export class MessageListPayload {
  list: MessageWire[] = []
}
