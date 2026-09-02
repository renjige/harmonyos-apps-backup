export class WisdomSortService {
  static suggestTags(text: string): string[] {
    const blob = text.toLowerCase()
    const tags: string[] = []
    if (WisdomSortService.hasAny(blob, ['工作', '项目', '会议', '职场', '客户', '交付'])) {
      tags.push('职场')
    }
    if (WisdomSortService.hasAny(blob, ['学习', '课程', '笔记', '考试', '公式', '概念'])) {
      tags.push('学习')
    }
    if (WisdomSortService.hasAny(blob, ['生活', '家庭', '习惯', '健康', '旅行'])) {
      tags.push('生活')
    }
    if (WisdomSortService.hasAny(blob, ['方法', '原则', '框架', '步骤', '清单'])) {
      tags.push('方法')
    }
    if (tags.length === 0) {
      tags.push('摘录')
    }
    return tags
  }

  private static hasAny(blob: string, keys: string[]): boolean {
    for (const k of keys) {
      if (blob.indexOf(k) >= 0) {
        return true
      }
    }
    return false
  }
}
