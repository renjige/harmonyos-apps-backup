/** 文案点缀 Emoji，禁止当功能图标 */
export class CategoryEmojiUtil {
  static markFor(category: string): string {
    if (category === '阅读' || category === 'digest') {
      return '📖'
    }
    if (category === '笔记' || category === 'note') {
      return '✍️'
    }
    if (category === '卡片' || category === 'card') {
      return '🗂️'
    }
    if (category === '计划' || category === 'plan') {
      return '🎯'
    }
    if (category === '习惯' || category === 'habit') {
      return '🔥'
    }
    if (category === '日志' || category === 'log') {
      return '🌙'
    }
    if (category === '方法') {
      return '🧭'
    }
    if (category === '职场') {
      return '💼'
    }
    return '🏷'
  }

  static chipLabel(category: string): string {
    return `${CategoryEmojiUtil.markFor(category)} ${category}`
  }
}
