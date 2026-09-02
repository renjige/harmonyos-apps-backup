/** 行程备忘数据模型（ArkTS 严格模式） */

export class TripItem {
  id: string = ''
  title: string = ''
  startDate: string = ''
  endDate: string = ''
  location: string = ''
  remark: string = ''
  reminderOffset: number = 0
  status: string = 'upcoming'
  createdAt: number = 0
  updatedAt: number = 0

  dayCount(): number {
    return TripDateHelp.daySpan(this.startDate, this.endDate)
  }

  dateRange(): string {
    if (this.startDate === this.endDate) {
      return this.startDate
    }
    return `${this.startDate}  —  ${this.endDate}`
  }

  statusLabel(): string {
    if (this.status === 'active') {
      return '进行中'
    }
    if (this.status === 'done') {
      return '已完成'
    }
    if (this.status === 'cancelled') {
      return '已取消'
    }
    return '即将开始'
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},` +
      `"startDate":${JSON.stringify(this.startDate)},"endDate":${JSON.stringify(this.endDate)},` +
      `"location":${JSON.stringify(this.location)},"remark":${JSON.stringify(this.remark)},` +
      `"reminderOffset":${this.reminderOffset},"status":${JSON.stringify(this.status)},` +
      `"createdAt":${this.createdAt},"updatedAt":${this.updatedAt}}`
  }

  static fromWire(w: TripWire): TripItem {
    const n = new TripItem()
    n.id = w.id
    n.title = w.title
    n.startDate = w.startDate
    n.endDate = w.endDate
    n.location = w.location
    n.remark = w.remark
    n.reminderOffset = w.reminderOffset
    n.status = w.status.length > 0 ? w.status : 'upcoming'
    n.createdAt = w.createdAt
    n.updatedAt = w.updatedAt
    return n
  }
}

export class TripWire {
  id: string = ''
  title: string = ''
  startDate: string = ''
  endDate: string = ''
  location: string = ''
  remark: string = ''
  reminderOffset: number = 0
  status: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}

export class TripFile {
  items: TripWire[] = []
}

export class MemoItem {
  id: string = ''
  tripId: string = ''
  title: string = ''
  itemDate: string = ''
  time: string = ''
  location: string = ''
  remark: string = ''
  reminderOffset: number = 0
  status: string = 'pending'
  createdAt: number = 0
  updatedAt: number = 0

  statusLabel(): string {
    if (this.status === 'ongoing') {
      return '进行中'
    }
    if (this.status === 'done') {
      return '已完成'
    }
    if (this.status === 'cancelled') {
      return '已取消'
    }
    return '待开始'
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"tripId":${JSON.stringify(this.tripId)},` +
      `"title":${JSON.stringify(this.title)},"itemDate":${JSON.stringify(this.itemDate)},` +
      `"time":${JSON.stringify(this.time)},"location":${JSON.stringify(this.location)},` +
      `"remark":${JSON.stringify(this.remark)},"reminderOffset":${this.reminderOffset},` +
      `"status":${JSON.stringify(this.status)},"createdAt":${this.createdAt},"updatedAt":${this.updatedAt}}`
  }

  static fromWire(w: MemoWire): MemoItem {
    const n = new MemoItem()
    n.id = w.id
    n.tripId = w.tripId
    n.title = w.title
    n.itemDate = w.itemDate
    n.time = w.time
    n.location = w.location
    n.remark = w.remark
    n.reminderOffset = w.reminderOffset
    n.status = w.status.length > 0 ? w.status : 'pending'
    n.createdAt = w.createdAt
    n.updatedAt = w.updatedAt
    return n
  }
}

export class MemoWire {
  id: string = ''
  tripId: string = ''
  title: string = ''
  itemDate: string = ''
  time: string = ''
  location: string = ''
  remark: string = ''
  reminderOffset: number = 0
  status: string = ''
  createdAt: number = 0
  updatedAt: number = 0
}

export class MemoFile {
  items: MemoWire[] = []
}

export class TplStep {
  title: string = ''
  offsetDays: number = 0
  time: string = ''
  location: string = ''
  remark: string = ''
}

export class TplItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  description: string = ''
  coverKey: string = ''
  durationDays: number = 1
  steps: TplStep[] = []
}

export class TplWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  description: string = ''
  body: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  durationDays: number = 1
}

export class TplListPayload {
  list: TplWire[] = []
}

export class StepWire {
  title: string = ''
  offsetDays: number = 0
  time: string = ''
  location: string = ''
  remark: string = ''
}

export class TripDateHelp {
  static pad2(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  static todayIso(): string {
    const d = new Date()
    return TripDateHelp.toIso(d)
  }

  static toIso(d: Date): string {
    return `${d.getFullYear()}-${TripDateHelp.pad2(d.getMonth() + 1)}-${TripDateHelp.pad2(d.getDate())}`
  }

  static parseIso(text: string): Date {
    const parts = text.split('-')
    if (parts.length === 3) {
      const y = Number.parseInt(parts[0], 10)
      const m = Number.parseInt(parts[1], 10)
      const day = Number.parseInt(parts[2], 10)
      if (!Number.isNaN(y) && !Number.isNaN(m) && !Number.isNaN(day)) {
        return new Date(y, m - 1, day)
      }
    }
    return new Date()
  }

  static addDaysIso(iso: string, days: number): string {
    const d = TripDateHelp.parseIso(iso)
    d.setDate(d.getDate() + days)
    return TripDateHelp.toIso(d)
  }

  static daySpan(start: string, end: string): number {
    const a = TripDateHelp.parseIso(start).getTime()
    const b = TripDateHelp.parseIso(end).getTime()
    const diff = Math.floor((b - a) / 86400000)
    if (diff < 0) {
      return 1
    }
    return diff + 1
  }

  static weekdayLabel(d: Date): string {
    const i = d.getDay()
    if (i === 1) {
      return '星期一'
    }
    if (i === 2) {
      return '星期二'
    }
    if (i === 3) {
      return '星期三'
    }
    if (i === 4) {
      return '星期四'
    }
    if (i === 5) {
      return '星期五'
    }
    if (i === 6) {
      return '星期六'
    }
    return '星期日'
  }

  static homeTitle(d: Date): string {
    return `${d.getMonth() + 1}月${d.getDate()}日`
  }

  static cmpTime(a: string, b: string): number {
    if (a < b) {
      return -1
    }
    if (a > b) {
      return 1
    }
    return 0
  }

  static nowHm(): string {
    const d = new Date()
    return `${TripDateHelp.pad2(d.getHours())}:${TripDateHelp.pad2(d.getMinutes())}`
  }

  static liveTripStatus(trip: TripItem, today: string): string {
    if (trip.status === 'cancelled' || trip.status === 'done') {
      return trip.status
    }
    if (today < trip.startDate) {
      return 'upcoming'
    }
    if (today > trip.endDate) {
      return 'done'
    }
    return 'active'
  }

  static liveItemStatus(item: MemoItem, today: string): string {
    if (item.status === 'cancelled' || item.status === 'done') {
      return item.status
    }
    if (item.itemDate !== today) {
      return 'pending'
    }
    if (item.time.length === 0) {
      return 'pending'
    }
    if (TripDateHelp.cmpTime(item.time, TripDateHelp.nowHm()) <= 0) {
      return 'ongoing'
    }
    return 'pending'
  }

  static remindLabel(offset: number): string {
    if (offset === 10) {
      return '提前 10 分钟'
    }
    if (offset === 30) {
      return '提前 30 分钟'
    }
    if (offset === 60) {
      return '提前 1 小时'
    }
    if (offset === 1440) {
      return '提前 1 天'
    }
    return '关闭提醒'
  }
}
