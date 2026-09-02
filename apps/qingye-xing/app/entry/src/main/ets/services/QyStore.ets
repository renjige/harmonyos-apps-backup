import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  QyCategory, QyClip, QyDateUtil, QyEntry, QyLookbackItem, QyProfile,
  QyStats, QyTheme, QyTimelineRow, QyYearArchive
} from '../models/QyModels'
import { AppContextService } from './AppContextService'

const STORE = 'qingye_xing_v1'
const KEY_ENTRIES = 'entries'
const KEY_CLIPS = 'clips'
const KEY_THEMES = 'themes'
const KEY_CATS = 'categories'
const KEY_TAGS = 'tags'
const KEY_PROFILE = 'profile'
const KEY_ACTIVITY = 'activity'
const KEY_UNLOCKED = 'unlocked'

export class QyStore {
  private static pref: preferences.Preferences | null = null
  /** 同进程读写缓存：避免 Preferences 未就绪时 put 静默失败、首页一直读到空 */
  private static mem: Map<string, string> = new Map()

  static bump(): void {
    const rev = (AppStorage.get<number>('QyDataRev') ?? 0) + 1
    if (!AppStorage.set('QyDataRev', rev)) {
      AppStorage.setOrCreate('QyDataRev', rev)
    }
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    AppContextService.setContext(context)
    try {
      QyStore.pref = await preferences.getPreferences(context, STORE)
      await QyStore.hydrateMemFromPref()
    } catch {
      QyStore.pref = null
    }
    const cats = await QyStore.loadCategories()
    if (cats.length === 0) {
      await QyStore.persistCategories(QyCategory.defaults())
    }
  }

  private static async hydrateMemFromPref(): Promise<void> {
    if (QyStore.pref === null) {
      return
    }
    const keys: string[] = [
      KEY_ENTRIES, KEY_CLIPS, KEY_THEMES, KEY_CATS, KEY_TAGS,
      KEY_PROFILE, KEY_ACTIVITY, KEY_UNLOCKED
    ]
    for (const key of keys) {
      try {
        const v = await QyStore.pref.get(key, '')
        if (typeof v === 'string') {
          QyStore.mem.set(key, v)
        }
      } catch {
        // ignore single-key hydrate failure
      }
    }
  }

  private static async ensurePref(): Promise<boolean> {
    if (QyStore.pref !== null) {
      return true
    }
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      return false
    }
    try {
      QyStore.pref = await preferences.getPreferences(ctx, STORE)
      await QyStore.hydrateMemFromPref()
      return true
    } catch {
      QyStore.pref = null
      return false
    }
  }

  static async loadEntries(): Promise<QyEntry[]> {
    return QyStore.parseEntries(await QyStore.getString(KEY_ENTRIES, ''))
  }

  static async findEntry(id: string): Promise<QyEntry | undefined> {
    const list = await QyStore.loadEntries()
    for (const e of list) {
      if (e.id === id) {
        return e
      }
    }
    return undefined
  }

  static async saveEntry(entry: QyEntry): Promise<void> {
    entry.updatedAt = Date.now()
    const list = await QyStore.loadEntries()
    let found = false
    const next: QyEntry[] = []
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
    await QyStore.persistEntries(next)
    await QyStore.recordActivity(entry.dateKey)
    await QyStore.checkAchievements()
    QyStore.bump()
  }

  static async deleteEntry(id: string): Promise<void> {
    const list = await QyStore.loadEntries()
    const next: QyEntry[] = []
    for (const e of list) {
      if (e.id !== id) {
        next.push(e)
      }
    }
    await QyStore.persistEntries(next)
    QyStore.bump()
  }

  static async loadClips(): Promise<QyClip[]> {
    return QyStore.parseClips(await QyStore.getString(KEY_CLIPS, ''))
  }

  static async findClip(id: string): Promise<QyClip | undefined> {
    const list = await QyStore.loadClips()
    for (const c of list) {
      if (c.id === id) {
        return c
      }
    }
    return undefined
  }

  static async saveClip(clip: QyClip): Promise<void> {
    const list = await QyStore.loadClips()
    let found = false
    const next: QyClip[] = []
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
    await QyStore.persistClips(next)
    await QyStore.recordActivity(clip.dateKey)
    await QyStore.checkAchievements()
    QyStore.bump()
  }

  static async deleteClip(id: string): Promise<void> {
    const list = await QyStore.loadClips()
    const next: QyClip[] = []
    for (const c of list) {
      if (c.id !== id) {
        next.push(c)
      }
    }
    await QyStore.persistClips(next)
    QyStore.bump()
  }

  static async loadThemes(): Promise<QyTheme[]> {
    return QyStore.parseThemes(await QyStore.getString(KEY_THEMES, ''))
  }

  static async findTheme(id: string): Promise<QyTheme | undefined> {
    const list = await QyStore.loadThemes()
    for (const t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async saveTheme(theme: QyTheme): Promise<void> {
    theme.updatedAt = Date.now()
    const list = await QyStore.loadThemes()
    let found = false
    const next: QyTheme[] = []
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
    await QyStore.persistThemes(next)
    await QyStore.checkAchievements()
    QyStore.bump()
  }

  static async deleteTheme(id: string): Promise<void> {
    const list = await QyStore.loadThemes()
    const next: QyTheme[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    await QyStore.persistThemes(next)
    const entries = await QyStore.loadEntries()
    for (const e of entries) {
      e.themeCsv = QyStore.removeId(e.themeCsv, id)
    }
    await QyStore.persistEntries(entries)
    const clips = await QyStore.loadClips()
    for (const c of clips) {
      c.themeCsv = QyStore.removeId(c.themeCsv, id)
    }
    await QyStore.persistClips(clips)
    QyStore.bump()
  }

  static async entriesForTheme(themeId: string): Promise<QyEntry[]> {
    const list = await QyStore.loadEntries()
    const out: QyEntry[] = []
    for (const e of list) {
      if (QyStore.csvHas(e.themeCsv, themeId)) {
        out.push(e)
      }
    }
    return out
  }

  static async clipsForTheme(themeId: string): Promise<QyClip[]> {
    const list = await QyStore.loadClips()
    const out: QyClip[] = []
    for (const c of list) {
      if (QyStore.csvHas(c.themeCsv, themeId)) {
        out.push(c)
      }
    }
    return out
  }

  static async loadCategories(): Promise<QyCategory[]> {
    return QyStore.parseCategories(await QyStore.getString(KEY_CATS, ''))
  }

  static async saveCategory(cat: QyCategory): Promise<void> {
    const list = await QyStore.loadCategories()
    let found = false
    const next: QyCategory[] = []
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
    await QyStore.persistCategories(next)
    QyStore.bump()
  }

  static async deleteCategory(key: string): Promise<void> {
    if (key === 'daily') {
      return
    }
    const list = await QyStore.loadCategories()
    const next: QyCategory[] = []
    for (const c of list) {
      if (c.key !== key) {
        next.push(c)
      }
    }
    await QyStore.persistCategories(next)
    QyStore.bump()
  }

  static categoryLabel(key: string, cats: QyCategory[]): string {
    for (const c of cats) {
      if (c.key === key) {
        return c.label
      }
    }
    return '日常'
  }

  static async loadTags(): Promise<string[]> {
    const raw = await QyStore.getString(KEY_TAGS, '')
    if (raw.length === 0) {
      return ['温暖', '成长', '灵感', '回忆', '计划', '收藏', '重要']
    }
    return QyStore.splitLines(raw)
  }

  static async saveTags(tags: string[]): Promise<void> {
    await QyStore.putString(KEY_TAGS, tags.join('\n'))
    QyStore.bump()
  }

  static async loadProfile(): Promise<QyProfile> {
    const raw = await QyStore.getString(KEY_PROFILE, '')
    const p = new QyProfile()
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

  static async saveProfile(p: QyProfile): Promise<void> {
    await QyStore.putString(KEY_PROFILE, `${p.nickname}\t${p.themeMode}`)
    QyStore.bump()
  }

  static async computeStats(): Promise<QyStats> {
    const s = new QyStats()
    const entries = await QyStore.loadEntries()
    const clips = await QyStore.loadClips()
    const themes = await QyStore.loadThemes()
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
    s.streakDays = await QyStore.computeStreak()
    return s
  }

  static async recentEntries(limit: number): Promise<QyEntry[]> {
    const list = await QyStore.loadEntries()
    list.sort((a: QyEntry, b: QyEntry) => b.updatedAt - a.updatedAt)
    const out: QyEntry[] = []
    for (const e of list) {
      if (out.length >= limit) {
        break
      }
      out.push(e)
    }
    return out
  }

  static async buildTimeline(): Promise<QyTimelineRow[]> {
    const rows: QyTimelineRow[] = []
    const entries = await QyStore.loadEntries()
    for (const e of entries) {
      const r = new QyTimelineRow()
      r.id = e.id
      r.kind = 'entry'
      r.dateKey = e.dateKey
      r.title = e.title
      r.subtitle = e.summaryText()
      rows.push(r)
    }
    const clips = await QyStore.loadClips()
    for (const c of clips) {
      const r = new QyTimelineRow()
      r.id = c.id
      r.kind = 'clip'
      r.dateKey = c.dateKey
      r.title = c.text
      r.subtitle = '观察收藏'
      rows.push(r)
    }
    rows.sort((a: QyTimelineRow, b: QyTimelineRow) => b.dateKey.localeCompare(a.dateKey))
    return rows
  }

  static async buildLookback(): Promise<QyLookbackItem> {
    const item = new QyLookbackItem()
    const yearKey = QyDateUtil.yearsAgoKey(1)
    const threeKey = QyDateUtil.daysAgoKey(90)
    const entries = await QyStore.loadEntries()
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
    const clips = await QyStore.loadClips()
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

  static async buildYearArchive(year: string): Promise<QyYearArchive> {
    const y = new QyYearArchive()
    y.year = year
    const entries = await QyStore.loadEntries()
    const clips = await QyStore.loadClips()
    const themes = await QyStore.loadThemes()
    const themeHits: string[] = []
    const tagHits: string[] = []
    for (const e of entries) {
      if (QyDateUtil.yearFromKey(e.dateKey) === year) {
        y.entryCount++
        if (y.highlightTitle.length === 0 && (e.status === 'treasure' || e.status === 'important')) {
          y.highlightTitle = e.title
        }
        const tids = QyStore.splitCsv(e.themeCsv)
        for (const id of tids) {
          themeHits.push(id)
        }
        const tags = QyStore.splitCsv(e.tagCsv)
        for (const t of tags) {
          tagHits.push(t)
        }
      }
    }
    for (const c of clips) {
      if (QyDateUtil.yearFromKey(c.dateKey) === year) {
        y.clipCount++
      }
    }
    y.themeCount = themes.length
    y.topTheme = QyStore.mostFrequent(themeHits)
    y.topTag = QyStore.mostFrequent(tagHits)
    if (y.highlightTitle.length === 0 && entries.length > 0) {
      y.highlightTitle = entries[0].title
    }
    return y
  }

  static async monthCounts(n: number): Promise<number[]> {
    const keys = QyDateUtil.lastNMonths(n)
    const counts: number[] = []
    for (let i = 0; i < keys.length; i++) {
      counts.push(0)
    }
    const entries = await QyStore.loadEntries()
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

  static async categoryCounts(): Promise<QyCategory[]> {
    return QyStore.loadCategories()
  }

  static async countByCategory(key: string): Promise<number> {
    const list = await QyStore.loadEntries()
    let n = 0
    for (const e of list) {
      if (e.categoryKey === key) {
        n++
      }
    }
    return n
  }

  static async loadUnlocked(): Promise<string[]> {
    return QyStore.splitCsv(await QyStore.getString(KEY_UNLOCKED, ''))
  }

  static async searchAll(q: string): Promise<QyTimelineRow[]> {
    const needle = q.trim()
    const rows = await QyStore.buildTimeline()
    if (needle.length === 0) {
      return rows
    }
    const out: QyTimelineRow[] = []
    for (const r of rows) {
      if (r.title.indexOf(needle) >= 0 || r.subtitle.indexOf(needle) >= 0 || r.dateKey.indexOf(needle) >= 0) {
        out.push(r)
      }
    }
    const entries = await QyStore.loadEntries()
    for (const e of entries) {
      if (e.tagCsv.indexOf(needle) >= 0 || e.categoryKey.indexOf(needle) >= 0 || e.body.indexOf(needle) >= 0) {
        let already = false
        for (const r of out) {
          if (r.id === e.id) {
            already = true
          }
        }
        if (!already) {
          const row = new QyTimelineRow()
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

  static async exportJson(): Promise<string> {
    const entries = await QyStore.loadEntries()
    const clips = await QyStore.loadClips()
    const themes = await QyStore.loadThemes()
    let s = '{"app":"清野札","entries":['
    let first = true
    for (const e of entries) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${e.id}","title":"${QyStore.esc(e.title)}","date":"${e.dateKey}","status":"${e.status}"}`
    }
    s += '],"clips":['
    first = true
    for (const c of clips) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${c.id}","text":"${QyStore.esc(c.text)}"}`
    }
    s += '],"themes":['
    first = true
    for (const t of themes) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${t.id}","title":"${QyStore.esc(t.title)}"}`
    }
    s += ']}'
    return s
  }

  static async clearAll(): Promise<void> {
    await QyStore.putString(KEY_ENTRIES, '')
    await QyStore.putString(KEY_CLIPS, '')
    await QyStore.putString(KEY_THEMES, '')
    await QyStore.putString(KEY_ACTIVITY, '')
    await QyStore.putString(KEY_UNLOCKED, '')
    await QyStore.persistCategories(QyCategory.defaults())
    QyStore.bump()
  }

  private static async checkAchievements(): Promise<void> {
    const unlocked = await QyStore.loadUnlocked()
    const stats = await QyStore.computeStats()
    const add: string[] = []
    if (stats.entryCount >= 1) {
      add.push('first_entry')
    }
    if (stats.streakDays >= 7) {
      add.push('streak_7')
    }
    if (stats.clipCount >= 20) {
      add.push('clips_20')
    }
    if (stats.themeCount >= 5) {
      add.push('themes_5')
    }
    const year = `${new Date().getFullYear()}`
    const ya = await QyStore.buildYearArchive(year)
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
      await QyStore.putString(KEY_UNLOCKED, unlocked.join(','))
    }
  }

  private static async computeStreak(): Promise<number> {
    const raw = await QyStore.getString(KEY_ACTIVITY, '')
    const days = QyStore.splitLines(raw)
    if (days.length === 0) {
      return 0
    }
    let streak = 0
    const cursor = new Date()
    for (let i = 0; i < 400; i++) {
      const key = QyDateUtil.keyFromDate(cursor)
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
    const raw = await QyStore.getString(KEY_ACTIVITY, '')
    const days = QyStore.splitLines(raw)
    let has = false
    for (const d of days) {
      if (d === dateKey) {
        has = true
      }
    }
    if (!has) {
      days.push(dateKey)
      await QyStore.putString(KEY_ACTIVITY, days.join('\n'))
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
    const parts = QyStore.splitCsv(csv)
    for (const p of parts) {
      if (p === id) {
        return true
      }
    }
    return false
  }

  static toggleCsv(csv: string, id: string): string {
    if (QyStore.csvHas(csv, id)) {
      return QyStore.removeId(csv, id)
    }
    if (csv.length === 0) {
      return id
    }
    return `${csv},${id}`
  }

  private static removeId(csv: string, id: string): string {
    const parts = QyStore.splitCsv(csv)
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

  private static async persistEntries(list: QyEntry[]): Promise<void> {
    const lines: string[] = []
    for (const e of list) {
      lines.push([
        e.id, QyStore.sanitize(e.title), e.dateKey, e.categoryKey, QyStore.sanitizeCsv(e.tagCsv), e.status, e.templateKey,
        QyStore.sanitize(e.fieldA), QyStore.sanitize(e.fieldB), QyStore.sanitize(e.fieldC),
        QyStore.sanitize(e.body), QyStore.sanitizeCsv(e.themeCsv), `${e.createdAt}`, `${e.updatedAt}`
      ].join('\t'))
    }
    await QyStore.putString(KEY_ENTRIES, lines.join('\n'))
  }

  private static parseEntries(raw: string): QyEntry[] {
    const out: QyEntry[] = []
    const lines = QyStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 14) {
        continue
      }
      const e = new QyEntry()
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
    out.sort((a: QyEntry, b: QyEntry) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async persistClips(list: QyClip[]): Promise<void> {
    const lines: string[] = []
    for (const c of list) {
      lines.push([
        c.id, QyStore.sanitize(c.text), c.clipKind, c.dateKey, QyStore.sanitizeCsv(c.tagCsv),
        QyStore.sanitizeCsv(c.themeCsv),
        c.treasured ? '1' : '0', `${c.createdAt}`
      ].join('\t'))
    }
    await QyStore.putString(KEY_CLIPS, lines.join('\n'))
  }

  private static parseClips(raw: string): QyClip[] {
    const out: QyClip[] = []
    const lines = QyStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 8) {
        continue
      }
      const c = new QyClip()
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
    out.sort((a: QyClip, b: QyClip) => b.createdAt - a.createdAt)
    return out
  }

  private static async persistThemes(list: QyTheme[]): Promise<void> {
    const lines: string[] = []
    for (const t of list) {
      lines.push([
        t.id, QyStore.sanitize(t.title), QyStore.sanitize(t.summary), t.coverKey,
        `${t.createdAt}`, `${t.updatedAt}`
      ].join('\t'))
    }
    await QyStore.putString(KEY_THEMES, lines.join('\n'))
  }

  private static parseThemes(raw: string): QyTheme[] {
    const out: QyTheme[] = []
    const lines = QyStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 6) {
        continue
      }
      const t = new QyTheme()
      t.id = p[0]
      t.title = p[1]
      t.summary = p[2]
      t.coverKey = p[3]
      t.createdAt = parseInt(p[4], 10)
      t.updatedAt = parseInt(p[5], 10)
      out.push(t)
    }
    out.sort((a: QyTheme, b: QyTheme) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async persistCategories(list: QyCategory[]): Promise<void> {
    const lines: string[] = []
    for (const c of list) {
      lines.push(`${c.key}\t${c.label}\t${c.sortOrder}`)
    }
    await QyStore.putString(KEY_CATS, lines.join('\n'))
  }

  private static parseCategories(raw: string): QyCategory[] {
    const out: QyCategory[] = []
    const lines = QyStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 3) {
        continue
      }
      out.push(QyCategory.make(p[0], p[1], parseInt(p[2], 10)))
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    const cached = QyStore.mem.get(key)
    if (cached !== undefined) {
      return cached
    }
    if (!(await QyStore.ensurePref()) || QyStore.pref === null) {
      return fallback
    }
    try {
      const v = await QyStore.pref.get(key, fallback)
      if (typeof v === 'string') {
        QyStore.mem.set(key, v)
        return v
      }
      return fallback
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    QyStore.mem.set(key, value)
    if (!(await QyStore.ensurePref()) || QyStore.pref === null) {
      return
    }
    try {
      await QyStore.pref.put(key, value)
      await QyStore.pref.flush()
    } catch {
      // 已写入 mem，同会话可读；落盘失败不阻断 UI 刷新
    }
  }
}
