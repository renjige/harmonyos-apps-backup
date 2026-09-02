/** 生活札记 — 平台 /biz/life-journal Wire 模型（ArkTS strict） */

export class JournalItemWire {
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
  photoCount: number = 0
  category: string = ''
  color: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

export class JournalItem {
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
  photoCount: number = 0
  category: string = ''
  color: string = ''
  createdAt: string = ''

  static fromWire(w: JournalItemWire): JournalItem {
    const item = new JournalItem()
    item.id = w.id
    item.title = w.title
    item.subtitle = w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    item.description = w.description ?? ''
    if (w.coverKey !== undefined && w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.tags = w.tags ?? []
    item.recordDate = w.recordDate ?? ''
    item.kind = w.kind ?? ''
    item.content = w.content ?? ''
    item.userId = w.userId ?? ''
    item.photoCount = w.photoCount ?? 0
    item.category = w.category ?? ''
    item.color = w.color ?? ''
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class JournalListPayload {
  list: JournalItemWire[] = []
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
    item.color = w.color ?? '#E8A87C'
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

export class AnnualStatsData {
  diaryCount: number = 0
  imageCount: number = 0
  topTags: TopTagItem[] = []
  albumCount: number = 0
  favoriteCount: number = 0
  year: number = 2026
}

export class SearchResultData {
  diaries: JournalItemWire[] = []
  featured: JournalItemWire[] = []
  query: string = ''
}

export class CreateDiaryRequest {
  title: string = ''
  body: string = ''
  summary: string = ''
  tags: string[] = []
  recordDate: string = ''
  coverKey: string = ''
  imageKeys: string[] = []
  userId: string = ''
  kind: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"summary":${JSON.stringify(this.summary)},"tags":${JSON.stringify(this.tags)},"recordDate":${JSON.stringify(this.recordDate)},"coverKey":${JSON.stringify(this.coverKey)},"imageKeys":${JSON.stringify(this.imageKeys)},"userId":${JSON.stringify(this.userId)},"kind":${JSON.stringify(this.kind)}}`
  }
}

export class CreateAlbumRequest {
  title: string = ''
  description: string = ''
  coverKey: string = ''
  imageKeys: string[] = []
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"description":${JSON.stringify(this.description)},"coverKey":${JSON.stringify(this.coverKey)},"imageKeys":${JSON.stringify(this.imageKeys)},"userId":${JSON.stringify(this.userId)}}`
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

export class DeleteFavoritePayload {
  id: string = ''
}
