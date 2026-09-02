/** 文案点缀 Emoji，禁止当功能图标 */
export class CategoryEmojiUtil {
  static markFor(category: string): string {
    if (category === '工作') {
      return '💼'
    }
    if (category === '生活') {
      return '🌿'
    }
    if (category === '灵感') {
      return '✨'
    }
    if (category === '旅行') {
      return '🧳'
    }
    if (category === '阅读') {
      return '📖'
    }
    if (category === '美食') {
      return '🍜'
    }
    return '🏷'
  }

  static chipLabel(category: string): string {
    return `${CategoryEmojiUtil.markFor(category)} ${category}`
  }
}
