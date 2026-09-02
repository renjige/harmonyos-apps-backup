import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  XdCategory, XdClip, XdDateUtil, XdEntry, XdLookbackItem, XdMemoryAlbumItem,
  XdMoodLog, XdProfile, XdStats, XdTheme, XdTimelineRow, XdTidySuggestion,
  XdWishItem, XdYearArchive
} from '../models/XdModels'
import { AppContextService } from './AppContextService'

const STORE = 'xiaodao_manji_v1'
const KEY_ENTRIES = 'entries'
const KEY_CLIPS = 'clips'
const KEY_THEMES = 'themes'
const KEY_CATS = 'categories'
const KEY_TAGS = 'tags'
const KEY_PROFILE = 'profile'
const KEY_ACTIVITY = 'activity'
const KEY_UNLOCKED = 'unlocked'
const KEY_MOODS = 'moods'
const KEY_WISHES = 'wishes'

export class XdStore {
  private static pref: preferences.Preferences | null = null
  /** 同进程读写缓存：避免 Preferences 未就绪时 put 静默失败、首页一直读到空 */
  private static mem: Map<string, string> = new Map()

  static bump(): void {
    const rev = (AppStorage.get<number>('xdDataRev') ?? 0) + 1
    if (!AppStorage.set('xdDataRev', rev)) {
      AppStorage.setOrCreate('xdDataRev', rev)
    }
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    AppContextService.setContext(context)
    try {
      XdStore.pref = await preferences.getPreferences(context, STORE)
      await XdStore.hydrateMemFromPref()
    } catch {
      XdStore.pref = null
    }
    const cats = await XdStore.loadCategories()
    if (cats.length === 0) {
      await XdStore.persistCategories(XdCategory.defaults())
    }
  }

  private static async hydrateMemFromPref(): Promise<void> {
    if (XdStore.pref === null) {
      return
    }
    const keys: string[] = [
      KEY_ENTRIES, KEY_CLIPS, KEY_THEMES, KEY_CATS, KEY_TAGS,
      KEY_PROFILE, KEY_ACTIVITY, KEY_UNLOCKED, KEY_MOODS, KEY_WISHES
    ]
    for (const key of keys) {
      try {
        const v = await XdStore.pref.get(key, '')
        if (typeof v === 'string') {
          XdStore.mem.set(key, v)
        }
      } catch {
        // ignore single-key hydrate failure
      }
    }
  }

  private static async ensurePref(): Promise<boolean> {
    if (XdStore.pref !== null) {
      return true
    }
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      return false
    }
    try {
      XdStore.pref = await preferences.getPreferences(ctx, STORE)
      await XdStore.hydrateMemFromPref()
      return true
    } catch {
      XdStore.pref = null
      return false
    }
  }

  static async loadEntries(): Promise<XdEntry[]> {
    return XdStore.parseEntries(await XdStore.getString(KEY_ENTRIES, ''))
  }

  static async findEntry(id: string): Promise<XdEntry | undefined> {
    const list = await XdStore.loadEntries()
    for (const e of list) {
      if (e.id === id) {
        return e
      }
    }
    return undefined
  }

  static async saveEntry(entry: XdEntry): Promise<void> {
    entry.updatedAt = Date.now()
    const list = await XdStore.loadEntries()
    let found = false
    const next: XdEntry[] = []
    for (const e of list) {
      if (e.id === entry.id) {
        next.push(entry)
        found = true
      } else {
        next.push(e)
      }
    }
    if (!found) {
      next.push(entry)
    }
    await XdStore.persistEntries(next)
    await XdStore.recordActivity(entry.dateKey)
    await XdStore.checkAchievements()
    XdStore.bump()
  }

  static async deleteEntry(id: string): Promise<void> {
    const list = await XdStore.loadEntries()
    const next: XdEntry[] = []
    for (const e of list) {
      if (e.id !== id) {
        next.push(e)
      }
    }
    await XdStore.persistEntries(next)
    XdStore.bump()
  }

  static async loadClips(): Promise<XdClip[]> {
    return XdStore.parseClips(await XdStore.getString(KEY_CLIPS, ''))
  }

  static async findClip(id: string): Promise<XdClip | undefined> {
    const list = await XdStore.loadClips()
    for (const c of list) {
      if (c.id === id) {
        return c
      }
    }
    return undefined
  }

  static async saveClip(clip: XdClip): Promise<void> {
    const list = await XdStore.loadClips()
    let found = false
    const next: XdClip[] = []
    for (const c of list) {
      if (c.id === clip.id) {
        next.push(clip)
        found = true
      } else {
        next.push(c)
      }
    }
    if (!found) {
      next.push(clip)
    }
    await XdStore.persistClips(next)
    await XdStore.recordActivity(clip.dateKey)
    await XdStore.checkAchievements()
    XdStore.bump()
  }

  static async deleteClip(id: string): Promise<void> {
    const list = await XdStore.loadClips()
    const next: XdClip[] = []
    for (const c of list) {
      if (c.id !== id) {
        next.push(c)
      }
    }
    await XdStore.persistClips(next)
    XdStore.bump()
  }

  static async loadThemes(): Promise<XdTheme[]> {
    return XdStore.parseThemes(await XdStore.getString(KEY_THEMES, ''))
  }

  static async findTheme(id: string): Promise<XdTheme | undefined> {
    const list = await XdStore.loadThemes()
    for (const t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async saveTheme(theme: XdTheme): Promise<void> {
    theme.updatedAt = Date.now()
    const list = await XdStore.loadThemes()
    let found = false
    const next: XdTheme[] = []
    for (const t of list) {
      if (t.id === theme.id) {
        next.push(theme)
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(theme)
    }
    await XdStore.persistThemes(next)
    await XdStore.checkAchievements()
    XdStore.bump()
  }

  static async deleteTheme(id: string): Promise<void> {
    const list = await XdStore.loadThemes()
    const next: XdTheme[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    await XdStore.persistThemes(next)
    const entries = await XdStore.loadEntries()
    for (const e of entries) {
      e.themeCsv = XdStore.removeId(e.themeCsv, id)
    }
    await XdStore.persistEntries(entries)
    const clips = await XdStore.loadClips()
    for (const c of clips) {
      c.themeCsv = XdStore.removeId(c.themeCsv, id)
    }
    await XdStore.persistClips(clips)
    XdStore.bump()
  }

  static async entriesForTheme(themeId: string): Promise<XdEntry[]> {
    const list = await XdStore.loadEntries()
    const out: XdEntry[] = []
    for (const e of list) {
      if (XdStore.csvHas(e.themeCsv, themeId)) {
        out.push(e)
      }
    }
    return out
  }

  static async clipsForTheme(themeId: string): Promise<XdClip[]> {
    const list = await XdStore.loadClips()
    const out: XdClip[] = []
    for (const c of list) {
      if (XdStore.csvHas(c.themeCsv, themeId)) {
        out.push(c)
      }
    }
    return out
  }

  static async loadCategories(): Promise<XdCategory[]> {
    return XdStore.parseCategories(await XdStore.getString(KEY_CATS, ''))
  }

  static async saveCategory(cat: XdCategory): Promise<void> {
    const list = await XdStore.loadCategories()
    let found = false
    const next: XdCategory[] = []
    for (const c of list) {
      if (c.key === cat.key) {
        next.push(cat)
        found = true
      } else {
        next.push(c)
      }
    }
    if (!found) {
      next.push(cat)
    }
    await XdStore.persistCategories(next)
    XdStore.bump()
  }

  static async deleteCategory(key: string): Promise<void> {
    if (key === 'daily') {
      return
    }
    const list = await XdStore.loadCategories()
    const next: XdCategory[] = []
    for (const c of list) {
      if (c.key !== key) {
        next.push(c)
      }
    }
    await XdStore.persistCategories(next)
    XdStore.bump()
  }

  static categoryLabel(key: string, cats: XdCategory[]): string {
    for (const c of cats) {
      if (c.key === key) {
        return c.label
      }
    }
    return '日常'
  }

  static async loadTags(): Promise<string[]> {
    const raw = await XdStore.getString(KEY_TAGS, '')
    if (raw.length === 0) {
      return ['温暖', '成长', '灵感', '回忆', '计划', '收藏', '重要']
    }
    return XdStore.splitLines(raw)
  }

  static async saveTags(tags: string[]): Promise<void> {
    await XdStore.putString(KEY_TAGS, tags.join('\n'))
    XdStore.bump()
  }

  static async loadProfile(): Promise<XdProfile> {
    const raw = await XdStore.getString(KEY_PROFILE, '')
    const p = new XdProfile()
    if (raw.length === 0) {
      return p
    }
    const parts = raw.split('\t')
    if (parts.length >= 1 && parts[0].length > 0) {
      p.nickname = parts[0]
    }
    if (parts.length >= 2 && parts[1].length > 0) {
      p.themeMode = parts[1]
    }
    return p
  }

  static async saveProfile(p: XdProfile): Promise<void> {
    await XdStore.putString(KEY_PROFILE, `${p.nickname}\t${p.themeMode}`)
    XdStore.bump()
  }

  static async computeStats(): Promise<XdStats> {
    const s = new XdStats()
    const entries = await XdStore.loadEntries()
    const clips = await XdStore.loadClips()
    const themes = await XdStore.loadThemes()
    s.entryCount = entries.length
    s.clipCount = clips.length
    s.themeCount = themes.length
    for (const e of entries) {
      if (e.status === 'inbox') {
        s.inboxCount++
      }
      if (e.status === 'treasure') {
        s.treasureCount++
      }
    }
    for (const c of clips) {
      if (c.treasured) {
        s.treasureCount++
      }
    }
    s.streakDays = await XdStore.computeStreak()
    return s
  }

  static async recentEntries(limit: number): Promise<XdEntry[]> {
    const list = await XdStore.loadEntries()
    list.sort((a: XdEntry, b: XdEntry) => b.updatedAt - a.updatedAt)
    const out: XdEntry[] = []
    for (const e of list) {
      if (out.length >= limit) {
        break
      }
      out.push(e)
    }
    return out
  }

  static async buildTimeline(): Promise<XdTimelineRow[]> {
    const rows: XdTimelineRow[] = []
    const entries = await XdStore.loadEntries()
    for (const e of entries) {
      const r = new XdTimelineRow()
      r.id = e.id
      r.kind = 'entry'
      r.dateKey = e.dateKey
      r.title = e.title
      r.subtitle = e.summaryText()
      rows.push(r)
    }
    const clips = await XdStore.loadClips()
    for (const c of clips) {
      const r = new XdTimelineRow()
      r.id = c.id
      r.kind = 'clip'
      r.dateKey = c.dateKey
      r.title = c.text
      r.subtitle = '瞬间收藏'
      rows.push(r)
    }
    rows.sort((a: XdTimelineRow, b: XdTimelineRow) => b.dateKey.localeCompare(a.dateKey))
    return rows
  }

  static async buildLookback(): Promise<XdLookbackItem> {
    const item = new XdLookbackItem()
    const yearKey = XdDateUtil.yearsAgoKey(1)
    const threeKey = XdDateUtil.daysAgoKey(90)
    const entries = await XdStore.loadEntries()
    for (const e of entries) {
      if (e.dateKey === yearKey) {
        item.title = '一年前今天'
        item.body = `你写下了「${e.title}」。`
        item.dateKey = e.dateKey
        item.sourceKind = 'entry'
        item.sourceId = e.id
        return item
      }
    }
    for (const e of entries) {
      if (e.dateKey === threeKey) {
        item.title = '三个月前'
        item.body = `你记录过「${e.title}」。`
        item.dateKey = e.dateKey
        item.sourceKind = 'entry'
        item.sourceId = e.id
        return item
      }
    }
    for (const e of entries) {
      if (e.status === 'treasure') {
        item.title = '曾经珍藏'
        item.body = e.title
        item.dateKey = e.dateKey
        item.sourceKind = 'entry'
        item.sourceId = e.id
        return item
      }
    }
    const clips = await XdStore.loadClips()
    for (const c of clips) {
      if (c.treasured) {
        item.title = '曾经珍藏'
        item.body = c.text
        item.dateKey = c.dateKey
        item.sourceKind = 'clip'
        item.sourceId = c.id
        return item
      }
    }
    item.title = '时光回望'
    item.body = '写下第一条片段后，这里会按本机日期回看往日记录。'
    return item
  }

  static async buildYearArchive(year: string): Promise<XdYearArchive> {
    const y = new XdYearArchive()
    y.year = year
    const entries = await XdStore.loadEntries()
    const clips = await XdStore.loadClips()
    const themes = await XdStore.loadThemes()
    const themeHits: string[] = []
    const tagHits: string[] = []
    for (const e of entries) {
      if (XdDateUtil.yearFromKey(e.dateKey) === year) {
        y.entryCount++
        if (y.highlightTitle.length === 0 && (e.status === 'treasure' || e.status === 'important')) {
          y.highlightTitle = e.title
        }
        const tids = XdStore.splitCsv(e.themeCsv)
        for (const id of tids) {
          themeHits.push(id)
        }
        const tags = XdStore.splitCsv(e.tagCsv)
        for (const t of tags) {
          tagHits.push(t)
        }
      }
    }
    for (const c of clips) {
      if (XdDateUtil.yearFromKey(c.dateKey) === year) {
        y.clipCount++
      }
    }
    y.themeCount = themes.length
    y.topTheme = XdStore.mostFrequent(themeHits)
    y.topTag = XdStore.mostFrequent(tagHits)
    if (y.highlightTitle.length === 0 && entries.length > 0) {
      y.highlightTitle = entries[0].title
    }
    return y
  }

  static async monthCounts(n: number): Promise<number[]> {
    const keys = XdDateUtil.lastNMonths(n)
    const counts: number[] = []
    for (let i = 0; i < keys.length; i++) {
      counts.push(0)
    }
    const entries = await XdStore.loadEntries()
    for (const e of entries) {
      if (e.dateKey.length >= 7) {
        const mk = e.dateKey.substring(0, 7)
        for (let i = 0; i < keys.length; i++) {
          if (keys[i] === mk) {
            counts[i] = counts[i] + 1
          }
        }
      }
    }
    return counts
  }

  static async categoryCounts(): Promise<XdCategory[]> {
    return XdStore.loadCategories()
  }

  static async countByCategory(key: string): Promise<number> {
    const list = await XdStore.loadEntries()
    let n = 0
    for (const e of list) {
      if (e.categoryKey === key) {
        n++
      }
    }
    return n
  }

  static async loadUnlocked(): Promise<string[]> {
    return XdStore.splitCsv(await XdStore.getString(KEY_UNLOCKED, ''))
  }

  static async searchAll(q: string): Promise<XdTimelineRow[]> {
    const needle = q.trim()
    const rows = await XdStore.buildTimeline()
    if (needle.length === 0) {
      return rows
    }
    const out: XdTimelineRow[] = []
    for (const r of rows) {
      if (r.title.indexOf(needle) >= 0 || r.subtitle.indexOf(needle) >= 0 || r.dateKey.indexOf(needle) >= 0) {
        out.push(r)
      }
    }
    const entries = await XdStore.loadEntries()
    for (const e of entries) {
      if (e.tagCsv.indexOf(needle) >= 0 || e.categoryKey.indexOf(needle) >= 0 || e.body.indexOf(needle) >= 0) {
        let already = false
        for (const r of out) {
          if (r.id === e.id) {
            already = true
          }
        }
        if (!already) {
          const row = new XdTimelineRow()
          row.id = e.id
          row.kind = 'entry'
          row.dateKey = e.dateKey
          row.title = e.title
          row.subtitle = e.summaryText()
          out.push(row)
        }
      }
    }
    return out
  }

  static async countInbox(): Promise<number> {
    const entries = await XdStore.loadEntries()
    let n = 0
    for (const e of entries) {
      if (e.status === 'inbox') {
        n++
      }
    }
    return n
  }

  static async buildTidySuggestions(): Promise<XdTidySuggestion[]> {
    const out: XdTidySuggestion[] = []
    const inbox = await XdStore.countInbox()
    if (inbox > 0) {
      const s = new XdTidySuggestion()
      s.id = 'tidy_inbox'
      s.title = `整理 ${inbox} 条待整理慢记`
      s.hint = '为待整理条目设定分类或归入主题岛'
      s.actionKind = 'journal_inbox'
      out.push(s)
    }
    const entries = await XdStore.loadEntries()
    for (const e of entries) {
      if (e.status === 'inbox' && e.themeCsv.length === 0 && out.length < 5) {
        const s = new XdTidySuggestion()
        s.id = `tidy_${e.id}`
        s.title = `「${e.title}」可归入主题岛`
        s.hint = '打开慢记详情，关联一个主题岛'
        s.actionKind = 'entry'
        s.targetId = e.id
        out.push(s)
      }
    }
    const themes = await XdStore.loadThemes()
    if (themes.length === 0 && entries.length >= 3) {
      const s = new XdTidySuggestion()
      s.id = 'tidy_theme'
      s.title = '创建第一座主题岛'
      s.hint = '把相关慢记与瞬间收藏归拢到同一主题'
      s.actionKind = 'theme_new'
      out.push(s)
    }
    return out
  }

  static async buildMemoryAlbum(monthKey: string): Promise<XdMemoryAlbumItem[]> {
    const out: XdMemoryAlbumItem[] = []
    const entries = await XdStore.loadEntries()
    for (const e of entries) {
      if (e.dateKey.length >= 7 && e.dateKey.substring(0, 7) === monthKey) {
        const item = new XdMemoryAlbumItem()
        item.id = e.id
        item.kind = 'entry'
        item.dateKey = e.dateKey
        item.title = e.title
        item.subtitle = e.summaryText()
        out.push(item)
      }
    }
    const clips = await XdStore.loadClips()
    for (const c of clips) {
      if (c.dateKey.length >= 7 && c.dateKey.substring(0, 7) === monthKey) {
        const item = new XdMemoryAlbumItem()
        item.id = c.id
        item.kind = 'clip'
        item.dateKey = c.dateKey
        item.title = c.text
        item.subtitle = '瞬间收藏'
        out.push(item)
      }
    }
    out.sort((a: XdMemoryAlbumItem, b: XdMemoryAlbumItem) => b.dateKey.localeCompare(a.dateKey))
    return out
  }

  static async loadMoodLogs(): Promise<XdMoodLog[]> {
    return XdStore.parseMoodLogs(await XdStore.getString(KEY_MOODS, ''))
  }

  static async moodForDate(dateKey: string): Promise<XdMoodLog | undefined> {
    const list = await XdStore.loadMoodLogs()
    for (const m of list) {
      if (m.dateKey === dateKey) {
        return m
      }
    }
    return undefined
  }

  static async moodForToday(): Promise<XdMoodLog | undefined> {
    return XdStore.moodForDate(XdDateUtil.todayKey())
  }

  static async saveMoodLog(log: XdMoodLog): Promise<void> {
    const list = await XdStore.loadMoodLogs()
    let found = false
    const next: XdMoodLog[] = []
    for (const m of list) {
      if (m.dateKey === log.dateKey) {
        next.push(log)
        found = true
      } else {
        next.push(m)
      }
    }
    if (!found) {
      next.push(log)
    }
    await XdStore.persistMoodLogs(next)
    await XdStore.recordActivity(log.dateKey)
    XdStore.bump()
  }

  static async loadWishes(): Promise<XdWishItem[]> {
    return XdStore.parseWishes(await XdStore.getString(KEY_WISHES, ''))
  }

  static async findWish(id: string): Promise<XdWishItem | undefined> {
    const list = await XdStore.loadWishes()
    for (const w of list) {
      if (w.id === id) {
        return w
      }
    }
    return undefined
  }

  static async saveWish(wish: XdWishItem): Promise<void> {
    const list = await XdStore.loadWishes()
    let found = false
    const next: XdWishItem[] = []
    for (const w of list) {
      if (w.id === wish.id) {
        next.push(wish)
        found = true
      } else {
        next.push(w)
      }
    }
    if (!found) {
      next.push(wish)
    }
    await XdStore.persistWishes(next)
    XdStore.bump()
  }

  static async deleteWish(id: string): Promise<void> {
    const list = await XdStore.loadWishes()
    const next: XdWishItem[] = []
    for (const w of list) {
      if (w.id !== id) {
        next.push(w)
      }
    }
    await XdStore.persistWishes(next)
    XdStore.bump()
  }

  static async exportJson(): Promise<string> {
    const entries = await XdStore.loadEntries()
    const clips = await XdStore.loadClips()
    const themes = await XdStore.loadThemes()
    let s = '{"app":"小岛慢记","entries":['
    let first = true
    for (const e of entries) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${e.id}","title":"${XdStore.esc(e.title)}","date":"${e.dateKey}","status":"${e.status}"}`
    }
    s += '],"clips":['
    first = true
    for (const c of clips) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${c.id}","text":"${XdStore.esc(c.text)}"}`
    }
    s += '],"themes":['
    first = true
    for (const t of themes) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${t.id}","title":"${XdStore.esc(t.title)}"}`
    }
    s += ']}'
    return s
  }

  static async clearAll(): Promise<void> {
    await XdStore.putString(KEY_ENTRIES, '')
    await XdStore.putString(KEY_CLIPS, '')
    await XdStore.putString(KEY_THEMES, '')
    await XdStore.putString(KEY_ACTIVITY, '')
    await XdStore.putString(KEY_UNLOCKED, '')
    await XdStore.putString(KEY_MOODS, '')
    await XdStore.putString(KEY_WISHES, '')
    await XdStore.persistCategories(XdCategory.defaults())
    XdStore.bump()
  }

  private static async checkAchievements(): Promise<void> {
    const unlocked = await XdStore.loadUnlocked()
    const stats = await XdStore.computeStats()
    const add: string[] = []
    if (stats.entryCount >= 1) {
      add.push('first_entry')
    }
    if (stats.streakDays >= 7) {
      add.push('streak_7')
    }
    if (stats.clipCount >= 50) {
      add.push('clips_50')
    }
    if (stats.themeCount >= 10) {
      add.push('themes_10')
    }
    const year = `${new Date().getFullYear()}`
    const ya = await XdStore.buildYearArchive(year)
    if (ya.entryCount + ya.clipCount >= 1) {
      add.push('year_file')
    }
    let changed = false
    for (const id of add) {
      let has = false
      for (const u of unlocked) {
        if (u === id) {
          has = true
        }
      }
      if (!has) {
        unlocked.push(id)
        changed = true
      }
    }
    if (changed) {
      await XdStore.putString(KEY_UNLOCKED, unlocked.join(','))
    }
  }

  private static async computeStreak(): Promise<number> {
    const raw = await XdStore.getString(KEY_ACTIVITY, '')
    const days = XdStore.splitLines(raw)
    if (days.length === 0) {
      return 0
    }
    let streak = 0
    const cursor = new Date()
    for (let i = 0; i < 400; i++) {
      const key = XdDateUtil.keyFromDate(cursor)
      let hit = false
      for (const d of days) {
        if (d === key) {
          hit = true
        }
      }
      if (!hit) {
        if (i === 0) {
          cursor.setDate(cursor.getDate() - 1)
          continue
        }
        break
      }
      streak++
      cursor.setDate(cursor.getDate() - 1)
    }
    return streak
  }

  private static async recordActivity(dateKey: string): Promise<void> {
    const raw = await XdStore.getString(KEY_ACTIVITY, '')
    const days = XdStore.splitLines(raw)
    let has = false
    for (const d of days) {
      if (d === dateKey) {
        has = true
      }
    }
    if (!has) {
      days.push(dateKey)
      await XdStore.putString(KEY_ACTIVITY, days.join('\n'))
    }
  }

  private static sanitize(v: string): string {
    return v.replace(/\t/g, ' ').replace(/\n/g, ' ')
  }

  private static sanitizeCsv(v: string): string {
    return v.replace(/\t/g, ' ').replace(/\n/g, ',')
  }

  private static esc(v: string): string {
    return v.replace(/\\/g, '\\\\').replace(/"/g, '\\"')
  }

  static splitCsv(raw: string): string[] {
    if (raw.length === 0) {
      return []
    }
    const parts = raw.split(',')
    const out: string[] = []
    for (const p of parts) {
      if (p.length > 0) {
        out.push(p)
      }
    }
    return out
  }

  static csvHas(csv: string, id: string): boolean {
    const parts = XdStore.splitCsv(csv)
    for (const p of parts) {
      if (p === id) {
        return true
      }
    }
    return false
  }

  static toggleCsv(csv: string, id: string): string {
    if (XdStore.csvHas(csv, id)) {
      return XdStore.removeId(csv, id)
    }
    if (csv.length === 0) {
      return id
    }
    return `${csv},${id}`
  }

  private static removeId(csv: string, id: string): string {
    const parts = XdStore.splitCsv(csv)
    const out: string[] = []
    for (const p of parts) {
      if (p !== id) {
        out.push(p)
      }
    }
    return out.join(',')
  }

  private static splitLines(raw: string): string[] {
    if (raw.length === 0) {
      return []
    }
    const lines = raw.split('\n')
    const out: string[] = []
    for (const l of lines) {
      if (l.length > 0) {
        out.push(l)
      }
    }
    return out
  }

  private static mostFrequent(ids: string[]): string {
    if (ids.length === 0) {
      return '—'
    }
    let best = ids[0]
    let bestN = 0
    for (const id of ids) {
      let n = 0
      for (const x of ids) {
        if (x === id) {
          n++
        }
      }
      if (n > bestN) {
        bestN = n
        best = id
      }
    }
    return best
  }

  private static async persistEntries(list: XdEntry[]): Promise<void> {
    const lines: string[] = []
    for (const e of list) {
      lines.push([
        e.id, XdStore.sanitize(e.title), e.dateKey, e.categoryKey, XdStore.sanitizeCsv(e.tagCsv), e.status, e.templateKey,
        XdStore.sanitize(e.fieldA), XdStore.sanitize(e.fieldB), XdStore.sanitize(e.fieldC),
        XdStore.sanitize(e.body), XdStore.sanitizeCsv(e.themeCsv), `${e.createdAt}`, `${e.updatedAt}`
      ].join('\t'))
    }
    await XdStore.putString(KEY_ENTRIES, lines.join('\n'))
  }

  private static parseEntries(raw: string): XdEntry[] {
    const out: XdEntry[] = []
    const lines = XdStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 14) {
        continue
      }
      const e = new XdEntry()
      e.id = p[0]
      e.title = p[1]
      e.dateKey = p[2]
      e.categoryKey = p[3]
      e.tagCsv = p[4]
      e.status = p[5]
      e.templateKey = p[6]
      e.fieldA = p[7]
      e.fieldB = p[8]
      e.fieldC = p[9]
      e.body = p[10]
      e.themeCsv = p[11]
      e.createdAt = parseInt(p[12], 10)
      e.updatedAt = parseInt(p[13], 10)
      out.push(e)
    }
    out.sort((a: XdEntry, b: XdEntry) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async persistClips(list: XdClip[]): Promise<void> {
    const lines: string[] = []
    for (const c of list) {
      lines.push([
        c.id, XdStore.sanitize(c.text), c.clipKind, c.dateKey, XdStore.sanitizeCsv(c.tagCsv),
        XdStore.sanitizeCsv(c.themeCsv),
        c.treasured ? '1' : '0', `${c.createdAt}`
      ].join('\t'))
    }
    await XdStore.putString(KEY_CLIPS, lines.join('\n'))
  }

  private static parseClips(raw: string): XdClip[] {
    const out: XdClip[] = []
    const lines = XdStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 8) {
        continue
      }
      const c = new XdClip()
      c.id = p[0]
      c.text = p[1]
      c.clipKind = p[2]
      c.dateKey = p[3]
      c.tagCsv = p[4]
      c.themeCsv = p[5]
      c.treasured = p[6] === '1'
      c.createdAt = parseInt(p[7], 10)
      out.push(c)
    }
    out.sort((a: XdClip, b: XdClip) => b.createdAt - a.createdAt)
    return out
  }

  private static async persistThemes(list: XdTheme[]): Promise<void> {
    const lines: string[] = []
    for (const t of list) {
      lines.push([
        t.id, XdStore.sanitize(t.title), XdStore.sanitize(t.summary), t.coverKey,
        `${t.createdAt}`, `${t.updatedAt}`
      ].join('\t'))
    }
    await XdStore.putString(KEY_THEMES, lines.join('\n'))
  }

  private static parseThemes(raw: string): XdTheme[] {
    const out: XdTheme[] = []
    const lines = XdStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 6) {
        continue
      }
      const t = new XdTheme()
      t.id = p[0]
      t.title = p[1]
      t.summary = p[2]
      t.coverKey = p[3]
      t.createdAt = parseInt(p[4], 10)
      t.updatedAt = parseInt(p[5], 10)
      out.push(t)
    }
    out.sort((a: XdTheme, b: XdTheme) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async persistCategories(list: XdCategory[]): Promise<void> {
    const lines: string[] = []
    for (const c of list) {
      lines.push(`${c.key}\t${c.label}\t${c.sortOrder}`)
    }
    await XdStore.putString(KEY_CATS, lines.join('\n'))
  }

  private static parseCategories(raw: string): XdCategory[] {
    const out: XdCategory[] = []
    const lines = XdStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 3) {
        continue
      }
      out.push(XdCategory.make(p[0], p[1], parseInt(p[2], 10)))
    }
    return out
  }

  private static async persistMoodLogs(list: XdMoodLog[]): Promise<void> {
    const lines: string[] = []
    for (const m of list) {
      lines.push([m.dateKey, m.moodKey, XdStore.sanitize(m.note)].join('\t'))
    }
    await XdStore.putString(KEY_MOODS, lines.join('\n'))
  }

  private static parseMoodLogs(raw: string): XdMoodLog[] {
    const out: XdMoodLog[] = []
    const lines = XdStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 2) {
        continue
      }
      const m = new XdMoodLog()
      m.dateKey = p[0]
      m.moodKey = p[1]
      m.note = p.length >= 3 ? p[2] : ''
      out.push(m)
    }
    return out
  }

  private static async persistWishes(list: XdWishItem[]): Promise<void> {
    const lines: string[] = []
    for (const w of list) {
      lines.push([
        w.id, XdStore.sanitize(w.title), XdStore.sanitize(w.note), w.status, w.themeId
      ].join('\t'))
    }
    await XdStore.putString(KEY_WISHES, lines.join('\n'))
  }

  private static parseWishes(raw: string): XdWishItem[] {
    const out: XdWishItem[] = []
    const lines = XdStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 4) {
        continue
      }
      const w = new XdWishItem()
      w.id = p[0]
      w.title = p[1]
      w.note = p[2]
      w.status = p[3]
      w.themeId = p.length >= 5 ? p[4] : ''
      out.push(w)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    const cached = XdStore.mem.get(key)
    if (cached !== undefined) {
      return cached
    }
    if (!(await XdStore.ensurePref()) || XdStore.pref === null) {
      return fallback
    }
    try {
      const v = await XdStore.pref.get(key, fallback)
      if (typeof v === 'string') {
        XdStore.mem.set(key, v)
        return v
      }
      return fallback
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    XdStore.mem.set(key, value)
    if (!(await XdStore.ensurePref()) || XdStore.pref === null) {
      return
    }
    try {
      await XdStore.pref.put(key, value)
      await XdStore.pref.flush()
    } catch {
      // 已写入 mem，同会话可读；落盘失败不阻断 UI 刷新
    }
  }
}
