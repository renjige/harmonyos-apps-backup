export class CategorySuggest {
  static categories(): string[] {
    return ['食品', '饮料', '日用品', '家居', '数码', '服饰', '其他']
  }

  static suggest(name: string): string {
    const t: string = name.trim()
    if (t.length === 0) {
      return '其他'
    }
    if (CategorySuggest.hasAny(t, ['可乐', '咖啡', '茶', '果汁', '豆浆', '奶茶', '汽水', '矿泉水', '红酒', '啤酒'])) {
      return '饮料'
    }
    if (CategorySuggest.hasAny(t, ['牛奶', '面包', '鸡蛋', '米', '面', '肉', '菜', '水果', '酸奶', '黄油', '豆腐',
      '火腿', '香肠', '饼干', '零食', '巧克力', '糖', '盐', '油', '醋', '酱油', '鸡', '鱼', '虾',
      '牛肉', '猪肉', '苹果', '香蕉', '橙子', '番茄', '土豆', '洋葱'])) {
      return '食品'
    }
    if (CategorySuggest.hasAny(t, ['洗衣液', '纸巾', '牙膏', '牙刷', '洗发水', '沐浴露', '肥皂', '垃圾袋',
      '洗洁精', '卫生纸', '湿巾', '洗手液', '消毒液', '口罩'])) {
      return '日用品'
    }
    if (CategorySuggest.hasAny(t, ['毛巾', '床单', '枕头', '灯泡', '挂钩', '收纳', '衣架', '拖把', '扫把', '垃圾桶'])) {
      return '家居'
    }
    if (CategorySuggest.hasAny(t, ['耳机', '充电', '内存卡', '鼠标', '键盘', '手机壳', '电池'])) {
      return '数码'
    }
    if (CategorySuggest.hasAny(t, ['袜子', '内衣', '鞋子', '衣服', '帽子', '围巾', '手套'])) {
      return '服饰'
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
