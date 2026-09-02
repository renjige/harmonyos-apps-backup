import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  GoalItem, HabitItem, ImportantMoment, InspirationItem, LifePlan, PlanProgress, PlanTask
} from '../models/LifeModels'
import { DateHelper } from './DateHelper'
import { LifeStorePhase3 } from './LifeStorePhase3'

const STORE = 'shiguang_life_v1'
const KEY_PLANS = 'plans'
const KEY_PLAN_TASKS = 'planTasks'
const KEY_HABITS = 'habits'
const KEY_HABIT_LOGS = 'habitLogs'
const KEY_GOALS = 'goals'
const KEY_MOMENTS = 'moments'
const KEY_INSPIRATIONS = 'inspirations'
const KEY_ACHIEVEMENTS = 'achievements'
const KEY_ONBOARDING = 'onboardingSeen'

export class LifeStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      LifeStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      LifeStore.pref = null
    }
  }

  // --- Plans ---

  static async loadPlans(): Promise<LifePlan[]> {
    const raw = await LifeStore.getString(KEY_PLANS, '')
    return LifeStore.parsePlans(raw)
  }

  static async findPlan(id: string): Promise<LifePlan | undefined> {
    const list = await LifeStore.loadPlans()
    for (const p of list) {
      if (p.id === id) {
        return p
      }
    }
    return undefined
  }

  static async savePlan(plan: LifePlan): Promise<void> {
    const list = await LifeStore.loadPlans()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === plan.id) {
        list[i] = plan
        found = true
      }
    }
    if (!found) {
      list.push(plan)
    }
    await LifeStore.persistPlans(list)
  }

  static async deletePlan(id: string): Promise<void> {
    const list = await LifeStore.loadPlans()
    const next: LifePlan[] = []
    for (const p of list) {
      if (p.id !== id) {
        next.push(p)
      }
    }
    await LifeStore.persistPlans(next)
    const tasks = await LifeStore.loadPlanTasks()
    const kept: PlanTask[] = []
    for (const t of tasks) {
      if (t.planId !== id) {
        kept.push(t)
      }
    }
    await LifeStore.persistPlanTasks(kept)
  }

  // --- Plan Tasks ---

  static async loadPlanTasks(): Promise<PlanTask[]> {
    const raw = await LifeStore.getString(KEY_PLAN_TASKS, '')
    return LifeStore.parsePlanTasks(raw)
  }

  static async tasksForPlan(planId: string): Promise<PlanTask[]> {
    const list = await LifeStore.loadPlanTasks()
    const out: PlanTask[] = []
    for (const t of list) {
      if (t.planId === planId) {
        out.push(t)
      }
    }
    out.sort((a, b) => a.sortOrder - b.sortOrder)
    return out
  }

  static async savePlanTask(task: PlanTask): Promise<void> {
    const list = await LifeStore.loadPlanTasks()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === task.id) {
        list[i] = task
        found = true
      }
    }
    if (!found) {
      list.push(task)
    }
    await LifeStore.persistPlanTasks(list)
  }

  static async deletePlanTask(id: string): Promise<void> {
    const list = await LifeStore.loadPlanTasks()
    const next: PlanTask[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    await LifeStore.persistPlanTasks(next)
  }

  static async togglePlanTaskDone(id: string): Promise<void> {
    const list = await LifeStore.loadPlanTasks()
    for (const t of list) {
      if (t.id === id) {
        t.done = !t.done
        await LifeStore.persistPlanTasks(list)
        if (t.done) {
          await LifeStorePhase3.logPlanTaskDone(t.id, DateHelper.todayKey())
        }
        await LifeStore.syncPlanCompletion(t.planId)
        return
      }
    }
  }

  static async syncPlanCompletion(planId: string): Promise<void> {
    const tasks = await LifeStore.tasksForPlan(planId)
    if (tasks.length === 0) {
      return
    }
    let allDone = true
    for (const t of tasks) {
      if (!t.done) {
        allDone = false
      }
    }
    const plan = await LifeStore.findPlan(planId)
    if (plan === undefined) {
      return
    }
    if (allDone) {
      plan.status = 'done'
    } else if (plan.status === 'done') {
      plan.status = 'active'
    }
    await LifeStore.savePlan(plan)
  }

  static async completePlan(id: string): Promise<void> {
    const plan = await LifeStore.findPlan(id)
    if (plan === undefined) {
      return
    }
    plan.status = 'done'
    const list = await LifeStore.loadPlanTasks()
    for (const t of list) {
      if (t.planId === id) {
        t.done = true
      }
    }
    await LifeStore.persistPlanTasks(list)
    await LifeStore.savePlan(plan)
  }

  static async countDonePlanTasks(): Promise<number> {
    const tasks = await LifeStore.loadPlanTasks()
    let cnt = 0
    for (const t of tasks) {
      if (t.done) {
        cnt++
      }
    }
    return cnt
  }

  static async todayPlanProgress(): Promise<PlanProgress> {
    return LifeStore.computeTodayPlanProgress()
  }

  static async computeTodayPlanProgress(): Promise<PlanProgress> {
    const plans = await LifeStore.loadPlans()
    const tasks = await LifeStore.loadPlanTasks()
    let done = 0
    let total = 0
    for (const p of plans) {
      if (p.status !== 'active') {
        continue
      }
      for (const t of tasks) {
        if (t.planId === p.id) {
          total++
          if (t.done) {
            done++
          }
        }
      }
    }
    return PlanProgress.make(done, total)
  }

  /** 与计划页「今日计划任务」一致 */
  static async loadTodayActivePlanTasks(): Promise<PlanTask[]> {
    const plans = await LifeStore.loadPlans()
    const tasks = await LifeStore.loadPlanTasks()
    const out: PlanTask[] = []
    for (const t of tasks) {
      for (const p of plans) {
        if (p.status === 'active' && t.planId === p.id) {
          out.push(t)
          break
        }
      }
    }
    return out
  }

  private static planContainsDate(plan: LifePlan, dateKey: string): boolean {
    if (plan.startDate.length === 0 && plan.endDate.length === 0) {
      return true
    }
    if (plan.startDate.length > 0 && dateKey < plan.startDate) {
      return false
    }
    if (plan.endDate.length > 0 && dateKey > plan.endDate) {
      return false
    }
    return true
  }

  // --- Habits ---

  static async loadHabits(): Promise<HabitItem[]> {
    const raw = await LifeStore.getString(KEY_HABITS, '')
    return LifeStore.parseHabits(raw)
  }

  static async saveHabit(habit: HabitItem): Promise<void> {
    const list = await LifeStore.loadHabits()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === habit.id) {
        list[i] = habit
        found = true
      }
    }
    if (!found) {
      list.push(habit)
    }
    await LifeStore.persistHabits(list)
  }

  static async deleteHabit(id: string): Promise<void> {
    const list = await LifeStore.loadHabits()
    const next: HabitItem[] = []
    for (const h of list) {
      if (h.id !== id) {
        next.push(h)
      }
    }
    await LifeStore.persistHabits(next)
    const logs = await LifeStore.loadHabitLogKeys()
    const kept: string[] = []
    for (const line of logs) {
      const parts = line.split('\t')
      if (parts.length >= 1 && parts[0] !== id) {
        kept.push(line)
      }
    }
    await LifeStore.putString(KEY_HABIT_LOGS, kept.join('\n'))
  }

  static async loadHabitLogKeys(): Promise<string[]> {
    const raw = await LifeStore.getString(KEY_HABIT_LOGS, '')
    if (raw.length === 0) {
      return []
    }
    return raw.split('\n').filter((l: string) => l.length > 0)
  }

  static async habitNamesOnDate(dateKey: string): Promise<string[]> {
    const habits = await LifeStore.loadHabits()
    const logs = await LifeStore.loadHabitLogKeys()
    const names: string[] = []
    for (const line of logs) {
      const parts = line.split('\t')
      if (parts.length >= 2 && parts[1] === dateKey) {
        const habitId = parts[0]
        for (const h of habits) {
          if (h.id === habitId && !names.includes(h.name)) {
            names.push(h.name)
          }
        }
      }
    }
    return names
  }

  static async isHabitLogged(habitId: string, dateKey: string): Promise<boolean> {
    const logs = await LifeStore.loadHabitLogKeys()
    const needle = `${habitId}\t${dateKey}`
    for (const line of logs) {
      if (line === needle) {
        return true
      }
    }
    return false
  }

  static async toggleHabitLog(habitId: string, dateKey: string): Promise<void> {
    const logs = await LifeStore.loadHabitLogKeys()
    const needle = `${habitId}\t${dateKey}`
    let found = false
    const next: string[] = []
    for (const line of logs) {
      if (line === needle) {
        found = true
      } else {
        next.push(line)
      }
    }
    if (!found) {
      next.push(needle)
    }
    await LifeStore.putString(KEY_HABIT_LOGS, next.join('\n'))
  }

  static async getHabitStreak(habitId: string): Promise<number> {
    const logs = await LifeStore.loadHabitLogKeys()
    const dateSet: Set<string> = new Set()
    for (const line of logs) {
      const parts = line.split('\t')
      if (parts.length >= 2 && parts[0] === habitId) {
        dateSet.add(parts[1])
      }
    }
    if (dateSet.size === 0) {
      return 0
    }
    let offset = 0
    if (!dateSet.has(DateHelper.todayKey())) {
      offset = 1
    }
    let streak = 0
    for (let i = offset; i < 400; i++) {
      const key = DateHelper.daysAgoKey(i)
      if (dateSet.has(key)) {
        streak++
      } else {
        break
      }
    }
    return streak
  }

  // --- Goals ---

  static async loadGoals(): Promise<GoalItem[]> {
    const raw = await LifeStore.getString(KEY_GOALS, '')
    return LifeStore.parseGoals(raw)
  }

  static async saveGoal(goal: GoalItem): Promise<void> {
    const list = await LifeStore.loadGoals()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === goal.id) {
        list[i] = goal
        found = true
      }
    }
    if (!found) {
      list.push(goal)
    }
    await LifeStore.persistGoals(list)
  }

  static async deleteGoal(id: string): Promise<void> {
    const list = await LifeStore.loadGoals()
    const next: GoalItem[] = []
    for (const g of list) {
      if (g.id !== id) {
        next.push(g)
      }
    }
    await LifeStore.persistGoals(next)
  }

  static async incrementGoal(id: string, step: number = 1): Promise<void> {
    const list = await LifeStore.loadGoals()
    for (const g of list) {
      if (g.id === id) {
        g.currentNum = g.currentNum + step
        if (g.currentNum >= g.targetNum) {
          g.currentNum = g.targetNum
          g.status = 'done'
        }
        await LifeStore.persistGoals(list)
        return
      }
    }
  }

  static async completeGoal(id: string): Promise<void> {
    const list = await LifeStore.loadGoals()
    for (const g of list) {
      if (g.id === id) {
        g.currentNum = g.targetNum
        g.status = 'done'
        await LifeStore.persistGoals(list)
        return
      }
    }
  }

  // --- Moments ---

  static async loadMoments(): Promise<ImportantMoment[]> {
    const raw = await LifeStore.getString(KEY_MOMENTS, '')
    return LifeStore.parseMoments(raw)
  }

  static async saveMoment(moment: ImportantMoment): Promise<void> {
    const list = await LifeStore.loadMoments()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === moment.id) {
        list[i] = moment
        found = true
      }
    }
    if (!found) {
      list.push(moment)
    }
    await LifeStore.persistMoments(list)
  }

  static async deleteMoment(id: string): Promise<void> {
    const list = await LifeStore.loadMoments()
    const next: ImportantMoment[] = []
    for (const m of list) {
      if (m.id !== id) {
        next.push(m)
      }
    }
    await LifeStore.persistMoments(next)
  }

  // --- Inspirations ---

  static async loadInspirations(): Promise<InspirationItem[]> {
    const raw = await LifeStore.getString(KEY_INSPIRATIONS, '')
    return LifeStore.parseInspirations(raw)
  }

  static async saveInspiration(item: InspirationItem): Promise<void> {
    const list = await LifeStore.loadInspirations()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === item.id) {
        list[i] = item
        found = true
      }
    }
    if (!found) {
      list.push(item)
    }
    await LifeStore.persistInspirations(list)
  }

  static async deleteInspiration(id: string): Promise<void> {
    const list = await LifeStore.loadInspirations()
    const next: InspirationItem[] = []
    for (const i of list) {
      if (i.id !== id) {
        next.push(i)
      }
    }
    await LifeStore.persistInspirations(next)
  }

  // --- Achievements / Onboarding ---

  static async loadUnlockedAchievements(): Promise<string[]> {
    const raw = await LifeStore.getString(KEY_ACHIEVEMENTS, '')
    if (raw.length === 0) {
      return []
    }
    const parts = raw.split('|')
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0 && !out.includes(t)) {
        out.push(t)
      }
    }
    return out
  }

  static async unlockAchievement(id: string): Promise<void> {
    const list = await LifeStore.loadUnlockedAchievements()
    if (!list.includes(id)) {
      list.push(id)
      await LifeStore.putString(KEY_ACHIEVEMENTS, list.join('|'))
    }
  }

  static async isOnboardingSeen(): Promise<boolean> {
    const raw = await LifeStore.getString(KEY_ONBOARDING, '0')
    return raw === '1'
  }

  static async markOnboardingSeen(): Promise<void> {
    await LifeStore.putString(KEY_ONBOARDING, '1')
  }

  static async clearAll(): Promise<void> {
    await LifeStore.putString(KEY_PLANS, '')
    await LifeStore.putString(KEY_PLAN_TASKS, '')
    await LifeStore.putString(KEY_HABITS, '')
    await LifeStore.putString(KEY_HABIT_LOGS, '')
    await LifeStore.putString(KEY_GOALS, '')
    await LifeStore.putString(KEY_MOMENTS, '')
    await LifeStore.putString(KEY_INSPIRATIONS, '')
    await LifeStore.putString(KEY_ACHIEVEMENTS, '')
    await LifeStore.putString(KEY_ONBOARDING, '0')
    await LifeStorePhase3.clearPhase3()
  }

  static async exportJson(): Promise<string> {
    return LifeStorePhase3.exportLifeJson()
  }

  static async togglePlanFavorite(id: string): Promise<void> {
    const plan = await LifeStore.findPlan(id)
    if (plan === undefined) {
      return
    }
    plan.isFavorite = !plan.isFavorite
    await LifeStore.savePlan(plan)
  }

  static async toggleMomentFavorite(id: string): Promise<void> {
    const list = await LifeStore.loadMoments()
    for (const m of list) {
      if (m.id === id) {
        m.isFavorite = !m.isFavorite
        await LifeStore.persistMoments(list)
        return
      }
    }
  }

  static async toggleInspirationFavorite(id: string): Promise<void> {
    const list = await LifeStore.loadInspirations()
    for (const i of list) {
      if (i.id === id) {
        i.isFavorite = !i.isFavorite
        await LifeStore.persistInspirations(list)
        return
      }
    }
  }

  static async getRaw(key: string, fallback: string): Promise<string> {
    return LifeStore.getString(key, fallback)
  }

  static async putRaw(key: string, value: string): Promise<void> {
    await LifeStore.putString(key, value)
  }

  // --- Serialization ---

  private static serializePlan(p: LifePlan): string {
    return [
      p.id,
      p.title.replace(/\t/g, ' '),
      p.planType,
      p.startDate,
      p.endDate,
      p.status,
      `${p.createdAt}`,
      p.isFavorite ? '1' : '0'
    ].join('\t')
  }

  private static parsePlans(raw: string): LifePlan[] {
    const out: LifePlan[] = []
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
      const p = new LifePlan()
      p.id = parts[0]
      p.title = parts[1]
      p.planType = parts[2]
      p.startDate = parts[3]
      p.endDate = parts[4]
      p.status = parts[5]
      p.createdAt = parseInt(parts[6], 10)
      if (parts.length >= 8) {
        p.isFavorite = parts[7] === '1'
      }
      out.push(p)
    }
    return out
  }

  private static serializePlanTask(t: PlanTask): string {
    return [
      t.id, t.planId, t.title.replace(/\t/g, ' '),
      t.done ? '1' : '0', `${t.sortOrder}`
    ].join('\t')
  }

  private static parsePlanTasks(raw: string): PlanTask[] {
    const out: PlanTask[] = []
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
      const t = new PlanTask()
      t.id = parts[0]
      t.planId = parts[1]
      t.title = parts[2]
      t.done = parts[3] === '1'
      t.sortOrder = parseInt(parts[4], 10)
      out.push(t)
    }
    return out
  }

  private static serializeHabit(h: HabitItem): string {
    return [h.id, h.name.replace(/\t/g, ' '), `${h.createdAt}`].join('\t')
  }

  private static parseHabits(raw: string): HabitItem[] {
    const out: HabitItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 3) {
        continue
      }
      const h = new HabitItem()
      h.id = parts[0]
      h.name = parts[1]
      h.createdAt = parseInt(parts[2], 10)
      out.push(h)
    }
    return out
  }

  private static serializeGoal(g: GoalItem): string {
    return [
      g.id, g.title.replace(/\t/g, ' '), g.targetLabel.replace(/\t/g, ' '),
      `${g.currentNum}`, `${g.targetNum}`, g.unit,
      g.startDate, g.endDate, g.status, `${g.createdAt}`
    ].join('\t')
  }

  private static parseGoals(raw: string): GoalItem[] {
    const out: GoalItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 10) {
        continue
      }
      const g = new GoalItem()
      g.id = parts[0]
      g.title = parts[1]
      g.targetLabel = parts[2]
      g.currentNum = parseInt(parts[3], 10)
      g.targetNum = parseInt(parts[4], 10)
      g.unit = parts[5]
      g.startDate = parts[6]
      g.endDate = parts[7]
      g.status = parts[8]
      g.createdAt = parseInt(parts[9], 10)
      out.push(g)
    }
    return out
  }

  private static serializeMoment(m: ImportantMoment): string {
    return [
      m.id, m.title.replace(/\t/g, ' '), m.dateKey,
      m.description.replace(/\t/g, ' '), m.category,
      m.useCountdown ? '1' : '0', m.done ? '1' : '0', `${m.createdAt}`,
      m.isFavorite ? '1' : '0'
    ].join('\t')
  }

  private static parseMoments(raw: string): ImportantMoment[] {
    const out: ImportantMoment[] = []
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
      const m = new ImportantMoment()
      m.id = parts[0]
      m.title = parts[1]
      m.dateKey = parts[2]
      m.description = parts[3]
      m.category = parts[4]
      m.useCountdown = parts[5] === '1'
      m.done = parts[6] === '1'
      m.createdAt = parseInt(parts[7], 10)
      if (parts.length >= 9) {
        m.isFavorite = parts[8] === '1'
      }
      out.push(m)
    }
    return out
  }

  private static serializeInspiration(i: InspirationItem): string {
    const tags = i.tags.join(',')
    return [
      i.id, i.text.replace(/\t/g, ' ').replace(/\n/g, ' '),
      i.categoryKey, i.status, tags, `${i.createdAt}`,
      i.isFavorite ? '1' : '0'
    ].join('\t')
  }

  private static parseInspirations(raw: string): InspirationItem[] {
    const out: InspirationItem[] = []
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
      const i = new InspirationItem()
      i.id = parts[0]
      i.text = parts[1]
      i.categoryKey = parts[2]
      i.status = parts[3]
      i.tags = LifeStore.splitCsv(parts[4])
      i.createdAt = parseInt(parts[5], 10)
      if (parts.length >= 7) {
        i.isFavorite = parts[6] === '1'
      }
      out.push(i)
    }
    out.sort((a, b) => b.createdAt - a.createdAt)
    return out
  }

  private static splitCsv(raw: string): string[] {
    if (raw.length === 0) {
      return []
    }
    const parts = raw.split(',')
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private static async persistPlans(items: LifePlan[]): Promise<void> {
    const lines: string[] = []
    for (const p of items) {
      lines.push(LifeStore.serializePlan(p))
    }
    await LifeStore.putString(KEY_PLANS, lines.join('\n'))
  }

  private static async persistPlanTasks(items: PlanTask[]): Promise<void> {
    const lines: string[] = []
    for (const t of items) {
      lines.push(LifeStore.serializePlanTask(t))
    }
    await LifeStore.putString(KEY_PLAN_TASKS, lines.join('\n'))
  }

  private static async persistHabits(items: HabitItem[]): Promise<void> {
    const lines: string[] = []
    for (const h of items) {
      lines.push(LifeStore.serializeHabit(h))
    }
    await LifeStore.putString(KEY_HABITS, lines.join('\n'))
  }

  private static async persistGoals(items: GoalItem[]): Promise<void> {
    const lines: string[] = []
    for (const g of items) {
      lines.push(LifeStore.serializeGoal(g))
    }
    await LifeStore.putString(KEY_GOALS, lines.join('\n'))
  }

  private static async persistMoments(items: ImportantMoment[]): Promise<void> {
    const lines: string[] = []
    for (const m of items) {
      lines.push(LifeStore.serializeMoment(m))
    }
    await LifeStore.putString(KEY_MOMENTS, lines.join('\n'))
  }

  private static async persistInspirations(items: InspirationItem[]): Promise<void> {
    const lines: string[] = []
    for (const i of items) {
      lines.push(LifeStore.serializeInspiration(i))
    }
    await LifeStore.putString(KEY_INSPIRATIONS, lines.join('\n'))
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (LifeStore.pref === null) {
      return fallback
    }
    try {
      const v = await LifeStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (LifeStore.pref === null) {
      return
    }
    try {
      await LifeStore.pref.put(key, value)
      await LifeStore.pref.flush()
    } catch {
    }
  }
}
