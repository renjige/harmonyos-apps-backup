import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { CommonSenseTime } from '../models/CommonSenseModels'
import { CommonSenseStore } from './CommonSenseStore'
import { CommonSenseLocalService } from './CommonSenseLocalService'
import {
  AchievementDef,
  DailyTaskState,
  DayStat,
  CategoryStat,
  LearningEvent,
  LearningPlan,
  UserNote,
  UserTopic,
  WeekReviewSummary,
  WorkbenchSnapshot
} from '../models/LearningHubModels'

const PREF = 'cs_learning_hub_v1'
const KEY_EVENTS = 'events'
const KEY_PLAN = 'plan'
const KEY_TASKS = 'tasks'
const KEY_ACH = 'achievements'
const KEY_TOPICS = 'topics'
const KEY_NOTES = 'notes'
const MAX_EVENTS = 120

class EventWire {
  id: string = ''
  type: string = ''
  refId: string = ''
  title: string = ''
  summary: string = ''
  createdAt: string = ''
}

class PlanWire {
  weekKey: string = ''
  targetCount: number = 7
  completedCount: number = 0
}

class TaskWire {
  dateKey: string = ''
  readDone: boolean = false
  quizDone: boolean = false
  checkInDone: boolean = false
  checklistDone: boolean = false
}

class AchWire {
  key: string = ''
  unlockedAt: string = ''
}

class TopicWire {
  id: string = ''
  title: string = ''
  desc: string = ''
  factIds: string[] = []
  createdAt: string = ''
}

class NoteWire {
  id: string = ''
  title: string = ''
  body: string = ''
  tags: string = ''
  createdAt: string = ''
  updatedAt: string = ''
}

class HubPayload {
  events: EventWire[] = []
  plan: PlanWire = new PlanWire()
  tasks: TaskWire[] = []
  achievements: AchWire[] = []
  topics: TopicWire[] = []
  notes: NoteWire[] = []
}

export class LearningHubService {
  private static pref: preferences.Preferences | null = null
  private static events: LearningEvent[] = []
  private static planRow: LearningPlan = new LearningPlan()
  private static tasks: DailyTaskState[] = []
  private static achievementRows: AchWire[] = []
  private static topicRows: UserTopic[] = []
  private static noteRows: UserNote[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    LearningHubService.pref = await preferences.getPreferences(context, PREF)
    await LearningHubService.load()
    LearningHubService.ensurePlanWeek()
    LearningHubService.ensureTodayTasks()
  }

  static weekKeyFromDate(dateKey: string): string {
    const parts = dateKey.split('-')
    if (parts.length < 3) {
      return dateKey
    }
    const y = Number(parts[0])
    const m = Number(parts[1]) - 1
    const d = Number(parts[2])
    const dt = new Date(y, m, d)
    const day = dt.getDay()
    const diff = day === 0 ? -6 : 1 - day
    const mon = new Date(dt)
    mon.setDate(dt.getDate() + diff)
    const mk = CommonSenseTime.todayKeyFromDate(mon)
    return mk.substring(0, 7) + '-W' + LearningHubService.isoWeekNumber(mon)
  }

  private static isoWeekNumber(dt: Date): string {
    const t = new Date(dt.getTime())
    t.setHours(0, 0, 0, 0)
    t.setDate(t.getDate() + 3 - (t.getDay() + 6) % 7)
    const week1 = new Date(t.getFullYear(), 0, 4)
    const n = 1 + Math.round(((t.getTime() - week1.getTime()) / 86400000 - 3 + (week1.getDay() + 6) % 7) / 7)
    return n < 10 ? '0' + n : '' + n
  }

  static workbench(): WorkbenchSnapshot {
    const snap = new WorkbenchSnapshot()
    snap.plan = LearningHubService.clonePlan()
    snap.tasks = LearningHubService.todayTasks()
    const st = CommonSenseStore.stats()
    snap.readCount = st.readCount
    snap.masterCount = st.mastered
    snap.favCount = st.favorites
    snap.streak = st.checkInStreak
    snap.recentEvents = LearningHubService.recentEvents(8)
    return snap
  }

  static weekReview(): WeekReviewSummary {
    const wk = LearningHubService.weekKeyFromDate(CommonSenseTime.todayKey())
    const sum = new WeekReviewSummary()
    sum.weekKey = wk
    const start = LearningHubService.weekStartKey()
    for (const ev of LearningHubService.events) {
      if (ev.createdAt.length >= 10 && ev.createdAt.substring(0, 10) >= start) {
        if (ev.type === 'read') {
          sum.readCount = sum.readCount + 1
        } else if (ev.type === 'quiz') {
          sum.quizCount = sum.quizCount + 1
        } else if (ev.type === 'favorite') {
          sum.favoriteCount = sum.favoriteCount + 1
        } else if (ev.type === 'master') {
          sum.masterCount = sum.masterCount + 1
        } else if (ev.type === 'list_learn') {
          sum.listLearnCount = sum.listLearnCount + 1
        }
      }
    }
    const days = CommonSenseStore.checkInDayKeys()
    for (const day of days) {
      if (day >= start) {
        sum.checkInDays = sum.checkInDays + 1
      }
    }
    return sum
  }

  static weekStartKey(): string {
    const today = CommonSenseTime.todayKey()
    const parts = today.split('-')
    const y = Number(parts[0])
    const m = Number(parts[1]) - 1
    const d = Number(parts[2])
    const dt = new Date(y, m, d)
    const day = dt.getDay()
    const diff = day === 0 ? -6 : 1 - day
    const mon = new Date(dt)
    mon.setDate(dt.getDate() + diff)
    return CommonSenseTime.todayKeyFromDate(mon)
  }

  static dailyStats(days: number): DayStat[] {
    const out: DayStat[] = []
    const keys = CommonSenseTime.recentDayKeys(days)
    for (const key of keys) {
      const row = new DayStat()
      row.label = key.substring(5)
      row.count = LearningHubService.countEventsOn(key)
      out.push(row)
    }
    return out
  }

  static categoryStats(): CategoryStat[] {
    const map: Map<string, number> = new Map()
    for (const ev of LearningHubService.events) {
      if (ev.type === 'read' && ev.summary.length > 0) {
        const c = ev.summary
        const prev = map.get(c)
        map.set(c, prev === undefined ? 1 : prev + 1)
      }
    }
    const out: CategoryStat[] = []
    map.forEach((count: number, category: string) => {
      const row = new CategoryStat()
      row.category = category
      row.label = category
      row.count = count
      out.push(row)
    })
    return out
  }

  static allEvents(): LearningEvent[] {
    return LearningHubService.cloneEvents()
  }

  static achievements(): AchievementDef[] {
    return LearningHubService.buildAchievementList()
  }

  static plan(): LearningPlan {
    return LearningHubService.clonePlan()
  }

  static setPlanTarget(target: number): Promise<void> {
    const t = target < 1 ? 1 : (target > 21 ? 21 : target)
    LearningHubService.planRow.targetCount = t
    return LearningHubService.persist()
  }

  static todayTasks(): DailyTaskState {
    LearningHubService.ensureTodayTasks()
    const key = CommonSenseTime.todayKey()
    for (const row of LearningHubService.tasks) {
      if (row.dateKey === key) {
        return LearningHubService.cloneTask(row)
      }
    }
    const fresh = new DailyTaskState()
    fresh.dateKey = key
    return fresh
  }

  static topics(): UserTopic[] {
    return LearningHubService.cloneTopics()
  }

  static notes(): UserNote[] {
    return LearningHubService.cloneNotes()
  }

  static topicById(id: string): UserTopic | undefined {
    for (const t of LearningHubService.topicRows) {
      if (t.id === id) {
        return LearningHubService.cloneTopic(t)
      }
    }
    return undefined
  }

  static noteById(id: string): UserNote | undefined {
    for (const n of LearningHubService.noteRows) {
      if (n.id === id) {
        return LearningHubService.cloneNote(n)
      }
    }
    return undefined
  }

  static async createTopic(title: string, desc: string): Promise<UserTopic> {
    const row = new UserTopic()
    row.id = 'topic_' + Date.now()
    row.title = title.trim()
    row.desc = desc.trim()
    row.createdAt = CommonSenseTime.nowIso()
    LearningHubService.topicRows.unshift(row)
    await LearningHubService.persist()
    await LearningHubService.logEvent('topic', row.id, row.title, '新建专题')
    return LearningHubService.cloneTopic(row)
  }

  static async addFactToTopic(topicId: string, factId: string): Promise<void> {
    for (const t of LearningHubService.topicRows) {
      if (t.id === topicId) {
        let exists = false
        for (const fid of t.factIds) {
          if (fid === factId) {
            exists = true
          }
        }
        if (!exists) {
          t.factIds.push(factId)
        }
        break
      }
    }
    await LearningHubService.persist()
  }

  static async saveNote(note: UserNote): Promise<void> {
    let found = false
    for (let i = 0; i < LearningHubService.noteRows.length; i++) {
      if (LearningHubService.noteRows[i].id === note.id) {
        LearningHubService.noteRows[i] = LearningHubService.cloneNote(note)
        LearningHubService.noteRows[i].updatedAt = CommonSenseTime.nowIso()
        found = true
        break
      }
    }
    if (!found) {
      const row = LearningHubService.cloneNote(note)
      if (row.id.length === 0) {
        row.id = 'note_' + Date.now()
      }
      row.createdAt = CommonSenseTime.nowIso()
      row.updatedAt = row.createdAt
      LearningHubService.noteRows.unshift(row)
    }
    await LearningHubService.persist()
    await LearningHubService.logEvent('note', note.id, note.title, '保存笔记')
  }

  static async deleteNote(id: string): Promise<void> {
    const next: UserNote[] = []
    for (const n of LearningHubService.noteRows) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    LearningHubService.noteRows = next
    await LearningHubService.persist()
  }

  static async onRead(factId: string, title: string, category: string): Promise<void> {
    await LearningHubService.markTask('readDone')
    LearningHubService.planRow.completedCount = LearningHubService.planRow.completedCount + 1
    await LearningHubService.logEvent('read', factId, title, category)
    await LearningHubService.evaluateAchievements()
    await LearningHubService.persist()
    LearningHubService.bumpRefresh()
  }

  static async onFavorite(factId: string, title: string, added: boolean): Promise<void> {
    if (added) {
      await LearningHubService.logEvent('favorite', factId, title, '收藏常识')
    }
    await LearningHubService.evaluateAchievements()
    await LearningHubService.persist()
    LearningHubService.bumpRefresh()
  }

  static async onCheckIn(): Promise<void> {
    await LearningHubService.markTask('checkInDone')
    await LearningHubService.logEvent('checkin', CommonSenseTime.todayKey(), '今日打卡', '连续学习')
    await LearningHubService.evaluateAchievements()
    await LearningHubService.persist()
    LearningHubService.bumpRefresh()
  }

  static async onQuiz(score: number, total: number): Promise<void> {
    await LearningHubService.markTask('quizDone')
    const summary = `答对 ${score}/${total}`
    await LearningHubService.logEvent('quiz', CommonSenseTime.todayKey(), '常识小测', summary)
    await LearningHubService.evaluateAchievements()
    await LearningHubService.persist()
    LearningHubService.bumpRefresh()
  }

  static async onListLearned(factId: string, title: string): Promise<void> {
    await LearningHubService.markTask('checklistDone')
    await LearningHubService.logEvent('list_learn', factId, title, '清单已掌握')
    await LearningHubService.evaluateAchievements()
    await LearningHubService.persist()
    LearningHubService.bumpRefresh()
  }

  static async onMaster(factId: string, title: string): Promise<void> {
    await LearningHubService.logEvent('master', factId, title, '深度掌握')
    await LearningHubService.evaluateAchievements()
    await LearningHubService.persist()
    LearningHubService.bumpRefresh()
  }

  private static async markTask(field: string): Promise<void> {
    LearningHubService.ensureTodayTasks()
    const key = CommonSenseTime.todayKey()
    for (const row of LearningHubService.tasks) {
      if (row.dateKey === key) {
        if (field === 'readDone') {
          row.readDone = true
        } else if (field === 'quizDone') {
          row.quizDone = true
        } else if (field === 'checkInDone') {
          row.checkInDone = true
        } else if (field === 'checklistDone') {
          row.checklistDone = true
        }
        return
      }
    }
  }

  private static async logEvent(type: string, refId: string, title: string, summary: string): Promise<void> {
    const ev = new LearningEvent()
    ev.id = 'ev_' + Date.now() + '_' + type
    ev.type = type
    ev.refId = refId
    ev.title = title
    ev.summary = summary
    ev.createdAt = CommonSenseTime.nowIso()
    LearningHubService.events.unshift(ev)
    if (LearningHubService.events.length > MAX_EVENTS) {
      LearningHubService.events = LearningHubService.events.slice(0, MAX_EVENTS)
    }
  }

  private static countEventsOn(dateKey: string): number {
    let n = 0
    for (const ev of LearningHubService.events) {
      if (ev.createdAt.length >= 10 && ev.createdAt.substring(0, 10) === dateKey) {
        n = n + 1
      }
    }
    return n
  }

  private static recentEvents(limit: number): LearningEvent[] {
    const out: LearningEvent[] = []
    const max = limit < LearningHubService.events.length ? limit : LearningHubService.events.length
    for (let i = 0; i < max; i++) {
      out.push(LearningHubService.cloneEvent(LearningHubService.events[i]))
    }
    return out
  }

  private static ensurePlanWeek(): void {
    const wk = LearningHubService.weekKeyFromDate(CommonSenseTime.todayKey())
    if (LearningHubService.planRow.weekKey !== wk) {
      LearningHubService.planRow.weekKey = wk
      LearningHubService.planRow.completedCount = 0
      if (LearningHubService.planRow.targetCount < 1) {
        LearningHubService.planRow.targetCount = 7
      }
    }
  }

  private static ensureTodayTasks(): void {
    const key = CommonSenseTime.todayKey()
    for (const row of LearningHubService.tasks) {
      if (row.dateKey === key) {
        return
      }
    }
    const fresh = new DailyTaskState()
    fresh.dateKey = key
    if (CommonSenseStore.isCheckedIn(key)) {
      fresh.checkInDone = true
    }
    LearningHubService.tasks.unshift(fresh)
    if (LearningHubService.tasks.length > 40) {
      LearningHubService.tasks = LearningHubService.tasks.slice(0, 40)
    }
  }

  private static async evaluateAchievements(): Promise<void> {
    const defs = LearningHubService.achievementCatalog()
    for (const def of defs) {
      if (LearningHubService.isUnlocked(def.key)) {
        continue
      }
      if (LearningHubService.isAchievementMet(def.key)) {
        const w = new AchWire()
        w.key = def.key
        w.unlockedAt = CommonSenseTime.nowIso()
        LearningHubService.achievementRows.push(w)
      }
    }
  }

  private static isAchievementMet(key: string): boolean {
    const st = CommonSenseStore.stats()
    if (key === 'first_read') {
      return st.readCount >= 1
    }
    if (key === 'streak_7') {
      return st.checkInStreak >= 7
    }
    if (key === 'streak_30') {
      return st.checkInStreak >= 30
    }
    if (key === 'master_10') {
      return st.mastered >= 10
    }
    if (key === 'quiz_5') {
      return LearningHubService.countType('quiz') >= 5
    }
    if (key === 'favorite_5') {
      return st.favorites >= 5
    }
    if (key === 'plan_done') {
      return LearningHubService.planRow.completedCount >= LearningHubService.planRow.targetCount
    }
    if (key === 'topic_1') {
      return LearningHubService.topicRows.length >= 1
    }
    if (key === 'note_3') {
      return LearningHubService.noteRows.length >= 3
    }
    return false
  }

  private static countType(type: string): number {
    let n = 0
    for (const ev of LearningHubService.events) {
      if (ev.type === type) {
        n = n + 1
      }
    }
    return n
  }

  private static achievementCatalog(): AchievementDef[] {
    const list: AchievementDef[] = []
    const rows: string[][] = [
      ['first_read', '初识常识', '完成首次阅读'],
      ['streak_7', '七日坚持', '连续打卡 7 天'],
      ['streak_30', '月度达人', '连续打卡 30 天'],
      ['master_10', '深度十条', '深度掌握 10 条常识'],
      ['quiz_5', '小测五胜', '完成 5 次常识小测'],
      ['favorite_5', '收藏五珍', '收藏 5 条常识'],
      ['plan_done', '计划达成', '完成本周学习计划'],
      ['topic_1', '专题起步', '创建第一个专题夹'],
      ['note_3', '笔记三本', '写下 3 篇学习笔记']
    ]
    for (const row of rows) {
      const def = new AchievementDef()
      def.key = row[0]
      def.title = row[1]
      def.desc = row[2]
      list.push(def)
    }
    return list
  }

  private static buildAchievementList(): AchievementDef[] {
    const catalog = LearningHubService.achievementCatalog()
    for (const def of catalog) {
      const at = LearningHubService.unlockedAt(def.key)
      if (at.length > 0) {
        def.unlocked = true
        def.unlockedAt = at
      }
    }
    return catalog
  }

  private static bumpRefresh(): void {
    const cur = AppStorage.get<number>('csRefresh')
    const next = cur === undefined ? 1 : cur + 1
    AppStorage.setOrCreate('csRefresh', next)
  }

  private static clonePlan(): LearningPlan {
    const p = new LearningPlan()
    p.weekKey = LearningHubService.planRow.weekKey
    p.targetCount = LearningHubService.planRow.targetCount
    p.completedCount = LearningHubService.planRow.completedCount
    return p
  }

  private static cloneTask(src: DailyTaskState): DailyTaskState {
    const t = new DailyTaskState()
    t.dateKey = src.dateKey
    t.readDone = src.readDone
    t.quizDone = src.quizDone
    t.checkInDone = src.checkInDone
    t.checklistDone = src.checklistDone
    return t
  }

  private static cloneEvent(src: LearningEvent): LearningEvent {
    const e = new LearningEvent()
    e.id = src.id
    e.type = src.type
    e.refId = src.refId
    e.title = src.title
    e.summary = src.summary
    e.createdAt = src.createdAt
    return e
  }

  private static cloneEvents(): LearningEvent[] {
    const out: LearningEvent[] = []
    for (const e of LearningHubService.events) {
      out.push(LearningHubService.cloneEvent(e))
    }
    return out
  }

  private static cloneTopic(src: UserTopic): UserTopic {
    const t = new UserTopic()
    t.id = src.id
    t.title = src.title
    t.desc = src.desc
    t.createdAt = src.createdAt
    const ids: string[] = []
    for (const fid of src.factIds) {
      ids.push(fid)
    }
    t.factIds = ids
    return t
  }

  private static cloneTopics(): UserTopic[] {
    const out: UserTopic[] = []
    for (const t of LearningHubService.topicRows) {
      out.push(LearningHubService.cloneTopic(t))
    }
    return out
  }

  private static cloneNote(src: UserNote): UserNote {
    const n = new UserNote()
    n.id = src.id
    n.title = src.title
    n.body = src.body
    n.tags = src.tags
    n.createdAt = src.createdAt
    n.updatedAt = src.updatedAt
    return n
  }

  private static cloneNotes(): UserNote[] {
    const out: UserNote[] = []
    for (const n of LearningHubService.noteRows) {
      out.push(LearningHubService.cloneNote(n))
    }
    return out
  }

  private static async load(): Promise<void> {
    if (LearningHubService.pref === null) {
      return
    }
    const raw = await LearningHubService.pref.get(KEY_EVENTS, '[]') as string
    LearningHubService.events = LearningHubService.parseEvents(raw)
    const planRaw = await LearningHubService.pref.get(KEY_PLAN, '') as string
    LearningHubService.planRow = LearningHubService.parsePlan(planRaw)
    const taskRaw = await LearningHubService.pref.get(KEY_TASKS, '[]') as string
    LearningHubService.tasks = LearningHubService.parseTasks(taskRaw)
    const achRaw = await LearningHubService.pref.get(KEY_ACH, '[]') as string
    LearningHubService.achievementRows = LearningHubService.parseAch(achRaw)
    const topicRaw = await LearningHubService.pref.get(KEY_TOPICS, '[]') as string
    LearningHubService.topicRows = LearningHubService.parseTopics(topicRaw)
    const noteRaw = await LearningHubService.pref.get(KEY_NOTES, '[]') as string
    LearningHubService.noteRows = LearningHubService.parseNotes(noteRaw)
  }

  private static async persist(): Promise<void> {
    if (LearningHubService.pref === null) {
      return
    }
    await LearningHubService.pref.put(KEY_EVENTS, LearningHubService.serializeEvents())
    await LearningHubService.pref.put(KEY_PLAN, LearningHubService.serializePlan())
    await LearningHubService.pref.put(KEY_TASKS, LearningHubService.serializeTasks())
    await LearningHubService.pref.put(KEY_ACH, LearningHubService.serializeAch())
    await LearningHubService.pref.put(KEY_TOPICS, LearningHubService.serializeTopics())
    await LearningHubService.pref.put(KEY_NOTES, LearningHubService.serializeNotes())
    await LearningHubService.pref.flush()
  }

  private static parseEvents(raw: string): LearningEvent[] {
    const out: LearningEvent[] = []
    try {
      const arr = JSON.parse(raw) as EventWire[]
      if (!Array.isArray(arr)) {
        return out
      }
      for (const w of arr) {
        const e = new LearningEvent()
        e.id = w.id !== undefined ? w.id : ''
        e.type = w.type !== undefined ? w.type : ''
        e.refId = w.refId !== undefined ? w.refId : ''
        e.title = w.title !== undefined ? w.title : ''
        e.summary = w.summary !== undefined ? w.summary : ''
        e.createdAt = w.createdAt !== undefined ? w.createdAt : ''
        out.push(e)
      }
    } catch {
    }
    return out
  }

  private static serializeEvents(): string {
    const wires: EventWire[] = []
    for (const e of LearningHubService.events) {
      const w = new EventWire()
      w.id = e.id
      w.type = e.type
      w.refId = e.refId
      w.title = e.title
      w.summary = e.summary
      w.createdAt = e.createdAt
      wires.push(w)
    }
    return JSON.stringify(wires)
  }

  private static parsePlan(raw: string): LearningPlan {
    const p = new LearningPlan()
    if (raw.length === 0) {
      return p
    }
    try {
      const w = JSON.parse(raw) as PlanWire
      p.weekKey = w.weekKey !== undefined ? w.weekKey : ''
      p.targetCount = w.targetCount !== undefined ? w.targetCount : 7
      p.completedCount = w.completedCount !== undefined ? w.completedCount : 0
    } catch {
    }
    return p
  }

  private static serializePlan(): string {
    const w = new PlanWire()
    w.weekKey = LearningHubService.planRow.weekKey
    w.targetCount = LearningHubService.planRow.targetCount
    w.completedCount = LearningHubService.planRow.completedCount
    return JSON.stringify(w)
  }

  private static parseTasks(raw: string): DailyTaskState[] {
    const out: DailyTaskState[] = []
    try {
      const arr = JSON.parse(raw) as TaskWire[]
      if (!Array.isArray(arr)) {
        return out
      }
      for (const w of arr) {
        const t = new DailyTaskState()
        t.dateKey = w.dateKey !== undefined ? w.dateKey : ''
        t.readDone = w.readDone === true
        t.quizDone = w.quizDone === true
        t.checkInDone = w.checkInDone === true
        t.checklistDone = w.checklistDone === true
        out.push(t)
      }
    } catch {
    }
    return out
  }

  private static serializeTasks(): string {
    const wires: TaskWire[] = []
    for (const t of LearningHubService.tasks) {
      const w = new TaskWire()
      w.dateKey = t.dateKey
      w.readDone = t.readDone
      w.quizDone = t.quizDone
      w.checkInDone = t.checkInDone
      w.checklistDone = t.checklistDone
      wires.push(w)
    }
    return JSON.stringify(wires)
  }

  private static isUnlocked(key: string): boolean {
    return LearningHubService.unlockedAt(key).length > 0
  }

  private static unlockedAt(key: string): string {
    for (const w of LearningHubService.achievementRows) {
      if (w.key === key) {
        return w.unlockedAt
      }
    }
    return ''
  }

  private static parseAch(raw: string): AchWire[] {
    const out: AchWire[] = []
    try {
      const arr = JSON.parse(raw) as AchWire[]
      if (!Array.isArray(arr)) {
        return out
      }
      for (const w of arr) {
        if (w.key !== undefined && w.unlockedAt !== undefined) {
          const row = new AchWire()
          row.key = w.key
          row.unlockedAt = w.unlockedAt
          out.push(row)
        }
      }
    } catch {
    }
    return out
  }

  private static serializeAch(): string {
    return JSON.stringify(LearningHubService.achievementRows)
  }

  private static parseTopics(raw: string): UserTopic[] {
    const out: UserTopic[] = []
    try {
      const arr = JSON.parse(raw) as TopicWire[]
      if (!Array.isArray(arr)) {
        return out
      }
      for (const w of arr) {
        const t = new UserTopic()
        t.id = w.id !== undefined ? w.id : ''
        t.title = w.title !== undefined ? w.title : ''
        t.desc = w.desc !== undefined ? w.desc : ''
        t.createdAt = w.createdAt !== undefined ? w.createdAt : ''
        if (Array.isArray(w.factIds)) {
          for (const fid of w.factIds) {
            t.factIds.push(fid)
          }
        }
        out.push(t)
      }
    } catch {
    }
    return out
  }

  private static serializeTopics(): string {
    const wires: TopicWire[] = []
    for (const t of LearningHubService.topicRows) {
      const w = new TopicWire()
      w.id = t.id
      w.title = t.title
      w.desc = t.desc
      w.createdAt = t.createdAt
      w.factIds = t.factIds
      wires.push(w)
    }
    return JSON.stringify(wires)
  }

  private static parseNotes(raw: string): UserNote[] {
    const out: UserNote[] = []
    try {
      const arr = JSON.parse(raw) as NoteWire[]
      if (!Array.isArray(arr)) {
        return out
      }
      for (const w of arr) {
        const n = new UserNote()
        n.id = w.id !== undefined ? w.id : ''
        n.title = w.title !== undefined ? w.title : ''
        n.body = w.body !== undefined ? w.body : ''
        n.tags = w.tags !== undefined ? w.tags : ''
        n.createdAt = w.createdAt !== undefined ? w.createdAt : ''
        n.updatedAt = w.updatedAt !== undefined ? w.updatedAt : ''
        out.push(n)
      }
    } catch {
    }
    return out
  }

  private static serializeNotes(): string {
    const wires: NoteWire[] = []
    for (const n of LearningHubService.noteRows) {
      const w = new NoteWire()
      w.id = n.id
      w.title = n.title
      w.body = n.body
      w.tags = n.tags
      w.createdAt = n.createdAt
      w.updatedAt = n.updatedAt
      wires.push(w)
    }
    return JSON.stringify(wires)
  }
}
