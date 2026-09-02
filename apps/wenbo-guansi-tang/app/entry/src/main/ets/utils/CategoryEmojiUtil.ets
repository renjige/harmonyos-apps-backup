/**
 * 分类 / 场景 Emoji — 仅用于文案与标签点缀，不替代 AppIcon / SymbolGlyph。
 */
export class CategoryEmojiUtil {
  static markFor(category: string): string {
    if (category === '全部') {
      return '📚'
    }
    if (category === '职场') {
      return '💼'
    }
    if (category === '人生') {
      return '🌱'
    }
    if (category === '阅读') {
      return '📖'
    }
    if (category === '情感') {
      return '💭'
    }
    if (category === '灵感') {
      return '✨'
    }
    if (category === '思辨') {
      return '🔮'
    }
    return '📝'
  }

  static chipLabel(category: string): string {
    if (category.length === 0) {
      return CategoryEmojiUtil.markFor('其他')
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

  static lunarHintWithMark(): string {
    const hints: string[] = [
      '🍃 宜静思 · 忌浮躁',
      '📖 宜读书 · 忌空言',
      '🪞 宜内省 · 忌争锋',
      '🐢 宜慢读 · 忌赶工',
      '💡 宜致良知 · 忌自欺',
      '🌿 宜留白 · 忌填满',
      '🙏 宜感恩 · 忌怨怼',
      '✍️ 宜践行 · 忌空谈',
      '🧭 宜守常 · 忌多变',
      '📜 宜温故 · 忌遗忘'
    ]
    const idx = new Date().getDate() % hints.length
    return hints[idx]
  }
}
