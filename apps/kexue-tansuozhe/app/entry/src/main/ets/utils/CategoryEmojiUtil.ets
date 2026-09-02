/** 文案 Emoji 点缀（非功能图标） */
export class CategoryEmojiUtil {
  static markFor(category: string): string {
    if (category === 'nature') return '🌿'
    if (category === 'life') return '🏠'
    if (category === 'science') return '🔬'
    if (category === 'culture') return '📜'
    if (category === 'fun') return '✨'
    return '🔍'
  }

  static chipLabel(category: string): string {
    if (category === 'nature') return '🌿 自然'
    if (category === 'life') return '🏠 生活'
    if (category === 'science') return '🔬 科学'
    if (category === 'culture') return '📜 人文'
    if (category === 'fun') return '✨ 趣味'
    if (category === 'all') return '📚 全部'
    return '🔍 探索'
  }

  static labelForKey(key: string): string {
    if (key === 'nature') return '自然'
    if (key === 'life') return '生活'
    if (key === 'science') return '科学'
    if (key === 'culture') return '人文'
    if (key === 'fun') return '趣味'
    return '探索'
  }
}
