/**
 * 分类文案 Emoji — 仅用于标签点缀，不替代 AppIcon。
 */
export class CategoryEmojiUtil {
  static markFor(category: string): string {
    if (category === '全部') {
      return '📚'
    }
    if (category === '人生哲思') {
      return '🌱'
    }
    if (category === '文学之美') {
      return '📖'
    }
    if (category === '处世智慧') {
      return '⚖️'
    }
    if (category === '情感共鸣') {
      return '💭'
    }
    if (category === '励志前行') {
      return '🔥'
    }
    if (category === '古典雅韵') {
      return '📜'
    }
    return '✨'
  }

  static chipLabel(category: string): string {
    if (category.length === 0) {
      return `${CategoryEmojiUtil.markFor('全部')} 全部`
    }
    return `${CategoryEmojiUtil.markFor(category)} ${category}`
  }

  static weekdayMark(): string {
    const d = new Date().getDay()
    if (d === 0 || d === 6) {
      return '🌤'
    }
    if (d === 1) {
      return '🌅'
    }
    if (d === 5) {
      return '🌙'
    }
    return '☕'
  }
}
