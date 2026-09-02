export class TimelineEvent {
  id: string = ''
  period: string = ''
  label: string = ''

  static fromJson(raw: object): TimelineEvent {
    const o = raw as Record<string, string>
    const e = new TimelineEvent()
    e.id = o['id'] ?? ''
    e.period = o['period'] ?? ''
    e.label = o['label'] ?? ''
    return e
  }
}

export class TreasureItem {
  id: string = ''
  name: string = ''
  categoryId: string = ''
  acquiredAt: string = ''
  source: string = ''
  keywords: string = ''
  tagIds: string[] = []
  traits: string = ''
  collectReason: string = ''
  story: string = ''
  personalReview: string = ''
  rating: number = 0
  appreciationText: string = ''
  archiveStatus: string = '刚入藏'
  listStatus: string = '已完成'
  storageLocation: string = ''
  storageNote: string = ''
  imagePath: string = ''
  planId: string = ''
  timeline: TimelineEvent[] = []
  createdAt: number = 0
  updatedAt: number = 0
  lastViewedAt: number = 0
  deletedAt: number = 0

  static fromJson(raw: object): TreasureItem {
    const o = raw as Record<string, string | number | object[]>
    const item = new TreasureItem()
    item.id = `${o['id'] ?? ''}`
    item.name = `${o['name'] ?? ''}`
    item.categoryId = `${o['categoryId'] ?? ''}`
    item.acquiredAt = `${o['acquiredAt'] ?? ''}`
    item.source = `${o['source'] ?? ''}`
    item.keywords = `${o['keywords'] ?? ''}`
    item.traits = `${o['traits'] ?? ''}`
    item.collectReason = `${o['collectReason'] ?? ''}`
    item.story = `${o['story'] ?? ''}`
    item.personalReview = `${o['personalReview'] ?? ''}`
    item.rating = typeof o['rating'] === 'number' ? o['rating'] as number : 0
    item.appreciationText = `${o['appreciationText'] ?? ''}`
    item.archiveStatus = `${o['archiveStatus'] ?? o['storageStatus'] ?? '刚入藏'}`
    if (item.archiveStatus === '完好') {
      item.archiveStatus = '已整理'
    }
    if (item.archiveStatus === '需要整理') {
      item.archiveStatus = '刚入藏'
    }
    item.listStatus = `${o['listStatus'] ?? '已完成'}`
    item.storageLocation = `${o['storageLocation'] ?? ''}`
    item.storageNote = `${o['storageNote'] ?? ''}`
    item.imagePath = `${o['imagePath'] ?? ''}`
    item.planId = `${o['planId'] ?? ''}`
    item.createdAt = typeof o['createdAt'] === 'number' ? o['createdAt'] as number : 0
    item.updatedAt = typeof o['updatedAt'] === 'number' ? o['updatedAt'] as number : 0
    item.lastViewedAt = typeof o['lastViewedAt'] === 'number' ? o['lastViewedAt'] as number : 0
    item.deletedAt = typeof o['deletedAt'] === 'number' ? o['deletedAt'] as number : 0
    item.tagIds = []
    const tags = o['tagIds']
    if (Array.isArray(tags)) {
      for (const t of tags) {
        item.tagIds.push(`${t}`)
      }
    }
    item.timeline = []
    const tl = o['timeline']
    if (Array.isArray(tl)) {
      for (const row of tl) {
        item.timeline.push(TimelineEvent.fromJson(row as object))
      }
    }
    return item
  }
}

export class CategoryItem {
  id: string = ''
  name: string = ''
  sortOrder: number = 0
  domainKey: string = ''

  static fromJson(raw: object): CategoryItem {
    const o = raw as Record<string, string | number>
    const c = new CategoryItem()
    c.id = `${o['id'] ?? ''}`
    c.name = `${o['name'] ?? ''}`
    c.sortOrder = typeof o['sortOrder'] === 'number' ? o['sortOrder'] as number : 0
    c.domainKey = `${o['domainKey'] ?? ''}`
    return c
  }
}

export class TagItem {
  id: string = ''
  name: string = ''

  static fromJson(raw: object): TagItem {
    const o = raw as Record<string, string>
    const t = new TagItem()
    t.id = o['id'] ?? ''
    t.name = o['name'] ?? ''
    return t
  }
}

export class TreasureAlbum {
  id: string = ''
  name: string = ''
  intro: string = ''
  coverTone: string = 'warm'
  spaceTheme: string = ''
  itemIds: string[] = []
  createdAt: number = 0

  static fromJson(raw: object): TreasureAlbum {
    const o = raw as Record<string, string | number | object[]>
    const a = new TreasureAlbum()
    a.id = `${o['id'] ?? ''}`
    a.name = `${o['name'] ?? ''}`
    a.intro = `${o['intro'] ?? ''}`
    a.coverTone = `${o['coverTone'] ?? 'warm'}`
    a.spaceTheme = `${o['spaceTheme'] ?? ''}`
    a.createdAt = typeof o['createdAt'] === 'number' ? o['createdAt'] as number : 0
    a.itemIds = []
    const ids = o['itemIds']
    if (Array.isArray(ids)) {
      for (const id of ids) {
        a.itemIds.push(`${id}`)
      }
    }
    return a
  }
}

export class CollectionPlan {
  id: string = ''
  name: string = ''
  targetCount: number = 0
  period: string = ''
  itemIds: string[] = []
  createdAt: number = 0
  completedAt: number = 0

  static fromJson(raw: object): CollectionPlan {
    const o = raw as Record<string, string | number | object[]>
    const p = new CollectionPlan()
    p.id = `${o['id'] ?? ''}`
    p.name = `${o['name'] ?? ''}`
    p.targetCount = typeof o['targetCount'] === 'number' ? o['targetCount'] as number : 0
    p.period = `${o['period'] ?? ''}`
    p.createdAt = typeof o['createdAt'] === 'number' ? o['createdAt'] as number : 0
    p.completedAt = typeof o['completedAt'] === 'number' ? o['completedAt'] as number : 0
    p.itemIds = []
    const ids = o['itemIds']
    if (Array.isArray(ids)) {
      for (const id of ids) {
        p.itemIds.push(`${id}`)
      }
    }
    return p
  }
}

export class WishItem {
  id: string = ''
  name: string = ''
  note: string = ''
  listKind: string = '想寻找'
  createdAt: number = 0

  static fromJson(raw: object): WishItem {
    const o = raw as Record<string, string | number>
    const w = new WishItem()
    w.id = `${o['id'] ?? ''}`
    w.name = `${o['name'] ?? ''}`
    w.note = `${o['note'] ?? ''}`
    w.listKind = `${o['listKind'] ?? '想寻找'}`
    w.createdAt = typeof o['createdAt'] === 'number' ? o['createdAt'] as number : 0
    return w
  }
}

export class CollectionNote {
  id: string = ''
  title: string = ''
  body: string = ''
  relatedItemId: string = ''
  createdAt: number = 0

  static fromJson(raw: object): CollectionNote {
    const o = raw as Record<string, string | number>
    const n = new CollectionNote()
    n.id = `${o['id'] ?? ''}`
    n.title = `${o['title'] ?? ''}`
    n.body = `${o['body'] ?? ''}`
    n.relatedItemId = `${o['relatedItemId'] ?? ''}`
    n.createdAt = typeof o['createdAt'] === 'number' ? o['createdAt'] as number : 0
    return n
  }
}

export class ActivityLog {
  id: string = ''
  dateKey: string = ''
  kind: string = ''
  label: string = ''
  refId: string = ''
  createdAt: number = 0

  static fromJson(raw: object): ActivityLog {
    const o = raw as Record<string, string | number>
    const a = new ActivityLog()
    a.id = `${o['id'] ?? ''}`
    a.dateKey = `${o['dateKey'] ?? ''}`
    a.kind = `${o['kind'] ?? ''}`
    a.label = `${o['label'] ?? ''}`
    a.refId = `${o['refId'] ?? ''}`
    a.createdAt = typeof o['createdAt'] === 'number' ? o['createdAt'] as number : 0
    return a
  }
}

export class AchievementDef {
  id: string = ''
  title: string = ''
  subtitle: string = ''

  static fromJson(raw: object): AchievementDef {
    const o = raw as Record<string, string>
    const a = new AchievementDef()
    a.id = o['id'] ?? ''
    a.title = o['title'] ?? ''
    a.subtitle = o['subtitle'] ?? ''
    return a
  }
}

export class AppSettings {
  nickname: string = ''
  themeMode: string = 'system'
  achievementsUnlocked: string[] = []
  onboardingDone: boolean = false

  static fromJson(raw: object): AppSettings {
    const o = raw as Record<string, string | boolean | object[]>
    const s = new AppSettings()
    s.nickname = `${o['nickname'] ?? ''}`
    s.themeMode = `${o['themeMode'] ?? 'system'}`
    s.onboardingDone = o['onboardingDone'] === true
    s.achievementsUnlocked = []
    const ach = o['achievementsUnlocked']
    if (Array.isArray(ach)) {
      for (const id of ach) {
        s.achievementsUnlocked.push(`${id}`)
      }
    }
    return s
  }
}

export class TreasureBundle {
  items: TreasureItem[] = []
  categories: CategoryItem[] = []
  tags: TagItem[] = []
  albums: TreasureAlbum[] = []
  plans: CollectionPlan[] = []
  wishes: WishItem[] = []
  notes: CollectionNote[] = []
  activities: ActivityLog[] = []
  settings: AppSettings = new AppSettings()
}

export class YearBucket {
  year: string = ''
  count: number = 0
}

export class LabelBucket {
  label: string = ''
  count: number = 0
}

export class DomainBucket {
  key: string = ''
  label: string = ''
  count: number = 0
  tone: string = ''
}

export class ReviewSnippet {
  title: string = ''
  body: string = ''
}

export class OrganizeHint {
  kind: string = ''
  title: string = ''
  detail: string = ''
  refId: string = ''
}

export class ExportPayload {
  exportedAt: string = ''
  itemCount: number = 0
  text: string = ''
}

export class SearchHit {
  kind: string = ''
  title: string = ''
  subtitle: string = ''
  refId: string = ''
}
