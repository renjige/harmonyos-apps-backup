export class CategorySuggest {
  static names(): string[] {
    return ['生活', '科普', '阅读', '工作', '兴趣', '其他']
  }

  static filters(): string[] {
    return ['全部', '生活', '科普', '阅读', '工作', '兴趣', '其他']
  }

  static fromText(title: string, body: string): string {
    const text = `${title} ${body}`
    if (CategorySuggest.hasAny(text, ['雨', '空气', '玻璃', '水珠', '气味', '天气', '日常'])) {
      return '生活'
    }
    if (CategorySuggest.hasAny(text, ['天空', '散射', '光', '分子', '科学', '自然'])) {
      return '科普'
    }
    if (CategorySuggest.hasAny(text, ['阅读', '记忆', '书', '复述', '理解'])) {
      return '阅读'
    }
    if (CategorySuggest.hasAny(text, ['任务', '拆分', '工作', '步骤', '进度'])) {
      return '工作'
    }
    if (CategorySuggest.hasAny(text, ['声音', '兴趣', '舒服', '感受', '爱好'])) {
      return '兴趣'
    }
    return '其他'
  }

  private static hasAny(text: string, keys: string[]): boolean {
    for (const k of keys) {
      if (text.indexOf(k) >= 0) {
        return true
      }
    }
    return false
  }
}

export class KnowledgeTime {
  static todayIso(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static dayOfYear(): number {
    const now = new Date()
    const start = new Date(now.getFullYear(), 0, 0)
    const diff = now.getTime() - start.getTime()
    return Math.floor(diff / 86400000)
  }

  static formatShort(ts: number): string {
    if (ts <= 0) {
      return ''
    }
    const d = new Date(ts)
    const m = d.getMonth() + 1
    const day = d.getDate()
    return `${m}月${day}日`
  }

  static sameDay(ts: number, iso: string): boolean {
    if (ts <= 0) {
      return false
    }
    const d = new Date(ts)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}` === iso
  }
}
