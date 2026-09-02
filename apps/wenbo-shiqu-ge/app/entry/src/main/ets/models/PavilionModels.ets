/** 识趣阁数据模型（ArkTS 严格模式） */
import { JsonChunks } from '../services/JsonChunks'

export class ArticleWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  category: string = ''
  kind: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  publishDate: string = ''
  tags: string = ''
  readMinutes: number = 2
}

export class ArticleListPayload {
  list: ArticleWire[] = []
}

export class DailyWire {
  id: string = ''
  title: string = ''
  quote: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  dateKey: string = ''
  coverKey: string = ''
  coverMedia: string = ''
}

export class DailyListPayload {
  list: DailyWire[] = []
}

export class CollectionItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  coverKey: string = 'hero_bg'
  articleIds: string = ''
  category: string = ''
}

export class ArticleItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  category: string = 'life'
  kind: string = 'card'
  coverKey: string = 'cover_life_01'
  publishDate: string = ''
  tags: string = ''
  readMinutes: number = 2

  categoryLabel(): string {
    return ArticleItem.labelOf(this.category)
  }

  static labelOf(category: string): string {
    if (category === 'fun') {
      return '趣味知识'
    }
    if (category === 'history') {
      return '历史文化'
    }
    if (category === 'science') {
      return '科普百科'
    }
    if (category === 'nature') {
      return '自然探索'
    }
    if (category === 'art') {
      return '艺术欣赏'
    }
    if (category === 'career') {
      return '职场识趣'
    }
    return '生活技巧'
  }

  kindLabel(): string {
    if (this.kind === 'list') {
      return '知识清单'
    }
    if (this.kind === 'story') {
      return '趣闻故事'
    }
    if (this.kind === 'quote') {
      return '每日语录'
    }
    return '图文卡片'
  }

  tagList(): string[] {
    if (this.tags.length === 0) {
      return []
    }
    return this.tags.split(',')
  }

  static fromChunk(chunk: string): ArticleItem {
    const item = new ArticleItem()
    item.id = JsonChunks.str(chunk, 'id')
    item.title = JsonChunks.str(chunk, 'title')
    const summary = JsonChunks.str(chunk, 'summary')
    const description = JsonChunks.str(chunk, 'description')
    item.summary = summary.length > 0 ? summary : description
    const body = JsonChunks.str(chunk, 'body')
    item.body = body.length > 0 ? body : description
    const cat = JsonChunks.str(chunk, 'category')
    item.category = cat.length > 0 ? cat : 'life'
    const kind = JsonChunks.str(chunk, 'kind')
    item.kind = kind.length > 0 ? kind : 'card'
    const media = JsonChunks.str(chunk, 'coverMedia')
    const key = JsonChunks.str(chunk, 'coverKey')
    if (media.length > 0) {
      item.coverKey = media
    } else if (key.length > 0) {
      item.coverKey = key
    }
    item.publishDate = JsonChunks.str(chunk, 'publishDate')
    item.tags = JsonChunks.str(chunk, 'tags')
    item.readMinutes = JsonChunks.num(chunk, 'readMinutes', 2)
    return item
  }
}

export class DailyItem {
  id: string = ''
  title: string = ''
  quote: string = ''
  body: string = ''
  dateKey: string = ''
  coverKey: string = 'cover_daily_01'

  static fromChunk(chunk: string): DailyItem {
    const item = new DailyItem()
    item.id = JsonChunks.str(chunk, 'id')
    item.title = JsonChunks.str(chunk, 'title')
    const quote = JsonChunks.str(chunk, 'quote')
    const summary = JsonChunks.str(chunk, 'summary')
    item.quote = quote.length > 0 ? quote : summary
    const body = JsonChunks.str(chunk, 'body')
    const description = JsonChunks.str(chunk, 'description')
    item.body = body.length > 0 ? body : description
    item.dateKey = JsonChunks.str(chunk, 'dateKey')
    const media = JsonChunks.str(chunk, 'coverMedia')
    const key = JsonChunks.str(chunk, 'coverKey')
    if (media.length > 0) {
      item.coverKey = media
    } else if (key.length > 0) {
      item.coverKey = key
    }
    return item
  }
}

export class MsgWire {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = ''
  createdAt: string = ''
}

export class MsgListPayload {
  list: MsgWire[] = []
}

export class PavilionStats {
  favorites: number = 0
  reads: number = 0
  notes: number = 0
  cards: number = 0
  days: number = 0
  logs: number = 0
  finds: number = 0
  wishes: number = 0
  tasks: number = 0
}

export class PavilionTime {
  static todayKey(): string {
    const d = new Date()
    return PavilionTime.format(d)
  }

  static format(d: Date): string {
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }
}
