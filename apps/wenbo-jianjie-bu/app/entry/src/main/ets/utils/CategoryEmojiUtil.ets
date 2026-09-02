export class CategoryEmojiUtil {
  static markForNotebook(id: string): string {
    if (id === 'nb_work') {
      return '💼'
    }
    if (id === 'nb_read') {
      return '📖'
    }
    if (id === 'nb_life') {
      return '🌿'
    }
    return '✨'
  }

  static chipLabel(tag: string): string {
    return `🏷 ${tag}`
  }
}
