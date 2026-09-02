export class SportPlan {
  id: string = ''
  title: string = ''
  kind: string = 'weekly'
  target: number = 3
  createdAt: number = 0

  static make(title: string, kind: string, target: number): SportPlan {
    const p = new SportPlan()
    p.id = `p_${Date.now()}`
    p.title = title
    p.kind = kind
    p.target = target
    p.createdAt = Date.now()
    return p
  }

  kindLabel(): string {
    if (this.kind === 'weekly') {
      return '每周次数'
    }
    if (this.kind === 'month') {
      return '每月次数'
    }
    return '连续天数'
  }
}

export class SportChallenge {
  id: string = ''
  title: string = ''
  kind: string = 'd7'
  started: string = ''
  done: number = 0

  static preset(id: string, title: string, kind: string): SportChallenge {
    const c = new SportChallenge()
    c.id = id
    c.title = title
    c.kind = kind
    return c
  }

  isStarted(): boolean {
    return this.started.length > 0
  }
}

export class PrepList {
  id: string = ''
  title: string = ''
  items: string = ''
  checks: string = ''

  itemArr(): string[] {
    if (this.items.length === 0) {
      return []
    }
    return this.items.split('|')
  }

  isChecked(index: number): boolean {
    const parts = this.checks.split(',')
    if (index < 0 || index >= parts.length) {
      return false
    }
    return parts[index] === '1'
  }

  isItemChecked(item: string): boolean {
    const items = this.itemArr()
    for (let i = 0; i < items.length; i++) {
      if (items[i] === item) {
        return this.isChecked(i)
      }
    }
    return false
  }

  static cloneOne(src: PrepList): PrepList {
    const l = new PrepList()
    l.id = src.id
    l.title = src.title
    l.items = src.items
    l.checks = src.checks
    return l
  }

  static cloneAll(src: PrepList[]): PrepList[] {
    const out: PrepList[] = []
    for (const s of src) {
      out.push(PrepList.cloneOne(s))
    }
    return out
  }
}

export class TipNote {
  id: string = ''
  title: string = ''
  body: string = ''
}

export class BodyLog {
  dateKey: string = ''
  energy: string = ''
  feeling: string = ''
  recovery: string = ''
}
