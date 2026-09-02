/** 灵感手册 — 平台 /biz/inspiration-handbook Wire 模型（ArkTS strict） */

export class InspirationItemWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  imageKeys: string[] = []
  tags: string[] = []
  recordDate: string = ''
  kind: string = ''
  content: string = ''
  userId: string = ''
  category: string = ''
  color: string = ''
  cardsJson: string = ''
  goal: string = ''
  progress: number = 0
  createdAt: string = ''
  updatedAt: string = ''
}

export class InspirationItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  tags: string[] = []
  recordDate: string = ''
  kind: string = ''
  content: string = ''
  userId: string = ''
  category: string = ''
  color: string = ''
  cardsJson: string = ''
  goal: string = ''
  progress: number = 0
  createdAt: string = ''

  private static textOf(v: string): string {
    return v ?? ''
  }

  static fromWire(w: InspirationItemWire): InspirationItem {
    const item = new InspirationItem()
    item.id = InspirationItem.textOf(w.id)
    item.title = InspirationItem.textOf(w.title)
    item.subtitle = InspirationItem.textOf(w.subtitle)
    item.summary = InspirationItem.textOf(w.summary)
    item.body = InspirationItem.textOf(w.body)
    item.description = InspirationItem.textOf(w.description)
    const coverKey = InspirationItem.textOf(w.coverKey)
    const coverMedia = InspirationItem.textOf(w.coverMedia)
    item.coverKey = coverKey.length > 0 ? coverKey : coverMedia
    if (w.tags !== undefined && w.tags !== null) {
      item.tags = w.tags
    } else {
      item.tags = []
    }
    item.recordDate = InspirationItem.textOf(w.recordDate)
    item.kind = InspirationItem.textOf(w.kind)
    item.content = InspirationItem.textOf(w.content)
    item.userId = InspirationItem.textOf(w.userId)
    item.category = InspirationItem.textOf(w.category)
    item.color = InspirationItem.textOf(w.color)
    item.cardsJson = InspirationItem.textOf(w.cardsJson)
    item.goal = InspirationItem.textOf(w.goal)
    item.progress = w.progress ?? 0
    item.createdAt = InspirationItem.textOf(w.createdAt)
    return item
  }
}

export class InspirationListPayload {
  list: InspirationItemWire[] = []
}

export class TagPresetWire {
  id: string = ''
  title: string = ''
  color: string = ''
  category: string = ''
}

export class TagPresetItem {
  id: string = ''
  title: string = ''
  color: string = ''

  static fromWire(w: TagPresetWire): TagPresetItem {
    const item = new TagPresetItem()
    item.id = w.id
    item.title = w.title
    item.color = w.color ?? '#F5C842'
    return item
  }
}

export class TagPresetListPayload {
  list: TagPresetWire[] = []
}

export class TopTagItem {
  tag: string = ''
  count: number = 0
}

export class StatsData {
  inspirationCount: number = 0
  favoriteCount: number = 0
  topTags: TopTagItem[] = []
  boardCount: number = 0
  planCount: number = 0
}

export class SearchResultData {
  inspirations: InspirationItemWire[] = []
  featured: InspirationItemWire[] = []
  query: string = ''
}

export class CreateInspirationRequest {
  title: string = ''
  body: string = ''
  summary: string = ''
  tags: string[] = []
  recordDate: string = ''
  coverKey: string = ''
  imageKeys: string[] = []
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"summary":${JSON.stringify(this.summary)},"tags":${JSON.stringify(this.tags)},"recordDate":${JSON.stringify(this.recordDate)},"coverKey":${JSON.stringify(this.coverKey)},"imageKeys":${JSON.stringify(this.imageKeys)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class UpdateInspirationRequest {
  title: string = ''
  body: string = ''
  summary: string = ''
  tags: string[] = []
  recordDate: string = ''
  coverKey: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"summary":${JSON.stringify(this.summary)},"tags":${JSON.stringify(this.tags)},"recordDate":${JSON.stringify(this.recordDate)},"coverKey":${JSON.stringify(this.coverKey)}}`
  }
}

export class CreateBoardRequest {
  title: string = ''
  description: string = ''
  coverKey: string = ''
  imageKeys: string[] = []
  cardsJson: string = ''
  body: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"description":${JSON.stringify(this.description)},"coverKey":${JSON.stringify(this.coverKey)},"imageKeys":${JSON.stringify(this.imageKeys)},"cardsJson":${JSON.stringify(this.cardsJson)},"body":${JSON.stringify(this.body)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreatePlanRequest {
  title: string = ''
  goal: string = ''
  summary: string = ''
  progress: number = 0
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"goal":${JSON.stringify(this.goal)},"summary":${JSON.stringify(this.summary)},"progress":${this.progress},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class UpdatePlanRequest {
  title: string = ''
  goal: string = ''
  summary: string = ''
  progress: number = 0

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"goal":${JSON.stringify(this.goal)},"summary":${JSON.stringify(this.summary)},"progress":${this.progress}}`
  }
}

export class UpdatePlanProgressRequest {
  progress: number = 0

  toJsonString(): string {
    return `{"progress":${this.progress}}`
  }
}

export class UpdateBoardRequest {
  title: string = ''
  description: string = ''
  coverKey: string = ''
  cardsJson: string = ''
  body: string = ''

  toJsonString(): string {
    return `{"cardsJson":${JSON.stringify(this.cardsJson)},"body":${JSON.stringify(this.body)}}`
  }
}

export class CreateFavoriteRequest {
  kind: string = ''
  content: string = ''
  title: string = ''
  coverKey: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"kind":${JSON.stringify(this.kind)},"content":${JSON.stringify(this.content)},"title":${JSON.stringify(this.title)},"coverKey":${JSON.stringify(this.coverKey)},"userId":${JSON.stringify(this.userId)}}`
  }
}

class DeleteOkPayload {
  id: string = ''
}
