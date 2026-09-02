export class CategoryOption {
  key: string = ''
  label: string = ''
  hint: string = ''
  knowledge: string = ''

  static all(): CategoryOption[] {
    const list: CategoryOption[] = []
    const rows: string[][] = [
      ['plant', '植物观察', '叶片、花期与光照', '观察植物时记录叶片形状、花期、光照与浇水，便于对比生长变化。'],
      ['animal', '动物观察', '习性与活动时段', '记录习性、食性与活动时段，近距离观察时避免惊扰。'],
      ['collect', '收藏物品', '来源、材质与保存', '记下来源、材质、尺寸与保存环境，方便日后整理收藏。'],
      ['home', '家庭物件', '位置、用途与磨损', '记录物件所在位置、日常用途与磨损痕迹，看见生活痕迹。'],
      ['nature', '自然发现', '天气、地点与季节', '写下天气、地点与季节特征，把一次遇见变成可回看的发现。']
    ]
    for (const row of rows) {
      const o = new CategoryOption()
      o.key = row[0]
      o.label = row[1]
      o.hint = row[2]
      o.knowledge = row[3]
      list.push(o)
    }
    return list
  }

  static find(key: string): CategoryOption | undefined {
    for (const o of CategoryOption.all()) {
      if (o.key === key) {
        return o
      }
    }
    return undefined
  }

  static labelOf(key: string): string {
    const o = CategoryOption.find(key)
    return o !== undefined ? o.label : '未分类'
  }

  static knowledgeOf(key: string): string {
    const o = CategoryOption.find(key)
    return o !== undefined ? o.knowledge : ''
  }
}

export class ObserveTemplate {
  key: string = ''
  title: string = ''
  kind: string = 'thought'
  categoryKey: string = 'nature'
  prompt: string = ''
  tags: string = ''

  static all(): ObserveTemplate[] {
    const list: ObserveTemplate[] = []
    const rows: string[][] = [
      ['plant', '植物观察记录', 'environment', 'plant', '写下这种植物的叶片、花色或生长位置。', '户外,春季'],
      ['pet', '宠物观察记录', 'mood', 'animal', '记下宠物此刻的状态、动作或让你留意的习性。', '喜爱'],
      ['collect', '收藏品记录', 'thought', 'collect', '写下这件收藏的来源、材质与你保存它的原因。', '收藏'],
      ['travel', '旅行见闻记录', 'scene', 'nature', '用一两句话定格旅途中眼前的一处风景或物件。', '户外'],
      ['nature', '自然观察记录', 'environment', 'nature', '记录此刻的光、风、天气或你新发现的自然痕迹。', '户外,春季']
    ]
    for (const row of rows) {
      const t = new ObserveTemplate()
      t.key = row[0]
      t.title = row[1]
      t.kind = row[2]
      t.categoryKey = row[3]
      t.prompt = row[4]
      t.tags = row[5]
      list.push(t)
    }
    return list
  }
}

export class ExploreTaskDef {
  key: string = ''
  title: string = ''
  prompt: string = ''
  kind: string = 'thought'
  categoryKey: string = 'nature'
  tags: string = ''

  static todayList(): ExploreTaskDef[] {
    const pool: string[][] = [
      ['t1', '今日发现一个新事物', '在身边找出一件你平时忽略的物品，写下它的颜色与材质。', 'thought', 'home', '喜爱'],
      ['t2', '记录一种植物', '观察一株植物的叶片或花期，写一句此刻的变化。', 'environment', 'plant', '户外,春季'],
      ['t3', '观察天气变化', '写下此刻的光、风或云，和昨天有什么不同。', 'environment', 'nature', '户外'],
      ['t4', '拍摄身边物品', '为手边一件家用物件拍照，并记下它的用途。', 'scene', 'home', '收藏']
    ]
    const out: ExploreTaskDef[] = []
    for (const row of pool) {
      const t = new ExploreTaskDef()
      t.key = row[0]
      t.title = row[1]
      t.prompt = row[2]
      t.kind = row[3]
      t.categoryKey = row[4]
      t.tags = row[5]
      out.push(t)
    }
    return out
  }
}

export class ObserveTag {
  static presets(): string[] {
    return ['春季', '户外', '收藏', '喜爱']
  }
}

export class ObserveSubject {
  id: string = ''
  name: string = ''
  categoryKey: string = 'nature'
  traits: string = ''
  knowledge: string = ''
  coverPath: string = ''
  tags: string = ''
  createdAt: number = 0
  remindWeekly: boolean = false

  static create(name: string, categoryKey: string): ObserveSubject {
    const s = new ObserveSubject()
    s.id = `sub_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    s.name = name
    s.categoryKey = categoryKey
    s.createdAt = Date.now()
    s.knowledge = CategoryOption.knowledgeOf(categoryKey)
    return s
  }
}
