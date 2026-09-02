/** 生活备笺数据模型（ArkTS 严格模式） */

export class SlipItem {
  id: string = ''
  title: string = ''
  content: string = ''
  category: string = '生活'
  date: string = ''
  reminderTime: string = ''
  isReminderEnabled: boolean = false
  isImportant: boolean = false
  isCompleted: boolean = false
  createdAt: number = 0
  completedAt: number = 0
  updatedAt: number = 0

  metaLine(): string {
    let line = this.category
    if (this.date.length > 0) {
      line = `${line} · ${this.date}`
    }
    if (this.isReminderEnabled && this.reminderTime.length > 0) {
      line = `${line} ${this.reminderTime}`
    }
    return line
  }

  toJsonString(): string {
    const rem = this.isReminderEnabled ? 'true' : 'false'
    const imp = this.isImportant ? 'true' : 'false'
    const done = this.isCompleted ? 'true' : 'false'
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},` +
      `"content":${JSON.stringify(this.content)},"category":${JSON.stringify(this.category)},` +
      `"date":${JSON.stringify(this.date)},"reminderTime":${JSON.stringify(this.reminderTime)},` +
      `"isReminderEnabled":${rem},"isImportant":${imp},"isCompleted":${done},` +
      `"createdAt":${this.createdAt},"completedAt":${this.completedAt},"updatedAt":${this.updatedAt}}`
  }

  static fromWire(w: SlipWire): SlipItem {
    const n = new SlipItem()
    n.id = w.id
    n.title = w.title
    n.content = w.content
    n.category = w.category.length > 0 ? w.category : '生活'
    n.date = w.date
    n.reminderTime = w.reminderTime
    n.isReminderEnabled = w.isReminderEnabled
    n.isImportant = w.isImportant
    n.isCompleted = w.isCompleted
    n.createdAt = w.createdAt
    n.completedAt = w.completedAt
    n.updatedAt = w.updatedAt
    return n
  }
}

export class SlipWire {
  id: string = ''
  title: string = ''
  content: string = ''
  category: string = ''
  date: string = ''
  reminderTime: string = ''
  isReminderEnabled: boolean = false
  isImportant: boolean = false
  isCompleted: boolean = false
  createdAt: number = 0
  completedAt: number = 0
  updatedAt: number = 0
}

export class SlipFile {
  items: SlipWire[] = []
}

export class SlipSyncBody {
  title: string = ''
  content: string = ''
  category: string = ''
  date: string = ''
  reminderTime: string = ''
  isReminderEnabled: boolean = false
  isImportant: boolean = false
  isCompleted: boolean = false
  userId: string = ''

  toJsonString(): string {
    const rem = this.isReminderEnabled ? 'true' : 'false'
    const imp = this.isImportant ? 'true' : 'false'
    const done = this.isCompleted ? 'true' : 'false'
    return `{"title":${JSON.stringify(this.title)},"content":${JSON.stringify(this.content)},` +
      `"category":${JSON.stringify(this.category)},"date":${JSON.stringify(this.date)},` +
      `"reminderTime":${JSON.stringify(this.reminderTime)},"isReminderEnabled":${rem},` +
      `"isImportant":${imp},"isCompleted":${done},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CatalogItem {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  coverKey: string = ''
  category: string = ''
}

export class CatalogWire {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  category: string = ''
}

export class CatalogListPayload {
  list: CatalogWire[] = []
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

export class CatalogMapper {
  static fromWire(w: CatalogWire): CatalogItem {
    const item = new CatalogItem()
    item.id = CatalogMapper.text(w.id)
    item.title = CatalogMapper.text(w.title)
    const body = CatalogMapper.text(w.body)
    const summary = CatalogMapper.text(w.summary)
    const description = CatalogMapper.text(w.description)
    item.body = body.length > 0 ? body : (summary.length > 0 ? summary : description)
    item.summary = summary.length > 0 ? summary : item.body
    const coverKey = CatalogMapper.text(w.coverKey)
    const coverMedia = CatalogMapper.text(w.coverMedia)
    item.coverKey = coverKey.length > 0 ? coverKey : coverMedia
    item.category = CatalogMapper.text(w.category)
    return item
  }

  private static text(v: string): string {
    if (!v) {
      return ''
    }
    return v
  }
}

export class CategoryCatalog {
  static all(): string[] {
    return ['生活', '工作', '家庭', '购物', '出行', '学习', '其他']
  }

  static withAll(): string[] {
    const out: string[] = ['全部']
    const cats = CategoryCatalog.all()
    for (const c of cats) {
      out.push(c)
    }
    return out
  }
}

export class CalCell {
  iso: string = ''
  day: number = 0
  inMonth: boolean = false
  hasItems: boolean = false
  isToday: boolean = false
  isSelected: boolean = false
}

export class WeekBar {
  done: number = 0
  total: number = 0
  label: string = ''
}
