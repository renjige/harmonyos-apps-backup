import { BannerSlide, InfoItem, TopicCollection } from '../models/InfoModels'
import { InfoSeedData } from './InfoSeedData'

/**
 * 本地模拟信息库（可扩展为网络 API）。
 */
export class InfoRepository {
  private static seeded: InfoItem[] = InfoSeedData.build()

  static allItems(): InfoItem[] {
    return InfoRepository.seeded
  }

  static totalCount(): number {
    return InfoRepository.seeded.length
  }

  static findById(id: string): InfoItem | undefined {
    for (const item of InfoRepository.seeded) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static filterByCategory(category: string): InfoItem[] {
    if (category === 'recommend') {
      return InfoRepository.seeded
    }
    const out: InfoItem[] = []
    for (const item of InfoRepository.seeded) {
      if (item.category === category) {
        out.push(item)
      }
    }
    return out
  }

  static featuredHorizontal(category: string): InfoItem[] {
    const list = InfoRepository.filterByCategory(category)
    const out: InfoItem[] = []
    let count = 0
    for (const item of list) {
      if (count > 0 && count <= 6) {
        out.push(item)
      }
      count++
      if (out.length >= 6) {
        break
      }
    }
    return out
  }

  static gridItems(category: string): InfoItem[] {
    const list = InfoRepository.filterByCategory(category)
    if (list.length <= 1) {
      return list
    }
    return list.slice(1)
  }

  static leadItem(category: string): InfoItem | undefined {
    const list = InfoRepository.filterByCategory(category)
    return list.length > 0 ? list[0] : undefined
  }

  static bannerSlides(): BannerSlide[] {
    return [
      BannerSlide.create('bn_1', '一页尽览今日万象', '30 篇精选 · 智慧摘要', 'hero_bg', 'info_008'),
      BannerSlide.create('bn_2', '科技前沿速递', '鸿蒙 · 合规 · 产业', 'banner_tech', 'info_001'),
      BannerSlide.create('bn_3', '生活灵感手册', '健康 · 效率 · 城市', 'banner_life', 'info_003'),
      BannerSlide.create('bn_4', '文化深度专题', '博物馆 · 非遗 · 美学', 'cover_culture_01', 'info_004'),
      BannerSlide.create('bn_5', '编辑本周必读', '收藏建立你的阅读队列', 'cover_recommend_01', 'info_019')
    ]
  }

  static hotTopics(): string[] {
    return [
      '鸿蒙', '科技', '生活', '文化', '博物馆', '阅读',
      '效率', '健康', '上架', 'IPv6', '深色模式', 'city walk'
    ]
  }

  static editorPicks(): InfoItem[] {
    return InfoRepository.itemsByIds(['info_019', 'info_011', 'info_008', 'info_004', 'info_016'])
  }

  static itemsByIds(ids: string[]): InfoItem[] {
    const out: InfoItem[] = []
    for (const id of ids) {
      const item = InfoRepository.findById(id)
      if (item !== undefined) {
        out.push(item)
      }
    }
    return out
  }

  static topicCollections(): TopicCollection[] {
    return [
      TopicCollection.create(
        'topic_tech',
        '科技前沿周报',
        '鸿蒙生态 · 合规上架 · 端侧安全',
        '⚡',
        'banner_tech',
        ['info_001', 'info_009', 'info_020', 'info_027', 'info_028']
      ),
      TopicCollection.create(
        'topic_life',
        '生活灵感手册',
        '效率 · 健康 · 城市探索',
        '☀',
        'banner_life',
        ['info_003', 'info_014', 'info_015', 'info_022', 'info_024']
      ),
      TopicCollection.create(
        'topic_culture',
        '文化深度专题',
        '博物馆 · 非遗 · 阅读现场',
        '⌁',
        'cover_culture_01',
        ['info_004', 'info_010', 'info_018', 'info_025', 'info_029']
      ),
      TopicCollection.create(
        'topic_reading',
        '信息素养课',
        '筛选可信资讯 · 建立阅读节奏',
        '✦',
        'cover_recommend_01',
        ['info_002', 'info_011', 'info_019', 'info_026', 'info_030']
      )
    ]
  }

  static topicItems(topicId: string): InfoItem[] {
    for (const topic of InfoRepository.topicCollections()) {
      if (topic.id === topicId) {
        return InfoRepository.itemsByIds(topic.itemIds)
      }
    }
    return []
  }

  static findTopic(topicId: string): TopicCollection | undefined {
    for (const topic of InfoRepository.topicCollections()) {
      if (topic.id === topicId) {
        return topic
      }
    }
    return undefined
  }

  static relatedItems(id: string, limit: number): InfoItem[] {
    const current = InfoRepository.findById(id)
    if (current === undefined) {
      return []
    }
    const out: InfoItem[] = []
    for (const item of InfoRepository.seeded) {
      if (item.id !== id && item.category === current.category) {
        out.push(item)
      }
      if (out.length >= limit) {
        break
      }
    }
    return out
  }

  static search(keyword: string): InfoItem[] {
    const q = keyword.trim().toLowerCase()
    if (q.length === 0) {
      return []
    }
    const out: InfoItem[] = []
    for (const item of InfoRepository.seeded) {
      const hay = `${item.title}${item.summary}${item.body}${item.source}`.toLowerCase()
      if (hay.indexOf(q) >= 0) {
        out.push(item)
      }
    }
    return out
  }

  static suggest(keyword: string): string[] {
    const q = keyword.trim().toLowerCase()
    if (q.length === 0) {
      return []
    }
    const set: string[] = []
    for (const item of InfoRepository.seeded) {
      if (item.title.toLowerCase().indexOf(q) >= 0 && set.indexOf(item.title) < 0) {
        set.push(item.title)
      }
      if (set.length >= 6) {
        break
      }
    }
    return set
  }

  /** 模拟网络延迟，便于展示骨架屏 */
  static loadWithDelay(onDone: () => void): void {
    setTimeout((): void => {
      onDone()
    }, 480)
  }
}
