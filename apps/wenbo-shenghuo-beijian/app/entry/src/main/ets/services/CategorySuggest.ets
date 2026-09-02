/** 智慧整理：标题关键词 → 建议分类（规则，非生成式） */

export class CategorySuggest {
  static suggest(title: string): string {
    const t = title
    if (CategorySuggest.hasAny(t, ['买', '超市', '洗衣液', '牛奶', '菜', '购物', '下单'])) {
      return '购物'
    }
    if (CategorySuggest.hasAny(t, ['出差', '火车', '机票', '出行', '出发', '行李', '车站'])) {
      return '出行'
    }
    if (CategorySuggest.hasAny(t, ['妈妈', '爸爸', '家人', '孩子', '家里', '电话'])) {
      return '家庭'
    }
    if (CategorySuggest.hasAny(t, ['会议', '周报', '客户', '邮件', '工作', '汇报'])) {
      return '工作'
    }
    if (CategorySuggest.hasAny(t, ['学习', '看书', '课程', '练习', '复习'])) {
      return '学习'
    }
    if (CategorySuggest.hasAny(t, ['整理', '打扫', '书桌', '洗衣', '做饭'])) {
      return '生活'
    }
    return ''
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
