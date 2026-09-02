/** 常识集数据模型（ArkTS 严格模式） */

export class FactWire {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  category: string = ''
  tags: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  publishDate: string = ''
  readMinutes: number = 2
  source: string = ''
  scene: string = ''
}

export class FactListPayload {
  list: FactWire[] = []
}

export class FactItem {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  category: string = 'life'
  tags: string = ''
  coverKey: string = 'cover_life'
  publishDate: string = ''
  readMinutes: number = 2
  source: string = ''
  scene: string = 'tips'

  categoryLabel(): string {
    if (this.category === 'science') {
      return '科普知识'
    }
    if (this.category === 'history') {
      return '人文历史'
    }
    if (this.category === 'health') {
      return '健康知识'
    }
    if (this.category === 'nature') {
      return '自然百科'
    }
    if (this.category === 'career') {
      return '职场智慧'
    }
    if (this.category === 'food') {
      return '饮食文化'
    }
    if (this.category === 'mind') {
      return '心理常识'
    }
    if (this.category === 'safety') {
      return '安全知识'
    }
    if (this.category === 'family') {
      return '家庭常识'
    }
    if (this.category === 'festival') {
      return '节日文化'
    }
    return '生活技巧'
  }

  sceneLabel(): string {
    return SceneChip.labelOf(this.scene)
  }

  tagList(): string[] {
    const out: string[] = []
    if (this.tags.length === 0) {
      return out
    }
    const parts = this.tags.split(',')
    for (const part of parts) {
      const trimmed = part.trim()
      if (trimmed.length > 0) {
        out.push(trimmed)
      }
    }
    return out
  }

  /** JSON.parse 得到的对象没有 class 默认值，缺字段时不能直接 .length */
  static wireText(raw: string): string {
    if (raw) {
      return raw
    }
    return ''
  }

  static fromWire(w: FactWire): FactItem {
    const item = new FactItem()
    const id = FactItem.wireText(w.id)
    const title = FactItem.wireText(w.title)
    const summary = FactItem.wireText(w.summary)
    const description = FactItem.wireText(w.description)
    const body = FactItem.wireText(w.body)
    const category = FactItem.wireText(w.category)
    const tags = FactItem.wireText(w.tags)
    const coverMedia = FactItem.wireText(w.coverMedia)
    const coverKey = FactItem.wireText(w.coverKey)
    const scene = FactItem.wireText(w.scene)
    item.id = id
    item.title = title
    item.summary = summary.length > 0 ? summary : description
    item.body = body.length > 0 ? body : description
    item.category = category.length > 0 ? category : 'life'
    item.tags = tags
    if (coverMedia.length > 0) {
      item.coverKey = coverMedia
    } else if (coverKey.length > 0) {
      item.coverKey = coverKey
    }
    item.publishDate = FactItem.wireText(w.publishDate)
    item.readMinutes = w.readMinutes > 0 ? w.readMinutes : 2
    item.source = FactItem.wireText(w.source)
    item.scene = scene.length > 0 ? scene : SceneChip.infer(item.category, item.tags)
    return item
  }
}

export class CommonSenseStats {
  readDays: number = 0
  favorites: number = 0
  checkInStreak: number = 0
  readCount: number = 0
  mastered: number = 0
  lists: number = 0
}

export class CategoryChip {
  key: string = 'all'
  label: string = '全部'

  static all(): CategoryChip[] {
    const rows: CategoryChip[] = []
    const keys: string[] = [
      'all', 'life', 'health', 'safety', 'family', 'science', 'festival',
      'history', 'nature', 'career', 'food', 'mind'
    ]
    const labels: string[] = [
      '全部', '生活技巧', '健康知识', '安全知识', '家庭常识', '科普知识', '节日文化',
      '人文历史', '自然百科', '职场智慧', '饮食文化', '心理常识'
    ]
    for (let i = 0; i < keys.length; i++) {
      const row = new CategoryChip()
      row.key = keys[i]
      row.label = labels[i]
      rows.push(row)
    }
    return rows
  }
}

export class CommonSenseTime {
  static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static formatDisplay(dateKey: string): string {
    if (dateKey.length < 10) {
      return dateKey
    }
    const parts = dateKey.split('-')
    if (parts.length < 3) {
      return dateKey
    }
    return `${parts[1]}/${parts[2]}`
  }

  static lastNDays(n: number): string[] {
    const out: string[] = []
    const now = new Date()
    for (let i = n - 1; i >= 0; i--) {
      const d = new Date(now.getTime() - i * 86400000)
      out.push(CommonSenseTime.todayKeyFromDate(d))
    }
    return out
  }

  static todayKeyFromDate(d: Date): string {
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static nowIso(): string {
    return new Date().toISOString()
  }

  static recentDayKeys(n: number): string[] {
    return CommonSenseTime.lastNDays(n)
  }
}

export class SceneChip {
  key: string = 'all'
  label: string = '全部场景'

  static all(): SceneChip[] {
    const rows: SceneChip[] = []
    const keys: string[] = ['all', 'clean', 'foodsave', 'travel', 'emergency', 'tips']
    const labels: string[] = ['全部场景', '居家清洁', '食材保存', '出行安全', '家庭应急', '生活小窍门']
    for (let i = 0; i < keys.length; i++) {
      const row = new SceneChip()
      row.key = keys[i]
      row.label = labels[i]
      rows.push(row)
    }
    return rows
  }

  static labelOf(key: string): string {
    if (key === 'clean') {
      return '居家清洁'
    }
    if (key === 'foodsave') {
      return '食材保存'
    }
    if (key === 'travel') {
      return '出行安全'
    }
    if (key === 'emergency') {
      return '家庭应急'
    }
    return '生活小窍门'
  }

  static infer(category: string, tags: string): string {
    if (tags.indexOf('清洁') >= 0 || tags.indexOf('家务') >= 0 || tags.indexOf('洗衣') >= 0) {
      return 'clean'
    }
    if (tags.indexOf('储存') >= 0 || tags.indexOf('剩菜') >= 0 || tags.indexOf('茶叶') >= 0 ||
      tags.indexOf('主食') >= 0 || tags.indexOf('烹饪') >= 0) {
      return 'foodsave'
    }
    if (tags.indexOf('飞行') >= 0 || tags.indexOf('沙漠') >= 0 || tags.indexOf('出行') >= 0) {
      return 'travel'
    }
    if (tags.indexOf('急救') >= 0 || tags.indexOf('伤口') >= 0 || tags.indexOf('电池') >= 0 ||
      tags.indexOf('安全') >= 0) {
      return 'emergency'
    }
    if (category === 'food') {
      return 'foodsave'
    }
    if (category === 'safety') {
      return 'emergency'
    }
    return 'tips'
  }
}
