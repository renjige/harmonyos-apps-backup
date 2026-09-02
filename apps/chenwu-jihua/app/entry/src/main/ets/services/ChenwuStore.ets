import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  CwAchievementDef, CwDateUtil, CwGoal, CwGoalCategory, CwHabit, CwHabitEntry,
  CwJournalEntry, CwLookbackItem, CwOrganizeHint, CwPhase, CwPhaseReview,
  CwPlan, CwPlanTask, CwPlanTemplate, CwProfile, CwStats, CwTaskCountPair, CwTimelineRow, CwYearArchive
} from '../models/ChenwuModels'
import { AppContextService } from './AppContextService'

const STORE = 'chenwu_jihua_v1'
const KEY_GOALS = 'goals'
const KEY_PLANS = 'plans'
const KEY_PHASES = 'phases'
const KEY_TASKS = 'tasks'
const KEY_REVIEWS = 'reviews'
const KEY_HABITS = 'habits'
const KEY_HABIT_ENTRIES = 'habit_entries'
const KEY_JOURNALS = 'journals'
const KEY_CATS = 'categories'
const KEY_PROFILE = 'profile'
const KEY_UNLOCKED = 'unlocked'
const KEY_ACTIVITY = 'activity'

export class ChenwuStore {
  private static pref: preferences.Preferences | null = null
  private static mem: Map<string, string> = new Map()

  static bump(): void {
    const rev = (AppStorage.get<number>('cwDataRev') ?? 0) + 1
    if (!AppStorage.set('cwDataRev', rev)) {
      AppStorage.setOrCreate('cwDataRev', rev)
    }
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    AppContextService.setContext(context)
    try {
      ChenwuStore.pref = await preferences.getPreferences(context, STORE)
      await ChenwuStore.hydrateMemFromPref()
    } catch {
      ChenwuStore.pref = null
    }
    const cats = await ChenwuStore.loadCategories()
    if (cats.length === 0) {
      await ChenwuStore.persistCategories(CwGoalCategory.defaults())
    }
  }

  private static async hydrateMemFromPref(): Promise<void> {
    if (ChenwuStore.pref === null) {
      return
    }
    const keys: string[] = [
      KEY_GOALS, KEY_PLANS, KEY_PHASES, KEY_TASKS, KEY_REVIEWS,
      KEY_HABITS, KEY_HABIT_ENTRIES, KEY_JOURNALS, KEY_CATS,
      KEY_PROFILE, KEY_UNLOCKED, KEY_ACTIVITY
    ]
    for (const key of keys) {
      try {
        const v = await ChenwuStore.pref.get(key, '')
        if (typeof v === 'string') {
          ChenwuStore.mem.set(key, v)
        }
      } catch {
        // ignore single-key hydrate failure
      }
    }
  }

  private static async ensurePref(): Promise<boolean> {
    if (ChenwuStore.pref !== null) {
      return true
    }
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      return false
    }
    try {
      ChenwuStore.pref = await preferences.getPreferences(ctx, STORE)
      await ChenwuStore.hydrateMemFromPref()
      return true
    } catch {
      ChenwuStore.pref = null
      return false
    }
  }

  // ── Goals ──

  static async loadGoals(): Promise<CwGoal[]> {
    return ChenwuStore.parseGoals(await ChenwuStore.getString(KEY_GOALS, ''))
  }

  static async findGoal(id: string): Promise<CwGoal | undefined> {
    const list = await ChenwuStore.loadGoals()
    for (const g of list) {
      if (g.id === id) {
        return g
      }
    }
    return undefined
  }

  static async saveGoal(goal: CwGoal): Promise<void> {
    goal.updatedAt = Date.now()
    const list = await ChenwuStore.loadGoals()
    let found = false
    const next: CwGoal[] = []
    for (const g of list) {
      if (g.id === goal.id) {
        next.push(goal)
        found = true
      } else {
        next.push(g)
      }
    }
    if (!found) {
      next.push(goal)
    }
    await ChenwuStore.persistGoals(next)
    await ChenwuStore.recordActivity(CwDateUtil.todayKey())
    await ChenwuStore.checkAchievements()
    ChenwuStore.bump()
  }

  static async deleteGoal(id: string): Promise<void> {
    const list = await ChenwuStore.loadGoals()
    const next: CwGoal[] = []
    for (const g of list) {
      if (g.id !== id) {
        next.push(g)
      }
    }
    await ChenwuStore.persistGoals(next)
    ChenwuStore.bump()
  }

  // ── Plans ──

  static async loadPlans(): Promise<CwPlan[]> {
    return ChenwuStore.parsePlans(await ChenwuStore.getString(KEY_PLANS, ''))
  }

  static async findPlan(id: string): Promise<CwPlan | undefined> {
    const list = await ChenwuStore.loadPlans()
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static async plansForGoal(goalId: string): Promise<CwPlan[]> {
    const list = await ChenwuStore.loadPlans()
    const out: CwPlan[] = []
    for (const p of list) {
      if (p.goalId === goalId) {
        out.push(p)
      }
    }
    return out
  }

  static async savePlan(plan: CwPlan): Promise<void> {
    const list = await ChenwuStore.loadPlans()
    let found = false
    const next: CwPlan[] = []
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
    await ChenwuStore.persistPlans(next)
    if (plan.status === 'active') {
      await ChenwuStore.ensureFirstPhaseActive(plan.id)
    }
    await ChenwuStore.recordActivity(CwDateUtil.todayKey())
    await ChenwuStore.checkAchievements()
    ChenwuStore.bump()
  }

  /** 计划是否在指定日期处于可执行区间（仅 active） */
  static planActiveOnDate(plan: CwPlan, dateKey: string): boolean {
    if (plan.status !== 'active') {
      return false
    }
    return ChenwuStore.planDateInRange(plan, dateKey)
  }

  /** 今日完成度统计范围：进行中/已完成、未暂停、日期有效 */
  static planInTodayScope(plan: CwPlan, dateKey: string): boolean {
    if (plan.status === 'paused') {
      return false
    }
    if (plan.status !== 'active' && plan.status !== 'done') {
      return false
    }
    return ChenwuStore.planDateInRange(plan, dateKey)
  }

  private static planDateInRange(plan: CwPlan, dateKey: string): boolean {
    if (plan.startDate.length > 0 && plan.startDate > dateKey) {
      return false
    }
    if (plan.endDate.length > 0 && plan.endDate < dateKey) {
      return false
    }
    return true
  }

  /** 无阶段/任务的手动计划补默认工作项，否则今日完成度无法计算 */
  static async ensureDefaultPhaseAndTask(planId: string, planTitle: string): Promise<void> {
    const phases = await ChenwuStore.phasesForPlan(planId)
    if (phases.length > 0) {
      return
    }
    const ph = CwPhase.createNew(planId, '第一阶段', 0)
    ph.status = 'active'
    await ChenwuStore.persistPhases(await ChenwuStore.mergePhase(ph))
    const task = CwPlanTask.createNew(ph.id, planTitle.length > 0 ? `推进：${planTitle}` : '完成第一步')
    await ChenwuStore.persistTasks(await ChenwuStore.mergeTask(task))
    await ChenwuStore.reconcilePlanProgress(planId)
  }

  /** 启动时修复历史空计划（仅补一次数据） */
  static async migrateEmptyPlans(): Promise<void> {
    const plans = await ChenwuStore.loadPlans()
    let changed = false
    for (const p of plans) {
      if (p.status === 'paused') {
        continue
      }
      const phases = await ChenwuStore.phasesForPlan(p.id)
      if (phases.length === 0) {
        await ChenwuStore.ensureDefaultPhaseAndTask(p.id, p.title)
        changed = true
      }
    }
    if (changed) {
      ChenwuStore.bump()
    }
  }

  private static async mergeTask(task: CwPlanTask): Promise<CwPlanTask[]> {
    const list = await ChenwuStore.loadTasks()
    const next: CwPlanTask[] = []
    let found = false
    for (const t of list) {
      if (t.id === task.id) {
        next.push(task)
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(task)
    }
    return next
  }

  /** 保存计划后自动激活首个待开始阶段，便于计入今日完成度 */
  static async ensureFirstPhaseActive(planId: string): Promise<void> {
    const phases = await ChenwuStore.phasesForPlan(planId)
    if (phases.length === 0) {
      return
    }
    for (const ph of phases) {
      if (ph.status === 'active') {
        return
      }
    }
    for (const ph of phases) {
      if (ph.status === 'pending') {
        ph.status = 'active'
        await ChenwuStore.savePhase(ph)
        return
      }
    }
  }

  static async deletePlan(id: string): Promise<void> {
    const list = await ChenwuStore.loadPlans()
    const next: CwPlan[] = []
    for (const p of list) {
      if (p.id !== id) {
        next.push(p)
      }
    }
    await ChenwuStore.persistPlans(next)
    ChenwuStore.bump()
  }

  // ── Phases ──

  static async loadPhases(): Promise<CwPhase[]> {
    return ChenwuStore.parsePhases(await ChenwuStore.getString(KEY_PHASES, ''))
  }

  static async findPhase(id: string): Promise<CwPhase | undefined> {
    const list = await ChenwuStore.loadPhases()
    for (const ph of list) {
      if (ph.id === id) {
        return ph
      }
    }
    return undefined
  }

  static async phasesForPlan(planId: string): Promise<CwPhase[]> {
    const list = await ChenwuStore.loadPhases()
    const out: CwPhase[] = []
    for (const ph of list) {
      if (ph.planId === planId) {
        out.push(ph)
      }
    }
    out.sort((a: CwPhase, b: CwPhase) => a.orderIndex - b.orderIndex)
    return out
  }

  static async savePhase(phase: CwPhase): Promise<void> {
    const list = await ChenwuStore.loadPhases()
    let found = false
    const next: CwPhase[] = []
    for (const ph of list) {
      if (ph.id === phase.id) {
        next.push(phase)
        found = true
      } else {
        next.push(ph)
      }
    }
    if (!found) {
      next.push(phase)
    }
    await ChenwuStore.persistPhases(next)
    ChenwuStore.bump()
  }

  static async deletePhase(id: string): Promise<void> {
    const list = await ChenwuStore.loadPhases()
    const next: CwPhase[] = []
    for (const ph of list) {
      if (ph.id !== id) {
        next.push(ph)
      }
    }
    await ChenwuStore.persistPhases(next)
    ChenwuStore.bump()
  }

  // ── Tasks ──

  static async loadTasks(): Promise<CwPlanTask[]> {
    return ChenwuStore.parseTasks(await ChenwuStore.getString(KEY_TASKS, ''))
  }

  static async findTask(id: string): Promise<CwPlanTask | undefined> {
    const list = await ChenwuStore.loadTasks()
    for (const t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async tasksForPhase(phaseId: string): Promise<CwPlanTask[]> {
    const list = await ChenwuStore.loadTasks()
    const out: CwPlanTask[] = []
    for (const t of list) {
      if (t.phaseId === phaseId) {
        out.push(t)
      }
    }
    return out
  }

  static async saveTask(task: CwPlanTask): Promise<void> {
    const list = await ChenwuStore.loadTasks()
    let found = false
    const next: CwPlanTask[] = []
    for (const t of list) {
      if (t.id === task.id) {
        next.push(task)
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(task)
    }
    await ChenwuStore.persistTasks(next)
    await ChenwuStore.syncProgressForTask(task)
    await ChenwuStore.recordActivity(CwDateUtil.todayKey())
    await ChenwuStore.checkAchievements()
    ChenwuStore.bump()
  }

  static async deleteTask(id: string): Promise<void> {
    const list = await ChenwuStore.loadTasks()
    let phaseId = ''
    let planId = ''
    const next: CwPlanTask[] = []
    for (const t of list) {
      if (t.id === id) {
        phaseId = t.phaseId
      } else {
        next.push(t)
      }
    }
    if (phaseId.length > 0) {
      const ph = await ChenwuStore.findPhase(phaseId)
      if (ph !== undefined) {
        planId = ph.planId
      }
    }
    await ChenwuStore.persistTasks(next)
    if (phaseId.length > 0) {
      const stub = new CwPlanTask()
      stub.phaseId = phaseId
      await ChenwuStore.syncProgressForTask(stub)
    }
    ChenwuStore.bump()
  }

  /** 根据任务完成情况同步阶段 / 计划 / 目标进度 */
  static async syncProgressForTask(task: CwPlanTask): Promise<void> {
    const phase = await ChenwuStore.findPhase(task.phaseId)
    if (phase === undefined) {
      return
    }
    const phaseTasks = await ChenwuStore.tasksForPhase(phase.id)
    let doneCount = 0
    for (const t of phaseTasks) {
      if (t.done) {
        doneCount++
      }
    }
    if (phaseTasks.length > 0 && doneCount === phaseTasks.length) {
      phase.status = 'done'
    } else if (doneCount > 0) {
      phase.status = 'active'
    } else {
      phase.status = 'pending'
    }
    await ChenwuStore.persistPhases(await ChenwuStore.mergePhase(phase))

    const plan = await ChenwuStore.findPlan(phase.planId)
    if (plan === undefined) {
      return
    }
    const planPhases = await ChenwuStore.phasesForPlan(plan.id)
    let allPhasesDone = planPhases.length > 0
    for (const ph of planPhases) {
      if (ph.status !== 'done') {
        allPhasesDone = false
      }
    }
    if (allPhasesDone && planPhases.length > 0) {
      plan.status = 'done'
    } else if (plan.status === 'done') {
      plan.status = 'active'
    }
    await ChenwuStore.persistPlans(await ChenwuStore.mergePlan(plan))

    if (plan.goalId.length > 0) {
      await ChenwuStore.syncGoalProgress(plan.goalId)
    }
  }

  /** 按任务实际完成情况校准阶段 / 计划 / 目标状态（修复历史脏数据） */
  static async reconcilePlanProgress(planId: string): Promise<void> {
    const phases = await ChenwuStore.phasesForPlan(planId)
    if (phases.length === 0) {
      const plan = await ChenwuStore.findPlan(planId)
      if (plan !== undefined && plan.status === 'done') {
        plan.status = 'active'
        await ChenwuStore.persistPlans(await ChenwuStore.mergePlan(plan))
      }
      return
    }
    for (const ph of phases) {
      const stub = new CwPlanTask()
      stub.phaseId = ph.id
      await ChenwuStore.syncProgressForTask(stub)
    }
  }

  static async syncGoalProgress(goalId: string): Promise<void> {
    const goal = await ChenwuStore.findGoal(goalId)
    if (goal === undefined) {
      return
    }
    const plans = await ChenwuStore.plansForGoal(goalId)
    const phases = await ChenwuStore.loadPhases()
    const tasks = await ChenwuStore.loadTasks()
    let total = 0
    let done = 0
    for (const plan of plans) {
      for (const ph of phases) {
        if (ph.planId !== plan.id) {
          continue
        }
        for (const t of tasks) {
          if (t.phaseId === ph.id) {
            total++
            if (t.done) {
              done++
            }
          }
        }
      }
    }
    if (total > 0) {
      goal.progress = Math.round(done * 100 / total)
    }
    goal.updatedAt = Date.now()
    await ChenwuStore.persistGoals(await ChenwuStore.mergeGoal(goal))
  }

  static async planCompletionPct(planId: string): Promise<number> {
    const phases = await ChenwuStore.phasesForPlan(planId)
    const tasks = await ChenwuStore.loadTasks()
    let total = 0
    let done = 0
    for (const ph of phases) {
      for (const t of tasks) {
        if (t.phaseId === ph.id) {
          total++
          if (t.done) {
            done++
          }
        }
      }
    }
    if (total === 0) {
      return 0
    }
    return Math.round(done * 100 / total)
  }

  private static async mergePhase(phase: CwPhase): Promise<CwPhase[]> {
    const list = await ChenwuStore.loadPhases()
    const next: CwPhase[] = []
    let found = false
    for (const ph of list) {
      if (ph.id === phase.id) {
        next.push(phase)
        found = true
      } else {
        next.push(ph)
      }
    }
    if (!found) {
      next.push(phase)
    }
    return next
  }

  private static async mergePlan(plan: CwPlan): Promise<CwPlan[]> {
    const list = await ChenwuStore.loadPlans()
    const next: CwPlan[] = []
    let found = false
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
    return next
  }

  private static async mergeGoal(goal: CwGoal): Promise<CwGoal[]> {
    const list = await ChenwuStore.loadGoals()
    const next: CwGoal[] = []
    let found = false
    for (const g of list) {
      if (g.id === goal.id) {
        next.push(goal)
        found = true
      } else {
        next.push(g)
      }
    }
    if (!found) {
      next.push(goal)
    }
    return next
  }

  // ── Reviews ──

  static async loadReviews(): Promise<CwPhaseReview[]> {
    return ChenwuStore.parseReviews(await ChenwuStore.getString(KEY_REVIEWS, ''))
  }

  static async findReview(id: string): Promise<CwPhaseReview | undefined> {
    const list = await ChenwuStore.loadReviews()
    for (const r of list) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async reviewForPhase(phaseId: string): Promise<CwPhaseReview | undefined> {
    const list = await ChenwuStore.loadReviews()
    for (const r of list) {
      if (r.phaseId === phaseId) {
        return r
      }
    }
    return undefined
  }

  static async saveReview(review: CwPhaseReview): Promise<void> {
    const list = await ChenwuStore.loadReviews()
    let found = false
    const next: CwPhaseReview[] = []
    for (const r of list) {
      if (r.id === review.id) {
        next.push(review)
        found = true
      } else {
        next.push(r)
      }
    }
    if (!found) {
      next.push(review)
    }
    await ChenwuStore.persistReviews(next)
    await ChenwuStore.checkAchievements()
    ChenwuStore.bump()
  }

  static async deleteReview(id: string): Promise<void> {
    const list = await ChenwuStore.loadReviews()
    const next: CwPhaseReview[] = []
    for (const r of list) {
      if (r.id !== id) {
        next.push(r)
      }
    }
    await ChenwuStore.persistReviews(next)
    ChenwuStore.bump()
  }

  // ── Habits ──

  static async loadHabits(): Promise<CwHabit[]> {
    return ChenwuStore.parseHabits(await ChenwuStore.getString(KEY_HABITS, ''))
  }

  static async findHabit(id: string): Promise<CwHabit | undefined> {
    const list = await ChenwuStore.loadHabits()
    for (const h of list) {
      if (h.id === id) {
        return h
      }
    }
    return undefined
  }

  static async saveHabit(habit: CwHabit): Promise<void> {
    const list = await ChenwuStore.loadHabits()
    let found = false
    const next: CwHabit[] = []
    for (const h of list) {
      if (h.id === habit.id) {
        next.push(habit)
        found = true
      } else {
        next.push(h)
      }
    }
    if (!found) {
      next.push(habit)
    }
    await ChenwuStore.persistHabits(next)
    await ChenwuStore.checkAchievements()
    ChenwuStore.bump()
  }

  static async deleteHabit(id: string): Promise<void> {
    const list = await ChenwuStore.loadHabits()
    const next: CwHabit[] = []
    for (const h of list) {
      if (h.id !== id) {
        next.push(h)
      }
    }
    await ChenwuStore.persistHabits(next)
    ChenwuStore.bump()
  }

  // ── Habit Entries ──

  static async loadHabitEntries(): Promise<CwHabitEntry[]> {
    return ChenwuStore.parseHabitEntries(await ChenwuStore.getString(KEY_HABIT_ENTRIES, ''))
  }

  static async findHabitEntry(id: string): Promise<CwHabitEntry | undefined> {
    const list = await ChenwuStore.loadHabitEntries()
    for (const e of list) {
      if (e.id === id) {
        return e
      }
    }
    return undefined
  }

  static async entriesForHabit(habitId: string): Promise<CwHabitEntry[]> {
    const list = await ChenwuStore.loadHabitEntries()
    const out: CwHabitEntry[] = []
    for (const e of list) {
      if (e.habitId === habitId) {
        out.push(e)
      }
    }
    out.sort((a: CwHabitEntry, b: CwHabitEntry) => b.dateKey.localeCompare(a.dateKey))
    return out
  }

  static async saveHabitEntry(entry: CwHabitEntry): Promise<void> {
    const list = await ChenwuStore.loadHabitEntries()
    let found = false
    const next: CwHabitEntry[] = []
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
    await ChenwuStore.persistHabitEntries(next)
    if (entry.done) {
      await ChenwuStore.recordActivity(entry.dateKey)
      const habit = await ChenwuStore.findHabit(entry.habitId)
      if (habit !== undefined) {
        ChenwuStore.refreshHabitStreak(habit)
        await ChenwuStore.saveHabit(habit)
      }
    }
    await ChenwuStore.checkAchievements()
    ChenwuStore.bump()
  }

  static async deleteHabitEntry(id: string): Promise<void> {
    const list = await ChenwuStore.loadHabitEntries()
    const next: CwHabitEntry[] = []
    for (const e of list) {
      if (e.id !== id) {
        next.push(e)
      }
    }
    await ChenwuStore.persistHabitEntries(next)
    ChenwuStore.bump()
  }

  // ── Journals ──

  static async loadJournals(): Promise<CwJournalEntry[]> {
    return ChenwuStore.parseJournals(await ChenwuStore.getString(KEY_JOURNALS, ''))
  }

  static async findJournal(id: string): Promise<CwJournalEntry | undefined> {
    const list = await ChenwuStore.loadJournals()
    for (const j of list) {
      if (j.id === id) {
        return j
      }
    }
    return undefined
  }

  static async journalForDate(dateKey: string): Promise<CwJournalEntry | undefined> {
    const list = await ChenwuStore.loadJournals()
    for (const j of list) {
      if (j.dateKey === dateKey) {
        return j
      }
    }
    return undefined
  }

  static async saveJournal(journal: CwJournalEntry): Promise<void> {
    const list = await ChenwuStore.loadJournals()
    let found = false
    const next: CwJournalEntry[] = []
    for (const j of list) {
      if (j.id === journal.id) {
        next.push(journal)
        found = true
      } else {
        next.push(j)
      }
    }
    if (!found) {
      next.push(journal)
    }
    await ChenwuStore.persistJournals(next)
    await ChenwuStore.recordActivity(journal.dateKey)
    await ChenwuStore.checkAchievements()
    ChenwuStore.bump()
  }

  static async deleteJournal(id: string): Promise<void> {
    const list = await ChenwuStore.loadJournals()
    const next: CwJournalEntry[] = []
    for (const j of list) {
      if (j.id !== id) {
        next.push(j)
      }
    }
    await ChenwuStore.persistJournals(next)
    ChenwuStore.bump()
  }

  // ── Categories ──

  static async loadCategories(): Promise<CwGoalCategory[]> {
    return ChenwuStore.parseCategories(await ChenwuStore.getString(KEY_CATS, ''))
  }

  static categoryLabel(key: string, cats: CwGoalCategory[]): string {
    for (const c of cats) {
      if (c.key === key) {
        return c.label
      }
    }
    return '成长'
  }

  // ── Profile ──

  static async loadProfile(): Promise<CwProfile> {
    const raw = await ChenwuStore.getString(KEY_PROFILE, '')
    const p = new CwProfile()
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

  static async saveProfile(p: CwProfile): Promise<void> {
    await ChenwuStore.putString(KEY_PROFILE, `${p.nickname}\t${p.themeMode}`)
    ChenwuStore.bump()
  }

  // ── Aggregates ──

  static async computeStats(): Promise<CwStats> {
    await ChenwuStore.migrateEmptyPlans()
    const s = new CwStats()
    const goals = await ChenwuStore.loadGoals()
    const plans = await ChenwuStore.loadPlans()
    const tasks = await ChenwuStore.loadTasks()
    const habits = await ChenwuStore.loadHabits()
    s.goalCount = goals.length
    s.planCount = plans.length
    s.habitCount = habits.length
    for (const t of tasks) {
      if (t.done) {
        s.taskDoneCount++
      }
    }
    for (const h of habits) {
      if (h.streakDays > s.streakMax) {
        s.streakMax = h.streakDays
      }
    }
    const todayTasks = await ChenwuStore.countTodayPlanTasks()
    s.todayTaskDone = todayTasks.done
    s.todayTaskTotal = todayTasks.total
    s.todayPlanPct = await ChenwuStore.resolveTodayPlanPct(todayTasks)
    return s
  }

  /** 有任务按任务比例；无任务则取今日范围内计划完成率均值 */
  static async resolveTodayPlanPct(counts: CwTaskCountPair): Promise<number> {
    if (counts.total > 0) {
      return Math.round(counts.done * 100 / counts.total)
    }
    const today = CwDateUtil.todayKey()
    const plans = await ChenwuStore.loadPlans()
    let sum = 0
    let n = 0
    for (const p of plans) {
      if (!ChenwuStore.planInTodayScope(p, today)) {
        continue
      }
      sum += await ChenwuStore.planCompletionPct(p.id)
      n++
    }
    if (n === 0) {
      return 0
    }
    return Math.round(sum / n)
  }

  /** 统计今日范围内计划下全部阶段任务 */
  static async countTodayPlanTasks(): Promise<CwTaskCountPair> {
    const pair = new CwTaskCountPair()
    const today = CwDateUtil.todayKey()
    const plans = await ChenwuStore.loadPlans()
    const phases = await ChenwuStore.loadPhases()
    const tasks = await ChenwuStore.loadTasks()
    const scopedPlanIds: string[] = []
    for (const p of plans) {
      if (ChenwuStore.planInTodayScope(p, today)) {
        scopedPlanIds.push(p.id)
      }
    }
    for (const ph of phases) {
      let inScope = false
      for (const pid of scopedPlanIds) {
        if (ph.planId === pid) {
          inScope = true
        }
      }
      if (!inScope) {
        continue
      }
      for (const t of tasks) {
        if (t.phaseId === ph.id) {
          pair.total++
          if (t.done) {
            pair.done++
          }
        }
      }
    }
    return pair
  }

  static async todayPlanCompletionPct(): Promise<number> {
    const c = await ChenwuStore.countTodayPlanTasks()
    return ChenwuStore.resolveTodayPlanPct(c)
  }

  static async recentPlans(limit: number): Promise<CwPlan[]> {
    const list = await ChenwuStore.loadPlans()
    list.sort((a: CwPlan, b: CwPlan) => b.createdAt - a.createdAt)
    const out: CwPlan[] = []
    for (const p of list) {
      if (out.length >= limit) {
        break
      }
      out.push(p)
    }
    return out
  }

  static async activePhasesForToday(): Promise<CwPhase[]> {
    const today = CwDateUtil.todayKey()
    const plans = await ChenwuStore.loadPlans()
    const out: CwPhase[] = []
    for (const p of plans) {
      if (!ChenwuStore.planActiveOnDate(p, today)) {
        continue
      }
      const planPhases = await ChenwuStore.phasesForPlan(p.id)
      let added = false
      for (const ph of planPhases) {
        if (ph.status === 'active') {
          out.push(ph)
          added = true
        }
      }
      if (!added) {
        for (const ph of planPhases) {
          if (ph.status === 'pending') {
            out.push(ph)
            break
          }
        }
      }
    }
    out.sort((a: CwPhase, b: CwPhase) => a.orderIndex - b.orderIndex)
    return out
  }

  static async buildLookback(): Promise<CwLookbackItem> {
    const item = new CwLookbackItem()
    const yearKey = CwDateUtil.yearsAgoKey(1)
    const threeKey = CwDateUtil.daysAgoKey(90)
    const journals = await ChenwuStore.loadJournals()
    for (const j of journals) {
      if (j.dateKey === yearKey) {
        item.title = '一年前今天'
        item.body = j.discovery.length > 0 ? j.discovery : j.doneToday
        item.dateKey = j.dateKey
        item.sourceKind = 'journal'
        item.sourceId = j.id
        return item
      }
    }
    for (const j of journals) {
      if (j.dateKey === threeKey) {
        item.title = '三个月前'
        item.body = j.discovery.length > 0 ? j.discovery : '你写过晨间札记。'
        item.dateKey = j.dateKey
        item.sourceKind = 'journal'
        item.sourceId = j.id
        return item
      }
    }
    const goals = await ChenwuStore.loadGoals()
    for (const g of goals) {
      if (g.progress >= 80) {
        item.title = '接近完成的目标'
        item.body = `「${g.title}」进度 ${g.progress}%`
        item.dateKey = g.startDate
        item.sourceKind = 'goal'
        item.sourceId = g.id
        return item
      }
    }
    const habits = await ChenwuStore.loadHabits()
    for (const h of habits) {
      if (h.streakDays >= 7) {
        item.title = '坚持中的习惯'
        item.body = `「${h.title}」已连续 ${h.streakDays} 天`
        item.dateKey = h.lastDateKey
        item.sourceKind = 'habit'
        item.sourceId = h.id
        return item
      }
    }
    item.title = '晨雾回望'
    item.body = '立下第一个目标或写下晨记后，这里会按本机日期回看成长轨迹。'
    return item
  }

  static async buildTimeline(): Promise<CwTimelineRow[]> {
    const rows: CwTimelineRow[] = []
    const goals = await ChenwuStore.loadGoals()
    for (const g of goals) {
      const r = new CwTimelineRow()
      r.id = g.id
      r.kind = 'goal'
      r.dateKey = g.startDate.length > 0 ? g.startDate : CwDateUtil.todayKey()
      r.title = g.title
      r.subtitle = `目标 · ${g.progress}%`
      r.sourceId = g.id
      rows.push(r)
    }
    const plans = await ChenwuStore.loadPlans()
    for (const p of plans) {
      const r = new CwTimelineRow()
      r.id = p.id
      r.kind = 'plan'
      r.dateKey = p.startDate
      r.title = p.title
      r.subtitle = p.horizonType === 'long' ? '长期规划' : '阶段计划'
      r.sourceId = p.id
      rows.push(r)
    }
    const journals = await ChenwuStore.loadJournals()
    for (const j of journals) {
      const r = new CwTimelineRow()
      r.id = j.id
      r.kind = 'journal'
      r.dateKey = j.dateKey
      r.title = '晨间札记'
      r.subtitle = j.discovery.length > 0 ? j.discovery : j.doneToday
      r.sourceId = j.id
      rows.push(r)
    }
    const entries = await ChenwuStore.loadHabitEntries()
    for (const e of entries) {
      if (!e.done) {
        continue
      }
      const habit = await ChenwuStore.findHabit(e.habitId)
      const r = new CwTimelineRow()
      r.id = e.id
      r.kind = 'habit'
      r.dateKey = e.dateKey
      r.title = habit !== undefined ? habit.title : '习惯打卡'
      r.subtitle = e.note.length > 0 ? e.note : '已完成'
      r.sourceId = e.habitId
      rows.push(r)
    }
    rows.sort((a: CwTimelineRow, b: CwTimelineRow) => b.dateKey.localeCompare(a.dateKey))
    return rows
  }

  static async buildOrganizeHints(): Promise<CwOrganizeHint[]> {
    const out: CwOrganizeHint[] = []
    const today = CwDateUtil.todayKey()
    const goals = await ChenwuStore.loadGoals()
    const plans = await ChenwuStore.loadPlans()
    for (const g of goals) {
      let hasPlan = false
      for (const p of plans) {
        if (p.goalId === g.id) {
          hasPlan = true
        }
      }
      if (!hasPlan) {
        const h = new CwOrganizeHint()
        h.title = g.title
        h.body = '目标尚未关联计划，建议添加阶段规划'
        h.actionKind = 'add_plan'
        h.targetId = g.id
        out.push(h)
      }
    }
    const phases = await ChenwuStore.loadPhases()
    const tasks = await ChenwuStore.loadTasks()
    for (const ph of phases) {
      if (ph.status !== 'active') {
        continue
      }
      let taskCount = 0
      for (const t of tasks) {
        if (t.phaseId === ph.id) {
          taskCount++
        }
      }
      if (taskCount === 0) {
        const h = new CwOrganizeHint()
        h.title = ph.title
        h.body = '进行中的阶段还没有任务，拆解后可追踪进度'
        h.actionKind = 'add_task'
        h.targetId = ph.id
        out.push(h)
      }
    }
    const habits = await ChenwuStore.loadHabits()
    for (const hb of habits) {
      if (hb.lastDateKey !== today) {
        const h = new CwOrganizeHint()
        h.title = hb.title
        h.body = '今日尚未打卡，保持连续记录'
        h.actionKind = 'habit_checkin'
        h.targetId = hb.id
        out.push(h)
      }
    }
    const reviews = await ChenwuStore.loadReviews()
    for (const ph of phases) {
      if (ph.status !== 'done') {
        continue
      }
      let hasReview = false
      for (const rv of reviews) {
        if (rv.phaseId === ph.id) {
          hasReview = true
        }
      }
      if (!hasReview) {
        const h = new CwOrganizeHint()
        h.title = ph.title
        h.body = '阶段已完成但尚未复盘，写下收获与下一步'
        h.actionKind = 'phase_review'
        h.targetId = ph.id
        out.push(h)
      }
    }
    const journalToday = await ChenwuStore.journalForDate(today)
    if (journalToday === undefined) {
      const h = new CwOrganizeHint()
      h.title = '晨间札记'
      h.body = '今天还没有写下今日完成与发现'
      h.actionKind = 'journal_write'
      h.targetId = today
      out.push(h)
    }
    return out
  }

  static async buildYearArchive(year: string): Promise<CwYearArchive> {
    const y = new CwYearArchive()
    y.year = year
    const goals = await ChenwuStore.loadGoals()
    const plans = await ChenwuStore.loadPlans()
    const entries = await ChenwuStore.loadHabitEntries()
    const journals = await ChenwuStore.loadJournals()
    const catHits: string[] = []
    for (const g of goals) {
      if (CwDateUtil.yearFromKey(g.startDate) === year) {
        y.goalCount++
        catHits.push(g.categoryKey)
        if (y.highlightTitle.length === 0) {
          y.highlightTitle = g.title
        }
      }
    }
    for (const p of plans) {
      if (CwDateUtil.yearFromKey(p.startDate) === year) {
        y.planCount++
        if (y.highlightTitle.length === 0) {
          y.highlightTitle = p.title
        }
      }
    }
    for (const e of entries) {
      if (e.done && CwDateUtil.yearFromKey(e.dateKey) === year) {
        y.habitDays++
      }
    }
    for (const j of journals) {
      if (CwDateUtil.yearFromKey(j.dateKey) === year && y.highlightTitle.length === 0) {
        y.highlightTitle = j.discovery.length > 0 ? j.discovery : '晨间札记'
      }
    }
    y.topCategory = ChenwuStore.mostFrequent(catHits)
    if (y.highlightTitle.length === 0) {
      y.highlightTitle = '本年度尚未留下记录'
    }
    return y
  }

  static async applyTemplate(templateKey: string, goalId: string): Promise<string> {
    const templates = CwPlanTemplate.defaults()
    let tpl: CwPlanTemplate | undefined = undefined
    for (const t of templates) {
      if (t.key === templateKey) {
        tpl = t
      }
    }
    if (tpl === undefined) {
      return ''
    }
    const plan = CwPlan.createNew(tpl.title, goalId, tpl.horizonType)
    plan.summary = tpl.description
    if (tpl.horizonType === 'short') {
      const end = new Date()
      end.setDate(end.getDate() + 30)
      plan.endDate = CwDateUtil.keyFromDate(end)
    } else if (tpl.horizonType === 'phase') {
      const end = new Date()
      end.setDate(end.getDate() + 90)
      plan.endDate = CwDateUtil.keyFromDate(end)
    } else {
      const end = new Date()
      end.setFullYear(end.getFullYear() + 1)
      plan.endDate = CwDateUtil.keyFromDate(end)
    }
    await ChenwuStore.savePlan(plan)
    const phases = await ChenwuStore.loadPhases()
    const newPhases: CwPhase[] = []
    for (let i = 0; i < tpl.phases.length; i++) {
      const ph = CwPhase.createNew(plan.id, tpl.phases[i], i)
      if (i === 0) {
        ph.status = 'active'
      }
      phases.push(ph)
      newPhases.push(ph)
    }
    await ChenwuStore.persistPhases(phases)
    for (const ph of newPhases) {
      const task = CwPlanTask.createNew(ph.id, `推进：${ph.title}`)
      await ChenwuStore.saveTask(task)
    }
    ChenwuStore.bump()
    return plan.id
  }

  static achievementCatalog(): CwAchievementDef[] {
    return CwAchievementDef.catalog()
  }

  static async loadUnlocked(): Promise<string[]> {
    return ChenwuStore.splitCsv(await ChenwuStore.getString(KEY_UNLOCKED, ''))
  }

  static async searchAll(q: string): Promise<CwTimelineRow[]> {
    const needle = q.trim()
    const rows = await ChenwuStore.buildTimeline()
    if (needle.length === 0) {
      return rows
    }
    const out: CwTimelineRow[] = []
    for (const r of rows) {
      if (r.title.indexOf(needle) >= 0 || r.subtitle.indexOf(needle) >= 0 || r.dateKey.indexOf(needle) >= 0) {
        out.push(r)
      }
    }
    const goals = await ChenwuStore.loadGoals()
    for (const g of goals) {
      if (g.description.indexOf(needle) >= 0 && !ChenwuStore.rowHas(out, g.id)) {
        const row = new CwTimelineRow()
        row.id = g.id
        row.kind = 'goal'
        row.dateKey = g.startDate
        row.title = g.title
        row.subtitle = g.description
        row.sourceId = g.id
        out.push(row)
      }
    }
    return out
  }

  static async clearAll(): Promise<void> {
    await ChenwuStore.putString(KEY_GOALS, '')
    await ChenwuStore.putString(KEY_PLANS, '')
    await ChenwuStore.putString(KEY_PHASES, '')
    await ChenwuStore.putString(KEY_TASKS, '')
    await ChenwuStore.putString(KEY_REVIEWS, '')
    await ChenwuStore.putString(KEY_HABITS, '')
    await ChenwuStore.putString(KEY_HABIT_ENTRIES, '')
    await ChenwuStore.putString(KEY_JOURNALS, '')
    await ChenwuStore.putString(KEY_UNLOCKED, '')
    await ChenwuStore.persistCategories(CwGoalCategory.defaults())
    ChenwuStore.bump()
  }

  static async exportJson(): Promise<string> {
    const goals = await ChenwuStore.loadGoals()
    const plans = await ChenwuStore.loadPlans()
    const habits = await ChenwuStore.loadHabits()
    const journals = await ChenwuStore.loadJournals()
    let s = '{"app":"晨雾计划","goals":['
    let first = true
    for (const g of goals) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${g.id}","title":"${ChenwuStore.esc(g.title)}","progress":${g.progress}}`
    }
    s += '],"plans":['
    first = true
    for (const p of plans) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${p.id}","title":"${ChenwuStore.esc(p.title)}","status":"${p.status}"}`
    }
    s += '],"habits":['
    first = true
    for (const h of habits) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${h.id}","title":"${ChenwuStore.esc(h.title)}","streak":${h.streakDays}}`
    }
    s += '],"journals":['
    first = true
    for (const j of journals) {
      if (!first) {
        s += ','
      }
      first = false
      s += `{"id":"${j.id}","date":"${j.dateKey}"}`
    }
    s += ']}'
    return s
  }

  // ── Private helpers ──

  private static refreshHabitStreak(habit: CwHabit): void {
    const today = CwDateUtil.todayKey()
    if (habit.lastDateKey === today) {
      return
    }
    habit.lastDateKey = today
    habit.streakDays = habit.streakDays + 1
  }

  private static async checkAchievements(): Promise<void> {
    const unlocked = await ChenwuStore.loadUnlocked()
    const stats = await ChenwuStore.computeStats()
    const reviews = await ChenwuStore.loadReviews()
    const add: string[] = []
    if (stats.goalCount >= 1) {
      add.push('first_goal')
    }
    if (stats.planCount >= 1) {
      add.push('first_plan')
    }
    if (stats.taskDoneCount >= 10) {
      add.push('tasks_10')
    }
    if (stats.streakMax >= 7) {
      add.push('streak_7')
    }
    if (reviews.length >= 1) {
      add.push('first_review')
    }
    const journalStreak = await ChenwuStore.computeJournalStreak()
    if (journalStreak >= 7) {
      add.push('journal_7')
    }
    const year = `${new Date().getFullYear()}`
    const ya = await ChenwuStore.buildYearArchive(year)
    if (ya.goalCount + ya.planCount + ya.habitDays >= 1) {
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
      await ChenwuStore.putString(KEY_UNLOCKED, unlocked.join(','))
    }
  }

  private static async computeJournalStreak(): Promise<number> {
    const raw = await ChenwuStore.getString(KEY_ACTIVITY, '')
    const days = ChenwuStore.splitLines(raw)
    if (days.length === 0) {
      return 0
    }
    let streak = 0
    const cursor = new Date()
    for (let i = 0; i < 400; i++) {
      const key = CwDateUtil.keyFromDate(cursor)
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
    const raw = await ChenwuStore.getString(KEY_ACTIVITY, '')
    const days = ChenwuStore.splitLines(raw)
    let has = false
    for (const d of days) {
      if (d === dateKey) {
        has = true
      }
    }
    if (!has) {
      days.push(dateKey)
      await ChenwuStore.putString(KEY_ACTIVITY, days.join('\n'))
    }
  }

  private static rowHas(rows: CwTimelineRow[], id: string): boolean {
    for (const r of rows) {
      if (r.id === id) {
        return true
      }
    }
    return false
  }

  private static sanitize(v: string): string {
    return v.replace(/\t/g, ' ').replace(/\n/g, ' ')
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

  private static async persistGoals(list: CwGoal[]): Promise<void> {
    const lines: string[] = []
    for (const g of list) {
      lines.push([
        g.id, ChenwuStore.sanitize(g.title), ChenwuStore.sanitize(g.description),
        g.categoryKey, `${g.progress}`, g.startDate, `${g.createdAt}`, `${g.updatedAt}`
      ].join('\t'))
    }
    await ChenwuStore.putString(KEY_GOALS, lines.join('\n'))
  }

  private static parseGoals(raw: string): CwGoal[] {
    const out: CwGoal[] = []
    for (const line of ChenwuStore.splitLines(raw)) {
      const p = line.split('\t')
      if (p.length < 8) {
        continue
      }
      const g = new CwGoal()
      g.id = p[0]
      g.title = p[1]
      g.description = p[2]
      g.categoryKey = p[3]
      g.progress = parseInt(p[4], 10)
      g.startDate = p[5]
      g.createdAt = parseInt(p[6], 10)
      g.updatedAt = parseInt(p[7], 10)
      out.push(g)
    }
    out.sort((a: CwGoal, b: CwGoal) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async persistPlans(list: CwPlan[]): Promise<void> {
    const lines: string[] = []
    for (const p of list) {
      lines.push([
        p.id, p.goalId, ChenwuStore.sanitize(p.title), p.horizonType,
        p.startDate, p.endDate, ChenwuStore.sanitize(p.summary), p.status, `${p.createdAt}`
      ].join('\t'))
    }
    await ChenwuStore.putString(KEY_PLANS, lines.join('\n'))
  }

  private static parsePlans(raw: string): CwPlan[] {
    const out: CwPlan[] = []
    for (const line of ChenwuStore.splitLines(raw)) {
      const p = line.split('\t')
      if (p.length < 9) {
        continue
      }
      const pl = new CwPlan()
      pl.id = p[0]
      pl.goalId = p[1]
      pl.title = p[2]
      pl.horizonType = p[3]
      pl.startDate = p[4]
      pl.endDate = p[5]
      pl.summary = p[6]
      pl.status = p[7]
      pl.createdAt = parseInt(p[8], 10)
      out.push(pl)
    }
    out.sort((a: CwPlan, b: CwPlan) => b.createdAt - a.createdAt)
    return out
  }

  private static async persistPhases(list: CwPhase[]): Promise<void> {
    const lines: string[] = []
    for (const ph of list) {
      lines.push([
        ph.id, ph.planId, ChenwuStore.sanitize(ph.title), `${ph.orderIndex}`,
        ph.status, ChenwuStore.sanitize(ph.targetNote)
      ].join('\t'))
    }
    await ChenwuStore.putString(KEY_PHASES, lines.join('\n'))
  }

  private static parsePhases(raw: string): CwPhase[] {
    const out: CwPhase[] = []
    for (const line of ChenwuStore.splitLines(raw)) {
      const p = line.split('\t')
      if (p.length < 6) {
        continue
      }
      const ph = new CwPhase()
      ph.id = p[0]
      ph.planId = p[1]
      ph.title = p[2]
      ph.orderIndex = parseInt(p[3], 10)
      ph.status = p[4]
      ph.targetNote = p[5]
      out.push(ph)
    }
    return out
  }

  private static async persistTasks(list: CwPlanTask[]): Promise<void> {
    const lines: string[] = []
    for (const t of list) {
      lines.push([t.id, t.phaseId, ChenwuStore.sanitize(t.title), t.done ? '1' : '0'].join('\t'))
    }
    await ChenwuStore.putString(KEY_TASKS, lines.join('\n'))
  }

  private static parseTasks(raw: string): CwPlanTask[] {
    const out: CwPlanTask[] = []
    for (const line of ChenwuStore.splitLines(raw)) {
      const p = line.split('\t')
      if (p.length < 4) {
        continue
      }
      const t = new CwPlanTask()
      t.id = p[0]
      t.phaseId = p[1]
      t.title = p[2]
      t.done = p[3] === '1'
      out.push(t)
    }
    return out
  }

  private static async persistReviews(list: CwPhaseReview[]): Promise<void> {
    const lines: string[] = []
    for (const r of list) {
      lines.push([
        r.id, r.phaseId, ChenwuStore.sanitize(r.harvest), ChenwuStore.sanitize(r.problems),
        ChenwuStore.sanitize(r.nextSteps), `${r.createdAt}`
      ].join('\t'))
    }
    await ChenwuStore.putString(KEY_REVIEWS, lines.join('\n'))
  }

  private static parseReviews(raw: string): CwPhaseReview[] {
    const out: CwPhaseReview[] = []
    for (const line of ChenwuStore.splitLines(raw)) {
      const p = line.split('\t')
      if (p.length < 6) {
        continue
      }
      const r = new CwPhaseReview()
      r.id = p[0]
      r.phaseId = p[1]
      r.harvest = p[2]
      r.problems = p[3]
      r.nextSteps = p[4]
      r.createdAt = parseInt(p[5], 10)
      out.push(r)
    }
    out.sort((a: CwPhaseReview, b: CwPhaseReview) => b.createdAt - a.createdAt)
    return out
  }

  private static async persistHabits(list: CwHabit[]): Promise<void> {
    const lines: string[] = []
    for (const h of list) {
      lines.push([
        h.id, ChenwuStore.sanitize(h.title), h.categoryKey, `${h.streakDays}`,
        h.lastDateKey, `${h.createdAt}`
      ].join('\t'))
    }
    await ChenwuStore.putString(KEY_HABITS, lines.join('\n'))
  }

  private static parseHabits(raw: string): CwHabit[] {
    const out: CwHabit[] = []
    for (const line of ChenwuStore.splitLines(raw)) {
      const p = line.split('\t')
      if (p.length < 6) {
        continue
      }
      const h = new CwHabit()
      h.id = p[0]
      h.title = p[1]
      h.categoryKey = p[2]
      h.streakDays = parseInt(p[3], 10)
      h.lastDateKey = p[4]
      h.createdAt = parseInt(p[5], 10)
      out.push(h)
    }
    out.sort((a: CwHabit, b: CwHabit) => b.createdAt - a.createdAt)
    return out
  }

  private static async persistHabitEntries(list: CwHabitEntry[]): Promise<void> {
    const lines: string[] = []
    for (const e of list) {
      lines.push([
        e.id, e.habitId, e.dateKey, ChenwuStore.sanitize(e.note),
        ChenwuStore.sanitize(e.changeNote), e.done ? '1' : '0', `${e.createdAt}`
      ].join('\t'))
    }
    await ChenwuStore.putString(KEY_HABIT_ENTRIES, lines.join('\n'))
  }

  private static parseHabitEntries(raw: string): CwHabitEntry[] {
    const out: CwHabitEntry[] = []
    for (const line of ChenwuStore.splitLines(raw)) {
      const p = line.split('\t')
      if (p.length < 7) {
        continue
      }
      const e = new CwHabitEntry()
      e.id = p[0]
      e.habitId = p[1]
      e.dateKey = p[2]
      e.note = p[3]
      e.changeNote = p[4]
      e.done = p[5] === '1'
      e.createdAt = parseInt(p[6], 10)
      out.push(e)
    }
    out.sort((a: CwHabitEntry, b: CwHabitEntry) => b.dateKey.localeCompare(a.dateKey))
    return out
  }

  private static async persistJournals(list: CwJournalEntry[]): Promise<void> {
    const lines: string[] = []
    for (const j of list) {
      lines.push([
        j.id, j.dateKey, ChenwuStore.sanitize(j.doneToday), ChenwuStore.sanitize(j.discovery),
        ChenwuStore.sanitize(j.tomorrowAdjust), `${j.createdAt}`
      ].join('\t'))
    }
    await ChenwuStore.putString(KEY_JOURNALS, lines.join('\n'))
  }

  private static parseJournals(raw: string): CwJournalEntry[] {
    const out: CwJournalEntry[] = []
    for (const line of ChenwuStore.splitLines(raw)) {
      const p = line.split('\t')
      if (p.length < 6) {
        continue
      }
      const j = new CwJournalEntry()
      j.id = p[0]
      j.dateKey = p[1]
      j.doneToday = p[2]
      j.discovery = p[3]
      j.tomorrowAdjust = p[4]
      j.createdAt = parseInt(p[5], 10)
      out.push(j)
    }
    out.sort((a: CwJournalEntry, b: CwJournalEntry) => b.dateKey.localeCompare(a.dateKey))
    return out
  }

  private static async persistCategories(list: CwGoalCategory[]): Promise<void> {
    const lines: string[] = []
    for (const c of list) {
      lines.push(`${c.key}\t${c.label}\t${c.coverKey}`)
    }
    await ChenwuStore.putString(KEY_CATS, lines.join('\n'))
  }

  private static parseCategories(raw: string): CwGoalCategory[] {
    const out: CwGoalCategory[] = []
    for (const line of ChenwuStore.splitLines(raw)) {
      const p = line.split('\t')
      if (p.length < 3) {
        continue
      }
      out.push(CwGoalCategory.make(p[0], p[1], p[2]))
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    const cached = ChenwuStore.mem.get(key)
    if (cached !== undefined) {
      return cached
    }
    if (!(await ChenwuStore.ensurePref()) || ChenwuStore.pref === null) {
      return fallback
    }
    try {
      const v = await ChenwuStore.pref.get(key, fallback)
      if (typeof v === 'string') {
        ChenwuStore.mem.set(key, v)
        return v
      }
      return fallback
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    ChenwuStore.mem.set(key, value)
    if (!(await ChenwuStore.ensurePref()) || ChenwuStore.pref === null) {
      return
    }
    try {
      await ChenwuStore.pref.put(key, value)
      await ChenwuStore.pref.flush()
    } catch {
      // mem cache keeps session reads consistent
    }
  }
}
