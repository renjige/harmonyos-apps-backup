export class CategorySuggest {
  static categories(): string[] {
    return ['家庭生活', '采购', '家务', '节日', '健康提醒', '其他']
  }

  static suggest(name: string): string {
    const t: string = name.trim()
    if (t.length === 0) {
      return '其他'
    }
    if (CategorySuggest.hasAny(t, ['春节', '中秋', '端午', '生日', '聚会', '礼物', '装饰', '红包', '年夜饭'])) {
      return '节日'
    }
    if (CategorySuggest.hasAny(t, ['体检', '复查', '吃药', '疫苗', '挂号', '睡眠', '运动', '血压', '血糖', '牙医'])) {
      return '健康提醒'
    }
    if (CategorySuggest.hasAny(t, ['打扫', '清洁', '拖地', '洗衣', '洗碗', '整理', '收纳', '擦', '换床品', '倒垃圾'])) {
      return '家务'
    }
    if (CategorySuggest.hasAny(t, ['买', '采购', '纸巾', '牛奶', '面包', '米', '油', '盐', '酱油', '超市', '补货'])) {
      return '采购'
    }
    if (CategorySuggest.hasAny(t, ['孩子', '父母', '家人', '亲子', '接送', '学校', '缴费', '账单', '缴费', '会议', '计划'])) {
      return '家庭生活'
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
}
