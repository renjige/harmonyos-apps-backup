export class XingyuCodec {
  static clean(raw: string): string {
    return raw.split('\t').join(' ').split('\n').join(' ')
  }

  static csv(items: string[]): string {
    if (items.length === 0) {
      return ''
    }
    const out: string[] = []
    for (const s of items) {
      if (s.length > 0) {
        out.push(s)
      }
    }
    return out.join(',')
  }

  static splitCsv(raw: string): string[] {
    const out: string[] = []
    if (raw.length === 0) {
      return out
    }
    const parts = raw.split(',')
    for (const p of parts) {
      if (p.length > 0) {
        out.push(p)
      }
    }
    return out
  }
}

export class TagItem {
  id: string = ''
  name: string = ''
  systemTag: boolean = false

  static make(id: string, name: string, systemTag: boolean): TagItem {
    const t = new TagItem()
    t.id = id
    t.name = name
    t.systemTag = systemTag
    return t
  }

  static defaults(): TagItem[] {
    const out: TagItem[] = []
    out.push(TagItem.make('tag_growth', '成长', true))
    out.push(TagItem.make('tag_spark', '灵感', true))
    out.push(TagItem.make('tag_read', '阅读', true))
    out.push(TagItem.make('tag_travel', '旅行', true))
    out.push(TagItem.make('tag_hobby', '兴趣', true))
    out.push(TagItem.make('tag_life', '生活', true))
    out.push(TagItem.make('tag_fav', '收藏', true))
    out.push(TagItem.make('tag_important', '重要', true))
    return out
  }
}

export class ThemeSpace {
  id: string = ''
  title: string = ''
  coverKey: string = 'cover_life'
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(title: string, coverKey: string): ThemeSpace {
    const t = new ThemeSpace()
    t.id = `th_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.title = title
    t.coverKey = coverKey
    t.createdAt = Date.now()
    t.updatedAt = Date.now()
    return t
  }
}

export class Narrative {
  id: string = ''
  title: string = ''
  dateKey: string = ''
  templateKey: string = 'fragment'
  status: string = 'normal'
  tags: string[] = []
  themeIds: string[] = []
  fieldA: string = ''
  fieldB: string = ''
  fieldC: string = ''
  isFavorite: boolean = false
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(dateKey: string, templateKey: string): Narrative {
    const n = new Narrative()
    n.id = `nv_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    n.dateKey = dateKey
    n.templateKey = templateKey
    n.status = 'normal'
    n.createdAt = Date.now()
    n.updatedAt = Date.now()
    return n
  }

  preview(): string {
    const raw = `${this.fieldA} ${this.fieldB} ${this.fieldC}`.trim()
    if (raw.length === 0) {
      return '尚未写下正文'
    }
    return raw.length > 42 ? `${raw.substring(0, 42)}…` : raw
  }

  bodyText(): string {
    return `${this.fieldA}\n${this.fieldB}\n${this.fieldC}`.trim()
  }

  statusLabel(): string {
    if (this.status === 'treasure') {
      return '珍藏'
    }
    if (this.status === 'important') {
      return '重要'
    }
    if (this.status === 'memory') {
      return '回忆'
    }
    return '普通'
  }

  templateLabel(): string {
    if (this.templateKey === 'reading') {
      return '阅读记录'
    }
    if (this.templateKey === 'travel') {
      return '旅行记录'
    }
    if (this.templateKey === 'spark') {
      return '灵感记录'
    }
    return '今日片段'
  }

  coverKey(): string {
    if (this.templateKey === 'reading') {
      return 'cover_reading'
    }
    if (this.templateKey === 'travel') {
      return 'cover_travel'
    }
    if (this.templateKey === 'spark') {
      return 'cover_hobby'
    }
    return 'cover_life'
  }
}

export class SparkItem {
  id: string = ''
  title: string = ''
  kind: string = 'idea'
  body: string = ''
  source: string = ''
  plan: string = ''
  dateKey: string = ''
  tags: string[] = []
  themeIds: string[] = []
  isFavorite: boolean = false
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(dateKey: string): SparkItem {
    const s = new SparkItem()
    s.id = `sp_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    s.dateKey = dateKey
    s.kind = 'idea'
    s.createdAt = Date.now()
    s.updatedAt = Date.now()
    return s
  }

  kindLabel(): string {
    if (this.kind === 'thought') {
      return '想法'
    }
    if (this.kind === 'plan') {
      return '计划'
    }
    if (this.kind === 'creative') {
      return '创意'
    }
    return '灵感'
  }

  preview(): string {
    const raw = this.body.length > 0 ? this.body : this.plan
    if (raw.length === 0) {
      return '尚未写下灵感'
    }
    return raw.length > 42 ? `${raw.substring(0, 42)}…` : raw
  }
}

export class FavoriteItem {
  id: string = ''
  targetType: string = 'narrative'
  targetId: string = ''
  excerpt: string = ''
  createdAt: number = 0

  static createNew(targetType: string, targetId: string, excerpt: string): FavoriteItem {
    const f = new FavoriteItem()
    f.id = `fv_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    f.targetType = targetType
    f.targetId = targetId
    f.excerpt = excerpt
    f.createdAt = Date.now()
    return f
  }
}

export class TimelineEvent {
  id: string = ''
  dateKey: string = ''
  kind: string = ''
  title: string = ''
  targetId: string = ''
  createdAt: number = 0
}

export class ArchiveStats {
  narrativeCount: number = 0
  sparkCount: number = 0
  themeCount: number = 0
  favoriteCount: number = 0
  streakDays: number = 0
}

export class AchievementDef {
  id: string = ''
  title: string = ''
  hint: string = ''
  unlocked: boolean = false

  static make(id: string, title: string, hint: string, unlocked: boolean): AchievementDef {
    const a = new AchievementDef()
    a.id = id
    a.title = title
    a.hint = hint
    a.unlocked = unlocked
    return a
  }
}

export class YearbookData {
  year: string = ''
  narrativeCount: number = 0
  sparkCount: number = 0
  favoriteCount: number = 0
  themeCount: number = 0
  topTag: string = ''
  topTheme: string = ''
  highlightTitle: string = ''
  highlightId: string = ''
}

export class LocalUser {
  username: string = ''
  password: string = ''
  realName: string = ''
  phone: string = ''
}
