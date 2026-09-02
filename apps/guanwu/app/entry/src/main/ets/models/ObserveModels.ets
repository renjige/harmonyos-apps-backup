export class KindOption {
  key: string = ''
  label: string = ''
  hint: string = ''

  static all(): KindOption[] {
    const list: KindOption[] = []
    const rows: string[][] = [
      ['mood', '心情', '此刻的情绪起伏'],
      ['scene', '场景', '你所在的地方'],
      ['thought', '想法', '一闪而过的念头'],
      ['environment', '环境', '光、风与气温的感觉']
    ]
    for (const row of rows) {
      const o = new KindOption()
      o.key = row[0]
      o.label = row[1]
      o.hint = row[2]
      list.push(o)
    }
    return list
  }

  static find(key: string): KindOption | undefined {
    for (const o of KindOption.all()) {
      if (o.key === key) {
        return o
      }
    }
    return undefined
  }
}

export class SubtypeOption {
  key: string = ''
  label: string = ''
  kind: string = ''
  score: number = 3

  static forKind(kind: string): SubtypeOption[] {
    const list: SubtypeOption[] = []
    const rows: string[][] = [
      ['mood', 'happy', '愉悦', '5'],
      ['mood', 'calm', '平静', '4'],
      ['mood', 'excited', '兴奋', '5'],
      ['mood', 'tired', '疲惫', '2'],
      ['mood', 'sad', '低落', '1'],
      ['scene', 'home', '居家', '3'],
      ['scene', 'work', '工作', '3'],
      ['scene', 'outdoor', '户外', '3'],
      ['scene', 'travel', '出行', '3'],
      ['scene', 'other', '其他', '3'],
      ['environment', 'sunny', '晴朗', '4'],
      ['environment', 'cloudy', '阴沉', '2'],
      ['environment', 'breeze', '微风', '4'],
      ['environment', 'stuffy', '闷热', '2'],
      ['environment', 'indoor_light', '室内光', '3'],
      ['thought', 'flash', '闪念', '3'],
      ['thought', 'question', '疑问', '3'],
      ['thought', 'plan', '打算', '4']
    ]
    for (const row of rows) {
      if (row[0] === kind) {
        const o = new SubtypeOption()
        o.kind = row[0]
        o.key = row[1]
        o.label = row[2]
        o.score = parseInt(row[3], 10)
        list.push(o)
      }
    }
    return list
  }

  static find(kind: string, key: string): SubtypeOption | undefined {
    for (const o of SubtypeOption.forKind(kind)) {
      if (o.key === key) {
        return o
      }
    }
    return undefined
  }

  static labelOf(kind: string, key: string): string {
    const o = SubtypeOption.find(kind, key)
    return o !== undefined ? o.label : ''
  }
}

export class ObserveRecord {
  id: string = ''
  dateKey: string = ''
  kind: string = 'thought'
  subtypeKey: string = ''
  content: string = ''
  imagePaths: string[] = []
  createdAt: number = 0
  updatedAt: number = 0
  categoryKey: string = 'nature'
  subjectId: string = ''
  tags: string = ''
  favorited: boolean = false
  itemName: string = ''

  static createNew(dateKey: string): ObserveRecord {
    const n = new ObserveRecord()
    n.id = `ob_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    n.dateKey = dateKey
    n.createdAt = Date.now()
    n.updatedAt = n.createdAt
    return n
  }

  kindLabel(): string {
    const k = KindOption.find(this.kind)
    return k !== undefined ? k.label : '观察'
  }

  subtypeLabel(): string {
    return SubtypeOption.labelOf(this.kind, this.subtypeKey)
  }

  preview(): string {
    const t = this.content.trim()
    if (t.length === 0) {
      return '（空观察）'
    }
    return t.length > 36 ? `${t.substring(0, 36)}…` : t
  }

  hasImage(): boolean {
    return this.imagePaths.length > 0 && this.imagePaths[0].length > 0
  }

  static cloneFrom(source: ObserveRecord): ObserveRecord {
    const n = new ObserveRecord()
    n.id = source.id
    n.dateKey = source.dateKey
    n.kind = source.kind
    n.subtypeKey = source.subtypeKey
    n.content = source.content
    n.createdAt = source.createdAt
    n.updatedAt = source.updatedAt
    n.categoryKey = source.categoryKey
    n.subjectId = source.subjectId
    n.tags = source.tags
    n.favorited = source.favorited
    n.itemName = source.itemName
    for (const p of source.imagePaths) {
      n.imagePaths.push(p)
    }
    return n
  }
}

export class UserProfile {
  nickname: string = '观物者'
  signature: string = '观物取象，看见日常'
  reminderHour: number = 21
  reminderMinute: number = 0
  reminderEnabled: boolean = false
  themeMode: string = 'system'
}

export class EmotionStat {
  key: string = ''
  label: string = ''
  count: number = 0
  ratio: number = 0
}

export class SceneStat {
  key: string = ''
  label: string = ''
  count: number = 0
}

export class TrendPoint {
  dateKey: string = ''
  label: string = ''
  score: number = 0
  count: number = 0
}

export class InsightReport {
  periodLabel: string = ''
  recordCount: number = 0
  mainMood: string = ''
  mainMoodRatio: number = 0
  topScene: string = ''
  wisdomMessage: string = ''
  streakDays: number = 0
}

export class MilestoneItem {
  title: string = ''
  reached: boolean = false
  threshold: number = 0
}

export class WisdomTip {
  title: string = ''
  body: string = ''
}
