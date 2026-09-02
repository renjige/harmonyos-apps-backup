import {
  ArchiveStats, AchievementDef, YearbookData, TimelineEvent, Narrative, SparkItem, ThemeSpace
} from '../models/XingyuModels'
import { XingyuStore } from './XingyuStore'
import { DateHelper } from './DateHelper'

export class XingyuStats {
  static async snapshot(): Promise<ArchiveStats> {
    const s = new ArchiveStats()
    const ns = await XingyuStore.loadNarratives()
    const sps = await XingyuStore.loadSparks()
    const th = await XingyuStore.loadThemes()
    const fv = await XingyuStore.loadFavorites()
    s.narrativeCount = ns.length
    s.sparkCount = sps.length
    s.themeCount = th.length
    s.favoriteCount = fv.length
    s.streakDays = XingyuStats.streak(ns, sps)
    return s
  }

  static streak(ns: Narrative[], sps: SparkItem[]): number {
    const set: string[] = []
    for (const n of ns) {
      if (!XingyuStats.hasKey(set, n.dateKey)) {
        set.push(n.dateKey)
      }
    }
    for (const s of sps) {
      if (!XingyuStats.hasKey(set, s.dateKey)) {
        set.push(s.dateKey)
      }
    }
    let cursor = DateHelper.todayKey()
    if (!XingyuStats.hasKey(set, cursor)) {
      cursor = DateHelper.daysAgoKey(1)
    }
    let days = 0
    while (XingyuStats.hasKey(set, cursor)) {
      days++
      cursor = XingyuStats.prevDay(cursor)
    }
    return days
  }

  static async achievements(): Promise<AchievementDef[]> {
    const snap = await XingyuStats.snapshot()
    const year = await XingyuStats.yearbook(DateHelper.currentYear())
    const out: AchievementDef[] = []
    out.push(AchievementDef.make('first', '第一颗星光', '留下第一条叙事或灵感', snap.narrativeCount + snap.sparkCount >= 1))
    out.push(AchievementDef.make('streak7', '连续记录 7 天', '连续 7 天留下内容', snap.streakDays >= 7))
    out.push(AchievementDef.make('fav50', '收藏 50 条', '星光收藏达到 50', snap.favoriteCount >= 50))
    out.push(AchievementDef.make('theme10', '创建 10 个主题', '主题空间达到 10', snap.themeCount >= 10))
    out.push(AchievementDef.make('year', '完成年册', '本年至少 5 条叙事可生成年册', year.narrativeCount >= 5))
    return out
  }

  static async yearbook(year: string): Promise<YearbookData> {
    const data = new YearbookData()
    data.year = year
    const ns = await XingyuStore.loadNarratives()
    const sps = await XingyuStore.loadSparks()
    const th = await XingyuStore.loadThemes()
    const fv = await XingyuStore.loadFavorites()
    const tagHits: string[] = []
    for (const n of ns) {
      if (DateHelper.yearFromKey(n.dateKey) === year) {
        data.narrativeCount++
        for (const t of n.tags) {
          tagHits.push(t)
        }
        if (data.highlightTitle.length === 0 && (n.status === 'treasure' || n.status === 'important' || n.status === 'memory')) {
          data.highlightTitle = n.title
          data.highlightId = n.id
        }
      }
    }
    if (data.highlightTitle.length === 0) {
      for (const n of ns) {
        if (DateHelper.yearFromKey(n.dateKey) === year) {
          data.highlightTitle = n.title
          data.highlightId = n.id
          break
        }
      }
    }
    for (const s of sps) {
      if (DateHelper.yearFromKey(s.dateKey) === year) {
        data.sparkCount++
      }
    }
    for (const t of th) {
      if (DateHelper.yearFromKey(DateHelper.keyFromDate(new Date(t.createdAt))) === year) {
        data.themeCount++
      }
    }
    data.favoriteCount = fv.length
    data.topTag = XingyuStats.mostCommon(tagHits)
    data.topTheme = await XingyuStats.topThemeName(ns, th, year)
    return data
  }

  static async timeline(): Promise<TimelineEvent[]> {
    const out: TimelineEvent[] = []
    const ns = await XingyuStore.loadNarratives()
    const sps = await XingyuStore.loadSparks()
    const th = await XingyuStore.loadThemes()
    for (const n of ns) {
      const e = new TimelineEvent()
      e.id = `tn_${n.id}`
      e.dateKey = n.dateKey
      e.kind = 'narrative'
      e.title = n.title
      e.targetId = n.id
      e.createdAt = n.createdAt
      out.push(e)
    }
    for (const s of sps) {
      const e = new TimelineEvent()
      e.id = `ts_${s.id}`
      e.dateKey = s.dateKey
      e.kind = 'spark'
      e.title = s.title
      e.targetId = s.id
      e.createdAt = s.createdAt
      out.push(e)
    }
    for (const t of th) {
      const e = new TimelineEvent()
      e.id = `tt_${t.id}`
      e.dateKey = DateHelper.keyFromDate(new Date(t.createdAt))
      e.kind = 'theme'
      e.title = `创建主题「${t.title}」`
      e.targetId = t.id
      e.createdAt = t.createdAt
      out.push(e)
    }
    out.sort((a, b) => {
      if (a.dateKey === b.dateKey) {
        return b.createdAt - a.createdAt
      }
      return a.dateKey > b.dateKey ? -1 : 1
    })
    return out
  }

  static async recallToday(): Promise<Narrative | undefined> {
    const keys: string[] = []
    keys.push(DateHelper.yearsAgoSameDay(1))
    keys.push(DateHelper.daysAgoKey(90))
    keys.push(DateHelper.daysAgoKey(30))
    const ns = await XingyuStore.loadNarratives()
    for (const k of keys) {
      for (const n of ns) {
        if (n.dateKey === k) {
          return n
        }
      }
    }
    for (const n of ns) {
      if (n.status === 'memory' || n.status === 'treasure') {
        return n
      }
    }
    return undefined
  }

  private static async topThemeName(ns: Narrative[], th: ThemeSpace[], year: string): Promise<string> {
    const counts: string[] = []
    for (const n of ns) {
      if (DateHelper.yearFromKey(n.dateKey) !== year) {
        continue
      }
      for (const id of n.themeIds) {
        counts.push(id)
      }
    }
    const topId = XingyuStats.mostCommon(counts)
    for (const t of th) {
      if (t.id === topId) {
        return t.title
      }
    }
    return ''
  }

  private static mostCommon(items: string[]): string {
    if (items.length === 0) {
      return ''
    }
    let best = items[0]
    let bestN = 0
    for (const x of items) {
      let n = 0
      for (const y of items) {
        if (y === x) {
          n++
        }
      }
      if (n > bestN) {
        bestN = n
        best = x
      }
    }
    return best
  }

  private static hasKey(set: string[], key: string): boolean {
    for (const s of set) {
      if (s === key) {
        return true
      }
    }
    return false
  }

  private static prevDay(key: string): string {
    const d = DateHelper.parseKey(key)
    d.setDate(d.getDate() - 1)
    return DateHelper.keyFromDate(d)
  }
}
