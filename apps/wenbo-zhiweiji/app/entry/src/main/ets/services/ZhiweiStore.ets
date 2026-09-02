import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  CaptureItem,
  CaptureStats,
  CategoryCount,
  DayChip,
  InsightDigest,
  KnowledgeFolder,
  LearnPlan,
  ReviewSummary,
  TimelineEvent,
  TodayProgress,
  AchievementItem,
  ZhiweiBundle,
  ZhiweiSettings
} from '../models/ZhiweiModels'
import { InsightEngine } from './InsightEngine'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'
import { AchievementCatalog } from './AchievementCatalog'

const STORE = 'zhiwei_local'
const KEY_BUNDLE = 'bundle'
const KEY_REV = 'zwRev'

export class ZhiweiStore {
  private static pref: preferences.Preferences | null = null
  private static cache: ZhiweiBundle = new ZhiweiBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ZhiweiStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await ZhiweiStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      ZhiweiStore.cache = ZhiweiStore.parseBundle(raw)
      const seeded = ZhiweiStore.ensureDefaultFolders()
      ZhiweiStore.ensureDefaultPlan()
      if (seeded) {
        await ZhiweiStore.persist(ZhiweiStore.cache)
      }
    } catch {
      ZhiweiStore.cache = new ZhiweiBundle()
      ZhiweiStore.ensureDefaultFolders()
      try {
        await ZhiweiStore.persist(ZhiweiStore.cache)
      } catch {
      }
    }
    const dark = ZhiweiStore.cache.settings.darkMode
    AppStorage.setOrCreate('darkModeOn', dark)
    ZhiweiStore.bump()
  }

  static snapshot(): ZhiweiBundle {
    return ZhiweiStore.cache
  }

  static captures(): CaptureItem[] {
    return ZhiweiStore.cache.captures
  }

  static settings(): ZhiweiSettings {
    return ZhiweiStore.cache.settings
  }

  static favoriteQuoteIds(): string[] {
    return ZhiweiStore.cache.favoriteQuoteIds
  }

  static digests(): InsightDigest[] {
    return ZhiweiStore.cache.digests
  }

  static findCapture(id: string): CaptureItem | null {
    for (const item of ZhiweiStore.cache.captures) {
      if (item.id === id) {
        return item
      }
    }
    return null
  }

  static sortedCaptures(): CaptureItem[] {
    const copy: CaptureItem[] = []
    for (const item of ZhiweiStore.cache.captures) {
      copy.push(item)
    }
    copy.sort((a: CaptureItem, b: CaptureItem): number => {
      return b.updatedAt - a.updatedAt
    })
    return copy
  }

  static searchCaptures(keyword: string, category: string, status: string, learnTag: string): CaptureItem[] {
    const key = keyword.trim()
    const list = ZhiweiStore.sortedCaptures()
    const out: CaptureItem[] = []
    const cat = category.length > 0 ? CategoryEmojiUtil.normalize(category) : ''
    for (const item of list) {
      if (cat.length > 0 && CategoryEmojiUtil.normalize(item.category) !== cat) {
        continue
      }
      if (status.length > 0 && item.status !== status) {
        continue
      }
      if (learnTag.length > 0 && item.learnTag !== learnTag) {
        continue
      }
      if (key.length > 0) {
        const blob = `${item.title}${item.body}${item.customTag}${CategoryEmojiUtil.learnLabel(item.learnTag)}`
        if (blob.indexOf(key) < 0) {
          continue
        }
      }
      out.push(item)
    }
    return out
  }

  static isFavorite(quoteId: string): boolean {
    for (const id of ZhiweiStore.cache.favoriteQuoteIds) {
      if (id === quoteId) {
        return true
      }
    }
    return false
  }

  static stats(): CaptureStats {
    const out = new CaptureStats()
    out.total = ZhiweiStore.cache.captures.length
    out.streak = ZhiweiStore.calcStreak()
    out.folderCount = ZhiweiStore.cache.folders.length
    out.learnDays = ZhiweiStore.cache.settings.learnDays
    for (const item of ZhiweiStore.cache.captures) {
      if (item.favored) {
        out.favCount += 1
      }
      if (item.learnTag === 'mastered') {
        out.masteredCount += 1
      }
      if (item.status === 'done') {
        out.digestDoneCount += 1
      }
      const cat = CategoryEmojiUtil.normalize(item.category)
      if (cat === 'work_tip') {
        out.workCount += 1
      } else if (cat === 'life_wiki') {
        out.lifeCount += 1
      } else if (cat === 'growth') {
        out.studyCount += 1
      } else {
        out.sparkCount += 1
      }
    }
    out.cats = ZhiweiStore.categoryRows(ZhiweiStore.cache.captures)
    return out
  }

  static searchCapturesWithTime(keyword: string, category: string, status: string, learnTag: string,
    days: number): CaptureItem[] {
    const base = ZhiweiStore.searchCaptures(keyword, category, status, learnTag)
    if (days <= 0) {
      return base
    }
    const keys = InsightEngine.lastDaysFromNow(days)
    const out: CaptureItem[] = []
    for (const item of base) {
      const k = InsightEngine.dateOf(InsightEngine.stampOf(item))
      for (const d of keys) {
        if (d === k) {
          out.push(item)
          break
        }
      }
    }
    return out
  }

  static todayProgress(): TodayProgress {
    const p = new TodayProgress()
    const s = ZhiweiStore.cache.settings
    p.goalCount = s.dailyGoalCount > 0 ? s.dailyGoalCount : 1
    const today = ZhiweiStore.today()
    p.captureToday = ZhiweiStore.capturesOnDate(today).length
    p.dailyRead = s.lastLearnDate === today && s.readDailyId.length > 0
    let digestToday = 0
    for (const it of ZhiweiStore.cache.captures) {
      if (it.status === 'done' && InsightEngine.dateOf(InsightEngine.stampOf(it)) === today) {
        digestToday += 1
      }
    }
    p.digestDoneToday = digestToday
    let inbox = 0
    for (const it of ZhiweiStore.cache.captures) {
      if (it.status === 'inbox') {
        inbox += 1
      }
    }
    p.inboxCount = inbox
    let done = 0
    if (p.captureToday >= p.goalCount) {
      done += 1
    }
    if (p.dailyRead) {
      done += 1
    }
    const goalUnits = p.goalCount + 1
    p.percent = Math.min(100, Math.floor(done * 100 / goalUnits))
    if (p.captureToday === 0 && !p.dailyRead) {
      p.hint = '记一条微知识或阅读每日一知，开启今日进度'
    } else if (p.inboxCount > 0) {
      p.hint = `还有 ${p.inboxCount} 条待消化，点进详情可标记已掌握`
    } else {
      p.hint = '今日进度不错，去成长页看看统计与回顾'
    }
    return p
  }

  static timelineEvents(limit: number): TimelineEvent[] {
    const events: TimelineEvent[] = []
    for (const it of ZhiweiStore.sortedCaptures()) {
      const created = new TimelineEvent()
      created.id = `tl_new_${it.id}`
      created.type = 'capture'
      created.refId = it.id
      created.title = it.title.length > 0 ? it.title : it.body.substring(0, 20)
      created.subtitle = `新建 · ${CategoryEmojiUtil.nameOf(it.category)}`
      created.ts = it.createdAt
      events.push(created)
      if (it.status === 'done') {
        const dig = new TimelineEvent()
        dig.id = `tl_done_${it.id}`
        dig.type = 'digest'
        dig.refId = it.id
        dig.title = it.title.length > 0 ? it.title : '微知识'
        dig.subtitle = '已消化'
        dig.ts = it.updatedAt > it.createdAt ? it.updatedAt : it.createdAt
        events.push(dig)
      }
      if (it.favored) {
        const fav = new TimelineEvent()
        fav.id = `tl_fav_${it.id}`
        fav.type = 'fav'
        fav.refId = it.id
        fav.title = it.title.length > 0 ? it.title : '收藏条目'
        fav.subtitle = '加入收藏夹'
        fav.ts = it.updatedAt
        events.push(fav)
      }
      if (it.source === 'daily') {
        const daily = new TimelineEvent()
        daily.id = `tl_daily_${it.id}`
        daily.type = 'daily'
        daily.refId = it.id
        daily.title = it.title
        daily.subtitle = '来自每日一知'
        daily.ts = it.createdAt
        events.push(daily)
      }
    }
    events.sort((a: TimelineEvent, b: TimelineEvent): number => b.ts - a.ts)
    const out: TimelineEvent[] = []
    let i = 0
    for (const e of events) {
      if (i >= limit) {
        break
      }
      out.push(e)
      i += 1
    }
    return out
  }

  static plans(): LearnPlan[] {
    return ZhiweiStore.cache.plans
  }

  static activePlan(): LearnPlan | null {
    for (const p of ZhiweiStore.cache.plans) {
      if (p.status === 'active') {
        return p
      }
    }
    return null
  }

  static planProgress(plan: LearnPlan): number {
    let n = 0
    const keys = InsightEngine.lastDaysFromNow(plan.period === 'month' ? 30 : 7)
    for (const it of ZhiweiStore.cache.captures) {
      const k = InsightEngine.dateOf(InsightEngine.stampOf(it))
      let inRange = false
      for (const d of keys) {
        if (d === k) {
          inRange = true
          break
        }
      }
      if (!inRange) {
        continue
      }
      if (plan.metric === 'capture') {
        n += 1
      } else if (plan.metric === 'digest_done' && it.status === 'done') {
        n += 1
      }
    }
    return n
  }

  static async savePlan(plan: LearnPlan): Promise<boolean> {
    try {
      const next = ZhiweiStore.cloneBundle()
      const list: LearnPlan[] = []
      let found = false
      for (const row of next.plans) {
        if (row.id === plan.id) {
          list.push(plan)
          found = true
        } else {
          list.push(row)
        }
      }
      if (!found) {
        list.push(plan)
      }
      next.plans = list
      await ZhiweiStore.persist(next)
      await ZhiweiStore.checkAchievements()
      return true
    } catch {
      return false
    }
  }

  static reviewSummary(period: string): ReviewSummary {
    const out = new ReviewSummary()
    out.period = period
    const days = period === 'month' ? 30 : 7
    const keys = InsightEngine.lastDaysFromNow(days)
    const items: CaptureItem[] = []
    for (const it of ZhiweiStore.cache.captures) {
      const k = InsightEngine.dateOf(InsightEngine.stampOf(it))
      for (const d of keys) {
        if (d === k) {
          items.push(it)
          break
        }
      }
    }
    out.captureCount = items.length
    let digest = 0
    let fav = 0
    const hl: string[] = []
    for (const it of items) {
      if (it.status === 'done') {
        digest += 1
      }
      if (it.favored) {
        fav += 1
      }
      if (hl.length < 3) {
        hl.push(it.title.length > 0 ? it.title : it.body.substring(0, 16))
      }
    }
    out.digestCount = digest
    out.favCount = fav
    out.highlights = hl
    out.title = period === 'month' ? '本月回顾' : '本周回顾'
    if (items.length === 0) {
      out.summary = '这一段时间还没有微知识记录。从工作台记一条，或阅读每日一知开始。'
    } else {
      const cats = ZhiweiStore.categoryRows(items)
      const parts: string[] = []
      for (const c of cats) {
        if (c.count > 0) {
          parts.push(`${c.name}${c.count}`)
        }
      }
      out.summary = `${out.title}共新增 ${items.length} 条，消化 ${digest} 条，收藏 ${fav} 条。${parts.join('、')}。`
    }
    return out
  }

  static achievements(): AchievementItem[] {
    const defs = AchievementCatalog.all()
    const unlocked = ZhiweiStore.cache.settings.unlockedAchIds
    const out: AchievementItem[] = []
    for (const d of defs) {
      const row = new AchievementItem()
      row.id = d.id
      row.title = d.title
      row.desc = d.desc
      row.unlocked = ZhiweiStore.hasAch(unlocked, d.id)
      out.push(row)
    }
    return out
  }

  static async checkAchievements(): Promise<string[]> {
    const st = ZhiweiStore.stats()
    const newly: string[] = []
    const tryUnlock = (id: string, ok: boolean): void => {
      if (ok && !ZhiweiStore.hasAch(ZhiweiStore.cache.settings.unlockedAchIds, id)) {
        newly.push(id)
      }
    }
    tryUnlock('ach_first', st.total >= 1)
    tryUnlock('ach_cap10', st.total >= 10)
    tryUnlock('ach_cap50', st.total >= 50)
    tryUnlock('ach_streak7', st.streak >= 7)
    tryUnlock('ach_learn7', st.learnDays >= 7)
    tryUnlock('ach_master10', st.masteredCount >= 10)
    tryUnlock('ach_fav5', st.favCount >= 5)
    tryUnlock('ach_folder3', st.folderCount >= 3)
    tryUnlock('ach_digest5', st.digestDoneCount >= 5)
    const plan = ZhiweiStore.activePlan()
    if (plan !== null) {
      tryUnlock('ach_plan_done', ZhiweiStore.planProgress(plan) >= plan.targetCount)
    }
    if (newly.length === 0) {
      return newly
    }
    try {
      const next = ZhiweiStore.cloneBundle()
      const ids: string[] = []
      for (const id of next.settings.unlockedAchIds) {
        ids.push(id)
      }
      for (const id of newly) {
        if (!ZhiweiStore.hasAch(ids, id)) {
          ids.push(id)
        }
      }
      next.settings.unlockedAchIds = ids
      await ZhiweiStore.persist(next)
    } catch {
    }
    return newly
  }

  static pendingInbox(limit: number): CaptureItem[] {
    const out: CaptureItem[] = []
    for (const it of ZhiweiStore.sortedCaptures()) {
      if (it.status === 'inbox' || it.status === 'follow') {
        out.push(it)
      }
      if (out.length >= limit) {
        break
      }
    }
    return out
  }

  static pathStepsDone(): number {
    return ZhiweiStore.cache.settings.completedPathStepIds.length
  }

  static isPathStepDone(stepId: string): boolean {
    for (const id of ZhiweiStore.cache.settings.completedPathStepIds) {
      if (id === stepId) {
        return true
      }
    }
    return false
  }

  static async markPathStepDone(stepId: string): Promise<void> {
    if (ZhiweiStore.isPathStepDone(stepId)) {
      return
    }
    try {
      const next = ZhiweiStore.cloneBundle()
      const ids: string[] = []
      for (const id of next.settings.completedPathStepIds) {
        ids.push(id)
      }
      ids.push(stepId)
      next.settings.completedPathStepIds = ids
      await ZhiweiStore.persist(next)
    } catch {
    }
  }

  static needsTour(): boolean {
    return ZhiweiStore.cache.settings.tourDone !== true
  }

  static async markTourDone(): Promise<void> {
    try {
      const next = ZhiweiStore.cloneBundle()
      next.settings.tourDone = true
      await ZhiweiStore.persist(next)
    } catch {
    }
  }

  static inboxByStatus(status: string): CaptureItem[] {
    const out: CaptureItem[] = []
    for (const it of ZhiweiStore.sortedCaptures()) {
      if (it.status === status) {
        out.push(it)
      }
    }
    return out
  }

  static reviewDueCount(): number {
    return ZhiweiStore.reviewQueue(999).length
  }

  static reviewQueue(limit: number): CaptureItem[] {
    const now = Date.now()
    const out: CaptureItem[] = []
    for (const it of ZhiweiStore.sortedCaptures()) {
      if (it.status === 'done') {
        continue
      }
      if (it.learnTag !== 'todo' && it.learnTag !== 'useful' && it.learnTag !== 'mastered') {
        continue
      }
      if (it.nextReviewAt > 0 && it.nextReviewAt > now) {
        continue
      }
      out.push(it)
      if (out.length >= limit) {
        break
      }
    }
    return out
  }

  static async scheduleReview(id: string, days: number, mastered: boolean): Promise<boolean> {
    const found = ZhiweiStore.findCapture(id)
    if (found === null) {
      return false
    }
    if (mastered) {
      found.learnTag = 'mastered'
      found.nextReviewAt = Date.now() + days * 86400000
    } else {
      found.nextReviewAt = Date.now() + days * 86400000
    }
    found.updatedAt = Date.now()
    return await ZhiweiStore.saveCapture(found)
  }

  static async setNextAction(id: string, action: string): Promise<boolean> {
    const found = ZhiweiStore.findCapture(id)
    if (found === null) {
      return false
    }
    found.nextAction = action.trim()
    found.updatedAt = Date.now()
    return await ZhiweiStore.saveCapture(found)
  }

  static relatedCaptures(id: string, limit: number): CaptureItem[] {
    const self = ZhiweiStore.findCapture(id)
    if (self === null) {
      return []
    }
    const scored: CaptureItem[] = []
    for (const it of ZhiweiStore.cache.captures) {
      if (it.id === id) {
        continue
      }
      let score = 0
      if (CategoryEmojiUtil.normalize(it.category) === CategoryEmojiUtil.normalize(self.category)) {
        score += 2
      }
      if (self.title.length > 0 && it.title.indexOf(self.title.substring(0, 2)) >= 0) {
        score += 1
      }
      if (self.customTag.length > 0 && it.customTag === self.customTag) {
        score += 2
      }
      if (score > 0) {
        scored.push(it)
      }
    }
    const out: CaptureItem[] = []
    let i = 0
    for (const it of scored) {
      if (i >= limit) {
        break
      }
      out.push(it)
      i += 1
    }
    return out
  }

  static async captureFromDailyReflection(title: string, articleBody: string, category: string,
    useWhere: string, counter: string, teach: string): Promise<boolean> {
    const item = new CaptureItem()
    item.id = ZhiweiStore.newId('cap')
    item.title = title.length > 0 ? title : '每日一知笔记'
    item.body = `【原文摘要】\n${articleBody}\n\n【能用在哪】\n${useWhere}\n\n【反例或边界】\n${counter}\n\n【教给别人】\n${teach}`
    item.category = CategoryEmojiUtil.normalize(category)
    item.learnTag = 'todo'
    item.priority = 'mid'
    item.source = 'daily'
    item.status = 'inbox'
    item.nextReviewAt = Date.now() + 86400000
    const now = Date.now()
    item.createdAt = now
    item.updatedAt = now
    return await ZhiweiStore.saveCapture(item)
  }

  static today(): string {
    return InsightEngine.dateOf(Date.now())
  }

  static displayDate(iso: string): string {
    if (iso.length < 10) {
      return iso
    }
    const y = iso.substring(0, 4)
    const m = iso.substring(5, 7)
    const d = iso.substring(8, 10)
    if (iso === ZhiweiStore.today()) {
      return '今天'
    }
    return `${y}年${Number.parseInt(m)}月${Number.parseInt(d)}日`
  }

  static displayTime(ts: number): string {
    const d = new Date(ts)
    const h = d.getHours()
    const m = d.getMinutes()
    const hs = h < 10 ? `0${h}` : `${h}`
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${ZhiweiStore.displayDate(InsightEngine.dateOf(ts))} ${hs}:${ms}`
  }

  static greeting(): string {
    const hour = new Date().getHours()
    if (hour < 6) {
      return '夜深了，把一条细微的念头收进来'
    }
    if (hour < 11) {
      return '早安，从一条收录开始'
    }
    if (hour < 18) {
      return '把此刻的碎片轻轻放下'
    }
    return '晚上好，回顾今天的细微处'
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static async saveCapture(item: CaptureItem): Promise<boolean> {
    try {
      const next = ZhiweiStore.cloneBundle()
      const list: CaptureItem[] = []
      let found = false
      for (const row of next.captures) {
        if (row.id === item.id) {
          list.push(item)
          found = true
        } else {
          list.push(row)
        }
      }
      if (!found) {
        list.push(item)
      }
      next.captures = list
      ZhiweiStore.touchLearnOn(next)
      await ZhiweiStore.persist(next)
      await ZhiweiStore.refreshTodayDigest()
      await ZhiweiStore.checkAchievements()
      return true
    } catch {
      return false
    }
  }

  static async deleteCapture(id: string): Promise<boolean> {
    try {
      const next = ZhiweiStore.cloneBundle()
      const list: CaptureItem[] = []
      for (const row of next.captures) {
        if (row.id !== id) {
          list.push(row)
        }
      }
      next.captures = list
      await ZhiweiStore.persist(next)
      await ZhiweiStore.refreshTodayDigest()
      await ZhiweiStore.checkAchievements()
      return true
    } catch {
      return false
    }
  }

  static async toggleFavorite(quoteId: string): Promise<boolean> {
    try {
      const next = ZhiweiStore.cloneBundle()
      const ids: string[] = []
      let found = false
      for (const id of next.favoriteQuoteIds) {
        if (id === quoteId) {
          found = true
        } else {
          ids.push(id)
        }
      }
      if (!found) {
        ids.push(quoteId)
      }
      next.favoriteQuoteIds = ids
      await ZhiweiStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async saveSettings(settings: ZhiweiSettings): Promise<boolean> {
    try {
      const next = ZhiweiStore.cloneBundle()
      next.settings = settings
      await ZhiweiStore.persist(next)
      AppStorage.setOrCreate('darkModeOn', settings.darkMode)
      return true
    } catch {
      return false
    }
  }

  static async refreshTodayDigest(): Promise<InsightDigest> {
    const digest = InsightEngine.buildDaily(ZhiweiStore.cache.captures, ZhiweiStore.today())
    await ZhiweiStore.upsertDigest(digest)
    return digest
  }

  static async weeklyDigest(): Promise<InsightDigest> {
    let items = InsightEngine.weekItems(ZhiweiStore.cache.captures, ZhiweiStore.today())
    if (items.length === 0 && ZhiweiStore.cache.captures.length > 0) {
      items = ZhiweiStore.cache.captures
      const digest = InsightEngine.buildFrom(items, 'week', ZhiweiStore.today())
      digest.summary = `近七日暂无新笔记。累计已有 ${digest.captureCount} 条微知识，分类分布如下。`
      await ZhiweiStore.upsertDigest(digest)
      return digest
    }
    const digest = InsightEngine.buildFrom(items, 'week', ZhiweiStore.today())
    await ZhiweiStore.upsertDigest(digest)
    return digest
  }

  static weeklyBarItems(): CaptureItem[] {
    const week = ZhiweiStore.weekCaptures()
    if (week.length > 0) {
      return week
    }
    return ZhiweiStore.cache.captures
  }

  static recentDayChips(): DayChip[] {
    const keys = InsightEngine.lastDaysFromNow(7)
    const chips: DayChip[] = []
    for (const k of keys) {
      const chip = new DayChip()
      chip.dateKey = k
      chip.count = InsightEngine.dayItems(ZhiweiStore.cache.captures, k).length
      const md = k.length >= 10 ? k.substring(5) : k
      chip.label = k === ZhiweiStore.today() ? '今' : md
      chips.push(chip)
    }
    return chips
  }

  static todayDigest(): InsightDigest {
    return InsightEngine.buildDaily(ZhiweiStore.cache.captures, ZhiweiStore.today())
  }

  static weekCaptures(): CaptureItem[] {
    return InsightEngine.weekItems(ZhiweiStore.cache.captures, ZhiweiStore.today())
  }

  static weekCapturesByCategory(category: string): CaptureItem[] {
    const all = ZhiweiStore.weekCaptures()
    if (category.length === 0) {
      return all
    }
    const out: CaptureItem[] = []
    for (const it of all) {
      if (CategoryEmojiUtil.normalize(it.category) === CategoryEmojiUtil.normalize(category)) {
        out.push(it)
      }
    }
    return out
  }

  static capturesOnDate(dateKey: string): CaptureItem[] {
    return InsightEngine.dayItems(ZhiweiStore.cache.captures, dateKey)
  }

  static capturesWithKeyword(keyword: string): CaptureItem[] {
    return InsightEngine.searchText(ZhiweiStore.sortedCaptures(), keyword)
  }

  static inboxHigh(): CaptureItem[] {
    const out: CaptureItem[] = []
    const list = ZhiweiStore.sortedCaptures()
    for (const it of list) {
      if (it.priority === 'high' && it.status !== 'done') {
        out.push(it)
      }
    }
    return out
  }

  static focusItems(kind: string, key: string): CaptureItem[] {
    if (kind === 'weekCat') {
      const week = ZhiweiStore.weekCapturesByCategory(key)
      if (week.length > 0) {
        return week
      }
      return ZhiweiStore.capturesByCategory(key)
    }
    if (kind === 'weekAll') {
      const week = ZhiweiStore.weekCaptures()
      if (week.length > 0) {
        return week
      }
      return ZhiweiStore.sortedCaptures()
    }
    if (kind === 'day') {
      return ZhiweiStore.capturesOnDate(key)
    }
    if (kind === 'keyword') {
      return ZhiweiStore.capturesWithKeyword(key)
    }
    if (kind === 'inboxHigh') {
      return ZhiweiStore.inboxHigh()
    }
    if (kind === 'folder') {
      return ZhiweiStore.capturesInFolder(key)
    }
    if (kind === 'fav') {
      return ZhiweiStore.favoredCaptures()
    }
    if (kind === 'tag') {
      return ZhiweiStore.capturesByLearnTag(key)
    }
    if (kind === 'allCat') {
      return ZhiweiStore.capturesByCategory(key)
    }
    return []
  }

  static capturesByCategory(category: string): CaptureItem[] {
    const out: CaptureItem[] = []
    const cat = CategoryEmojiUtil.normalize(category)
    for (const it of ZhiweiStore.sortedCaptures()) {
      if (CategoryEmojiUtil.normalize(it.category) === cat) {
        out.push(it)
      }
    }
    return out
  }

  static capturesInFolder(folderId: string): CaptureItem[] {
    const out: CaptureItem[] = []
    for (const it of ZhiweiStore.sortedCaptures()) {
      if (it.collectionId === folderId) {
        out.push(it)
      }
    }
    return out
  }

  static favoredCaptures(): CaptureItem[] {
    const out: CaptureItem[] = []
    for (const it of ZhiweiStore.sortedCaptures()) {
      if (it.favored) {
        out.push(it)
      }
    }
    return out
  }

  static capturesByLearnTag(tag: string): CaptureItem[] {
    const out: CaptureItem[] = []
    for (const it of ZhiweiStore.sortedCaptures()) {
      if (it.learnTag === tag) {
        out.push(it)
      }
    }
    return out
  }

  static folders(): KnowledgeFolder[] {
    return ZhiweiStore.cache.folders
  }

  static findFolder(id: string): KnowledgeFolder | null {
    for (const f of ZhiweiStore.cache.folders) {
      if (f.id === id) {
        return f
      }
    }
    return null
  }

  static categoryRows(items: CaptureItem[]): CategoryCount[] {
    const ids = CategoryEmojiUtil.allIds()
    const rows: CategoryCount[] = []
    for (const id of ids) {
      let n = 0
      for (const it of items) {
        if (CategoryEmojiUtil.normalize(it.category) === id) {
          n += 1
        }
      }
      rows.push(ZhiweiStore.cat(id, CategoryEmojiUtil.nameOf(id), n))
    }
    return rows
  }

  static async setStatus(id: string, status: string): Promise<boolean> {
    const found = ZhiweiStore.findCapture(id)
    if (found === null) {
      return false
    }
    found.status = status
    found.updatedAt = Date.now()
    return await ZhiweiStore.saveCapture(found)
  }

  static async captureFromQuote(title: string, body: string, author: string): Promise<boolean> {
    const item = new CaptureItem()
    item.id = ZhiweiStore.newId('cap')
    item.title = title.length > 0 ? title : '金句摘录'
    item.body = author.length > 0 ? `${body}\n——${author}` : body
    item.category = 'interest'
    item.learnTag = 'spark'
    item.priority = 'mid'
    item.source = 'quote'
    item.status = 'inbox'
    const now = Date.now()
    item.createdAt = now
    item.updatedAt = now
    return await ZhiweiStore.saveCapture(item)
  }

  static async captureFromDaily(title: string, body: string, category: string): Promise<boolean> {
    const item = new CaptureItem()
    item.id = ZhiweiStore.newId('cap')
    item.title = title
    item.body = body
    item.category = CategoryEmojiUtil.normalize(category)
    item.learnTag = 'todo'
    item.priority = 'mid'
    item.source = 'daily'
    item.status = 'inbox'
    const now = Date.now()
    item.createdAt = now
    item.updatedAt = now
    return await ZhiweiStore.saveCapture(item)
  }

  static knowledgeCardText(item: CaptureItem): string {
    const cat = CategoryEmojiUtil.nameOf(item.category)
    const tag = CategoryEmojiUtil.learnLabel(item.learnTag)
    return `【知微集】${item.title}\n分类：${cat} · ${tag}\n${item.body}`
  }

  static async toggleCaptureFav(id: string): Promise<boolean> {
    const found = ZhiweiStore.findCapture(id)
    if (found === null) {
      return false
    }
    found.favored = !found.favored
    found.updatedAt = Date.now()
    return await ZhiweiStore.saveCapture(found)
  }

  static async setLearnTag(id: string, tag: string): Promise<boolean> {
    const found = ZhiweiStore.findCapture(id)
    if (found === null) {
      return false
    }
    found.learnTag = tag
    found.updatedAt = Date.now()
    return await ZhiweiStore.saveCapture(found)
  }

  static async addToFolder(captureId: string, folderId: string): Promise<boolean> {
    const found = ZhiweiStore.findCapture(captureId)
    if (found === null) {
      return false
    }
    found.collectionId = folderId
    found.updatedAt = Date.now()
    return await ZhiweiStore.saveCapture(found)
  }

  static async createFolder(name: string): Promise<boolean> {
    const title = name.trim()
    if (title.length === 0) {
      return false
    }
    try {
      const next = ZhiweiStore.cloneBundle()
      const folder = new KnowledgeFolder()
      folder.id = ZhiweiStore.newId('lib')
      folder.name = title
      folder.createdAt = Date.now()
      const list: KnowledgeFolder[] = []
      for (const f of next.folders) {
        list.push(f)
      }
      list.push(folder)
      next.folders = list
      await ZhiweiStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async markDailyRead(dailyId: string): Promise<boolean> {
    try {
      const next = ZhiweiStore.cloneBundle()
      const today = ZhiweiStore.today()
      next.settings.readDailyId = dailyId
      if (next.settings.lastLearnDate !== today) {
        if (next.settings.lastLearnDate.length > 0) {
          next.settings.learnDays += 1
        } else {
          next.settings.learnDays = 1
        }
        next.settings.lastLearnDate = today
      }
      await ZhiweiStore.persist(next)
      await ZhiweiStore.checkAchievements()
      return true
    } catch {
      return false
    }
  }

  static isDailyRead(dailyId: string): boolean {
    return ZhiweiStore.cache.settings.readDailyId === dailyId &&
      ZhiweiStore.cache.settings.lastLearnDate === ZhiweiStore.today()
  }

  static historyDays(): InsightDigest[] {
    const list: InsightDigest[] = []
    for (const d of ZhiweiStore.cache.digests) {
      if (d.period === 'day') {
        list.push(d)
      }
    }
    list.sort((a: InsightDigest, b: InsightDigest): number => {
      return a.dateKey < b.dateKey ? 1 : -1
    })
    return list
  }

  static exportText(): string {
    const lines: string[] = []
    lines.push('知微集 · 本机收录导出')
    const list = ZhiweiStore.sortedCaptures()
    for (const item of list) {
      lines.push('---')
      lines.push(ZhiweiStore.displayTime(item.createdAt))
      lines.push(`${item.title} · ${CategoryEmojiUtil.nameOf(item.category)} · ${CategoryEmojiUtil.learnLabel(item.learnTag)}`)
      lines.push(item.body)
    }
    return lines.join('\n')
  }

  static async clearAll(): Promise<boolean> {
    try {
      const keep = ZhiweiStore.cache.settings
      const next = new ZhiweiBundle()
      next.settings = keep
      await ZhiweiStore.persist(next)
      ZhiweiStore.ensureDefaultFolders()
      await ZhiweiStore.persist(ZhiweiStore.cache)
      return true
    } catch {
      return false
    }
  }

  private static async upsertDigest(digest: InsightDigest): Promise<void> {
    const next = ZhiweiStore.cloneBundle()
    const list: InsightDigest[] = []
    let found = false
    for (const d of next.digests) {
      if (d.period === digest.period && d.dateKey === digest.dateKey) {
        list.push(digest)
        found = true
      } else {
        list.push(d)
      }
    }
    if (!found) {
      list.push(digest)
    }
    next.digests = list
    await ZhiweiStore.persist(next)
  }

  private static calcStreak(): number {
    const days: string[] = []
    for (const item of ZhiweiStore.cache.captures) {
      const k = InsightEngine.dateOf(InsightEngine.stampOf(item))
      let exists = false
      for (const d of days) {
        if (d === k) {
          exists = true
          break
        }
      }
      if (!exists) {
        days.push(k)
      }
    }
    days.sort((a: string, b: string): number => {
      return a < b ? 1 : -1
    })
    if (days.length === 0) {
      return 0
    }
    const today = ZhiweiStore.today()
    const yest = InsightEngine.lastDays(today, 2)[1]
    let cursor = ''
    if (days[0] === today) {
      cursor = today
    } else if (days[0] === yest) {
      cursor = yest
    } else {
      return 0
    }
    let streak = 0
    for (const d of days) {
      if (d === cursor) {
        streak += 1
        const prev = InsightEngine.lastDays(cursor, 2)
        cursor = prev.length > 1 ? prev[1] : cursor
      } else if (d < cursor) {
        break
      }
    }
    return streak
  }

  private static touchLearnOn(next: ZhiweiBundle): void {
    const today = ZhiweiStore.today()
    if (next.settings.lastLearnDate === today) {
      return
    }
    if (next.settings.lastLearnDate.length > 0) {
      next.settings.learnDays += 1
    } else {
      next.settings.learnDays = 1
    }
    next.settings.lastLearnDate = today
  }

  private static cat(id: string, name: string, count: number): CategoryCount {
    const row = new CategoryCount()
    row.id = id
    row.name = name
    row.count = count
    return row
  }

  private static bump(): void {
    const cur = AppStorage.get<number>(KEY_REV)
    const next = (cur ?? 0) + 1
    AppStorage.setOrCreate(KEY_REV, next)
  }

  private static cloneBundle(): ZhiweiBundle {
    const next = new ZhiweiBundle()
    next.captures = ZhiweiStore.cache.captures
    next.digests = ZhiweiStore.cache.digests
    next.favoriteQuoteIds = ZhiweiStore.cache.favoriteQuoteIds
    next.folders = ZhiweiStore.cache.folders
    next.plans = ZhiweiStore.cache.plans
    next.settings = ZhiweiStore.cache.settings
    return next
  }

  private static async persist(next: ZhiweiBundle): Promise<void> {
    ZhiweiStore.cache = next
    await ZhiweiStore.putString(KEY_BUNDLE, JSON.stringify(next))
    ZhiweiStore.bump()
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ZhiweiStore.pref === null) {
      return
    }
    try {
      await ZhiweiStore.pref.put(key, value)
      await ZhiweiStore.pref.flush()
    } catch {
      return
    }
  }

  private static parseBundle(raw: string): ZhiweiBundle {
    const empty = new ZhiweiBundle()
    if (raw.length === 0) {
      return empty
    }
    try {
      const parsed = JSON.parse(raw) as ZhiweiBundle
      const out = new ZhiweiBundle()
      if (parsed.captures !== undefined) {
        const list: CaptureItem[] = []
        for (const row of parsed.captures) {
          const e = new CaptureItem()
          e.id = row.id
          e.title = row.title
          e.body = row.body
          e.category = CategoryEmojiUtil.normalize(row.category)
          e.customTag = row.customTag
          if (row.learnTag !== undefined && row.learnTag.length > 0) {
            e.learnTag = row.learnTag
          }
          e.priority = row.priority
          e.source = row.source
          if (row.imageUri !== undefined) {
            e.imageUri = row.imageUri
          }
          if (row.collectionId !== undefined) {
            e.collectionId = row.collectionId
          }
          e.favored = row.favored === true
          if (row.nextReviewAt !== undefined) {
            e.nextReviewAt = ZhiweiStore.asTime(row.nextReviewAt)
          }
          if (row.nextAction !== undefined) {
            e.nextAction = row.nextAction
          }
          e.status = 'inbox'
          if (row.status === 'follow') {
            e.status = 'follow'
          }
          if (row.status === 'done') {
            e.status = 'done'
          }
          e.createdAt = ZhiweiStore.asTime(row.createdAt)
          e.updatedAt = ZhiweiStore.asTime(row.updatedAt)
          if (e.createdAt < 1000000000000 && e.updatedAt >= 1000000000000) {
            e.createdAt = e.updatedAt
          }
          if (e.createdAt < 1000000000000) {
            e.createdAt = Date.now()
          }
          if (e.updatedAt < 1000000000000) {
            e.updatedAt = e.createdAt
          }
          list.push(e)
        }
        out.captures = list
      }
      if (parsed.digests !== undefined) {
        const list: InsightDigest[] = []
        for (const row of parsed.digests) {
          const d = new InsightDigest()
          d.id = row.id
          d.period = row.period
          d.dateKey = row.dateKey
          d.summary = row.summary
          d.keywordCsv = row.keywordCsv
          d.workCount = ZhiweiStore.asCount(row.workCount)
          d.lifeCount = ZhiweiStore.asCount(row.lifeCount)
          d.studyCount = ZhiweiStore.asCount(row.studyCount)
          d.sparkCount = ZhiweiStore.asCount(row.sparkCount)
          d.captureCount = ZhiweiStore.asCount(row.captureCount)
          d.generatedAt = ZhiweiStore.asTime(row.generatedAt)
          list.push(d)
        }
        out.digests = list
      }
      if (parsed.favoriteQuoteIds !== undefined) {
        const ids: string[] = []
        for (const id of parsed.favoriteQuoteIds) {
          ids.push(id)
        }
        out.favoriteQuoteIds = ids
      }
      if (parsed.settings !== undefined) {
        const s = new ZhiweiSettings()
        s.darkMode = parsed.settings.darkMode
        s.nickname = parsed.settings.nickname
        if (parsed.settings.lastLearnDate !== undefined) {
          s.lastLearnDate = parsed.settings.lastLearnDate
        }
        s.learnDays = ZhiweiStore.asCount(parsed.settings.learnDays)
        if (parsed.settings.readDailyId !== undefined) {
          s.readDailyId = parsed.settings.readDailyId
        }
        if (parsed.settings.dailyGoalCount !== undefined && parsed.settings.dailyGoalCount > 0) {
          s.dailyGoalCount = parsed.settings.dailyGoalCount
        }
        if (parsed.settings.weeklyDigestGoal !== undefined && parsed.settings.weeklyDigestGoal > 0) {
          s.weeklyDigestGoal = parsed.settings.weeklyDigestGoal
        }
        if (parsed.settings.unlockedAchIds !== undefined) {
          const achIds: string[] = []
          for (const id of parsed.settings.unlockedAchIds) {
            achIds.push(id)
          }
          s.unlockedAchIds = achIds
        }
        if (parsed.settings.completedPathStepIds !== undefined) {
          const stepIds: string[] = []
          for (const id of parsed.settings.completedPathStepIds) {
            stepIds.push(id)
          }
          s.completedPathStepIds = stepIds
        }
        if (parsed.settings.tourDone === true) {
          s.tourDone = true
        }
        out.settings = s
      }
      if (parsed.plans !== undefined) {
        const list: LearnPlan[] = []
        for (const row of parsed.plans) {
          const p = new LearnPlan()
          p.id = row.id
          p.title = row.title
          p.period = row.period
          p.targetCount = ZhiweiStore.asCount(row.targetCount)
          p.metric = row.metric
          p.startDate = row.startDate
          p.endDate = row.endDate
          p.status = row.status
          p.createdAt = ZhiweiStore.asTime(row.createdAt)
          list.push(p)
        }
        out.plans = list
      }
      if (parsed.folders !== undefined) {
        const list: KnowledgeFolder[] = []
        for (const row of parsed.folders) {
          const f = new KnowledgeFolder()
          f.id = row.id
          f.name = row.name
          f.createdAt = ZhiweiStore.asTime(row.createdAt)
          list.push(f)
        }
        out.folders = list
      }
      return out
    } catch {
      return empty
    }
  }

  private static asTime(raw: number): number {
    if (raw > 1000000000 && raw < 1000000000000) {
      return raw * 1000
    }
    if (raw > 0) {
      return raw
    }
    return 0
  }

  private static asCount(raw: number): number {
    if (raw > 0) {
      return raw
    }
    return 0
  }

  private static ensureDefaultFolders(): boolean {
    if (ZhiweiStore.cache.folders.length > 0) {
      return false
    }
    const names: string[] = []
    names.push('我的读书笔记')
    names.push('我的生活技巧')
    names.push('我的学习资料')
    const list: KnowledgeFolder[] = []
    let i = 0
    for (const name of names) {
      const f = new KnowledgeFolder()
      f.id = `lib_default_${i}`
      f.name = name
      f.createdAt = Date.now()
      list.push(f)
      i += 1
    }
    ZhiweiStore.cache.folders = list
    return true
  }

  private static hasAch(ids: string[], id: string): boolean {
    for (const x of ids) {
      if (x === id) {
        return true
      }
    }
    return false
  }

  private static ensureDefaultPlan(): void {
    if (ZhiweiStore.cache.plans.length > 0) {
      return
    }
    const p = new LearnPlan()
    p.id = 'plan_default_week'
    p.title = '本周消化 3 条微知识'
    p.period = 'week'
    p.targetCount = 3
    p.metric = 'digest_done'
    p.startDate = ZhiweiStore.today()
    p.endDate = ''
    p.status = 'active'
    p.createdAt = Date.now()
    const list: LearnPlan[] = []
    list.push(p)
    ZhiweiStore.cache.plans = list
    if (ZhiweiStore.cache.settings.dailyGoalCount < 1) {
      ZhiweiStore.cache.settings.dailyGoalCount = 1
    }
    if (ZhiweiStore.cache.settings.weeklyDigestGoal < 1) {
      ZhiweiStore.cache.settings.weeklyDigestGoal = 3
    }
  }
}
