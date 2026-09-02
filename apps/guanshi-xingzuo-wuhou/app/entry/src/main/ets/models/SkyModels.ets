/** 星座物候 — 平台 Wire 与本地模型（ArkTS 严格模式） */

export class SkyWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  enName: string = ''
  dateRange: string = ''
  season: string = ''
  bestTime: string = ''
  brightStar: string = ''
  observeTip: string = ''
  story: string = ''
  kind: string = ''
  monthStart: number = 1
  dayStart: number = 1
  monthEnd: number = 1
  dayEnd: number = 1
  mapKey: string = ''
}

export class SkyListPayload {
  list: SkyWire[] = []
}

export class ConstellationItem {
  id: string = ''
  title: string = ''
  enName: string = ''
  dateRange: string = ''
  season: string = ''
  summary: string = ''
  story: string = ''
  bestTime: string = ''
  brightStar: string = ''
  observeTip: string = ''
  coverKey: string = ''
  mapKey: string = ''
  monthStart: number = 1
  dayStart: number = 1
  monthEnd: number = 1
  dayEnd: number = 1

  static fromWire(w: SkyWire): ConstellationItem {
    const item = new ConstellationItem()
    item.id = w.id ?? ''
    item.title = w.title ?? ''
    item.enName = w.enName ?? w.subtitle ?? ''
    item.dateRange = w.dateRange ?? ''
    item.season = w.season ?? ''
    item.summary = w.summary ?? ''
    item.story = w.story ?? w.body ?? w.description ?? ''
    item.bestTime = w.bestTime ?? ''
    item.brightStar = w.brightStar ?? ''
    item.observeTip = w.observeTip ?? ''
    item.coverKey = ConstellationItem.pickCover(w)
    item.mapKey = w.mapKey ?? ''
    item.monthStart = w.monthStart ?? 1
    item.dayStart = w.dayStart ?? 1
    item.monthEnd = w.monthEnd ?? 1
    item.dayEnd = w.dayEnd ?? 1
    return item
  }

  static pickCover(w: SkyWire): string {
    if (w.coverKey !== undefined && w.coverKey.length > 0) {
      return w.coverKey
    }
    if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      return w.coverMedia
    }
    return 'night_summer'
  }

  static make(
    id: string,
    title: string,
    enName: string,
    dateRange: string,
    season: string,
    m0: number,
    d0: number,
    m1: number,
    d1: number,
    bestTime: string,
    brightStar: string,
    summary: string,
    story: string,
    observeTip: string,
    mapKey: string,
    coverKey: string
  ): ConstellationItem {
    const item = new ConstellationItem()
    item.id = id
    item.title = title
    item.enName = enName
    item.dateRange = dateRange
    item.season = season
    item.monthStart = m0
    item.dayStart = d0
    item.monthEnd = m1
    item.dayEnd = d1
    item.bestTime = bestTime
    item.brightStar = brightStar
    item.summary = summary
    item.story = story
    item.observeTip = observeTip
    item.mapKey = mapKey
    item.coverKey = coverKey
    return item
  }
}

export class PhenologyItem {
  id: string = ''
  title: string = ''
  season: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  monthStart: number = 1
  dayStart: number = 1

  static fromWire(w: SkyWire): PhenologyItem {
    const item = new PhenologyItem()
    item.id = w.id ?? ''
    item.title = w.title ?? ''
    item.season = w.season ?? w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    item.coverKey = ConstellationItem.pickCover(w)
    item.monthStart = w.monthStart ?? 1
    item.dayStart = w.dayStart ?? 1
    return item
  }

  static make(
    id: string,
    title: string,
    season: string,
    monthStart: number,
    dayStart: number,
    summary: string,
    body: string,
    coverKey: string
  ): PhenologyItem {
    const item = new PhenologyItem()
    item.id = id
    item.title = title
    item.season = season
    item.monthStart = monthStart
    item.dayStart = dayStart
    item.summary = summary
    item.body = body
    item.coverKey = coverKey
    return item
  }
}

export class SkyEventItem {
  id: string = ''
  title: string = ''
  kind: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''

  static fromWire(w: SkyWire): SkyEventItem {
    const item = new SkyEventItem()
    item.id = w.id ?? ''
    item.title = w.title ?? ''
    item.kind = w.kind ?? ''
    item.subtitle = w.subtitle ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? w.description ?? ''
    item.coverKey = ConstellationItem.pickCover(w)
    return item
  }

  static make(
    id: string,
    title: string,
    kind: string,
    subtitle: string,
    summary: string,
    body: string,
    coverKey: string
  ): SkyEventItem {
    const item = new SkyEventItem()
    item.id = id
    item.title = title
    item.kind = kind
    item.subtitle = subtitle
    item.summary = summary
    item.body = body
    item.coverKey = coverKey
    return item
  }
}

export class JournalItem {
  id: string = ''
  dateLabel: string = ''
  body: string = ''
  tag: string = ''
  createdAt: number = 0
}

export class ReadingItem {
  id: string = ''
  kind: string = ''
  title: string = ''
  viewedAt: number = 0
}

export class FavoriteItem {
  id: string = ''
  kind: string = ''
}

export class MoonPhaseInfo {
  name: string = ''
  illumination: number = 0
  ageDays: number = 0
  hint: string = ''
}

export class SolarTermInfo {
  name: string = ''
  relation: string = ''
  line: string = ''
  phenologyId: string = ''
}
