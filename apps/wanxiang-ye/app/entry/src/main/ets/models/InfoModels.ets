export class InfoCategory {
  key: string = ''
  label: string = ''
  emoji: string = ''

  constructor(key: string, label: string, emoji: string) {
    this.key = key
    this.label = label
    this.emoji = emoji
  }

  static all(): InfoCategory[] {
    return [
      new InfoCategory('recommend', '推荐', '✦'),
      new InfoCategory('tech', '科技', '⚡'),
      new InfoCategory('life', '生活', '☀'),
      new InfoCategory('culture', '文化', '⌁')
    ]
  }

  static labelOf(key: string): string {
    for (const c of InfoCategory.all()) {
      if (c.key === key) {
        return c.label
      }
    }
    return '资讯'
  }

  static emojiOf(key: string): string {
    for (const c of InfoCategory.all()) {
      if (c.key === key) {
        return c.emoji
      }
    }
    return '·'
  }
}

export class InfoItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  source: string = ''
  category: string = 'recommend'
  coverKey: string = 'hero_bg'
  publishedAt: string = ''
  readMinutes: number = 3

  static create(
    id: string,
    title: string,
    summary: string,
    body: string,
    source: string,
    category: string,
    coverKey: string,
    publishedAt: string,
    readMinutes: number
  ): InfoItem {
    const item = new InfoItem()
    item.id = id
    item.title = title
    item.summary = summary
    item.body = body
    item.source = source
    item.category = category
    item.coverKey = coverKey
    item.publishedAt = publishedAt
    item.readMinutes = readMinutes
    return item
  }
}

export class BannerSlide {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  coverKey: string = 'hero_bg'
  targetId: string = ''

  static create(id: string, title: string, subtitle: string, coverKey: string, targetId: string): BannerSlide {
    const b = new BannerSlide()
    b.id = id
    b.title = title
    b.subtitle = subtitle
    b.coverKey = coverKey
    b.targetId = targetId
    return b
  }
}

export class TopicCollection {
  id: string = ''
  title: string = ''
  description: string = ''
  emoji: string = ''
  coverKey: string = 'hero_bg'
  itemIds: string[] = []

  static create(
    id: string,
    title: string,
    description: string,
    emoji: string,
    coverKey: string,
    itemIds: string[]
  ): TopicCollection {
    const topic = new TopicCollection()
    topic.id = id
    topic.title = title
    topic.description = description
    topic.emoji = emoji
    topic.coverKey = coverKey
    topic.itemIds = itemIds
    return topic
  }
}
