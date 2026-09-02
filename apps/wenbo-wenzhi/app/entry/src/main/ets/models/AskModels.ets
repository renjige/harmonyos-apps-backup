/** 问知数据模型（ArkTS 严格模式） */

export class InsightItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  further: string = ''
  keywords: string = ''
  relatedIds: string = ''
  category: string = '学习知识'
  tags: string = ''
  coverKey: string = 'cover_study'
  topic: string = ''
  choiceA: string = ''
  choiceB: string = ''
  choiceC: string = ''
  choiceD: string = ''
  answerIndex: number = 0

  static copy(src: InsightItem): InsightItem {
    const n = new InsightItem()
    n.id = src.id
    n.title = src.title
    n.summary = src.summary
    n.body = src.body
    n.description = src.description
    n.further = src.further
    n.keywords = src.keywords
    n.relatedIds = src.relatedIds
    n.category = src.category
    n.tags = src.tags
    n.coverKey = src.coverKey
    n.topic = src.topic
    n.choiceA = src.choiceA
    n.choiceB = src.choiceB
    n.choiceC = src.choiceC
    n.choiceD = src.choiceD
    n.answerIndex = src.answerIndex
    return n
  }

  hasQuiz(): boolean {
    return this.choiceA.length > 0 && this.choiceB.length > 0
  }

  choiceAt(index: number): string {
    if (index === 0) {
      return this.choiceA
    }
    if (index === 1) {
      return this.choiceB
    }
    if (index === 2) {
      return this.choiceC
    }
    return this.choiceD
  }

  choices(): string[] {
    const out: string[] = []
    if (this.choiceA.length > 0) {
      out.push(this.choiceA)
    }
    if (this.choiceB.length > 0) {
      out.push(this.choiceB)
    }
    if (this.choiceC.length > 0) {
      out.push(this.choiceC)
    }
    if (this.choiceD.length > 0) {
      out.push(this.choiceD)
    }
    return out
  }

  relatedList(): string[] {
    const out: string[] = []
    if (this.relatedIds.length === 0) {
      return out
    }
    const parts = this.relatedIds.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }
}

export class CollectionItem {
  id: string = ''
  insightId: string = ''
  question: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  further: string = ''
  folder: string = '学习知识'
  tags: string = ''
  note: string = ''
  userTag: string = '待了解'
  coverKey: string = 'cover_study'
  createdAt: number = 0
}

export class CatalogWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  further: string = ''
  keywords: string = ''
  relatedIds: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  category: string = ''
  tags: string = ''
  folder: string = ''
  insightId: string = ''
  question: string = ''
  note: string = ''
  topic: string = ''
  choiceA: string = ''
  choiceB: string = ''
  choiceC: string = ''
  choiceD: string = ''
  answerIndex: number = 0
  createdAt: string = ''
}

export class CatalogListPayload {
  list: CatalogWire[] = []
}

export class CatalogMapper {
  static textOf(v: string): string {
    if (!v) {
      return ''
    }
    return v
  }

  static toInsight(w: CatalogWire): InsightItem {
    const n = new InsightItem()
    n.id = CatalogMapper.textOf(w.id)
    n.title = CatalogMapper.textOf(w.title)
    n.summary = CatalogMapper.textOf(w.summary)
    n.body = CatalogMapper.textOf(w.body)
    const desc = CatalogMapper.textOf(w.description)
    n.description = desc.length > 0 ? desc : n.body
    n.further = CatalogMapper.textOf(w.further)
    n.keywords = CatalogMapper.textOf(w.keywords)
    n.relatedIds = CatalogMapper.textOf(w.relatedIds)
    const cat = CatalogMapper.textOf(w.category)
    n.category = cat.length > 0 ? cat : '学习知识'
    n.tags = CatalogMapper.textOf(w.tags)
    const cover = CatalogMapper.textOf(w.coverKey)
    n.coverKey = cover.length > 0 ? cover : CatalogMapper.textOf(w.coverMedia)
    if (n.coverKey.length === 0) {
      n.coverKey = 'cover_study'
    }
    n.topic = CatalogMapper.textOf(w.topic)
    n.choiceA = CatalogMapper.textOf(w.choiceA)
    n.choiceB = CatalogMapper.textOf(w.choiceB)
    n.choiceC = CatalogMapper.textOf(w.choiceC)
    n.choiceD = CatalogMapper.textOf(w.choiceD)
    const ai = w.answerIndex
    n.answerIndex = ai >= 0 && ai <= 3 ? ai : 0
    return n
  }
}

export class CollectionSyncBody {
  title: string = ''
  question: string = ''
  insightId: string = ''
  note: string = ''
  folder: string = ''
  tags: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  further: string = ''
  coverMedia: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"question":${JSON.stringify(this.question)},` +
      `"insightId":${JSON.stringify(this.insightId)},"note":${JSON.stringify(this.note)},` +
      `"folder":${JSON.stringify(this.folder)},"tags":${JSON.stringify(this.tags)},` +
      `"summary":${JSON.stringify(this.summary)},"body":${JSON.stringify(this.body)},` +
      `"description":${JSON.stringify(this.description)},"further":${JSON.stringify(this.further)},` +
      `"coverMedia":${JSON.stringify(this.coverMedia)},"userId":${JSON.stringify(this.userId)}}`
  }
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

export class CollectionFile {
  items: CollectionItem[] = []
}
