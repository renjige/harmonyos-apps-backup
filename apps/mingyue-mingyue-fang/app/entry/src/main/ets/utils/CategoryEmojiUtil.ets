/**
 * 分类 / 场景 Emoji — 仅用于文案与标签点缀，不替代 AppIcon / SymbolGlyph。
 */
export class CategoryEmojiUtil {
  static markFor(category: string): string {
    if (category === '全部') {
      return '📚'
    }
    if (category === '正在阅读' || category === 'reading') {
      return '📖'
    }
    if (category === '已读完' || category === 'finished') {
      return '✅'
    }
    if (category === '收藏精选' || category === 'starred') {
      return '⭐'
    }
    if (category === '文学') {
      return '📜'
    }
    if (category === '哲学') {
      return '🧭'
    }
    if (category === '摘抄') {
      return '✂️'
    }
    if (category === '明悟') {
      return '💡'
    }
    if (category === '灵感') {
      return '✨'
    }
    if (category === '情感') {
      return '💭'
    }
    return '📝'
  }

  static chipLabel(category: string): string {
    if (category.length === 0) {
      return CategoryEmojiUtil.markFor('其他')
    }
    return `${CategoryEmojiUtil.markFor(category)} ${category}`
  }

  static filterLabel(key: string, label: string): string {
    return `${CategoryEmojiUtil.markFor(label.length > 0 ? label : key)} ${label}`
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

  static dailyHint(): string {
    const hints: string[] = [
      '🍃 宜静读 · 忌浮躁',
      '📖 宜深读 · 忌浅尝',
      '🪞 宜内省 · 忌空言',
      '🐢 宜慢品 · 忌赶工',
      '💡 宜明悟 · 忌死记',
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
