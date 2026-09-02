export class LifeScript {
  id: string = ''
  title: string = ''
  sceneDescription: string = ''
  prologue: string = ''
  moodTag: string = '平静'
  imagePaths: string[] = []
  createdAt: number = 0
  updatedAt: number = 0
  dateKey: string = ''

  static createNew(dateKey: string): LifeScript {
    const s = new LifeScript()
    s.id = `s_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    s.dateKey = dateKey
    s.createdAt = Date.now()
    s.updatedAt = s.createdAt
    return s
  }

  summaryLine(): string {
    const text = this.prologue.length > 0 ? this.prologue : this.sceneDescription
    const plain = text.replace(/\n/g, ' ').trim()
    if (plain.length === 0) {
      return '（暂无摘要）'
    }
    return plain.length > 48 ? `${plain.substring(0, 48)}…` : plain
  }

  coverPath(): string {
    if (this.imagePaths.length > 0) {
      return this.imagePaths[0]
    }
    return ''
  }
}

export class MoodOption {
  key: string = ''
  label: string = ''

  static all(): MoodOption[] {
    const labels: string[] = ['开心', '感动', '平静', '思考', '其他']
    const out: MoodOption[] = []
    for (const label of labels) {
      const m = new MoodOption()
      m.key = label
      m.label = label
      out.push(m)
    }
    return out
  }

  static withAllChip(): MoodOption[] {
    const all = new MoodOption()
    all.key = '全部'
    all.label = '全部'
    const out: MoodOption[] = [all]
    const rest = MoodOption.all()
    for (const m of rest) {
      out.push(m)
    }
    return out
  }
}

export class CalendarDayCell {
  day: number = 0
  inMonth: boolean = true
  dateKey: string = ''
  hasScript: boolean = false
}

export class DateCountItem {
  dateKey: string = ''
  count: number = 0
}

export class DateCountMap {
  items: DateCountItem[] = []

  static build(scripts: LifeScript[]): DateCountMap {
    const map = new DateCountMap()
    const tally: DateCountItem[] = []
    for (const s of scripts) {
      let found: DateCountItem | undefined = undefined
      for (const t of tally) {
        if (t.dateKey === s.dateKey) {
          found = t
          break
        }
      }
      if (found === undefined) {
        const item = new DateCountItem()
        item.dateKey = s.dateKey
        item.count = 1
        tally.push(item)
      } else {
        found.count++
      }
    }
    map.items = tally
    return map
  }

  countFor(dateKey: string): number {
    for (const t of this.items) {
      if (t.dateKey === dateKey) {
        return t.count
      }
    }
    return 0
  }
}
