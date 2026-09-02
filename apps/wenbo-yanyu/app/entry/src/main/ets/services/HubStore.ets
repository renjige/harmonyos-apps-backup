import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  AchievementDef,
  AchievementUnlock,
  ActivityEvent,
  HubDashboard,
  Manuscript,
  WeekReview,
  WritingGoal
} from '../models/HubModels'
import { FavoriteStore } from './FavoriteStore'
import { LocalRecordStore } from './LocalRecordStore'
import { ResearchStore } from './ResearchStore'
import { AppRefresh } from './AppRefresh'
import { AppStoreContext } from './AppStoreContext'

const STORE = 'yanyu_hub'
const KEY_MS = 'manuscripts'
const KEY_ACT = 'activities'
const KEY_GOAL = 'goal_week'
const KEY_ACH = 'achievements'
const ACT_MAX = 40

export class HubStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.Context): Promise<void> {
    AppStoreContext.bind(context)
    if (HubStore.pref !== null) {
      return
    }
    HubStore.pref = await preferences.getPreferences(context, STORE)
  }

  static async ensureReady(): Promise<boolean> {
    if (HubStore.pref !== null) {
      return true
    }
    const ctx = AppStoreContext.get()
    if (ctx === null) {
      return false
    }
    try {
      HubStore.pref = await preferences.getPreferences(ctx, STORE)
      return HubStore.pref !== null
    } catch {
      return false
    }
  }

  static weekKey(): string {
    const d = new Date()
    const day = d.getDay()
    const diff = day === 0 ? -6 : 1 - day
    const mon = new Date(d.getTime())
    mon.setDate(d.getDate() + diff)
    const y = mon.getFullYear()
    const m = mon.getMonth() + 1
    const dd = mon.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = dd < 10 ? `0${dd}` : `${dd}`
    return `${y}-${ms}-${ds}`
  }

  static bump(): void {
    AppRefresh.bumpResearch()
  }

  static achievementDefs(): AchievementDef[] {
    return [
      AchievementDef.of('first_polish', '初次润色', '完成第一次智慧润色并保存'),
      AchievementDef.of('polish_10', '表达达人', '累计润色保存 10 次'),
      AchievementDef.of('first_note', '研究起步', '写下第一条研究笔记'),
      AchievementDef.of('note_10', '笔记十篇', '研究笔记达到 10 条'),
      AchievementDef.of('streak_7', '连续思考', '每日思考连续 7 天'),
      AchievementDef.of('first_ms', '稿本归档', '保存第一份稿本'),
      AchievementDef.of('fav_5', '收藏达人', '收藏 5 条表达范例'),
      AchievementDef.of('plan_done', '计划推进', '完成一项研究计划阶段')
    ]
  }

  static async listManuscripts(): Promise<Manuscript[]> {
    return HubStore.parseMs(await HubStore.get(KEY_MS))
  }

  static async findManuscript(id: string): Promise<Manuscript | undefined> {
    const list = await HubStore.listManuscripts()
    for (const m of list) {
      if (m.id === id) {
        return m
      }
    }
    return undefined
  }

  static async saveManuscript(row: Manuscript): Promise<void> {
    row.updatedAt = Date.now()
    const list = await HubStore.listManuscripts()
    const next: Manuscript[] = []
    let found = false
    for (const m of list) {
      if (m.id === row.id) {
        next.push(row)
        found = true
      } else {
        next.push(m)
      }
    }
    if (!found) {
      next.unshift(row)
    }
    await HubStore.put(KEY_MS, HubStore.serializeMs(next))
    await HubStore.appendActivity(ActivityEvent.of('manuscript', row.title.length > 0 ? row.title : '稿本',
      row.kind === 'summary' ? '摘要稿本' : '润色稿本', row.id))
    HubStore.bump()
  }

  static async deleteManuscript(id: string): Promise<void> {
    const list = await HubStore.listManuscripts()
    const next: Manuscript[] = []
    for (const m of list) {
      if (m.id !== id) {
        next.push(m)
      }
    }
    await HubStore.put(KEY_MS, HubStore.serializeMs(next))
    HubStore.bump()
  }

  static async listActivities(): Promise<ActivityEvent[]> {
    return HubStore.parseAct(await HubStore.get(KEY_ACT))
  }

  private static countActivityKind(acts: ActivityEvent[], kind: string): number {
    let count = 0
    for (const row of acts) {
      if (row.kind === kind) {
        count += 1
      }
    }
    return count
  }

  private static countManuscriptKind(list: Manuscript[], kind: string): number {
    let count = 0
    for (const row of list) {
      if (row.kind === kind) {
        count += 1
      }
    }
    return count
  }

  private static maxCount(values: number[]): number {
    let max = 0
    for (const v of values) {
      if (v > max) {
        max = v
      }
    }
    return max
  }

  static async appendActivity(event: ActivityEvent): Promise<void> {
    const ready = await HubStore.ensureReady()
    if (!ready) {
      return
    }
    const list = await HubStore.listActivities()
    const next: ActivityEvent[] = [event]
    let i = 0
    for (const e of list) {
      if (i < ACT_MAX - 1) {
        next.push(e)
        i += 1
      }
    }
    await HubStore.put(KEY_ACT, HubStore.serializeAct(next))
  }

  static async recordPolish(styleLabel: string): Promise<void> {
    await HubStore.appendActivity(ActivityEvent.of('polish', '智慧润色', styleLabel, ''))
    await HubStore.bumpGoalPolish()
    HubStore.bump()
  }

  static async recordSummary(modeLabel: string): Promise<void> {
    await HubStore.appendActivity(ActivityEvent.of('summary', '智能摘要', modeLabel, ''))
    HubStore.bump()
  }

  static async recordNote(title: string, id: string): Promise<void> {
    await HubStore.appendActivity(ActivityEvent.of('note', title.length > 0 ? title : '研究笔记', '新建或更新笔记', id))
    await HubStore.bumpGoalNote()
    HubStore.bump()
  }

  static async recordDaily(): Promise<void> {
    await HubStore.appendActivity(ActivityEvent.of('daily', '每日思考', ResearchStore.todayKey(), ''))
    await HubStore.bumpGoalDaily()
    HubStore.bump()
  }

  static async recordSpark(text: string, id: string): Promise<void> {
    const t = text.length > 18 ? `${text.substring(0, 18)}…` : text
    await HubStore.appendActivity(ActivityEvent.of('spark', '灵感快记', t, id))
    HubStore.bump()
  }

  static async recordFavorite(title: string, id: string): Promise<void> {
    await HubStore.appendActivity(ActivityEvent.of('favorite', '收藏范例', title, id))
    HubStore.bump()
  }

  static async recordPlan(title: string): Promise<void> {
    await HubStore.appendActivity(ActivityEvent.of('plan', '计划推进', title, ''))
    HubStore.bump()
  }

  static async currentGoal(): Promise<WritingGoal> {
    const wk = HubStore.weekKey()
    const raw = await HubStore.get(KEY_GOAL)
    return WritingGoal.fromStored(raw, wk)
  }

  private static async saveGoal(goal: WritingGoal): Promise<void> {
    await HubStore.put(KEY_GOAL, JSON.stringify(goal))
  }

  private static async bumpGoalPolish(): Promise<void> {
    const g = await HubStore.currentGoal()
    g.polishDone += 1
    await HubStore.saveGoal(g)
  }

  private static async bumpGoalNote(): Promise<void> {
    const g = await HubStore.currentGoal()
    g.noteDone += 1
    await HubStore.saveGoal(g)
  }

  private static async bumpGoalDaily(): Promise<void> {
    const g = await HubStore.currentGoal()
    g.dailyDone += 1
    await HubStore.saveGoal(g)
  }

  static async listAchievements(): Promise<AchievementUnlock[]> {
    const raw = await HubStore.get(KEY_ACH)
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as AchievementUnlock[]
      if (Array.isArray(parsed)) {
        return parsed
      }
    } catch {
      return []
    }
    return []
  }

  static async isUnlocked(key: string): Promise<boolean> {
    const list = await HubStore.listAchievements()
    for (const a of list) {
      if (a.key === key) {
        return true
      }
    }
    return false
  }

  static async unlock(key: string): Promise<boolean> {
    if (await HubStore.isUnlocked(key)) {
      return false
    }
    const list = await HubStore.listAchievements()
    const row = new AchievementUnlock()
    row.key = key
    row.unlockedAt = Date.now()
    list.push(row)
    await HubStore.put(KEY_ACH, JSON.stringify(list))
    HubStore.bump()
    return true
  }

  static async checkAchievements(): Promise<void> {
    const rs = await ResearchStore.stats()
    const ls = await LocalRecordStore.stats()
    const ms = await HubStore.listManuscripts()
    const fav = await FavoriteStore.count()
    const acts = await HubStore.listActivities()
    let polishActs = 0
    for (const a of acts) {
      if (a.kind === 'polish') {
        polishActs += 1
      }
    }
    const polishTotal = HubStore.maxCount([ls.polishCount, polishActs])
    if (polishTotal >= 1) {
      await HubStore.unlock('first_polish')
    }
    if (polishTotal >= 10) {
      await HubStore.unlock('polish_10')
    }
    if (rs.noteCount >= 1) {
      await HubStore.unlock('first_note')
    }
    if (rs.noteCount >= 10) {
      await HubStore.unlock('note_10')
    }
    if (rs.streak >= 7) {
      await HubStore.unlock('streak_7')
    }
    if (ms.length >= 1) {
      await HubStore.unlock('first_ms')
    }
    if (fav >= 5) {
      await HubStore.unlock('fav_5')
    }
    const plans = await ResearchStore.listPlans()
    for (const p of plans) {
      if (p.doneA === '1' && p.doneB === '1' && p.doneC === '1' &&
        p.stageA.length + p.stageB.length + p.stageC.length > 0) {
        await HubStore.unlock('plan_done')
      }
    }
  }

  static async dashboard(): Promise<HubDashboard> {
    const d = new HubDashboard()
    const rs = await ResearchStore.stats()
    const ls = await LocalRecordStore.stats()
    const ms = await HubStore.listManuscripts()
    const ach = await HubStore.listAchievements()
    d.noteCount = rs.noteCount
    d.manuscriptCount = ms.length
    d.favoriteCount = await FavoriteStore.count()
    d.streakDays = rs.streak
    const acts = await HubStore.listActivities()
    const polishActs = HubStore.countActivityKind(acts, 'polish')
    const summaryActs = HubStore.countActivityKind(acts, 'summary')
    const msPolish = HubStore.countManuscriptKind(ms, 'polish')
    const msSummary = HubStore.countManuscriptKind(ms, 'summary')
    d.polishCount = HubStore.maxCount([ls.polishCount, polishActs, msPolish])
    d.summaryCount = HubStore.maxCount([ls.summaryCount, summaryActs, msSummary])
    d.sparkCount = rs.sparkCount
    d.cardCount = rs.cardCount
    d.readingCount = rs.readingCount
    d.planCount = rs.planCount
    d.topicCount = rs.topicCount
    d.starredNoteCount = await ResearchStore.starredNoteCount()
    d.weekNotes = rs.weekNotes
    d.achievementCount = ach.length
    d.achievementTotal = HubStore.achievementDefs().length
    const weekStart = HubStore.weekStartMs()
    for (const a of acts) {
      if (a.at >= weekStart) {
        if (a.kind === 'polish') {
          d.weekPolish += 1
        }
        if (a.kind === 'summary') {
          d.weekSummary += 1
        }
      }
    }
    const plans = await ResearchStore.listPlans()
    for (const p of plans) {
      d.planTotal += 3
      if (p.doneA === '1') {
        d.planDone += 1
      }
      if (p.doneB === '1') {
        d.planDone += 1
      }
      if (p.doneC === '1') {
        d.planDone += 1
      }
    }
    return d
  }

  static async weekReview(): Promise<WeekReview> {
    const r = new WeekReview()
    r.weekKey = HubStore.weekKey()
    const rs = await ResearchStore.stats()
    r.streak = rs.streak
    r.noteCount = rs.weekNotes
    const acts = await HubStore.listActivities()
    const weekStart = HubStore.weekStartMs()
    for (const a of acts) {
      if (a.at >= weekStart) {
        if (a.kind === 'polish') {
          r.polishCount += 1
        }
        if (a.kind === 'summary') {
          r.summaryCount += 1
        }
        if (a.kind === 'spark') {
          r.sparkCount += 1
        }
        if (a.kind === 'daily') {
          r.dailyCount += 1
        }
      }
    }
    if (r.polishCount + r.noteCount + r.dailyCount === 0) {
      r.highlight = '本周还没有记录，从首页快捷入口开始第一条吧。'
    } else if (r.polishCount >= 5) {
      r.highlight = `本周已完成 ${r.polishCount} 次润色，表达练习节奏不错。`
    } else if (r.noteCount >= 3) {
      r.highlight = `本周新增 ${r.noteCount} 条笔记，研究资料在持续积累。`
    } else {
      r.highlight = `本周润色 ${r.polishCount} 次 · 笔记 ${r.noteCount} 条 · 思考 ${r.dailyCount} 天。`
    }
    return r
  }

  static weekStartMs(): number {
    const parts = HubStore.weekKey().split('-')
    if (parts.length < 3) {
      return Date.now()
    }
    const y = parseInt(parts[0])
    const m = parseInt(parts[1]) - 1
    const day = parseInt(parts[2])
    return new Date(y, m, day, 0, 0, 0).getTime()
  }

  static activityLabel(kind: string): string {
    if (kind === 'polish') {
      return '润色'
    }
    if (kind === 'summary') {
      return '摘要'
    }
    if (kind === 'note') {
      return '笔记'
    }
    if (kind === 'daily') {
      return '思考'
    }
    if (kind === 'spark') {
      return '灵感'
    }
    if (kind === 'favorite') {
      return '收藏'
    }
    if (kind === 'manuscript') {
      return '稿本'
    }
    if (kind === 'plan') {
      return '计划'
    }
    return '动态'
  }

  static timeShort(at: number): string {
    const d = new Date(at)
    const h = d.getHours()
    const min = d.getMinutes()
    const hs = h < 10 ? `0${h}` : `${h}`
    const mins = min < 10 ? `0${min}` : `${min}`
    return `${hs}:${mins}`
  }

  private static async get(key: string): Promise<string> {
    const ready = await HubStore.ensureReady()
    if (!ready || HubStore.pref === null) {
      return ''
    }
    return await HubStore.pref.get(key, '') as string
  }

  private static async put(key: string, value: string): Promise<void> {
    const ready = await HubStore.ensureReady()
    if (!ready || HubStore.pref === null) {
      return
    }
    await HubStore.pref.put(key, value)
    await HubStore.pref.flush()
  }

  private static parseMs(raw: string): Manuscript[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as Manuscript[]
      if (Array.isArray(parsed)) {
        return parsed
      }
    } catch {
      return []
    }
    return []
  }

  private static serializeMs(list: Manuscript[]): string {
    return JSON.stringify(list)
  }

  private static parseAct(raw: string): ActivityEvent[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as ActivityEvent[]
      if (Array.isArray(parsed)) {
        return parsed
      }
    } catch {
      return []
    }
    return []
  }

  private static serializeAct(list: ActivityEvent[]): string {
    return JSON.stringify(list)
  }
}
