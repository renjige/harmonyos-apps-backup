import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  ActionLog,
  GrowthStats,
  KnowledgeItem,
  OverviewStats,
  PlanTask,
  PlanTemplate,
  StudyHabit,
  StudyPlan,
  StudyReminder,
  TagNode,
  TimelineEvent,
  TodayProgress,
  WeeklyGoalProgress,
  WeeklyInsight
} from '../models/ZhixingModels'

const STORE = 'zhixing_ye_v1'
const DAY_MS = 24 * 60 * 60 * 1000

export class ZhixingStore {
  private static pref: preferences.Preferences | null = null
  private static ctx: common.UIAbilityContext | null = null

  static notifyChanged(): void {
    const cur = AppStorage.get<number>('dataEpoch') ?? 0
    AppStorage.setOrCreate('dataEpoch', cur + 1)
  }

  static async getAchievementRaw(): Promise<string> {
    return await ZhixingStore.getString('achievements', '')
  }

  static async saveAchievementRaw(v: string): Promise<void> {
    await ZhixingStore.putString('achievements', v)
  }

  static async loadFavorites(): Promise<KnowledgeItem[]> {
    const all = await ZhixingStore.loadItems()
    const out: KnowledgeItem[] = []
    for (const it of all) {
      if (it.favorite) {
        out.push(it)
      }
    }
    return out
  }

  static async loadByTag(tag: string): Promise<KnowledgeItem[]> {
    const q = tag.trim()
    const all = await ZhixingStore.loadItems()
    const out: KnowledgeItem[] = []
    for (const it of all) {
      const tags = it.tagList()
      for (const t of tags) {
        if (t === q) {
          out.push(it)
          break
        }
      }
    }
    return out
  }

  static async searchFiltered(keyword: string, kindFilter: string, favOnly: boolean): Promise<KnowledgeItem[]> {
    let list = await ZhixingStore.search(keyword)
    if (kindFilter.length > 0 && kindFilter !== 'all') {
      const next: KnowledgeItem[] = []
      for (const it of list) {
        if (it.kind === kindFilter) {
          next.push(it)
        }
      }
      list = next
    }
    if (!favOnly) {
      return list
    }
    const fav: KnowledgeItem[] = []
    for (const it of list) {
      if (it.favorite) {
        fav.push(it)
      }
    }
    return fav
  }

  static async loadContinueReading(limit: number): Promise<KnowledgeItem[]> {
    const all = await ZhixingStore.loadItems()
    all.sort((a: KnowledgeItem, b: KnowledgeItem) => b.updateTime - a.updateTime)
    const out: KnowledgeItem[] = []
    for (const it of all) {
      out.push(it)
      if (out.length >= limit) {
        break
      }
    }
    return out
  }

  static async todayProgress(): Promise<TodayProgress> {
    const tp = new TodayProgress()
    const today = ActionLog.formatDate(Date.now())
    const habits = await ZhixingStore.loadHabits()
    tp.habitTotal = habits.length
    for (const h of habits) {
      if (h.lastCheckDate === today) {
        tp.habitDone++
      }
    }
    const plans = await ZhixingStore.loadPlans()
    for (const p of plans) {
      if (p.status !== 'active') {
        continue
      }
      for (const t of p.tasks) {
        tp.taskTotal++
        if (t.done) {
          tp.taskDone++
        }
      }
    }
    return tp
  }

  static async loadTimeline(limit: number): Promise<TimelineEvent[]> {
    const events: TimelineEvent[] = []
    const items = await ZhixingStore.loadItems()
    for (const it of items) {
      const e = new TimelineEvent()
      e.dateKey = ZhixingStore.timeLabel(it.createTime)
      e.eventType = 'create'
      e.refId = it.id
      e.title = `${it.kindLabel()} · ${it.title}`
      e.createTime = it.createTime
      events.push(e)
      if (it.favorite) {
        const f = new TimelineEvent()
        f.dateKey = ZhixingStore.timeLabel(it.updateTime)
        f.eventType = 'favorite'
        f.refId = it.id
        f.title = `收藏 · ${it.title}`
        f.createTime = it.updateTime
        events.push(f)
      }
    }
    const habits = await ZhixingStore.loadHabits()
    for (const h of habits) {
      for (const d of h.checkDates) {
        const e = new TimelineEvent()
        e.dateKey = d
        e.eventType = 'check'
        e.refId = h.id
        e.title = `打卡 · ${h.title}`
        e.createTime = Date.parse(`${d}T12:00:00`)
        events.push(e)
      }
    }
    const plans = await ZhixingStore.loadPlans()
    for (const p of plans) {
      if (p.status === 'done') {
        const e = new TimelineEvent()
        e.dateKey = ZhixingStore.timeLabel(p.createTime)
        e.eventType = 'done'
        e.refId = p.id
        e.title = `完成计划 · ${p.title}`
        e.createTime = p.createTime
        events.push(e)
      }
    }
    const logs = await ZhixingStore.loadLogs()
    for (const l of logs) {
      const e = new TimelineEvent()
      e.dateKey = l.dateKey.length > 0 ? l.dateKey : ZhixingStore.timeLabel(l.createTime)
      e.eventType = 'log'
      e.refId = l.id
      e.title = `日志 · ${l.title}`
      e.createTime = l.createTime
      events.push(e)
    }
    events.sort((a: TimelineEvent, b: TimelineEvent) => b.createTime - a.createTime)
    const out: TimelineEvent[] = []
    for (const ev of events) {
      out.push(ev)
      if (out.length >= limit) {
        break
      }
    }
    return out
  }

  static async growthStats(): Promise<GrowthStats> {
    const g = new GrowthStats()
    const start = ZhixingStore.weekStartMs()
    const items = await ZhixingStore.loadItems()
    for (const it of items) {
      g.knowledgeTotal++
      if (it.favorite) {
        g.favoriteTotal++
      }
      if (it.createTime >= start) {
        g.weekKnowledge++
      }
    }
    const logs = await ZhixingStore.loadLogs()
    g.logTotal = logs.length
    for (const l of logs) {
      if (l.createTime >= start) {
        g.weekLogs++
      }
    }
    const plans = await ZhixingStore.loadPlans()
    for (const p of plans) {
      if (p.status === 'done') {
        g.donePlans++
      }
    }
    const habits = await ZhixingStore.loadHabits()
    for (const h of habits) {
      if (h.streak > g.maxStreak) {
        g.maxStreak = h.streak
      }
      for (const d of h.checkDates) {
        const ms = Date.parse(`${d}T00:00:00`)
        const monthStart = new Date(new Date().getFullYear(), new Date().getMonth(), 1).getTime()
        if (ms >= monthStart) {
          g.monthChecks++
        }
      }
    }
    return g
  }

  static async togglePlanTask(planId: string, taskId: string): Promise<void> {
    const p = await ZhixingStore.findPlan(planId)
    if (p === undefined) {
      return
    }
    for (const t of p.tasks) {
      if (t.id === taskId) {
        t.done = !t.done
      }
    }
    p.syncProgressFromTasks()
    await ZhixingStore.savePlan(p)
  }

  static async addPlanTask(planId: string, title: string): Promise<void> {
    const p = await ZhixingStore.findPlan(planId)
    if (p === undefined || title.trim().length === 0) {
      return
    }
    p.tasks.push(PlanTask.create(title.trim()))
    p.syncProgressFromTasks()
    await ZhixingStore.savePlan(p)
  }

  static planTemplates(): PlanTemplate[] {
    const out: PlanTemplate[] = []
    const t1 = new PlanTemplate()
    t1.id = 'read21'
    t1.title = '21 天阅读计划'
    t1.goal = '每天阅读并沉淀为摘要卡片，第 21 天复盘'
    t1.taskTitles = ['阅读 30 分钟', '写摘要卡片', '周中复盘一次']
    out.push(t1)
    const t2 = new PlanTemplate()
    t2.id = 'skill'
    t2.title = '技能攻坚计划'
    t2.goal = '围绕一个技能点完成拆解、练习与输出'
    t2.taskTitles = ['整理知识卡片', '完成 3 次练习', '输出行动日志']
    out.push(t2)
    const t3 = new PlanTemplate()
    t3.id = 'habit21'
    t3.title = '21 天习惯计划'
    t3.goal = '与习惯打卡联动，形成稳定学习节奏'
    t3.taskTitles = ['每日打卡', '写一条日志', '周末总结']
    out.push(t3)
    return out
  }

  static async markReviewed(id: string): Promise<boolean> {
    const item = await ZhixingStore.findItem(id)
    if (item === undefined) {
      return false
    }
    item.updateTime = Date.now()
    await ZhixingStore.saveItem(item)
    await ZhixingStore.bumpWeekReviewCount()
    return true
  }

  private static weekReviewKey(): string {
    return `rev_${ZhixingStore.weekStartMs()}`
  }

  static async bumpWeekReviewCount(): Promise<void> {
    const key = ZhixingStore.weekReviewKey()
    const raw = await ZhixingStore.getString('week_reviews', '')
    let count = 0
    if (raw.startsWith(`${key}:`)) {
      count = ZhixingStore.num(raw.substring(key.length + 1))
    }
    count++
    await ZhixingStore.putString('week_reviews', `${key}:${count}`)
  }

  private static async weekReviewCount(): Promise<number> {
    const key = ZhixingStore.weekReviewKey()
    const raw = await ZhixingStore.getString('week_reviews', '')
    if (!raw.startsWith(`${key}:`)) {
      return 0
    }
    return ZhixingStore.num(raw.substring(key.length + 1))
  }

  static async weekHabitCheckCount(): Promise<number> {
    const start = ZhixingStore.weekStartMs()
    const habits = await ZhixingStore.loadHabits()
    let total = 0
    for (const h of habits) {
      for (const d of h.checkDates) {
        const ms = Date.parse(`${d}T00:00:00`)
        if (ms >= start) {
          total++
        }
      }
    }
    return total
  }

  static async loadWeeklyGoalProgress(): Promise<WeeklyGoalProgress> {
    const g = new WeeklyGoalProgress()
    const raw = await ZhixingStore.getString('weekly_goal', '3\t5\t2')
    const p = raw.split('\t')
    if (p.length > 0) {
      g.targetKnowledge = ZhixingStore.num(p[0]) > 0 ? ZhixingStore.num(p[0]) : 3
    }
    if (p.length > 1) {
      g.targetChecks = ZhixingStore.num(p[1]) > 0 ? ZhixingStore.num(p[1]) : 5
    }
    if (p.length > 2) {
      g.targetReviews = ZhixingStore.num(p[2]) > 0 ? ZhixingStore.num(p[2]) : 2
    }
    const w = await ZhixingStore.weeklyInsight()
    g.doneKnowledge = w.newKnowledge
    g.doneChecks = await ZhixingStore.weekHabitCheckCount()
    g.doneReviews = await ZhixingStore.weekReviewCount()
    return g
  }

  static async saveWeeklyGoalTargets(know: number, checks: number, reviews: number): Promise<void> {
    const k = know > 0 ? know : 3
    const c = checks > 0 ? checks : 5
    const r = reviews > 0 ? reviews : 2
    await ZhixingStore.putString('weekly_goal', `${k}\t${c}\t${r}`)
    ZhixingStore.notifyChanged()
  }

  static async logFocusSession(title: string, minutes: number, knowId: string): Promise<void> {
    const log = ActionLog.createNew()
    log.title = title.length > 0 ? `专注 · ${title}` : '专注学习'
    log.body = `完成 ${minutes} 分钟专注学习，已记入行动日志。`
    if (knowId.length > 0) {
      log.relatedPlanId = knowId
    }
    await ZhixingStore.saveLog(log)
  }

  private static memKey(key: string): string {
    return `zx_mem_${key}`
  }

  static weekStartMs(): number {
    const now = new Date()
    const day = now.getDay()
    const diff = day === 0 ? 6 : day - 1
    const start = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    start.setDate(start.getDate() - diff)
    start.setHours(0, 0, 0, 0)
    return start.getTime()
  }

  static async weeklyInsight(): Promise<WeeklyInsight> {
    const w = new WeeklyInsight()
    const start = ZhixingStore.weekStartMs()
    const items = await ZhixingStore.loadItems()
    for (const it of items) {
      if (it.createTime >= start) {
        w.newKnowledge++
      }
    }
    const logs = await ZhixingStore.loadLogs()
    for (const l of logs) {
      if (l.createTime >= start) {
        w.newLogs++
      }
    }
    const habits = await ZhixingStore.loadHabits()
    w.habitTotal = habits.length
    const today = ActionLog.formatDate(Date.now())
    for (const h of habits) {
      if (h.lastCheckDate === today) {
        w.checkedHabitsToday++
      }
    }
    w.planRate = await ZhixingStore.planRate()
    w.staleCount = (await ZhixingStore.staleItems()).length
    return w
  }

  static async staleItems(): Promise<KnowledgeItem[]> {
    const all = await ZhixingStore.loadItems()
    const cut = Date.now() - 7 * DAY_MS
    const out: KnowledgeItem[] = []
    for (const it of all) {
      if (it.updateTime > 0 && it.updateTime < cut) {
        out.push(it)
      }
      if (out.length >= 8) {
        break
      }
    }
    return out
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    ZhixingStore.ctx = context
    try {
      ZhixingStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ZhixingStore.pref = null
    }
  }

  private static async ensurePref(): Promise<void> {
    if (ZhixingStore.pref !== null) {
      return
    }
    if (ZhixingStore.ctx === null) {
      return
    }
    try {
      ZhixingStore.pref = await preferences.getPreferences(ZhixingStore.ctx, STORE)
    } catch {
      ZhixingStore.pref = null
    }
  }

  static async loadItems(): Promise<KnowledgeItem[]> {
    return ZhixingStore.parseItems(await ZhixingStore.getString('items', ''))
  }

  static async loadByKind(kind: string): Promise<KnowledgeItem[]> {
    const all = await ZhixingStore.loadItems()
    const out: KnowledgeItem[] = []
    for (const it of all) {
      if (it.kind === kind) {
        out.push(it)
      }
    }
    return out
  }

  static async findItem(id: string): Promise<KnowledgeItem | undefined> {
    const all = await ZhixingStore.loadItems()
    for (const it of all) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async saveItem(item: KnowledgeItem): Promise<void> {
    item.updateTime = Date.now()
    const all = await ZhixingStore.loadItems()
    const next: KnowledgeItem[] = []
    let found = false
    for (const it of all) {
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
    next.sort((a: KnowledgeItem, b: KnowledgeItem) => b.updateTime - a.updateTime)
    await ZhixingStore.putString('items', ZhixingStore.joinItems(next))
    ZhixingStore.notifyChanged()
  }

  static async deleteItem(id: string): Promise<void> {
    const all = await ZhixingStore.loadItems()
    const next: KnowledgeItem[] = []
    for (const it of all) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ZhixingStore.putString('items', ZhixingStore.joinItems(next))
    ZhixingStore.notifyChanged()
  }

  static async search(keyword: string): Promise<KnowledgeItem[]> {
    const q = keyword.trim()
    const all = await ZhixingStore.loadItems()
    if (q.length === 0) {
      return all
    }
    const out: KnowledgeItem[] = []
    for (const it of all) {
      const blob = `${it.title} ${it.summary} ${it.body} ${it.tags} ${it.source}`
      if (blob.indexOf(q) >= 0) {
        out.push(it)
      }
    }
    return out
  }

  static async loadPlans(): Promise<StudyPlan[]> {
    return ZhixingStore.parsePlans(await ZhixingStore.getString('plans', ''))
  }

  static async findPlan(id: string): Promise<StudyPlan | undefined> {
    const all = await ZhixingStore.loadPlans()
    for (const it of all) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async savePlan(item: StudyPlan): Promise<void> {
    if (item.tasks.length > 0 && item.status === 'active') {
      item.syncProgressFromTasks()
    }
    const all = await ZhixingStore.loadPlans()
    const next: StudyPlan[] = []
    let found = false
    for (const it of all) {
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
    next.sort((a: StudyPlan, b: StudyPlan) => b.createTime - a.createTime)
    await ZhixingStore.putString('plans', ZhixingStore.joinPlans(next))
    ZhixingStore.notifyChanged()
  }

  static async deletePlan(id: string): Promise<void> {
    const all = await ZhixingStore.loadPlans()
    const next: StudyPlan[] = []
    for (const it of all) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ZhixingStore.putString('plans', ZhixingStore.joinPlans(next))
    ZhixingStore.notifyChanged()
  }

  static async loadHabits(): Promise<StudyHabit[]> {
    return ZhixingStore.parseHabits(await ZhixingStore.getString('habits', ''))
  }

  static async findHabit(id: string): Promise<StudyHabit | undefined> {
    const all = await ZhixingStore.loadHabits()
    for (const it of all) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async saveHabit(item: StudyHabit): Promise<void> {
    const all = await ZhixingStore.loadHabits()
    const next: StudyHabit[] = []
    let found = false
    for (const it of all) {
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
    await ZhixingStore.putString('habits', ZhixingStore.joinHabits(next))
    ZhixingStore.notifyChanged()
  }

  static async deleteHabit(id: string): Promise<void> {
    const all = await ZhixingStore.loadHabits()
    const next: StudyHabit[] = []
    for (const it of all) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ZhixingStore.putString('habits', ZhixingStore.joinHabits(next))
    ZhixingStore.notifyChanged()
  }

  static async checkHabit(id: string): Promise<boolean> {
    const h = await ZhixingStore.findHabit(id)
    if (h === undefined) {
      return false
    }
    const today = ActionLog.formatDate(Date.now())
    if (h.lastCheckDate === today) {
      return false
    }
    const yest = ActionLog.formatDate(Date.now() - DAY_MS)
    if (h.lastCheckDate === yest) {
      h.streak = h.streak + 1
    } else {
      h.streak = 1
    }
    h.lastCheckDate = today
    h.totalChecks = h.totalChecks + 1
    let exists = false
    for (const d of h.checkDates) {
      if (d === today) {
        exists = true
      }
    }
    if (!exists) {
      h.checkDates.push(today)
      if (h.checkDates.length > 90) {
        h.checkDates = h.checkDates.slice(h.checkDates.length - 90)
      }
    }
    await ZhixingStore.saveHabit(h)
    return true
  }

  static async loadLogs(): Promise<ActionLog[]> {
    return ZhixingStore.parseLogs(await ZhixingStore.getString('logs', ''))
  }

  static async findLog(id: string): Promise<ActionLog | undefined> {
    const all = await ZhixingStore.loadLogs()
    for (const it of all) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async saveLog(item: ActionLog): Promise<void> {
    const all = await ZhixingStore.loadLogs()
    const next: ActionLog[] = []
    let found = false
    for (const it of all) {
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
    next.sort((a: ActionLog, b: ActionLog) => b.createTime - a.createTime)
    await ZhixingStore.putString('logs', ZhixingStore.joinLogs(next))
    ZhixingStore.notifyChanged()
  }

  static async deleteLog(id: string): Promise<void> {
    const all = await ZhixingStore.loadLogs()
    const next: ActionLog[] = []
    for (const it of all) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ZhixingStore.putString('logs', ZhixingStore.joinLogs(next))
    ZhixingStore.notifyChanged()
  }

  static async loadReminder(): Promise<StudyReminder> {
    const raw = await ZhixingStore.getString('reminder', '')
    const r = new StudyReminder()
    if (raw.length === 0) {
      return r
    }
    const p = raw.split('\t')
    r.enabled = p[0] === '1'
    r.hour = ZhixingStore.num(p.length > 1 ? p[1] : '21')
    r.minute = ZhixingStore.num(p.length > 2 ? p[2] : '0')
    r.agentId = ZhixingStore.num(p.length > 3 ? p[3] : '0')
    return r
  }

  static async saveReminder(r: StudyReminder): Promise<void> {
    const en = r.enabled ? '1' : '0'
    await ZhixingStore.putString('reminder', `${en}\t${r.hour}\t${r.minute}\t${r.agentId}`)
  }

  static async loadDark(): Promise<boolean> {
    return (await ZhixingStore.getString('dark', '0')) === '1'
  }

  static async saveDark(on: boolean): Promise<void> {
    await ZhixingStore.putString('dark', on ? '1' : '0')
  }

  static async loadNick(): Promise<string> {
    return await ZhixingStore.getString('nick', '')
  }

  static async saveNick(v: string): Promise<void> {
    await ZhixingStore.putString('nick', v)
  }

  static async loadBio(): Promise<string> {
    return await ZhixingStore.getString('bio', '')
  }

  static async saveBio(v: string): Promise<void> {
    await ZhixingStore.putString('bio', v)
  }

  static async overview(): Promise<OverviewStats> {
    const s = new OverviewStats()
    const items = await ZhixingStore.loadItems()
    for (const it of items) {
      if (it.kind === 'note') {
        s.notes++
      } else if (it.kind === 'digest') {
        s.digests++
      } else {
        s.cards++
      }
      if (it.favorite) {
        s.favorites++
      }
    }
    const plans = await ZhixingStore.loadPlans()
    s.plans = plans.length
    for (const p of plans) {
      if (p.status === 'done') {
        s.donePlans++
      }
    }
    const habits = await ZhixingStore.loadHabits()
    s.habits = habits.length
    let maxStreak = 0
    for (const h of habits) {
      if (h.streak > maxStreak) {
        maxStreak = h.streak
      }
    }
    s.streak = maxStreak
    s.logs = (await ZhixingStore.loadLogs()).length
    return s
  }

  static async planRate(): Promise<number> {
    const plans = await ZhixingStore.loadPlans()
    if (plans.length === 0) {
      return 0
    }
    let sum = 0
    for (const p of plans) {
      sum += p.progress
    }
    return Math.floor(sum / plans.length)
  }

  static async tagCloud(): Promise<TagNode[]> {
    const items = await ZhixingStore.loadItems()
    const names: string[] = []
    const counts: number[] = []
    for (const it of items) {
      const tags = it.tagList()
      for (const t of tags) {
        let idx = -1
        for (let i = 0; i < names.length; i++) {
          if (names[i] === t) {
            idx = i
          }
        }
        if (idx < 0) {
          names.push(t)
          counts.push(1)
        } else {
          counts[idx] = counts[idx] + 1
        }
      }
    }
    const out: TagNode[] = []
    for (let i = 0; i < names.length; i++) {
      const n = new TagNode()
      n.name = names[i]
      n.count = counts[i]
      out.push(n)
    }
    out.sort((a: TagNode, b: TagNode) => b.count - a.count)
    return out
  }

  static async exportAllText(): Promise<string> {
    const lines: string[] = []
    lines.push('知行页导出')
    lines.push('')
    const items = await ZhixingStore.loadItems()
    for (const it of items) {
      lines.push(`【${it.kindLabel()}】${it.title}`)
      lines.push(it.summary)
      lines.push(it.body)
      lines.push(`标签：${it.tags}`)
      lines.push('')
    }
    const plans = await ZhixingStore.loadPlans()
    for (const p of plans) {
      lines.push(`【计划】${p.title} ${p.progress}% ${p.statusLabel()}`)
      lines.push(p.goal)
      lines.push('')
    }
    const logs = await ZhixingStore.loadLogs()
    for (const l of logs) {
      lines.push(`【日志】${l.dateKey} ${l.title}`)
      lines.push(l.body)
      lines.push('')
    }
    return lines.join('\n')
  }

  static timeLabel(ms: number): string {
    const d = new Date(ms)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  private static esc(s: string): string {
    return s.replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/\t/g, '\\t')
  }

  private static unesc(s: string): string {
    return s.replace(/\\n/g, '\n').replace(/\\t/g, '\t').replace(/\\\\/g, '\\')
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

  private static joinItems(list: KnowledgeItem[]): string {
    const lines: string[] = []
    for (const it of list) {
      const fav = it.favorite ? '1' : '0'
      lines.push([
        it.id, it.kind, ZhixingStore.esc(it.title), ZhixingStore.esc(it.summary),
        ZhixingStore.esc(it.body), it.tags, it.coverKey, ZhixingStore.esc(it.source),
        `${it.progress}`, fav, `${it.createTime}`, `${it.updateTime}`, `${it.lastReadAt}`
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseItems(raw: string): KnowledgeItem[] {
    const out: KnowledgeItem[] = []
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
      const it = new KnowledgeItem()
      it.id = p[0]
      it.kind = p[1]
      it.title = ZhixingStore.unesc(p[2])
      it.summary = ZhixingStore.unesc(p[3])
      it.body = ZhixingStore.unesc(p[4])
      if (p.length > 5) {
        it.tags = p[5]
      }
      if (p.length > 6) {
        it.coverKey = p[6]
      }
      if (p.length > 7) {
        it.source = ZhixingStore.unesc(p[7])
      }
      if (p.length > 8) {
        it.progress = ZhixingStore.num(p[8])
      }
      if (p.length > 9) {
        it.favorite = p[9] === '1'
      }
      if (p.length > 10) {
        it.createTime = ZhixingStore.num(p[10])
      }
      if (p.length > 11) {
        it.updateTime = ZhixingStore.num(p[11])
      }
      if (p.length > 12) {
        it.lastReadAt = ZhixingStore.num(p[12])
      }
      out.push(it)
    }
    return out
  }

  private static joinPlans(list: StudyPlan[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push([
        it.id, ZhixingStore.esc(it.title), ZhixingStore.esc(it.goal),
        it.deadline, `${it.progress}`, it.status, `${it.createTime}`,
        it.knowledgeId, ZhixingStore.esc(ZhixingStore.joinTasks(it.tasks))
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static joinTasks(tasks: PlanTask[]): string {
    const parts: string[] = []
    for (const t of tasks) {
      const done = t.done ? '1' : '0'
      parts.push(`${t.id}::${ZhixingStore.esc(t.title)}::${done}`)
    }
    return parts.join('|')
  }

  private static parseTasks(raw: string): PlanTask[] {
    const out: PlanTask[] = []
    if (raw.length === 0) {
      return out
    }
    const parts = raw.split('|')
    for (const seg of parts) {
      if (seg.length === 0) {
        continue
      }
      const p = seg.split('::')
      if (p.length < 2) {
        continue
      }
      const t = new PlanTask()
      t.id = p[0]
      t.title = ZhixingStore.unesc(p[1])
      t.done = p.length > 2 && p[2] === '1'
      out.push(t)
    }
    return out
  }

  private static parsePlans(raw: string): StudyPlan[] {
    const out: StudyPlan[] = []
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
      const it = new StudyPlan()
      it.id = p[0]
      it.title = ZhixingStore.unesc(p[1])
      it.goal = ZhixingStore.unesc(p[2])
      if (p.length > 3) {
        it.deadline = p[3]
      }
      if (p.length > 4) {
        it.progress = ZhixingStore.num(p[4])
      }
      if (p.length > 5) {
        it.status = p[5]
      }
      if (p.length > 6) {
        it.createTime = ZhixingStore.num(p[6])
      }
      if (p.length > 7) {
        it.knowledgeId = p[7]
      }
      if (p.length > 8) {
        it.tasks = ZhixingStore.parseTasks(ZhixingStore.unesc(p[8]))
      }
      out.push(it)
    }
    return out
  }

  private static joinHabits(list: StudyHabit[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push([
        it.id, ZhixingStore.esc(it.title), it.lastCheckDate,
        `${it.totalChecks}`, `${it.streak}`, `${it.createTime}`,
        it.checkDates.join(',')
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseHabits(raw: string): StudyHabit[] {
    const out: StudyHabit[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 2) {
        continue
      }
      const it = new StudyHabit()
      it.id = p[0]
      it.title = ZhixingStore.unesc(p[1])
      if (p.length > 2) {
        it.lastCheckDate = p[2]
      }
      if (p.length > 3) {
        it.totalChecks = ZhixingStore.num(p[3])
      }
      if (p.length > 4) {
        it.streak = ZhixingStore.num(p[4])
      }
      if (p.length > 5) {
        it.createTime = ZhixingStore.num(p[5])
      }
      if (p.length > 6 && p[6].length > 0) {
        const ds = p[6].split(',')
        for (const d of ds) {
          if (d.length > 0) {
            it.checkDates.push(d)
          }
        }
      }
      out.push(it)
    }
    return out
  }

  private static joinLogs(list: ActionLog[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push([
        it.id, ZhixingStore.esc(it.title), ZhixingStore.esc(it.body),
        it.dateKey, it.relatedPlanId, `${it.createTime}`
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseLogs(raw: string): ActionLog[] {
    const out: ActionLog[] = []
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
      const it = new ActionLog()
      it.id = p[0]
      it.title = ZhixingStore.unesc(p[1])
      it.body = ZhixingStore.unesc(p[2])
      if (p.length > 3) {
        it.dateKey = p[3]
      }
      if (p.length > 4) {
        it.relatedPlanId = p[4]
      }
      if (p.length > 5) {
        it.createTime = ZhixingStore.num(p[5])
      }
      out.push(it)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    await ZhixingStore.ensurePref()
    const mem = AppStorage.get<string>(ZhixingStore.memKey(key))
    const memVal = mem !== undefined ? mem : fallback
    if (ZhixingStore.pref === null) {
      return memVal
    }
    try {
      const v = await ZhixingStore.pref.get(key, memVal)
      const text = `${v}`
      if (text.length > 0) {
        AppStorage.setOrCreate(ZhixingStore.memKey(key), text)
      }
      return text
    } catch {
      return memVal
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    AppStorage.setOrCreate(ZhixingStore.memKey(key), value)
    await ZhixingStore.ensurePref()
    if (ZhixingStore.pref === null) {
      return
    }
    try {
      await ZhixingStore.pref.put(key, value)
      await ZhixingStore.pref.flush()
    } catch {
      // keep AppStorage backup
    }
  }
}
