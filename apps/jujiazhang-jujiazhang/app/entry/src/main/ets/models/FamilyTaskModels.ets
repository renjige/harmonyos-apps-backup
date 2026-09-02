export class FamilyTaskItem {
  id: string = ''
  title: string = ''
  category: string = '其他'
  date: string = ''
  time: string = ''
  completed: boolean = false
  reminder: string = 'none'
  repeatType: string = 'none'
  remark: string = ''
  assignee: string = ''
  reminderAgentId: number = 0
  userId: string = ''
  createdAt: string = ''
  updatedAt: string = ''
  isSample: boolean = false

  period(): string {
    if (this.time.length < 2) {
      return '全天'
    }
    const hourText = this.time.substring(0, 2)
    const hour = Number.parseInt(hourText)
    if (hour < 12) {
      return '上午'
    }
    return '下午'
  }

  coverKey(): string {
    if (this.category === '家务安排' || this.category === '家务') {
      return 'cat_chore'
    }
    if (this.category === '家庭采购' || this.category === '采购') {
      return 'cat_shop'
    }
    if (this.category === '维修事项') {
      return 'cat_family'
    }
    return 'cat_other'
  }
}

export class FamilyCategory {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
}

export class FamilyRhythm {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
}

export class FamilyNotice {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = 'system'
  read: boolean = false
}

export class ListPayload<T> {
  list: T[] = []
  items: T[] = []
}

export class LocalBundle {
  tasks: FamilyTaskItem[] = []
}

export class BundleWire {
  tasks: FamilyTaskItem[] = []
}

export class CreateTaskBody {
  title: string = ''
  category: string = '其他'
  date: string = ''
  time: string = ''
  reminder: string = 'none'
  repeatType: string = 'none'
  remark: string = ''
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"category":${JSON.stringify(this.category)},"date":${JSON.stringify(this.date)},"time":${JSON.stringify(this.time)},"reminder":${JSON.stringify(this.reminder)},"repeatType":${JSON.stringify(this.repeatType)},"remark":${JSON.stringify(this.remark)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class PatchTaskBody {
  title: string = ''
  category: string = ''
  date: string = ''
  time: string = ''
  reminder: string = ''
  repeatType: string = ''
  remark: string = ''
  completed: boolean = false
  userId: string = ''

  toJsonString(): string {
    const done = this.completed ? 'true' : 'false'
    return `{"title":${JSON.stringify(this.title)},"category":${JSON.stringify(this.category)},"date":${JSON.stringify(this.date)},"time":${JSON.stringify(this.time)},"reminder":${JSON.stringify(this.reminder)},"repeatType":${JSON.stringify(this.repeatType)},"remark":${JSON.stringify(this.remark)},"completed":${done},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class DayCell {
  key: string = ''
  day: number = 0
  date: string = ''
  inMonth: boolean = false
  isToday: boolean = false
  hasTask: boolean = false
}

export class TaskDates {
  static pad(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  static ymd(d: Date): string {
    return `${d.getFullYear()}-${TaskDates.pad(d.getMonth() + 1)}-${TaskDates.pad(d.getDate())}`
  }

  static today(): string {
    return TaskDates.ymd(new Date())
  }

  static tomorrow(): string {
    const d = new Date()
    d.setDate(d.getDate() + 1)
    return TaskDates.ymd(d)
  }

  static parse(ymd: string): Date {
    const p = ymd.split('-')
    if (p.length < 3) {
      return new Date()
    }
    return new Date(Number.parseInt(p[0]), Number.parseInt(p[1]) - 1, Number.parseInt(p[2]))
  }

  static weekdayLabel(ymd: string): string {
    const names = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
    const d = TaskDates.parse(ymd)
    return names[d.getDay()]
  }

  static displayDate(ymd: string): string {
    const d = TaskDates.parse(ymd)
    return `${d.getMonth() + 1}月${d.getDate()}日 ${TaskDates.weekdayLabel(ymd)}`
  }

  static addDays(ymd: string, days: number): string {
    const d = TaskDates.parse(ymd)
    d.setDate(d.getDate() + days)
    return TaskDates.ymd(d)
  }

  static addMonths(ymd: string, months: number): string {
    const d = TaskDates.parse(ymd)
    d.setMonth(d.getMonth() + months)
    return TaskDates.ymd(d)
  }

  static greeting(): string {
    const h = new Date().getHours()
    if (h < 11) {
      return '早上好'
    }
    if (h < 18) {
      return '下午好'
    }
    return '晚上好'
  }

  static startOfWeek(ymd: string): string {
    const d = TaskDates.parse(ymd)
    const day = d.getDay()
    const offset = day === 0 ? 6 : day - 1
    d.setDate(d.getDate() - offset)
    return TaskDates.ymd(d)
  }

  static inSameWeek(a: string, b: string): boolean {
    return TaskDates.startOfWeek(a) === TaskDates.startOfWeek(b)
  }

  static nextRepeat(ymd: string, repeatType: string): string {
    if (repeatType === 'daily') {
      return TaskDates.addDays(ymd, 1)
    }
    if (repeatType === 'weekly') {
      return TaskDates.addDays(ymd, 7)
    }
    if (repeatType === 'monthly') {
      return TaskDates.addMonths(ymd, 1)
    }
    return ymd
  }
}
