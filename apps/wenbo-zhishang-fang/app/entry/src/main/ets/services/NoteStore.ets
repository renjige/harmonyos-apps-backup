import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { BookNote, BookProfile, BookShelfGroup, MonthlyReadingReport, NoteOverview, ReadingInsight, TagCloudItem, TimelineItem, WeekDayStat } from '../models/BookNoteModels'
import { MediaUriUtil } from '../utils/MediaUriUtil'

const STORE = 'zhishang_fang_v1'
const KEY_ITEMS = 'book_notes'
const KEY_DARK = 'dark_mode'
const KEY_RECALL = 'today_recall'
const KEY_MONTH_GOAL = 'month_goal'

export class NoteStore {
  private static pref: preferences.Preferences | null = null
  private static ctx: common.UIAbilityContext | null = null
  private static cache: BookNote[] = []
  private static ready: boolean = false

  static async init(context: common.UIAbilityContext): Promise<void> {
    NoteStore.ctx = context
    if (NoteStore.pref === null) {
      try {
        NoteStore.pref = await preferences.getPreferences(context, STORE)
      } catch {
        NoteStore.pref = null
      }
    }
    if (!NoteStore.ready) {
      const raw = await NoteStore.getString(KEY_ITEMS, '')
      NoteStore.cache = NoteStore.parse(raw)
      NoteStore.ready = true
    }
    await NoteStore.publishOverview()
  }

  static async loadAll(): Promise<BookNote[]> {
    if (!NoteStore.ready && NoteStore.ctx !== null) {
      await NoteStore.init(NoteStore.ctx)
    }
    return NoteStore.cache
  }

  static async loadFavorites(): Promise<BookNote[]> {
    const list = await NoteStore.loadAll()
    const out: BookNote[] = []
    for (const it of list) {
      if (it.isFavorite) {
        out.push(it)
      }
    }
    return out
  }

  static async searchByBook(query: string): Promise<BookNote[]> {
    const q = query.trim().toLowerCase()
    const list = await NoteStore.loadAll()
    if (q.length === 0) {
      return list
    }
    const out: BookNote[] = []
    for (const it of list) {
      const book = it.bookName.toLowerCase()
      const excerpt = it.excerpt.toLowerCase()
      const reflection = it.reflection.toLowerCase()
      const tags = it.tagLine().toLowerCase()
      if (book.indexOf(q) >= 0 || excerpt.indexOf(q) >= 0 || reflection.indexOf(q) >= 0 || tags.indexOf(q) >= 0) {
        out.push(it)
      }
    }
    return out
  }

  static async byTag(tag: string): Promise<BookNote[]> {
    const list = await NoteStore.loadAll()
    const out: BookNote[] = []
    for (const it of list) {
      if (it.hasTag(tag)) {
        out.push(it)
      }
    }
    return out
  }

  static async save(note: BookNote): Promise<void> {
    note.updatedAt = Date.now()
    const list = await NoteStore.loadAll()
    const next: BookNote[] = []
    let found = false
    for (const it of list) {
      if (it.id === note.id) {
        next.push(note)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(note)
    }
    next.sort((a: BookNote, b: BookNote) => b.createdAt - a.createdAt)
    await NoteStore.persist(next)
  }

  static async deleteById(id: string): Promise<void> {
    const list = await NoteStore.loadAll()
    const next: BookNote[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await NoteStore.persist(next)
  }

  static async findById(id: string): Promise<BookNote | undefined> {
    const list = await NoteStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async toggleFavorite(id: string): Promise<boolean> {
    const found = await NoteStore.findById(id)
    if (found === undefined) {
      return false
    }
    found.isFavorite = !found.isFavorite
    await NoteStore.save(found)
    return found.isFavorite
  }

  static async overview(): Promise<NoteOverview> {
    await NoteStore.loadAll()
    return NoteStore.computeOverview(NoteStore.cache)
  }

  static computeOverview(list: BookNote[]): NoteOverview {
    const ov = new NoteOverview()
    ov.totalNotes = list.length
    const books: string[] = []
    for (const it of list) {
      if (it.isFavorite) {
        ov.favoriteCount++
      }
      const name = it.bookName.trim()
      if (name.length === 0) {
        continue
      }
      let seen = false
      for (const b of books) {
        if (b === name) {
          seen = true
        }
      }
      if (!seen) {
        books.push(name)
      }
    }
    ov.bookCount = books.length
    return ov
  }

  static async nextRecall(excludeId: string): Promise<BookNote | undefined> {
    const list = await NoteStore.loadAll()
    if (list.length === 0) {
      return undefined
    }
    let best: BookNote | undefined = undefined
    for (const it of list) {
      if (it.id === excludeId) {
        continue
      }
      if (best === undefined) {
        best = it
        continue
      }
      if (it.recallCount < best.recallCount) {
        best = it
        continue
      }
      if (it.recallCount === best.recallCount && it.lastRecalledAt < best.lastRecalledAt) {
        best = it
      }
    }
    if (best === undefined) {
      return list[0]
    }
    return best
  }

  static async markRecalled(id: string, remembered: boolean): Promise<void> {
    const found = await NoteStore.findById(id)
    if (found === undefined) {
      return
    }
    if (remembered) {
      found.recallCount = found.recallCount + 1
    }
    found.lastRecalledAt = Date.now()
    await NoteStore.save(found)
    await NoteStore.bumpTodayRecall()
  }

  static async bumpTodayRecall(): Promise<void> {
    const stamp = NoteStore.dayStamp()
    const raw = await NoteStore.getString(KEY_RECALL, '')
    let count = 1
    if (raw.indexOf(`${stamp}:`) === 0) {
      count = NoteStore.num(raw.substring(stamp.length + 1)) + 1
    }
    await NoteStore.putString(KEY_RECALL, `${stamp}:${count}`)
    AppStorage.setOrCreate('statTodayRecall', count)
  }

  static async loadTodayRecall(): Promise<number> {
    const stamp = NoteStore.dayStamp()
    const raw = await NoteStore.getString(KEY_RECALL, '')
    if (raw.indexOf(`${stamp}:`) !== 0) {
      AppStorage.setOrCreate('statTodayRecall', 0)
      return 0
    }
    const count = NoteStore.num(raw.substring(stamp.length + 1))
    AppStorage.setOrCreate('statTodayRecall', count)
    return count
  }

  private static dayStamp(): string {
    const d = new Date()
    return `${d.getFullYear()}${NoteStore.pad(d.getMonth() + 1)}${NoteStore.pad(d.getDate())}`
  }

  static async publishOverview(): Promise<void> {
    const ov = NoteStore.computeOverview(NoteStore.cache)
    AppStorage.setOrCreate('statTotalNotes', ov.totalNotes)
    AppStorage.setOrCreate('statBookCount', ov.bookCount)
    AppStorage.setOrCreate('statFavoriteCount', ov.favoriteCount)
    await NoteStore.loadTodayRecall()
    const epoch = (AppStorage.get<number>('noteEpoch') ?? 0) + 1
    AppStorage.setOrCreate('noteEpoch', epoch)
  }

  static quoteCard(it: BookNote): string {
    const page = it.pageLabel().length > 0 ? ` ${it.pageLabel()}` : ''
    const feel = it.reflection.length > 0 ? `\n\n感悟：${it.reflection}` : ''
    return `「${it.excerpt}」\n——《${it.bookName}》${page}${feel}`
  }

  static async tagCloud(): Promise<TagCloudItem[]> {
    const list = await NoteStore.loadAll()
    const names: string[] = []
    const counts: number[] = []
    let max = 1
    for (const it of list) {
      for (const t of it.tags) {
        let idx = -1
        let i = 0
        for (const n of names) {
          if (n === t) {
            idx = i
          }
          i++
        }
        if (idx < 0) {
          names.push(t)
          counts.push(1)
        } else {
          counts[idx] = counts[idx] + 1
          if (counts[idx] > max) {
            max = counts[idx]
          }
        }
      }
    }
    const out: TagCloudItem[] = []
    let j = 0
    for (const n of names) {
      const item = new TagCloudItem()
      item.name = n
      item.count = counts[j]
      item.fontSize = 12 + Math.floor((counts[j] * 10) / max)
      out.push(item)
      j++
    }
    out.sort((a: TagCloudItem, b: TagCloudItem) => b.count - a.count)
    return out
  }

  static async readingInsight(): Promise<ReadingInsight> {
    const list = await NoteStore.loadAll()
    const insight = new ReadingInsight()
    const dayKeys: string[] = []
    const dayCounts: number[] = []
    const tagNames: string[] = []
    const tagCounts: number[] = []
    let weekTotal = 0
    const now = new Date()
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime()
    for (let i = 6; i >= 0; i--) {
      const d = new Date(todayStart - i * 86400000)
      const label = `${d.getMonth() + 1}/${d.getDate()}`
      dayKeys.push(label)
      dayCounts.push(0)
    }
    for (const it of list) {
      const createdDay = new Date(it.createdAt)
      const dayStart = new Date(createdDay.getFullYear(), createdDay.getMonth(), createdDay.getDate()).getTime()
      const diff = Math.floor((todayStart - dayStart) / 86400000)
      if (diff >= 0 && diff < 7) {
        const idx = 6 - diff
        dayCounts[idx] = dayCounts[idx] + 1
        weekTotal++
      }
      for (const t of it.tags) {
        let idx = -1
        let i = 0
        for (const n of tagNames) {
          if (n === t) {
            idx = i
          }
          i++
        }
        if (idx < 0) {
          tagNames.push(t)
          tagCounts.push(1)
        } else {
          tagCounts[idx] = tagCounts[idx] + 1
        }
      }
    }
    insight.weekTotal = weekTotal
    insight.topTag = ''
    let topCount = 0
    let ti = 0
    for (const n of tagNames) {
      if (tagCounts[ti] > topCount) {
        topCount = tagCounts[ti]
        insight.topTag = n
      }
      ti++
    }
    insight.streakDays = NoteStore.calcStreak(list)
    insight.weekDays = []
    let wi = 0
    for (const label of dayKeys) {
      const row = new WeekDayStat()
      row.label = label
      row.count = dayCounts[wi]
      insight.weekDays.push(row)
      wi++
    }
    return insight
  }

  static cloneNote(src: BookNote): BookNote {
    const n = new BookNote()
    n.id = src.id
    n.bookName = src.bookName
    n.pageNumber = src.pageNumber
    n.excerpt = src.excerpt
    n.reflection = src.reflection
    n.coverImage = src.coverImage
    n.isFavorite = src.isFavorite
    n.recallCount = src.recallCount
    n.lastRecalledAt = src.lastRecalledAt
    n.createdAt = src.createdAt
    n.updatedAt = src.updatedAt
    for (const t of src.tags) {
      n.tags.push(t)
    }
    return n
  }

  static async bookProfile(bookName: string): Promise<BookProfile | undefined> {
    const target = bookName.trim()
    if (target.length === 0) {
      return undefined
    }
    const list = await NoteStore.loadAll()
    const profile = new BookProfile()
    profile.bookName = target
    const tagNames: string[] = []
    const tagCounts: number[] = []
    let earliest = 0
    let latest = 0
    for (const it of list) {
      if (it.bookName.trim() !== target) {
        continue
      }
      profile.noteCount++
      if (it.isFavorite) {
        profile.favoriteCount++
      }
      for (const t of it.tags) {
        let idx = -1
        let i = 0
        for (const n of tagNames) {
          if (n === t) {
            idx = i
          }
          i++
        }
        if (idx < 0) {
          tagNames.push(t)
          tagCounts.push(1)
        } else {
          tagCounts[idx] = tagCounts[idx] + 1
        }
      }
      if (earliest === 0 || it.createdAt < earliest) {
        earliest = it.createdAt
      }
      if (it.createdAt > latest) {
        latest = it.createdAt
      }
    }
    if (profile.noteCount === 0) {
      return undefined
    }
    let topCount = 0
    let ti = 0
    for (const n of tagNames) {
      if (tagCounts[ti] > topCount) {
        topCount = tagCounts[ti]
        profile.topTag = n
      }
      ti++
    }
    if (earliest > 0) {
      profile.firstDate = NoteStore.timeLabel(earliest)
    }
    if (latest > 0) {
      profile.latestDate = NoteStore.timeLabel(latest)
    }
    return profile
  }

  static async monthlyReport(): Promise<MonthlyReadingReport> {
    const list = await NoteStore.loadAll()
    const report = new MonthlyReadingReport()
    const now = new Date()
    report.monthLabel = `${now.getFullYear()}年${now.getMonth() + 1}月`
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1).getTime()
    const bookNames: string[] = []
    const bookCounts: number[] = []
    const tagNames: string[] = []
    const tagCounts: number[] = []
    let recallTotal = 0
    for (const it of list) {
      if (it.createdAt >= monthStart) {
        report.newNotes++
        report.goalProgress++
        const name = it.bookName.trim()
        if (name.length > 0) {
          let idx = -1
          let i = 0
          for (const n of bookNames) {
            if (n === name) {
              idx = i
            }
            i++
          }
          if (idx < 0) {
            bookNames.push(name)
            bookCounts.push(1)
          } else {
            bookCounts[idx] = bookCounts[idx] + 1
          }
        }
        for (const t of it.tags) {
          let tidx = -1
          let j = 0
          for (const n of tagNames) {
            if (n === t) {
              tidx = j
            }
            j++
          }
          if (tidx < 0) {
            tagNames.push(t)
            tagCounts.push(1)
          } else {
            tagCounts[tidx] = tagCounts[tidx] + 1
          }
        }
      }
      if (it.lastRecalledAt >= monthStart) {
        recallTotal++
      }
    }
    report.recallTotal = recallTotal
    let topBookCount = 0
    let bi = 0
    for (const n of bookNames) {
      if (bookCounts[bi] > topBookCount) {
        topBookCount = bookCounts[bi]
        report.topBook = n
      }
      bi++
    }
    let topTagCount = 0
    let ti = 0
    for (const n of tagNames) {
      if (tagCounts[ti] > topTagCount) {
        topTagCount = tagCounts[ti]
        report.topTag = n
      }
      ti++
    }
    report.goalTarget = await NoteStore.loadMonthlyGoal()
    return report
  }

  static async loadMonthlyGoal(): Promise<number> {
    const raw = await NoteStore.getString(KEY_MONTH_GOAL, '10')
    const n = NoteStore.num(raw)
    if (n < 1) {
      return 10
    }
    if (n > 100) {
      return 100
    }
    return n
  }

  static async saveMonthlyGoal(target: number): Promise<void> {
    let n = target
    if (n < 1) {
      n = 1
    }
    if (n > 100) {
      n = 100
    }
    await NoteStore.putString(KEY_MONTH_GOAL, `${n}`)
  }

  static async recentTimeline(limit: number): Promise<TimelineItem[]> {
    const list = await NoteStore.loadAll()
    const sorted: BookNote[] = []
    for (const it of list) {
      sorted.push(it)
    }
    sorted.sort((a: BookNote, b: BookNote) => b.createdAt - a.createdAt)
    const out: TimelineItem[] = []
    let count = 0
    for (const it of sorted) {
      if (count >= limit) {
        break
      }
      const row = new TimelineItem()
      row.id = it.id
      row.bookName = it.bookName
      row.excerptPreview = it.excerptPreview()
      row.tagLabel = it.tagLine()
      row.dateLabel = NoteStore.timeLabel(it.createdAt)
      out.push(row)
      count++
    }
    return out
  }

  static async exportBookQuotes(bookName: string): Promise<string> {
    const target = bookName.trim()
    const list = await NoteStore.loadAll()
    const lines: string[] = []
    lines.push(`《${target}》书摘合集`)
    for (const it of list) {
      if (it.bookName.trim() === target) {
        lines.push('')
        lines.push(NoteStore.quoteCard(it))
      }
    }
    return lines.join('\n')
  }

  static async bookShelf(): Promise<BookShelfGroup[]> {
    const list = await NoteStore.loadAll()
    const names: string[] = []
    const counts: number[] = []
    const previews: string[] = []
    for (const it of list) {
      const name = it.bookName.trim()
      if (name.length === 0) {
        continue
      }
      let idx = -1
      let i = 0
      for (const n of names) {
        if (n === name) {
          idx = i
        }
        i++
      }
      if (idx < 0) {
        names.push(name)
        counts.push(1)
        previews.push(it.excerptPreview())
      } else {
        counts[idx] = counts[idx] + 1
        previews[idx] = it.excerptPreview()
      }
    }
    const out: BookShelfGroup[] = []
    let j = 0
    for (const n of names) {
      const g = new BookShelfGroup()
      g.bookName = n
      g.noteCount = counts[j]
      g.latestExcerpt = previews[j]
      out.push(g)
      j++
    }
    out.sort((a: BookShelfGroup, b: BookShelfGroup) => b.noteCount - a.noteCount)
    return out
  }

  static async sameBookNotes(bookName: string, excludeId: string): Promise<BookNote[]> {
    const list = await NoteStore.loadAll()
    const out: BookNote[] = []
    const target = bookName.trim()
    for (const it of list) {
      if (it.id === excludeId) {
        continue
      }
      if (it.bookName.trim() === target) {
        out.push(it)
      }
    }
    return out
  }

  static async todayWisdom(): Promise<BookNote | undefined> {
    let pool = await NoteStore.loadFavorites()
    if (pool.length === 0) {
      pool = await NoteStore.loadAll()
    }
    if (pool.length === 0) {
      return undefined
    }
    const d = new Date()
    let acc = d.getFullYear() * 10000 + (d.getMonth() + 1) * 100 + d.getDate()
    for (const it of pool) {
      acc = acc + it.id.length
    }
    const idx = acc % pool.length
    let k = 0
    for (const it of pool) {
      if (k === idx) {
        return it
      }
      k++
    }
    return undefined
  }

  static async exportCsv(): Promise<string> {
    const list = await NoteStore.loadAll()
    const lines: string[] = []
    lines.push('书籍,页码,摘录,感悟,标签,收藏,日期')
    for (const it of list) {
      const row: string[] = []
      row.push(NoteStore.csvCell(it.bookName))
      row.push(it.pageNumber > 0 ? `${it.pageNumber}` : '')
      row.push(NoteStore.csvCell(it.excerpt))
      row.push(NoteStore.csvCell(it.reflection))
      row.push(NoteStore.csvCell(it.tagLine()))
      row.push(it.isFavorite ? '是' : '否')
      row.push(NoteStore.timeLabel(it.createdAt))
      lines.push(row.join(','))
    }
    return lines.join('\n')
  }

  static timeLabel(ts: number): string {
    const d = new Date(ts)
    const m = d.getMonth() + 1
    const day = d.getDate()
    return `${d.getFullYear()}-${NoteStore.pad(m)}-${NoteStore.pad(day)}`
  }

  static async loadDark(): Promise<boolean> {
    const v = await NoteStore.getString(KEY_DARK, '0')
    return v === '1'
  }

  static async saveDark(on: boolean): Promise<void> {
    await NoteStore.putString(KEY_DARK, on ? '1' : '0')
  }

  private static calcStreak(list: BookNote[]): number {
    if (list.length === 0) {
      return 0
    }
    const daySet: number[] = []
    for (const it of list) {
      const d = new Date(it.createdAt)
      const key = d.getFullYear() * 10000 + (d.getMonth() + 1) * 100 + d.getDate()
      let seen = false
      for (const k of daySet) {
        if (k === key) {
          seen = true
        }
      }
      if (!seen) {
        daySet.push(key)
      }
    }
    daySet.sort((a: number, b: number) => b - a)
    const now = new Date()
    let cursor = now.getFullYear() * 10000 + (now.getMonth() + 1) * 100 + now.getDate()
    let streak = 0
    for (const k of daySet) {
      if (k === cursor) {
        streak++
        cursor = NoteStore.prevDayKey(cursor)
        continue
      }
      if (k === NoteStore.prevDayKey(cursor) && streak === 0) {
        cursor = k
        streak++
        cursor = NoteStore.prevDayKey(cursor)
        continue
      }
      break
    }
    return streak
  }

  private static prevDayKey(key: number): number {
    const y = Math.floor(key / 10000)
    const m = Math.floor((key % 10000) / 100)
    const d = key % 100
    const dt = new Date(y, m - 1, d)
    dt.setDate(dt.getDate() - 1)
    return dt.getFullYear() * 10000 + (dt.getMonth() + 1) * 100 + dt.getDate()
  }

  private static csvCell(raw: string): string {
    const t = raw.replace(/"/g, '""').replace(/\n/g, ' ')
    return `"${t}"`
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

  private static async persist(items: BookNote[]): Promise<void> {
    NoteStore.cache = items
    NoteStore.ready = true
    const lines: string[] = []
    for (const it of items) {
      lines.push(NoteStore.serialize(it))
    }
    await NoteStore.putString(KEY_ITEMS, lines.join('\n'))
    await NoteStore.publishOverview()
  }

  private static serialize(it: BookNote): string {
    const excerpt = it.excerpt.replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/\t/g, '\\t')
    const reflection = it.reflection.replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/\t/g, '\\t')
    const cover = it.coverImage.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const book = it.bookName.replace(/\t/g, ' ').replace(/\n/g, ' ')
    return [
      it.id, book, `${it.pageNumber}`, excerpt, reflection, cover,
      it.tags.join(','), NoteStore.flag(it.isFavorite), `${it.createdAt}`, `${it.updatedAt}`,
      `${it.recallCount}`, `${it.lastRecalledAt}`
    ].join('\t')
  }

  private static unescape(s: string): string {
    return s.replace(/\\n/g, '\n').replace(/\\t/g, '\t').replace(/\\\\/g, '\\')
  }

  private static parse(raw: string): BookNote[] {
    const out: BookNote[] = []
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
      const e = new BookNote()
      e.id = parts[0]
      e.bookName = parts[1]
      e.pageNumber = NoteStore.num(parts[2])
      e.excerpt = NoteStore.unescape(parts[3])
      e.reflection = NoteStore.unescape(parts[4])
      e.coverImage = MediaUriUtil.imageSrc(parts[5])
      e.tags = parts[6].length === 0 ? [] : parts[6].split(',')
      e.isFavorite = NoteStore.isOne(parts[7])
      e.createdAt = NoteStore.num(parts[8])
      if (parts.length >= 10) {
        e.updatedAt = NoteStore.num(parts[9])
      }
      if (parts.length >= 12) {
        e.recallCount = NoteStore.num(parts[10])
        e.lastRecalledAt = NoteStore.num(parts[11])
      }
      out.push(e)
    }
    out.sort((a: BookNote, b: BookNote) => b.createdAt - a.createdAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (NoteStore.pref === null) {
      return fallback
    }
    try {
      const v = await NoteStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (NoteStore.pref === null && NoteStore.ctx !== null) {
      try {
        NoteStore.pref = await preferences.getPreferences(NoteStore.ctx, STORE)
      } catch {
        NoteStore.pref = null
      }
    }
    if (NoteStore.pref === null) {
      return
    }
    try {
      await NoteStore.pref.put(key, value)
      await NoteStore.pref.flush()
    } catch {
      // keep in-memory cache even if disk write fails
    }
  }
}
