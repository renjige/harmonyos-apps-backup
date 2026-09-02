/** 研语 · 个人研究与知识沉淀（本机） */

export class ResearchNote {
  id: string = ''
  title: string = ''
  body: string = ''
  viewpoint: string = ''
  topicId: string = ''
  tagKeys: string = ''
  coverKey: string = 'cover_library'
  photoPath: string = ''
  collectionId: string = ''
  starred: string = '0'
  createdAt: number = 0
  updatedAt: number = 0

  static create(): ResearchNote {
    const n = new ResearchNote()
    n.id = ResearchNote.newId()
    n.createdAt = Date.now()
    n.updatedAt = n.createdAt
    return n
  }

  static newId(): string {
    return `n_${Date.now()}_${Math.floor(Math.random() * 100000)}`
  }
}

export class ResearchTopic {
  id: string = ''
  title: string = ''
  summary: string = ''
  category: string = '读书笔记'
  coverKey: string = 'cover_academic'
  createdAt: number = 0

  static create(): ResearchTopic {
    const t = new ResearchTopic()
    t.id = `t_${Date.now()}_${Math.floor(Math.random() * 100000)}`
    t.createdAt = Date.now()
    return t
  }
}

export class ResearchTag {
  key: string = ''
  label: string = ''
  builtin: string = '0'

  static of(key: string, label: string, builtin: string): ResearchTag {
    const t = new ResearchTag()
    t.key = key
    t.label = label
    t.builtin = builtin
    return t
  }
}

export class SparkItem {
  id: string = ''
  text: string = ''
  remark: string = ''
  createdAt: number = 0

  static create(): SparkItem {
    const s = new SparkItem()
    s.id = `s_${Date.now()}_${Math.floor(Math.random() * 100000)}`
    s.createdAt = Date.now()
    return s
  }
}

export class ViewpointCard {
  id: string = ''
  quote: string = ''
  sourceId: string = ''
  createdAt: number = 0

  static create(): ViewpointCard {
    const c = new ViewpointCard()
    c.id = `c_${Date.now()}_${Math.floor(Math.random() * 100000)}`
    c.createdAt = Date.now()
    return c
  }
}

export class ReadingRecord {
  id: string = ''
  title: string = ''
  progress: string = ''
  thought: string = ''
  createdAt: number = 0

  static create(): ReadingRecord {
    const r = new ReadingRecord()
    r.id = `r_${Date.now()}_${Math.floor(Math.random() * 100000)}`
    r.createdAt = Date.now()
    return r
  }
}

export class ResearchPlan {
  id: string = ''
  title: string = ''
  goal: string = ''
  stageA: string = ''
  stageB: string = ''
  stageC: string = ''
  doneA: string = '0'
  doneB: string = '0'
  doneC: string = '0'
  createdAt: number = 0

  static create(): ResearchPlan {
    const p = new ResearchPlan()
    p.id = `p_${Date.now()}_${Math.floor(Math.random() * 100000)}`
    p.createdAt = Date.now()
    return p
  }

  progressLabel(): string {
    let n = 0
    if (this.doneA === '1') {
      n += 1
    }
    if (this.doneB === '1') {
      n += 1
    }
    if (this.doneC === '1') {
      n += 1
    }
    return `${n}/3`
  }
}

export class CollectionFolder {
  id: string = ''
  title: string = ''
  createdAt: number = 0

  static create(): CollectionFolder {
    const f = new CollectionFolder()
    f.id = `f_${Date.now()}_${Math.floor(Math.random() * 100000)}`
    f.createdAt = Date.now()
    return f
  }
}

export class DailyThink {
  dateKey: string = ''
  viewpoint: string = ''
  createdAt: number = 0

  static create(dateKey: string): DailyThink {
    const d = new DailyThink()
    d.dateKey = dateKey
    d.createdAt = Date.now()
    return d
  }
}

export class TimelineEvent {
  id: string = ''
  kind: string = ''
  title: string = ''
  summary: string = ''
  at: number = 0
}

export class ResearchStats {
  noteCount: number = 0
  topicCount: number = 0
  sparkCount: number = 0
  cardCount: number = 0
  readingCount: number = 0
  planCount: number = 0
  streak: number = 0
  weekNotes: number = 0
}

export class DeskAction {
  key: string = ''
  title: string = ''
  hint: string = ''

  static of(key: string, title: string, hint: string): DeskAction {
    const a = new DeskAction()
    a.key = key
    a.title = title
    a.hint = hint
    return a
  }

  static all(): DeskAction[] {
    return [
      DeskAction.of('notes', '研究笔记', '主题笔记 · 观点 · 配图'),
      DeskAction.of('topics', '专题资料库', '历史 / 读书 / 行业 / 兴趣'),
      DeskAction.of('tags', '知识标签', '待学习 · 已整理 · 自定义'),
      DeskAction.of('sparks', '灵感收集', '快记突然想到的内容'),
      DeskAction.of('timeline', '时间线整理', '按时间回顾思考变化'),
      DeskAction.of('cards', '观点卡片', '抽出核心观点速览'),
      DeskAction.of('readings', '阅读记录', '进度与读后感'),
      DeskAction.of('plans', '研究计划', '目标与阶段进度'),
      DeskAction.of('collections', '收藏管理', '分类收藏重要内容'),
      DeskAction.of('daily', '每日思考', '一天一个观点打卡'),
      DeskAction.of('search', '内容搜索', '关键词与标签筛选'),
      DeskAction.of('stats', '知识统计', '笔记量与连续思考')
    ]
  }
}
