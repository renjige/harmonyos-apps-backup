/**
 * 四象 / 场景 Emoji — 仅用于文案与标签点缀，不替代 AppIcon。
 */
export class CategoryEmojiUtil {
  static markForKind(kind: string): string {
    if (kind === 'mood') {
      return '💭'
    }
    if (kind === 'scene') {
      return '📍'
    }
    if (kind === 'thought') {
      return '✨'
    }
    if (kind === 'environment') {
      return '🌿'
    }
    if (kind === 'all') {
      return '📚'
    }
    return '📝'
  }

  static chipLabel(kind: string, label: string): string {
    return `${CategoryEmojiUtil.markForKind(kind)} ${label}`
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
