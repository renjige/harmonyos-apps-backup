/** 心情手册 — 情绪状态目录（非医疗诊断） */
import { DateFormatUtil } from '../components/design-system/DateFormatUtil'

export class MoodOption {
  id: string = ''
  label: string = ''
  color: string = ''
  hint: string = ''

  constructor(id: string, label: string, color: string, hint: string) {
    this.id = id
    this.label = label
    this.color = color
    this.hint = hint
  }
}

export class MoodCatalog {
  static all(): MoodOption[] {
    return [
      new MoodOption('joyful', '愉悦', '#A8D5BA', '像薄荷一样轻盈'),
      new MoodOption('warm', '温暖', '#E8B4BC', '被柔和的光包围'),
      new MoodOption('calm', '平静', '#9B8AA8', '雾霾紫里的安宁'),
      new MoodOption('tired', '疲惫', '#C9C4BC', '需要慢下来'),
      new MoodOption('low', '低落', '#8FA8B8', '允许自己休息')
    ]
  }

  static find(id: string): MoodOption | undefined {
    for (const m of MoodCatalog.all()) {
      if (m.id === id) {
        return m
      }
    }
    return undefined
  }

  static labelOf(id: string): string {
    const m = MoodCatalog.find(id)
    if (m !== undefined) {
      return m.label
    }
    return '未标记'
  }

  static colorOf(id: string): string {
    const m = MoodCatalog.find(id)
    if (m !== undefined) {
      return m.color
    }
    return '#9B8AA8'
  }

  /** 浅色心情底上的标签字色（避免白字叠浅底导致对比度不足） */
  static chipTextColor(id: string): string {
    if (id === 'calm' || id === 'low') {
      return '#FAF7F2'
    }
    return '#3D3842'
  }

  /** 连续记录天数（按 recordDate 去重后倒序计算） */
  static streakDays(dates: string[]): number {
    if (dates.length === 0) {
      return 0
    }
    const unique = MoodCatalog.uniqueDates(dates)
    const sorted = MoodCatalog.sortDesc(unique)
    let head = ''
    for (const d of sorted) {
      head = d
      break
    }
    if (head.length === 0) {
      return 0
    }
    const today = DateFormatUtil.formatDate(new Date())
    const yesterday = MoodCatalog.prevDayIso(today)
    if (head !== today && head !== yesterday) {
      return 0
    }
    let streak = 1
    let prev = head
    let skippedHead = false
    for (const d of sorted) {
      if (!skippedHead) {
        skippedHead = true
        continue
      }
      const expected = MoodCatalog.prevDayIso(prev)
      if (d === expected) {
        streak += 1
        prev = d
      } else {
        break
      }
    }
    return streak
  }

  private static uniqueDates(dates: string[]): string[] {
    const out: string[] = []
    for (const d of dates) {
      if (d.length === 0) {
        continue
      }
      let exists = false
      for (const u of out) {
        if (u === d) {
          exists = true
          break
        }
      }
      if (!exists) {
        out.push(d)
      }
    }
    return out
  }

  private static sortDesc(items: string[]): string[] {
    const work: string[] = []
    for (const x of items) {
      work.push(x)
    }
    const result: string[] = []
    while (work.length > 0) {
      let best = ''
      for (const x of work) {
        if (best.length === 0 || x.localeCompare(best) > 0) {
          best = x
        }
      }
      result.push(best)
      const remaining: string[] = []
      for (const x of work) {
        if (x !== best) {
          remaining.push(x)
        }
      }
      work.length = 0
      for (const x of remaining) {
        work.push(x)
      }
    }
    return result
  }

  private static prevDayIso(iso: string): string {
    const dt = DateFormatUtil.parseDate(iso)
    dt.setDate(dt.getDate() - 1)
    return DateFormatUtil.formatDate(dt)
  }
}
