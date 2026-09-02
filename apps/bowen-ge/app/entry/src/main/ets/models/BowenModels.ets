export class Thought {
  id: string = ''
  title: string = ''
  categoryKey: string = ''
  kind: string = 'viewpoint'
  body: string = ''
  tags: string[] = []
  status: string = 'draft'
  themeIds: string[] = []
  favorite: boolean = false
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(title: string): Thought {
    const t = new Thought()
    t.id = `th_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.title = title
    t.categoryKey = 'life'
    t.kind = 'viewpoint'
    t.body = ''
    t.tags = []
    t.status = 'draft'
    t.themeIds = []
    t.favorite = false
    t.createdAt = Date.now()
    t.updatedAt = Date.now()
    return t
  }
}

export class ReadingRecord {
  id: string = ''
  title: string = ''
  sourceType: string = 'book'
  readAt: string = ''
  corePoints: string = ''
  myUnderstanding: string = ''
  harvest: string = ''
  tags: string[] = []
  themeIds: string[] = []
  favorite: boolean = false
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(title: string): ReadingRecord {
    const r = new ReadingRecord()
    r.id = `rd_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    r.title = title
    r.sourceType = 'book'
    r.readAt = ''
    r.corePoints = ''
    r.myUnderstanding = ''
    r.harvest = ''
    r.tags = []
    r.themeIds = []
    r.favorite = false
    r.createdAt = Date.now()
    r.updatedAt = Date.now()
    return r
  }
}

export class KnowledgeCard {
  id: string = ''
  title: string = ''
  content: string = ''
  myUnderstanding: string = ''
  categoryKey: string = 'study'
  sourceNote: string = ''
  tags: string[] = []
  themeIds: string[] = []
  sourceType: string = 'book'
  sourceId: string = ''
  favoriteTier: string = 'none'
  status: string = 'draft'
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(title: string): KnowledgeCard {
    const c = new KnowledgeCard()
    c.id = `cd_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    c.title = title
    c.content = ''
    c.myUnderstanding = ''
    c.categoryKey = 'study'
    c.sourceNote = ''
    c.tags = []
    c.themeIds = []
    c.sourceType = 'book'
    c.sourceId = ''
    c.favoriteTier = 'none'
    c.status = 'draft'
    c.createdAt = Date.now()
    c.updatedAt = Date.now()
    return c
  }
}

export class StudyLog {
  id: string = ''
  studyDate: string = ''
  topic: string = ''
  content: string = ''
  harvest: string = ''
  summary: string = ''
  tags: string[] = []
  themeIds: string[] = []
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(topic: string): StudyLog {
    const s = new StudyLog()
    s.id = `st_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    s.studyDate = ''
    s.topic = topic
    s.content = ''
    s.harvest = ''
    s.summary = ''
    s.tags = []
    s.themeIds = []
    s.createdAt = Date.now()
    s.updatedAt = Date.now()
    return s
  }
}

export class Spark {
  id: string = ''
  title: string = ''
  body: string = ''
  kind: string = 'idea'
  tags: string[] = []
  themeIds: string[] = []
  favorite: boolean = false
  promotedThoughtId: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(title: string): Spark {
    const s = new Spark()
    s.id = `sp_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    s.title = title
    s.body = ''
    s.kind = 'idea'
    s.tags = []
    s.themeIds = []
    s.favorite = false
    s.promotedThoughtId = ''
    s.createdAt = Date.now()
    s.updatedAt = Date.now()
    return s
  }
}

export class ThemeSpace {
  id: string = ''
  title: string = ''
  summary: string = ''
  tags: string[] = []
  createdAt: number = 0
  updatedAt: number = 0

  static createNew(title: string): ThemeSpace {
    const t = new ThemeSpace()
    t.id = `tm_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.title = title
    t.summary = ''
    t.tags = []
    t.createdAt = Date.now()
    t.updatedAt = Date.now()
    return t
  }
}

export class BowenProfile {
  nickname: string = ''
  themeMode: string = 'system'
}

export class BowenStats {
  thoughtCount: number = 0
  readingCount: number = 0
  cardCount: number = 0
  studyCount: number = 0
  sparkCount: number = 0
  themeCount: number = 0
  favoriteCount: number = 0
  settledCount: number = 0
  streakDays: number = 0
  todayNewCount: number = 0
}

export class TimelineEvent {
  id: string = ''
  kind: string = 'thought'
  title: string = ''
  subtitle: string = ''
  ts: number = 0
}

export class OrganizeHint {
  id: string = ''
  kind: string = ''
  entityKind: string = ''
  entityId: string = ''
  title: string = ''
  message: string = ''
}

export class MonthlyBar {
  monthKey: string = ''
  label: string = ''
  count: number = 0
}

export class CatShare {
  key: string = ''
  label: string = ''
  count: number = 0
}

export class YearReport {
  year: string = ''
  thoughtCount: number = 0
  readingCount: number = 0
  themeCount: number = 0
  favoriteCount: number = 0
  topTheme: string = ''
  topTag: string = ''
  highlightTitle: string = ''
}

export class AchievementDef {
  id: string = ''
  title: string = ''
  hint: string = ''

  static make(id: string, title: string, hint: string): AchievementDef {
    const a = new AchievementDef()
    a.id = id
    a.title = title
    a.hint = hint
    return a
  }

  static catalog(): AchievementDef[] {
    const out: AchievementDef[] = []
    out.push(AchievementDef.make('first_card', '初识博闻', '完成第一条知识记录'))
    out.push(AchievementDef.make('reading_20', '阅读达人', '完成 20 次阅读沉淀'))
    out.push(AchievementDef.make('favorite_100', '知识收藏家', '收藏 100 条内容'))
    out.push(AchievementDef.make('themes_5', '专题策展人', '创建 5 个知识专题'))
    out.push(AchievementDef.make('streak_30', '长期学习者', '连续记录 30 天'))
    out.push(AchievementDef.make('cards_50', '卡片五十', '积累 50 张知识卡片'))
    out.push(AchievementDef.make('study_10', '学习十次', '完成 10 条学习记录'))
    return out
  }
}

export class LabelOption {
  key: string = ''
  label: string = ''

  static make(key: string, label: string): LabelOption {
    const o = new LabelOption()
    o.key = key
    o.label = label
    return o
  }

  static categories(): LabelOption[] {
    const out: LabelOption[] = []
    out.push(LabelOption.make('tech', '科技'))
    out.push(LabelOption.make('history', '历史'))
    out.push(LabelOption.make('reading', '阅读'))
    out.push(LabelOption.make('study', '学习'))
    out.push(LabelOption.make('work', '工作'))
    out.push(LabelOption.make('hobby', '兴趣'))
    return out
  }

  static favoriteTiers(): LabelOption[] {
    const out: LabelOption[] = []
    out.push(LabelOption.make('none', '未收藏'))
    out.push(LabelOption.make('todo', '待学习'))
    out.push(LabelOption.make('essence', '精华'))
    out.push(LabelOption.make('important', '重要'))
    out.push(LabelOption.make('archive', '长期保存'))
    return out
  }

  static cardSources(): LabelOption[] {
    const out: LabelOption[] = []
    out.push(LabelOption.make('book', '书籍'))
    out.push(LabelOption.make('course', '课程'))
    out.push(LabelOption.make('life', '生活观察'))
    out.push(LabelOption.make('other', '其他'))
    return out
  }

  static thoughtKinds(): LabelOption[] {
    const out: LabelOption[] = []
    out.push(LabelOption.make('viewpoint', '观点'))
    out.push(LabelOption.make('insight', '感悟'))
    out.push(LabelOption.make('summary', '总结'))
    out.push(LabelOption.make('question', '问题'))
    return out
  }

  static statuses(): LabelOption[] {
    const out: LabelOption[] = []
    out.push(LabelOption.make('draft', '草稿'))
    out.push(LabelOption.make('organizing', '整理中'))
    out.push(LabelOption.make('settled', '已沉淀'))
    out.push(LabelOption.make('treasured', '珍藏'))
    return out
  }

  static sources(): LabelOption[] {
    const out: LabelOption[] = []
    out.push(LabelOption.make('book', '书籍'))
    out.push(LabelOption.make('article', '文章'))
    out.push(LabelOption.make('course', '课程资料'))
    return out
  }

  static sparkKinds(): LabelOption[] {
    const out: LabelOption[] = []
    out.push(LabelOption.make('idea', '想法'))
    out.push(LabelOption.make('creative', '创意'))
    out.push(LabelOption.make('question', '问题'))
    out.push(LabelOption.make('plan', '计划'))
    return out
  }

  static labelOf(list: LabelOption[], key: string): string {
    for (const o of list) {
      if (o.key === key) {
        return o.label
      }
    }
    return key
  }
}

export class FeedItem {
  id: string = ''
  kind: string = ''
  title: string = ''
  summary: string = ''
  meta: string = ''
  ts: number = 0
}
