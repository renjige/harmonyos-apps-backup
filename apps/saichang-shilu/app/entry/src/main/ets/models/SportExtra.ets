export class KeyMoment {
  minute: number = 0
  kind: string = 'score'
  text: string = ''

  static kindLabel(kind: string): string {
    if (kind === 'score') {
      return '得分'
    }
    if (kind === 'miss') {
      return '失误'
    }
    if (kind === 'timeout') {
      return '暂停'
    }
    if (kind === 'clutch') {
      return '关键回合'
    }
    if (kind === 'injury') {
      return '身体提醒'
    }
    return '其他'
  }

  static kindIds(): string[] {
    return ['score', 'miss', 'timeout', 'clutch', 'injury', 'other']
  }

  static pack(list: KeyMoment[]): string {
    const parts: string[] = []
    for (const m of list) {
      const t = m.text.replace(/~/g, ' ').replace(/;/g, '，')
      parts.push(`${m.minute}~${m.kind}~${t}`)
    }
    return parts.join(';;')
  }

  static unpack(raw: string): KeyMoment[] {
    const out: KeyMoment[] = []
    if (raw.length === 0) {
      return out
    }
    const chunks = raw.split(';;')
    for (const c of chunks) {
      const p = c.split('~')
      if (p.length < 3) {
        continue
      }
      const m = new KeyMoment()
      m.minute = parseInt(p[0], 10)
      m.kind = p[1]
      m.text = p[2]
      out.push(m)
    }
    return out
  }
}

export class ResultOption {
  id: string = ''
  label: string = ''

  static all(): ResultOption[] {
    const out: ResultOption[] = []
    const defs: string[][] = [
      ['win', '胜'],
      ['draw', '平'],
      ['lose', '负'],
      ['practice', '训练']
    ]
    for (const row of defs) {
      const o = new ResultOption()
      o.id = row[0]
      o.label = row[1]
      out.push(o)
    }
    return out
  }

  static labelOf(id: string): string {
    for (const o of ResultOption.all()) {
      if (o.id === id) {
        return o.label
      }
    }
    return ''
  }
}

export class RivalStat {
  name: string = ''
  matches: number = 0
  wins: number = 0
  lastDate: string = ''
}

export class SeasonGoal {
  year: number = 2026
  targetMatches: number = 12
  targetMinutes: number = 600
}

export class CalendarDay {
  dateKey: string = ''
  dayNum: number = 0
  hasMark: boolean = false
  isToday: boolean = false
  blank: boolean = false
}

export class MonthBar {
  label: string = ''
  value: number = 0
}

export class ChecklistItem {
  id: string = ''
  label: string = ''
  done: boolean = false
}

export class WatchChecklist {
  static defaults(): ChecklistItem[] {
    const defs: string[][] = [
      ['time', '确认开球时间与转播'],
      ['lineup', '了解双方阵容/伤病'],
      ['venue', '记录场地或直播平台'],
      ['focus', '设定本场观察重点'],
      ['moments', '赛中记下关键瞬间'],
      ['recap', '赛后完成复盘']
    ]
    const out: ChecklistItem[] = []
    for (const row of defs) {
      const it = new ChecklistItem()
      it.id = row[0]
      it.label = row[1]
      out.push(it)
    }
    return out
  }

  static pack(list: ChecklistItem[]): string {
    const parts: string[] = []
    for (const it of list) {
      parts.push(`${it.id}~${it.done ? '1' : '0'}`)
    }
    return parts.join(';;')
  }

  static unpack(raw: string): ChecklistItem[] {
    const base = WatchChecklist.defaults()
    const out: ChecklistItem[] = []
    for (const it of base) {
      const copy = new ChecklistItem()
      copy.id = it.id
      copy.label = it.label
      copy.done = it.done
      out.push(copy)
    }
    if (raw.length === 0) {
      return out
    }
    const map = new Map<string, boolean>()
    const chunks = raw.split(';;')
    for (const c of chunks) {
      const p = c.split('~')
      if (p.length >= 2) {
        map.set(p[0], p[1] === '1')
      }
    }
    for (const it of out) {
      const v = map.get(it.id)
      if (v !== undefined) {
        it.done = v
      }
    }
    return out
  }

  static progress(list: ChecklistItem[]): number {
    if (list.length === 0) {
      return 0
    }
    let done = 0
    for (const it of list) {
      if (it.done) {
        done++
      }
    }
    return done / list.length
  }
}

export class CompareField {
  label: string = ''
  left: string = ''
  right: string = ''
}

export class TagStat {
  tag: string = ''
  count: number = 0
}

export class PlayerStatRow {
  name: string = ''
  mvpCount: number = 0
  perfCount: number = 0
  avgPerf: number = 0
  lastDate: string = ''
}

export class TeamStatRow {
  name: string = ''
  matchCount: number = 0
  avgRating: number = 0
  wins: number = 0
  lastDate: string = ''
}

export class HeatDay {
  dateKey: string = ''
  count: number = 0
}

export class StreakInfo {
  currentWeeks: number = 0
  longestWeeks: number = 0
  activeDays: number = 0
  summary: string = ''
}

export class PredictionRow {
  matchId: string = ''
  title: string = ''
  date: string = ''
  prediction: string = ''
  resultLabel: string = ''
  outcome: string = ''
}

export class PredictionSummary {
  total: number = 0
  hits: number = 0
  misses: number = 0
  unknown: number = 0
  ratePercent: number = 0
  headline: string = ''
}

export class VenueStatRow {
  name: string = ''
  matchCount: number = 0
  avgRating: number = 0
  lastDate: string = ''
}
