export class CategorySuggest {
  static categories(): string[] {
    const out: string[] = []
    out.push('家务安排')
    out.push('家庭采购')
    out.push('维修事项')
    out.push('日常计划')
    return out
  }

  static normalize(category: string): string {
    if (category === '家务' || category === '家务安排') {
      return '家务安排'
    }
    if (category === '采购' || category === '家庭采购') {
      return '家庭采购'
    }
    if (category === '维修' || category === '维修事项') {
      return '维修事项'
    }
    if (category === '家庭' || category === '孩子' || category === '日常计划' || category === '其他') {
      return '日常计划'
    }
    return category.length > 0 ? category : '日常计划'
  }

  static suggest(title: string): string {
    const t = title
    if (CategorySuggest.hasAny(t, ['打扫', '收拾', '洗衣', '垃圾', '整理', '客厅', '厨房', '卫生间', '床', '拖地', '洗碗'])) {
      return '家务安排'
    }
    if (CategorySuggest.hasAny(t, ['买', '牛奶', '菜', '食材', '用品', '超市', '采购'])) {
      return '家庭采购'
    }
    if (CategorySuggest.hasAny(t, ['修', '维修', '换', '滤芯', '空调', '漏水', '师傅'])) {
      return '维修事项'
    }
    return '日常计划'
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
    if (code === '0') {
      return '准时提醒'
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
    const c = CategorySuggest.normalize(category)
    if (c === '家务安排') {
      return 'cat_chore'
    }
    if (c === '家庭采购') {
      return 'cat_shop'
    }
    if (c === '维修事项') {
      return 'cat_family'
    }
    return 'cat_other'
  }
}
