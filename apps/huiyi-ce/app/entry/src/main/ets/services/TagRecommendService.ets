/**
 * 规则标签推荐（非大模型）。界面文案使用「智慧推荐」。
 */
export class TagRecommendService {
  static catalog(): string[] {
    return ['工作', '生活', '灵感', '旅行', '阅读', '美食']
  }

  static suggest(content: string): string[] {
    const text = content.toLowerCase()
    const hits: string[] = []
    if (TagRecommendService.matchAny(text, ['会议', '项目', '客户', '加班', '周报', '邮件', '汇报', 'deadline', '工单'])) {
      hits.push('工作')
    }
    if (TagRecommendService.matchAny(text, ['灵感', '想法', '突然', '如果', '创意', '点子'])) {
      hits.push('灵感')
    }
    if (TagRecommendService.matchAny(text, ['旅行', '出行', '机票', '酒店', '景点', '火车', '高铁'])) {
      hits.push('旅行')
    }
    if (TagRecommendService.matchAny(text, ['书', '阅读', '章节', '读完', '笔记'])) {
      hits.push('阅读')
    }
    if (TagRecommendService.matchAny(text, ['餐厅', '味道', '菜', '美食', '咖啡', '晚饭', '午饭'])) {
      hits.push('美食')
    }
    if (TagRecommendService.matchAny(text, ['家', '买', '快递', '水电', '洗衣', '家人', '生活'])) {
      hits.push('生活')
    }
    if (hits.length === 0 && content.trim().length > 0) {
      hits.push('生活')
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
