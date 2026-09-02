import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { DayGroup, HeatDay, InsightEntry, InsightNotebook, InsightTagCount, MonthGroup, TitleGuard, UserProfile } from '../models/InsightModels'
import { DateHelper } from './DateHelper'
import { SensitiveFilter } from './SensitiveFilter'
import { AppContextService } from './AppContextService'
import { AchievementService } from './AchievementService'
import { GrowthStore } from './GrowthStore'

const STORE = 'jianjiebu_v1'
const KEY_ENTRIES = 'entries'
const KEY_NOTEBOOKS = 'notebooks'
const KEY_PROFILE = 'profile'

export class InsightStore {
  private static pref: preferences.Preferences | null = null
  static lastError: string = ''

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      InsightStore.pref = await preferences.getPreferences(context, STORE)
      await InsightStore.ensureDefaultNotebooks()
      await GrowthStore.ensurePref()
    } catch {
      InsightStore.pref = null
    }
  }

  static async loadAll(): Promise<InsightEntry[]> {
    const raw = await InsightStore.getString(KEY_ENTRIES, '')
    return InsightStore.parseEntries(raw)
  }

  static async loadNotebooks(): Promise<InsightNotebook[]> {
    const raw = await InsightStore.getString(KEY_NOTEBOOKS, '')
    const list = InsightStore.parseNotebooks(raw)
    if (list.length === 0) {
      return InsightStore.defaultNotebooks()
    }
    return list
  }

  static async findById(id: string): Promise<InsightEntry | undefined> {
    const list = await InsightStore.loadAll()
    for (const n of list) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static async saveEntry(entry: InsightEntry): Promise<boolean> {
    InsightStore.lastError = ''
    const title = entry.title.trim()
    if (!TitleGuard.isValid(title)) {
      InsightStore.lastError = '标题仅可用中文、字母、数字和空格，不可含表情或特殊符号'
      return false
    }
    const hit = SensitiveFilter.scan(`${title}\n${entry.body}`)
    if (hit.length > 0) {
      InsightStore.lastError = `含有不宜发布内容，请修改后再保存`
      return false
    }
    if (entry.body.trim().length === 0 && entry.imagePath.length === 0) {
      InsightStore.lastError = '请写下正文或插入一张配图'
      return false
    }
    entry.title = title
    entry.updatedAt = Date.now()
    if (entry.createdAt === 0) {
      entry.createdAt = entry.updatedAt
    }
    if (entry.dateKey.length === 0) {
      entry.dateKey = DateHelper.todayKey()
    }
    const list = await InsightStore.loadAll()
    const next: InsightEntry[] = []
    let replaced = false
    let wasNew = true
    for (const n of list) {
      if (n.id === entry.id) {
        replaced = true
        wasNew = false
      }
    }
    for (const n of list) {
      if (n.id === entry.id) {
        next.push(entry)
        replaced = true
      } else {
        next.push(n)
      }
    }
    if (!replaced) {
      next.push(entry)
    }
    InsightStore.sortEntries(next)
    const wrote = await InsightStore.persistEntries(next)
    if (!wrote) {
      InsightStore.lastError = InsightStore.lastError.length > 0 ? InsightStore.lastError : '保存失败，请重试'
      return false
    }
    if (wasNew) {
      const unlocks = await AchievementService.onEntryCreated(entry)
      InsightStore.publishUnlocks(unlocks)
    } else {
      const unlocks = await AchievementService.evaluateAll()
      InsightStore.publishUnlocks(unlocks)
    }
    return true
  }

  static async deleteEntry(id: string): Promise<void> {
    const list = await InsightStore.loadAll()
    const next: InsightEntry[] = []
    for (const n of list) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    await InsightStore.persistEntries(next)
  }

  static async groupedByDay(keyword: string): Promise<DayGroup[]> {
    const list = await InsightStore.search(keyword)
    const map = new Map<string, InsightEntry[]>()
    const keys: string[] = []
    for (const n of list) {
      if (!map.has(n.dateKey)) {
        map.set(n.dateKey, [])
        keys.push(n.dateKey)
      }
      const bucket = map.get(n.dateKey)
      if (bucket !== undefined) {
        bucket.push(n)
      }
    }
    const groups: DayGroup[] = []
    for (const k of keys) {
      const g = new DayGroup()
      g.dateKey = k
      const items = map.get(k)
      g.items = items !== undefined ? items : []
      groups.push(g)
    }
    return groups
  }

  static async search(keyword: string): Promise<InsightEntry[]> {
    const list = await InsightStore.loadAll()
    const q = keyword.trim()
    if (q.length === 0) {
      return list
    }
    const out: InsightEntry[] = []
    for (const n of list) {
      if (n.title.indexOf(q) >= 0 || n.body.indexOf(q) >= 0 || n.tags.indexOf(q) >= 0 ||
        n.reviewNote.indexOf(q) >= 0) {
        out.push(n)
      }
    }
    return out
  }

  static async patchMeta(id: string, starred: boolean, pinned: boolean, verdict: string): Promise<boolean> {
    InsightStore.lastError = ''
    const list = await InsightStore.loadAll()
    const next: InsightEntry[] = []
    let found: InsightEntry | undefined = undefined
    let prevStar = false
    let prevVerdict = ''
    for (const n of list) {
      if (n.id === id) {
        prevStar = n.starred
        prevVerdict = n.verdict
        n.starred = starred
        n.pinned = pinned
        n.verdict = verdict
        n.updatedAt = Date.now()
        found = n
      }
      next.push(n)
    }
    if (found === undefined) {
      InsightStore.lastError = '找不到这条见解'
      return false
    }
    const wrote = await InsightStore.persistEntries(next)
    if (!wrote) {
      InsightStore.lastError = InsightStore.lastError.length > 0 ? InsightStore.lastError : '保存失败，请重试'
      return false
    }
    let unlocks: string[] = []
    if (starred && !prevStar) {
      unlocks = await AchievementService.onStarChanged(true, found)
    } else if (verdict.length > 0 && verdict !== prevVerdict &&
      (verdict === 'hit' || verdict === 'miss' || verdict === 'revised')) {
      unlocks = await AchievementService.onVerdictChanged(found)
    } else {
      unlocks = await AchievementService.evaluateAll()
    }
    InsightStore.publishUnlocks(unlocks)
    return true
  }

  private static publishUnlocks(ids: string[]): void {
    if (ids.length === 0) {
      return
    }
    AppStorage.setOrCreate('lastAchievementUnlock', ids[0])
    AppStorage.setOrCreate('achievementToastAt', Date.now())
  }

  static async randomOne(excludeId: string): Promise<InsightEntry | undefined> {
    const list = await InsightStore.loadAll()
    const pool: InsightEntry[] = []
    const today = DateHelper.todayKey()
    for (const n of list) {
      if (n.id !== excludeId) {
        pool.push(n)
      }
    }
    if (pool.length === 0) {
      return undefined
    }
    const older: InsightEntry[] = []
    for (const n of pool) {
      if (n.dateKey !== today) {
        older.push(n)
      }
    }
    const src = older.length > 0 ? older : pool
    const idx = Math.floor(Math.random() * src.length)
    if (idx < 0 || idx >= src.length) {
      return src[0]
    }
    return src[idx]
  }

  static async judgments(): Promise<InsightEntry[]> {
    const list = await InsightStore.loadAll()
    const out: InsightEntry[] = []
    for (const n of list) {
      if (n.frameKind === 'judge' || n.verdict.length > 0) {
        out.push(n)
      }
    }
    return out
  }

  static async quotes(): Promise<InsightEntry[]> {
    const list = await InsightStore.loadAll()
    const out: InsightEntry[] = []
    for (const n of list) {
      if (n.frameKind === 'quote' || n.tags.indexOf('金句') >= 0) {
        out.push(n)
      }
    }
    return out
  }

  static async adoptAsJudgment(id: string): Promise<boolean> {
    const found = await InsightStore.findById(id)
    if (found === undefined) {
      InsightStore.lastError = '找不到这条见解'
      return false
    }
    found.frameKind = 'judge'
    if (found.verdict.length === 0) {
      found.verdict = 'pending'
    }
    return InsightStore.saveEntry(found)
  }

  static async latestId(): Promise<string> {
    const list = await InsightStore.loadAll()
    if (list.length === 0) {
      return ''
    }
    return list[0].id
  }

  static async starred(): Promise<InsightEntry[]> {
    const list = await InsightStore.loadAll()
    const out: InsightEntry[] = []
    for (const n of list) {
      if (n.starred) {
        out.push(n)
      }
    }
    return out
  }

  static async pinned(): Promise<InsightEntry[]> {
    const list = await InsightStore.loadAll()
    const out: InsightEntry[] = []
    for (const n of list) {
      if (n.pinned) {
        out.push(n)
      }
    }
    return out
  }

  static async related(entry: InsightEntry): Promise<InsightEntry[]> {
    const tags = entry.tagList()
    const list = await InsightStore.loadAll()
    const out: InsightEntry[] = []
    for (const n of list) {
      if (n.id === entry.id) {
        continue
      }
      if (entry.notebookId.length > 0 && n.notebookId === entry.notebookId) {
        out.push(n)
        if (out.length >= 5) {
          break
        }
        continue
      }
      const nt = n.tagList()
      let hit = false
      for (const t of tags) {
        for (const x of nt) {
          if (t === x) {
            hit = true
          }
        }
      }
      if (hit) {
        out.push(n)
      }
      if (out.length >= 5) {
        break
      }
    }
    return out
  }

  static async containingWord(word: string): Promise<InsightEntry[]> {
    const list = await InsightStore.loadAll()
    const out: InsightEntry[] = []
    for (const n of list) {
      if (n.title.indexOf(word) >= 0 || n.body.indexOf(word) >= 0 || n.tags.indexOf(word) >= 0) {
        out.push(n)
      }
    }
    return out
  }

  static async heatmap28(): Promise<HeatDay[]> {
    const keys = DateHelper.lastNDays(28)
    const list = await InsightStore.loadAll()
    const map = new Map<string, number>()
    for (const n of list) {
      const cur = map.get(n.dateKey)
      map.set(n.dateKey, (cur !== undefined ? cur : 0) + 1)
    }
    const out: HeatDay[] = []
    for (let i = keys.length - 1; i >= 0; i--) {
      const k = keys[i]
      const d = new HeatDay()
      d.dateKey = k
      const c = map.get(k)
      d.count = c !== undefined ? c : 0
      const parsed = DateHelper.parseKey(k)
      d.label = `${parsed.getMonth() + 1}/${parsed.getDate()}`
      out.push(d)
    }
    return out
  }

  static async weekBars(): Promise<number[]> {
    const keys = DateHelper.lastNDays(7)
    const list = await InsightStore.loadAll()
    const vals: number[] = []
    for (let i = keys.length - 1; i >= 0; i--) {
      let c = 0
      for (const n of list) {
        if (n.dateKey === keys[i]) {
          c++
        }
      }
      vals.push(c)
    }
    return vals
  }

  static async addNotebook(name: string): Promise<boolean> {
    const trimmed = name.trim()
    if (trimmed.length === 0 || trimmed.length > 16) {
      InsightStore.lastError = '笔记本名称 1–16 字'
      return false
    }
    const list = await InsightStore.loadNotebooks()
    for (const b of list) {
      if (b.name === trimmed) {
        InsightStore.lastError = '已有同名笔记本'
        return false
      }
    }
    list.push(InsightNotebook.make(`nb_${Date.now()}`, trimmed))
    await InsightStore.persistNotebooks(list)
    return true
  }

  static async byTag(tag: string): Promise<InsightEntry[]> {
    const list = await InsightStore.loadAll()
    const out: InsightEntry[] = []
    for (const n of list) {
      const tags = n.tagList()
      for (const t of tags) {
        if (t === tag) {
          out.push(n)
        }
      }
    }
    return out
  }

  static async byNotebook(notebookId: string): Promise<InsightEntry[]> {
    const list = await InsightStore.loadAll()
    const out: InsightEntry[] = []
    for (const n of list) {
      if (n.notebookId === notebookId) {
        out.push(n)
      }
    }
    return out
  }

  static async byMonth(monthKey: string): Promise<InsightEntry[]> {
    const list = await InsightStore.loadAll()
    const out: InsightEntry[] = []
    for (const n of list) {
      if (DateHelper.monthKey(n.dateKey) === monthKey) {
        out.push(n)
      }
    }
    return out
  }

  static async tagCloud(): Promise<InsightTagCount[]> {
    const list = await InsightStore.loadAll()
    const map = new Map<string, number>()
    const names: string[] = []
    for (const n of list) {
      const tags = n.tagList()
      for (const t of tags) {
        if (!map.has(t)) {
          map.set(t, 0)
          names.push(t)
        }
        const cur = map.get(t)
        map.set(t, (cur !== undefined ? cur : 0) + 1)
      }
    }
    const out: InsightTagCount[] = []
    for (const name of names) {
      const c = new InsightTagCount()
      c.name = name
      const n = map.get(name)
      c.count = n !== undefined ? n : 0
      out.push(c)
    }
    out.sort((a, b) => b.count - a.count)
    return out
  }

  static async monthGroups(): Promise<MonthGroup[]> {
    const list = await InsightStore.loadAll()
    const map = new Map<string, number>()
    const keys: string[] = []
    for (const n of list) {
      const mk = DateHelper.monthKey(n.dateKey)
      if (!map.has(mk)) {
        map.set(mk, 0)
        keys.push(mk)
      }
      const cur = map.get(mk)
      map.set(mk, (cur !== undefined ? cur : 0) + 1)
    }
    const out: MonthGroup[] = []
    for (const k of keys) {
      const g = new MonthGroup()
      g.monthKey = k
      g.label = DateHelper.monthLabel(k)
      const n = map.get(k)
      g.count = n !== undefined ? n : 0
      out.push(g)
    }
    return out
  }

  static async notebookName(id: string): Promise<string> {
    const books = await InsightStore.loadNotebooks()
    for (const b of books) {
      if (b.id === id) {
        return b.name
      }
    }
    return '未分簿'
  }

  static async streakDays(): Promise<number> {
    const list = await InsightStore.loadAll()
    const set = new Set<string>()
    for (const n of list) {
      set.add(n.dateKey)
    }
    let streak = 0
    const cursor = new Date()
    while (true) {
      const key = DateHelper.keyFromDate(cursor)
      if (!set.has(key)) {
        break
      }
      streak++
      cursor.setDate(cursor.getDate() - 1)
      if (streak > 365) {
        break
      }
    }
    return streak
  }

  static async loadProfile(): Promise<UserProfile> {
    const raw = await InsightStore.getString(KEY_PROFILE, '')
    const p = new UserProfile()
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

  static async saveProfile(profile: UserProfile): Promise<void> {
    await InsightStore.putString(KEY_PROFILE, `${profile.nickname}\t${profile.themeMode}`)
  }

  static async exportJson(): Promise<string> {
    const list = await InsightStore.loadAll()
    const lines: string[] = []
    lines.push('{"app":"见解簿","notes":[')
    for (let i = 0; i < list.length; i++) {
      const n = list[i]
      const title = n.title.replace(/\\/g, '\\\\').replace(/"/g, '\\"')
      const body = n.body.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n')
      const comma = i < list.length - 1 ? ',' : ''
      lines.push(`{"id":"${n.id}","title":"${title}","body":"${body}","dateKey":"${n.dateKey}","tags":"${n.tags}"}${comma}`)
    }
    lines.push(']}')
    return lines.join('')
  }

  private static async ensureDefaultNotebooks(): Promise<void> {
    const raw = await InsightStore.getString(KEY_NOTEBOOKS, '')
    if (raw.length > 0) {
      return
    }
    await InsightStore.persistNotebooks(InsightStore.defaultNotebooks())
  }

  private static defaultNotebooks(): InsightNotebook[] {
    const list: InsightNotebook[] = []
    list.push(InsightNotebook.make('nb_work', '工作洞见'))
    list.push(InsightNotebook.make('nb_read', '阅读札记'))
    list.push(InsightNotebook.make('nb_life', '生活沉淀'))
    return list
  }

  static sortEntries(items: InsightEntry[]): void {
    items.sort((a: InsightEntry, b: InsightEntry) => {
      if (a.pinned && !b.pinned) {
        return -1
      }
      if (!a.pinned && b.pinned) {
        return 1
      }
      return b.updatedAt - a.updatedAt
    })
  }

  private static async persistEntries(items: InsightEntry[]): Promise<boolean> {
    if (InsightStore.pref === null) {
      const ctx = AppContextService.getContext()
      if (ctx !== null) {
        await InsightStore.init(ctx)
      }
    }
    if (InsightStore.pref === null) {
      InsightStore.lastError = '本地存储尚未就绪'
      return false
    }
    const lines: string[] = []
    for (const n of items) {
      lines.push(InsightStore.serializeEntry(n))
    }
    await InsightStore.putString(KEY_ENTRIES, lines.join('\n'))
    return true
  }

  private static async persistNotebooks(items: InsightNotebook[]): Promise<void> {
    const lines: string[] = []
    for (const n of items) {
      lines.push(`${n.id}\t${n.name}\t${n.createdAt}`)
    }
    await InsightStore.putString(KEY_NOTEBOOKS, lines.join('\n'))
  }

  private static serializeEntry(n: InsightEntry): string {
    const title = n.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const body = n.body.replace(/\t/g, ' ').replace(/\n/g, '\\n')
    const img = n.imagePath.replace(/\t/g, '')
    const tags = n.tags.replace(/\t/g, ',')
    const note = n.reviewNote.replace(/\t/g, ' ').replace(/\n/g, '\\n')
    const star = n.starred ? '1' : '0'
    const pin = n.pinned ? '1' : '0'
    const frame = n.frameKind.replace(/\t/g, '')
    const verdict = n.verdict.replace(/\t/g, '')
    return [n.id, title, body, img, n.notebookId, tags, n.dateKey, `${n.createdAt}`, `${n.updatedAt}`,
      star, pin, frame, note, verdict].join('\t')
  }

  private static parseEntries(raw: string): InsightEntry[] {
    const out: InsightEntry[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 9) {
        continue
      }
      const e = new InsightEntry()
      e.id = parts[0]
      e.title = parts[1]
      e.body = parts[2].replace(/\\n/g, '\n')
      e.imagePath = parts[3]
      e.notebookId = parts[4]
      e.tags = parts[5]
      e.dateKey = parts[6]
      e.createdAt = parseInt(parts[7], 10)
      e.updatedAt = parseInt(parts[8], 10)
      if (parts.length >= 13) {
        e.starred = parts[9] === '1'
        e.pinned = parts[10] === '1'
        e.frameKind = parts[11]
        e.reviewNote = parts[12].replace(/\\n/g, '\n')
      }
      if (parts.length >= 14) {
        e.verdict = parts[13]
      }
      out.push(e)
    }
    InsightStore.sortEntries(out)
    return out
  }

  private static parseNotebooks(raw: string): InsightNotebook[] {
    const out: InsightNotebook[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('\t')
      if (parts.length < 2) {
        continue
      }
      const n = new InsightNotebook()
      n.id = parts[0]
      n.name = parts[1]
      n.createdAt = parts.length >= 3 ? parseInt(parts[2], 10) : 0
      out.push(n)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (InsightStore.pref === null) {
      return fallback
    }
    try {
      const v = await InsightStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (InsightStore.pref === null) {
      return
    }
    try {
      await InsightStore.pref.put(key, value)
      await InsightStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
