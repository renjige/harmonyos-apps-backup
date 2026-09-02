/** 夏日漫游 — 平台 Wire 与本地模型（ArkTS 严格模式） */

export class RouteNode {
  title: string = ''
  time: string = ''
  note: string = ''
}

export class RouteWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  tags: string[] = []
  duration: string = ''
  difficulty: string = ''
  durationKind: string = ''
  sceneKind: string = ''
  nodesJson: string = ''
  packItems: string[] = []
  createdAt: string = ''
}

export class RouteItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  tags: string[] = []
  duration: string = ''
  difficulty: string = ''
  durationKind: string = ''
  sceneKind: string = ''
  nodes: RouteNode[] = []
  packItems: string[] = []

  static fromWire(w: RouteWire): RouteItem {
    const item = new RouteItem()
    item.id = w.id
    item.title = w.title
    item.subtitle = w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.tags = w.tags ?? []
    item.duration = w.duration ?? ''
    item.difficulty = w.difficulty ?? ''
    item.durationKind = w.durationKind ?? ''
    item.sceneKind = w.sceneKind ?? ''
    item.nodes = RouteItem.parseNodes(w.nodesJson ?? '')
    item.packItems = w.packItems ?? []
    return item
  }

  static parseNodes(raw: string): RouteNode[] {
    const out: RouteNode[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('||')
      let title = ''
      let time = ''
      let note = ''
      let i = 0
      for (const p of parts) {
        if (i === 0) {
          title = p
        } else if (i === 1) {
          time = p
        } else if (i === 2) {
          note = p
        }
        i += 1
      }
      if (title.length > 0) {
        const n = new RouteNode()
        n.title = title
        n.time = time
        n.note = note
        out.push(n)
      }
    }
    return out
  }

  matchesFilter(filter: string): boolean {
    if (filter === 'all' || filter.length === 0) {
      return true
    }
    if (filter === 'halfday') {
      return this.durationKind === 'halfday'
    }
    if (filter === 'day') {
      return this.durationKind === 'day'
    }
    if (filter === 'weekend') {
      return this.durationKind === 'weekend'
    }
    if (filter === 'nature') {
      return this.sceneKind === 'nature'
    }
    if (filter === 'city') {
      return this.sceneKind === 'city'
    }
    return true
  }

  matchesQuery(q: string): boolean {
    if (q.length === 0) {
      return true
    }
    const k = q.toLowerCase()
    if (this.title.toLowerCase().indexOf(k) >= 0) {
      return true
    }
    if (this.summary.toLowerCase().indexOf(k) >= 0) {
      return true
    }
    if (this.subtitle.toLowerCase().indexOf(k) >= 0) {
      return true
    }
    for (const t of this.tags) {
      if (t.toLowerCase().indexOf(k) >= 0) {
        return true
      }
    }
    return false
  }
}

export class RouteListPayload {
  list: RouteWire[] = []
}

export class InspirationWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
}

export class InspirationItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''

  static fromWire(w: InspirationWire): InspirationItem {
    const item = new InspirationItem()
    item.id = w.id
    item.title = w.title
    item.subtitle = w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    if (w.coverKey.length > 0) {
      item.coverKey = w.coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    return item
  }
}

export class InspirationListPayload {
  list: InspirationWire[] = []
}

export class QuoteWire {
  id: string = ''
  title: string = ''
  quoteAuthor: string = ''
}

export class QuoteItem {
  id: string = ''
  text: string = ''
  author: string = ''

  static fromWire(w: QuoteWire): QuoteItem {
    const item = new QuoteItem()
    item.id = w.id
    item.text = w.title
    item.author = w.quoteAuthor ?? '夏日漫游'
    return item
  }
}

export class QuoteListPayload {
  list: QuoteWire[] = []
}

export class JournalItem {
  id: string = ''
  title: string = ''
  place: string = ''
  body: string = ''
  mood: string = ''
  dateLabel: string = ''
  coverKey: string = ''
  photoUri: string = ''
  createdAt: number = 0
}

export class JournalDayGroup {
  label: string = ''
  items: JournalItem[] = []
}

export class CheckItem {
  id: string = ''
  label: string = ''
  done: boolean = false
}

export class FilterChip {
  id: string = ''
  label: string = ''
}

export class MessageItemWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  read: boolean = false
  createdAt: string = ''
}

export class MessageItem {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  createdAt: string = ''

  static fromWire(w: MessageItemWire): MessageItem {
    const item = new MessageItem()
    item.id = w.id
    item.title = w.title
    item.body = w.body ?? ''
    item.type = w.type ?? 'system'
    item.createdAt = w.createdAt ?? ''
    return item
  }
}

export class MessageListPayload {
  list: MessageItemWire[] = []
}

export class CoverOption {
  key: string = ''
  label: string = ''
}
