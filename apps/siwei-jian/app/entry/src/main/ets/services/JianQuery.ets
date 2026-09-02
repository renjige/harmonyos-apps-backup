import {
  Thought, ReadingRecord, KnowledgeCard, Spark, ThemeSpace,
  JianStats, TimelineEvent, OrganizeHint, MonthlyBar, CatShare, YearReport, FeedItem, LabelOption
} from '../models/JianModels'
import { JianStore } from './JianStore'
import { DateHelper } from './DateHelper'

export class JianQuery {
  static async stats(): Promise<JianStats> {
    const thoughts = await JianStore.loadThoughts()
    const readings = await JianStore.loadReadings()
    const cards = await JianStore.loadCards()
    const sparks = await JianStore.loadSparks()
    const themes = await JianStore.loadThemes()
    const s = new JianStats()
    s.thoughtCount = thoughts.length
    s.readingCount = readings.length
    s.cardCount = cards.length
    s.sparkCount = sparks.length
    s.themeCount = themes.length
    s.favoriteCount = JianQuery.countFav(thoughts, readings, cards, sparks)
    s.settledCount = JianQuery.countSettled(thoughts)
    s.streakDays = await JianStore.computeStreakDays()
    return s
  }

  static async recentFeed(limit: number): Promise<FeedItem[]> {
    const items: FeedItem[] = []
    const thoughts = await JianStore.loadThoughts()
    for (const t of thoughts) {
      items.push(JianQuery.feed('thought', t.id, t.title, t.body, LabelOption.labelOf(LabelOption.statuses(), t.status), t.updatedAt))
    }
    const cards = await JianStore.loadCards()
    for (const c of cards) {
      items.push(JianQuery.feed('card', c.id, c.title, c.content, '观点卡片', c.updatedAt))
    }
    const sparks = await JianStore.loadSparks()
    for (const s of sparks) {
      items.push(JianQuery.feed('spark', s.id, s.title, s.body, LabelOption.labelOf(LabelOption.sparkKinds(), s.kind), s.updatedAt))
    }
    items.sort((a, b) => b.ts - a.ts)
    const out: FeedItem[] = []
    for (const it of items) {
      if (out.length < limit) {
        out.push(it)
      }
    }
    return out
  }

  static async recall(): Promise<Thought | undefined> {
    const thoughts = await JianStore.loadThoughts()
    const now = Date.now()
    const day = 86400000
    let best: Thought | undefined = undefined
    for (const t of thoughts) {
      if (now - t.createdAt < 90 * day) {
        continue
      }
      if (best === undefined || t.createdAt < best.createdAt) {
        best = t
      }
    }
    if (best !== undefined) {
      return best
    }
    for (const t of thoughts) {
      if (DateHelper.keyFromDate(new Date(t.createdAt)) !== DateHelper.todayKey()) {
        return t
      }
    }
    return undefined
  }

  static async timeline(): Promise<TimelineEvent[]> {
    const feed = await JianQuery.recentFeed(80)
    const out: TimelineEvent[] = []
    for (const f of feed) {
      const e = new TimelineEvent()
      e.id = f.id
      e.kind = f.kind
      e.title = f.title
      e.subtitle = f.meta
      e.ts = f.ts
      out.push(e)
    }
    return out
  }

  static async monthlyBars(): Promise<MonthlyBar[]> {
    const keys = DateHelper.lastNMonths(6)
    const feed = await JianQuery.recentFeed(400)
    const out: MonthlyBar[] = []
    for (const k of keys) {
      const b = new MonthlyBar()
      b.monthKey = k
      b.label = DateHelper.monthLabel(k)
      b.count = 0
      for (const f of feed) {
        if (DateHelper.monthKeyFromTs(f.ts) === k) {
          b.count++
        }
      }
      out.push(b)
    }
    return out
  }

  static async categoryShares(): Promise<CatShare[]> {
    const thoughts = await JianStore.loadThoughts()
    const opts = LabelOption.categories()
    const out: CatShare[] = []
    for (const o of opts) {
      const s = new CatShare()
      s.key = o.key
      s.label = o.label
      s.count = 0
      for (const t of thoughts) {
        if (t.categoryKey === o.key) {
          s.count++
        }
      }
      out.push(s)
    }
    return out
  }

  static async yearReport(): Promise<YearReport> {
    const year = `${new Date().getFullYear()}`
    const r = new YearReport()
    r.year = year
    const thoughts = await JianStore.loadThoughts()
    const readings = await JianStore.loadReadings()
    const cards = await JianStore.loadCards()
    const sparks = await JianStore.loadSparks()
    const themes = await JianStore.loadThemes()
    r.thoughtCount = JianQuery.countInYearTs(thoughts, year)
    r.sparkCount = JianQuery.countSparkInYear(sparks, year)
    r.themeCount = themes.length
    r.favoriteCount = JianQuery.countFav(thoughts, readings, cards, sparks)
    r.topTheme = '尚未创建主题'
    for (const th of themes) {
      r.topTheme = th.title
      break
    }
    r.topTag = await JianQuery.topTag()
    r.highlightTitle = '还没有思考记录'
    for (const th of thoughts) {
      r.highlightTitle = th.title
      break
    }
    return r
  }

  static async organizeHints(): Promise<OrganizeHint[]> {
    const out: OrganizeHint[] = []
    const thoughts = await JianStore.loadThoughts()
    const now = Date.now()
    const day = 86400000
    for (const t of thoughts) {
      if (t.categoryKey.length === 0) {
        out.push(JianQuery.hint(`cat_${t.id}`, 'uncat', 'thought', t.id, t.title, '尚未分类，点此补上分类'))
      }
      if (t.tags.length === 0 && t.body.length > 40) {
        out.push(JianQuery.hint(`tag_${t.id}`, 'tags', 'thought', t.id, t.title, '内容较长但还没有标签'))
      }
      if ((t.status === 'draft' || t.status === 'organizing') && now - t.updatedAt > 14 * day) {
        out.push(JianQuery.hint(`stale_${t.id}`, 'stale', 'thought', t.id, t.title, '超过 14 天未整理'))
      }
      if (t.status === 'settled' && now - t.updatedAt > 60 * day) {
        out.push(JianQuery.hint(`arc_${t.id}`, 'archive', 'thought', t.id, t.title, '建议珍藏或挂到主题'))
      }
    }
    return out
  }

  static async search(q: string): Promise<FeedItem[]> {
    const needle = q.trim()
    const feed = await JianQuery.recentFeed(400)
    if (needle.length === 0) {
      return feed
    }
    const out: FeedItem[] = []
    for (const f of feed) {
      if (f.title.indexOf(needle) >= 0 || f.summary.indexOf(needle) >= 0 || f.meta.indexOf(needle) >= 0) {
        out.push(f)
      }
    }
    const thoughts = await JianStore.loadThoughts()
    for (const t of thoughts) {
      if (JianQuery.csvHas(t.tags, needle) && !JianQuery.feedHas(out, t.id)) {
        out.push(JianQuery.feed('thought', t.id, t.title, t.body, t.tags.join(' · '), t.updatedAt))
      }
    }
    return out
  }

  static async linkedToTheme(themeId: string): Promise<FeedItem[]> {
    const out: FeedItem[] = []
    const thoughts = await JianStore.loadThoughts()
    for (const t of thoughts) {
      if (t.themeIds.includes(themeId)) {
        out.push(JianQuery.feed('thought', t.id, t.title, t.body, LabelOption.labelOf(LabelOption.statuses(), t.status), t.updatedAt))
      }
    }
    const readings = await JianStore.loadReadings()
    for (const r of readings) {
      if (r.themeIds.includes(themeId)) {
        out.push(JianQuery.feed('reading', r.id, r.title, r.myUnderstanding, '阅读', r.updatedAt))
      }
    }
    const cards = await JianStore.loadCards()
    for (const c of cards) {
      if (c.themeIds.includes(themeId)) {
        out.push(JianQuery.feed('card', c.id, c.title, c.content, '卡片', c.updatedAt))
      }
    }
    const sparks = await JianStore.loadSparks()
    for (const s of sparks) {
      if (s.themeIds.includes(themeId)) {
        out.push(JianQuery.feed('spark', s.id, s.title, s.body, '灵感', s.updatedAt))
      }
    }
    out.sort((a, b) => b.ts - a.ts)
    return out
  }

  static async themeCount(themeId: string): Promise<number> {
    const list = await JianQuery.linkedToTheme(themeId)
    return list.length
  }

  static async favorites(): Promise<FeedItem[]> {
    const out: FeedItem[] = []
    const thoughts = await JianStore.loadThoughts()
    for (const t of thoughts) {
      if (t.favorite) {
        out.push(JianQuery.feed('thought', t.id, t.title, t.body, '思考', t.updatedAt))
      }
    }
    const readings = await JianStore.loadReadings()
    for (const r of readings) {
      if (r.favorite) {
        out.push(JianQuery.feed('reading', r.id, r.title, r.myUnderstanding, '阅读', r.updatedAt))
      }
    }
    const cards = await JianStore.loadCards()
    for (const c of cards) {
      if (c.favorite) {
        out.push(JianQuery.feed('card', c.id, c.title, c.content, '卡片', c.updatedAt))
      }
    }
    const sparks = await JianStore.loadSparks()
    for (const s of sparks) {
      if (s.favorite) {
        out.push(JianQuery.feed('spark', s.id, s.title, s.body, '灵感', s.updatedAt))
      }
    }
    out.sort((a, b) => b.ts - a.ts)
    return out
  }

  static async unlockAchievements(): Promise<string[]> {
    const unlocked = await JianStore.loadUnlocked()
    const s = await JianQuery.stats()
    JianQuery.ensureUnlock(unlocked, 'first_thought', s.thoughtCount >= 1)
    JianQuery.ensureUnlock(unlocked, 'spark_50', s.sparkCount >= 50)
    JianQuery.ensureUnlock(unlocked, 'favorite_50', s.favoriteCount >= 50)
    JianQuery.ensureUnlock(unlocked, 'themes_10', s.themeCount >= 10)
    JianQuery.ensureUnlock(unlocked, 'streak_30', s.streakDays >= 30)
    JianQuery.ensureUnlock(unlocked, 'cards_5', s.cardCount >= 5)
    JianQuery.ensureUnlock(unlocked, 'settled_10', s.settledCount >= 10)
    await JianStore.saveUnlocked(unlocked)
    return unlocked
  }

  private static ensureUnlock(ids: string[], id: string, ok: boolean): void {
    if (ok && !ids.includes(id)) {
      ids.push(id)
    }
  }

  private static countFav(thoughts: Thought[], readings: ReadingRecord[], cards: KnowledgeCard[], sparks: Spark[]): number {
    let n = 0
    for (const t of thoughts) {
      if (t.favorite) {
        n++
      }
    }
    for (const r of readings) {
      if (r.favorite) {
        n++
      }
    }
    for (const c of cards) {
      if (c.favorite) {
        n++
      }
    }
    for (const s of sparks) {
      if (s.favorite) {
        n++
      }
    }
    return n
  }

  private static countSettled(thoughts: Thought[]): number {
    let n = 0
    for (const t of thoughts) {
      if (t.status === 'settled' || t.status === 'treasured') {
        n++
      }
    }
    return n
  }

  private static countInYearTs(thoughts: Thought[], year: string): number {
    let n = 0
    for (const t of thoughts) {
      if (`${new Date(t.createdAt).getFullYear()}` === year) {
        n++
      }
    }
    return n
  }

  private static countSparkInYear(sparks: Spark[], year: string): number {
    let n = 0
    for (const s of sparks) {
      if (`${new Date(s.createdAt).getFullYear()}` === year) {
        n++
      }
    }
    return n
  }

  private static countReadYear(readings: ReadingRecord[], year: string): number {
    let n = 0
    for (const r of readings) {
      if (DateHelper.yearFromKey(r.readAt) === year || (r.readAt.length === 0 && `${new Date(r.createdAt).getFullYear()}` === year)) {
        n++
      }
    }
    return n
  }

  private static async topTag(): Promise<string> {
    const tags = await JianStore.loadTags()
    for (const t of tags) {
      return t
    }
    return '暂无标签'
  }

  private static feed(kind: string, id: string, title: string, summary: string, meta: string, ts: number): FeedItem {
    const f = new FeedItem()
    f.kind = kind
    f.id = id
    f.title = title
    f.summary = summary
    f.meta = meta
    f.ts = ts
    return f
  }

  private static hint(id: string, kind: string, entityKind: string, entityId: string, title: string, message: string): OrganizeHint {
    const h = new OrganizeHint()
    h.id = id
    h.kind = kind
    h.entityKind = entityKind
    h.entityId = entityId
    h.title = title
    h.message = message
    return h
  }

  private static csvHas(tags: string[], needle: string): boolean {
    for (const t of tags) {
      if (t.indexOf(needle) >= 0) {
        return true
      }
    }
    return false
  }

  private static feedHas(list: FeedItem[], id: string): boolean {
    for (const f of list) {
      if (f.id === id) {
        return true
      }
    }
    return false
  }
}
