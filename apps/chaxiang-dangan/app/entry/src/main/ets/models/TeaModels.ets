export class TeaTypeDef {
  key: string = ''
  name: string = ''

  static six(): TeaTypeDef[] {
    const rows: TeaTypeDef[] = []
    const keys: string[] = ['green', 'red', 'white', 'yellow', 'oolong', 'dark']
    const names: string[] = ['绿茶', '红茶', '白茶', '黄茶', '乌龙茶', '黑茶']
    for (let i = 0; i < keys.length; i++) {
      const d = new TeaTypeDef()
      d.key = keys[i]
      d.name = names[i]
      rows.push(d)
    }
    return rows
  }

  static nameOf(key: string): string {
    const all = TeaTypeDef.six()
    for (const t of all) {
      if (t.key === key) {
        return t.name
      }
    }
    return '未分类'
  }
}

export class TagItem {
  id: string = ''
  name: string = ''
  system: boolean = false

  static fromJson(raw: object): TagItem {
    const o = raw as Record<string, string | number | boolean | object[]>
    const t = new TagItem()
    t.id = `${o['id'] ?? ''}`
    t.name = `${o['name'] ?? ''}`
    const sys = o['system']
    t.system = sys === true
    return t
  }

  static defaults(): TagItem[] {
    const names: string[] = ['清香', '浓郁', '回甘', '收藏', '日常', '纪念', '分享']
    const out: TagItem[] = []
    for (let i = 0; i < names.length; i++) {
      const t = new TagItem()
      t.id = `sys_tag_${i}`
      t.name = names[i]
      t.system = true
      out.push(t)
    }
    return out
  }
}

export class CustomBin {
  id: string = ''
  name: string = ''

  static fromJson(raw: object): CustomBin {
    const o = raw as Record<string, string | number | object[]>
    const b = new CustomBin()
    b.id = `${o['id'] ?? ''}`
    b.name = `${o['name'] ?? ''}`
    return b
  }
}

export class TeaItem {
  id: string = ''
  name: string = ''
  typeKey: string = ''
  binId: string = ''
  brand: string = ''
  origin: string = ''
  yearText: string = ''
  collectedAt: string = ''
  packageNote: string = ''
  aromaNote: string = ''
  tasteNote: string = ''
  liquorNote: string = ''
  aftertasteNote: string = ''
  review: string = ''
  stockStatus: string = 'collected'
  story: string = ''
  imageDesc: string = ''
  tagIds: string[] = []
  createdAt: number = 0
  updatedAt: number = 0

  static fromJson(raw: object): TeaItem {
    const o = raw as Record<string, string | number | object[]>
    const item = new TeaItem()
    item.id = `${o['id'] ?? ''}`
    item.name = `${o['name'] ?? ''}`
    item.typeKey = `${o['typeKey'] ?? ''}`
    item.binId = `${o['binId'] ?? ''}`
    item.brand = `${o['brand'] ?? ''}`
    item.origin = `${o['origin'] ?? ''}`
    item.yearText = `${o['yearText'] ?? ''}`
    item.collectedAt = `${o['collectedAt'] ?? ''}`
    item.packageNote = `${o['packageNote'] ?? ''}`
    item.aromaNote = `${o['aromaNote'] ?? ''}`
    item.tasteNote = `${o['tasteNote'] ?? ''}`
    item.liquorNote = `${o['liquorNote'] ?? ''}`
    item.aftertasteNote = `${o['aftertasteNote'] ?? ''}`
    item.review = `${o['review'] ?? ''}`
    item.stockStatus = `${o['stockStatus'] ?? 'collected'}`
    item.story = `${o['story'] ?? ''}`
    item.imageDesc = `${o['imageDesc'] ?? ''}`
    item.createdAt = typeof o['createdAt'] === 'number' ? o['createdAt'] as number : 0
    item.updatedAt = typeof o['updatedAt'] === 'number' ? o['updatedAt'] as number : 0
    item.tagIds = []
    const tags = o['tagIds']
    if (Array.isArray(tags)) {
      for (const t of tags) {
        item.tagIds.push(`${t}`)
      }
    }
    return item
  }

  static statusLabel(key: string): string {
    if (key === 'sipping') {
      return '正在品饮'
    }
    if (key === 'finished') {
      return '已饮完'
    }
    if (key === 'wishlist') {
      return '想尝试'
    }
    return '已收藏'
  }
}

export class TastingRecord {
  id: string = ''
  teaId: string = ''
  dateKey: string = ''
  period: string = '下午'
  mood: string = '悠闲'
  aromaFeel: string = ''
  tasteFeel: string = ''
  scoreAroma: number = 0
  scoreTaste: number = 0
  scoreLove: number = 0
  scoreKeep: number = 0
  note: string = ''
  createdAt: number = 0

  static fromJson(raw: object): TastingRecord {
    const o = raw as Record<string, string | number | object[]>
    const r = new TastingRecord()
    r.id = `${o['id'] ?? ''}`
    r.teaId = `${o['teaId'] ?? ''}`
    r.dateKey = `${o['dateKey'] ?? ''}`
    r.period = `${o['period'] ?? '下午'}`
    r.mood = `${o['mood'] ?? '悠闲'}`
    r.aromaFeel = `${o['aromaFeel'] ?? ''}`
    r.tasteFeel = `${o['tasteFeel'] ?? ''}`
    r.scoreAroma = typeof o['scoreAroma'] === 'number' ? o['scoreAroma'] as number : 0
    r.scoreTaste = typeof o['scoreTaste'] === 'number' ? o['scoreTaste'] as number : 0
    r.scoreLove = typeof o['scoreLove'] === 'number' ? o['scoreLove'] as number : 0
    r.scoreKeep = typeof o['scoreKeep'] === 'number' ? o['scoreKeep'] as number : 0
    r.note = `${o['note'] ?? ''}`
    r.createdAt = typeof o['createdAt'] === 'number' ? o['createdAt'] as number : 0
    return r
  }

  stars(): number {
    const sum = this.scoreAroma + this.scoreTaste + this.scoreLove + this.scoreKeep
    if (sum <= 0) {
      return 0
    }
    return Math.round(sum / 4)
  }
}

export class TeaList {
  id: string = ''
  name: string = ''
  intro: string = ''
  teaIds: string[] = []
  createdAt: number = 0

  static fromJson(raw: object): TeaList {
    const o = raw as Record<string, string | number | object[]>
    const l = new TeaList()
    l.id = `${o['id'] ?? ''}`
    l.name = `${o['name'] ?? ''}`
    l.intro = `${o['intro'] ?? ''}`
    l.createdAt = typeof o['createdAt'] === 'number' ? o['createdAt'] as number : 0
    l.teaIds = []
    const ids = o['teaIds']
    if (Array.isArray(ids)) {
      for (const id of ids) {
        l.teaIds.push(`${id}`)
      }
    }
    return l
  }
}

export class ThemeAlbum {
  id: string = ''
  name: string = ''
  intro: string = ''
  teaIds: string[] = []
  story: string = ''
  createdAt: number = 0

  static fromJson(raw: object): ThemeAlbum {
    const o = raw as Record<string, string | number | object[]>
    const a = new ThemeAlbum()
    a.id = `${o['id'] ?? ''}`
    a.name = `${o['name'] ?? ''}`
    a.intro = `${o['intro'] ?? ''}`
    a.story = `${o['story'] ?? ''}`
    a.createdAt = typeof o['createdAt'] === 'number' ? o['createdAt'] as number : 0
    a.teaIds = []
    const ids = o['teaIds']
    if (Array.isArray(ids)) {
      for (const id of ids) {
        a.teaIds.push(`${id}`)
      }
    }
    return a
  }
}

export class TeaPlan {
  id: string = ''
  name: string = ''
  targetCount: number = 30
  year: number = 0
  createdAt: number = 0

  static fromJson(raw: object): TeaPlan {
    const o = raw as Record<string, string | number | object[]>
    const p = new TeaPlan()
    p.id = `${o['id'] ?? ''}`
    p.name = `${o['name'] ?? ''}`
    p.targetCount = typeof o['targetCount'] === 'number' ? o['targetCount'] as number : 30
    p.year = typeof o['year'] === 'number' ? o['year'] as number : 0
    p.createdAt = typeof o['createdAt'] === 'number' ? o['createdAt'] as number : 0
    return p
  }
}

export class AppSettings {
  themeMode: string = 'system'
  nickname: string = ''

  static fromJson(raw: object): AppSettings {
    const o = raw as Record<string, string | number | object[]>
    const s = new AppSettings()
    s.themeMode = `${o['themeMode'] ?? 'system'}`
    s.nickname = `${o['nickname'] ?? ''}`
    return s
  }
}

export class TeaBundle {
  teas: TeaItem[] = []
  tastings: TastingRecord[] = []
  lists: TeaList[] = []
  albums: ThemeAlbum[] = []
  plans: TeaPlan[] = []
  tags: TagItem[] = []
  bins: CustomBin[] = []
  settings: AppSettings = new AppSettings()
}

export class OrganizeHint {
  teaId: string = ''
  title: string = ''
  reason: string = ''
}

export class TimelineMark {
  id: string = ''
  dateKey: string = ''
  title: string = ''
  body: string = ''
}

export class AchievementDef {
  id: string = ''
  title: string = ''
  hint: string = ''

  static catalog(): AchievementDef[] {
    const rows: AchievementDef[] = []
    const ids: string[] = ['first_sip', 'week_7', 'teas_10', 'sip_100', 'albums_5']
    const titles: string[] = ['第一杯记录', '连续记录7天', '收藏10款茶', '品饮100次', '创建5个茶主题']
    const hints: string[] = ['写下第一次品饮', '7个不同日期有记录', '茶库满10款', '累计100次品饮', '主题册满5本']
    for (let i = 0; i < ids.length; i++) {
      const a = new AchievementDef()
      a.id = ids[i]
      a.title = titles[i]
      a.hint = hints[i]
      rows.push(a)
    }
    return rows
  }
}

export class TeaStats {
  teaCount: number = 0
  tastingCount: number = 0
  favoriteCount: number = 0
  albumCount: number = 0
  listCount: number = 0
  dayCount: number = 0
}

export class TypeShare {
  key: string = ''
  name: string = ''
  count: number = 0
}

export class MonthBar {
  label: string = ''
  value: number = 0
}
