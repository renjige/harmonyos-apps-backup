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
  sourceRefId: string = ''
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
  imageKeys: string[] = []
  sourceRefId: string = ''

  static fromWire(w: JournalItemWire): JournalItem {
    const item = new JournalItem()
    item.id = w.id
    item.title = w.title
    item.subtitle = w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    item.description = w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.tags = w.tags ?? []
    item.recordDate = w.recordDate ?? ''
    item.kind = w.kind ?? ''
    item.content = w.content ?? ''
    item.userId = w.userId ?? ''
    item.imageKeys = w.imageKeys ?? []
    const keyCount = item.imageKeys.length
    item.photoCount = keyCount > 0 ? keyCount : (w.photoCount ?? 0)
    item.category = w.category ?? ''
    item.color = w.color ?? ''
    item.createdAt = w.createdAt ?? ''
    item.sourceRefId = w.sourceRefId ?? ''
    return item
  }

  /** 展示用图片 key 列表：优先 imageKeys，否则封面 */
  static displayPhotoKeys(item: JournalItem): string[] {
    if (item.imageKeys.length > 0) {
      return item.imageKeys
    }
    if (item.coverKey.length > 0) {
      return [item.coverKey]
    }
    return []
  }

  static isShowcase(item: JournalItem): boolean {
    return item.userId.length === 0 || item.id.startsWith('lja')
  }

  static isUtilityKind(kind: string): boolean {
    return kind === 'habit' || kind === 'checkin' || kind === 'list' || kind === 'moodlog'
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

  static fromWire(w: TopTagWire): TopTagItem {
    const item = new TopTagItem()
    item.tag = w.tag ?? ''
    item.count = w.count ?? 0
    return item
  }
}

export class TopTagWire {
  tag: string = ''
  count: number = 0
}

export class AnnualStatsWire {
  diaryCount: number = 0
  imageCount: number = 0
  topTags: TopTagWire[] = []
  albumCount: number = 0
  favoriteCount: number = 0
  writingDays: number = 0
  year: number = 2026
}

export class AnnualStatsData {
  diaryCount: number = 0
  imageCount: number = 0
  topTags: TopTagItem[] = []
  albumCount: number = 0
  favoriteCount: number = 0
  writingDays: number = 0
  year: number = 2026

  static fromWire(w: AnnualStatsWire): AnnualStatsData {
    const stats = new AnnualStatsData()
    stats.diaryCount = w.diaryCount ?? 0
    stats.imageCount = w.imageCount ?? 0
    stats.albumCount = w.albumCount ?? 0
    stats.favoriteCount = w.favoriteCount ?? 0
    stats.writingDays = w.writingDays ?? 0
    stats.year = w.year ?? new Date().getFullYear()
    stats.topTags = []
    const tags = w.topTags ?? []
    for (let i = 0; i < tags.length; i++) {
      stats.topTags.push(TopTagItem.fromWire(tags[i]))
    }
    return stats
  }
}

export class MonthStatItem {
  month: number = 0
  diaryCount: number = 0
  imageCount: number = 0
}

export class MonthlyStatsData {
  year: number = 2026
  months: MonthStatItem[] = []
}

export class TimelineListPayload {
  list: JournalItemWire[] = []
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
  subtitle: string = ''
  category: string = ''
  kind: string = ''
  sourceRefId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"summary":${JSON.stringify(this.summary)},"tags":${JSON.stringify(this.tags)},"recordDate":${JSON.stringify(this.recordDate)},"coverKey":${JSON.stringify(this.coverKey)},"imageKeys":${JSON.stringify(this.imageKeys)},"userId":${JSON.stringify(this.userId)},"subtitle":${JSON.stringify(this.subtitle)},"category":${JSON.stringify(this.category)},"kind":${JSON.stringify(this.kind)},"sourceRefId":${JSON.stringify(this.sourceRefId)}}`
  }
}

export class UpdateDiaryRequest {
  title: string = ''
  body: string = ''
  summary: string = ''
  tags: string[] = []
  recordDate: string = ''
  coverKey: string = ''
  imageKeys: string[] = []
  userId: string = ''
  category: string = ''
  kind: string = ''
  sourceRefId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"summary":${JSON.stringify(this.summary)},"tags":${JSON.stringify(this.tags)},"recordDate":${JSON.stringify(this.recordDate)},"coverKey":${JSON.stringify(this.coverKey)},"imageKeys":${JSON.stringify(this.imageKeys)},"userId":${JSON.stringify(this.userId)},"category":${JSON.stringify(this.category)},"kind":${JSON.stringify(this.kind)},"sourceRefId":${JSON.stringify(this.sourceRefId)}}`
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

export class UpdateAlbumRequest {
  description: string = ''
  coverKey: string = ''
  imageKeys: string[] = []
  appendImageKeys: string[] = []
  userId: string = ''

  toJsonString(): string {
    return `{"description":${JSON.stringify(this.description)},"coverKey":${JSON.stringify(this.coverKey)},"imageKeys":${JSON.stringify(this.imageKeys)},"appendImageKeys":${JSON.stringify(this.appendImageKeys)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateFavoriteRequest {
  kind: string = ''
  content: string = ''
  title: string = ''
  coverKey: string = ''
  sourceRefId: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"kind":${JSON.stringify(this.kind)},"content":${JSON.stringify(this.content)},"title":${JSON.stringify(this.title)},"coverKey":${JSON.stringify(this.coverKey)},"sourceRefId":${JSON.stringify(this.sourceRefId)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class DeleteFavoritePayload {
  id: string = ''
}

export class MsgWire {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  type: string = ''
  read: boolean = false
  createdAt: string = ''
}

export class MsgListPayload {
  list: MsgWire[] = []
}
