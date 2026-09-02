import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  AchievementDef, AchievementRecord, BookLibraryItem, BookNoteRef, BookRankItem, CategoryStat,
  DailyCheckIn, LibraryShelfSnapshot, PlanRef, ReadingDiagnosisReport, ReadingPlan, ReadingSession,
  StatsSnapshot, TimelineDayGroup, TimelineDayItem,
  TopicShelf, WeeklyRecap, WorkbenchSnapshot
} from '../models/StudyModels'
import { BookNote, WeekDayStat } from '../models/BookNoteModels'
import { NoteStore } from './NoteStore'

const STORE = 'zhishang_fang_v1'
const KEY_PLANS = 'reading_plans'
const KEY_CHECKINS = 'daily_checkins'
const KEY_TOPICS = 'topic_shelves'
const KEY_ACHIEVEMENTS = 'achievements'
const KEY_RECALL_TOTAL = 'recall_total'
const KEY_BOOKS = 'book_library'
const KEY_SESSIONS = 'reading_sessions'

export class StudyStore {
  private static pref: preferences.Preferences | null = null
  private static ctx: common.UIAbilityContext | null = null
  private static plans: ReadingPlan[] = []
  private static checkins: DailyCheckIn[] = []
  private static topics: TopicShelf[] = []
  private static achievements: AchievementRecord[] = []
  private static books: BookLibraryItem[] = []
  private static sessions: ReadingSession[] = []
  private static ready: boolean = false
  private static lastUnlockId: string = ''

  static async init(context: common.UIAbilityContext): Promise<void> {
    StudyStore.ctx = context
    if (StudyStore.pref === null) {
      try {
        StudyStore.pref = await preferences.getPreferences(context, STORE)
      } catch {
        StudyStore.pref = null
      }
    }
    if (!StudyStore.ready) {
      StudyStore.plans = StudyStore.parsePlans(await StudyStore.getString(KEY_PLANS, ''))
      StudyStore.checkins = StudyStore.parseCheckins(await StudyStore.getString(KEY_CHECKINS, ''))
      StudyStore.topics = StudyStore.parseTopics(await StudyStore.getString(KEY_TOPICS, ''))
      StudyStore.achievements = StudyStore.parseAchievements(await StudyStore.getString(KEY_ACHIEVEMENTS, ''))
      StudyStore.books = StudyStore.parseBooks(await StudyStore.getString(KEY_BOOKS, ''))
      StudyStore.sessions = StudyStore.parseSessions(await StudyStore.getString(KEY_SESSIONS, ''))
      StudyStore.ready = true
      await StudyStore.ensureDefaultPlan()
    }
  }

  static async syncFromNotes(): Promise<string> {
    if (!StudyStore.ready && StudyStore.ctx !== null) {
      await StudyStore.init(StudyStore.ctx)
    }
    const notes = await NoteStore.loadAll()
    StudyStore.syncPlanProgress(notes)
    StudyStore.syncTodayExcerptCount(notes)
    await StudyStore.syncBookLibraryFromNotes(notes)
    await StudyStore.persistPlans()
    await StudyStore.persistCheckins()
    await StudyStore.persistBooks()
    const unlocked = await StudyStore.evaluateAchievements(notes)
    StudyStore.bumpEpoch()
    return unlocked
  }

  static bumpEpoch(): void {
    const epoch = (AppStorage.get<number>('studyEpoch') ?? 0) + 1
    AppStorage.setOrCreate('studyEpoch', epoch)
  }

  static lastUnlockedAchievement(): string {
    return StudyStore.lastUnlockId
  }

  static clearLastUnlock(): void {
    StudyStore.lastUnlockId = ''
  }

  // --- Plans ---

  static async loadPlans(): Promise<ReadingPlan[]> {
    await StudyStore.ensureReady()
    return StudyStore.plans
  }

  static async loadActivePlans(): Promise<ReadingPlan[]> {
    const all = await StudyStore.loadPlans()
    const out: ReadingPlan[] = []
    for (const p of all) {
      if (p.status === 'active') {
        out.push(p)
      }
    }
    return out
  }

  static async findPlan(id: string): Promise<ReadingPlan | undefined> {
    const all = await StudyStore.loadPlans()
    for (const p of all) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static async savePlan(plan: ReadingPlan): Promise<void> {
    await StudyStore.ensureReady()
    plan.updatedAt = Date.now()
    if (plan.isDone() && plan.status === 'active') {
      plan.status = 'done'
    }
    const next: ReadingPlan[] = []
    let found = false
    for (const p of StudyStore.plans) {
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
    StudyStore.plans = next
    await StudyStore.persistPlans()
    const notes = await NoteStore.loadAll()
    const unlocked = await StudyStore.evaluateAchievements(notes)
    StudyStore.bumpEpoch()
    if (unlocked.length > 0) {
      StudyStore.lastUnlockId = unlocked
    }
  }

  static async deletePlan(id: string): Promise<void> {
    await StudyStore.ensureReady()
    const next: ReadingPlan[] = []
    for (const p of StudyStore.plans) {
      if (p.id !== id) {
        next.push(p)
      }
    }
    StudyStore.plans = next
    await StudyStore.persistPlans()
    StudyStore.bumpEpoch()
  }

  // --- Check-in ---

  static async todayCheckIn(): Promise<DailyCheckIn> {
    await StudyStore.ensureReady()
    const key = StudyStore.dateKey(new Date())
    for (const c of StudyStore.checkins) {
      if (c.dateKey === key) {
        return c
      }
    }
    const row = new DailyCheckIn()
    row.dateKey = key
    return row
  }

  static async checkInToday(moodNote: string): Promise<void> {
    await StudyStore.ensureReady()
    const key = StudyStore.dateKey(new Date())
    const notes = await NoteStore.loadAll()
    let excerptToday = StudyStore.countNotesOnDate(notes, key)
    const next: DailyCheckIn[] = []
    let found = false
    for (const c of StudyStore.checkins) {
      if (c.dateKey === key) {
        const row = new DailyCheckIn()
        row.dateKey = key
        row.checked = true
        row.moodNote = moodNote.trim()
        row.excerptCount = excerptToday
        next.push(row)
        found = true
      } else {
        next.push(c)
      }
    }
    if (!found) {
      const row = new DailyCheckIn()
      row.dateKey = key
      row.checked = true
      row.moodNote = moodNote.trim()
      row.excerptCount = excerptToday
      next.push(row)
    }
    StudyStore.checkins = next
    await StudyStore.persistCheckins()
    const unlocked = await StudyStore.evaluateAchievements(notes)
    StudyStore.bumpEpoch()
    if (unlocked.length > 0) {
      StudyStore.lastUnlockId = unlocked
    }
  }

  static checkInStreak(): number {
    if (StudyStore.checkins.length === 0) {
      return 0
    }
    const keys: number[] = []
    for (const c of StudyStore.checkins) {
      if (c.checked) {
        keys.push(StudyStore.num(c.dateKey))
      }
    }
    keys.sort((a: number, b: number) => b - a)
    const now = new Date()
    let cursor = now.getFullYear() * 10000 + (now.getMonth() + 1) * 100 + now.getDate()
    let streak = 0
    for (const k of keys) {
      if (k === cursor) {
        streak++
        cursor = StudyStore.prevDayKey(cursor)
        continue
      }
      if (k === StudyStore.prevDayKey(cursor) && streak === 0) {
        cursor = k
        streak++
        cursor = StudyStore.prevDayKey(cursor)
        continue
      }
      break
    }
    return streak
  }

  static weekCheckInDays(): number {
    let count = 0
    const now = new Date()
    for (let i = 0; i < 7; i++) {
      const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - i)
      const key = StudyStore.dateKey(d)
      for (const c of StudyStore.checkins) {
        if (c.dateKey === key && c.checked) {
          count++
        }
      }
    }
    return count
  }

  // --- Topics ---

  static async loadTopics(): Promise<TopicShelf[]> {
    await StudyStore.ensureReady()
    return StudyStore.topics
  }

  static async findTopic(id: string): Promise<TopicShelf | undefined> {
    const all = await StudyStore.loadTopics()
    for (const t of all) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async saveTopic(topic: TopicShelf): Promise<void> {
    await StudyStore.ensureReady()
    topic.updatedAt = Date.now()
    const next: TopicShelf[] = []
    let found = false
    for (const t of StudyStore.topics) {
      if (t.id === topic.id) {
        next.push(topic)
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(topic)
    }
    StudyStore.topics = next
    await StudyStore.persistTopics()
    const notes = await NoteStore.loadAll()
    const unlocked = await StudyStore.evaluateAchievements(notes)
    StudyStore.bumpEpoch()
    if (unlocked.length > 0) {
      StudyStore.lastUnlockId = unlocked
    }
  }

  static async deleteTopic(id: string): Promise<void> {
    await StudyStore.ensureReady()
    const next: TopicShelf[] = []
    for (const t of StudyStore.topics) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    StudyStore.topics = next
    await StudyStore.persistTopics()
    StudyStore.bumpEpoch()
  }

  static async addNoteToTopic(topicId: string, noteId: string): Promise<boolean> {
    const topic = await StudyStore.findTopic(topicId)
    if (topic === undefined) {
      return false
    }
    for (const id of topic.noteIds) {
      if (id === noteId) {
        return true
      }
    }
    topic.noteIds.push(noteId)
    await StudyStore.saveTopic(topic)
    return true
  }

  static async topicsForNote(noteId: string): Promise<TopicShelf[]> {
    const all = await StudyStore.loadTopics()
    const out: TopicShelf[] = []
    for (const t of all) {
      for (const id of t.noteIds) {
        if (id === noteId) {
          out.push(t)
        }
      }
    }
    return out
  }

  // --- Book Library ---

  static async loadBooks(): Promise<BookLibraryItem[]> {
    await StudyStore.ensureReady()
    return StudyStore.books
  }

  static async findBook(id: string): Promise<BookLibraryItem | undefined> {
    const all = await StudyStore.loadBooks()
    for (const b of all) {
      if (b.id === id) {
        return b
      }
    }
    return undefined
  }

  static async findBookByTitle(title: string): Promise<BookLibraryItem | undefined> {
    const target = title.trim()
    if (target.length === 0) {
      return undefined
    }
    const all = await StudyStore.loadBooks()
    for (const b of all) {
      if (b.title.trim() === target) {
        return b
      }
    }
    return undefined
  }

  static async saveBook(book: BookLibraryItem): Promise<void> {
    await StudyStore.ensureReady()
    book.updatedAt = Date.now()
    const next: BookLibraryItem[] = []
    let found = false
    for (const b of StudyStore.books) {
      if (b.id === book.id) {
        next.push(book)
        found = true
      } else {
        next.push(b)
      }
    }
    if (!found) {
      next.push(book)
    }
    StudyStore.books = next
    await StudyStore.persistBooks()
    const notes = await NoteStore.loadAll()
    const unlocked = await StudyStore.evaluateAchievements(notes)
    StudyStore.bumpEpoch()
    if (unlocked.length > 0) {
      StudyStore.lastUnlockId = unlocked
    }
  }

  static async deleteBook(id: string): Promise<void> {
    await StudyStore.ensureReady()
    const next: BookLibraryItem[] = []
    for (const b of StudyStore.books) {
      if (b.id !== id) {
        next.push(b)
      }
    }
    StudyStore.books = next
    await StudyStore.persistBooks()
    StudyStore.bumpEpoch()
  }

  static noteCountForBook(title: string, notes: BookNote[]): number {
    const target = title.trim()
    let count = 0
    for (const n of notes) {
      if (n.bookName.trim() === target) {
        count++
      }
    }
    return count
  }

  static sessionMinutesForBook(bookId: string): number {
    let total = 0
    for (const s of StudyStore.sessions) {
      if (s.bookId === bookId) {
        total += s.durationMinutes
      }
    }
    return total
  }

  static async libraryShelfSnapshot(): Promise<LibraryShelfSnapshot> {
    await StudyStore.ensureReady()
    const snap = new LibraryShelfSnapshot()
    snap.totalBooks = StudyStore.books.length
    for (const b of StudyStore.books) {
      if (b.status === 'finished') {
        snap.finishedCount++
      } else if (b.status === 'wish') {
        snap.wishCount++
      } else {
        snap.readingCount++
      }
    }
    const notes = await NoteStore.loadAll()
    snap.totalExcerpts = notes.length
    for (const s of StudyStore.sessions) {
      snap.totalSessionMinutes += s.durationMinutes
    }
    return snap
  }

  static async loadSessions(): Promise<ReadingSession[]> {
    await StudyStore.ensureReady()
    const copy: ReadingSession[] = []
    for (const s of StudyStore.sessions) {
      copy.push(s)
    }
    copy.sort((a: ReadingSession, b: ReadingSession) => b.createdAt - a.createdAt)
    return copy
  }

  static async sessionsForBook(bookId: string): Promise<ReadingSession[]> {
    const all = await StudyStore.loadSessions()
    const out: ReadingSession[] = []
    for (const s of all) {
      if (s.bookId === bookId) {
        out.push(s)
      }
    }
    return out
  }

  static async saveSession(session: ReadingSession): Promise<void> {
    await StudyStore.ensureReady()
    StudyStore.sessions.push(session)
    await StudyStore.persistSessions()
    const notes = await NoteStore.loadAll()
    const unlocked = await StudyStore.evaluateAchievements(notes)
    StudyStore.bumpEpoch()
    if (unlocked.length > 0) {
      StudyStore.lastUnlockId = unlocked
    }
  }

  static totalSessionMinutes(): number {
    let total = 0
    for (const s of StudyStore.sessions) {
      total += s.durationMinutes
    }
    return total
  }

  static buildDiagnosisReport(scores: number[]): ReadingDiagnosisReport {
    const report = new ReadingDiagnosisReport()
    let depth = 0
    let collect = 0
    let plan = 0
    let wander = 0
    for (let i = 0; i < scores.length; i++) {
      const s = scores[i]
      const bucket = i % 4
      if (bucket === 0) {
        depth += s
      } else if (bucket === 1) {
        collect += s
      } else if (bucket === 2) {
        plan += s
      } else {
        wander += s
      }
    }
    if (plan >= depth && plan >= collect && plan >= wander) {
      report.readerType = '计划执行型读者'
      report.summary = '你习惯用目标和进度驱动阅读，适合把零散摘录沉淀成可追踪的阅读计划。'
      report.strengths = ['目标感强', '坚持打卡', '进度可视化']
      report.suggestions = ['为每本书设定页数目标', '每周回顾计划完成度', '读完一本再标记「已读完」']
      report.featureTips = ['书架 Tab 管理在读/想读/已读', '阅读计划自动累计摘录', '成长页查看月度报告']
    } else if (depth >= collect && depth >= wander) {
      report.readerType = '深度思考型读者'
      report.summary = '你更重视理解与反思，适合在摘录之外写下读书感悟，并用专题串联主题。'
      report.strengths = ['善于反思', '摘录质量高', '主题关联强']
      report.suggestions = ['每条摘录写一句感悟', '用专题整理同一主题', '抽卡回顾加深记忆']
      report.featureTips = ['添加书摘时填写「我的感悟」', '专题书架跨书整理', '成长页抽卡回顾']
    } else if (collect >= wander) {
      report.readerType = '碎片收集型读者'
      report.summary = '你乐于捕捉金句与灵感，适合建立书架分类并用标签快速检索。'
      report.strengths = ['捕捉速度快', '金句敏感', '覆盖面广']
      report.suggestions = ['及时打上智慧分类标签', '收藏优质金句', '按书名筛选书房列表']
      report.featureTips = ['智慧分类一键推荐', '收藏夹集中回顾', '书房按书筛选']
    } else {
      report.readerType = '灵感漫游型读者'
      report.summary = '你阅读路径灵活，适合用时间轴与本周回顾发现阅读轨迹中的亮点。'
      report.strengths = ['阅读面广', '联想丰富', '体验优先']
      report.suggestions = ['用专注阅读记录单次时长', '每周看回顾找高光句', '跨书专题串联灵感']
      report.featureTips = ['专注阅读计时', '本周阅读回顾', '完整时间轴浏览']
    }
    return report
  }

  static async isOnboardingDone(): Promise<boolean> {
    const v = await StudyStore.getString('onboarding_v12_done', '0')
    return v === '1'
  }

  static async markOnboardingDone(): Promise<void> {
    await StudyStore.putString('onboarding_v12_done', '1')
  }

  private static async syncBookLibraryFromNotes(notes: BookNote[]): Promise<void> {
    await StudyStore.ensureReady()
    const names: string[] = []
    for (const n of notes) {
      const name = n.bookName.trim()
      if (name.length === 0) {
        continue
      }
      let seen = false
      for (const x of names) {
        if (x === name) {
          seen = true
        }
      }
      if (!seen) {
        names.push(name)
      }
    }
    let changed = false
    for (const name of names) {
      const existing = await StudyStore.findBookByTitle(name)
      if (existing !== undefined) {
        continue
      }
      const b = BookLibraryItem.createNew()
      b.title = name
      for (const n of notes) {
        if (n.bookName.trim() === name && n.coverImage.length > 0) {
          b.coverImage = n.coverImage
          break
        }
      }
      StudyStore.books.push(b)
      changed = true
    }
    if (changed) {
      await StudyStore.persistBooks()
    }
  }

  // --- Achievements ---

  static async loadAchievements(): Promise<AchievementRecord[]> {
    await StudyStore.ensureReady()
    return StudyStore.achievements
  }

  static isUnlocked(id: string): boolean {
    for (const a of StudyStore.achievements) {
      if (a.id === id) {
        return true
      }
    }
    return false
  }

  static async bumpRecallTotal(): Promise<string> {
    const raw = await StudyStore.getString(KEY_RECALL_TOTAL, '0')
    const count = StudyStore.num(raw) + 1
    await StudyStore.putString(KEY_RECALL_TOTAL, `${count}`)
    const notes = await NoteStore.loadAll()
    return await StudyStore.evaluateAchievements(notes)
  }

  // --- Stats & Recap ---

  static async workbenchSnapshot(): Promise<WorkbenchSnapshot> {
    const snap = new WorkbenchSnapshot()
    const report = await NoteStore.monthlyReport()
    snap.monthGoalTarget = report.goalTarget
    snap.monthGoalProgress = report.goalProgress
    const today = await StudyStore.todayCheckIn()
    snap.todayCheckedIn = today.checked
    snap.checkInStreak = StudyStore.checkInStreak()
    const notes = await NoteStore.loadAll()
    let count = 0
    for (const n of notes) {
      if (count >= 3) {
        break
      }
      const ref = new BookNoteRef()
      ref.id = n.id
      ref.bookName = n.bookName
      ref.excerptPreview = n.excerptPreview()
      snap.recentNotes.push(ref)
      count++
    }
    const plans = await StudyStore.loadActivePlans()
    let pi = 0
    for (const p of plans) {
      if (pi >= 2) {
        break
      }
      const ref = new PlanRef()
      ref.id = p.id
      ref.title = p.title
      ref.progressPercent = p.progressPercent()
      ref.doneCount = p.doneCount
      ref.targetCount = p.targetCount
      snap.activePlans.push(ref)
      pi++
    }
    return snap
  }

  static async statsSnapshot(): Promise<StatsSnapshot> {
    const snap = new StatsSnapshot()
    const notes = await NoteStore.loadAll()
    const tagNames: string[] = []
    const tagCounts: number[] = []
    let totalTagged = 0
    for (const n of notes) {
      for (const t of n.tags) {
        totalTagged++
        let idx = -1
        let i = 0
        for (const name of tagNames) {
          if (name === t) {
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
    let j = 0
    for (const name of tagNames) {
      const row = new CategoryStat()
      row.name = name
      row.count = tagCounts[j]
      row.percent = notes.length > 0 ? Math.floor((tagCounts[j] * 100) / notes.length) : 0
      snap.categoryStats.push(row)
      j++
    }
    snap.categoryStats.sort((a: CategoryStat, b: CategoryStat) => b.count - a.count)
    const now = new Date()
    for (let i = 6; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth(), now.getDate() - i)
      const row = new WeekDayStat()
      row.label = `${d.getMonth() + 1}/${d.getDate()}`
      row.count = StudyStore.countNotesOnDate(notes, StudyStore.dateKey(d))
      snap.weekDays.push(row)
    }
    const bookNames: string[] = []
    const bookCounts: number[] = []
    for (const n of notes) {
      const name = n.bookName.trim()
      if (name.length === 0) {
        continue
      }
      let idx = -1
      let i = 0
      for (const bn of bookNames) {
        if (bn === name) {
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
    let bi = 0
    for (const name of bookNames) {
      const row = new BookRankItem()
      row.bookName = name
      row.count = bookCounts[bi]
      snap.topBooks.push(row)
      bi++
    }
    snap.topBooks.sort((a: BookRankItem, b: BookRankItem) => b.count - a.count)
    if (snap.topBooks.length > 3) {
      snap.topBooks = snap.topBooks.slice(0, 3)
    }
    snap.checkInStreak = StudyStore.checkInStreak()
    snap.unlockedAchievements = StudyStore.achievements.length
    snap.totalAchievements = AchievementDef.catalog().length
    return snap
  }

  static async fullTimeline(): Promise<TimelineDayGroup[]> {
    const notes = await NoteStore.loadAll()
    const sorted: BookNote[] = []
    for (const n of notes) {
      sorted.push(n)
    }
    sorted.sort((a: BookNote, b: BookNote) => b.createdAt - a.createdAt)
    const labels: string[] = []
    const groups: TimelineDayGroup[] = []
    for (const n of sorted) {
      const label = NoteStore.timeLabel(n.createdAt)
      let idx = -1
      let i = 0
      for (const l of labels) {
        if (l === label) {
          idx = i
        }
        i++
      }
      const item = new TimelineDayItem()
      item.id = n.id
      item.bookName = n.bookName
      item.excerptPreview = n.excerptPreview()
      item.tagLabel = n.tagLine()
      if (idx < 0) {
        labels.push(label)
        const g = new TimelineDayGroup()
        g.dateLabel = label
        g.items.push(item)
        groups.push(g)
      } else {
        groups[idx].items.push(item)
      }
    }
    return groups
  }

  static async weeklyRecap(): Promise<WeeklyRecap> {
    const recap = new WeeklyRecap()
    const now = new Date()
    recap.weekLabel = `${now.getMonth() + 1}月第${Math.ceil(now.getDate() / 7)}周`
    const weekStart = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 6).getTime()
    const notes = await NoteStore.loadAll()
    const tagNames: string[] = []
    const tagCounts: number[] = []
    for (const n of notes) {
      if (n.createdAt >= weekStart) {
        recap.newNotes++
        if (recap.highlightQuote.length === 0) {
          recap.highlightQuote = n.excerptPreview()
          recap.highlightBook = n.bookName
        }
        for (const t of n.tags) {
          let idx = -1
          let i = 0
          for (const name of tagNames) {
            if (name === t) {
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
    }
    let topCount = 0
    let ti = 0
    for (const name of tagNames) {
      if (tagCounts[ti] > topCount) {
        topCount = tagCounts[ti]
        recap.topTag = name
      }
      ti++
    }
    recap.checkInDays = StudyStore.weekCheckInDays()
    const raw = await StudyStore.getString(KEY_RECALL_TOTAL, '0')
    recap.recallCount = StudyStore.num(raw)
    return recap
  }

  // --- private ---

  private static async ensureReady(): Promise<void> {
    if (!StudyStore.ready && StudyStore.ctx !== null) {
      await StudyStore.init(StudyStore.ctx)
    }
  }

  private static async ensureDefaultPlan(): Promise<void> {
    if (StudyStore.plans.length > 0) {
      return
    }
    const p = ReadingPlan.createNew()
    const now = new Date()
    p.title = `${now.getMonth() + 1}月阅读计划`
    p.bookName = ''
    p.targetCount = await NoteStore.loadMonthlyGoal()
    p.deadline = new Date(now.getFullYear(), now.getMonth() + 1, 0).getTime()
    const notes = await NoteStore.loadAll()
    StudyStore.syncPlanProgress(notes, [p])
    StudyStore.plans = [p]
    await StudyStore.persistPlans()
  }

  private static syncPlanProgress(notes: BookNote[], plans?: ReadingPlan[]): void {
    const list = plans ?? StudyStore.plans
    for (const p of list) {
      let count = 0
      const monthStart = StudyStore.monthStart()
      for (const n of notes) {
        if (p.bookName.length > 0) {
          if (n.bookName.trim() === p.bookName && n.createdAt >= monthStart) {
            count++
          }
        } else if (n.createdAt >= monthStart) {
          count++
        }
      }
      p.doneCount = count
      if (p.isDone() && p.status === 'active') {
        p.status = 'done'
      }
    }
  }

  private static syncTodayExcerptCount(notes: BookNote[]): void {
    const key = StudyStore.dateKey(new Date())
    const count = StudyStore.countNotesOnDate(notes, key)
    const next: DailyCheckIn[] = []
    let found = false
    for (const c of StudyStore.checkins) {
      if (c.dateKey === key) {
        const row = new DailyCheckIn()
        row.dateKey = c.dateKey
        row.checked = c.checked || count > 0
        row.moodNote = c.moodNote
        row.excerptCount = count
        next.push(row)
        found = true
      } else {
        next.push(c)
      }
    }
    if (!found && count > 0) {
      const row = new DailyCheckIn()
      row.dateKey = key
      row.checked = true
      row.excerptCount = count
      next.push(row)
    }
    StudyStore.checkins = next
  }

  private static countNotesOnDate(notes: BookNote[], dateKey: string): number {
    let count = 0
    for (const n of notes) {
      if (StudyStore.dateKey(new Date(n.createdAt)) === dateKey) {
        count++
      }
    }
    return count
  }

  private static monthStart(): number {
    const now = new Date()
    return new Date(now.getFullYear(), now.getMonth(), 1).getTime()
  }

  private static async evaluateAchievements(notes: BookNote[]): Promise<string> {
    const unlocked: string[] = []
    const tryUnlock = (id: string): void => {
      if (!StudyStore.isUnlocked(id)) {
        const rec = new AchievementRecord()
        rec.id = id
        rec.unlockedAt = Date.now()
        StudyStore.achievements.push(rec)
        unlocked.push(id)
      }
    }
    if (notes.length >= 1) {
      tryUnlock('first_note')
    }
    if (notes.length >= 10) {
      tryUnlock('notes_10')
    }
    if (notes.length >= 50) {
      tryUnlock('notes_50')
    }
    let favCount = 0
    for (const n of notes) {
      if (n.isFavorite) {
        favCount++
      }
    }
    if (favCount >= 5) {
      tryUnlock('favorite_5')
    }
    const streak = StudyStore.checkInStreak()
    const excerptStreak = StudyStore.calcExcerptStreak(notes)
    if (streak >= 7 || excerptStreak >= 7) {
      tryUnlock('streak_7')
    }
    const recallRaw = await StudyStore.getString(KEY_RECALL_TOTAL, '0')
    if (StudyStore.num(recallRaw) >= 10) {
      tryUnlock('recall_10')
    }
    for (const p of StudyStore.plans) {
      if (p.status === 'done') {
        tryUnlock('plan_done')
      }
    }
    if (StudyStore.topics.length >= 1) {
      tryUnlock('topic_1')
    }
    if (StudyStore.sessions.length >= 3) {
      tryUnlock('session_3')
    }
    if (StudyStore.books.length >= 5) {
      tryUnlock('library_5')
    }
    if (unlocked.length > 0) {
      await StudyStore.persistAchievements()
    }
    return unlocked.length > 0 ? unlocked[0] : ''
  }

  private static calcExcerptStreak(notes: BookNote[]): number {
    if (notes.length === 0) {
      return 0
    }
    const daySet: number[] = []
    for (const n of notes) {
      const d = new Date(n.createdAt)
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
        cursor = StudyStore.prevDayKey(cursor)
        continue
      }
      if (k === StudyStore.prevDayKey(cursor) && streak === 0) {
        cursor = k
        streak++
        cursor = StudyStore.prevDayKey(cursor)
        continue
      }
      break
    }
    return streak
  }

  private static dateKey(d: Date): string {
    return `${d.getFullYear()}${StudyStore.pad(d.getMonth() + 1)}${StudyStore.pad(d.getDate())}`
  }

  private static prevDayKey(key: number): number {
    const y = Math.floor(key / 10000)
    const m = Math.floor((key % 10000) / 100)
    const d = key % 100
    const dt = new Date(y, m - 1, d)
    dt.setDate(dt.getDate() - 1)
    return dt.getFullYear() * 10000 + (dt.getMonth() + 1) * 100 + dt.getDate()
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

  private static serializePlan(p: ReadingPlan): string {
    const title = p.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const book = p.bookName.replace(/\t/g, ' ').replace(/\n/g, ' ')
    return [p.id, title, book, `${p.targetCount}`, `${p.doneCount}`, `${p.deadline}`, p.status,
      `${p.createdAt}`, `${p.updatedAt}`].join('\t')
  }

  private static parsePlans(raw: string): ReadingPlan[] {
    const out: ReadingPlan[] = []
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
      const p = new ReadingPlan()
      p.id = parts[0]
      p.title = parts[1]
      p.bookName = parts[2]
      p.targetCount = StudyStore.num(parts[3])
      p.doneCount = StudyStore.num(parts[4])
      p.deadline = StudyStore.num(parts[5])
      p.status = parts[6]
      if (parts.length >= 9) {
        p.createdAt = StudyStore.num(parts[7])
        p.updatedAt = StudyStore.num(parts[8])
      }
      out.push(p)
    }
    return out
  }

  private static serializeCheckin(c: DailyCheckIn): string {
    const note = c.moodNote.replace(/\t/g, ' ').replace(/\n/g, ' ')
    return [c.dateKey, c.checked ? '1' : '0', note, `${c.excerptCount}`].join('\t')
  }

  private static parseCheckins(raw: string): DailyCheckIn[] {
    const out: DailyCheckIn[] = []
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
      const c = new DailyCheckIn()
      c.dateKey = parts[0]
      c.checked = parts[1] === '1'
      c.moodNote = parts[2]
      c.excerptCount = StudyStore.num(parts[3])
      out.push(c)
    }
    return out
  }

  private static serializeTopic(t: TopicShelf): string {
    const title = t.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const summary = t.summary.replace(/\t/g, ' ').replace(/\n/g, ' ')
    return [t.id, title, summary, t.noteIds.join(','), `${t.createdAt}`, `${t.updatedAt}`].join('\t')
  }

  private static parseTopics(raw: string): TopicShelf[] {
    const out: TopicShelf[] = []
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
      const t = new TopicShelf()
      t.id = parts[0]
      t.title = parts[1]
      t.summary = parts[2]
      t.noteIds = parts[3].length === 0 ? [] : parts[3].split(',')
      if (parts.length >= 6) {
        t.createdAt = StudyStore.num(parts[4])
        t.updatedAt = StudyStore.num(parts[5])
      }
      out.push(t)
    }
    return out
  }

  private static parseAchievements(raw: string): AchievementRecord[] {
    const out: AchievementRecord[] = []
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
      const a = new AchievementRecord()
      a.id = parts[0]
      a.unlockedAt = StudyStore.num(parts[1])
      out.push(a)
    }
    return out
  }

  private static async persistPlans(): Promise<void> {
    const lines: string[] = []
    for (const p of StudyStore.plans) {
      lines.push(StudyStore.serializePlan(p))
    }
    await StudyStore.putString(KEY_PLANS, lines.join('\n'))
  }

  private static async persistCheckins(): Promise<void> {
    const lines: string[] = []
    for (const c of StudyStore.checkins) {
      lines.push(StudyStore.serializeCheckin(c))
    }
    await StudyStore.putString(KEY_CHECKINS, lines.join('\n'))
  }

  private static async persistTopics(): Promise<void> {
    const lines: string[] = []
    for (const t of StudyStore.topics) {
      lines.push(StudyStore.serializeTopic(t))
    }
    await StudyStore.putString(KEY_TOPICS, lines.join('\n'))
  }

  private static async persistAchievements(): Promise<void> {
    const lines: string[] = []
    for (const a of StudyStore.achievements) {
      lines.push(`${a.id}\t${a.unlockedAt}`)
    }
    await StudyStore.putString(KEY_ACHIEVEMENTS, lines.join('\n'))
  }

  private static async persistBooks(): Promise<void> {
    const lines: string[] = []
    for (const b of StudyStore.books) {
      lines.push(StudyStore.serializeBook(b))
    }
    await StudyStore.putString(KEY_BOOKS, lines.join('\n'))
  }

  private static async persistSessions(): Promise<void> {
    const lines: string[] = []
    for (const s of StudyStore.sessions) {
      lines.push(StudyStore.serializeSession(s))
    }
    await StudyStore.putString(KEY_SESSIONS, lines.join('\n'))
  }

  private static serializeBook(b: BookLibraryItem): string {
    const title = b.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const author = b.author.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const memo = b.memo.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const cover = b.coverImage.replace(/\t/g, ' ')
    return [b.id, title, author, b.status, cover, `${b.totalPages}`, `${b.currentPage}`, memo,
      `${b.createdAt}`, `${b.updatedAt}`].join('\t')
  }

  private static parseBooks(raw: string): BookLibraryItem[] {
    const out: BookLibraryItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 8) {
        continue
      }
      const b = new BookLibraryItem()
      b.id = parts[0]
      b.title = parts[1]
      b.author = parts[2]
      b.status = parts[3]
      b.coverImage = parts[4]
      b.totalPages = StudyStore.num(parts[5])
      b.currentPage = StudyStore.num(parts[6])
      b.memo = parts[7]
      if (parts.length >= 10) {
        b.createdAt = StudyStore.num(parts[8])
        b.updatedAt = StudyStore.num(parts[9])
      }
      out.push(b)
    }
    return out
  }

  private static serializeSession(s: ReadingSession): string {
    const title = s.bookTitle.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const note = s.moodNote.replace(/\t/g, ' ').replace(/\n/g, ' ')
    return [s.id, s.bookId, title, `${s.durationMinutes}`, `${s.pagesRead}`, note,
      `${s.createdAt}`].join('\t')
  }

  private static parseSessions(raw: string): ReadingSession[] {
    const out: ReadingSession[] = []
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
      const s = new ReadingSession()
      s.id = parts[0]
      s.bookId = parts[1]
      s.bookTitle = parts[2]
      s.durationMinutes = StudyStore.num(parts[3])
      s.pagesRead = StudyStore.num(parts[4])
      s.moodNote = parts[5]
      s.createdAt = StudyStore.num(parts[6])
      out.push(s)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (StudyStore.pref === null) {
      return fallback
    }
    try {
      const v = await StudyStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (StudyStore.pref === null && StudyStore.ctx !== null) {
      try {
        StudyStore.pref = await preferences.getPreferences(StudyStore.ctx, STORE)
      } catch {
        StudyStore.pref = null
      }
    }
    if (StudyStore.pref === null) {
      return
    }
    try {
      await StudyStore.pref.put(key, value)
      await StudyStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
