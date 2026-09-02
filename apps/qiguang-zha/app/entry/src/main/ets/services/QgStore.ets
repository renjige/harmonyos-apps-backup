import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  QgCategory, QgClip, QgDateUtil, QgEntry, QgLookbackItem, QgProfile,
  QgStats, QgTheme, QgTimelineRow, QgYearArchive
} from '../models/QgModels'
import { AppContextService } from './AppContextService'

const STORE = 'qiguang_zha_v1'
const KEY_ENTRIES = 'entries'
const KEY_CLIPS = 'clips'
const KEY_THEMES = 'themes'
const KEY_CATS = 'categories'
const KEY_TAGS = 'tags'
const KEY_PROFILE = 'profile'
const KEY_ACTIVITY = 'activity'
const KEY_UNLOCKED = 'unlocked'

export class QgStore {
  private static pref: preferences.Preferences | null = null
  /** 同进程读写缓存：避免 Preferences 未就绪时 put 静默失败、首页一直读到空 */
  private static mem: Map<string, string> = new Map()

  static bump(): void {
    const rev = (AppStorage.get<number>('qgDataRev') ?? 0) + 1
    if (!AppStorage.set('qgDataRev', rev)) {
      AppStorage.setOrCreate('qgDataRev', rev)
    }
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    AppContextService.setContext(context)
    try {
      QgStore.pref = await preferences.getPreferences(context, STORE)
      await QgStore.hydrateMemFromPref()
    } catch {
      QgStore.pref = null
    }
    const cats = await QgStore.loadCategories()
    if (cats.length === 0) {
      await QgStore.persistCategories(QgCategory.defaults())
    }
  }

  private static async hydrateMemFromPref(): Promise<void> {
    if (QgStore.pref === null) {
      return
    }
    const keys: string[] = [
      KEY_ENTRIES, KEY_CLIPS, KEY_THEMES, KEY_CATS, KEY_TAGS,
      KEY_PROFILE, KEY_ACTIVITY, KEY_UNLOCKED
    ]
    for (const key of keys) {
      try {
        const v = await QgStore.pref.get(key, '')
        if (typeof v === 'string') {
          QgStore.mem.set(key, v)
        }
      } catch {
        // ignore single-key hydrate failure
      }
    }
  }

  private static async ensurePref(): Promise<boolean> {
    if (QgStore.pref !== null) {
      return true
    }
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      return false
    }
    try {
      QgStore.pref = await preferences.getPreferences(ctx, STORE)
      await QgStore.hydrateMemFromPref()
      return true
    } catch {
      QgStore.pref = null
      return false
    }
  }

  static async loadEntries(): Promise<QgEntry[]> {
    return QgStore.parseEntries(await QgStore.getString(KEY_ENTRIES, ''))
  }

  static async findEntry(id: string): Promise<QgEntry | undefined> {
    const list = await QgStore.loadEntries()
    for (const e of list) {
      if (e.id === id) {
        return e
      }
    }
    return undefined
  }

  static async saveEntry(entry: QgEntry): Promise<void> {
    entry.updatedAt = Date.now()
    const list = await QgStore.loadEntries()
    let found = false
    const next: QgEntry[] = []
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
    await QgStore.persistEntries(next)
    await QgStore.recordActivity(entry.dateKey)
    await QgStore.checkAchievements()
    QgStore.bump()
  }

  static async deleteEntry(id: string): Promise<void> {
    const list = await QgStore.loadEntries()
    const next: QgEntry[] = []
    for (const e of list) {
      if (e.id !== id) {
        next.push(e)
      }
    }
    await QgStore.persistEntries(next)
    QgStore.bump()
  }

  static async loadClips(): Promise<QgClip[]> {
    return QgStore.parseClips(await QgStore.getString(KEY_CLIPS, ''))
  }

  static async findClip(id: string): Promise<QgClip | undefined> {
    const list = await QgStore.loadClips()
    for (const c of list) {
      if (c.id === id) {
        return c
      }
    }
    return undefined
  }

  static async saveClip(clip: QgClip): Promise<void> {
    const list = await QgStore.loadClips()
    let found = false
    const next: QgClip[] = []
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
    await QgStore.persistClips(next)
    await QgStore.recordActivity(clip.dateKey)
    await QgStore.checkAchievements()
    QgStore.bump()
  }

  static async deleteClip(id: string): Promise<void> {
    const list = await QgStore.loadClips()
    const next: QgClip[] = []
    for (const c of list) {
      if (c.id !== id) {
        next.push(c)
      }
    }
    await QgStore.persistClips(next)
    QgStore.bump()
  }

  static async loadThemes(): Promise<QgTheme[]> {
    return QgStore.parseThemes(await QgStore.getString(KEY_THEMES, ''))
  }

  static async findTheme(id: string): Promise<QgTheme | undefined> {
    const list = await QgStore.loadThemes()
    for (const t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async saveTheme(theme: QgTheme): Promise<void> {
    theme.updatedAt = Date.now()
    const list = await QgStore.loadThemes()
    let found = false
    const next: QgTheme[] = []
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
    await QgStore.persistThemes(next)
    await QgStore.checkAchievements()
    QgStore.bump()
  }

  static async deleteTheme(id: string): Promise<void> {
    const list = await QgStore.loadThemes()
    const next: QgTheme[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    await QgStore.persistThemes(next)
    const entries = await QgStore.loadEntries()
    for (const e of entries) {
      e.themeCsv = QgStore.removeId(e.themeCsv, id)
    }
    await QgStore.persistEntries(entries)
    const clips = await QgStore.loadClips()
    for (const c of clips) {
      c.themeCsv = QgStore.removeId(c.themeCsv, id)
    }
    await QgStore.persistClips(clips)
    QgStore.bump()
  }

  static async entriesForTheme(themeId: string): Promise<QgEntry[]> {
    const list = await QgStore.loadEntries()
    const out: QgEntry[] = []
    for (const e of list) {
      if (QgStore.csvHas(e.themeCsv, themeId)) {
        out.push(e)
      }
    }
    return out
  }

  static async clipsForTheme(themeId: string): Promise<QgClip[]> {
    const list = await QgStore.loadClips()
    const out: QgClip[] = []
    for (const c of list) {
      if (QgStore.csvHas(c.themeCsv, themeId)) {
        out.push(c)
      }
    }
    return out
  }

  static async loadCategories(): Promise<QgCategory[]> {
    return QgStore.parseCategories(await QgStore.getString(KEY_CATS, ''))
  }

  static async saveCategory(cat: QgCategory): Promise<void> {
    const list = await QgStore.loadCategories()
    let found = false
    const next: QgCategory[] = []
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
    await QgStore.persistCategories(next)
    QgStore.bump()
  }

  static async deleteCategory(key: string): Promise<void> {
    if (key === 'daily') {
      return
    }
    const list = await QgStore.loadCategories()
    const next: QgCategory[] = []
    for (const c of list) {
      if (c.key !== key) {
        next.push(c)
      }
    }
    await QgStore.persistCategories(next)
    QgStore.bump()
  }

  static categoryLabel(key: string, cats: QgCategory[]): string {
    for (const c of cats) {
      if (c.key === key) {
        return c.label
      }
    }
    return '日常'
  }

  static async loadTags(): Promise<string[]> {
    const raw = await QgStore.getString(KEY_TAGS, '')
    if (raw.length === 0) {
      return ['温暖', '成长', '灵感', '回忆', '计划', '收藏', '重要']
    }
    return QgStore.splitLines(raw)
  }

  static async saveTags(tags: string[]): Promise<void> {
    await QgStore.putString(KEY_TAGS, tags.join('\n'))
    QgStore.bump()
  }

  static async loadProfile(): Promise<QgProfile> {
    const raw = await QgStore.getString(KEY_PROFILE, '')
    const p = new QgProfile()
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

  static async saveProfile(p: QgProfile): Promise<void> {
    await QgStore.putString(KEY_PROFILE, `${p.nickname}\t${p.themeMode}`)
    QgStore.bump()
  }

  static async computeStats(): Promise<QgStats> {
    const s = new QgStats()
    const entries = await QgStore.loadEntries()
    const clips = await QgStore.loadClips()
    const themes = await QgStore.loadThemes()
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
    s.streakDays = await QgStore.computeStreak()
    return s
  }

  static async recentEntries(limit: number): Promise<QgEntry[]> {
    const list = await QgStore.loadEntries()
    list.sort((a: QgEntry, b: QgEntry) => b.updatedAt - a.updatedAt)
    const out: QgEntry[] = []
    for (const e of list) {
      if (out.length >= limit) {
        break
      }
      out.push(e)
    }
    return out
  }

  static async buildTimeline(): Promise<QgTimelineRow[]> {
    const rows: QgTimelineRow[] = []
    const entries = await QgStore.loadEntries()
    for (const e of entries) {
      const r = new QgTimelineRow()
      r.id = e.id
      r.kind = 'entry'
      r.dateKey = e.dateKey
      r.title = e.title
      r.subtitle = e.summaryText()
      rows.push(r)
    }
    const clips = await QgStore.loadClips()
    for (const c of clips) {
      const r = new QgTimelineRow()
      r.id = c.id
      r.kind = 'clip'
      r.dateKey = c.dateKey
      r.title = c.text
      r.subtitle = '光影收藏'
      rows.push(r)
    }
    rows.sort((a: QgTimelineRow, b: QgTimelineRow) => b.dateKey.localeCompare(a.dateKey))
    return rows
  }

  static async buildLookback(): Promise<QgLookbackItem> {
    const item = new QgLookbackItem()
    const yearKey = QgDateUtil.yearsAgoKey(1)
    const threeKey = QgDateUtil.daysAgoKey(90)
    const entries = await QgStore.loadEntries()
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
    const clips = await QgStore.loadClips()
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

  static async buildYearArchive(year: string): Promise<QgYearArchive> {
    const y = new QgYearArchive()
    y.year = year
    const entries = await QgStore.loadEntries()
    const clips = await QgStore.loadClips()
    const themes = await QgStore.loadThemes()
    const themeHits: string[] = []
    const tagHits: string[] = []
    for (const e of entries) {
      if (QgDateUtil.yearFromKey(e.dateKey) === year) {
        y.entryCount++
        if (y.highlightTitle.length === 0 && (e.status === 'treasure' || e.status === 'important')) {
          y.highlightTitle = e.title
        }
        const tids = QgStore.splitCsv(e.themeCsv)
        for (const id of tids) {
          themeHits.push(id)
        }
        const tags = QgStore.splitCsv(e.tagCsv)
        for (const t of tags) {
          tagHits.push(t)
        }
      }
    }
    for (const c of clips) {
      if (QgDateUtil.yearFromKey(c.dateKey) === year) {
        y.clipCount++
      }
    }
    y.themeCount = themes.length
    y.topTheme = QgStore.mostFrequent(themeHits)
    y.topTag = QgStore.mostFrequent(tagHits)
    if (y.highlightTitle.length === 0 && entries.length > 0) {
      y.highlightTitle = entries[0].title
    }
    return y
  }

  static async monthCounts(n: number): Promise<number[]> {
    const keys = QgDateUtil.lastNMonths(n)
    const counts: number[] = []
    for (let i = 0; i < keys.length; i++) {
      counts.push(0)
    }
    const entries = await QgStore.loadEntries()
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

  static async categoryCounts(): Promise<QgCategory[]> {
    return QgStore.loadCategories()
  }

  static async countByCategory(key: string): Promise<number> {
    const list = await QgStore.loadEntries()
    let n = 0
    for (const e of list) {
      if (e.categoryKey === key) {
        n++
      }
    }
    return n
  }

  static async loadUnlocked(): Promise<string[]> {
    return QgStore.splitCsv(await QgStore.getString(KEY_UNLOCKED, ''))
  }

  static async searchAll(q: string): Promise<QgTimelineRow[]> {
    const needle = q.trim()
    const rows = await QgStore.buildTimeline()
    if (needle.length === 0) {
      return rows
    }
    const out: QgTimelineRow[] = []
    for (const r of rows) {
      if (r.title.indexOf(needle) >= 0 || r.subtitle.indexOf(needle) >= 0 || r.dateKey.indexOf(needle) >= 0) {
        out.push(r)
      }
    }
    const entries = await QgStore.loadEntries()
    for (const e of entries) {
      if (e.tagCsv.indexOf(needle) >= 0 || e.categoryKey.indexOf(needle) >= 0 || e.body.indexOf(needle) >= 0) {
        let already = false
        for (const r of out) {
          if (r.id === e.id) {
            already = true
          }
        }
        if (!already) {
          const row = new QgTimelineRow()
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
    const entries = await QgStore.loadEntries()
    const clips = await QgStore.loadClips()
    const themes = await QgStore.loadThemes()
    let s = '{"app":"栖光札","entries":['
    let first = true
    for (const e of entries) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${e.id}","title":"${QgStore.esc(e.title)}","date":"${e.dateKey}","status":"${e.status}"}`
    }
    s += '],"clips":['
    first = true
    for (const c of clips) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${c.id}","text":"${QgStore.esc(c.text)}"}`
    }
    s += '],"themes":['
    first = true
    for (const t of themes) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${t.id}","title":"${QgStore.esc(t.title)}"}`
    }
    s += ']}'
    return s
  }

  static async clearAll(): Promise<void> {
    await QgStore.putString(KEY_ENTRIES, '')
    await QgStore.putString(KEY_CLIPS, '')
    await QgStore.putString(KEY_THEMES, '')
    await QgStore.putString(KEY_ACTIVITY, '')
    await QgStore.putString(KEY_UNLOCKED, '')
    await QgStore.persistCategories(QgCategory.defaults())
    QgStore.bump()
  }

  private static async checkAchievements(): Promise<void> {
    const unlocked = await QgStore.loadUnlocked()
    const stats = await QgStore.computeStats()
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
    const ya = await QgStore.buildYearArchive(year)
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
      await QgStore.putString(KEY_UNLOCKED, unlocked.join(','))
    }
  }

  private static async computeStreak(): Promise<number> {
    const raw = await QgStore.getString(KEY_ACTIVITY, '')
    const days = QgStore.splitLines(raw)
    if (days.length === 0) {
      return 0
    }
    let streak = 0
    const cursor = new Date()
    for (let i = 0; i < 400; i++) {
      const key = QgDateUtil.keyFromDate(cursor)
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
    const raw = await QgStore.getString(KEY_ACTIVITY, '')
    const days = QgStore.splitLines(raw)
    let has = false
    for (const d of days) {
      if (d === dateKey) {
        has = true
      }
    }
    if (!has) {
      days.push(dateKey)
      await QgStore.putString(KEY_ACTIVITY, days.join('\n'))
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
    const parts = QgStore.splitCsv(csv)
    for (const p of parts) {
      if (p === id) {
        return true
      }
    }
    return false
  }

  static toggleCsv(csv: string, id: string): string {
    if (QgStore.csvHas(csv, id)) {
      return QgStore.removeId(csv, id)
    }
    if (csv.length === 0) {
      return id
    }
    return `${csv},${id}`
  }

  private static removeId(csv: string, id: string): string {
    const parts = QgStore.splitCsv(csv)
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

  private static async persistEntries(list: QgEntry[]): Promise<void> {
    const lines: string[] = []
    for (const e of list) {
      lines.push([
        e.id, QgStore.sanitize(e.title), e.dateKey, e.categoryKey, QgStore.sanitizeCsv(e.tagCsv), e.status, e.templateKey,
        QgStore.sanitize(e.fieldA), QgStore.sanitize(e.fieldB), QgStore.sanitize(e.fieldC),
        QgStore.sanitize(e.body), QgStore.sanitizeCsv(e.themeCsv), `${e.createdAt}`, `${e.updatedAt}`
      ].join('\t'))
    }
    await QgStore.putString(KEY_ENTRIES, lines.join('\n'))
  }

  private static parseEntries(raw: string): QgEntry[] {
    const out: QgEntry[] = []
    const lines = QgStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 14) {
        continue
      }
      const e = new QgEntry()
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
    out.sort((a: QgEntry, b: QgEntry) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async persistClips(list: QgClip[]): Promise<void> {
    const lines: string[] = []
    for (const c of list) {
      lines.push([
        c.id, QgStore.sanitize(c.text), c.clipKind, c.dateKey, QgStore.sanitizeCsv(c.tagCsv),
        QgStore.sanitizeCsv(c.themeCsv),
        c.treasured ? '1' : '0', `${c.createdAt}`
      ].join('\t'))
    }
    await QgStore.putString(KEY_CLIPS, lines.join('\n'))
  }

  private static parseClips(raw: string): QgClip[] {
    const out: QgClip[] = []
    const lines = QgStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 8) {
        continue
      }
      const c = new QgClip()
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
    out.sort((a: QgClip, b: QgClip) => b.createdAt - a.createdAt)
    return out
  }

  private static async persistThemes(list: QgTheme[]): Promise<void> {
    const lines: string[] = []
    for (const t of list) {
      lines.push([
        t.id, QgStore.sanitize(t.title), QgStore.sanitize(t.summary), t.coverKey,
        `${t.createdAt}`, `${t.updatedAt}`
      ].join('\t'))
    }
    await QgStore.putString(KEY_THEMES, lines.join('\n'))
  }

  private static parseThemes(raw: string): QgTheme[] {
    const out: QgTheme[] = []
    const lines = QgStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 6) {
        continue
      }
      const t = new QgTheme()
      t.id = p[0]
      t.title = p[1]
      t.summary = p[2]
      t.coverKey = p[3]
      t.createdAt = parseInt(p[4], 10)
      t.updatedAt = parseInt(p[5], 10)
      out.push(t)
    }
    out.sort((a: QgTheme, b: QgTheme) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async persistCategories(list: QgCategory[]): Promise<void> {
    const lines: string[] = []
    for (const c of list) {
      lines.push(`${c.key}\t${c.label}\t${c.sortOrder}`)
    }
    await QgStore.putString(KEY_CATS, lines.join('\n'))
  }

  private static parseCategories(raw: string): QgCategory[] {
    const out: QgCategory[] = []
    const lines = QgStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 3) {
        continue
      }
      out.push(QgCategory.make(p[0], p[1], parseInt(p[2], 10)))
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    const cached = QgStore.mem.get(key)
    if (cached !== undefined) {
      return cached
    }
    if (!(await QgStore.ensurePref()) || QgStore.pref === null) {
      return fallback
    }
    try {
      const v = await QgStore.pref.get(key, fallback)
      if (typeof v === 'string') {
        QgStore.mem.set(key, v)
        return v
      }
      return fallback
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    QgStore.mem.set(key, value)
    if (!(await QgStore.ensurePref()) || QgStore.pref === null) {
      return
    }
    try {
      await QgStore.pref.put(key, value)
      await QgStore.pref.flush()
    } catch {
      // 已写入 mem，同会话可读；落盘失败不阻断 UI 刷新
    }
  }
}
