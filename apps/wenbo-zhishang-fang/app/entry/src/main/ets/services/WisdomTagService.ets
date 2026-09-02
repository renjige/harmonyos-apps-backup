/**
 * 规则标签推荐（非大模型）。界面文案使用「智慧分类」。
 */
export class WisdomTagService {
  static catalog(): string[] {
    return ['文学', '哲学', '商业', '科技', '历史', '心理']
  }

  static suggest(bookName: string, excerpt: string): string[] {
    const text = `${bookName} ${excerpt}`.toLowerCase()
    const hits: string[] = []
    if (WisdomTagService.matchAny(text, ['诗', '小说', '散文', '文学', '故事', '鲁迅', '村上', '余华', '诗集', '戏剧'])) {
      hits.push('文学')
    }
    if (WisdomTagService.matchAny(text, ['哲学', '存在', '康德', '尼采', '庄子', '老子', '伦理', '形而上学', '思辨'])) {
      hits.push('哲学')
    }
    if (WisdomTagService.matchAny(text, ['商业', '管理', '营销', '创业', '战略', '投资', '客户', '增长', '品牌', '组织'])) {
      hits.push('商业')
    }
    if (WisdomTagService.matchAny(text, ['科技', '算法', '编程', '芯片', '互联网', '人工智能', '智能', '数据', '工程', '网络'])) {
      hits.push('科技')
    }
    if (WisdomTagService.matchAny(text, ['历史', '朝代', '战争', '文明', '考古', '帝国', '传记', '年代'])) {
      hits.push('历史')
    }
    if (WisdomTagService.matchAny(text, ['心理', '情绪', '认知', '人格', '潜意识', '焦虑', '幸福', '动机'])) {
      hits.push('心理')
    }
    if (hits.length === 0 && (bookName.trim().length > 0 || excerpt.trim().length > 0)) {
      hits.push('文学')
    }
    const unique: string[] = []
    for (const h of hits) {
      let seen = false
      for (const u of unique) {
        if (u === h) {
          seen = true
        }
      }
      if (!seen) {
        unique.push(h)
      }
      if (unique.length >= 3) {
        break
      }
    }
    return unique
  }

  private static matchAny(text: string, keys: string[]): boolean {
    for (const k of keys) {
      if (text.indexOf(k) >= 0) {
        return true
      }
    }
    return false
  }
}
