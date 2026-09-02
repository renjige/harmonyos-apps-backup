import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { DayCell, MemoryBooklet, MemoryRecord } from '../models/MemoryModels'

const STORE = 'huiyi_ce_v1'
const KEY_ITEMS = 'memories'
const KEY_BOOKLETS = 'booklets'
const KEY_DARK = 'dark_mode'
const DAY_MS = 24 * 60 * 60 * 1000

export class MemoryStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      MemoryStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      MemoryStore.pref = null
    }
  }

  static async loadAll(): Promise<MemoryRecord[]> {
    const raw = await MemoryStore.getString(KEY_ITEMS, '')
    return MemoryStore.parse(raw)
  }

  static async loadActive(): Promise<MemoryRecord[]> {
    const list = await MemoryStore.loadAll()
    const out: MemoryRecord[] = []
    for (const it of list) {
      if (!it.archived) {
        out.push(it)
      }
    }
    return out
  }

  static async loadArchived(): Promise<MemoryRecord[]> {
    const list = await MemoryStore.loadAll()
    const out: MemoryRecord[] = []
    for (const it of list) {
      if (it.archived) {
        out.push(it)
      }
    }
    return out
  }

  static async loadFavorites(): Promise<MemoryRecord[]> {
    const list = await MemoryStore.loadActive()
    const out: MemoryRecord[] = []
    for (const it of list) {
      if (it.favorite) {
        out.push(it)
      }
    }
    return out
  }

  static async loadPinned(): Promise<MemoryRecord[]> {
    const list = await MemoryStore.loadActive()
    const out: MemoryRecord[] = []
    for (const it of list) {
      if (it.pinned) {
        out.push(it)
      }
    }
    return out
  }

  static async loadDueReview(): Promise<MemoryRecord[]> {
    const list = await MemoryStore.loadActive()
    const now = Date.now()
    const out: MemoryRecord[] = []
    for (const it of list) {
      if (it.dueReview(now)) {
        out.push(it)
      }
    }
    return out
  }

  static async save(record: MemoryRecord): Promise<void> {
    record.updateTime = Date.now()
    const list = await MemoryStore.loadAll()
    const next: MemoryRecord[] = []
    let found = false
    for (const it of list) {
      if (it.id === record.id) {
        next.push(record)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(record)
    }
    next.sort((a: MemoryRecord, b: MemoryRecord) => {
      if (a.pinned !== b.pinned) {
        return a.pinned ? -1 : 1
      }
      return b.createTime - a.createTime
    })
    await MemoryStore.persist(next)
  }

  static async deleteById(id: string): Promise<void> {
    const list = await MemoryStore.loadAll()
    const next: MemoryRecord[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await MemoryStore.persist(next)
    await MemoryStore.dropRecordFromBooklets(id)
  }

  static async findById(id: string): Promise<MemoryRecord | undefined> {
    const list = await MemoryStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async byTag(name: string): Promise<MemoryRecord[]> {
    const list = await MemoryStore.loadActive()
    const out: MemoryRecord[] = []
    for (const it of list) {
      if (it.hasTag(name)) {
        out.push(it)
      }
    }
    return out
  }

  static async byDateKey(key: string): Promise<MemoryRecord[]> {
    const list = await MemoryStore.loadActive()
    const out: MemoryRecord[] = []
    for (const it of list) {
      if (MemoryStore.dateKey(it.createTime) === key) {
        out.push(it)
      }
    }
    return out
  }

  static async search(query: string): Promise<MemoryRecord[]> {
    const q = query.trim()
    const list = await MemoryStore.loadActive()
    if (q.length === 0) {
      return list
    }
    const out: MemoryRecord[] = []
    for (const it of list) {
      if (it.content.indexOf(q) >= 0 || it.tagLine().indexOf(q) >= 0) {
        out.push(it)
      }
    }
    return out
  }

  static async randomOne(): Promise<MemoryRecord | undefined> {
    const list = await MemoryStore.loadActive()
    if (list.length === 0) {
      return undefined
    }
    const idx = Math.floor(Math.random() * list.length)
    return list[idx]
  }

  static async relatedOf(id: string): Promise<MemoryRecord[]> {
    const me = await MemoryStore.findById(id)
    if (me === undefined) {
      return []
    }
    const tag = me.primaryTag()
    const list = await MemoryStore.loadActive()
    const out: MemoryRecord[] = []
    for (const it of list) {
      if (it.id === id) {
        continue
      }
      const same = tag === '未分类' ? it.isUnclassified() : it.hasTag(tag)
      if (same) {
        out.push(it)
      }
      if (out.length >= 3) {
        break
      }
    }
    return out
  }

  static async markReviewed(id: string): Promise<void> {
    const found = await MemoryStore.findById(id)
    if (found === undefined) {
      return
    }
    found.lastReviewAt = Date.now()
    found.reviewCount = found.reviewCount + 1
    await MemoryStore.save(found)
  }

  static async togglePin(id: string): Promise<void> {
    const found = await MemoryStore.findById(id)
    if (found === undefined) {
      return
    }
    found.pinned = !found.pinned
    await MemoryStore.save(found)
  }

  static async toggleFavorite(id: string): Promise<void> {
    const found = await MemoryStore.findById(id)
    if (found === undefined) {
      return
    }
    found.favorite = !found.favorite
    await MemoryStore.save(found)
  }

  static async toggleArchive(id: string): Promise<void> {
    const found = await MemoryStore.findById(id)
    if (found === undefined) {
      return
    }
    found.archived = !found.archived
    await MemoryStore.save(found)
  }

  static async loadBooklets(): Promise<MemoryBooklet[]> {
    const raw = await MemoryStore.getString(KEY_BOOKLETS, '')
    return MemoryStore.parseBooklets(raw)
  }

  static async saveBooklet(book: MemoryBooklet): Promise<void> {
    const list = await MemoryStore.loadBooklets()
    const next: MemoryBooklet[] = []
    let found = false
    for (const it of list) {
      if (it.id === book.id) {
        next.push(book)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(book)
    }
    next.sort((a: MemoryBooklet, b: MemoryBooklet) => b.createdAt - a.createdAt)
    await MemoryStore.persistBooklets(next)
  }

  static async deleteBooklet(id: string): Promise<void> {
    const list = await MemoryStore.loadBooklets()
    const next: MemoryBooklet[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await MemoryStore.persistBooklets(next)
  }

  static async findBooklet(id: string): Promise<MemoryBooklet | undefined> {
    const list = await MemoryStore.loadBooklets()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async recordsOfBooklet(id: string): Promise<MemoryRecord[]> {
    const book = await MemoryStore.findBooklet(id)
    if (book === undefined) {
      return []
    }
    const out: MemoryRecord[] = []
    for (const rid of book.recordIds) {
      const rec = await MemoryStore.findById(rid)
      if (rec !== undefined && !rec.archived) {
        out.push(rec)
      }
    }
    return out
  }

  static async addToBooklet(bookletId: string, recordId: string): Promise<boolean> {
    const book = await MemoryStore.findBooklet(bookletId)
    if (book === undefined) {
      return false
    }
    for (const rid of book.recordIds) {
      if (rid === recordId) {
        return false
      }
    }
    const ids: string[] = []
    for (const rid of book.recordIds) {
      ids.push(rid)
    }
    ids.push(recordId)
    book.recordIds = ids
    await MemoryStore.saveBooklet(book)
    return true
  }

  static async removeFromBooklet(bookletId: string, recordId: string): Promise<void> {
    const book = await MemoryStore.findBooklet(bookletId)
    if (book === undefined) {
      return
    }
    const ids: string[] = []
    for (const rid of book.recordIds) {
      if (rid !== recordId) {
        ids.push(rid)
      }
    }
    book.recordIds = ids
    await MemoryStore.saveBooklet(book)
  }

  static async exportAllText(): Promise<string> {
    return MemoryStore.buildExport(await MemoryStore.loadAll(), '全部记忆')
  }

  static async exportFavoritesText(): Promise<string> {
    return MemoryStore.buildExport(await MemoryStore.loadFavorites(), '收藏记忆')
  }

  static async exportBookletText(id: string): Promise<string> {
    const book = await MemoryStore.findBooklet(id)
    const title = book === undefined ? '记忆册' : book.title
    return MemoryStore.buildExport(await MemoryStore.recordsOfBooklet(id), `记忆册 · ${title}`)
  }

  static async loadDark(): Promise<boolean> {
    const v = await MemoryStore.getString(KEY_DARK, '0')
    return v === '1'
  }

  static async saveDark(dark: boolean): Promise<void> {
    await MemoryStore.putString(KEY_DARK, dark ? '1' : '0')
  }

  static timeLabel(ms: number): string {
    const d = new Date(ms)
    return `${d.getFullYear()}-${MemoryStore.pad(d.getMonth() + 1)}-${MemoryStore.pad(d.getDate())} ${MemoryStore.pad(d.getHours())}:${MemoryStore.pad(d.getMinutes())}`
  }

  static dateKey(ms: number): string {
    const d = new Date(ms)
    return `${d.getFullYear()}-${MemoryStore.pad(d.getMonth() + 1)}-${MemoryStore.pad(d.getDate())}`
  }

  static todayKey(): string {
    return MemoryStore.dateKey(Date.now())
  }

  static monthGrid(year: number, month: number, filled: string[]): DayCell[] {
    const cells: DayCell[] = []
    const first = new Date(year, month - 1, 1)
    let pad = first.getDay()
    pad = pad === 0 ? 6 : pad - 1
    for (let i = 0; i < pad; i++) {
      const c = new DayCell()
      c.isPad = true
      c.dateKey = `pad-${i}`
      cells.push(c)
    }
    const days = new Date(year, month, 0).getDate()
    const today = MemoryStore.todayKey()
    for (let d = 1; d <= days; d++) {
      const c = new DayCell()
      c.dayNum = d
      c.dateKey = `${year}-${MemoryStore.pad(month)}-${MemoryStore.pad(d)}`
      c.isToday = c.dateKey === today
      for (const k of filled) {
        if (k === c.dateKey) {
          c.hasEntry = true
        }
      }
      cells.push(c)
    }
    return cells
  }

  static filledDateKeys(list: MemoryRecord[]): string[] {
    const keys: string[] = []
    for (const it of list) {
      const k = MemoryStore.dateKey(it.createTime)
      let seen = false
      for (const e of keys) {
        if (e === k) {
          seen = true
        }
      }
      if (!seen) {
        keys.push(k)
      }
    }
    return keys
  }

  static streakDays(list: MemoryRecord[]): number {
    const set: string[] = MemoryStore.filledDateKeys(list)
    let streak = 0
    let cursor = new Date()
    cursor.setHours(0, 0, 0, 0)
    while (true) {
      const key = MemoryStore.dateKey(cursor.getTime())
      let hit = false
      for (const k of set) {
        if (k === key) {
          hit = true
        }
      }
      if (!hit) {
        break
      }
      streak++
      cursor = new Date(cursor.getTime() - DAY_MS)
    }
    return streak
  }

  private static buildExport(list: MemoryRecord[], title: string): string {
    const lines: string[] = []
    lines.push(`慧忆册 — ${title}`)
    lines.push(`共 ${list.length} 条`)
    lines.push('')
    for (const it of list) {
      lines.push('---')
      lines.push(MemoryStore.timeLabel(it.createTime))
      lines.push(`标签：${it.tagLine()}`)
      if (it.favorite) {
        lines.push('收藏：是')
      }
      lines.push(it.content)
      lines.push('')
    }
    return lines.join('\n')
  }

  private static async dropRecordFromBooklets(recordId: string): Promise<void> {
    const list = await MemoryStore.loadBooklets()
    for (const b of list) {
      const ids: string[] = []
      let changed = false
      for (const rid of b.recordIds) {
        if (rid === recordId) {
          changed = true
        } else {
          ids.push(rid)
        }
      }
      if (changed) {
        b.recordIds = ids
        await MemoryStore.saveBooklet(b)
      }
    }
  }

  private static pad(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  private static flag(v: boolean): string {
    return v ? '1' : '0'
  }

  private static isOne(s: string): boolean {
    return s === '1'
  }

  private static num(s: string): number {
    if (s.length === 0) {
      return 0
    }
    const n = Number.parseInt(s, 10)
    if (n !== n) {
      return 0
    }
    return n
  }

  private static async persist(items: MemoryRecord[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(MemoryStore.serialize(it))
    }
    await MemoryStore.putString(KEY_ITEMS, lines.join('\n'))
  }

  private static serialize(it: MemoryRecord): string {
    const body = it.content.replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/\t/g, '\\t')
    const tags = it.tags.join(',')
    return [
      it.id, body, tags, `${it.createTime}`, `${it.updateTime}`,
      MemoryStore.flag(it.pinned), MemoryStore.flag(it.favorite), it.templateKey,
      `${it.reviewCount}`, `${it.lastReviewAt}`, MemoryStore.flag(it.archived)
    ].join('\t')
  }

  private static parse(raw: string): MemoryRecord[] {
    const out: MemoryRecord[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 5) {
        continue
      }
      const e = new MemoryRecord()
      e.id = parts[0]
      e.content = parts[1].replace(/\\n/g, '\n').replace(/\\t/g, '\t').replace(/\\\\/g, '\\')
      e.tags = parts[2].length === 0 ? [] : parts[2].split(',')
      e.createTime = MemoryStore.num(parts[3])
      e.updateTime = MemoryStore.num(parts[4])
      if (parts.length >= 6) {
        e.pinned = MemoryStore.isOne(parts[5])
      }
      if (parts.length >= 7) {
        e.favorite = MemoryStore.isOne(parts[6])
      }
      if (parts.length >= 8) {
        e.templateKey = parts[7]
      }
      if (parts.length >= 9) {
        e.reviewCount = MemoryStore.num(parts[8])
      }
      if (parts.length >= 10) {
        e.lastReviewAt = MemoryStore.num(parts[9])
      }
      if (parts.length >= 11) {
        e.archived = MemoryStore.isOne(parts[10])
      }
      out.push(e)
    }
    out.sort((a: MemoryRecord, b: MemoryRecord) => {
      if (a.pinned !== b.pinned) {
        return a.pinned ? -1 : 1
      }
      return b.createTime - a.createTime
    })
    return out
  }

  private static async persistBooklets(items: MemoryBooklet[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(MemoryStore.serializeBooklet(it))
    }
    await MemoryStore.putString(KEY_BOOKLETS, lines.join('\n'))
  }

  private static serializeBooklet(it: MemoryBooklet): string {
    const title = it.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const summary = it.summary.replace(/\t/g, ' ').replace(/\n/g, ' ')
    return [it.id, title, summary, `${it.createdAt}`, it.recordIds.join(',')].join('\t')
  }

  private static parseBooklets(raw: string): MemoryBooklet[] {
    const out: MemoryBooklet[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 4) {
        continue
      }
      const b = new MemoryBooklet()
      b.id = parts[0]
      b.title = parts[1]
      b.summary = parts[2]
      b.createdAt = MemoryStore.num(parts[3])
      if (parts.length >= 5 && parts[4].length > 0) {
        b.recordIds = parts[4].split(',')
      }
      out.push(b)
    }
    out.sort((a: MemoryBooklet, b: MemoryBooklet) => b.createdAt - a.createdAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (MemoryStore.pref === null) {
      return fallback
    }
    try {
      const v = await MemoryStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (MemoryStore.pref === null) {
      return
    }
    try {
      await MemoryStore.pref.put(key, value)
      await MemoryStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
