/** 文案点缀 Emoji（非功能图标） */
export class CategoryEmojiUtil {
  static forCategory(category: string): string {
    if (category === 'history') {
      return '📜'
    }
    if (category === 'science') {
      return '🔬'
    }
    if (category === 'literature') {
      return '📖'
    }
    if (category === 'art') {
      return '🎨'
    }
    if (category === 'philosophy') {
      return '💭'
    }
    return '✨'
  }

  static tagline(category: string, label: string): string {
    return `${CategoryEmojiUtil.forCategory(category)} ${label}`
  }
}
