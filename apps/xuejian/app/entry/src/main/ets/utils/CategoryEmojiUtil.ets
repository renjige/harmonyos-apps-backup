/** 文案点缀 Emoji，禁止当功能图标 */
export class CategoryEmojiUtil {
  static markFor(category: string): string {
    if (category === '数学') {
      return '📐'
    }
    if (category === '英语') {
      return '🔤'
    }
    if (category === '编程') {
      return '💻'
    }
    if (category === '职场') {
      return '💼'
    }
    if (category === '方法') {
      return '⏱'
    }
    if (category === '锦囊') {
      return '💡'
    }
    return '🏷'
  }

  static chipLabel(category: string): string {
    return `${CategoryEmojiUtil.markFor(category)} ${category}`
  }
}
