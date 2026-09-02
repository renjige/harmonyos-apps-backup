export class ThoughtCard {
  id: string = ''
  body: string = ''
  tagsCsv: string = ''
  imagePath: string = ''
  archived: number = 0
  deletedAt: number = 0
  mapX: number = 0
  mapY: number = 0
  createdAt: number = 0
  updatedAt: number = 0
  shelf: string = '想法'

  static createNew(body: string): ThoughtCard {
    const c = new ThoughtCard()
    c.id = `tb_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    c.body = body
    c.shelf = '想法'
    c.createdAt = Date.now()
    c.updatedAt = c.createdAt
    return c
  }

  tags(): string[] {
    if (this.tagsCsv.length === 0) {
      return []
    }
    const out: string[] = []
    const parts = this.tagsCsv.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  primaryTag(): string {
    const list = this.tags()
    if (list.length === 0) {
      return '未分类'
    }
    return list[0]
  }

  preview(): string {
    const plain = this.body.replace(/\n/g, ' ').trim()
    if (plain.length === 0) {
      return '（空白卡片）'
    }
    return plain.length > 72 ? `${plain.substring(0, 72)}…` : plain
  }

  titleLine(): string {
    const first = this.body.split('\n')[0].trim()
    if (first.length === 0) {
      return this.preview()
    }
    return first.length > 24 ? `${first.substring(0, 24)}…` : first
  }

  tagLine(): string {
    const list = this.tags()
    if (list.length === 0) {
      return '未分类'
    }
    return list.join(' · ')
  }
}

export class CatalogItem {
  id: string = ''
  title: string = ''
  body: string = ''
  summary: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  tags: string = ''
  keywords: string = ''
}

export class CatalogListData {
  list: CatalogItem[] = []
}

export class TagStat {
  name: string = ''
  count: number = 0
}

export class MapNode {
  id: string = ''
  title: string = ''
  isGroup: boolean = false
  x: number = 0
  y: number = 0
  cardId: string = ''
}

export class MapGroup {
  tag: string = ''
  cards: ThoughtCard[] = []
}
