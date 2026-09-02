import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { MomentNote, MomentTodo, TagPreset, TagStat, UserProfile, MonthCell, MonthShareCard, WeekSummary, DayActivity, WeeklyReview, MilestoneBadge, DailyWrap, WeekCompare, LifeMemorial, MoodDay, CheckinCell, ActivityEvent, LifePlan, PlanTask, TopicCollection, HomeDashboard, SearchHit } from '../models/MomentModels'
import { DateHelper } from './DateHelper'

const STORE = 'xiaoshi_moment_v1'
const KEY_NOTES = 'notes'
const KEY_TODOS = 'todos'
const KEY_PROFILE = 'profile'
const KEY_WEEKLY = 'weeklyReviews'
const KEY_WRAPS = 'dailyWraps'
const KEY_MEMORIALS = 'memorials'
const KEY_EPOCH = 'momentDataEpoch'
const KEY_ACTIVITIES = 'activities'
const KEY_PLANS = 'plans'
const KEY_TOPICS = 'topics'

export class MomentStore {
  private static pref: preferences.Preferences | null = null

  static notifyChanged(): void {
    const cur = AppStorage.get<number>(KEY_EPOCH)
    const n = cur !== undefined ? cur : 0
    AppStorage.setOrCreate(KEY_EPOCH, n + 1)
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      MomentStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      MomentStore.pref = null
    }
  }

  static async loadNotes(): Promise<MomentNote[]> {
    const raw = await MomentStore.getString(KEY_NOTES, '')
    const list = MomentStore.parseNotes(raw)
    list.sort((a, b) => {
      if (a.pinned !== b.pinned) {
        return a.pinned ? -1 : 1
      }
      return b.createdAt - a.createdAt
    })
    return list
  }

  static async findNote(id: string): Promise<MomentNote | undefined> {
    const list = await MomentStore.loadNotes()
    for (const n of list) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static async notesOn(dateKey: string): Promise<MomentNote[]> {
    const list = await MomentStore.loadNotes()
    const out: MomentNote[] = []
    for (const n of list) {
      if (n.dateKey === dateKey) {
        out.push(n)
      }
    }
    return out
  }

  static async saveNote(note: MomentNote): Promise<boolean> {
    const content = note.content.trim()
    if (content.length === 0) {
      return false
    }
    note.content = content
    note.updatedAt = Date.now()
    if (note.tags.length > 3) {
      const clipped: string[] = []
      for (let i = 0; i < 3; i++) {
        clipped.push(note.tags[i])
      }
      note.tags = clipped
    }
    const list = await MomentStore.loadNotes()
    let found = false
    for (const n of list) {
      if (n.id === note.id) {
        n.content = note.content
        n.tags = note.tags
        n.updatedAt = note.updatedAt
        n.dateKey = note.dateKey
        n.pinned = note.pinned
        found = true
      }
    }
    if (!found) {
      list.push(note)
      await MomentStore.recordActivity(
        ActivityEvent.create('note', note.id, '记下小事', note.preview(), note.dateKey)
      )
    }
    await MomentStore.persistNotes(list)
    return true
  }

  static async deleteNote(id: string): Promise<void> {
    const list = await MomentStore.loadNotes()
    const next: MomentNote[] = []
    for (const n of list) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    await MomentStore.persistNotes(next)
  }

  static async togglePin(id: string): Promise<boolean> {
    const list = await MomentStore.loadNotes()
    let pinned = false
    for (const n of list) {
      if (n.id === id) {
        n.pinned = !n.pinned
        n.updatedAt = Date.now()
        pinned = n.pinned
        if (n.pinned) {
          await MomentStore.recordActivity(
            ActivityEvent.create('star', n.id, '星标小事', n.preview(), n.dateKey)
          )
        }
      }
    }
    await MomentStore.persistNotes(list)
    return pinned
  }

  static async convertNoteToTodo(noteId: string): Promise<boolean> {
    const note = await MomentStore.findNote(noteId)
    if (note === undefined) {
      return false
    }
    const t = MomentTodo.createNew()
    const text = note.content.trim()
    t.content = text.length > 80 ? `${text.substring(0, 80)}…` : text
    t.bucket = 'today'
    t.priority = 'medium'
    return await MomentStore.saveTodo(t)
  }

  static splitPieces(text: string): string[] {
    const out: string[] = []
    let buf = ''
    for (let i = 0; i < text.length; i++) {
      const ch = text.charAt(i)
      if (ch === '。' || ch === '！' || ch === '？' || ch === '\n' || ch === '；' || ch === ';') {
        const piece = buf.trim()
        if (piece.length > 0) {
          out.push(piece.length > 80 ? `${piece.substring(0, 80)}…` : piece)
        }
        buf = ''
      } else {
        buf += ch
      }
      if (out.length >= 3) {
        return out
      }
    }
    const last = buf.trim()
    if (last.length > 0 && out.length < 3) {
      out.push(last.length > 80 ? `${last.substring(0, 80)}…` : last)
    }
    if (out.length === 0) {
      const fallback = text.trim()
      if (fallback.length > 0) {
        out.push(fallback.length > 80 ? `${fallback.substring(0, 80)}…` : fallback)
      }
    }
    return out
  }

  static async splitNoteToTodos(noteId: string): Promise<number> {
    const note = await MomentStore.findNote(noteId)
    if (note === undefined) {
      return 0
    }
    const pieces = MomentStore.splitPieces(note.content)
    let count = 0
    for (const piece of pieces) {
      const t = MomentTodo.createNew()
      t.content = piece
      t.bucket = 'today'
      t.priority = 'medium'
      const ok = await MomentStore.saveTodo(t)
      if (ok) {
        count++
      }
    }
    return count
  }

  static async settleTodoAsNote(todoId: string, feeling: string): Promise<boolean> {
    const todo = await MomentStore.findTodo(todoId)
    if (todo === undefined) {
      return false
    }
    const note = MomentNote.createNew(DateHelper.todayKey())
    const feel = feeling.trim()
    if (feel.length > 0) {
      note.content = `做成了「${todo.content}」。${feel}`
    } else {
      note.content = `做成了「${todo.content}」。`
    }
    note.tags = ['日常生活']
    return await MomentStore.saveNote(note)
  }

  static async loadTodos(): Promise<MomentTodo[]> {
    const raw = await MomentStore.getString(KEY_TODOS, '')
    return MomentStore.parseTodos(raw)
  }

  static async findTodo(id: string): Promise<MomentTodo | undefined> {
    const list = await MomentStore.loadTodos()
    for (const t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async saveTodo(todo: MomentTodo): Promise<boolean> {
    const content = todo.content.trim()
    if (content.length === 0) {
      return false
    }
    todo.content = content
    todo.updatedAt = Date.now()
    const list = await MomentStore.loadTodos()
    let found = false
    for (const t of list) {
      if (t.id === todo.id) {
        t.content = todo.content
        t.priority = todo.priority
        t.bucket = todo.bucket
        t.isCompleted = todo.isCompleted
        t.updatedAt = todo.updatedAt
        found = true
      }
    }
    if (!found) {
      list.push(todo)
    }
    await MomentStore.persistTodos(list)
    return true
  }

  static async toggleTodo(id: string): Promise<void> {
    const list = await MomentStore.loadTodos()
    for (const t of list) {
      if (t.id === id) {
        t.isCompleted = !t.isCompleted
        t.updatedAt = Date.now()
        if (t.isCompleted) {
          await MomentStore.recordActivity(
            ActivityEvent.create(
              'todo_done',
              t.id,
              '完成待办',
              t.content,
              DateHelper.keyFromDate(new Date(t.updatedAt))
            )
          )
        }
      }
    }
    await MomentStore.persistTodos(list)
  }

  static async moveTodoBucket(id: string, bucket: string): Promise<void> {
    const list = await MomentStore.loadTodos()
    for (const t of list) {
      if (t.id === id) {
        t.bucket = bucket
        t.updatedAt = Date.now()
      }
    }
    await MomentStore.persistTodos(list)
  }

  static async deleteTodo(id: string): Promise<void> {
    const list = await MomentStore.loadTodos()
    const next: MomentTodo[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    await MomentStore.persistTodos(next)
  }

  static async clearCompletedTodos(): Promise<number> {
    const list = await MomentStore.loadTodos()
    const next: MomentTodo[] = []
    let removed = 0
    for (const t of list) {
      if (t.isCompleted) {
        removed++
      } else {
        next.push(t)
      }
    }
    await MomentStore.persistTodos(next)
    return removed
  }

  static todayProgress(todos: MomentTodo[]): number {
    let total = 0
    let done = 0
    for (const t of todos) {
      if (t.bucket === 'today') {
        total++
        if (t.isCompleted) {
          done++
        }
      }
    }
    if (total === 0) {
      return 0
    }
    return Math.floor((done * 100) / total)
  }

  static async loadProfile(): Promise<UserProfile> {
    const raw = await MomentStore.getString(KEY_PROFILE, '')
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
    if (parts.length >= 3) {
      p.firstUseAt = parseInt(parts[2], 10)
    }
    return p
  }

  static async saveProfile(profile: UserProfile): Promise<void> {
    if (profile.firstUseAt <= 0) {
      profile.firstUseAt = Date.now()
    }
    const line = `${profile.nickname}\t${profile.themeMode}\t${profile.firstUseAt}`
    await MomentStore.putString(KEY_PROFILE, line)
  }

  static async ensureFirstUse(): Promise<void> {
    const p = await MomentStore.loadProfile()
    if (p.firstUseAt <= 0) {
      p.firstUseAt = Date.now()
      await MomentStore.saveProfile(p)
    }
  }

  static async tagStats(): Promise<TagStat[]> {
    const notes = await MomentStore.loadNotes()
    const map: TagStat[] = []
    for (const preset of TagPreset.all()) {
      const s = new TagStat()
      s.label = preset.label
      s.color = preset.color
      s.count = 0
      map.push(s)
    }
    for (const n of notes) {
      for (const tag of n.tags) {
        let hit = false
        for (const s of map) {
          if (s.label === tag) {
            s.count++
            hit = true
          }
        }
        if (!hit) {
          const extra = new TagStat()
          extra.label = tag
          extra.color = TagPreset.colorOf(tag)
          extra.count = 1
          map.push(extra)
        }
      }
    }
    const used: TagStat[] = []
    for (const s of map) {
      if (s.count > 0) {
        used.push(s)
      }
    }
    return used
  }

  static async monthCells(year: number, month: number): Promise<MonthCell[]> {
    const notes = await MomentStore.loadNotes()
    const marked: string[] = []
    for (const n of notes) {
      marked.push(n.dateKey)
    }
    const first = new Date(year, month, 1)
    const startPad = first.getDay()
    const days = DateHelper.daysInMonth(year, month)
    const cells: MonthCell[] = []
    for (let i = 0; i < startPad; i++) {
      const c = new MonthCell()
      c.inMonth = false
      c.slot = cells.length
      cells.push(c)
    }
    for (let d = 1; d <= days; d++) {
      const c = new MonthCell()
      c.day = d
      c.inMonth = true
      const dt = new Date(year, month, d)
      c.dateKey = DateHelper.keyFromDate(dt)
      c.hasNote = marked.indexOf(c.dateKey) >= 0
      c.slot = cells.length
      cells.push(c)
    }
    return cells
  }

  static async monthNoteCount(year: number, month: number): Promise<number> {
    const notes = await MomentStore.loadNotes()
    const prefix = `${year}-${month + 1 < 10 ? `0${month + 1}` : `${month + 1}`}`
    let count = 0
    for (const n of notes) {
      if (n.dateKey.indexOf(prefix) === 0) {
        count++
      }
    }
    return count
  }

  static async streakDays(): Promise<number> {
    const notes = await MomentStore.loadNotes()
    const set: string[] = []
    for (const n of notes) {
      if (set.indexOf(n.dateKey) < 0) {
        set.push(n.dateKey)
      }
    }
    let streak = 0
    let cursor = DateHelper.todayKey()
    while (set.indexOf(cursor) >= 0) {
      streak++
      cursor = DateHelper.addDays(cursor, -1)
    }
    return streak
  }

  static async weekSummary(): Promise<WeekSummary> {
    const summary = new WeekSummary()
    const start = DateHelper.weekStartKey()
    const notes = await MomentStore.loadNotes()
    const todos = await MomentStore.loadTodos()
    const tagHits: TagStat[] = []
    for (const n of notes) {
      if (n.dateKey >= start) {
        summary.noteCount++
        for (const tag of n.tags) {
          let found = false
          for (const s of tagHits) {
            if (s.label === tag) {
              s.count++
              found = true
            }
          }
          if (!found) {
            const extra = new TagStat()
            extra.label = tag
            extra.count = 1
            tagHits.push(extra)
          }
        }
      }
    }
    let top = 0
    for (const s of tagHits) {
      if (s.count > top) {
        top = s.count
        summary.topTag = s.label
      }
    }
    for (const t of todos) {
      if (t.isCompleted) {
        summary.todoDone++
      } else {
        summary.todoOpen++
      }
    }
    const tagPart = summary.topTag.length > 0 ? `，最多是#${summary.topTag}` : ''
    summary.line = `本周记下 ${summary.noteCount} 件小事${tagPart}。待办进行中 ${summary.todoOpen}、已完成 ${summary.todoDone}。`
    return summary
  }

  static async todayDigest(): Promise<WeekSummary> {
    const digest = new WeekSummary()
    const today = DateHelper.todayKey()
    const notes = await MomentStore.loadNotes()
    const todos = await MomentStore.loadTodos()
    for (const n of notes) {
      if (n.dateKey === today) {
        digest.noteCount++
      }
    }
    for (const t of todos) {
      if (t.bucket === 'today') {
        if (t.isCompleted) {
          digest.todoDone++
        } else {
          digest.todoOpen++
        }
      }
    }
    digest.line = `今天 ${digest.noteCount} 件小事 · 今日待办 ${digest.todoDone}/${digest.todoDone + digest.todoOpen}`
    return digest
  }

  static async buildMonthShare(year: number, month: number): Promise<MonthShareCard> {
    const card = new MonthShareCard()
    card.title = `小事记 · ${DateHelper.monthTitle(year, month)}`
    card.noteCount = await MomentStore.monthNoteCount(year, month)
    card.streak = await MomentStore.streakDays()
    const notes = await MomentStore.loadNotes()
    const lines: string[] = []
    lines.push(card.title)
    lines.push(`本月记下 ${card.noteCount} 件小事 · 连续 ${card.streak} 天`)
    lines.push('')
    let shown = 0
    const prefix = `${year}-${month + 1 < 10 ? `0${month + 1}` : `${month + 1}`}`
    for (const n of notes) {
      if (n.dateKey.indexOf(prefix) === 0 && shown < 8) {
        lines.push(`${n.dateKey}  ${n.preview()}`)
        shown++
      }
    }
    if (shown === 0) {
      lines.push('这个月还没有小事，打开小事记写下第一件吧。')
    }
    lines.push('')
    lines.push('—— 来自小事记')
    card.body = lines.join('\n')
    return card
  }

  static async buildWeekPoster(): Promise<MonthShareCard> {
    const card = new MonthShareCard()
    const week = await MomentStore.weekSummary()
    const streak = await MomentStore.streakDays()
    const wrap = await MomentStore.loadDailyWrap(DateHelper.todayKey())
    const tags = await MomentStore.tagStats()
    card.streak = streak
    card.noteCount = week.noteCount
    card.title = '小事记 · 本周生活海报'
    const tagBits: string[] = []
    let n = 0
    for (const s of tags) {
      if (n < 4 && s.count > 0) {
        tagBits.push(`#${s.label}`)
        n++
      }
    }
    const tagLine = tagBits.length > 0 ? tagBits.join('  ') : '本周还没有标签'
    const wrapLine = wrap.keep.trim().length > 0 ? wrap.keep.trim() : '今晚可以写一句今日收束'
    const lines: string[] = []
    lines.push(card.title)
    lines.push(`记下 ${week.noteCount} 件小事 · 待办完成 ${week.todoDone} · 连续 ${streak} 天`)
    lines.push(tagLine)
    lines.push('')
    lines.push(wrapLine)
    lines.push('')
    lines.push('—— 来自小事记')
    card.body = lines.join('\n')
    return card
  }

  static async exportText(): Promise<string> {
    const notes = await MomentStore.loadNotes()
    const todos = await MomentStore.loadTodos()
    const profile = await MomentStore.loadProfile()
    const review = await MomentStore.loadWeeklyReview(DateHelper.weekStartKey())
    const lines: string[] = []
    lines.push(`小事记导出 · ${profile.nickname}`)
    lines.push(`导出时间 ${DateHelper.displayLong(DateHelper.todayKey())}`)
    lines.push('')
    lines.push('【灵感随记】')
    if (notes.length === 0) {
      lines.push('（空）')
    }
    for (const n of notes) {
      const tags = n.tags.join(' #')
      lines.push(`${n.dateKey} ${DateHelper.timeLabel(n.createdAt)}`)
      lines.push(n.content)
      if (tags.length > 0) {
        lines.push(`#${tags}`)
      }
      lines.push('')
    }
    lines.push('【待办清单】')
    if (todos.length === 0) {
      lines.push('（空）')
    }
    for (const t of todos) {
      const mark = t.isCompleted ? '[完成]' : '[未完成]'
      lines.push(`${mark} ${t.bucketLabel()} ${t.priorityLabel()} ${t.content}`)
    }
    if (review.highlight.length > 0 || review.learned.length > 0 || review.nextIntent.length > 0) {
      lines.push('')
      lines.push('【本周复盘】')
      lines.push(`本周亮点：${review.highlight}`)
      lines.push(`新收获：${review.learned}`)
      lines.push(`下周想坚持：${review.nextIntent}`)
    }
    const wrap = await MomentStore.loadDailyWrap(DateHelper.todayKey())
    if (wrap.filled()) {
      lines.push('')
      lines.push('【今日收束】')
      lines.push(`心情：${wrap.mood}`)
      lines.push(`最想记住：${wrap.keep}`)
      lines.push(`明天一件事：${wrap.tomorrow}`)
    }
    const memorials = await MomentStore.loadMemorials()
    if (memorials.length > 0) {
      lines.push('')
      lines.push('【重要纪念日】')
      for (const m of memorials) {
        lines.push(`${m.dateKey} ${m.time} ${m.title}${m.enabled ? ' · 提醒开' : ''}`)
        if (m.note.length > 0) {
          lines.push(m.note)
        }
      }
    }
    return lines.join('\n')
  }

  static async last7DayActivity(): Promise<DayActivity[]> {
    const notes = await MomentStore.loadNotes()
    const todos = await MomentStore.loadTodos()
    const out: DayActivity[] = []
    const names: string[] = ['一', '二', '三', '四', '五', '六', '日']
    for (let i = 6; i >= 0; i--) {
      const key = DateHelper.addDays(DateHelper.todayKey(), -i)
      const d = DateHelper.parseKey(key)
      const day = new DayActivity()
      day.dateKey = key
      const wd = d.getDay()
      day.weekday = names[wd === 0 ? 6 : wd - 1]
      for (const n of notes) {
        if (n.dateKey === key) {
          day.noteCount++
        }
      }
      for (const t of todos) {
        if (t.isCompleted && DateHelper.keyFromDate(new Date(t.updatedAt)) === key) {
          day.todoDone++
        }
      }
      out.push(day)
    }
    return out
  }

  static async randomNote(): Promise<MomentNote | undefined> {
    const list = await MomentStore.loadNotes()
    if (list.length === 0) {
      return undefined
    }
    const idx = Math.floor(Math.random() * list.length)
    return list[idx]
  }

  static async relatedNotes(noteId: string): Promise<MomentNote[]> {
    const self = await MomentStore.findNote(noteId)
    const out: MomentNote[] = []
    if (self === undefined || self.tags.length === 0) {
      return out
    }
    const primary = self.tags[0]
    const list = await MomentStore.loadNotes()
    for (const n of list) {
      if (n.id === noteId) {
        continue
      }
      if (n.tags.indexOf(primary) >= 0) {
        out.push(n)
      }
      if (out.length >= 3) {
        break
      }
    }
    return out
  }

  static async starredNotes(): Promise<MomentNote[]> {
    const list = await MomentStore.loadNotes()
    const out: MomentNote[] = []
    for (const n of list) {
      if (n.pinned) {
        out.push(n)
      }
    }
    return out
  }

  static async onThisDayNotes(todayKey: string): Promise<MomentNote[]> {
    const md = DateHelper.monthDay(todayKey)
    if (md.length === 0) {
      return []
    }
    const list = await MomentStore.loadNotes()
    const out: MomentNote[] = []
    for (const n of list) {
      if (n.dateKey === todayKey) {
        continue
      }
      if (DateHelper.monthDay(n.dateKey) === md) {
        out.push(n)
      }
      if (out.length >= 3) {
        break
      }
    }
    return out
  }

  static async weekCompare(): Promise<WeekCompare> {
    const c = new WeekCompare()
    const thisStart = DateHelper.weekStartKey()
    const lastStart = DateHelper.lastWeekStartKey()
    const notes = await MomentStore.loadNotes()
    const todos = await MomentStore.loadTodos()
    for (const n of notes) {
      if (n.dateKey >= thisStart) {
        c.thisNotes++
      } else if (n.dateKey >= lastStart && n.dateKey < thisStart) {
        c.lastNotes++
      }
      if (n.pinned) {
        c.starCount++
      }
    }
    for (const t of todos) {
      if (!t.isCompleted) {
        continue
      }
      const doneKey = DateHelper.keyFromDate(new Date(t.updatedAt))
      if (doneKey >= thisStart) {
        c.thisDone++
      } else if (doneKey >= lastStart && doneKey < thisStart) {
        c.lastDone++
      }
    }
    const wrap = await MomentStore.loadDailyWrap(DateHelper.todayKey())
    c.wrapDone = wrap.filled()
    const noteDelta = c.thisNotes - c.lastNotes
    const noteHint = noteDelta > 0 ? `比上周多 ${noteDelta} 件` : (noteDelta < 0 ? `比上周少 ${-noteDelta} 件` : '与上周件数持平')
    c.line = `本周 ${c.thisNotes} 件小事，${noteHint}。星标 ${c.starCount} 条，本周完成待办 ${c.thisDone}。`
    return c
  }

  static async loadDailyWrap(dateKey: string): Promise<DailyWrap> {
    const raw = await MomentStore.lookupWrap(dateKey)
    const w = new DailyWrap()
    w.dateKey = dateKey
    if (raw.length === 0) {
      return w
    }
    const parts = raw.split('\u0001')
    if (parts.length >= 1) {
      w.keep = parts[0]
    }
    if (parts.length >= 2) {
      w.mood = parts[1]
    }
    if (parts.length >= 3) {
      w.tomorrow = parts[2]
    }
    if (parts.length >= 4) {
      w.updatedAt = parseInt(parts[3], 10)
    }
    return w
  }

  static async saveDailyWrap(wrap: DailyWrap): Promise<void> {
    wrap.updatedAt = Date.now()
    const body = `${wrap.keep}\u0001${wrap.mood}\u0001${wrap.tomorrow}\u0001${wrap.updatedAt}`
    await MomentStore.upsertWrap(wrap.dateKey, body)
    if (wrap.mood.trim().length > 0) {
      await MomentStore.recordActivity(
        ActivityEvent.create('mood', wrap.dateKey, '记录心情', wrap.mood, wrap.dateKey)
      )
    }
  }

  private static async lookupWrap(dateKey: string): Promise<string> {
    const lines = await MomentStore.splitLines(await MomentStore.getString(KEY_WRAPS, ''))
    for (const line of lines) {
      const idx = line.indexOf('\t')
      if (idx <= 0) {
        continue
      }
      if (line.substring(0, idx) === dateKey) {
        return MomentStore.decodeBody(line.substring(idx + 1))
      }
    }
    return ''
  }

  private static async upsertWrap(dateKey: string, body: string): Promise<void> {
    const lines = await MomentStore.splitLines(await MomentStore.getString(KEY_WRAPS, ''))
    const next: string[] = []
    let found = false
    const encoded = MomentStore.encodeBody(body)
    for (const line of lines) {
      const idx = line.indexOf('\t')
      if (idx <= 0) {
        continue
      }
      if (line.substring(0, idx) === dateKey) {
        next.push(`${dateKey}\t${encoded}`)
        found = true
      } else {
        next.push(line)
      }
    }
    if (!found) {
      next.push(`${dateKey}\t${encoded}`)
    }
    await MomentStore.putString(KEY_WRAPS, next.join('\n'))
    MomentStore.notifyChanged()
  }

  static async loadWeeklyReview(weekKey: string): Promise<WeeklyReview> {
    const raw = await MomentStore.lookupWeekly(weekKey)
    const r = new WeeklyReview()
    r.weekKey = weekKey
    if (raw.length === 0) {
      return r
    }
    const parts = raw.split('\u0001')
    if (parts.length >= 1) {
      r.highlight = parts[0]
    }
    if (parts.length >= 2) {
      r.learned = parts[1]
    }
    if (parts.length >= 3) {
      r.nextIntent = parts[2]
    }
    if (parts.length >= 4) {
      r.updatedAt = parseInt(parts[3], 10)
    }
    return r
  }

  static async saveWeeklyReview(review: WeeklyReview): Promise<void> {
    review.updatedAt = Date.now()
    const body = `${review.highlight}\u0001${review.learned}\u0001${review.nextIntent}\u0001${review.updatedAt}`
    await MomentStore.upsertWeekly(review.weekKey, body)
  }

  static async milestones(): Promise<MilestoneBadge[]> {
    const notes = await MomentStore.loadNotes()
    const todos = await MomentStore.loadTodos()
    const streak = await MomentStore.streakDays()
    let done = 0
    for (const t of todos) {
      if (t.isCompleted) {
        done++
      }
    }
    const review = await MomentStore.loadWeeklyReview(DateHelper.weekStartKey())
    const hasReview = review.highlight.trim().length > 0 || review.learned.trim().length > 0
    const wrap = await MomentStore.loadDailyWrap(DateHelper.todayKey())
    let stars = 0
    for (const n of notes) {
      if (n.pinned) {
        stars++
      }
    }

    const moodDays = await MomentStore.moodStreak()

    const defs: string[][] = [
      ['first', '写下第一件小事', '开启你的记录轨迹', notes.length >= 1 ? '1' : '0'],
      ['week7', '连续记录 7 天', '坚持一周，轨迹连成线', streak >= 7 ? '1' : '0'],
      ['notes10', '累计 10 条随记', '生活细节开始被看见', notes.length >= 10 ? '1' : '0'],
      ['todo5', '完成 5 项待办', '小事也能被真正做完', done >= 5 ? '1' : '0'],
      ['review', '完成本周复盘', '用三问整理一周收获', hasReview ? '1' : '0'],
      ['wrap', '写下今日收束', '睡前把今天收成一句', wrap.filled() ? '1' : '0'],
      ['star', '星标 3 条小事', '把值得回看的片段收藏起来', stars >= 3 ? '1' : '0'],
      ['mood3', '连续 3 天记心情', '把心情轨迹画出来', moodDays >= 3 ? '1' : '0']
    ]
    const out: MilestoneBadge[] = []
    for (const row of defs) {
      const b = new MilestoneBadge()
      b.id = row[0]
      b.title = row[1]
      b.detail = row[2]
      b.unlocked = row[3] === '1'
      out.push(b)
    }
    return out
  }

  private static async lookupWeekly(weekKey: string): Promise<string> {
    const lines = await MomentStore.splitLines(await MomentStore.getString(KEY_WEEKLY, ''))
    for (const line of lines) {
      const idx = line.indexOf('\t')
      if (idx <= 0) {
        continue
      }
      if (line.substring(0, idx) === weekKey) {
        return MomentStore.decodeBody(line.substring(idx + 1))
      }
    }
    return ''
  }

  private static async upsertWeekly(weekKey: string, body: string): Promise<void> {
    const lines = await MomentStore.splitLines(await MomentStore.getString(KEY_WEEKLY, ''))
    const next: string[] = []
    let found = false
    const encoded = MomentStore.encodeBody(body)
    for (const line of lines) {
      const idx = line.indexOf('\t')
      if (idx <= 0) {
        continue
      }
      if (line.substring(0, idx) === weekKey) {
        next.push(`${weekKey}\t${encoded}`)
        found = true
      } else {
        next.push(line)
      }
    }
    if (!found) {
      next.push(`${weekKey}\t${encoded}`)
    }
    await MomentStore.putString(KEY_WEEKLY, next.join('\n'))
    MomentStore.notifyChanged()
  }

  private static encodeBody(text: string): string {
    return text.split('\n').join('\\n').split('\t').join(' ')
  }

  private static decodeBody(text: string): string {
    return text.split('\\n').join('\n')
  }

  private static async splitLines(raw: string): Promise<string[]> {
    if (raw.length === 0) {
      return []
    }
    return raw.split('\n')
  }

  static async moodStreak(): Promise<number> {
    let streak = 0
    let cursor = DateHelper.todayKey()
    for (let i = 0; i < 60; i++) {
      const wrap = await MomentStore.loadDailyWrap(cursor)
      if (wrap.mood.trim().length === 0) {
        break
      }
      streak++
      cursor = DateHelper.addDays(cursor, -1)
    }
    return streak
  }

  static async loadMoodTrend(days: number): Promise<MoodDay[]> {
    const out: MoodDay[] = []
    for (let i = days - 1; i >= 0; i--) {
      const key = DateHelper.addDays(DateHelper.todayKey(), -i)
      const wrap = await MomentStore.loadDailyWrap(key)
      const d = new MoodDay()
      d.dateKey = key
      d.mood = wrap.mood.trim()
      const keep = wrap.keep.trim()
      if (keep.length > 18) {
        d.short = `${keep.substring(0, 18)}…`
      } else {
        d.short = keep
      }
      out.push(d)
    }
    return out
  }

  static async loadCheckinCells(days: number): Promise<CheckinCell[]> {
    const notes = await MomentStore.loadNotes()
    const marked: string[] = []
    for (const n of notes) {
      if (marked.indexOf(n.dateKey) < 0) {
        marked.push(n.dateKey)
      }
    }
    const out: CheckinCell[] = []
    for (let i = days - 1; i >= 0; i--) {
      const key = DateHelper.addDays(DateHelper.todayKey(), -i)
      const cell = new CheckinCell()
      cell.dateKey = key
      cell.day = DateHelper.parseKey(key).getDate()
      cell.done = marked.indexOf(key) >= 0
      out.push(cell)
    }
    return out
  }

  static async todayCheckedIn(): Promise<boolean> {
    const today = DateHelper.todayKey()
    const notes = await MomentStore.loadNotes()
    for (const n of notes) {
      if (n.dateKey === today) {
        return true
      }
    }
    return false
  }

  static async loadMemorials(): Promise<LifeMemorial[]> {
    const raw = await MomentStore.getString(KEY_MEMORIALS, '')
    const list = MomentStore.parseMemorials(raw)
    list.sort((a, b) => {
      if (a.dateKey === b.dateKey) {
        return a.time.localeCompare(b.time)
      }
      return a.dateKey.localeCompare(b.dateKey)
    })
    return list
  }

  static async findMemorial(id: string): Promise<LifeMemorial | undefined> {
    const list = await MomentStore.loadMemorials()
    for (const m of list) {
      if (m.id === id) {
        return m
      }
    }
    return undefined
  }

  static async saveMemorial(item: LifeMemorial): Promise<boolean> {
    const title = item.title.trim()
    if (title.length === 0 || item.dateKey.length < 10) {
      return false
    }
    item.title = title
    item.note = item.note.trim()
    if (item.time.length < 5) {
      item.time = '09:00'
    }
    const list = await MomentStore.loadMemorials()
    let found = false
    for (const m of list) {
      if (m.id === item.id) {
        m.title = item.title
        m.dateKey = item.dateKey
        m.time = item.time
        m.note = item.note
        m.enabled = item.enabled
        m.agentId = item.agentId
        found = true
      }
    }
    if (!found) {
      list.push(item)
    }
    await MomentStore.persistMemorials(list)
    return true
  }

  static async deleteMemorial(id: string): Promise<number> {
    const list = await MomentStore.loadMemorials()
    let agentId = 0
    const next: LifeMemorial[] = []
    for (const m of list) {
      if (m.id === id) {
        agentId = m.agentId
      } else {
        next.push(m)
      }
    }
    await MomentStore.persistMemorials(next)
    return agentId
  }

  static async nextMemorial(): Promise<LifeMemorial | undefined> {
    const today = DateHelper.todayKey()
    const list = await MomentStore.loadMemorials()
    for (const m of list) {
      if (m.dateKey >= today) {
        return m
      }
    }
    return undefined
  }

  private static async persistMemorials(items: LifeMemorial[]): Promise<void> {
    const lines: string[] = []
    for (const m of items) {
      lines.push(MomentStore.serializeMemorial(m))
    }
    await MomentStore.putString(KEY_MEMORIALS, lines.join('\n'))
    MomentStore.notifyChanged()
  }

  private static serializeMemorial(m: LifeMemorial): string {
    const title = m.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const note = m.note.replace(/\t/g, ' ').replace(/\n/g, '↵')
    const on = m.enabled ? '1' : '0'
    return [m.id, title, m.dateKey, m.time, note, on, `${m.agentId}`].join('\t')
  }

  private static parseMemorials(raw: string): LifeMemorial[] {
    const out: LifeMemorial[] = []
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
      const m = new LifeMemorial()
      m.id = parts[0]
      m.title = parts[1]
      m.dateKey = parts[2]
      m.time = parts[3]
      m.note = parts[4].replace(/↵/g, '\n')
      m.enabled = parts[5] === '1'
      if (parts.length >= 7) {
        m.agentId = parseInt(parts[6], 10)
      }
      out.push(m)
    }
    return out
  }

  private static async persistNotes(items: MomentNote[]): Promise<void> {
    const lines: string[] = []
    for (const n of items) {
      lines.push(MomentStore.serializeNote(n))
    }
    await MomentStore.putString(KEY_NOTES, lines.join('\n'))
    MomentStore.notifyChanged()
  }

  private static async persistTodos(items: MomentTodo[]): Promise<void> {
    const lines: string[] = []
    for (const t of items) {
      lines.push(MomentStore.serializeTodo(t))
    }
    await MomentStore.putString(KEY_TODOS, lines.join('\n'))
    MomentStore.notifyChanged()
  }

  private static serializeNote(n: MomentNote): string {
    const content = n.content.replace(/\t/g, ' ').replace(/\n/g, '↵')
    const tags = n.tags.join('|')
    const pin = n.pinned ? '1' : '0'
    return [n.id, n.dateKey, content, tags, `${n.createdAt}`, `${n.updatedAt}`, pin].join('\t')
  }

  private static parseNotes(raw: string): MomentNote[] {
    const out: MomentNote[] = []
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
      const n = new MomentNote()
      n.id = parts[0]
      n.dateKey = parts[1]
      n.content = parts[2].replace(/↵/g, '\n')
      n.tags = parts[3].length > 0 ? parts[3].split('|') : []
      const migrated: string[] = []
      for (const tag of n.tags) {
        migrated.push(TagPreset.migrateLabel(tag))
      }
      n.tags = migrated
      n.createdAt = parseInt(parts[4], 10)
      n.updatedAt = parseInt(parts[5], 10)
      n.pinned = parts.length >= 7 && parts[6] === '1'
      out.push(n)
    }
    return out
  }

  private static serializeTodo(t: MomentTodo): string {
    const content = t.content.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const done = t.isCompleted ? '1' : '0'
    return [t.id, content, t.priority, t.bucket, done, `${t.createdAt}`, `${t.updatedAt}`].join('\t')
  }

  private static parseTodos(raw: string): MomentTodo[] {
    const out: MomentTodo[] = []
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
      const t = new MomentTodo()
      t.id = parts[0]
      t.content = parts[1]
      t.priority = parts[2]
      t.bucket = parts[3]
      t.isCompleted = parts[4] === '1'
      t.createdAt = parseInt(parts[5], 10)
      t.updatedAt = parseInt(parts[6], 10)
      out.push(t)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (MomentStore.pref === null) {
      return fallback
    }
    try {
      const v = await MomentStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (MomentStore.pref === null) {
      return
    }
    try {
      await MomentStore.pref.put(key, value)
      await MomentStore.pref.flush()
    } catch {
      // ignore
    }
  }

  static async loadDashboard(): Promise<HomeDashboard> {
    const d = new HomeDashboard()
    const notes = await MomentStore.loadNotes()
    const todos = await MomentStore.loadTodos()
    d.noteCount = notes.length
    d.streak = await MomentStore.streakDays()
    d.todayDone = await MomentStore.todayCheckedIn()
    const wrap = await MomentStore.loadDailyWrap(DateHelper.todayKey())
    d.todayMood = wrap.mood
    for (const n of notes) {
      if (n.pinned) {
        d.starCount++
      }
    }
    for (const t of todos) {
      if (t.bucket === 'today') {
        d.todoTotalToday++
        if (t.isCompleted) {
          d.todoDoneToday++
        }
      }
    }
    d.progressPct = d.todoTotalToday > 0 ?
      Math.round((d.todoDoneToday / d.todoTotalToday) * 100) : (d.todayDone ? 100 : 0)
    return d
  }

  static async recordActivity(event: ActivityEvent): Promise<void> {
    const list = await MomentStore.loadActivitiesRaw()
    const next: ActivityEvent[] = [event]
    for (let i = 0; i < list.length && next.length < 120; i++) {
      next.push(list[i])
    }
    await MomentStore.persistActivities(next)
  }

  static async loadRecentActivities(limit: number): Promise<ActivityEvent[]> {
    const stored = await MomentStore.loadActivitiesRaw()
    if (stored.length > 0) {
      const out: ActivityEvent[] = []
      for (let i = 0; i < stored.length && i < limit; i++) {
        out.push(stored[i])
      }
      return out
    }
    return await MomentStore.synthesizeActivities(limit)
  }

  private static async synthesizeActivities(limit: number): Promise<ActivityEvent[]> {
    const notes = await MomentStore.loadNotes()
    const todos = await MomentStore.loadTodos()
    const out: ActivityEvent[] = []
    for (let i = 0; i < notes.length && out.length < limit; i++) {
      out.push(ActivityEvent.create('note', notes[i].id, '记下小事', notes[i].preview(), notes[i].dateKey))
    }
    for (let i = 0; i < todos.length && out.length < limit; i++) {
      if (todos[i].isCompleted) {
        out.push(ActivityEvent.create(
          'todo_done',
          todos[i].id,
          '完成待办',
          todos[i].content,
          DateHelper.keyFromDate(new Date(todos[i].updatedAt))
        ))
      }
    }
    out.sort((a, b) => b.createdAt - a.createdAt)
    const trimmed: ActivityEvent[] = []
    for (let i = 0; i < out.length && i < limit; i++) {
      trimmed.push(out[i])
    }
    return trimmed
  }

  static async searchAll(query: string): Promise<SearchHit[]> {
    const q = query.trim()
    if (q.length === 0) {
      return []
    }
    const hits: SearchHit[] = []
    const notes = await MomentStore.loadNotes()
    for (let i = 0; i < notes.length; i++) {
      const n = notes[i]
      if (n.content.indexOf(q) >= 0 || n.tags.join('').indexOf(q) >= 0) {
        const h = new SearchHit()
        h.kind = 'note'
        h.refId = n.id
        h.title = n.preview()
        h.subtitle = `${n.dateKey} · ${n.tags.join(' ')}`
        hits.push(h)
      }
    }
    const todos = await MomentStore.loadTodos()
    for (let i = 0; i < todos.length; i++) {
      const t = todos[i]
      if (t.content.indexOf(q) >= 0) {
        const h = new SearchHit()
        h.kind = 'todo'
        h.refId = t.id
        h.title = t.content
        h.subtitle = `${t.bucketLabel()} · ${t.isCompleted ? '已完成' : '待办'}`
        hits.push(h)
      }
    }
    const plans = await MomentStore.loadPlans()
    for (let i = 0; i < plans.length; i++) {
      const p = plans[i]
      if (p.title.indexOf(q) >= 0 || p.description.indexOf(q) >= 0) {
        const h = new SearchHit()
        h.kind = 'plan'
        h.refId = p.id
        h.title = p.title
        h.subtitle = `计划 · ${p.progress()}%`
        hits.push(h)
      }
    }
    return hits
  }

  static async loadPlans(): Promise<LifePlan[]> {
    const raw = await MomentStore.getString(KEY_PLANS, '')
    const list = MomentStore.parsePlans(raw)
    list.sort((a, b) => b.updatedAt - a.updatedAt)
    return list
  }

  static async findPlan(id: string): Promise<LifePlan | undefined> {
    const list = await MomentStore.loadPlans()
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === id) {
        return list[i]
      }
    }
    return undefined
  }

  static async savePlan(plan: LifePlan): Promise<boolean> {
    if (plan.title.trim().length === 0) {
      return false
    }
    plan.title = plan.title.trim()
    plan.updatedAt = Date.now()
    const list = await MomentStore.loadPlans()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === plan.id) {
        list[i].title = plan.title
        list[i].description = plan.description
        list[i].startDate = plan.startDate
        list[i].endDate = plan.endDate
        list[i].status = plan.status
        list[i].tasks = plan.tasks
        list[i].updatedAt = plan.updatedAt
        found = true
      }
    }
    if (!found) {
      list.push(plan)
    }
    await MomentStore.persistPlans(list)
    return true
  }

  static async togglePlanTask(planId: string, taskId: string): Promise<boolean> {
    const plan = await MomentStore.findPlan(planId)
    if (plan === undefined) {
      return false
    }
    for (let i = 0; i < plan.tasks.length; i++) {
      if (plan.tasks[i].id === taskId) {
        plan.tasks[i].done = !plan.tasks[i].done
        if (plan.tasks[i].done) {
          await MomentStore.recordActivity(
            ActivityEvent.create('plan_done', plan.id, `计划 · ${plan.title}`, plan.tasks[i].text, DateHelper.todayKey())
          )
        }
      }
    }
    if (plan.progress() >= 100) {
      plan.status = 'done'
    }
    return await MomentStore.savePlan(plan)
  }

  static async deletePlan(id: string): Promise<void> {
    const list = await MomentStore.loadPlans()
    const next: LifePlan[] = []
    for (let i = 0; i < list.length; i++) {
      if (list[i].id !== id) {
        next.push(list[i])
      }
    }
    await MomentStore.persistPlans(next)
  }

  static async loadTopics(): Promise<TopicCollection[]> {
    const raw = await MomentStore.getString(KEY_TOPICS, '')
    const list = MomentStore.parseTopics(raw)
    list.sort((a, b) => b.updatedAt - a.updatedAt)
    return list
  }

  static async findTopic(id: string): Promise<TopicCollection | undefined> {
    const list = await MomentStore.loadTopics()
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === id) {
        return list[i]
      }
    }
    return undefined
  }

  static async saveTopic(topic: TopicCollection): Promise<boolean> {
    if (topic.title.trim().length === 0) {
      return false
    }
    topic.title = topic.title.trim()
    topic.updatedAt = Date.now()
    const list = await MomentStore.loadTopics()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === topic.id) {
        list[i].title = topic.title
        list[i].coverColor = topic.coverColor
        list[i].noteIds = topic.noteIds
        list[i].updatedAt = topic.updatedAt
        found = true
      }
    }
    if (!found) {
      list.push(topic)
    }
    await MomentStore.persistTopics(list)
    return true
  }

  static async addNoteToTopic(topicId: string, noteId: string): Promise<boolean> {
    const topic = await MomentStore.findTopic(topicId)
    if (topic === undefined) {
      return false
    }
    if (topic.noteIds.indexOf(noteId) < 0) {
      topic.noteIds.push(noteId)
    }
    return await MomentStore.saveTopic(topic)
  }

  static async deleteTopic(id: string): Promise<void> {
    const list = await MomentStore.loadTopics()
    const next: TopicCollection[] = []
    for (let i = 0; i < list.length; i++) {
      if (list[i].id !== id) {
        next.push(list[i])
      }
    }
    await MomentStore.persistTopics(next)
  }

  static async notesInTopic(topicId: string): Promise<MomentNote[]> {
    const topic = await MomentStore.findTopic(topicId)
    if (topic === undefined) {
      return []
    }
    const notes = await MomentStore.loadNotes()
    const out: MomentNote[] = []
    for (let i = 0; i < notes.length; i++) {
      if (topic.noteIds.indexOf(notes[i].id) >= 0) {
        out.push(notes[i])
      }
    }
    return out
  }

  private static async loadActivitiesRaw(): Promise<ActivityEvent[]> {
    const raw = await MomentStore.getString(KEY_ACTIVITIES, '')
    return MomentStore.parseActivities(raw)
  }

  private static async persistActivities(items: ActivityEvent[]): Promise<void> {
    const lines: string[] = []
    for (let i = 0; i < items.length; i++) {
      lines.push(MomentStore.serializeActivity(items[i]))
    }
    await MomentStore.putString(KEY_ACTIVITIES, lines.join('\n'))
    MomentStore.notifyChanged()
  }

  private static serializeActivity(e: ActivityEvent): string {
    const title = e.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const summary = e.summary.replace(/\t/g, ' ').replace(/\n/g, '↵')
    return [e.id, e.type, e.refId, title, summary, e.dateKey, `${e.createdAt}`].join('\t')
  }

  private static parseActivities(raw: string): ActivityEvent[] {
    const out: ActivityEvent[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 7) {
        continue
      }
      const e = new ActivityEvent()
      e.id = parts[0]
      e.type = parts[1]
      e.refId = parts[2]
      e.title = parts[3]
      e.summary = parts[4].replace(/↵/g, '\n')
      e.dateKey = parts[5]
      e.createdAt = parseInt(parts[6], 10)
      out.push(e)
    }
    return out
  }

  private static async persistPlans(items: LifePlan[]): Promise<void> {
    const lines: string[] = []
    for (let i = 0; i < items.length; i++) {
      lines.push(MomentStore.serializePlan(items[i]))
    }
    await MomentStore.putString(KEY_PLANS, lines.join('\n'))
    MomentStore.notifyChanged()
  }

  private static serializePlan(p: LifePlan): string {
    const title = p.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const desc = p.description.replace(/\t/g, ' ').replace(/\n/g, '↵')
    const taskParts: string[] = []
    for (let i = 0; i < p.tasks.length; i++) {
      const t = p.tasks[i]
      const text = t.text.replace(/\t/g, ' ').replace(/\n/g, ' ')
      taskParts.push(`${t.id}:${text}:${t.done ? '1' : '0'}`)
    }
    const tasks = taskParts.join('|')
    return [p.id, title, desc, p.startDate, p.endDate, p.status, tasks, `${p.createdAt}`, `${p.updatedAt}`].join('\t')
  }

  private static parsePlans(raw: string): LifePlan[] {
    const out: LifePlan[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 8) {
        continue
      }
      const p = new LifePlan()
      p.id = parts[0]
      p.title = parts[1]
      p.description = parts[2].replace(/↵/g, '\n')
      p.startDate = parts[3]
      p.endDate = parts[4]
      p.status = parts[5]
      p.tasks = []
      if (parts[6].length > 0) {
        const chunks = parts[6].split('|')
        for (let j = 0; j < chunks.length; j++) {
          const seg = chunks[j].split(':')
          if (seg.length >= 3) {
            const t = new PlanTask()
            t.id = seg[0]
            t.text = seg[1]
            t.done = seg[2] === '1'
            p.tasks.push(t)
          }
        }
      }
      p.createdAt = parseInt(parts[7], 10)
      p.updatedAt = parseInt(parts[8], 10)
      out.push(p)
    }
    return out
  }

  private static async persistTopics(items: TopicCollection[]): Promise<void> {
    const lines: string[] = []
    for (let i = 0; i < items.length; i++) {
      lines.push(MomentStore.serializeTopic(items[i]))
    }
    await MomentStore.putString(KEY_TOPICS, lines.join('\n'))
    MomentStore.notifyChanged()
  }

  private static serializeTopic(t: TopicCollection): string {
    const title = t.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const ids = t.noteIds.join('|')
    return [t.id, title, t.coverColor, ids, `${t.createdAt}`, `${t.updatedAt}`].join('\t')
  }

  private static parseTopics(raw: string): TopicCollection[] {
    const out: TopicCollection[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 6) {
        continue
      }
      const t = new TopicCollection()
      t.id = parts[0]
      t.title = parts[1]
      t.coverColor = parts[2]
      t.noteIds = parts[3].length > 0 ? parts[3].split('|') : []
      t.createdAt = parseInt(parts[4], 10)
      t.updatedAt = parseInt(parts[5], 10)
      out.push(t)
    }
    return out
  }
}
