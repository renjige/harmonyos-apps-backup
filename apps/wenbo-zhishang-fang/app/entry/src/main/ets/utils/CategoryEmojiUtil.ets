/** 文案点缀 Emoji，禁止当功能图标 */
export class CategoryEmojiUtil {
  static markFor(category: string): string {
    if (category === '文学') {
      return '📖'
    }
    if (category === '哲学') {
      return '🧭'
    }
    if (category === '商业') {
      return '💼'
    }
    if (category === '科技') {
      return '🔭'
    }
    if (category === '历史') {
      return '🕰'
    }
    if (category === '心理') {
      return '💭'
    }
    return '🏷'
  }

  static chipLabel(category: string): string {
    return `${CategoryEmojiUtil.markFor(category)} ${category}`
  }
}
