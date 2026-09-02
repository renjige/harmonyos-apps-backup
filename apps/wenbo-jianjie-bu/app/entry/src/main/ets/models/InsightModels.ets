export class InsightEntry {
  id: string = ''
  title: string = ''
  body: string = ''
  imagePath: string = ''
  notebookId: string = ''
  tags: string = ''
  dateKey: string = ''
  createdAt: number = 0
  updatedAt: number = 0
  starred: boolean = false
  pinned: boolean = false
  frameKind: string = ''
  reviewNote: string = ''
  verdict: string = ''

  static createNew(dateKey: string): InsightEntry {
    const e = new InsightEntry()
    const now = Date.now()
    e.id = `ie_${now}`
    e.dateKey = dateKey
    e.createdAt = now
    e.updatedAt = now
    return e
  }

  tagList(): string[] {
    const out: string[] = []
    if (this.tags.length === 0) {
      return out
    }
    const parts = this.tags.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  summaryLine(): string {
    const raw = this.body.replace(/[#*_]/g, '').trim()
    if (raw.length <= 72) {
      return raw
    }
    return raw.substring(0, 72) + '…'
  }
}

export class InsightNotebook {
  id: string = ''
  name: string = ''
  createdAt: number = 0

  static make(id: string, name: string): InsightNotebook {
    const n = new InsightNotebook()
    n.id = id
    n.name = name
    n.createdAt = Date.now()
    return n
  }
}

export class InsightTagCount {
  name: string = ''
  count: number = 0
}

export class DayGroup {
  dateKey: string = ''
  items: InsightEntry[] = []
}

export class MonthGroup {
  monthKey: string = ''
  label: string = ''
  count: number = 0
}

export class KeywordItem {
  word: string = ''
  count: number = 0
  weight: number = 1
}

export class TimelineRow {
  rowId: string = ''
  isHeader: boolean = false
  dateKey: string = ''
  entry: InsightEntry = new InsightEntry()
}

export class UserProfile {
  nickname: string = '思考者'
  themeMode: string = 'system'
}

export class HeatDay {
  dateKey: string = ''
  count: number = 0
  label: string = ''
}

export class FrameTemplate {
  id: string = ''
  name: string = ''
  body: string = ''

  static all(): FrameTemplate[] {
    const list: FrameTemplate[] = []
    list.push(FrameTemplate.make('flash', '闪念', '此刻：\n'))
    list.push(FrameTemplate.make('judge', '判断', '现象：\n判断：\n所以呢：\n'))
    list.push(FrameTemplate.make('review', '复盘', '发生了什么：\n当时怎么想：\n现在怎么看：\n下次怎么做：\n'))
    list.push(FrameTemplate.make('quote', '金句', '原文：\n我的理解：\n'))
    return list
  }

  static make(id: string, name: string, body: string): FrameTemplate {
    const t = new FrameTemplate()
    t.id = id
    t.name = name
    t.body = body
    return t
  }
}

export class VerdictGuard {
  static pending(): string {
    return 'pending'
  }

  static label(v: string): string {
    if (v === 'hit') {
      return '应验'
    }
    if (v === 'miss') {
      return '落空'
    }
    if (v === 'revised') {
      return '已修正'
    }
    if (v === 'pending') {
      return '待验证'
    }
    return '未入账'
  }

  static codes(): string[] {
    const list: string[] = []
    list.push('pending')
    list.push('hit')
    list.push('miss')
    list.push('revised')
    return list
  }
}

export class TitleGuard {
  static isValid(title: string): boolean {
    const s = title.trim()
    if (s.length === 0 || s.length > 40) {
      return false
    }
    for (let i = 0; i < s.length; i++) {
      const code = s.charCodeAt(i)
      const isSpace = code === 32
      const isDigit = code >= 48 && code <= 57
      const isUpper = code >= 65 && code <= 90
      const isLower = code >= 97 && code <= 122
      const isCjk = code >= 0x4E00 && code <= 0x9FFF
      if (!(isSpace || isDigit || isUpper || isLower || isCjk)) {
        return false
      }
    }
    return true
  }
}
