import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  YunAnniversaryItem,
  YunAppStats,
  YunHabitItem,
  YunMoodDay,
  YunMonthlyReview,
  YunNoteItem,
  YunTagRecord,
  YunTimelineGroup,
  YunAlbumGroup,
  YunTodoItem
} from '../models/YunModels'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from './ThemeAppearance'
import { AppContextService } from './AppContextService'

const STORE = 'yunshui_jian_life'
const KEY_NOTES = 'notes_v2'
const KEY_TODOS = 'todos_v2'
const KEY_TAGS = 'tags_v1'
const KEY_ANNIV = 'anniv_v1'
const KEY_DARK = 'dark_v1'
const KEY_HABITS = 'habits_v1'
const KEY_MOODS = 'moods_v1'
const KEY_CRAFT = 'craft_v1'

export class YunDateHelper {
  static todayKey(): string {
    return YunDateHelper.keyFromDate(new Date())
  }

  static keyFromDate(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static monthKey(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${y}-${ms}`
  }

  static yearKey(d: Date): string {
    return `${d.getFullYear()}`
  }

  static displayDate(dateKey: string): string {
    const parts = dateKey.split('-')
    if (parts.length < 3) {
      return dateKey
    }
    const d = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10))
    const names: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日 星期${names[d.getDay()]}`
  }

  static displayMonth(monthKey: string): string {
    const parts = monthKey.split('-')
    if (parts.length < 2) {
      return monthKey
    }
    return `${parts[0]}年${parseInt(parts[1], 10)}月`
  }

  static newId(): string {
    return `${Date.now()}_${Math.floor(Math.random() * 100000)}`
  }

  static tsFromId(id: string): number {
    const parts = id.split('_')
    if (parts.length > 0 && parts[0].length >= 13) {
      const n = parseInt(parts[0], 10)
      if (n > 1000000000000) {
        return n
      }
    }
    return Date.now()
  }

  static isValidTs(ts: number): boolean {
    return ts > 1000000000000 && ts < 4102444800000
  }

  static sanitizeTs(raw: number, id: string): number {
    if (YunDateHelper.isValidTs(raw)) {
      return raw
    }
    return YunDateHelper.tsFromId(id)
  }

  static effectiveTs(createdAt: number, updatedAt: number, id: string): number {
    if (YunDateHelper.isValidTs(updatedAt)) {
      return updatedAt
    }
    if (YunDateHelper.isValidTs(createdAt)) {
      return createdAt
    }
    return YunDateHelper.tsFromId(id)
  }

  private static pad2(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  static formatDateTime(ts: number): string {
    const d = new Date(ts)
    return `${d.getFullYear()}-${YunDateHelper.pad2(d.getMonth() + 1)}-${YunDateHelper.pad2(d.getDate())} ${YunDateHelper.pad2(d.getHours())}:${YunDateHelper.pad2(d.getMinutes())}`
  }

  static formatClock(ts: number): string {
    const d = new Date(ts)
    return `${YunDateHelper.pad2(d.getHours())}:${YunDateHelper.pad2(d.getMinutes())}`
  }

  static soonTime(minAhead: number): string {
    const d = new Date()
    d.setMinutes(d.getMinutes() + minAhead)
    const h = d.getHours()
    const m = d.getMinutes()
    const hs = h < 10 ? `0${h}` : `${h}`
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${hs}:${ms}`
  }

  static daysUntil(dateKey: string, yearly: boolean): number {
    const now = new Date()
    now.setHours(0, 0, 0, 0)
    const parts = dateKey.split('-')
    let target: Date
    if (parts.length >= 3) {
      target = new Date(parseInt(parts[0], 10), parseInt(parts[1], 10) - 1, parseInt(parts[2], 10))
    } else if (parts.length === 2) {
      target = new Date(now.getFullYear(), parseInt(parts[0], 10) - 1, parseInt(parts[1], 10))
    } else {
      return 0
    }
    target.setHours(0, 0, 0, 0)
    if (yearly && parts.length === 2) {
      target.setFullYear(now.getFullYear())
      if (target.getTime() < now.getTime()) {
        target.setFullYear(now.getFullYear() + 1)
      }
    } else if (yearly && parts.length >= 3) {
      target.setFullYear(now.getFullYear())
      if (target.getTime() < now.getTime()) {
        target.setFullYear(now.getFullYear() + 1)
      }
    }
    const diff = target.getTime() - now.getTime()
    return Math.max(0, Math.ceil(diff / 86400000))
  }
}

export class YunLocalStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      YunLocalStore.pref = await preferences.getPreferences(context, STORE)
      const dark = await YunLocalStore.isDarkMode()
      Theme.applyDark(dark)
    } catch {
      YunLocalStore.pref = null
    }
  }

  static async loadNotes(): Promise<YunNoteItem[]> {
    const raw = await YunLocalStore.getString(KEY_NOTES, '')
    return YunLocalStore.parseNotes(raw)
  }

  static async saveNote(note: YunNoteItem): Promise<boolean> {
    if (!YunDateHelper.isValidTs(note.createdAt)) {
      note.createdAt = YunDateHelper.tsFromId(note.id)
    }
    if (!YunDateHelper.isValidTs(note.updatedAt)) {
      note.updatedAt = Date.now()
    }
    const list = await YunLocalStore.loadNotes()
    const next: YunNoteItem[] = []
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
      next.unshift(note)
    }
    next.sort((a, b) => b.updatedAt - a.updatedAt)
    const ok = await YunLocalStore.putString(KEY_NOTES, YunLocalStore.serializeNotes(next))
    if (ok) {
      await YunLocalStore.rebuildTagsFromNotes(next)
    }
    return ok
  }

  static async deleteNote(id: string): Promise<void> {
    const list = await YunLocalStore.loadNotes()
    const next: YunNoteItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await YunLocalStore.putString(KEY_NOTES, YunLocalStore.serializeNotes(next))
    await YunLocalStore.rebuildTagsFromNotes(next)
  }

  static async findNote(id: string): Promise<YunNoteItem | undefined> {
    const list = await YunLocalStore.loadNotes()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async searchNotes(query: string): Promise<YunNoteItem[]> {
    const q = query.trim().toLowerCase()
    if (q.length === 0) {
      return await YunLocalStore.loadNotes()
    }
    const list = await YunLocalStore.loadNotes()
    const out: YunNoteItem[] = []
    for (const n of list) {
      const hay = `${n.title}\n${n.body}\n${n.tags.join(' ')}`.toLowerCase()
      if (hay.indexOf(q) >= 0) {
        out.push(n)
      }
    }
    return out
  }

  static async groupNotesByDate(): Promise<YunTimelineGroup[]> {
    const notes = await YunLocalStore.loadNotes()
    const map: Map<string, YunNoteItem[]> = new Map()
    for (const n of notes) {
      const key = YunDateHelper.keyFromDate(new Date(YunDateHelper.effectiveTs(n.createdAt, n.updatedAt, n.id)))
      const bucket = map.get(key)
      if (bucket === undefined) {
        const arr: YunNoteItem[] = []
        arr.push(n)
        map.set(key, arr)
      } else {
        bucket.push(n)
      }
    }
    const keys: string[] = []
    map.forEach((_v: YunNoteItem[], k: string) => { keys.push(k) })
    keys.sort((a, b) => b.localeCompare(a))
    const groups: YunTimelineGroup[] = []
    for (const k of keys) {
      const g = YunTimelineGroup.create(k, YunDateHelper.displayDate(k))
      const items = map.get(k)
      if (items !== undefined) {
        g.notes = items
      }
      groups.push(g)
    }
    return groups
  }

  static async groupAlbumNotes(byYear: boolean): Promise<YunAlbumGroup[]> {
    const notes = await YunLocalStore.loadNotes()
    const withImg: YunNoteItem[] = []
    for (const n of notes) {
      if (n.imagePaths.length > 0) {
        withImg.push(n)
      }
    }
    const map: Map<string, YunNoteItem[]> = new Map()
    for (const n of withImg) {
      const d = new Date(YunDateHelper.effectiveTs(n.createdAt, n.updatedAt, n.id))
      const key = byYear ? YunDateHelper.yearKey(d) : YunDateHelper.monthKey(d)
      const bucket = map.get(key)
      if (bucket === undefined) {
        const arr: YunNoteItem[] = []
        arr.push(n)
        map.set(key, arr)
      } else {
        bucket.push(n)
      }
    }
    const keys: string[] = []
    map.forEach((_v: YunNoteItem[], k: string) => { keys.push(k) })
    keys.sort((a, b) => b.localeCompare(a))
    const groups: YunAlbumGroup[] = []
    for (const k of keys) {
      const label = byYear ? `${k}年` : YunDateHelper.displayMonth(k)
      const g = YunAlbumGroup.create(k, label)
      const items = map.get(k)
      if (items !== undefined) {
        g.notes = items
      }
      groups.push(g)
    }
    return groups
  }

  static async loadTodos(): Promise<YunTodoItem[]> {
    const raw = await YunLocalStore.getString(KEY_TODOS, '')
    return YunLocalStore.parseTodos(raw)
  }

  static async saveTodo(todo: YunTodoItem): Promise<void> {
    const list = await YunLocalStore.loadTodos()
    const next: YunTodoItem[] = []
    let found = false
    for (const it of list) {
      if (it.id === todo.id) {
        next.push(todo)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.unshift(todo)
    }
    await YunLocalStore.putString(KEY_TODOS, YunLocalStore.serializeTodos(next))
  }

  static async deleteTodo(id: string): Promise<void> {
    const list = await YunLocalStore.loadTodos()
    const next: YunTodoItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await YunLocalStore.putString(KEY_TODOS, YunLocalStore.serializeTodos(next))
  }

  static async toggleTodoDone(id: string): Promise<void> {
    const list = await YunLocalStore.loadTodos()
    for (const it of list) {
      if (it.id === id) {
        it.done = !it.done
        it.completedAt = it.done ? Date.now() : 0
        break
      }
    }
    await YunLocalStore.putString(KEY_TODOS, YunLocalStore.serializeTodos(list))
  }

  static async findTodo(id: string): Promise<YunTodoItem | undefined> {
    const list = await YunLocalStore.loadTodos()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async createTodo(content: string, dueDate: string, dueTime: string, repeatType: string,
    listKind: string): Promise<YunTodoItem> {
    const todo = YunTodoItem.create(YunDateHelper.newId(), content)
    todo.dueDate = dueDate
    todo.dueTime = dueTime
    todo.repeatType = repeatType
    todo.listKind = listKind.length > 0 ? listKind : 'remind'
    await YunLocalStore.saveTodo(todo)
    return todo
  }

  static async loadHabits(): Promise<YunHabitItem[]> {
    const raw = await YunLocalStore.getString(KEY_HABITS, '')
    return YunLocalStore.parseHabits(raw)
  }

  static async saveHabit(item: YunHabitItem): Promise<void> {
    const list = await YunLocalStore.loadHabits()
    const next: YunHabitItem[] = []
    let found = false
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
    await YunLocalStore.putString(KEY_HABITS, YunLocalStore.serializeHabits(next))
  }

  static async deleteHabit(id: string): Promise<void> {
    const list = await YunLocalStore.loadHabits()
    const next: YunHabitItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await YunLocalStore.putString(KEY_HABITS, YunLocalStore.serializeHabits(next))
  }

  static async checkinHabit(id: string): Promise<boolean> {
    const today = YunDateHelper.todayKey()
    const found = await YunLocalStore.findHabit(id)
    if (found === undefined) {
      return false
    }
    if (found.lastDate === today) {
      return true
    }
    const yest = new Date()
    yest.setDate(yest.getDate() - 1)
    const yestKey = YunDateHelper.keyFromDate(yest)
    if (found.lastDate === yestKey) {
      found.streak = found.streak + 1
    } else {
      found.streak = 1
    }
    found.lastDate = today
    found.totalDays = found.totalDays + 1
    await YunLocalStore.saveHabit(found)
    return true
  }

  static async findHabit(id: string): Promise<YunHabitItem | undefined> {
    const list = await YunLocalStore.loadHabits()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async loadMoods(): Promise<YunMoodDay[]> {
    const raw = await YunLocalStore.getString(KEY_MOODS, '')
    return YunLocalStore.parseMoods(raw)
  }

  static async saveMood(item: YunMoodDay): Promise<void> {
    const list = await YunLocalStore.loadMoods()
    const next: YunMoodDay[] = []
    let found = false
    for (const it of list) {
      if (it.dateKey === item.dateKey) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(item)
    }
    await YunLocalStore.putString(KEY_MOODS, YunLocalStore.serializeMoods(next))
  }

  static async todayMood(): Promise<YunMoodDay | undefined> {
    const key = YunDateHelper.todayKey()
    const list = await YunLocalStore.loadMoods()
    for (const it of list) {
      if (it.dateKey === key) {
        return it
      }
    }
    return undefined
  }

  static async buildMonthlyReview(): Promise<YunMonthlyReview> {
    const review = new YunMonthlyReview()
    const month = YunDateHelper.monthKey(new Date())
    review.monthKey = month
    const notes = await YunLocalStore.loadNotes()
    const tagMap: Map<string, number> = new Map()
    for (const n of notes) {
      const d = new Date(YunDateHelper.effectiveTs(n.createdAt, n.updatedAt, n.id))
      if (YunDateHelper.monthKey(d) === month) {
        review.noteCount++
        review.photoCount += n.imagePaths.length
        for (const t of n.tags) {
          const prev = tagMap.get(t)
          tagMap.set(t, prev === undefined ? 1 : prev + 1)
        }
      }
    }
    let top = ''
    let topN = 0
    tagMap.forEach((count: number, name: string) => {
      if (count > topN) {
        topN = count
        top = name
      }
    })
    review.topTag = top
    const habits = await YunLocalStore.loadHabits()
    for (const h of habits) {
      if (h.lastDate.indexOf(month) === 0) {
        review.checkinCount += 1
      }
    }
    if (review.noteCount === 0 && review.checkinCount === 0) {
      review.summary = '这个月还没有生活片段。从一条札记或一次打卡开始吧。'
    } else {
      const tagBit = review.topTag.length > 0 ? `，常写「${review.topTag}」` : ''
      review.summary = `本月写下 ${review.noteCount} 条札记、收录 ${review.photoCount} 张照片、完成 ${review.checkinCount} 次打卡${tagBit}。`
    }
    return review
  }

  static async loadAnniversaries(): Promise<YunAnniversaryItem[]> {
    const raw = await YunLocalStore.getString(KEY_ANNIV, '')
    return YunLocalStore.parseAnniversaries(raw)
  }

  static async saveAnniversary(item: YunAnniversaryItem): Promise<void> {
    const list = await YunLocalStore.loadAnniversaries()
    const next: YunAnniversaryItem[] = []
    let found = false
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
    await YunLocalStore.putString(KEY_ANNIV, YunLocalStore.serializeAnniversaries(next))
  }

  static async deleteAnniversary(id: string): Promise<void> {
    const list = await YunLocalStore.loadAnniversaries()
    const next: YunAnniversaryItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await YunLocalStore.putString(KEY_ANNIV, YunLocalStore.serializeAnniversaries(next))
  }

  static async loadTags(): Promise<YunTagRecord[]> {
    const raw = await YunLocalStore.getString(KEY_TAGS, '')
    return YunLocalStore.parseTags(raw)
  }

  static async saveTags(tags: YunTagRecord[]): Promise<void> {
    await YunLocalStore.putString(KEY_TAGS, YunLocalStore.serializeTags(tags))
  }

  static async renameTag(oldName: string, newName: string): Promise<void> {
    const trimmed = newName.trim()
    if (trimmed.length === 0 || trimmed === oldName) {
      return
    }
    const notes = await YunLocalStore.loadNotes()
    for (const n of notes) {
      const nextTags: string[] = []
      for (const t of n.tags) {
        if (t === oldName) {
          nextTags.push(trimmed)
        } else {
          nextTags.push(t)
        }
      }
      n.tags = nextTags
    }
    await YunLocalStore.putString(KEY_NOTES, YunLocalStore.serializeNotes(notes))
    await YunLocalStore.rebuildTagsFromNotes(notes)
  }

  static async deleteTag(name: string): Promise<void> {
    const notes = await YunLocalStore.loadNotes()
    for (const n of notes) {
      const nextTags: string[] = []
      for (const t of n.tags) {
        if (t !== name) {
          nextTags.push(t)
        }
      }
      n.tags = nextTags
    }
    await YunLocalStore.putString(KEY_NOTES, YunLocalStore.serializeNotes(notes))
    await YunLocalStore.rebuildTagsFromNotes(notes)
  }

  static async clearCache(): Promise<void> {
    AppStorage.setOrCreate('lifeCacheTick', Date.now())
  }

  static async clearAllData(): Promise<void> {
    await YunLocalStore.putString(KEY_NOTES, '')
    await YunLocalStore.putString(KEY_TODOS, '')
    await YunLocalStore.putString(KEY_TAGS, '')
    await YunLocalStore.putString(KEY_ANNIV, '')
    await YunLocalStore.putString(KEY_HABITS, '')
    await YunLocalStore.putString(KEY_MOODS, '')
    await YunLocalStore.putString(KEY_CRAFT, '')
  }

  static async isDarkMode(): Promise<boolean> {
    const raw = await YunLocalStore.getString(KEY_DARK, '0')
    return raw === '1'
  }

  static async setDarkMode(dark: boolean): Promise<void> {
    await YunLocalStore.putString(KEY_DARK, dark ? '1' : '0')
    Theme.applyDark(dark)
    const ctx = AppContextService.getContext()
    if (ctx !== null) {
      ThemeAppearance.lockSystemLight(ctx)
    }
    AppStorage.setOrCreate('yunThemeTick', Date.now())
  }

  static async loadStats(): Promise<YunAppStats> {
    const stats = new YunAppStats()
    const notes = await YunLocalStore.loadNotes()
    stats.noteCount = notes.length
    for (const n of notes) {
      stats.imageCount += n.imagePaths.length
    }
    const todos = await YunLocalStore.loadTodos()
    for (const t of todos) {
      if (t.done) {
        stats.todoDone++
      } else {
        stats.todoActive++
      }
    }
    const anniv = await YunLocalStore.loadAnniversaries()
    stats.anniversaryCount = anniv.length
    stats.streakDays = YunLocalStore.computeStreak(notes)
    const habits = await YunLocalStore.loadHabits()
    for (const h of habits) {
      stats.habitCheckins += h.totalDays
    }
    const moods = await YunLocalStore.loadMoods()
    stats.moodDays = moods.length
    let firstTs = Date.now()
    for (const n of notes) {
      if (n.createdAt > 0 && n.createdAt < firstTs) {
        firstTs = n.createdAt
      }
    }
    const craftRaw = await YunLocalStore.rawGet(KEY_CRAFT, '')
    if (craftRaw.length > 0) {
      const lines = craftRaw.split('\n')
      for (const line of lines) {
        if (line.length === 0) {
          continue
        }
        stats.craftCount++
        const parts = line.split('\t')
        if (parts.length >= 8 && parts[1] === 'goal') {
          const p = parseInt(parts[7], 10)
          if (p < 100) {
            stats.goalOpen++
          }
        }
        if (parts.length >= 9) {
          const cts = parseInt(parts[8], 10)
          if (cts > 0 && cts < firstTs) {
            firstTs = cts
          }
        }
      }
    }
    if (notes.length > 0 || stats.craftCount > 0) {
      stats.archiveDays = Math.max(1, Math.ceil((Date.now() - firstTs) / 86400000))
    }
    return stats
  }

  static async findOnThisDay(): Promise<YunNoteItem[]> {
    const notes = await YunLocalStore.loadNotes()
    const today = new Date()
    const m = today.getMonth()
    const d = today.getDate()
    const y = today.getFullYear()
    const out: YunNoteItem[] = []
    for (const n of notes) {
      const ts = YunDateHelper.effectiveTs(n.createdAt, n.updatedAt, n.id)
      const dt = new Date(ts)
      if (dt.getFullYear() < y && dt.getMonth() === m && dt.getDate() === d) {
        out.push(n)
      }
    }
    return out
  }

  static computeStreak(notes: YunNoteItem[]): number {
    if (notes.length === 0) {
      return 0
    }
    const daySet: Set<string> = new Set()
    for (const n of notes) {
      daySet.add(YunDateHelper.keyFromDate(new Date(YunDateHelper.effectiveTs(n.createdAt, n.updatedAt, n.id))))
    }
    let streak = 0
    const cursor = new Date()
    cursor.setHours(0, 0, 0, 0)
    while (true) {
      const key = YunDateHelper.keyFromDate(cursor)
      if (daySet.has(key)) {
        streak++
        cursor.setDate(cursor.getDate() - 1)
      } else {
        break
      }
    }
    return streak
  }

  private static async rebuildTagsFromNotes(notes: YunNoteItem[]): Promise<void> {
    const countMap: Map<string, number> = new Map()
    for (const n of notes) {
      for (const t of n.tags) {
        const prev = countMap.get(t)
        if (prev === undefined) {
          countMap.set(t, 1)
        } else {
          countMap.set(t, prev + 1)
        }
      }
    }
    const tags: YunTagRecord[] = []
    countMap.forEach((count: number, name: string) => {
      tags.push(YunTagRecord.create(name, count))
    })
    tags.sort((a, b) => b.usageCount - a.usageCount)
    await YunLocalStore.saveTags(tags)
  }

  private static serializeHabits(items: YunHabitItem[]): string {
    const lines: string[] = []
    for (const it of items) {
      const title = it.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
      lines.push(`${it.id}\t${title}\t${it.lastDate}\t${it.streak}\t${it.totalDays}\t${it.createdAt}`)
    }
    return lines.join('\n')
  }

  private static parseHabits(raw: string): YunHabitItem[] {
    const out: YunHabitItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 6) {
        continue
      }
      const h = YunHabitItem.create(parts[0], parts[1])
      h.lastDate = parts[2]
      h.streak = parseInt(parts[3], 10)
      h.totalDays = parseInt(parts[4], 10)
      h.createdAt = parseInt(parts[5], 10)
      out.push(h)
    }
    return out
  }

  private static serializeMoods(items: YunMoodDay[]): string {
    const lines: string[] = []
    for (const it of items) {
      const note = it.note.replace(/\t/g, ' ').replace(/\n/g, ' ')
      lines.push(`${it.dateKey}\t${it.mood}\t${note}`)
    }
    return lines.join('\n')
  }

  private static parseMoods(raw: string): YunMoodDay[] {
    const out: YunMoodDay[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 2) {
        continue
      }
      out.push(YunMoodDay.create(parts[0], parts[1], parts.length >= 3 ? parts[2] : ''))
    }
    return out
  }

  private static serializeNotes(items: YunNoteItem[]): string {
    const lines: string[] = []
    for (const it of items) {
      const tags = it.tags.join('|')
      const imgs = it.imagePaths.join('|')
      const title = it.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
      const body = it.body.replace(/\t/g, ' ').replace(/\n/g, '\\n')
      lines.push(`${it.id}\t${title}\t${body}\t${tags}\t${imgs}\t${it.createdAt}\t${it.updatedAt}\t${it.category}\t${it.mood}\t${it.templateKey}`)
    }
    return lines.join('\n')
  }

  private static parseNotes(raw: string): YunNoteItem[] {
    const out: YunNoteItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 7) {
        continue
      }
      const n = YunNoteItem.create(parts[0], parts[1], parts[2].replace(/\\n/g, '\n'))
      const tagRaw = parts[3]
      if (tagRaw.length > 0) {
        const tags = tagRaw.split('|')
        for (const t of tags) {
          if (t.length > 0) {
            n.tags.push(t)
          }
        }
      }
      const imgRaw = parts[4]
      if (imgRaw.length > 0) {
        const imgs = imgRaw.split('|')
        for (const p of imgs) {
          if (p.length > 0) {
            n.imagePaths.push(p)
          }
        }
      }
      n.createdAt = YunDateHelper.sanitizeTs(parseInt(parts[5], 10), parts[0])
      n.updatedAt = YunDateHelper.sanitizeTs(parseInt(parts[6], 10), parts[0])
      if (n.updatedAt < n.createdAt) {
        n.updatedAt = n.createdAt
      }
      if (parts.length >= 8 && parts[7].length > 0) {
        n.category = parts[7]
      }
      if (parts.length >= 9) {
        n.mood = parts[8]
      }
      if (parts.length >= 10) {
        n.templateKey = parts[9]
      }
      out.push(n)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static serializeTodos(items: YunTodoItem[]): string {
    const lines: string[] = []
    for (const it of items) {
      const content = it.content.replace(/\t/g, ' ').replace(/\n/g, ' ')
      lines.push(`${it.id}\t${content}\t${it.done ? '1' : '0'}\t${it.dueDate}\t${it.dueTime}\t${it.repeatType}\t${it.reminderAgentId}\t${it.createdAt}\t${it.completedAt}\t${it.listKind}`)
    }
    return lines.join('\n')
  }

  private static parseTodos(raw: string): YunTodoItem[] {
    const out: YunTodoItem[] = []
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
      const t = YunTodoItem.create(parts[0], parts[1])
      t.done = parts[2] === '1'
      t.dueDate = parts[3]
      t.dueTime = parts[4]
      t.repeatType = parts[5].length > 0 ? parts[5] : 'none'
      t.reminderAgentId = parseInt(parts[6], 10)
      t.createdAt = parseInt(parts[7], 10)
      t.completedAt = parseInt(parts[8], 10)
      if (parts.length >= 10 && parts[9].length > 0) {
        t.listKind = parts[9]
      }
      out.push(t)
    }
    return out
  }

  private static serializeAnniversaries(items: YunAnniversaryItem[]): string {
    const lines: string[] = []
    for (const it of items) {
      const title = it.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
      lines.push(`${it.id}\t${title}\t${it.dateKey}\t${it.yearly ? '1' : '0'}\t${it.createdAt}`)
    }
    return lines.join('\n')
  }

  private static parseAnniversaries(raw: string): YunAnniversaryItem[] {
    const out: YunAnniversaryItem[] = []
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
      const a = YunAnniversaryItem.create(parts[0], parts[1], parts[2])
      a.yearly = parts[3] === '1'
      a.createdAt = parseInt(parts[4], 10)
      out.push(a)
    }
    return out
  }

  private static serializeTags(items: YunTagRecord[]): string {
    const lines: string[] = []
    for (const it of items) {
      lines.push(`${it.name}\t${it.usageCount}`)
    }
    return lines.join('\n')
  }

  private static parseTags(raw: string): YunTagRecord[] {
    const out: YunTagRecord[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 2) {
        continue
      }
      out.push(YunTagRecord.create(parts[0], parseInt(parts[1], 10)))
    }
    return out
  }

  static async rawGet(key: string, fallback: string): Promise<string> {
    return await YunLocalStore.getString(key, fallback)
  }

  static async rawPut(key: string, value: string): Promise<boolean> {
    return await YunLocalStore.putString(key, value)
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (YunLocalStore.pref === null) {
      return fallback
    }
    try {
      const v = await YunLocalStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<boolean> {
    if (YunLocalStore.pref === null) {
      return false
    }
    try {
      await YunLocalStore.pref.put(key, value)
      await YunLocalStore.pref.flush()
      return true
    } catch {
      return false
    }
  }

  static storeReady(): boolean {
    return YunLocalStore.pref !== null
  }
}
