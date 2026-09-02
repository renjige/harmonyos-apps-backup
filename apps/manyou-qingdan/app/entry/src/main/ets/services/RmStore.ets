import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  RmCategory, RmWish, RmDateUtil, RmChecklist, RmCheckItem, RmPlan, RmLookbackItem, RmProfile,
  RmStats, RmTheme, RmTimelineRow, RmYearArchive
} from '../models/RmModels'
import { AppContextService } from './AppContextService'

const STORE = 'manyou_qingdan_v1'
const KEY_ENTRIES = 'entries'
const KEY_CLIPS = 'clips'
const KEY_ITEMS = 'items'
const KEY_PLANS = 'plans'
const KEY_THEMES = 'themes'
const KEY_CATS = 'categories'
const KEY_TAGS = 'tags'
const KEY_PROFILE = 'profile'
const KEY_ACTIVITY = 'activity'
const KEY_UNLOCKED = 'unlocked'

export class RmStore {
  private static pref: preferences.Preferences | null = null
  /** 同进程读写缓存：避免 Preferences 未就绪时 put 静默失败、首页一直读到空 */
  private static mem: Map<string, string> = new Map()

  static bump(): void {
    const rev = (AppStorage.get<number>('RmDataRev') ?? 0) + 1
    if (!AppStorage.set('RmDataRev', rev)) {
      AppStorage.setOrCreate('RmDataRev', rev)
    }
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    AppContextService.setContext(context)
    try {
      RmStore.pref = await preferences.getPreferences(context, STORE)
      await RmStore.hydrateMemFromPref()
    } catch {
      RmStore.pref = null
    }
    const cats = await RmStore.loadCategories()
    if (cats.length === 0) {
      await RmStore.persistCategories(RmCategory.defaults())
    }
  }

  private static async hydrateMemFromPref(): Promise<void> {
    if (RmStore.pref === null) {
      return
    }
    const keys: string[] = [
      KEY_ENTRIES, KEY_CLIPS, KEY_ITEMS, KEY_PLANS, KEY_THEMES, KEY_CATS, KEY_TAGS,
      KEY_PROFILE, KEY_ACTIVITY, KEY_UNLOCKED
    ]
    for (const key of keys) {
      try {
        const v = await RmStore.pref.get(key, '')
        if (typeof v === 'string') {
          RmStore.mem.set(key, v)
        }
      } catch {
        // ignore single-key hydrate failure
      }
    }
  }

  private static async ensurePref(): Promise<boolean> {
    if (RmStore.pref !== null) {
      return true
    }
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      return false
    }
    try {
      RmStore.pref = await preferences.getPreferences(ctx, STORE)
      await RmStore.hydrateMemFromPref()
      return true
    } catch {
      RmStore.pref = null
      return false
    }
  }

  static async loadChecklists(): Promise<RmChecklist[]> {
    return RmStore.parseEntries(await RmStore.getString(KEY_ENTRIES, ''))
  }

  static async findChecklist(id: string): Promise<RmChecklist | undefined> {
    const list = await RmStore.loadChecklists()
    for (const e of list) {
      if (e.id === id) {
        return e
      }
    }
    return undefined
  }

  static async saveChecklist(entry: RmChecklist): Promise<void> {
    entry.updatedAt = Date.now()
    const list = await RmStore.loadChecklists()
    let found = false
    const next: RmChecklist[] = []
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
    await RmStore.persistEntries(next)
    await RmStore.recordActivity(entry.dateKey)
    await RmStore.checkAchievements()
    RmStore.bump()
  }

  static async deleteChecklist(id: string): Promise<void> {
    const list = await RmStore.loadChecklists()
    const next: RmChecklist[] = []
    for (const e of list) {
      if (e.id !== id) {
        next.push(e)
      }
    }
    await RmStore.persistEntries(next)
    const items = await RmStore.loadItems()
    const kept: RmCheckItem[] = []
    for (const it of items) {
      if (it.checklistId !== id) {
        kept.push(it)
      }
    }
    await RmStore.persistItems(kept)
    RmStore.bump()
  }

  static async loadItems(): Promise<RmCheckItem[]> {
    return RmStore.parseItems(await RmStore.getString(KEY_ITEMS, ''))
  }

  static async itemsForChecklist(checklistId: string): Promise<RmCheckItem[]> {
    const list = await RmStore.loadItems()
    const out: RmCheckItem[] = []
    for (const it of list) {
      if (it.checklistId === checklistId) {
        out.push(it)
      }
    }
    out.sort((a: RmCheckItem, b: RmCheckItem) => a.sortOrder - b.sortOrder)
    return out
  }

  static async findItem(id: string): Promise<RmCheckItem | undefined> {
    const list = await RmStore.loadItems()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async saveItem(item: RmCheckItem): Promise<void> {
    const list = await RmStore.loadItems()
    let found = false
    const next: RmCheckItem[] = []
    for (const it of list) {
      if (it.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    await RmStore.persistItems(next)
    if (item.status === 'done') {
      await RmStore.recordActivity(RmDateUtil.todayKey())
    }
    await RmStore.checkAchievements()
    RmStore.bump()
  }

  static async deleteItem(id: string): Promise<void> {
    const list = await RmStore.loadItems()
    const next: RmCheckItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await RmStore.persistItems(next)
    RmStore.bump()
  }

  static async recentDoneItems(limit: number): Promise<RmCheckItem[]> {
    const list = await RmStore.loadItems()
    const done: RmCheckItem[] = []
    for (const it of list) {
      if (it.status === 'done') {
        done.push(it)
      }
    }
    done.sort((a: RmCheckItem, b: RmCheckItem) => b.completedAt - a.completedAt)
    const out: RmCheckItem[] = []
    for (const it of done) {
      if (out.length >= limit) {
        break
      }
      out.push(it)
    }
    return out
  }

  static async loadPlans(): Promise<RmPlan[]> {
    return RmStore.parsePlans(await RmStore.getString(KEY_PLANS, ''))
  }

  static async savePlan(plan: RmPlan): Promise<void> {
    const list = await RmStore.loadPlans()
    let found = false
    const next: RmPlan[] = []
    for (const p of list) {
      if (p.id === plan.id) {
        next.push(plan)
        found = true
      } else {
        next.push(p)
      }
    }
    if (!found) {
      next.push(plan)
    }
    await RmStore.persistPlans(next)
    RmStore.bump()
  }

  static async deletePlan(id: string): Promise<void> {
    const list = await RmStore.loadPlans()
    const next: RmPlan[] = []
    for (const p of list) {
      if (p.id !== id) {
        next.push(p)
      }
    }
    await RmStore.persistPlans(next)
    RmStore.bump()
  }

  static async loadWishes(): Promise<RmWish[]> {
    return RmStore.parseClips(await RmStore.getString(KEY_CLIPS, ''))
  }

  static async findWish(id: string): Promise<RmWish | undefined> {
    const list = await RmStore.loadWishes()
    for (const c of list) {
      if (c.id === id) {
        return c
      }
    }
    return undefined
  }

  static async saveWish(clip: RmWish): Promise<void> {
    const list = await RmStore.loadWishes()
    let found = false
    const next: RmWish[] = []
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
    await RmStore.persistClips(next)
    await RmStore.recordActivity(clip.dateKey)
    await RmStore.checkAchievements()
    RmStore.bump()
  }

  static async deleteWish(id: string): Promise<void> {
    const list = await RmStore.loadWishes()
    const next: RmWish[] = []
    for (const c of list) {
      if (c.id !== id) {
        next.push(c)
      }
    }
    await RmStore.persistClips(next)
    RmStore.bump()
  }

  static async loadThemes(): Promise<RmTheme[]> {
    return RmStore.parseThemes(await RmStore.getString(KEY_THEMES, ''))
  }

  static async findTheme(id: string): Promise<RmTheme | undefined> {
    const list = await RmStore.loadThemes()
    for (const t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async saveTheme(theme: RmTheme): Promise<void> {
    theme.updatedAt = Date.now()
    const list = await RmStore.loadThemes()
    let found = false
    const next: RmTheme[] = []
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
    await RmStore.persistThemes(next)
    await RmStore.checkAchievements()
    RmStore.bump()
  }

  static async deleteTheme(id: string): Promise<void> {
    const list = await RmStore.loadThemes()
    const next: RmTheme[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    await RmStore.persistThemes(next)
    const entries = await RmStore.loadChecklists()
    for (const e of entries) {
      e.themeCsv = RmStore.removeId(e.themeCsv, id)
    }
    await RmStore.persistEntries(entries)
    const clips = await RmStore.loadWishes()
    for (const c of clips) {
      c.themeCsv = RmStore.removeId(c.themeCsv, id)
    }
    await RmStore.persistClips(clips)
    RmStore.bump()
  }

  static async checklistsForTheme(themeId: string): Promise<RmChecklist[]> {
    const list = await RmStore.loadChecklists()
    const out: RmChecklist[] = []
    for (const e of list) {
      if (RmStore.csvHas(e.themeCsv, themeId)) {
        out.push(e)
      }
    }
    return out
  }

  static async wishesForTheme(themeId: string): Promise<RmWish[]> {
    const list = await RmStore.loadWishes()
    const out: RmWish[] = []
    for (const c of list) {
      if (RmStore.csvHas(c.themeCsv, themeId)) {
        out.push(c)
      }
    }
    return out
  }

  static async loadCategories(): Promise<RmCategory[]> {
    return RmStore.parseCategories(await RmStore.getString(KEY_CATS, ''))
  }

  static async saveCategory(cat: RmCategory): Promise<void> {
    const list = await RmStore.loadCategories()
    let found = false
    const next: RmCategory[] = []
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
    await RmStore.persistCategories(next)
    RmStore.bump()
  }

  static async deleteCategory(key: string): Promise<void> {
    if (key === 'daily') {
      return
    }
    const list = await RmStore.loadCategories()
    const next: RmCategory[] = []
    for (const c of list) {
      if (c.key !== key) {
        next.push(c)
      }
    }
    await RmStore.persistCategories(next)
    RmStore.bump()
  }

  static categoryLabel(key: string, cats: RmCategory[]): string {
    for (const c of cats) {
      if (c.key === key) {
        return c.label
      }
    }
    return '日常'
  }

  static async loadTags(): Promise<string[]> {
    const raw = await RmStore.getString(KEY_TAGS, '')
    if (raw.length === 0) {
      return ['成长', '灵感', '回忆', '重要']
    }
    return RmStore.splitLines(raw)
  }

  static async saveTags(tags: string[]): Promise<void> {
    await RmStore.putString(KEY_TAGS, tags.join('\n'))
    RmStore.bump()
  }

  static async loadProfile(): Promise<RmProfile> {
    const raw = await RmStore.getString(KEY_PROFILE, '')
    const p = new RmProfile()
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

  static async saveProfile(p: RmProfile): Promise<void> {
    await RmStore.putString(KEY_PROFILE, `${p.nickname}\t${p.themeMode}`)
    RmStore.bump()
  }

  static async computeStats(): Promise<RmStats> {
    const s = new RmStats()
    const entries = await RmStore.loadChecklists()
    const clips = await RmStore.loadWishes()
    const themes = await RmStore.loadThemes()
    const items = await RmStore.loadItems()
    s.entryCount = entries.length
    s.clipCount = clips.length
    s.themeCount = themes.length
    s.itemCount = items.length
    for (const e of entries) {
      if (e.status === 'inbox') {
        s.inboxCount++
      }
    }
    for (const it of items) {
      if (it.status === 'done') {
        s.doneItemCount++
      }
      if (it.starred) {
        s.treasureCount++
      }
    }
    for (const c of clips) {
      if (c.treasured) {
        s.treasureCount++
      }
    }
    s.streakDays = await RmStore.computeStreak()
    return s
  }

  static async recentChecklists(limit: number): Promise<RmChecklist[]> {
    const list = await RmStore.loadChecklists()
    list.sort((a: RmChecklist, b: RmChecklist) => b.updatedAt - a.updatedAt)
    const out: RmChecklist[] = []
    for (const e of list) {
      if (out.length >= limit) {
        break
      }
      out.push(e)
    }
    return out
  }

  static async buildTimeline(): Promise<RmTimelineRow[]> {
    const rows: RmTimelineRow[] = []
    const entries = await RmStore.loadChecklists()
    for (const e of entries) {
      const r = new RmTimelineRow()
      r.id = e.id
      r.kind = 'entry'
      r.dateKey = e.dateKey
      r.title = e.title
      r.subtitle = e.summaryText()
      rows.push(r)
    }
    const clips = await RmStore.loadWishes()
    for (const c of clips) {
      const r = new RmTimelineRow()
      r.id = c.id
      r.kind = 'wish'
      r.dateKey = c.dateKey
      r.title = c.text
      r.subtitle = '愿望清单'
      rows.push(r)
    }
    const items = await RmStore.loadItems()
    for (const it of items) {
      if (it.status !== 'done') {
        continue
      }
      const r = new RmTimelineRow()
      r.id = it.id
      r.kind = 'item'
      r.dateKey = it.completedAt > 0 ? RmDateUtil.keyFromDate(new Date(it.completedAt)) : RmDateUtil.todayKey()
      r.title = it.title
      r.subtitle = it.harvest.length > 0 ? it.harvest : '完成一项体验'
      rows.push(r)
    }
    rows.sort((a: RmTimelineRow, b: RmTimelineRow) => b.dateKey.localeCompare(a.dateKey))
    return rows
  }

  static async buildLookback(): Promise<RmLookbackItem> {
    const item = new RmLookbackItem()
    const doneItems = await RmStore.recentDoneItems(1)
    if (doneItems.length > 0) {
      const it = doneItems[0]
      item.title = '最近一次完成'
      item.body = `你完成了「${it.title}」。`
      item.dateKey = it.completedAt > 0 ? RmDateUtil.keyFromDate(new Date(it.completedAt)) : RmDateUtil.todayKey()
      item.sourceKind = 'item'
      item.sourceId = it.id
      return item
    }
    const lists = await RmStore.recentChecklists(1)
    if (lists.length > 0) {
      const cl = lists[0]
      item.title = '清单已创建'
      item.body = `「${cl.title}」等待你的第一项体验。点进清单，添加事项后按「完成」。`
      item.dateKey = cl.dateKey
      item.sourceKind = 'entry'
      item.sourceId = cl.id
      return item
    }
    item.title = '开始漫游'
    item.body = '新建一份体验清单，添加事项并点「完成」，档案就会活起来。'
    return item
  }

  static async buildYearArchive(year: string): Promise<RmYearArchive> {
    const y = new RmYearArchive()
    y.year = year
    const entries = await RmStore.loadChecklists()
    const clips = await RmStore.loadWishes()
    const themes = await RmStore.loadThemes()
    const themeHits: string[] = []
    const tagHits: string[] = []
    for (const e of entries) {
      if (RmDateUtil.yearFromKey(e.dateKey) === year) {
        y.entryCount++
        if (y.highlightTitle.length === 0 && (e.status === 'treasure' || e.status === 'important')) {
          y.highlightTitle = e.title
        }
        const tids = RmStore.splitCsv(e.themeCsv)
        for (const id of tids) {
          themeHits.push(id)
        }
        const tags = RmStore.splitCsv(e.tagCsv)
        for (const t of tags) {
          tagHits.push(t)
        }
      }
    }
    for (const c of clips) {
      if (RmDateUtil.yearFromKey(c.dateKey) === year) {
        y.clipCount++
      }
    }
    y.themeCount = themes.length
    y.topTheme = RmStore.mostFrequent(themeHits)
    y.topTag = RmStore.mostFrequent(tagHits)
    if (y.highlightTitle.length === 0 && entries.length > 0) {
      y.highlightTitle = entries[0].title
    }
    return y
  }

  static async monthCounts(n: number): Promise<number[]> {
    const keys = RmDateUtil.lastNMonths(n)
    const counts: number[] = []
    for (let i = 0; i < keys.length; i++) {
      counts.push(0)
    }
    const entries = await RmStore.loadChecklists()
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

  static async categoryCounts(): Promise<RmCategory[]> {
    return RmStore.loadCategories()
  }

  static async countByCategory(key: string): Promise<number> {
    const list = await RmStore.loadChecklists()
    let n = 0
    for (const e of list) {
      if (e.categoryKey === key) {
        n++
      }
    }
    return n
  }

  static async loadUnlocked(): Promise<string[]> {
    return RmStore.splitCsv(await RmStore.getString(KEY_UNLOCKED, ''))
  }

  static async searchAll(q: string): Promise<RmTimelineRow[]> {
    const needle = q.trim()
    const rows = await RmStore.buildTimeline()
    if (needle.length === 0) {
      return rows
    }
    const out: RmTimelineRow[] = []
    for (const r of rows) {
      if (r.title.indexOf(needle) >= 0 || r.subtitle.indexOf(needle) >= 0 || r.dateKey.indexOf(needle) >= 0) {
        out.push(r)
      }
    }
    const entries = await RmStore.loadChecklists()
    for (const e of entries) {
      if (e.tagCsv.indexOf(needle) >= 0 || e.categoryKey.indexOf(needle) >= 0 || e.body.indexOf(needle) >= 0) {
        let already = false
        for (const r of out) {
          if (r.id === e.id) {
            already = true
          }
        }
        if (!already) {
          const row = new RmTimelineRow()
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
    const entries = await RmStore.loadChecklists()
    const clips = await RmStore.loadWishes()
    const themes = await RmStore.loadThemes()
    let s = '{"app":"漫游札","entries":['
    let first = true
    for (const e of entries) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${e.id}","title":"${RmStore.esc(e.title)}","date":"${e.dateKey}","status":"${e.status}"}`
    }
    s += '],"clips":['
    first = true
    for (const c of clips) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${c.id}","text":"${RmStore.esc(c.text)}"}`
    }
    s += '],"themes":['
    first = true
    for (const t of themes) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${t.id}","title":"${RmStore.esc(t.title)}"}`
    }
    s += ']}'
    return s
  }

  static async clearAll(): Promise<void> {
    await RmStore.putString(KEY_ENTRIES, '')
    await RmStore.putString(KEY_CLIPS, '')
    await RmStore.putString(KEY_ITEMS, '')
    await RmStore.putString(KEY_PLANS, '')
    await RmStore.putString(KEY_THEMES, '')
    await RmStore.putString(KEY_ACTIVITY, '')
    await RmStore.putString(KEY_UNLOCKED, '')
    await RmStore.persistCategories(RmCategory.defaults())
    RmStore.bump()
  }

  private static async checkAchievements(): Promise<void> {
    const unlocked = await RmStore.loadUnlocked()
    const stats = await RmStore.computeStats()
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
    if (stats.doneItemCount >= 20) {
      add.push('clips_20')
    }
    if (stats.themeCount >= 5) {
      add.push('themes_5')
    }
    const year = `${new Date().getFullYear()}`
    const ya = await RmStore.buildYearArchive(year)
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
      await RmStore.putString(KEY_UNLOCKED, unlocked.join(','))
    }
  }

  private static async computeStreak(): Promise<number> {
    const raw = await RmStore.getString(KEY_ACTIVITY, '')
    const days = RmStore.splitLines(raw)
    if (days.length === 0) {
      return 0
    }
    let streak = 0
    const cursor = new Date()
    for (let i = 0; i < 400; i++) {
      const key = RmDateUtil.keyFromDate(cursor)
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
    const raw = await RmStore.getString(KEY_ACTIVITY, '')
    const days = RmStore.splitLines(raw)
    let has = false
    for (const d of days) {
      if (d === dateKey) {
        has = true
      }
    }
    if (!has) {
      days.push(dateKey)
      await RmStore.putString(KEY_ACTIVITY, days.join('\n'))
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
    const parts = RmStore.splitCsv(csv)
    for (const p of parts) {
      if (p === id) {
        return true
      }
    }
    return false
  }

  static toggleCsv(csv: string, id: string): string {
    if (RmStore.csvHas(csv, id)) {
      return RmStore.removeId(csv, id)
    }
    if (csv.length === 0) {
      return id
    }
    return `${csv},${id}`
  }

  private static removeId(csv: string, id: string): string {
    const parts = RmStore.splitCsv(csv)
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

  private static async persistEntries(list: RmChecklist[]): Promise<void> {
    const lines: string[] = []
    for (const e of list) {
      lines.push([
        e.id, RmStore.sanitize(e.title), e.dateKey, e.categoryKey, RmStore.sanitizeCsv(e.tagCsv), e.status, e.templateKey,
        RmStore.sanitize(e.fieldA), RmStore.sanitize(e.fieldB), RmStore.sanitize(e.fieldC),
        RmStore.sanitize(e.body), RmStore.sanitizeCsv(e.themeCsv), `${e.createdAt}`, `${e.updatedAt}`
      ].join('\t'))
    }
    await RmStore.putString(KEY_ENTRIES, lines.join('\n'))
  }

  private static parseEntries(raw: string): RmChecklist[] {
    const out: RmChecklist[] = []
    const lines = RmStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 14) {
        continue
      }
      const e = new RmChecklist()
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
    out.sort((a: RmChecklist, b: RmChecklist) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async persistClips(list: RmWish[]): Promise<void> {
    const lines: string[] = []
    for (const c of list) {
      lines.push([
        c.id, RmStore.sanitize(c.text), c.clipKind, c.dateKey, RmStore.sanitizeCsv(c.tagCsv),
        RmStore.sanitizeCsv(c.themeCsv),
        c.treasured ? '1' : '0', `${c.createdAt}`
      ].join('\t'))
    }
    await RmStore.putString(KEY_CLIPS, lines.join('\n'))
  }

  private static parseClips(raw: string): RmWish[] {
    const out: RmWish[] = []
    const lines = RmStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 8) {
        continue
      }
      const c = new RmWish()
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
    out.sort((a: RmWish, b: RmWish) => b.createdAt - a.createdAt)
    return out
  }

  private static async persistThemes(list: RmTheme[]): Promise<void> {
    const lines: string[] = []
    for (const t of list) {
      lines.push([
        t.id, RmStore.sanitize(t.title), RmStore.sanitize(t.summary), t.coverKey,
        `${t.createdAt}`, `${t.updatedAt}`
      ].join('\t'))
    }
    await RmStore.putString(KEY_THEMES, lines.join('\n'))
  }

  private static parseThemes(raw: string): RmTheme[] {
    const out: RmTheme[] = []
    const lines = RmStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 6) {
        continue
      }
      const t = new RmTheme()
      t.id = p[0]
      t.title = p[1]
      t.summary = p[2]
      t.coverKey = p[3]
      t.createdAt = parseInt(p[4], 10)
      t.updatedAt = parseInt(p[5], 10)
      out.push(t)
    }
    out.sort((a: RmTheme, b: RmTheme) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async persistCategories(list: RmCategory[]): Promise<void> {
    const lines: string[] = []
    for (const c of list) {
      lines.push(`${c.key}\t${c.label}\t${c.sortOrder}`)
    }
    await RmStore.putString(KEY_CATS, lines.join('\n'))
  }

  private static parseCategories(raw: string): RmCategory[] {
    const out: RmCategory[] = []
    const lines = RmStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 3) {
        continue
      }
      out.push(RmCategory.make(p[0], p[1], parseInt(p[2], 10)))
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    const cached = RmStore.mem.get(key)
    if (cached !== undefined) {
      return cached
    }
    if (!(await RmStore.ensurePref()) || RmStore.pref === null) {
      return fallback
    }
    try {
      const v = await RmStore.pref.get(key, fallback)
      if (typeof v === 'string') {
        RmStore.mem.set(key, v)
        return v
      }
      return fallback
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    RmStore.mem.set(key, value)
    if (!(await RmStore.ensurePref()) || RmStore.pref === null) {
      return
    }
    try {
      await RmStore.pref.put(key, value)
      await RmStore.pref.flush()
    } catch {
      // 已写入 mem，同会话可读；落盘失败不阻断 UI 刷新
    }
  }

  private static async persistItems(list: RmCheckItem[]): Promise<void> {
    const lines: string[] = []
    for (const it of list) {
      lines.push([
        it.id, it.checklistId, RmStore.sanitize(it.title), it.status,
        RmStore.sanitize(it.feeling), RmStore.sanitize(it.harvest), RmStore.sanitize(it.note),
        it.starred ? '1' : '0', `${it.completedAt}`, `${it.sortOrder}`
      ].join('\t'))
    }
    await RmStore.putString(KEY_ITEMS, lines.join('\n'))
  }

  private static parseItems(raw: string): RmCheckItem[] {
    const out: RmCheckItem[] = []
    const lines = RmStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 10) {
        continue
      }
      const it = new RmCheckItem()
      it.id = p[0]
      it.checklistId = p[1]
      it.title = p[2]
      it.status = p[3]
      it.feeling = p[4]
      it.harvest = p[5]
      it.note = p[6]
      it.starred = p[7] === '1'
      it.completedAt = parseInt(p[8], 10)
      it.sortOrder = parseInt(p[9], 10)
      out.push(it)
    }
    return out
  }

  private static async persistPlans(list: RmPlan[]): Promise<void> {
    const lines: string[] = []
    for (const p of list) {
      lines.push([
        p.id, RmStore.sanitize(p.title), p.planKind, p.startDate, p.endDate,
        RmStore.sanitizeCsv(p.checklistCsv), `${p.createdAt}`
      ].join('\t'))
    }
    await RmStore.putString(KEY_PLANS, lines.join('\n'))
  }

  private static parsePlans(raw: string): RmPlan[] {
    const out: RmPlan[] = []
    const lines = RmStore.splitLines(raw)
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 7) {
        continue
      }
      const plan = new RmPlan()
      plan.id = p[0]
      plan.title = p[1]
      plan.planKind = p[2]
      plan.startDate = p[3]
      plan.endDate = p[4]
      plan.checklistCsv = p[5]
      plan.createdAt = parseInt(p[6], 10)
      out.push(plan)
    }
    out.sort((a: RmPlan, b: RmPlan) => b.createdAt - a.createdAt)
    return out
  }
}
