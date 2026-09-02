import { InspirationItem } from '../models/InspirationModels'
import { ContentSync } from './ContentSync'

/**
 * 收藏实时刷新：详情/收藏页增删后 bump epoch，首页 @StorageLink 立即重拉。
 * source 编码进 content：[[src:featured:id]] 正文，便于取消收藏时精确匹配。
 */
export class FavoriteSync {
  static bump(): void {
    const n = AppStorage.get<number>('favoriteEpoch')
    const next = n !== undefined && n !== null ? n + 1 : 1
    AppStorage.setOrCreate('favoriteEpoch', next)
    ContentSync.bump()
  }

  static sourceKey(kind: string, id: string): string {
    return `${kind}:${id}`
  }

  static encodeContent(sourceKey: string, content: string): string {
    return `[[src:${sourceKey}]]${content}`
  }

  static parseSourceKey(content: string): string {
    if (!content.startsWith('[[src:')) {
      return ''
    }
    const end = content.indexOf(']]')
    if (end < 0) {
      return ''
    }
    return content.substring(6, end)
  }

  static displayContent(content: string): string {
    if (!content.startsWith('[[src:')) {
      return content
    }
    const end = content.indexOf(']]')
    if (end < 0) {
      return content
    }
    return content.substring(end + 2)
  }

  static findMatch(
    list: InspirationItem[],
    kind: string,
    id: string,
    title: string
  ): InspirationItem | undefined {
    const key = FavoriteSync.sourceKey(kind, id)
    for (const it of list) {
      if (FavoriteSync.parseSourceKey(it.content) === key) {
        return it
      }
    }
    for (const it of list) {
      if (it.title === title && FavoriteSync.parseSourceKey(it.content).length === 0) {
        return it
      }
    }
    return undefined
  }
}
