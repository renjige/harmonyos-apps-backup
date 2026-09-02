import { ShoppingTemplate, TemplateItemSeed } from '../models/ShoppingModels'

export class ShoppingCatalog {
  static listKinds(): string[] {
    return ['日常采购', '生鲜食品', '家庭用品', '旅行用品', '儿童用品']
  }

  static itemTags(): string[] {
    return ['必买', '待确认', '常用', '季节用品']
  }

  static sortModes(): string[] {
    return ['分类', '时间', '状态']
  }

  static coverOfKind(kind: string): string {
    if (kind === '生鲜食品') {
      return 'tpl_breakfast'
    }
    if (kind === '家庭用品') {
      return 'tpl_family'
    }
    if (kind === '旅行用品') {
      return 'tpl_travel'
    }
    if (kind === '儿童用品') {
      return 'memo_hero'
    }
    return 'tpl_daily'
  }

  static builtinTemplates(): ShoppingTemplate[] {
    const out: ShoppingTemplate[] = []
    out.push(ShoppingCatalog.make('tpl_market', '超市采购清单', '日常采购',
      '米面粮油、乳品零食一次列齐，进超市按动线勾选。',
      '适合周末补货。创建后可改数量、补备注、记预估价格。', 'tpl_daily',
      ShoppingCatalog.seeds([
        '牛奶|食品|2 盒', '鸡蛋|食品|1 盒', '面包|食品|1 袋', '洗衣液|日用品|1 瓶',
        '纸巾|日用品|1 提', '牙膏|日用品|1 支', '垃圾袋|日用品|1 卷'
      ])))
    out.push(ShoppingCatalog.make('tpl_wetmarket', '菜市场清单', '生鲜食品',
      '蔬菜肉禽水产按摊位记，避免漏买当天要吃的。',
      '适合当天晚饭采购。可把必买标成标签，到摊位再确认份量。', 'tpl_breakfast',
      ShoppingCatalog.seeds([
        '青菜|食品|1 把', '西红柿|食品|4 个', '猪肉|食品|500g', '豆腐|食品|1 块',
        '葱姜蒜|食品|1 份', '鸡蛋|食品|10 个'
      ])))
    out.push(ShoppingCatalog.make('tpl_restock', '家庭补货清单', '家庭用品',
      '日用品和家居耗材集中补货，减少一周跑多次。',
      '结合「该补货了」使用：超过一周未买的会提示加入。', 'tpl_family',
      ShoppingCatalog.seeds([
        '洗衣液|日用品|1 瓶', '洗洁精|日用品|1 瓶', '卫生纸|日用品|1 提',
        '洗发水|日用品|1 瓶', '垃圾袋|日用品|1 卷', '灯泡|家居|2 只'
      ])))
    out.push(ShoppingCatalog.make('tpl_move', '搬家采购清单', '家庭用品',
      '收纳清洁工具一次备齐，搬家当天少跑一趟五金店。',
      '可收藏后下次搬家直接「再买一次」。', 'tpl_family',
      ShoppingCatalog.seeds([
        '纸箱|家居|10 个', '胶带|日用品|2 卷', '垃圾袋|日用品|2 卷',
        '拖把|家居|1 把', '挂钩|家居|1 包', '收纳箱|家居|4 个'
      ])))
    out.push(ShoppingCatalog.make('tpl_trip', '出行准备清单', '旅行用品',
      '洗漱、药品、充电和路上零食，出门前全屏核对。',
      '配合出门核对，避免登机或上车才发现漏带。', 'tpl_travel',
      ShoppingCatalog.seeds([
        '充电宝|数码|1 个', '充电线|数码|1 根', '牙刷|日用品|1 支',
        '常用药|日用品|1 盒', '零食|食品|若干', '袜子|服饰|3 双'
      ])))
    out.push(ShoppingCatalog.make('tpl_weekend', '周末采购', '日常采购',
      '收藏用的周末采购方案，一键生成可勾选清单。',
      '适合每周固定采购日。可设每周提醒。', 'tpl_daily',
      ShoppingCatalog.seeds([
        '牛奶|食品|2 盒', '水果|食品|1 份', '蔬菜|食品|1 份', '零食|食品|若干',
        '饮料|饮料|2 瓶'
      ])))
    out.push(ShoppingCatalog.make('tpl_festival', '节日采购', '家庭用品',
      '过节聚餐食材与一次性用品，避免当天超市缺货。',
      '可提前写预算和预估价，聚餐后对照实付。', 'tpl_family',
      ShoppingCatalog.seeds([
        '肉类|食品|1 份', '海鲜|食品|1 份', '饮料|饮料|1 箱', '水果|食品|1 份',
        '一次性餐具|日用品|1 包'
      ])))
    out.push(ShoppingCatalog.make('tpl_school', '开学采购', '儿童用品',
      '文具和日用品按开学清单备齐，减少漏买。',
      '可标「必买 / 待确认」，和孩子一起勾选。', 'memo_hero',
      ShoppingCatalog.seeds([
        '笔记本|其他|4 本', '中性笔|其他|1 盒', '书包|服饰|1 个',
        '水杯|日用品|1 个', '纸巾|日用品|1 包'
      ])))
    return out
  }

  static mergeTemplates(remote: ShoppingTemplate[]): ShoppingTemplate[] {
    const out: ShoppingTemplate[] = ShoppingCatalog.builtinTemplates()
    const used: string[] = []
    for (const row of out) {
      used.push(row.id)
      used.push(row.title)
    }
    for (const row of remote) {
      if (used.indexOf(row.id) >= 0 || used.indexOf(row.title) >= 0) {
        continue
      }
      out.push(row)
    }
    return out
  }

  private static seeds(lines: string[]): string {
    const items: TemplateItemSeed[] = []
    for (const line of lines) {
      const parts = line.split('|')
      const seed = new TemplateItemSeed()
      seed.title = parts.length > 0 ? parts[0] : ''
      seed.category = parts.length > 1 ? parts[1] : '其他'
      seed.qty = parts.length > 2 ? parts[2] : ''
      if (seed.title.length > 0) {
        items.push(seed)
      }
    }
    return ShoppingCatalog.pack(items)
  }

  private static pack(items: TemplateItemSeed[]): string {
    let json = '['
    for (let i = 0; i < items.length; i++) {
      const it = items[i]
      if (i > 0) {
        json = `${json},`
      }
      json = `${json}{"title":${JSON.stringify(it.title)},"category":${JSON.stringify(it.category)},"qty":${JSON.stringify(it.qty)}}`
    }
    return `${json}]`
  }

  private static make(id: string, title: string, subtitle: string, summary: string, body: string,
    coverKey: string, itemsJson: string): ShoppingTemplate {
    const row = new ShoppingTemplate()
    row.id = id
    row.title = title
    row.subtitle = subtitle
    row.summary = summary
    row.body = body
    row.coverKey = coverKey
    row.itemsJson = itemsJson
    return row
  }
}
