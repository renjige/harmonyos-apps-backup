/** 分类文案点缀（仅 Text，不作图标） */

export class CategoryEmojiUtil {
  static chipLabel(category: string): string {
    if (category === 'business') {
      return '🏛 商业'
    }
    if (category === 'humanity') {
      return '📜 人文'
    }
    if (category === 'tech') {
      return '🔭 科技'
    }
    if (category === 'art') {
      return '🎨 艺术'
    }
    if (category === 'life') {
      return '🌿 生活'
    }
    if (category === 'all') {
      return '全部'
    }
    return category
  }
}
