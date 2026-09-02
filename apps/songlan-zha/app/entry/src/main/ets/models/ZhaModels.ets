export class ZhaQuoteItem {
  id: string = ''
  text: string = ''
  author: string = ''

  static create(id: string, text: string, author: string): ZhaQuoteItem {
    const q = new ZhaQuoteItem()
    q.id = id
    q.text = text
    q.author = author
    return q
  }
}

export class ZhaNoteItem {
  id: string = ''
  title: string = ''
  body: string = ''
  tags: string[] = []
  createdAt: number = 0
  updatedAt: number = 0

  static create(id: string, title: string, body: string): ZhaNoteItem {
    const n = new ZhaNoteItem()
    n.id = id
    n.title = title
    n.body = body
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
}

export class ZhaTodoItem {
  id: string = ''
  content: string = ''
  priority: string = 'medium'
  done: boolean = false
  dueDate: string = ''
  createdAt: number = 0
  completedAt: number = 0

  static create(id: string, content: string, priority: string, dueDate: string): ZhaTodoItem {
    const t = new ZhaTodoItem()
    t.id = id
    t.content = content
    t.priority = priority
    t.dueDate = dueDate
    t.createdAt = Date.now()
    return t
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
}

export class ZhaJournalEntry {
  dateKey: string = ''
  mood: string = ''
  content: string = ''
  updatedAt: number = 0

  static create(dateKey: string, mood: string, content: string): ZhaJournalEntry {
    const j = new ZhaJournalEntry()
    j.dateKey = dateKey
    j.mood = mood
    j.content = content
    j.updatedAt = Date.now()
    return j
  }
}

export class ZhaAppStats {
  noteCount: number = 0
  todoActive: number = 0
  todoDone: number = 0
  journalDays: number = 0
}

export class ZhaQuoteConstants {
  static quotes(): ZhaQuoteItem[] {
    const list: ZhaQuoteItem[] = []
    list.push(ZhaQuoteItem.create('q01', '行到水穷处，坐看云起时。', '王维'))
    list.push(ZhaQuoteItem.create('q02', '一花一世界，一叶一菩提。', '佛偈'))
    list.push(ZhaQuoteItem.create('q03', '知止而后有定，定而后能静。', '大学'))
    list.push(ZhaQuoteItem.create('q04', '慢即是快，少即是多。', '松岚札'))
    list.push(ZhaQuoteItem.create('q05', '今日事，今日毕；明日事，今日计。', '松岚札'))
    list.push(ZhaQuoteItem.create('q06', '心若无尘，清风自来。', '禅语'))
    list.push(ZhaQuoteItem.create('q07', '记录本身，就是一种思考。', '松岚札'))
    list.push(ZhaQuoteItem.create('q08', '松风过耳，不留痕迹；札记在心，自有回响。', '松岚札'))
    list.push(ZhaQuoteItem.create('q09', '静以修身，俭以养德。', '诸葛亮'))
    list.push(ZhaQuoteItem.create('q10', '把灵感留给纸面，把从容留给自己。', '松岚札'))
    list.push(ZhaQuoteItem.create('q11', '山不在高，有仙则名；水不在深，有龙则灵。', '刘禹锡'))
    list.push(ZhaQuoteItem.create('q12', '每写一字，皆是与昨日的自己对话。', '松岚札'))
    return list
  }
}
