import {
  Thought, ReadingRecord, KnowledgeCard, Spark, ThemeSpace, StudyLog,
  BowenStats, TimelineEvent, OrganizeHint, MonthlyBar, CatShare, YearReport, FeedItem, LabelOption
} from '../models/BowenModels'
import { BowenStore } from './BowenStore'
import { DateHelper } from './DateHelper'

export class BowenQuery {
  static async stats(): Promise<BowenStats> {
    const thoughts = await BowenStore.loadThoughts()
    const readings = await BowenStore.loadReadings()
    const cards = await BowenStore.loadCards()
    const studies = await BowenStore.loadStudyLogs()
    const sparks = await BowenStore.loadSparks()
    const themes = await BowenStore.loadThemes()
    const s = new BowenStats()
    s.thoughtCount = thoughts.length
    s.readingCount = readings.length
    s.cardCount = cards.length
    s.studyCount = studies.length
    s.sparkCount = sparks.length
    s.themeCount = themes.length
    s.favoriteCount = BowenQuery.countFav(thoughts, readings, cards, sparks)
    s.settledCount = BowenQuery.countSettled(cards)
    s.streakDays = await BowenStore.computeStreakDays()
    s.todayNewCount = BowenQuery.countTodayNew(cards, readings, studies)
    return s
  }

  static async recentFeed(limit: number): Promise<FeedItem[]> {
    const items: FeedItem[] = []
    const thoughts = await BowenStore.loadThoughts()
    for (const t of thoughts) {
      items.push(BowenQuery.feed('thought', t.id, t.title, t.body, LabelOption.labelOf(LabelOption.statuses(), t.status), t.updatedAt))
    }
    const readings = await BowenStore.loadReadings()
    for (const r of readings) {
      items.push(BowenQuery.feed('reading', r.id, r.title, r.myUnderstanding, LabelOption.labelOf(LabelOption.sources(), r.sourceType), r.updatedAt))
    }
    const cards = await BowenStore.loadCards()
    for (const c of cards) {
      items.push(BowenQuery.feed('card', c.id, c.title, c.content, '知识卡片', c.updatedAt))
    }
    const studies = await BowenStore.loadStudyLogs()
    for (const st of studies) {
      items.push(BowenQuery.feed('study', st.id, st.topic, st.summary.length > 0 ? st.summary : st.content, '学习记录', st.updatedAt))
    }
    const sparks = await BowenStore.loadSparks()
    for (const s of sparks) {
      items.push(BowenQuery.feed('spark', s.id, s.title, s.body, LabelOption.labelOf(LabelOption.sparkKinds(), s.kind), s.updatedAt))
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

  static async recall(): Promise<FeedItem | undefined> {
    const cards = await BowenStore.loadCards()
    const now = Date.now()
    const day = 86400000
    let bestCard: KnowledgeCard | undefined = undefined
    for (const c of cards) {
      if (now - c.createdAt < 90 * day) {
        continue
      }
      if (bestCard === undefined || c.createdAt < bestCard.createdAt) {
        bestCard = c
      }
    }
    if (bestCard !== undefined) {
      return BowenQuery.feed('card', bestCard.id, bestCard.title, bestCard.content, '知识卡片', bestCard.updatedAt)
    }
    for (const c of cards) {
      if (DateHelper.keyFromDate(new Date(c.createdAt)) !== DateHelper.todayKey()) {
        return BowenQuery.feed('card', c.id, c.title, c.content, '知识卡片', c.updatedAt)
      }
    }
    const thoughts = await BowenStore.loadThoughts()
    let bestThought: Thought | undefined = undefined
    for (const t of thoughts) {
      if (now - t.createdAt < 90 * day) {
        continue
      }
      if (bestThought === undefined || t.createdAt < bestThought.createdAt) {
        bestThought = t
      }
    }
    if (bestThought !== undefined) {
      return BowenQuery.feed('thought', bestThought.id, bestThought.title, bestThought.body,
        LabelOption.labelOf(LabelOption.statuses(), bestThought.status), bestThought.updatedAt)
    }
    for (const t of thoughts) {
      if (DateHelper.keyFromDate(new Date(t.createdAt)) !== DateHelper.todayKey()) {
        return BowenQuery.feed('thought', t.id, t.title, t.body,
          LabelOption.labelOf(LabelOption.statuses(), t.status), t.updatedAt)
      }
    }
    return undefined
  }

  static async timeline(): Promise<TimelineEvent[]> {
    const feed = await BowenQuery.recentFeed(80)
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
    const feed = await BowenQuery.recentFeed(400)
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
    const cards = await BowenStore.loadCards()
    const opts = LabelOption.categories()
    const out: CatShare[] = []
    for (const o of opts) {
      const s = new CatShare()
      s.key = o.key
      s.label = o.label
      s.count = 0
      for (const c of cards) {
        if (c.categoryKey === o.key) {
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
    const thoughts = await BowenStore.loadThoughts()
    const readings = await BowenStore.loadReadings()
    const cards = await BowenStore.loadCards()
    const sparks = await BowenStore.loadSparks()
    const themes = await BowenStore.loadThemes()
    r.thoughtCount = BowenQuery.countInYearTs(thoughts, year)
    r.readingCount = BowenQuery.countReadYear(readings, year)
    r.themeCount = themes.length
    r.favoriteCount = BowenQuery.countFav(thoughts, readings, cards, sparks)
    r.topTheme = '尚未创建专题'
    for (const th of themes) {
      r.topTheme = th.title
      break
    }
    r.topTag = await BowenQuery.topTag()
    r.highlightTitle = '还没有思考知识'
    for (const th of thoughts) {
      r.highlightTitle = th.title
      break
    }
    return r
  }

  static async organizeHints(): Promise<OrganizeHint[]> {
    const out: OrganizeHint[] = []
    const thoughts = await BowenStore.loadThoughts()
    const now = Date.now()
    const day = 86400000
    for (const t of thoughts) {
      if (t.categoryKey.length === 0) {
        out.push(BowenQuery.hint(`cat_${t.id}`, 'uncat', 'thought', t.id, t.title, '尚未分类，点此补上分类'))
      }
      if (t.tags.length === 0 && t.body.length > 40) {
        out.push(BowenQuery.hint(`tag_${t.id}`, 'tags', 'thought', t.id, t.title, '内容较长但还没有标签'))
      }
      if ((t.status === 'draft' || t.status === 'organizing') && now - t.updatedAt > 14 * day) {
        out.push(BowenQuery.hint(`stale_${t.id}`, 'stale', 'thought', t.id, t.title, '超过 14 天未整理'))
      }
      if (t.status === 'settled' && now - t.updatedAt > 60 * day) {
        out.push(BowenQuery.hint(`arc_${t.id}`, 'archive', 'thought', t.id, t.title, '建议珍藏或挂到专题'))
      }
    }
    return out
  }

  static async search(q: string): Promise<FeedItem[]> {
    const needle = q.trim()
    const feed = await BowenQuery.recentFeed(400)
    if (needle.length === 0) {
      return feed
    }
    const out: FeedItem[] = []
    for (const f of feed) {
      if (f.title.indexOf(needle) >= 0 || f.summary.indexOf(needle) >= 0 || f.meta.indexOf(needle) >= 0) {
        out.push(f)
      }
    }
    const thoughts = await BowenStore.loadThoughts()
    for (const t of thoughts) {
      if (BowenQuery.csvHas(t.tags, needle) && !BowenQuery.feedHas(out, t.id)) {
        out.push(BowenQuery.feed('thought', t.id, t.title, t.body, t.tags.join(' · '), t.updatedAt))
      }
    }
    return out
  }

  static async linkedToTheme(themeId: string): Promise<FeedItem[]> {
    const out: FeedItem[] = []
    const thoughts = await BowenStore.loadThoughts()
    for (const t of thoughts) {
      if (t.themeIds.includes(themeId)) {
        out.push(BowenQuery.feed('thought', t.id, t.title, t.body, LabelOption.labelOf(LabelOption.statuses(), t.status), t.updatedAt))
      }
    }
    const readings = await BowenStore.loadReadings()
    for (const r of readings) {
      if (r.themeIds.includes(themeId)) {
        out.push(BowenQuery.feed('reading', r.id, r.title, r.myUnderstanding, '阅读', r.updatedAt))
      }
    }
    const cards = await BowenStore.loadCards()
    for (const c of cards) {
      if (c.themeIds.includes(themeId)) {
        out.push(BowenQuery.feed('card', c.id, c.title, c.content, '卡片', c.updatedAt))
      }
    }
    const sparks = await BowenStore.loadSparks()
    for (const s of sparks) {
      if (s.themeIds.includes(themeId)) {
        out.push(BowenQuery.feed('spark', s.id, s.title, s.body, '灵感', s.updatedAt))
      }
    }
    out.sort((a, b) => b.ts - a.ts)
    return out
  }

  static async themeCount(themeId: string): Promise<number> {
    const list = await BowenQuery.linkedToTheme(themeId)
    return list.length
  }

  static async favorites(): Promise<FeedItem[]> {
    const out: FeedItem[] = []
    const thoughts = await BowenStore.loadThoughts()
    for (const t of thoughts) {
      if (t.favorite) {
        out.push(BowenQuery.feed('thought', t.id, t.title, t.body, '思考', t.updatedAt))
      }
    }
    const readings = await BowenStore.loadReadings()
    for (const r of readings) {
      if (r.favorite) {
        out.push(BowenQuery.feed('reading', r.id, r.title, r.myUnderstanding, '阅读', r.updatedAt))
      }
    }
    const cards = await BowenStore.loadCards()
    for (const c of cards) {
      if (BowenQuery.isCardFavorited(c)) {
        out.push(BowenQuery.feed('card', c.id, c.title, c.content, '卡片', c.updatedAt))
      }
    }
    const sparks = await BowenStore.loadSparks()
    for (const s of sparks) {
      if (s.favorite) {
        out.push(BowenQuery.feed('spark', s.id, s.title, s.body, '灵感', s.updatedAt))
      }
    }
    out.sort((a, b) => b.ts - a.ts)
    return out
  }

  static async unlockAchievements(): Promise<string[]> {
    const unlocked = await BowenStore.loadUnlocked()
    const s = await BowenQuery.stats()
    BowenQuery.ensureUnlock(unlocked, 'first_card', s.cardCount >= 1)
    BowenQuery.ensureUnlock(unlocked, 'reading_20', s.readingCount >= 20)
    BowenQuery.ensureUnlock(unlocked, 'favorite_100', s.favoriteCount >= 100)
    BowenQuery.ensureUnlock(unlocked, 'themes_5', s.themeCount >= 5)
    BowenQuery.ensureUnlock(unlocked, 'streak_30', s.streakDays >= 30)
    BowenQuery.ensureUnlock(unlocked, 'cards_50', s.cardCount >= 50)
    BowenQuery.ensureUnlock(unlocked, 'study_10', s.studyCount >= 10)
    await BowenStore.saveUnlocked(unlocked)
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
      if (BowenQuery.isCardFavorited(c)) {
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

  private static countSettled(cards: KnowledgeCard[]): number {
    let n = 0
    for (const c of cards) {
      if (c.status === 'settled' || c.status === 'treasured') {
        n++
      }
    }
    return n
  }

  private static countTodayNew(cards: KnowledgeCard[], readings: ReadingRecord[], studies: StudyLog[]): number {
    const today = DateHelper.todayKey()
    let n = 0
    for (const c of cards) {
      if (DateHelper.keyFromDate(new Date(c.createdAt)) === today) {
        n++
      }
    }
    for (const r of readings) {
      if (DateHelper.keyFromDate(new Date(r.createdAt)) === today) {
        n++
      }
    }
    for (const s of studies) {
      if (DateHelper.keyFromDate(new Date(s.createdAt)) === today) {
        n++
      }
    }
    return n
  }

  private static isCardFavorited(c: KnowledgeCard): boolean {
    return c.favoriteTier !== 'none' && c.favoriteTier.length > 0
  }

  private static nextFavoriteTier(current: string): string {
    if (current === 'none' || current.length === 0) {
      return 'todo'
    }
    if (current === 'todo') {
      return 'essence'
    }
    if (current === 'essence') {
      return 'important'
    }
    if (current === 'important') {
      return 'archive'
    }
    return 'none'
  }

  static favoriteTierLabel(tier: string): string {
    return LabelOption.labelOf(LabelOption.favoriteTiers(), tier)
  }

  static cycleFavoriteTier(current: string): string {
    return BowenQuery.nextFavoriteTier(current)
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
    const tags = await BowenStore.loadTags()
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
