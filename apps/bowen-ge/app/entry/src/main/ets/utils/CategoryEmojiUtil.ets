export class CategoryEmojiUtil {
  static markFor(kind: string): string {
    if (kind === 'thought') {
      return '✍️'
    }
    if (kind === 'reading') {
      return '📖'
    }
    if (kind === 'card') {
      return '🗂️'
    }
    if (kind === 'spark') {
      return '✨'
    }
    if (kind === 'theme') {
      return '🏛️'
    }
    if (kind === 'study') {
      return '📚'
    }
    return '·'
  }

  static chipLabel(kind: string, label: string): string {
    return `${CategoryEmojiUtil.markFor(kind)} ${label}`
  }
}
