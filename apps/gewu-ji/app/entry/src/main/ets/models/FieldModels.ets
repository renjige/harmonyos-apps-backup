/** 格物记录 / 图鉴 / 收藏夹 / 探索任务 */

export class AtlasKind {
  static all(): string[] {
    return ['植物图鉴', '动物图鉴', '昆虫图鉴', '矿物图鉴', '日常物品']
  }
}

export class AlbumKind {
  static all(): string[] {
    return ['古物收藏', '自然观察', '生活用品', '艺术品', '科普知识']
  }
}

export class TagPreset {
  static all(): string[] {
    return ['春季发现', '户外探索', '收藏记录']
  }
}

export class NoteTemplate {
  key: string = ''
  label: string = ''
  body: string = ''

  static all(): NoteTemplate[] {
    const list: NoteTemplate[] = []
    list.push(NoteTemplate.make('plant', '植物观察笔记',
      '名称：\n生长环境：\n叶片/花果特征：\n本次观察变化：\n疑问：'))
    list.push(NoteTemplate.make('animal', '动物观察笔记',
      '名称：\n出现地点：\n行为与特征：\n本次观察变化：\n疑问：'))
    list.push(NoteTemplate.make('collect', '收藏品档案',
      '物品名称：\n来源/年代：\n材质与工艺：\n为何收藏：\n待查知识：'))
    list.push(NoteTemplate.make('nature', '自然探索笔记',
      '现象：\n时间与天气：\n现场描述：\n可能成因：\n下次想验证：'))
    list.push(NoteTemplate.make('life', '生活发现笔记',
      '物品/场景：\n它解决什么问题：\n结构或用法：\n今日体会：'))
    return list
  }

  static make(key: string, label: string, body: string): NoteTemplate {
    const t = new NoteTemplate()
    t.key = key
    t.label = label
    t.body = body
    return t
  }

  static byKey(key: string): NoteTemplate {
    for (const t of NoteTemplate.all()) {
      if (t.key === key) {
        return t
      }
    }
    return NoteTemplate.make('life', '生活发现笔记', '')
  }
}

export class FieldRecord {
  id: string = ''
  subjectId: string = ''
  title: string = ''
  atlasKind: string = '日常物品'
  albumKey: string = ''
  templateKey: string = 'life'
  body: string = ''
  place: string = ''
  dateKey: string = ''
  coverKey: string = 'atlas_lotus'
  tags: string[] = []
  createdAt: number = 0

  preview(): string {
    const t = this.body.trim()
    if (t.length === 0) {
      return '（尚未填写观察）'
    }
    return t.length > 48 ? `${t.substring(0, 48)}…` : t
  }
}

export class ExploreQuest {
  id: string = ''
  title: string = ''
  hint: string = ''
  done: boolean = false
}

export class QuizOption {
  text: string = ''
  ok: boolean = false
}

export class QuizItem {
  prompt: string = ''
  options: QuizOption[] = []
}

export class AtlasStat {
  kind: string = ''
  total: number = 0
  saved: number = 0
}

export class WeekMark {
  key: string = ''
  label: string = ''
  hasRecord: boolean = false
}

export class DayCount {
  key: string = ''
  label: string = ''
  count: number = 0
}

export class GewuPlan {
  id: string = ''
  title: string = ''
  atlasKind: string = 'all'
  targetCount: number = 5
  startKey: string = ''
  endKey: string = ''
  note: string = ''
  createdAt: number = 0

  rangeLabel(): string {
    return `${this.startKey} 至 ${this.endKey}`
  }
}

export class GewuCheckin {
  dateKey: string = ''
  note: string = ''
  objectId: string = ''
  createdAt: number = 0
}

export class GewuTopic {
  id: string = ''
  title: string = ''
  objectIds: string[] = []
  createdAt: number = 0
}

export class GewuEvent {
  dateKey: string = ''
  kind: string = ''
  title: string = ''
  refId: string = ''
  at: number = 0
}

export class GewuBadge {
  id: string = ''
  title: string = ''
  hint: string = ''
  unlocked: boolean = false

  static catalog(): GewuBadge[] {
    const list: GewuBadge[] = []
    list.push(GewuBadge.make('first_record', '初识格物', '写下第一条观察'))
    list.push(GewuBadge.make('first_checkin', '物候初记', '完成一次物候打卡'))
    list.push(GewuBadge.make('records_10', '记录达人', '累计 10 则观察'))
    list.push(GewuBadge.make('records_50', '观察五十', '累计 50 则观察'))
    list.push(GewuBadge.make('fav_5', '收藏达人', '收藏 5 件知识物'))
    list.push(GewuBadge.make('streak_7', '七日不断', '观察或打卡连续 7 天'))
    list.push(GewuBadge.make('streak_30', '月轮物候', '观察或打卡连续 30 天'))
    list.push(GewuBadge.make('quiz_3', '格物三试', '完成 3 次格物小测'))
    list.push(GewuBadge.make('plan_done', '功成一课', '完成一份格物功课'))
    list.push(GewuBadge.make('browse_8', '博览群物', '浏览过 8 件图鉴'))
    return list
  }

  static make(id: string, title: string, hint: string): GewuBadge {
    const b = new GewuBadge()
    b.id = id
    b.title = title
    b.hint = hint
    return b
  }
}

export class DashStats {
  questDone: number = 0
  checkinToday: boolean = false
  recordCount: number = 0
  favCount: number = 0
  streak: number = 0
  checkinCount: number = 0
  ritualDone: number = 0
  ritualTotal: number = 6
  planTitle: string = ''
  planId: string = ''
  planDone: number = 0
  planTarget: number = 0
  weekLine: string = ''
  monthLine: string = ''
}

export class DailyTheme {
  static today(): string {
    const list: string[] = [
      '观察一种身边的植物，记下叶片或花的特征',
      '记录一件生活用品：它最初要解决什么问题？',
      '在户外找一种昆虫或鸟，写清出现的地点',
      '对照矿物或玉石图鉴，描述光泽与质地',
      '为收藏夹新增一件物品，并写一句为何收藏',
      '对同一对象追加一次观察，对比上次变化',
      '用「自然探索笔记」模板完成一次现场记录'
    ]
    const idx = new Date().getDate() % list.length
    let i = 0
    for (const line of list) {
      if (i === idx) {
        return line
      }
      i++
    }
    return '记录身边一种物品，写下它解决的问题'
  }
}

/** 今日格物路径 — 读→问→测→记→候，区别于通用记事本 */
export class GewuPathStep {
  key: string = ''
  label: string = ''
  shortLabel: string = ''
  done: boolean = false
}

export class GewuPathStatus {
  steps: GewuPathStep[] = []
  doneCount: number = 0
  total: number = 5
}
