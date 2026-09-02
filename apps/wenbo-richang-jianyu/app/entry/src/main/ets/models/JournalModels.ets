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
  sourceRefId: string = ''
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
  imageKeys: string[] = []
  sourceRefId: string = ''

  static safeText(value: string): string {
    if (value === undefined || value === null) {
      return ''
    }
    return value
  }

  static safeKeys(keys: string[]): string[] {
    if (keys === undefined || keys === null) {
      return []
    }
    const out: string[] = []
    for (const k of keys) {
      if (k !== undefined && k !== null && k.length > 0) {
        out.push(k)
      }
    }
    return out
  }

  static fromWire(w: JournalItemWire): JournalItem {
    const item = new JournalItem()
    if (w === undefined || w === null) {
      return item
    }
    item.id = JournalItem.safeText(w.id)
    item.title = JournalItem.safeText(w.title)
    item.subtitle = JournalItem.safeText(w.subtitle)
    item.summary = JournalItem.safeText(w.summary)
    item.body = JournalItem.safeText(w.body)
    item.description = JournalItem.safeText(w.description)
    const cover = JournalItem.safeText(w.coverKey)
    const media = JournalItem.safeText(w.coverMedia)
    if (cover.length > 0) {
      item.coverKey = cover
    } else {
      item.coverKey = media
    }
    item.tags = JournalItem.safeKeys(w.tags)
    item.recordDate = JournalItem.safeText(w.recordDate)
    item.kind = JournalItem.safeText(w.kind)
    item.content = JournalItem.safeText(w.content)
    item.userId = JournalItem.safeText(w.userId)
    item.imageKeys = JournalItem.safeKeys(w.imageKeys)
    const keyCount = item.imageKeys.length
    const pc = w.photoCount
    item.photoCount = keyCount > 0 ? keyCount : (pc !== undefined && pc !== null ? pc : 0)
    item.category = JournalItem.safeText(w.category)
    item.color = JournalItem.safeText(w.color)
    item.createdAt = JournalItem.safeText(w.createdAt)
    item.sourceRefId = JournalItem.safeText(w.sourceRefId)
    return item
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},"subtitle":${JSON.stringify(this.subtitle)},"summary":${JSON.stringify(this.summary)},"body":${JSON.stringify(this.body)},"description":${JSON.stringify(this.description)},"coverKey":${JSON.stringify(this.coverKey)},"imageKeys":${JSON.stringify(this.imageKeys)},"tags":${JSON.stringify(this.tags)},"recordDate":${JSON.stringify(this.recordDate)},"kind":${JSON.stringify(this.kind)},"content":${JSON.stringify(this.content)},"userId":${JSON.stringify(this.userId)},"photoCount":${this.photoCount},"category":${JSON.stringify(this.category)},"color":${JSON.stringify(this.color)},"createdAt":${JSON.stringify(this.createdAt)},"sourceRefId":${JSON.stringify(this.sourceRefId)}}`
  }

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
  category: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"summary":${JSON.stringify(this.summary)},"tags":${JSON.stringify(this.tags)},"recordDate":${JSON.stringify(this.recordDate)},"coverKey":${JSON.stringify(this.coverKey)},"imageKeys":${JSON.stringify(this.imageKeys)},"userId":${JSON.stringify(this.userId)},"kind":${JSON.stringify(this.kind)},"category":${JSON.stringify(this.category)}}`
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
  kind: string = ''
  category: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"body":${JSON.stringify(this.body)},"summary":${JSON.stringify(this.summary)},"tags":${JSON.stringify(this.tags)},"recordDate":${JSON.stringify(this.recordDate)},"coverKey":${JSON.stringify(this.coverKey)},"imageKeys":${JSON.stringify(this.imageKeys)},"userId":${JSON.stringify(this.userId)},"kind":${JSON.stringify(this.kind)},"category":${JSON.stringify(this.category)}}`
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
    let body = '{'
    let first = true
    if (this.description.length > 0) {
      body += `"description":${JSON.stringify(this.description)}`
      first = false
    }
    if (this.coverKey.length > 0) {
      if (!first) {
        body += ','
      }
      body += `"coverKey":${JSON.stringify(this.coverKey)}`
      first = false
    }
    if (this.imageKeys.length > 0) {
      if (!first) {
        body += ','
      }
      body += `"imageKeys":${JSON.stringify(this.imageKeys)}`
      first = false
    }
    if (this.appendImageKeys.length > 0) {
      if (!first) {
        body += ','
      }
      body += `"appendImageKeys":${JSON.stringify(this.appendImageKeys)}`
      first = false
    }
    if (this.userId.length > 0) {
      if (!first) {
        body += ','
      }
      body += `"userId":${JSON.stringify(this.userId)}`
    }
    body += '}'
    return body
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
