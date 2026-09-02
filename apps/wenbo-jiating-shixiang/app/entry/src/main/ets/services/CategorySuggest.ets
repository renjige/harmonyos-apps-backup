export class CategorySuggest {
  static categories(): string[] {
    const out: string[] = []
    out.push('家务')
    out.push('采购')
    out.push('家庭')
    out.push('孩子')
    out.push('其他')
    return out
  }

  static suggest(title: string): string {
    const t = title
    if (CategorySuggest.hasAny(t, ['打扫', '收拾', '洗衣', '垃圾', '整理', '客厅', '厨房', '卫生间', '床', '拖地'])) {
      return '家务'
    }
    if (CategorySuggest.hasAny(t, ['买', '牛奶', '菜', '食材', '用品', '超市', '采购'])) {
      return '采购'
    }
    if (CategorySuggest.hasAny(t, ['接', '送', '孩子', '学校', '书包', '亲子'])) {
      return '孩子'
    }
    if (CategorySuggest.hasAny(t, ['晚餐', '聚会', '周末', '账单', '缴费', '家庭'])) {
      return '家庭'
    }
    return '其他'
  }

  private static hasAny(title: string, keys: string[]): boolean {
    for (const k of keys) {
      if (title.indexOf(k) >= 0) {
        return true
      }
    }
    return false
  }

  static reminderLabel(code: string): string {
    if (code === '10') {
      return '提前 10 分钟'
    }
    if (code === '30') {
      return '提前 30 分钟'
    }
    if (code === '60') {
      return '提前 1 小时'
    }
    return '不提醒'
  }

  static repeatLabel(code: string): string {
    if (code === 'daily') {
      return '每天'
    }
    if (code === 'weekly') {
      return '每周'
    }
    if (code === 'monthly') {
      return '每月'
    }
    return '不重复'
  }

  static coverKey(category: string): string {
    if (category === '家务') {
      return 'cat_chore'
    }
    if (category === '采购') {
      return 'cat_shop'
    }
    if (category === '家庭') {
      return 'cat_family'
    }
    if (category === '孩子') {
      return 'cat_kids'
    }
    return 'cat_other'
  }
}
