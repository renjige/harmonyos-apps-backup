/** 生活工具箱本地模型（ArkTS 严格模式） */

export class MoodEntry {
  id: string = ''
  date: string = ''
  moodId: string = ''
  note: string = ''

  static fromParts(id: string, date: string, moodId: string, note: string): MoodEntry {
    const row = new MoodEntry()
    row.id = id
    row.date = date
    row.moodId = moodId
    row.note = note
    return row
  }

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"date":${JSON.stringify(this.date)},"moodId":${JSON.stringify(this.moodId)},"note":${JSON.stringify(this.note)}}`
  }

  static fromRaw(id: string, date: string, moodId: string, note: string): MoodEntry {
    return MoodEntry.fromParts(id, date, moodId, note)
  }
}

export class ReminderItem {
  id: string = ''
  title: string = ''
  category: string = 'life'
  date: string = ''
  time: string = '09:00'
  enabled: boolean = true
  agentId: number = 0

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},"category":${JSON.stringify(this.category)},"date":${JSON.stringify(this.date)},"time":${JSON.stringify(this.time)},"enabled":${this.enabled},"agentId":${this.agentId}}`
  }
}

export class TodoItem {
  id: string = ''
  title: string = ''
  category: string = 'life'
  done: boolean = false
  date: string = ''

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},"category":${JSON.stringify(this.category)},"done":${this.done},"date":${JSON.stringify(this.date)}}`
  }
}

export class LifeTag {
  id: string = ''
  name: string = ''
  category: string = 'custom'
  builtin: boolean = false

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"name":${JSON.stringify(this.name)},"category":${JSON.stringify(this.category)},"builtin":${this.builtin}}`
  }
}

export class HabitItem {
  id: string = ''
  title: string = ''
  checkins: string[] = []

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},"checkins":${JSON.stringify(this.checkins)}}`
  }

  streak(): number {
    const today = LifeDates.todayIso()
    let cursor = today
    let count = 0
    let guard = 0
    while (guard < 400) {
      let hit = false
      for (const d of this.checkins) {
        if (d === cursor) {
          hit = true
        }
      }
      if (!hit) {
        if (count === 0 && cursor === today) {
          cursor = LifeDates.shiftIso(cursor, -1)
          guard += 1
          continue
        }
        return count
      }
      count += 1
      cursor = LifeDates.shiftIso(cursor, -1)
      guard += 1
    }
    return count
  }

  checkedOn(iso: string): boolean {
    for (const d of this.checkins) {
      if (d === iso) {
        return true
      }
    }
    return false
  }

  monthCount(year: number, month: number): number {
    const mm = month < 10 ? `0${month}` : `${month}`
    const prefix = `${year}-${mm}-`
    let n = 0
    for (const d of this.checkins) {
      if (d.startsWith(prefix)) {
        n += 1
      }
    }
    return n
  }
}

export class GoalItem {
  id: string = ''
  title: string = ''
  progress: number = 0
  status: string = 'active'

  toJsonString(): string {
    return `{"id":${JSON.stringify(this.id)},"title":${JSON.stringify(this.title)},"progress":${this.progress},"status":${JSON.stringify(this.status)}}`
  }
}

export class LifeToolEntry {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  icon: string = 'home'

  constructor(id: string, title: string, subtitle: string, icon: string) {
    this.id = id
    this.title = title
    this.subtitle = subtitle
    this.icon = icon
  }
}

export class DayCount {
  iso: string = ''
  count: number = 0
}

export class LifeDates {
  static todayIso(): string {
    const d = new Date()
    return LifeDates.toIso(d)
  }

  static toIso(d: Date): string {
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  static nowTime(): string {
    const d = new Date()
    const h = d.getHours()
    const m = d.getMinutes()
    const hh = h < 10 ? `0${h}` : `${h}`
    const mm = m < 10 ? `0${m}` : `${m}`
    return `${hh}:${mm}`
  }

  static shiftIso(iso: string, days: number): string {
    if (iso.length < 10) {
      return iso
    }
    const y = parseInt(iso.substring(0, 4), 10)
    const m = parseInt(iso.substring(5, 7), 10)
    const d = parseInt(iso.substring(8, 10), 10)
    const dt = new Date(y, m - 1, d)
    dt.setDate(dt.getDate() + days)
    return LifeDates.toIso(dt)
  }

  static pad2(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  static weekStartIso(): string {
    const d = new Date()
    const day = d.getDay()
    const diff = day === 0 ? -6 : 1 - day
    d.setDate(d.getDate() + diff)
    return LifeDates.toIso(d)
  }

  static monthPrefix(iso: string): string {
    if (iso.length < 7) {
      return iso
    }
    return iso.substring(0, 7) + '-'
  }

  static monthEndIso(): string {
    const d = new Date()
    const last = new Date(d.getFullYear(), d.getMonth() + 1, 0)
    return LifeDates.toIso(last)
  }

  static inRange(iso: string, start: string, end: string): boolean {
    return iso >= start && iso <= end
  }
}
