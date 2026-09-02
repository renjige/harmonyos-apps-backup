import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  HeatCell, KnowledgeCardItem, StudyNote, StudySession, StudySettings, StudyTask,
  DayStudyLine, DayStudySummary, WeeklyPlan, WeeklyPlanItem
} from '../models/StudyModels'

const STORE = 'xuejian_v1'
const KEY_SESSIONS = 'sessions'
const KEY_NOTES = 'notes'
const KEY_CARDS = 'cards'
const KEY_NICK = 'nickname'
const KEY_GOAL = 'daily_goal'
const KEY_REMIND = 'remind_hour'
const KEY_DARK = 'dark_mode'
const KEY_TASKS = 'tasks'
const KEY_CHECKIN = 'checkin'
const KEY_LEGACY_CLEANUP = 'legacy_cleanup_v103'
const KEY_WEEKLY_PLAN = 'weekly_plan'
const DAY_MS = 24 * 60 * 60 * 1000

class StoreMem {
  sessions: string = ''
  notes: string = ''
  cards: string = ''
  nickname: string = ''
  daily_goal: string = ''
  remind_hour: string = ''
  dark_mode: string = ''
  tasks: string = ''
  checkin: string = ''
  weekly_plan: string = ''
}

export class StudyStore {
  private static pref: preferences.Preferences | null = null
  private static mem: StoreMem = new StoreMem()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      StudyStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      StudyStore.pref = null
    }
    await StudyStore.ensureLegacyCleanup()
  }

  /** 启动时清除 1.0.2 误触生成的占位卡片/笔记，只执行一次 */
  static async ensureLegacyCleanup(): Promise<void> {
    const done = await StudyStore.getString(KEY_LEGACY_CLEANUP, '')
    if (done === '1') {
      return
    }
    let removed = 0
    const cards = await StudyStore.loadCards()
    const nextCards: KnowledgeCardItem[] = []
    for (const it of cards) {
      if (it.isPlaceholder()) {
        removed++
      } else {
        nextCards.push(it)
      }
    }
    if (nextCards.length !== cards.length) {
      await StudyStore.persistCards(nextCards)
    }
    const notes = await StudyStore.loadNotes()
    const nextNotes: StudyNote[] = []
    for (const it of notes) {
      if (it.isPlaceholder()) {
        removed++
      } else {
        nextNotes.push(it)
      }
    }
    if (nextNotes.length !== notes.length) {
      await StudyStore.persistNotes(nextNotes)
    }
    await StudyStore.putString(KEY_LEGACY_CLEANUP, '1')
    if (removed > 0) {
      AppStorage.setOrCreate('studyDataEpoch', (AppStorage.get<number>('studyDataEpoch') ?? 0) + 1)
    }
  }

  static async loadSessions(): Promise<StudySession[]> {
    return StudyStore.parseSessions(await StudyStore.getString(KEY_SESSIONS, ''))
  }

  static async addSession(item: StudySession): Promise<void> {
    const list = await StudyStore.loadSessions()
    list.unshift(item)
    await StudyStore.persistSessions(list)
  }

  static async deleteSession(id: string): Promise<void> {
    const list = await StudyStore.loadSessions()
    const next: StudySession[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await StudyStore.persistSessions(next)
  }

  static async loadTasks(): Promise<StudyTask[]> {
    return StudyStore.parseTasks(await StudyStore.getString(KEY_TASKS, ''))
  }

  static async saveTask(item: StudyTask): Promise<void> {
    const list = await StudyStore.loadTasks()
    const next: StudyTask[] = []
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
      next.unshift(item)
    }
    await StudyStore.persistTasks(next)
  }

  static async deleteTask(id: string): Promise<void> {
    const list = await StudyStore.loadTasks()
    const next: StudyTask[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await StudyStore.persistTasks(next)
  }

  static async loadNotes(): Promise<StudyNote[]> {
    return StudyStore.parseNotes(await StudyStore.getString(KEY_NOTES, ''))
  }

  static async saveNote(item: StudyNote): Promise<void> {
    item.updatedAt = Date.now()
    const list = await StudyStore.loadNotes()
    const next: StudyNote[] = []
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
      next.unshift(item)
    }
    await StudyStore.persistNotes(next)
  }

  static async deleteNote(id: string): Promise<void> {
    const list = await StudyStore.loadNotes()
    const next: StudyNote[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await StudyStore.persistNotes(next)
  }

  static async findNote(id: string): Promise<StudyNote | undefined> {
    const list = await StudyStore.loadNotes()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async loadCards(): Promise<KnowledgeCardItem[]> {
    return StudyStore.parseCards(await StudyStore.getString(KEY_CARDS, ''))
  }

  static async saveCard(item: KnowledgeCardItem): Promise<void> {
    item.updatedAt = Date.now()
    const list = await StudyStore.loadCards()
    const next: KnowledgeCardItem[] = []
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
      next.unshift(item)
    }
    await StudyStore.persistCards(next)
  }

  static async deleteCard(id: string): Promise<void> {
    const list = await StudyStore.loadCards()
    const next: KnowledgeCardItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await StudyStore.persistCards(next)
  }

  static async findCard(id: string): Promise<KnowledgeCardItem | undefined> {
    const list = await StudyStore.loadCards()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async randomReviewCard(): Promise<KnowledgeCardItem | undefined> {
    const list = await StudyStore.loadCards()
    const pool: KnowledgeCardItem[] = []
    const realPool: KnowledgeCardItem[] = []
    for (const it of list) {
      if (it.isMastered()) {
        continue
      }
      pool.push(it)
      if (!it.isPlaceholder()) {
        realPool.push(it)
      }
    }
    const pickFrom = realPool.length > 0 ? realPool : pool
    if (pickFrom.length === 0) {
      if (list.length === 0) {
        return undefined
      }
      return list[Math.floor(Math.random() * list.length)]
    }
    return pickFrom[Math.floor(Math.random() * pickFrom.length)]
  }

  static async loadSettings(): Promise<StudySettings> {
    const s = new StudySettings()
    const nick = await StudyStore.getString(KEY_NICK, '学习者')
    s.nickname = nick.length > 0 ? nick : '学习者'
    s.dailyGoalMinutes = StudyStore.num(await StudyStore.getString(KEY_GOAL, '90'))
    if (s.dailyGoalMinutes <= 0) {
      s.dailyGoalMinutes = 90
    }
    s.reminderHour = StudyStore.num(await StudyStore.getString(KEY_REMIND, '21'))
    return s
  }

  static async saveSettings(s: StudySettings): Promise<void> {
    await StudyStore.putString(KEY_NICK, s.nickname)
    await StudyStore.putString(KEY_GOAL, `${s.dailyGoalMinutes}`)
    await StudyStore.putString(KEY_REMIND, `${s.reminderHour}`)
  }

  static async loadDark(): Promise<boolean> {
    return (await StudyStore.getString(KEY_DARK, '0')) === '1'
  }

  static async saveDark(dark: boolean): Promise<void> {
    await StudyStore.putString(KEY_DARK, dark ? '1' : '0')
  }

  static async loadTodayCheckin(): Promise<string> {
    const today = StudyStore.dateKey(Date.now())
    const raw = await StudyStore.getString(KEY_CHECKIN, '')
    const lines = raw.split('\n')
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      const prefix = `${today}\t`
      if (line.indexOf(prefix) === 0) {
        return line.substring(prefix.length)
      }
    }
    return ''
  }

  static async saveTodayCheckin(text: string): Promise<void> {
    const today = StudyStore.dateKey(Date.now())
    const raw = await StudyStore.getString(KEY_CHECKIN, '')
    const lines = raw.split('\n')
    const next: string[] = []
    let found = false
    const row = `${today}\t${text}`
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      if (line.length === 0) {
        continue
      }
      if (line.indexOf(`${today}\t`) === 0) {
        next.push(row)
        found = true
      } else {
        next.push(line)
      }
    }
    if (!found) {
      next.unshift(row)
    }
    await StudyStore.putString(KEY_CHECKIN, next.join('\n'))
  }

  static todayMinutes(list: StudySession[]): number {
    const key = StudyStore.dateKey(Date.now())
    let sum = 0
    for (const it of list) {
      if (StudyStore.dateKey(it.endedAt) === key) {
        sum += it.minutes
      }
    }
    return sum
  }

  static streakDays(list: StudySession[]): number {
    const set: string[] = []
    for (const it of list) {
      if (it.minutes <= 0) {
        continue
      }
      const k = StudyStore.dateKey(it.endedAt)
      let seen = false
      for (const e of set) {
        if (e === k) {
          seen = true
        }
      }
      if (!seen) {
        set.push(k)
      }
    }
    let streak = 0
    let cursor = new Date()
    cursor.setHours(0, 0, 0, 0)
    while (true) {
      const key = StudyStore.dateKey(cursor.getTime())
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

  static heat30(list: StudySession[]): HeatCell[] {
    const mapMinutes: string[] = []
    const mapValues: number[] = []
    for (const it of list) {
      const k = StudyStore.dateKey(it.endedAt)
      let idx = -1
      for (let i = 0; i < mapMinutes.length; i++) {
        if (mapMinutes[i] === k) {
          idx = i
        }
      }
      if (idx < 0) {
        mapMinutes.push(k)
        mapValues.push(it.minutes)
      } else {
        mapValues[idx] = mapValues[idx] + it.minutes
      }
    }
    const out: HeatCell[] = []
    const start = new Date()
    start.setHours(0, 0, 0, 0)
    for (let i = 29; i >= 0; i--) {
      const t = start.getTime() - i * DAY_MS
      const cell = new HeatCell()
      cell.dateKey = StudyStore.dateKey(t)
      cell.dayLabel = `${new Date(t).getDate()}`
      cell.minutes = 0
      for (let j = 0; j < mapMinutes.length; j++) {
        if (mapMinutes[j] === cell.dateKey) {
          cell.minutes = mapValues[j]
        }
      }
      out.push(cell)
    }
    return out
  }

  static dateKey(ts: number): string {
    const d = new Date(ts)
    return `${d.getFullYear()}-${StudyStore.pad(d.getMonth() + 1)}-${StudyStore.pad(d.getDate())}`
  }

  static async daySnapshot(dateKey: string): Promise<DayStudySummary> {
    const summary = new DayStudySummary()
    summary.dateKey = dateKey
    const parts = dateKey.split('-')
    if (parts.length >= 3) {
      summary.dateLabel = `${parts[1]}月${parts[2]}日`
    } else {
      summary.dateLabel = dateKey
    }
    const sessions = await StudyStore.loadSessions()
    for (const s of sessions) {
      if (StudyStore.dateKey(s.endedAt) !== dateKey) {
        continue
      }
      summary.totalMinutes += s.minutes
      const line = new DayStudyLine()
      line.id = s.id
      line.kind = 'session'
      line.title = `专注 ${s.minutes} 分钟`
      line.subtitle = s.completed ? '已完成计时' : '补记时长'
      line.at = s.endedAt
      summary.lines.push(line)
    }
    const notes = await StudyStore.loadNotes()
    for (const n of notes) {
      if (StudyStore.dateKey(n.createdAt) !== dateKey) {
        continue
      }
      const line = new DayStudyLine()
      line.id = n.id
      line.kind = 'note'
      line.title = n.title
      line.subtitle = '学习笔记'
      line.at = n.createdAt
      summary.lines.push(line)
    }
    const cards = await StudyStore.loadCards()
    for (const c of cards) {
      if (StudyStore.dateKey(c.createdAt) !== dateKey) {
        continue
      }
      const line = new DayStudyLine()
      line.id = c.id
      line.kind = 'card'
      line.title = c.title
      line.subtitle = `知识卡片 · ${c.category}`
      line.at = c.createdAt
      summary.lines.push(line)
    }
    summary.checkinLine = await StudyStore.checkinForDate(dateKey)
    return summary
  }

  static async checkinForDate(dateKey: string): Promise<string> {
    const raw = await StudyStore.getString(KEY_CHECKIN, '')
    const lines = raw.split('\n')
    const prefix = `${dateKey}\t`
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      if (line.indexOf(prefix) === 0) {
        return line.substring(prefix.length)
      }
    }
    return ''
  }

  static weekKey(ts: number = Date.now()): string {
    const d = new Date(ts)
    d.setHours(0, 0, 0, 0)
    const day = d.getDay() === 0 ? 7 : d.getDay()
    d.setDate(d.getDate() - day + 1)
    return StudyStore.dateKey(d.getTime())
  }

  static async loadWeeklyPlan(): Promise<WeeklyPlan> {
    const plan = new WeeklyPlan()
    plan.weekKey = StudyStore.weekKey()
    const raw = await StudyStore.getString(KEY_WEEKLY_PLAN, '')
    if (raw.length === 0) {
      return plan
    }
    const rows = raw.split('\n')
    if (rows.length < 1) {
      return plan
    }
    plan.weekKey = rows[0]
    if (plan.weekKey !== StudyStore.weekKey()) {
      return plan
    }
    for (let i = 1; i < rows.length; i++) {
      const row = rows[i]
      if (row.length === 0) {
        continue
      }
      const p = row.split('\t')
      if (p.length < 3) {
        continue
      }
      const item = new WeeklyPlanItem()
      item.id = p[0]
      item.title = p[1]
      item.done = p[2] === '1'
      plan.items.push(item)
    }
    return plan
  }

  static async saveWeeklyPlan(plan: WeeklyPlan): Promise<void> {
    const lines: string[] = [plan.weekKey]
    for (const it of plan.items) {
      const title = it.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
      lines.push([it.id, title, it.done ? '1' : '0'].join('\t'))
    }
    await StudyStore.putString(KEY_WEEKLY_PLAN, lines.join('\n'))
  }

  static async ensureWeeklyPlan(): Promise<WeeklyPlan> {
    let plan = await StudyStore.loadWeeklyPlan()
    if (plan.items.length > 0) {
      return plan
    }
    plan.weekKey = StudyStore.weekKey()
    plan.items.push(WeeklyPlanItem.create('完成 3 次专注计时'))
    plan.items.push(WeeklyPlanItem.create('写 2 条学习笔记'))
    plan.items.push(WeeklyPlanItem.create('复习 5 张知识卡片'))
    await StudyStore.saveWeeklyPlan(plan)
    return plan
  }

  static async toggleWeeklyItem(id: string): Promise<void> {
    const plan = await StudyStore.loadWeeklyPlan()
    if (plan.items.length === 0) {
      await StudyStore.ensureWeeklyPlan()
      return
    }
    const next: WeeklyPlanItem[] = []
    for (const it of plan.items) {
      const copy = new WeeklyPlanItem()
      copy.id = it.id
      copy.title = it.title
      copy.done = it.id === id ? !it.done : it.done
      next.push(copy)
    }
    plan.items = next
    await StudyStore.saveWeeklyPlan(plan)
  }

  static async addWeeklyItem(title: string): Promise<void> {
    const trimmed = title.trim()
    if (trimmed.length === 0) {
      return
    }
    let plan = await StudyStore.loadWeeklyPlan()
    if (plan.items.length === 0) {
      plan = await StudyStore.ensureWeeklyPlan()
    }
    if (plan.items.length >= 5) {
      return
    }
    plan.items.push(WeeklyPlanItem.create(trimmed))
    await StudyStore.saveWeeklyPlan(plan)
  }

  static timeLabel(ts: number): string {
    const d = new Date(ts)
    return `${d.getMonth() + 1}月${d.getDate()}日 ${StudyStore.pad(d.getHours())}:${StudyStore.pad(d.getMinutes())}`
  }

  static hourOf(ts: number): number {
    return new Date(ts).getHours()
  }

  private static persistSessions(items: StudySession[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push([it.id, `${it.minutes}`, `${it.plannedMinutes}`, `${it.startedAt}`, `${it.endedAt}`,
        it.completed ? '1' : '0'].join('\t'))
    }
    return StudyStore.putString(KEY_SESSIONS, lines.join('\n'))
  }

  private static parseSessions(raw: string): StudySession[] {
    const out: StudySession[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 5) {
        continue
      }
      const s = new StudySession()
      s.id = p[0]
      s.minutes = StudyStore.num(p[1])
      s.plannedMinutes = StudyStore.num(p[2])
      s.startedAt = StudyStore.num(p[3])
      s.endedAt = StudyStore.num(p[4])
      s.completed = p.length >= 6 && p[5] === '1'
      out.push(s)
    }
    return out
  }

  private static persistNotes(items: StudyNote[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      const title = it.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
      const body = it.body.replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/\t/g, '\\t')
      const tags = it.tags.replace(/\t/g, ' ')
      lines.push([it.id, title, body, tags, it.coverKey, `${it.createdAt}`, `${it.updatedAt}`].join('\t'))
    }
    return StudyStore.putString(KEY_NOTES, lines.join('\n'))
  }

  private static parseNotes(raw: string): StudyNote[] {
    const out: StudyNote[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 5) {
        continue
      }
      const n = new StudyNote()
      n.id = p[0]
      n.title = p[1]
      n.body = p[2].replace(/\\n/g, '\n').replace(/\\t/g, '\t').replace(/\\\\/g, '\\')
      n.tags = p[3]
      n.coverKey = p[4]
      n.createdAt = p.length >= 6 ? StudyStore.num(p[5]) : 0
      n.updatedAt = p.length >= 7 ? StudyStore.num(p[6]) : n.createdAt
      out.push(n)
    }
    return out
  }

  private static persistCards(items: KnowledgeCardItem[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      const title = it.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
      const body = it.body.replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/\t/g, '\\t')
      lines.push([it.id, title, body, it.category, it.mastery, it.coverKey, `${it.createdAt}`, `${it.updatedAt}`].join('\t'))
    }
    return StudyStore.putString(KEY_CARDS, lines.join('\n'))
  }

  private static persistTasks(items: StudyTask[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      const title = it.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
      lines.push([it.id, title, it.done ? '1' : '0', `${it.createdAt}`].join('\t'))
    }
    return StudyStore.putString(KEY_TASKS, lines.join('\n'))
  }

  private static parseTasks(raw: string): StudyTask[] {
    const out: StudyTask[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 3) {
        continue
      }
      const t = new StudyTask()
      t.id = p[0]
      t.title = p[1]
      t.done = p[2] === '1'
      t.createdAt = p.length >= 4 ? StudyStore.num(p[3]) : 0
      out.push(t)
    }
    return out
  }

  private static parseCards(raw: string): KnowledgeCardItem[] {
    const out: KnowledgeCardItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 6) {
        continue
      }
      const c = new KnowledgeCardItem()
      c.id = p[0]
      c.title = p[1]
      c.body = p[2].replace(/\\n/g, '\n').replace(/\\t/g, '\t').replace(/\\\\/g, '\\')
      c.category = p[3]
      c.mastery = p[4]
      c.coverKey = p[5]
      c.createdAt = p.length >= 7 ? StudyStore.num(p[6]) : 0
      c.updatedAt = p.length >= 8 ? StudyStore.num(p[7]) : c.createdAt
      out.push(c)
    }
    return out
  }

  private static pad(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
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

  private static memGet(key: string): string {
    if (key === KEY_SESSIONS) {
      return StudyStore.mem.sessions
    }
    if (key === KEY_NOTES) {
      return StudyStore.mem.notes
    }
    if (key === KEY_CARDS) {
      return StudyStore.mem.cards
    }
    if (key === KEY_NICK) {
      return StudyStore.mem.nickname
    }
    if (key === KEY_GOAL) {
      return StudyStore.mem.daily_goal
    }
    if (key === KEY_REMIND) {
      return StudyStore.mem.remind_hour
    }
    if (key === KEY_DARK) {
      return StudyStore.mem.dark_mode
    }
    if (key === KEY_TASKS) {
      return StudyStore.mem.tasks
    }
    if (key === KEY_CHECKIN) {
      return StudyStore.mem.checkin
    }
    if (key === KEY_WEEKLY_PLAN) {
      return StudyStore.mem.weekly_plan
    }
    return ''
  }

  private static memSet(key: string, value: string): void {
    if (key === KEY_SESSIONS) {
      StudyStore.mem.sessions = value
    } else if (key === KEY_NOTES) {
      StudyStore.mem.notes = value
    } else if (key === KEY_CARDS) {
      StudyStore.mem.cards = value
    } else if (key === KEY_NICK) {
      StudyStore.mem.nickname = value
    } else if (key === KEY_GOAL) {
      StudyStore.mem.daily_goal = value
    } else if (key === KEY_REMIND) {
      StudyStore.mem.remind_hour = value
    } else if (key === KEY_DARK) {
      StudyStore.mem.dark_mode = value
    } else if (key === KEY_TASKS) {
      StudyStore.mem.tasks = value
    } else if (key === KEY_CHECKIN) {
      StudyStore.mem.checkin = value
    } else if (key === KEY_WEEKLY_PLAN) {
      StudyStore.mem.weekly_plan = value
    }
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    const mem = StudyStore.memGet(key)
    if (StudyStore.pref === null) {
      return mem.length > 0 ? mem : fallback
    }
    try {
      const v = await StudyStore.pref.get(key, fallback)
      const s = `${v}`
      if (s.length > 0) {
        StudyStore.memSet(key, s)
        return s
      }
      return mem.length > 0 ? mem : fallback
    } catch {
      return mem.length > 0 ? mem : fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    StudyStore.memSet(key, value)
    if (StudyStore.pref !== null) {
      try {
        await StudyStore.pref.put(key, value)
        await StudyStore.pref.flush()
      } catch {
      }
    }
    if (key !== KEY_DARK) {
      const epoch = (AppStorage.get<number>('studyDataEpoch') ?? 0) + 1
      AppStorage.setOrCreate('studyDataEpoch', epoch)
    }
  }
}
