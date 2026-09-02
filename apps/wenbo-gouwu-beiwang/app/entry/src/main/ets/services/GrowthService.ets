import {
  AchievementBadge,
  ActivityEvent,
  AssigneeRow,
  CalendarDayMark,
  CheckInRecord,
  FavoriteEntry,
  GrowthSnapshot,
  MonthlyReview,
  ProcurementPlan,
  SearchFilter,
  SearchHit,
  ShoppingItem,
  ShoppingMemoNote,
  ProcurementTopic,
  EventNavTarget,
  WeeklyReview
} from '../models/ShoppingModels'
import { GrowthLocalStore, GrowthWire } from './GrowthLocalStore'
import { ShoppingLocalStore } from './ShoppingLocalStore'
import { ShoppingService } from './ShoppingService'
import { ShoppingStatsService } from './ShoppingStatsService'

export class GrowthService {
  static async record(type: string, title: string, summary: string, refId: string): Promise<void> {
    const row = new ActivityEvent()
    row.id = GrowthLocalStore.newId('act')
    row.type = type
    row.title = title
    row.summary = summary
    row.refId = refId
    row.createdAt = ShoppingLocalStore.nowIso()
    const events: ActivityEvent[] = [row]
    for (const e of GrowthLocalStore.events()) {
      events.push(GrowthLocalStore.cloneEvent(e))
      if (events.length >= 80) {
        break
      }
    }
    const cache = GrowthService.readCache()
    cache.events = events
    await GrowthLocalStore.saveAll(cache)
    await GrowthService.refreshAchievements()
  }

  static recentEvents(limit: number): ActivityEvent[] {
    const all = GrowthLocalStore.events()
    const out: ActivityEvent[] = []
    for (const row of all) {
      out.push(GrowthLocalStore.cloneEvent(row))
      if (out.length >= limit) {
        break
      }
    }
    return out
  }

  static activePlan(): ProcurementPlan | undefined {
    for (const row of GrowthLocalStore.plans()) {
      if (row.status === 'active') {
        return GrowthLocalStore.clonePlan(row)
      }
    }
    return undefined
  }

  static plans(): ProcurementPlan[] {
    return GrowthLocalStore.plans()
  }

  static async savePlan(plan: ProcurementPlan): Promise<void> {
    const cache = GrowthService.readCache()
    const next: ProcurementPlan[] = []
    let hit = false
    for (const row of cache.plans) {
      if (row.id === plan.id) {
        next.push(GrowthLocalStore.clonePlan(plan))
        hit = true
      } else {
        next.push(GrowthLocalStore.clonePlan(row))
      }
    }
    if (!hit) {
      next.unshift(GrowthLocalStore.clonePlan(plan))
    }
    cache.plans = next
    await GrowthLocalStore.saveAll(cache)
    await GrowthService.record('plan_save', '更新采购计划', plan.title, plan.id)
    await GrowthService.refreshAchievements()
  }

  static async createDefaultWeekPlan(): Promise<ProcurementPlan> {
    for (const row of GrowthLocalStore.plans()) {
      if (row.status === 'active') {
        return GrowthLocalStore.clonePlan(row)
      }
    }
    const plan = new ProcurementPlan()
    plan.id = GrowthLocalStore.newId('plan')
    plan.title = '本周采购计划'
    plan.period = 'week'
    plan.startDate = ShoppingLocalStore.today()
    const end = new Date()
    end.setDate(end.getDate() + 6)
    const em = end.getMonth() + 1
    const ed = end.getDate()
    plan.endDate = `${end.getFullYear()}-${em < 10 ? `0${em}` : `${em}`}-${ed < 10 ? `0${ed}` : `${ed}`}`
    plan.targetItemCount = 12
    plan.targetBudgetYuan = '300'
    plan.status = 'active'
    plan.createdAt = ShoppingLocalStore.nowIso()
    await GrowthService.savePlan(plan)
    return plan
  }

  static planProgress(plan: ProcurementPlan): number {
    let done = 0
    const ids: string[] = plan.linkedListIds
    if (ids.length === 0) {
      for (const list of ShoppingLocalStore.lists()) {
        ids.push(list.id)
      }
    }
    for (const listId of ids) {
      for (const it of ShoppingLocalStore.itemsOf(listId)) {
        if (it.completed) {
          done += 1
        }
      }
    }
    return done
  }

  static planBudgetUsed(plan: ProcurementPlan): number {
    let budget = 0
    for (const list of ShoppingLocalStore.lists()) {
      for (const it of ShoppingLocalStore.itemsOf(list.id)) {
        if (!it.completed) {
          continue
        }
        const n = Number.parseFloat(it.paidPrice.length > 0 ? it.paidPrice : it.estPrice)
        if (!Number.isNaN(n)) {
          budget += n
        }
      }
    }
    return Math.round(budget * 100) / 100
  }

  static async checkInToday(source: string, note: string): Promise<boolean> {
    const key = ShoppingLocalStore.today()
    for (const row of GrowthLocalStore.checkIns()) {
      if (row.dateKey === key) {
        return false
      }
    }
    const rec = new CheckInRecord()
    rec.dateKey = key
    rec.source = source
    rec.note = note
    rec.createdAt = ShoppingLocalStore.nowIso()
    const cache = GrowthService.readCache()
    const next: CheckInRecord[] = [rec]
    for (const row of cache.checkIns) {
      next.push(GrowthLocalStore.cloneCheckIn(row))
    }
    cache.checkIns = next
    await GrowthLocalStore.saveAll(cache)
    await GrowthService.record('checkin', '完成采购打卡', note.length > 0 ? note : '今日已打卡', key)
    await GrowthService.refreshAchievements()
    return true
  }

  static checkInStreak(): number {
    const keys: string[] = []
    for (const row of GrowthLocalStore.checkIns()) {
      if (keys.indexOf(row.dateKey) < 0) {
        keys.push(row.dateKey)
      }
    }
    let streak = 0
    const cursor = new Date()
    cursor.setHours(0, 0, 0, 0)
    for (let i = 0; i < 60; i++) {
      const y = cursor.getFullYear()
      const m = cursor.getMonth() + 1
      const d = cursor.getDate()
      const ms: string = m < 10 ? `0${m}` : `${m}`
      const ds: string = d < 10 ? `0${d}` : `${d}`
      const key = `${y}-${ms}-${ds}`
      if (keys.indexOf(key) >= 0) {
        streak += 1
        cursor.setDate(cursor.getDate() - 1)
      } else if (i === 0) {
        cursor.setDate(cursor.getDate() - 1)
      } else {
        break
      }
    }
    return streak
  }

  static checkIns(): CheckInRecord[] {
    return GrowthLocalStore.checkIns()
  }

  static badges(): AchievementBadge[] {
    return GrowthLocalStore.badges()
  }

  static favorites(): FavoriteEntry[] {
    return GrowthLocalStore.favorites()
  }

  static favoriteCount(): number {
    let n = GrowthLocalStore.favorites().length
    for (const row of ShoppingLocalStore.lists()) {
      if (row.starred) {
        n += 1
      }
    }
    for (const row of ShoppingLocalStore.memos()) {
      if (row.important) {
        n += 1
      }
    }
    return n
  }

  static async toggleFavorite(refType: string, refId: string, title: string, subtitle: string): Promise<boolean> {
    const cache = GrowthService.readCache()
    let removed = false
    const next: FavoriteEntry[] = []
    for (const row of cache.favorites) {
      if (row.refType === refType && row.refId === refId) {
        removed = true
        continue
      }
      next.push(GrowthLocalStore.cloneFavorite(row))
    }
    if (!removed) {
      const fav = new FavoriteEntry()
      fav.refType = refType
      fav.refId = refId
      fav.title = title
      fav.subtitle = subtitle
      fav.createdAt = ShoppingLocalStore.nowIso()
      next.unshift(fav)
      await GrowthService.record('favorite', '加入收藏', title, refId)
    }
    cache.favorites = next
    await GrowthLocalStore.saveAll(cache)
    await GrowthService.refreshAchievements()
    return !removed
  }

  static isFavorite(refType: string, refId: string): boolean {
    for (const row of GrowthLocalStore.favorites()) {
      if (row.refType === refType && row.refId === refId) {
        return true
      }
    }
    return false
  }

  static search(keyword: string): SearchHit[] {
    const filter = new SearchFilter()
    filter.keyword = keyword
    return GrowthService.searchWithFilter(filter)
  }

  static searchWithFilter(filter: SearchFilter): SearchHit[] {
    const key = filter.keyword.trim()
    const out: SearchHit[] = []
    for (const list of ShoppingLocalStore.lists()) {
      if (!GrowthService.matchListFilter(list.updatedAt, filter)) {
        continue
      }
      if (key.length > 0 && list.title.indexOf(key) < 0) {
        continue
      }
      const hit = new SearchHit()
      hit.kind = 'list'
      hit.id = list.id
      hit.title = list.title
      hit.subtitle = list.kind
      out.push(hit)
    }
    for (const it of ShoppingLocalStore.items()) {
      if (!GrowthService.matchItemFilter(it, filter)) {
        continue
      }
      if (key.length > 0 && it.title.indexOf(key) < 0 && it.remark.indexOf(key) < 0) {
        continue
      }
      const hit = new SearchHit()
      hit.kind = 'item'
      hit.id = it.id
      hit.listId = it.listId
      hit.title = it.title
      hit.subtitle = it.category
      out.push(hit)
    }
    for (const memo of ShoppingLocalStore.memos()) {
      if (!GrowthService.matchDateFilter(memo.updatedAt, filter)) {
        continue
      }
      if (key.length > 0 && memo.title.indexOf(key) < 0 && memo.body.indexOf(key) < 0) {
        continue
      }
      const hit = new SearchHit()
      hit.kind = 'memo'
      hit.id = memo.id
      hit.title = memo.title
      hit.subtitle = '备忘'
      out.push(hit)
    }
    for (const freq of ShoppingLocalStore.library()) {
      if (key.length === 0 || freq.title.indexOf(key) >= 0) {
        const hit = new SearchHit()
        hit.kind = 'library'
        hit.id = freq.title
        hit.title = freq.title
        hit.subtitle = '常购库'
        out.push(hit)
      }
    }
    for (const topic of GrowthLocalStore.topics()) {
      if (key.length === 0 || topic.title.indexOf(key) >= 0) {
        const hit = new SearchHit()
        hit.kind = 'topic'
        hit.id = topic.id
        hit.title = topic.title
        hit.subtitle = '采购主题'
        out.push(hit)
      }
    }
    for (const fav of GrowthLocalStore.favorites()) {
      if (key.length > 0 && fav.title.indexOf(key) < 0) {
        continue
      }
      const hit = new SearchHit()
      hit.kind = fav.refType
      hit.id = fav.refId
      hit.title = fav.title
      hit.subtitle = `收藏 · ${fav.subtitle}`
      if (fav.refType === 'item') {
        for (const it of ShoppingLocalStore.items()) {
          if (it.id === fav.refId) {
            hit.listId = it.listId
            break
          }
        }
      }
      out.push(hit)
    }
    return out
  }

  private static matchItemFilter(it: ShoppingItem, filter: SearchFilter): boolean {
    if (filter.status === 'pending' && it.completed) {
      return false
    }
    if (filter.status === 'done' && !it.completed) {
      return false
    }
    if (filter.tag.length > 0 && it.tag !== filter.tag) {
      return false
    }
    if (filter.category.length > 0 && it.category !== filter.category) {
      return false
    }
    return GrowthService.matchDateFilter(it.updatedAt, filter)
  }

  private static matchListFilter(updatedAt: string, filter: SearchFilter): boolean {
    if (filter.status === 'pending') {
      return false
    }
    if (filter.status === 'done') {
      return false
    }
    return GrowthService.matchDateFilter(updatedAt, filter)
  }

  private static matchDateFilter(iso: string, filter: SearchFilter): boolean {
    if (filter.dateFrom.length === 0 && filter.dateTo.length === 0) {
      return true
    }
    const day = iso.length >= 10 ? iso.substring(0, 10) : ''
    if (day.length === 0) {
      return true
    }
    if (filter.dateFrom.length > 0 && day < filter.dateFrom) {
      return false
    }
    if (filter.dateTo.length > 0 && day > filter.dateTo) {
      return false
    }
    return true
  }

  static monthlyReview(monthKey: string): MonthlyReview {
    const out = new MonthlyReview()
    out.monthKey = monthKey
    let paid = 0
    let est = 0
    let checked = 0
    const catNames: string[] = []
    const catCounts: number[] = []
    for (const it of ShoppingLocalStore.items()) {
      const day = it.updatedAt.length >= 10 ? it.updatedAt.substring(0, 7) : ''
      if (day !== monthKey) {
        continue
      }
      if (it.completed) {
        checked += 1
        const n = Number.parseFloat(it.paidPrice.length > 0 ? it.paidPrice : it.estPrice)
        if (!Number.isNaN(n)) {
          paid += n
        }
      }
      const e = Number.parseFloat(it.estPrice)
      if (!Number.isNaN(e)) {
        est += e
      }
      const idx = catNames.indexOf(it.category)
      if (idx < 0) {
        catNames.push(it.category)
        catCounts.push(1)
      } else {
        catCounts[idx] += 1
      }
    }
    out.paidTotal = Math.round(paid * 100) / 100
    out.estTotal = Math.round(est * 100) / 100
    out.checkedCount = checked
    for (const list of ShoppingLocalStore.lists()) {
      if (list.status === 'done' && list.updatedAt.substring(0, 7) === monthKey) {
        out.listDone += 1
      }
    }
    for (const row of GrowthLocalStore.checkIns()) {
      if (row.dateKey.substring(0, 7) === monthKey) {
        out.checkInDays += 1
      }
    }
    let topCat = '暂无'
    let topN = 0
    for (let i = 0; i < catNames.length; i++) {
      if (catCounts[i] > topN) {
        topN = catCounts[i]
        topCat = catNames[i]
      }
    }
    out.topCategory = topCat
    const prevKey = GrowthService.prevMonthKey(monthKey)
    const prevPaid = GrowthService.monthPaidTotal(prevKey)
    if (prevPaid > 0) {
      out.vsLastMonthPercent = Math.round(((out.paidTotal - prevPaid) / prevPaid) * 100)
    }
    out.summary = `${monthKey} 勾选 ${out.checkedCount} 件，完成 ${out.listDone} 份清单，打卡 ${out.checkInDays} 天，实付约 ${out.paidTotal} 元，常买 ${out.topCategory}。`
    return out
  }

  private static monthPaidTotal(monthKey: string): number {
    let paid = 0
    for (const it of ShoppingLocalStore.items()) {
      const day = it.updatedAt.length >= 10 ? it.updatedAt.substring(0, 7) : ''
      if (day !== monthKey || !it.completed) {
        continue
      }
      const n = Number.parseFloat(it.paidPrice.length > 0 ? it.paidPrice : it.estPrice)
      if (!Number.isNaN(n)) {
        paid += n
      }
    }
    return Math.round(paid * 100) / 100
  }

  private static prevMonthKey(key: string): string {
    const parts = key.split('-')
    if (parts.length < 2) {
      return key
    }
    let y = Number.parseInt(parts[0])
    let m = Number.parseInt(parts[1])
    m -= 1
    if (m < 1) {
      m = 12
      y -= 1
    }
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${y}-${ms}`
  }

  static calendarMarks(year: number, month: number): CalendarDayMark[] {
    const out: CalendarDayMark[] = []
    const checkKeys: string[] = []
    for (const row of GrowthLocalStore.checkIns()) {
      checkKeys.push(row.dateKey)
    }
    const plan = GrowthService.activePlan()
    let budgetLimit = 0
    if (plan !== undefined) {
      budgetLimit = Number.parseFloat(plan.targetBudgetYuan)
      if (Number.isNaN(budgetLimit)) {
        budgetLimit = 0
      }
    }
    const daysInMonth = new Date(year, month, 0).getDate()
    for (let d = 1; d <= daysInMonth; d++) {
      const ms = month < 10 ? `0${month}` : `${month}`
      const ds = d < 10 ? `0${d}` : `${d}`
      const key = `${year}-${ms}-${ds}`
      const mark = new CalendarDayMark()
      mark.dateKey = key
      mark.checkIn = checkKeys.indexOf(key) >= 0
      let dayPaid = 0
      let dayChecked = 0
      for (const it of ShoppingLocalStore.items()) {
        const day = it.updatedAt.length >= 10 ? it.updatedAt.substring(0, 10) : ''
        if (day !== key) {
          continue
        }
        if (it.completed) {
          dayChecked += 1
          const n = Number.parseFloat(it.paidPrice.length > 0 ? it.paidPrice : it.estPrice)
          if (!Number.isNaN(n)) {
            dayPaid += n
          }
        }
      }
      mark.checkedCount = dayChecked
      for (const list of ShoppingLocalStore.lists()) {
        if (list.status === 'done' && list.updatedAt.substring(0, 10) === key) {
          mark.listDoneCount += 1
        }
      }
      if (budgetLimit > 0 && dayPaid > budgetLimit / 7) {
        mark.overBudget = true
      }
      out.push(mark)
    }
    return out
  }

  static eventsForDate(dateKey: string): ActivityEvent[] {
    const out: ActivityEvent[] = []
    for (const e of GrowthLocalStore.events()) {
      const day = e.createdAt.length >= 10 ? e.createdAt.substring(0, 10) : ''
      if (day === dateKey) {
        out.push(GrowthLocalStore.cloneEvent(e))
      }
    }
    return out
  }

  static assigneeBoard(): AssigneeRow[] {
    const names: string[] = []
    const out: AssigneeRow[] = []
    const ensure = (name: string): AssigneeRow => {
      const key = name.length > 0 ? name : '未分配'
      const idx = names.indexOf(key)
      if (idx >= 0) {
        return out[idx]
      }
      const row = new AssigneeRow()
      row.name = key
      names.push(key)
      out.push(row)
      return row
    }
    for (const it of ShoppingLocalStore.items()) {
      if (it.completed) {
        continue
      }
      const row = ensure(it.assignee)
      row.pendingCount += 1
      row.items.push(ShoppingLocalStore.cloneItem(it))
    }
    for (const it of ShoppingLocalStore.items()) {
      if (!it.completed || it.assignee.length === 0) {
        continue
      }
      const row = ensure(it.assignee)
      row.doneCount += 1
    }
    return out
  }

  static assigneePresets(): string[] {
    return ['我', '爸爸', '妈妈', '家人']
  }

  static rangeArray(count: number): number[] {
    const out: number[] = []
    for (let i = 0; i < count; i++) {
      out.push(i)
    }
    return out
  }

  static currentMonthKey(): string {
    const now = new Date()
    const m = now.getMonth() + 1
    const ms = m < 10 ? `0${m}` : `${m}`
    return `${now.getFullYear()}-${ms}`
  }

  static favoriteGroups(): FavoriteEntry[] {
    return GrowthLocalStore.favorites()
  }

  static starredMemos(): ShoppingMemoNote[] {
    const out: ShoppingMemoNote[] = []
    for (const row of ShoppingLocalStore.memos()) {
      if (row.important) {
        out.push(ShoppingLocalStore.cloneMemo(row))
      }
    }
    return out
  }

  static snapshot(): GrowthSnapshot {
    const out = new GrowthSnapshot()
    const stats = ShoppingService.weekStats()
    out.listCount = stats.listCount
    out.checkedTotal = stats.checkedCount
    out.favoriteCount = GrowthService.favoriteCount()
    out.checkInStreak = GrowthService.checkInStreak()
    const plan = GrowthService.activePlan()
    if (plan !== undefined) {
      out.planTarget = plan.targetItemCount
      out.planDone = GrowthService.planProgress(plan)
      out.planBudgetTarget = Number.parseFloat(plan.targetBudgetYuan)
      if (Number.isNaN(out.planBudgetTarget)) {
        out.planBudgetTarget = 0
      }
      out.planBudgetUsed = GrowthService.planBudgetUsed(plan)
    }
    const badges = GrowthLocalStore.badges()
    out.achievementTotal = badges.length
    for (const b of badges) {
      if (b.unlockedAt.length > 0) {
        out.achievementUnlocked += 1
      }
    }
    out.topicCount = GrowthLocalStore.topics().length
    return out
  }

  static weeklyReview(): WeeklyReview {
    const out = new WeeklyReview()
    const insight = ShoppingStatsService.insight()
    out.checkedCount = insight.weekChecked
    out.topCategory = insight.topCategory
    out.checkInDays = GrowthLocalStore.checkIns().length
    let paid = 0
    for (const it of ShoppingLocalStore.items()) {
      if (!it.completed) {
        continue
      }
      const n = Number.parseFloat(it.paidPrice.length > 0 ? it.paidPrice : it.estPrice)
      if (!Number.isNaN(n)) {
        paid += n
      }
    }
    out.paidTotal = Math.round(paid * 100) / 100
    for (const list of ShoppingLocalStore.lists()) {
      if (list.status === 'done') {
        out.listDone += 1
      }
    }
    out.summary = `本周勾选 ${out.checkedCount} 件，完成 ${out.listDone} 份清单，打卡 ${out.checkInDays} 天，常买 ${out.topCategory}。`
    return out
  }

  static async refreshAchievements(): Promise<void> {
    const cache = GrowthService.readCache()
    const lists = ShoppingLocalStore.lists()
    const items = ShoppingLocalStore.items()
    let checked = 0
    for (const it of items) {
      if (it.completed) {
        checked += 1
      }
    }
    const streak = GrowthService.checkInStreak()
    const favCount = GrowthService.favoriteCount()
    let planDone = 0
    for (const p of cache.plans) {
      if (p.status === 'done') {
        planDone += 1
      }
    }
    const next: AchievementBadge[] = []
    for (const b of cache.badges) {
      const copy = GrowthLocalStore.cloneBadge(b)
      if (copy.id === 'first_list') {
        copy.progress = lists.length
      } else if (copy.id === 'first_check') {
        copy.progress = checked > 0 ? 1 : 0
      } else if (copy.id === 'check_10') {
        copy.progress = checked
      } else if (copy.id === 'check_50') {
        copy.progress = checked
      } else if (copy.id === 'streak_3') {
        copy.progress = streak
      } else if (copy.id === 'streak_7') {
        copy.progress = streak
      } else if (copy.id === 'plan_done') {
        copy.progress = planDone
      } else if (copy.id === 'star_3') {
        copy.progress = favCount
      }
      if (copy.unlockedAt.length === 0 && copy.progress >= copy.target) {
        copy.unlockedAt = ShoppingLocalStore.nowIso()
      }
      next.push(copy)
    }
    cache.badges = next
    await GrowthLocalStore.saveAll(cache)
  }

  static async onItemToggled(item: ShoppingItem, completed: boolean): Promise<void> {
    const verb = completed ? '勾选' : '取消勾选'
    await GrowthService.record('toggle_item', `${verb}：${item.title}`, item.category, item.id)
    const plan = GrowthService.activePlan()
    if (plan !== undefined && plan.targetItemCount > 0) {
      const done = GrowthService.planProgress(plan)
      if (done >= plan.targetItemCount && plan.status === 'active') {
        plan.status = 'done'
        await GrowthService.savePlan(plan)
        await GrowthService.record('plan_done', '完成采购计划', plan.title, plan.id)
      }
    }
    await GrowthService.refreshAchievements()
  }

  static async onListCreated(title: string, listId: string): Promise<void> {
    await GrowthService.record('create_list', '创建清单', title, listId)
    await GrowthService.refreshAchievements()
  }

  static async onVerifyDone(): Promise<void> {
    const ok = await GrowthService.checkInToday('verify', '完成出门核对')
    if (ok) {
      await GrowthService.record('verify', '出门核对完成', '全屏核对通过', ShoppingLocalStore.today())
    }
  }

  static topics(): ProcurementTopic[] {
    return GrowthLocalStore.topics()
  }

  static findTopic(id: string): ProcurementTopic | undefined {
    for (const row of GrowthLocalStore.topics()) {
      if (row.id === id) {
        return GrowthLocalStore.cloneTopic(row)
      }
    }
    return undefined
  }

  static async saveTopic(topic: ProcurementTopic): Promise<void> {
    const cache = GrowthService.readCache()
    const next: ProcurementTopic[] = []
    let hit = false
    for (const row of cache.topics) {
      if (row.id === topic.id) {
        next.push(GrowthLocalStore.cloneTopic(topic))
        hit = true
      } else {
        next.push(GrowthLocalStore.cloneTopic(row))
      }
    }
    if (!hit) {
      next.unshift(GrowthLocalStore.cloneTopic(topic))
    }
    cache.topics = next
    await GrowthLocalStore.saveAll(cache)
    await GrowthService.record('topic_save', '更新采购主题', topic.title, topic.id)
  }

  static async deleteTopic(id: string): Promise<void> {
    const cache = GrowthService.readCache()
    const next: ProcurementTopic[] = []
    for (const row of cache.topics) {
      if (row.id !== id) {
        next.push(GrowthLocalStore.cloneTopic(row))
      }
    }
    cache.topics = next
    await GrowthLocalStore.saveAll(cache)
  }

  static async createTopic(title: string, coverKey: string): Promise<ProcurementTopic> {
    const topic = new ProcurementTopic()
    topic.id = GrowthLocalStore.newId('topic')
    topic.title = title
    topic.coverKey = coverKey.length > 0 ? coverKey : 'tpl_family'
    topic.updatedAt = ShoppingLocalStore.nowIso()
    await GrowthService.saveTopic(topic)
    return topic
  }

  static async linkListToTopic(topicId: string, listId: string): Promise<void> {
    const topic = GrowthService.findTopic(topicId)
    if (topic === undefined) {
      return
    }
    let hit = false
    for (const id of topic.listIds) {
      if (id === listId) {
        hit = true
        break
      }
    }
    if (!hit) {
      topic.listIds.push(listId)
    }
    topic.updatedAt = ShoppingLocalStore.nowIso()
    await GrowthService.saveTopic(topic)
  }

  static async unlinkListFromTopic(topicId: string, listId: string): Promise<void> {
    const topic = GrowthService.findTopic(topicId)
    if (topic === undefined) {
      return
    }
    const next: string[] = []
    for (const id of topic.listIds) {
      if (id !== listId) {
        next.push(id)
      }
    }
    topic.listIds = next
    topic.updatedAt = ShoppingLocalStore.nowIso()
    await GrowthService.saveTopic(topic)
  }

  static eventTarget(event: ActivityEvent): EventNavTarget | undefined {
    const out = new EventNavTarget()
    if (event.type === 'create_list' || event.type === 'plan_done') {
      out.kind = 'list'
      out.id = event.refId
      return out
    }
    if (event.type === 'toggle_item') {
      out.kind = 'item'
      out.id = event.refId
      for (const it of ShoppingLocalStore.items()) {
        if (it.id === event.refId) {
          out.listId = it.listId
          return out
        }
      }
      return undefined
    }
    if (event.type === 'topic_save') {
      out.kind = 'topic'
      out.id = event.refId
      return out
    }
    return undefined
  }

  private static readCache(): GrowthWire {
    return GrowthLocalStore.snapshotWire()
  }
}
