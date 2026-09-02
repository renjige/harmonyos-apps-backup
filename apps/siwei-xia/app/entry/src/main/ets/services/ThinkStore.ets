import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  BreakdownItem,
  DailyItem,
  GrowthStat,
  OpinionItem,
  GoalItem,
  ReviewItem,
  ThemeMapItem,
  ThinkNote
} from '../models/ThinkModels'
import { DateHelper } from './DateHelper'
import { ThoughtStore } from './ThoughtStore'
import { AppContextService } from './AppContextService'
import { GrowthStatHub } from './GrowthStatHub'

const STORE = 'siwei_xia_think_v1'
const KEY_NOTES = 'notes'
const KEY_BREAK = 'breaks'
const KEY_OPINION = 'opinions'
const KEY_DAILY = 'dailies'
const KEY_MAPS = 'maps'
const KEY_GOALS = 'goals'
const KEY_REVIEWS = 'reviews'

export class ThinkStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ThinkStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ThinkStore.pref = null
    }
  }

  static async ensureReady(): Promise<void> {
    if (ThinkStore.pref !== null) {
      return
    }
    const ctx = AppContextService.getContext()
    if (ctx !== null) {
      await ThinkStore.init(ctx)
    }
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}_${Math.floor(Math.random() * 10000)}`
  }

  static dailyPrompt(dateKey: string): string {
    const pool: string[] = [
      '今天学到了什么？',
      '如果重新选择，我会怎么做？',
      '这件事真正卡住我的是什么？',
      '我可以立刻做的最小一步是什么？',
      '哪些假设还没有被验证？',
      '今天哪句话值得留下？',
      '如果给一个月前的自己一个建议，会说什么？'
    ]
    let sum = 0
    for (let i = 0; i < dateKey.length; i++) {
      sum = sum + dateKey.charCodeAt(i)
    }
    return pool[sum % pool.length]
  }

  static async loadNotes(): Promise<ThinkNote[]> {
    return ThinkStore.parseNotes(await ThinkStore.getString(KEY_NOTES, ''))
  }

  static async saveNote(item: ThinkNote): Promise<void> {
    item.updatedAt = Date.now()
    const list = await ThinkStore.loadNotes()
    await ThinkStore.putString(KEY_NOTES, ThinkStore.joinNotes(ThinkStore.upsertNote(list, item)))
    ThinkStore.bump()
  }

  static async removeNote(id: string): Promise<void> {
    const list = await ThinkStore.loadNotes()
    const next: ThinkNote[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ThinkStore.putString(KEY_NOTES, ThinkStore.joinNotes(next))
    ThinkStore.bump()
  }

  static async loadBreaks(): Promise<BreakdownItem[]> {
    return ThinkStore.parseBreaks(await ThinkStore.getString(KEY_BREAK, ''))
  }

  static async saveBreak(item: BreakdownItem): Promise<void> {
    item.updatedAt = Date.now()
    const list = await ThinkStore.loadBreaks()
    await ThinkStore.putString(KEY_BREAK, ThinkStore.joinBreaks(ThinkStore.upsertBreak(list, item)))
    ThinkStore.bump()
  }

  static async removeBreak(id: string): Promise<void> {
    const list = await ThinkStore.loadBreaks()
    const next: BreakdownItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ThinkStore.putString(KEY_BREAK, ThinkStore.joinBreaks(next))
    ThinkStore.bump()
  }

  static async loadOpinions(): Promise<OpinionItem[]> {
    return ThinkStore.parseOpinions(await ThinkStore.getString(KEY_OPINION, ''))
  }

  static async saveOpinion(item: OpinionItem): Promise<void> {
    item.updatedAt = Date.now()
    const list = await ThinkStore.loadOpinions()
    await ThinkStore.putString(KEY_OPINION, ThinkStore.joinOpinions(ThinkStore.upsertOpinion(list, item)))
    ThinkStore.bump()
  }

  static async removeOpinion(id: string): Promise<void> {
    const list = await ThinkStore.loadOpinions()
    const next: OpinionItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ThinkStore.putString(KEY_OPINION, ThinkStore.joinOpinions(next))
    ThinkStore.bump()
  }

  static async loadDailies(): Promise<DailyItem[]> {
    return ThinkStore.parseDailies(await ThinkStore.getString(KEY_DAILY, ''))
  }

  static async saveDaily(item: DailyItem): Promise<void> {
    item.updatedAt = Date.now()
    const list = await ThinkStore.loadDailies()
    await ThinkStore.putString(KEY_DAILY, ThinkStore.joinDailies(ThinkStore.upsertDaily(list, item)))
    ThinkStore.bump()
  }

  static async todayDaily(): Promise<DailyItem> {
    const key = DateHelper.todayKey()
    const list = await ThinkStore.loadDailies()
    for (const it of list) {
      if (it.dateKey === key) {
        return it
      }
    }
    const d = new DailyItem()
    d.id = ThinkStore.newId('dy')
    d.dateKey = key
    d.prompt = ThinkStore.dailyPrompt(key)
    d.createdAt = Date.now()
    d.updatedAt = d.createdAt
    return d
  }

  static async loadMaps(): Promise<ThemeMapItem[]> {
    return ThinkStore.parseMaps(await ThinkStore.getString(KEY_MAPS, ''))
  }

  static async saveMap(item: ThemeMapItem): Promise<void> {
    item.updatedAt = Date.now()
    const list = await ThinkStore.loadMaps()
    await ThinkStore.putString(KEY_MAPS, ThinkStore.joinMaps(ThinkStore.upsertMap(list, item)))
    ThinkStore.bump()
  }

  static async removeMap(id: string): Promise<void> {
    const list = await ThinkStore.loadMaps()
    const next: ThemeMapItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ThinkStore.putString(KEY_MAPS, ThinkStore.joinMaps(next))
    ThinkStore.bump()
  }

  static async growth(): Promise<GrowthStat> {
    await ThinkStore.ensureReady()
    await ThoughtStore.ensureReady()
    const g = new GrowthStat()
    const sparks = await ThoughtStore.loadActive()
    g.sparks = sparks.length
    g.notes = (await ThinkStore.loadNotes()).length
    g.breakdowns = (await ThinkStore.loadBreaks()).length
    g.opinions = (await ThinkStore.loadOpinions()).length
    g.goals = (await ThinkStore.loadGoals()).length
    g.reviews = (await ThinkStore.loadReviews()).length
    const dailies = await ThinkStore.loadDailies()
    g.dailies = dailies.length
    const keys: string[] = []
    for (const d of dailies) {
      if (d.answer.trim().length > 0) {
        keys.push(d.dateKey)
      }
    }
    g.streak = DateHelper.streakFromKeys(keys)
    return g
  }

  static async loadGoals(): Promise<GoalItem[]> {
    return ThinkStore.parseGoals(await ThinkStore.getString(KEY_GOALS, ''))
  }

  static async saveGoal(item: GoalItem): Promise<void> {
    item.updatedAt = Date.now()
    const list = await ThinkStore.loadGoals()
    await ThinkStore.putString(KEY_GOALS, ThinkStore.joinGoals(ThinkStore.upsertGoal(list, item)))
    ThinkStore.bump()
  }

  static async removeGoal(id: string): Promise<void> {
    const list = await ThinkStore.loadGoals()
    const next: GoalItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ThinkStore.putString(KEY_GOALS, ThinkStore.joinGoals(next))
    ThinkStore.bump()
  }

  static async loadReviews(): Promise<ReviewItem[]> {
    return ThinkStore.parseReviews(await ThinkStore.getString(KEY_REVIEWS, ''))
  }

  static async saveReview(item: ReviewItem): Promise<void> {
    item.updatedAt = Date.now()
    const list = await ThinkStore.loadReviews()
    await ThinkStore.putString(KEY_REVIEWS, ThinkStore.joinReviews(ThinkStore.upsertReview(list, item)))
    ThinkStore.bump()
  }

  static async removeReview(id: string): Promise<void> {
    const list = await ThinkStore.loadReviews()
    const next: ReviewItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ThinkStore.putString(KEY_REVIEWS, ThinkStore.joinReviews(next))
    ThinkStore.bump()
  }

  static cloneBreak(src: BreakdownItem): BreakdownItem {
    const it = new BreakdownItem()
    it.id = src.id
    it.question = src.question
    it.current = src.current
    it.causes = src.causes
    it.solutions = src.solutions
    it.createdAt = src.createdAt
    it.updatedAt = src.updatedAt
    return it
  }

  static cloneNote(src: ThinkNote): ThinkNote {
    const it = new ThinkNote()
    it.id = src.id
    it.title = src.title
    it.body = src.body
    it.category = src.category
    it.createdAt = src.createdAt
    it.updatedAt = src.updatedAt
    return it
  }

  static cloneOpinion(src: OpinionItem): OpinionItem {
    const it = new OpinionItem()
    it.id = src.id
    it.title = src.title
    it.viewpoint = src.viewpoint
    it.remark = src.remark
    it.createdAt = src.createdAt
    it.updatedAt = src.updatedAt
    return it
  }

  static cloneGoal(src: GoalItem): GoalItem {
    const it = new GoalItem()
    it.id = src.id
    it.title = src.title
    it.target = src.target
    it.stepsCsv = src.stepsCsv
    it.createdAt = src.createdAt
    it.updatedAt = src.updatedAt
    return it
  }

  static cloneReview(src: ReviewItem): ReviewItem {
    const it = new ReviewItem()
    it.id = src.id
    it.title = src.title
    it.subject = src.subject
    it.beforeText = src.beforeText
    it.afterText = src.afterText
    it.createdAt = src.createdAt
    it.updatedAt = src.updatedAt
    return it
  }

  static async exportText(): Promise<string> {
    const lines: string[] = []
    lines.push('# 思维匣 · 思考档案')
    lines.push('')
    const breaks = await ThinkStore.loadBreaks()
    if (breaks.length > 0) {
      lines.push('## 问题拆解')
      for (const it of breaks) {
        lines.push(`### ${it.question}`)
        lines.push(`当前：${it.current}`)
        lines.push(`原因：${it.causes}`)
        lines.push(`方案：${it.solutions}`)
        lines.push('')
      }
    }
    const notes = await ThinkStore.loadNotes()
    if (notes.length > 0) {
      lines.push('## 思维笔记')
      for (const it of notes) {
        lines.push(`### ${it.title}（${it.category}）`)
        lines.push(it.body)
        lines.push('')
      }
    }
    const ops = await ThinkStore.loadOpinions()
    if (ops.length > 0) {
      lines.push('## 观点卡片')
      for (const it of ops) {
        lines.push(`### ${it.title}`)
        lines.push(it.viewpoint)
        if (it.remark.length > 0) {
          lines.push(`备注：${it.remark}`)
        }
        lines.push('')
      }
    }
    const dailies = await ThinkStore.loadDailies()
    if (dailies.length > 0) {
      lines.push('## 每日思考')
      for (const it of dailies) {
        lines.push(`### ${it.dateKey} ${it.prompt}`)
        lines.push(it.answer)
        lines.push('')
      }
    }
    const goals = await ThinkStore.loadGoals()
    if (goals.length > 0) {
      lines.push('## 目标推演')
      for (const it of goals) {
        lines.push(`### ${it.title}`)
        lines.push(`目标：${it.target}`)
        for (const s of it.steps()) {
          lines.push(`- ${s}`)
        }
        lines.push('')
      }
    }
    const reviews = await ThinkStore.loadReviews()
    if (reviews.length > 0) {
      lines.push('## 思考复盘')
      for (const it of reviews) {
        lines.push(`### ${it.title}`)
        lines.push(`主题：${it.subject}`)
        lines.push(`当时理解：${it.beforeText}`)
        lines.push(`现在理解：${it.afterText}`)
        lines.push('')
      }
    }
    return lines.join('\n')
  }

  static async syncGrowthToAppStorage(): Promise<void> {
    GrowthStatHub.apply(await ThinkStore.growth())
  }

  private static bump(): void {
    const n = AppStorage.get<number>('tbReload') ?? 0
    AppStorage.setOrCreate('tbReload', n + 1)
    void ThinkStore.syncGrowthToAppStorage()
  }

  private static enc(s: string): string {
    return s.split('\\').join('\\\\').split('\n').join('\\n').split('|').join('\\p')
  }

  private static dec(s: string): string {
    return s.split('\\p').join('|').split('\\n').join('\n').split('\\\\').join('\\')
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    await ThinkStore.ensureReady()
    if (ThinkStore.pref === null) {
      return fallback
    }
    try {
      const v = await ThinkStore.pref.get(key, fallback)
      if (typeof v === 'string') {
        return v
      }
      return fallback
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    await ThinkStore.ensureReady()
    if (ThinkStore.pref === null) {
      return
    }
    try {
      await ThinkStore.pref.put(key, value)
      await ThinkStore.pref.flush()
    } catch {
    }
  }

  private static upsertNote(list: ThinkNote[], item: ThinkNote): ThinkNote[] {
    const next: ThinkNote[] = []
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
    return next
  }

  private static upsertBreak(list: BreakdownItem[], item: BreakdownItem): BreakdownItem[] {
    const next: BreakdownItem[] = []
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
    return next
  }

  private static upsertOpinion(list: OpinionItem[], item: OpinionItem): OpinionItem[] {
    const next: OpinionItem[] = []
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
    return next
  }

  private static upsertDaily(list: DailyItem[], item: DailyItem): DailyItem[] {
    const next: DailyItem[] = []
    let found = false
    for (const it of list) {
      if (it.id === item.id || it.dateKey === item.dateKey) {
        next.push(item)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    return next
  }

  private static upsertMap(list: ThemeMapItem[], item: ThemeMapItem): ThemeMapItem[] {
    const next: ThemeMapItem[] = []
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
    return next
  }

  private static joinNotes(list: ThinkNote[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push([it.id, `${it.createdAt}`, `${it.updatedAt}`, ThinkStore.enc(it.category),
        ThinkStore.enc(it.title), ThinkStore.enc(it.body)].join('|'))
    }
    return lines.join('\n')
  }

  private static parseNotes(raw: string): ThinkNote[] {
    const out: ThinkNote[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('|')
      if (p.length < 6) {
        continue
      }
      const it = new ThinkNote()
      it.id = p[0]
      it.createdAt = parseInt(p[1], 10)
      it.updatedAt = parseInt(p[2], 10)
      it.category = ThinkStore.dec(p[3])
      it.title = ThinkStore.dec(p[4])
      it.body = ThinkStore.dec(p.slice(5).join('|'))
      out.push(it)
    }
    return out
  }

  private static joinBreaks(list: BreakdownItem[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push([it.id, `${it.createdAt}`, `${it.updatedAt}`, ThinkStore.enc(it.question),
        ThinkStore.enc(it.current), ThinkStore.enc(it.causes), ThinkStore.enc(it.solutions)].join('|'))
    }
    return lines.join('\n')
  }

  private static parseBreaks(raw: string): BreakdownItem[] {
    const out: BreakdownItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('|')
      if (p.length < 7) {
        continue
      }
      const it = new BreakdownItem()
      it.id = p[0]
      it.createdAt = parseInt(p[1], 10)
      it.updatedAt = parseInt(p[2], 10)
      it.question = ThinkStore.dec(p[3])
      it.current = ThinkStore.dec(p[4])
      it.causes = ThinkStore.dec(p[5])
      it.solutions = ThinkStore.dec(p.slice(6).join('|'))
      out.push(it)
    }
    return out
  }

  private static joinOpinions(list: OpinionItem[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push([it.id, `${it.createdAt}`, `${it.updatedAt}`, ThinkStore.enc(it.title),
        ThinkStore.enc(it.viewpoint), ThinkStore.enc(it.remark)].join('|'))
    }
    return lines.join('\n')
  }

  private static parseOpinions(raw: string): OpinionItem[] {
    const out: OpinionItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('|')
      if (p.length < 6) {
        continue
      }
      const it = new OpinionItem()
      it.id = p[0]
      it.createdAt = parseInt(p[1], 10)
      it.updatedAt = parseInt(p[2], 10)
      it.title = ThinkStore.dec(p[3])
      it.viewpoint = ThinkStore.dec(p[4])
      it.remark = ThinkStore.dec(p.slice(5).join('|'))
      out.push(it)
    }
    return out
  }

  private static joinDailies(list: DailyItem[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push([it.id, `${it.createdAt}`, `${it.updatedAt}`, ThinkStore.enc(it.dateKey),
        ThinkStore.enc(it.prompt), ThinkStore.enc(it.answer)].join('|'))
    }
    return lines.join('\n')
  }

  private static parseDailies(raw: string): DailyItem[] {
    const out: DailyItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('|')
      if (p.length < 6) {
        continue
      }
      const it = new DailyItem()
      it.id = p[0]
      it.createdAt = parseInt(p[1], 10)
      it.updatedAt = parseInt(p[2], 10)
      it.dateKey = ThinkStore.dec(p[3])
      it.prompt = ThinkStore.dec(p[4])
      it.answer = ThinkStore.dec(p.slice(5).join('|'))
      out.push(it)
    }
    return out
  }

  private static joinMaps(list: ThemeMapItem[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push([it.id, `${it.createdAt}`, `${it.updatedAt}`, ThinkStore.enc(it.title),
        ThinkStore.enc(it.center), ThinkStore.enc(it.branchesCsv)].join('|'))
    }
    return lines.join('\n')
  }

  private static parseMaps(raw: string): ThemeMapItem[] {
    const out: ThemeMapItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('|')
      if (p.length < 6) {
        continue
      }
      const it = new ThemeMapItem()
      it.id = p[0]
      it.createdAt = parseInt(p[1], 10)
      it.updatedAt = parseInt(p[2], 10)
      it.title = ThinkStore.dec(p[3])
      it.center = ThinkStore.dec(p[4])
      it.branchesCsv = ThinkStore.dec(p.slice(5).join('|'))
      out.push(it)
    }
    return out
  }

  private static upsertGoal(list: GoalItem[], item: GoalItem): GoalItem[] {
    const next: GoalItem[] = []
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
    return next
  }

  private static upsertReview(list: ReviewItem[], item: ReviewItem): ReviewItem[] {
    const next: ReviewItem[] = []
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
    return next
  }

  private static joinGoals(list: GoalItem[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push([it.id, `${it.createdAt}`, `${it.updatedAt}`, ThinkStore.enc(it.title),
        ThinkStore.enc(it.target), ThinkStore.enc(it.stepsCsv)].join('|'))
    }
    return lines.join('\n')
  }

  private static parseGoals(raw: string): GoalItem[] {
    const out: GoalItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('|')
      if (p.length < 6) {
        continue
      }
      const it = new GoalItem()
      it.id = p[0]
      it.createdAt = parseInt(p[1], 10)
      it.updatedAt = parseInt(p[2], 10)
      it.title = ThinkStore.dec(p[3])
      it.target = ThinkStore.dec(p[4])
      it.stepsCsv = ThinkStore.dec(p.slice(5).join('|'))
      out.push(it)
    }
    return out
  }

  private static joinReviews(list: ReviewItem[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push([it.id, `${it.createdAt}`, `${it.updatedAt}`, ThinkStore.enc(it.title),
        ThinkStore.enc(it.subject), ThinkStore.enc(it.beforeText), ThinkStore.enc(it.afterText)].join('|'))
    }
    return lines.join('\n')
  }

  private static parseReviews(raw: string): ReviewItem[] {
    const out: ReviewItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('|')
      if (p.length < 7) {
        continue
      }
      const it = new ReviewItem()
      it.id = p[0]
      it.createdAt = parseInt(p[1], 10)
      it.updatedAt = parseInt(p[2], 10)
      it.title = ThinkStore.dec(p[3])
      it.subject = ThinkStore.dec(p[4])
      it.beforeText = ThinkStore.dec(p[5])
      it.afterText = ThinkStore.dec(p.slice(6).join('|'))
      out.push(it)
    }
    return out
  }
}
