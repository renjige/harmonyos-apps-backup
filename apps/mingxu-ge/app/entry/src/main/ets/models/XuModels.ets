export class XuDateHelper {
  static todayKey(): string {
    return XuDateHelper.keyFromDate(new Date())
  }

  static keyFromDate(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static displayDate(d: Date): string {
    const names: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日 星期${names[d.getDay()]}`
  }

  static monthTitle(year: number, month: number): string {
    return `${year}年${month}月`
  }

  static newId(): string {
    return `${Date.now()}_${Math.floor(Math.random() * 100000)}`
  }

  static daysInMonth(year: number, month: number): number {
    return new Date(year, month, 0).getDate()
  }

  static firstWeekday(year: number, month: number): number {
    return new Date(year, month - 1, 1).getDay()
  }
}

export class XuAgendaItem {
  id: string = ''
  kind: string = 'todo'
  title: string = ''
  remark: string = ''
  dateKey: string = ''
  timeText: string = ''
  priority: string = 'mid'
  done: boolean = false
  remindOn: boolean = false
  createdAt: number = 0
  updatedAt: number = 0

  static create(kind: string, title: string, dateKey: string, timeText: string, priority: string): XuAgendaItem {
    const it = new XuAgendaItem()
    it.id = XuDateHelper.newId()
    it.kind = kind
    it.title = title
    it.dateKey = dateKey
    it.timeText = timeText
    it.priority = priority
    it.createdAt = Date.now()
    it.updatedAt = it.createdAt
    return it
  }

  priorityLabel(): string {
    if (this.priority === 'high') {
      return '高'
    }
    if (this.priority === 'low') {
      return '低'
    }
    return '中'
  }

  kindLabel(): string {
    return this.kind === 'event' ? '日程' : '待办'
  }
}

export class XuHabitItem {
  id: string = ''
  title: string = ''
  remark: string = ''
  streak: number = 0
  lastCheck: string = ''
  createdAt: number = 0

  static create(title: string, remark: string): XuHabitItem {
    const h = new XuHabitItem()
    h.id = XuDateHelper.newId()
    h.title = title
    h.remark = remark
    h.createdAt = Date.now()
    return h
  }

  checkedToday(todayKey: string): boolean {
    return this.lastCheck === todayKey
  }
}

export class XuNoteItem {
  id: string = ''
  title: string = ''
  body: string = ''
  tags: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  static create(title: string, body: string, tags: string): XuNoteItem {
    const n = new XuNoteItem()
    n.id = XuDateHelper.newId()
    n.title = title
    n.body = body
    n.tags = tags
    n.createdAt = Date.now()
    n.updatedAt = n.createdAt
    return n
  }

  summary(maxLen: number): string {
    const raw = this.body.length > 0 ? this.body : this.title
    if (raw.length <= maxLen) {
      return raw
    }
    return `${raw.substring(0, maxLen)}…`
  }

  tagList(): string[] {
    if (this.tags.length === 0) {
      return []
    }
    return this.tags.split('|')
  }

  tagPreview(): string {
    const list = this.tagList()
    const parts: string[] = []
    for (const t of list) {
      if (parts.length >= 3) {
        break
      }
      if (t.length > 0) {
        parts.push(t)
      }
    }
    return parts.join(' · ')
  }
}

export class XuMoodItem {
  dateKey: string = ''
  mood: string = '安宁'
  energy: number = 3
  updatedAt: number = 0

  static create(dateKey: string, mood: string, energy: number): XuMoodItem {
    const m = new XuMoodItem()
    m.dateKey = dateKey
    m.mood = mood
    m.energy = energy
    m.updatedAt = Date.now()
    return m
  }
}

export class XuTipItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  readMinutes: number = 3
}

export class XuCalCell {
  dateKey: string = ''
  dayNum: number = 0
  inMonth: boolean = false
  isToday: boolean = false
  selected: boolean = false
  hasItems: boolean = false
}

export class XuAppStats {
  habitCheckTotal: number = 0
  habitTodayCount: number = 0
  habitStreakDays: number = 0
  agendaDone: number = 0
  agendaTotal: number = 0
  noteCount: number = 0
  usedDays: number = 1
}

export class XuListPayload {
  list: XuTipWire[] = []
}

export class XuTipWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  readMinutes: number = 3
}

export class XuMsgPayload {
  list: XuMsgWire[] = []
}

export class XuMsgWire {
  id: string = ''
  title: string = ''
  body: string = ''
  createdAt: string = ''
}

export class XuMsgItem {
  id: string = ''
  title: string = ''
  body: string = ''
}

export class XuWriteBody {
  raw: string = ''

  static of(raw: string): XuWriteBody {
    const b = new XuWriteBody()
    b.raw = raw
    return b
  }
}

export class XuWisdomItem {
  title: string = ''
  body: string = ''
  action: string = ''
}
