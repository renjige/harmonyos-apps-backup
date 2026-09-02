/** 平台 enrollment-guide JSON 映射 */

export class BrochureItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  level: string = ''
  type: string = ''
  province: string = ''
  enrollmentTotal: number = 0
  majors: string = ''
  scoreLine: string = ''
  registrationStart: string = ''
  registrationEnd: string = ''
  contactPhone: string = ''
  contactEmail: string = ''
  contactWebsite: string = ''
  note: string = ''
  status: string = 'published'
  tags: string = ''
  tuition: string = ''
  examRequirement: string = ''
  scholarship: string = ''

  metaLine(): string {
    const parts: string[] = []
    if (this.level.length > 0) {
      parts.push(this.level)
    }
    if (this.type.length > 0) {
      parts.push(this.type)
    }
    if (this.province.length > 0) {
      parts.push(this.province)
    }
    return parts.join(' · ')
  }

  tagList(): string[] {
    if (this.tags.length === 0) {
      return []
    }
    const list = this.tags.split(',')
    const out: string[] = []
    for (let s of list) {
      const t = s.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  tagPreview(max: number = 3): string[] {
    const all = this.tagList()
    const out: string[] = []
    let i = 0
    while (i < all.length && i < max) {
      out.push(all[i])
      i = i + 1
    }
    return out
  }

  majorList(): string[] {
    if (this.majors.length === 0) {
      return []
    }
    const list = this.majors.split(',')
    const out: string[] = []
    for (let s of list) {
      const t = s.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  majorsPreview(max: number = 3): string {
    const list = this.majorList()
    const out: string[] = []
    let i = 0
    while (i < list.length && i < max) {
      const s = list[i].trim()
      if (s.length > 0) {
        out.push(s)
      }
      i = i + 1
    }
    let line = out.join('、')
    if (list.length > max) {
      line = `${line} 等`
    }
    return line
  }
}

export class ArticleItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  tags: string = ''
  readMinutes: number = 0
  updatedAt: string = ''
}

export class FavoriteRecord {
  id: string = ''
  title: string = ''
  userId: string = ''
  targetKind: string = 'brochure'
  targetId: string = ''
  status: string = 'active'
}

export class WatchRecord {
  id: string = ''
  title: string = ''
  userId: string = ''
  targetKind: string = 'brochure'
  targetId: string = ''
  status: string = 'active'
}

export class MessageItem {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = 'system'
  read: boolean = false
  createdAt: string = ''
}

export class BrochureWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  level: string = ''
  type: string = ''
  province: string = ''
  enrollmentTotal: number = 0
  majors: string = ''
  scoreLine: string = ''
  registrationStart: string = ''
  registrationEnd: string = ''
  contactPhone: string = ''
  contactEmail: string = ''
  contactWebsite: string = ''
  note: string = ''
  status: string = ''
  tags: string = ''
  tuition: string = ''
  examRequirement: string = ''
  scholarship: string = ''
}

export class BrochureListWire {
  list: BrochureWire[] = []
}

export class ArticleWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  tags: string = ''
  readMinutes: number = 0
  updatedAt: string = ''
}

export class ArticleListWire {
  list: ArticleWire[] = []
}

export class FavoriteWire {
  id: string = ''
  title: string = ''
  userId: string = ''
  targetKind: string = ''
  targetId: string = ''
  status: string = ''
}

export class FavoriteListWire {
  list: FavoriteWire[] = []
}

export class WatchListWire {
  list: FavoriteWire[] = []
}

export class MessageWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
  createdAt: string = ''
}

export class MessageListWire {
  list: MessageWire[] = []
}

export class FavoriteCreateBody {
  userId: string = ''
  title: string = ''
  targetKind: string = 'brochure'
  targetId: string = ''

  toJsonString(): string {
    const o = new FavoriteCreatePayload()
    o.userId = this.userId
    o.title = this.title
    o.targetKind = this.targetKind
    o.targetId = this.targetId
    return JSON.stringify(o)
  }
}

class FavoriteCreatePayload {
  userId: string = ''
  title: string = ''
  targetKind: string = 'brochure'
  targetId: string = ''
}

export class DeleteOkWire {
  success: boolean = false
}

export class HistoryEntry {
  id: string = ''
  title: string = ''
  kind: string = 'brochure'
  viewedAt: number = 0
}
