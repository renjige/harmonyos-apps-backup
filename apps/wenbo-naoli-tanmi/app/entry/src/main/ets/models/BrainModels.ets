export class DrillItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = 'cover_memory'
  category: string = ''
  categoryLabel: string = ''
  gameType: string = 'memory'
  dimension: string = 'memory'
  durationMin: number = 3
  difficulty: string = '入门'
}

export class DrillListData {
  list: DrillItem[] = []
}

export class ArticleItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = 'cover_know_palace'
  category: string = ''
  categoryLabel: string = ''
  readMinutes: number = 3
}

export class ArticleListData {
  list: ArticleItem[] = []
}

export class AchieveItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  rule: string = ''
  coverKey: string = 'cover_ach_first'
}

export class AchieveListData {
  list: AchieveItem[] = []
}

export class ProbeItem {
  id: string = ''
  title: string = ''
  question: string = ''
  optionA: string = ''
  optionB: string = ''
  optionC: string = ''
  optionD: string = ''
  answerIndex: number = 0
  explanation: string = ''
  dimension: string = 'memory'
}

export class ProbeListData {
  list: ProbeItem[] = []
}

export class SessionItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  drillId: string = ''
  gameType: string = ''
  score: number = 0
  durationSec: number = 0
  dateKey: string = ''
  userId: string = ''
}

export class SessionListData {
  list: SessionItem[] = []
}

export class SessionRequest {
  drillId: string = ''
  gameType: string = ''
  score: number = 0
  durationSec: number = 0
  dateKey: string = ''
  username: string = ''
  title: string = ''

  toJsonString(): string {
    return `{"drillId":${JSON.stringify(this.drillId)},"gameType":${JSON.stringify(this.gameType)},` +
      `"score":${this.score},"durationSec":${this.durationSec},"dateKey":${JSON.stringify(this.dateKey)},` +
      `"username":${JSON.stringify(this.username)},"title":${JSON.stringify(this.title)}}`
  }
}

export class MsgItem {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = 'system'
  read: boolean = false
}

export class MsgListData {
  list: MsgItem[] = []
}

export class DimScore {
  key: string = ''
  label: string = ''
  value: number = 0
}

export class BrainMappers {
  static drill(raw: DrillItem): DrillItem {
    const d = new DrillItem()
    d.id = raw.id ?? ''
    d.title = raw.title ?? ''
    d.subtitle = raw.subtitle ?? ''
    d.summary = raw.summary ?? ''
    d.body = raw.body ?? ''
    d.description = raw.description ?? ''
    d.coverKey = raw.coverKey ?? 'cover_memory'
    d.category = raw.category ?? ''
    d.categoryLabel = raw.categoryLabel ?? ''
    d.gameType = raw.gameType ?? 'memory'
    d.dimension = raw.dimension ?? 'memory'
    d.durationMin = raw.durationMin ?? 3
    d.difficulty = raw.difficulty ?? '入门'
    return d
  }

  static article(raw: ArticleItem): ArticleItem {
    const a = new ArticleItem()
    a.id = raw.id ?? ''
    a.title = raw.title ?? ''
    a.subtitle = raw.subtitle ?? ''
    a.summary = raw.summary ?? ''
    a.body = raw.body ?? ''
    a.description = raw.description ?? ''
    a.coverKey = raw.coverKey ?? 'cover_know_palace'
    a.category = raw.category ?? ''
    a.categoryLabel = raw.categoryLabel ?? ''
    a.readMinutes = raw.readMinutes ?? 3
    return a
  }

  static achieve(raw: AchieveItem): AchieveItem {
    const a = new AchieveItem()
    a.id = raw.id ?? ''
    a.title = raw.title ?? ''
    a.subtitle = raw.subtitle ?? ''
    a.summary = raw.summary ?? ''
    a.body = raw.body ?? ''
    a.rule = raw.rule ?? ''
    a.coverKey = raw.coverKey ?? 'cover_ach_first'
    return a
  }

  static probe(raw: ProbeItem): ProbeItem {
    const p = new ProbeItem()
    p.id = raw.id ?? ''
    p.title = raw.title ?? ''
    p.question = raw.question ?? ''
    p.optionA = raw.optionA ?? ''
    p.optionB = raw.optionB ?? ''
    p.optionC = raw.optionC ?? ''
    p.optionD = raw.optionD ?? ''
    p.answerIndex = raw.answerIndex ?? 0
    p.explanation = raw.explanation ?? ''
    p.dimension = raw.dimension ?? 'memory'
    return p
  }

  static message(raw: MsgItem): MsgItem {
    const m = new MsgItem()
    m.id = raw.id ?? ''
    m.title = raw.title ?? ''
    m.body = raw.body ?? ''
    m.type = raw.type ?? 'system'
    m.read = raw.read === true
    return m
  }
}
