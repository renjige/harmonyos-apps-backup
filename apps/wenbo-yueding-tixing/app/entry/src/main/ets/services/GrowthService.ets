import { AppointmentItem } from '../models/AppointmentModels'
import { AppointmentLocalStore } from './AppointmentLocalStore'
import { AppointmentService } from './AppointmentService'
import {
  AchievementDef,
  AchievementState,
  AchievementBundle,
  ActivityBundle,
  ActivityLogItem,
  CheckInBundle,
  CheckInRecord,
  CollectionBundle,
  CommitmentPlan,
  FavoriteTemplate,
  FavoriteTemplateBundle,
  GrowthSnapshot,
  PlanBundle,
  PlanFormDraft,
  SearchResultRow,
  TagBundle,
  UserCollection,
  UserTag
} from '../models/GrowthModels'
import { GrowthLocalStore } from './GrowthLocalStore'

export class GrowthService {
  static achievementDefs(): AchievementDef[] {
    const defs: AchievementDef[] = []
    const a = new AchievementDef()
    a.key = 'first_complete'
    a.title = '首次守约'
    a.description = '完成第一件约定'
    a.iconLabel = '首'
    a.target = 1
    defs.push(a)
    const b = new AchievementDef()
    b.key = 'complete_10'
    b.title = '守约十次'
    b.description = '累计完成 10 件约定'
    b.iconLabel = '10'
    b.target = 10
    defs.push(b)
    const c = new AchievementDef()
    c.key = 'complete_50'
    c.title = '守约达人'
    c.description = '累计完成 50 件约定'
    c.iconLabel = '50'
    c.target = 50
    defs.push(c)
    const d = new AchievementDef()
    d.key = 'streak_7'
    d.title = '连续一周'
    d.description = '连续 7 天有守约打卡'
    d.iconLabel = '7'
    d.target = 7
    defs.push(d)
    const e = new AchievementDef()
    e.key = 'streak_30'
    e.title = '连续一月'
    e.description = '连续 30 天有守约打卡'
    e.iconLabel = '30'
    e.target = 30
    defs.push(e)
    const f = new AchievementDef()
    f.key = 'favorite_5'
    f.title = '收藏达人'
    f.description = '收藏 5 条约定或模板'
    f.iconLabel = '★'
    f.target = 5
    defs.push(f)
    const g = new AchievementDef()
    g.key = 'plan_done'
    g.title = '计划达成'
    g.description = '完成一个守约计划'
    g.iconLabel = '计'
    g.target = 1
    defs.push(g)
    return defs
  }

  static async log(type: string, refId: string, title: string, summary: string, scene: string = ''): Promise<void> {
    const item = new ActivityLogItem()
    item.id = GrowthLocalStore.newId('log')
    item.type = type
    item.refId = refId
    item.title = title
    item.summary = summary
    item.scene = scene
    item.occurredAt = AppointmentLocalStore.nowIso()
    const bundle = new ActivityBundle()
    const logs: ActivityLogItem[] = [item]
    for (const row of GrowthLocalStore.activityLogs()) {
      logs.push(row)
    }
    const limited: ActivityLogItem[] = []
    for (let i = 0; i < logs.length && i < 200; i++) {
      limited.push(logs[i])
    }
    bundle.logs = limited
    await GrowthLocalStore.saveActivities(bundle)
  }

  static recentLogs(limit: number): ActivityLogItem[] {
    const out: ActivityLogItem[] = []
    let count = 0
    for (const row of GrowthLocalStore.activityLogs()) {
      if (count >= limit) {
        break
      }
      out.push(row)
      count += 1
    }
    return out
  }

  static logsByDate(isoDate: string): ActivityLogItem[] {
    const out: ActivityLogItem[] = []
    for (const row of GrowthLocalStore.activityLogs()) {
      if (row.occurredAt.startsWith(isoDate)) {
        out.push(row)
      }
    }
    return out
  }

  static activityLabel(type: string): string {
    if (type === 'create') {
      return '创建了'
    }
    if (type === 'complete') {
      return '完成了'
    }
    if (type === 'favorite') {
      return '收藏了'
    }
    if (type === 'checkin') {
      return '打卡'
    }
    if (type === 'plan_done') {
      return '达成计划'
    }
    if (type === 'postpone') {
      return '改期'
    }
    return '更新了'
  }

  static async onAppointmentCreated(item: AppointmentItem): Promise<void> {
    await GrowthService.log('create', item.id, item.title, item.dateTimeLabel(), item.scene)
    if (item.planId.length > 0) {
      await GrowthService.linkAppointmentToPlan(item.planId, item.id)
    }
  }

  static async onAppointmentCompleted(item: AppointmentItem): Promise<void> {
    await GrowthService.log('complete', item.id, item.title, '守约完成', item.scene)
    await GrowthService.recordDailyCheckIn()
    if (item.planId.length > 0) {
      await GrowthService.incrementPlanDone(item.planId, item.id)
    }
    await GrowthService.evaluateAchievements()
  }

  static async onAppointmentFavorite(item: AppointmentItem, favorited: boolean): Promise<void> {
    if (favorited) {
      await GrowthService.log('favorite', item.id, item.title, '加入收藏', item.scene)
    }
    await GrowthService.evaluateAchievements()
  }

  static async onCheckIn(item: AppointmentItem): Promise<void> {
    if (item.checkedIn) {
      await GrowthService.log('checkin', item.id, item.title, '到达打卡', item.scene)
    }
  }

  static async recordDailyCheckIn(): Promise<void> {
    const today = AppointmentLocalStore.today()
    const bundle = new CheckInBundle()
    let found = false
    for (const row of GrowthLocalStore.checkInList()) {
      if (row.date === today) {
        const rec = new CheckInRecord()
        rec.date = today
        rec.done = true
        rec.note = '完成约定'
        bundle.records.push(rec)
        found = true
      } else {
        bundle.records.push(row)
      }
    }
    if (!found) {
      const rec = new CheckInRecord()
      rec.date = today
      rec.done = true
      rec.note = '完成约定'
      bundle.records.push(rec)
    }
    await GrowthLocalStore.saveCheckIns(bundle)
    await GrowthService.evaluateAchievements()
  }

  static computeStreakDays(): number {
    const records = GrowthLocalStore.checkInList()
    const dates: string[] = []
    for (const row of records) {
      if (row.done) {
        dates.push(row.date)
      }
    }
    if (dates.length === 0) {
      return 0
    }
    dates.sort()
    let streak = 0
    let cursor = AppointmentLocalStore.today()
    for (let i = 0; i < 400; i++) {
      let hit = false
      for (const d of dates) {
        if (d === cursor) {
          hit = true
          break
        }
      }
      if (!hit) {
        break
      }
      streak += 1
      cursor = GrowthService.addDays(cursor, -1)
    }
    return streak
  }

  private static addDays(iso: string, delta: number): string {
    const parts = iso.split('-')
    const y = parseInt(parts[0], 10)
    const m = parseInt(parts[1], 10) - 1
    const d = parseInt(parts[2], 10)
    const date = new Date(y, m, d)
    date.setDate(date.getDate() + delta)
    const mm = date.getMonth() + 1
    const dd = date.getDate()
    const ms = mm < 10 ? `0${mm}` : `${mm}`
    const ds = dd < 10 ? `0${dd}` : `${dd}`
    return `${date.getFullYear()}-${ms}-${ds}`
  }

  static checkInHeatmapDays(): CheckInRecord[] {
    const out: CheckInRecord[] = []
    const today = AppointmentLocalStore.today()
    for (let i = 27; i >= 0; i--) {
      const date = GrowthService.addDays(today, -i)
      let rec: CheckInRecord | undefined = undefined
      for (const row of GrowthLocalStore.checkInList()) {
        if (row.date === date) {
          rec = row
          break
        }
      }
      if (rec !== undefined) {
        out.push(rec)
      } else {
        const empty = new CheckInRecord()
        empty.date = date
        empty.done = false
        out.push(empty)
      }
    }
    return out
  }

  static async listPlans(): Promise<CommitmentPlan[]> {
    const out: CommitmentPlan[] = []
    for (const row of GrowthLocalStore.planList()) {
      out.push(GrowthService.hydratePlan(row))
    }
    return out
  }

  static async activePlans(): Promise<CommitmentPlan[]> {
    const all = await GrowthService.listPlans()
    const out: CommitmentPlan[] = []
    for (const row of all) {
      if (row.status === 'active') {
        out.push(row)
      }
    }
    return out
  }

  static hydratePlan(raw: CommitmentPlan): CommitmentPlan {
    const p = new CommitmentPlan()
    p.id = raw.id ?? ''
    p.title = raw.title ?? ''
    p.description = raw.description ?? ''
    p.targetCount = raw.targetCount > 0 ? raw.targetCount : 10
    p.doneCount = raw.doneCount >= 0 ? raw.doneCount : 0
    p.scene = raw.scene ?? ''
    p.startDate = raw.startDate ?? ''
    p.endDate = raw.endDate ?? ''
    p.status = raw.status ?? 'active'
    p.linkedAppointmentIds = raw.linkedAppointmentIds ?? []
    p.createdAt = raw.createdAt ?? ''
    p.updatedAt = raw.updatedAt ?? ''
    return p
  }

  static async savePlanDraft(draft: PlanFormDraft): Promise<CommitmentPlan | undefined> {
    if (draft.title.trim().length === 0) {
      return undefined
    }
    const target = parseInt(draft.targetCount, 10)
    const plan = new CommitmentPlan()
    plan.id = draft.id.length > 0 ? draft.id : GrowthLocalStore.newId('plan')
    plan.title = draft.title.trim()
    plan.description = draft.description.trim()
    plan.targetCount = Number.isNaN(target) || target <= 0 ? 10 : target
    plan.scene = draft.scene
    plan.startDate = draft.startDate.length > 0 ? draft.startDate : AppointmentLocalStore.today()
    plan.endDate = draft.endDate
    plan.updatedAt = AppointmentLocalStore.nowIso()
    const isNew = draft.id.length === 0
    if (isNew) {
      plan.createdAt = plan.updatedAt
      plan.doneCount = 0
      plan.status = 'active'
      plan.linkedAppointmentIds = []
    } else {
      for (const row of GrowthLocalStore.planList()) {
        if (row.id === plan.id) {
          plan.doneCount = row.doneCount
          plan.status = row.status
          plan.linkedAppointmentIds = row.linkedAppointmentIds
          plan.createdAt = row.createdAt
          break
        }
      }
    }
    const bundle = new PlanBundle()
    let found = false
    for (const row of GrowthLocalStore.planList()) {
      if (row.id === plan.id) {
        bundle.plans.push(plan)
        found = true
      } else {
        bundle.plans.push(row)
      }
    }
    if (!found) {
      bundle.plans.unshift(plan)
    }
    await GrowthLocalStore.savePlans(bundle)
    if (isNew) {
      await GrowthService.log('create', plan.id, plan.title, '新建守约计划')
    }
    return plan
  }

  static async findPlan(id: string): Promise<CommitmentPlan | undefined> {
    for (const row of GrowthLocalStore.planList()) {
      if (row.id === id) {
        return GrowthService.hydratePlan(row)
      }
    }
    return undefined
  }

  static async removePlan(id: string): Promise<boolean> {
    const bundle = new PlanBundle()
    let removed = false
    for (const row of GrowthLocalStore.planList()) {
      if (row.id === id) {
        removed = true
      } else {
        bundle.plans.push(row)
      }
    }
    if (!removed) {
      return false
    }
    await GrowthLocalStore.savePlans(bundle)
    return true
  }

  static async linkAppointmentToPlan(planId: string, appointmentId: string): Promise<void> {
    const bundle = new PlanBundle()
    for (const row of GrowthLocalStore.planList()) {
      const plan = GrowthService.hydratePlan(row)
      if (plan.id === planId) {
        let exists = false
        for (const aid of plan.linkedAppointmentIds) {
          if (aid === appointmentId) {
            exists = true
            break
          }
        }
        if (!exists) {
          plan.linkedAppointmentIds.push(appointmentId)
        }
        bundle.plans.push(plan)
      } else {
        bundle.plans.push(row)
      }
    }
    await GrowthLocalStore.savePlans(bundle)
  }

  static async incrementPlanDone(planId: string, appointmentId: string): Promise<void> {
    const bundle = new PlanBundle()
    for (const row of GrowthLocalStore.planList()) {
      const plan = GrowthService.hydratePlan(row)
      if (plan.id === planId) {
        let exists = false
        for (const aid of plan.linkedAppointmentIds) {
          if (aid === appointmentId) {
            exists = true
            break
          }
        }
        if (!exists) {
          plan.linkedAppointmentIds.push(appointmentId)
          plan.doneCount += 1
        }
        if (plan.doneCount >= plan.targetCount && plan.status === 'active') {
          plan.status = 'done'
          await GrowthService.log('plan_done', plan.id, plan.title, '计划目标达成')
        }
        plan.updatedAt = AppointmentLocalStore.nowIso()
        bundle.plans.push(plan)
      } else {
        bundle.plans.push(row)
      }
    }
    await GrowthLocalStore.savePlans(bundle)
    await GrowthService.evaluateAchievements()
  }

  static draftFromPlan(plan: CommitmentPlan): PlanFormDraft {
    const d = new PlanFormDraft()
    d.id = plan.id
    d.title = plan.title
    d.description = plan.description
    d.targetCount = `${plan.targetCount}`
    d.scene = plan.scene
    d.startDate = plan.startDate
    d.endDate = plan.endDate
    return d
  }

  static async listCollections(): Promise<UserCollection[]> {
    const out: UserCollection[] = []
    for (const row of GrowthLocalStore.collectionList()) {
      out.push(row)
    }
    for (let i = 0; i < out.length; i++) {
      for (let j = i + 1; j < out.length; j++) {
        if (out[i].sortOrder > out[j].sortOrder) {
          const tmp = out[i]
          out[i] = out[j]
          out[j] = tmp
        }
      }
    }
    return out
  }

  static async saveCollection(title: string, id: string = ''): Promise<UserCollection | undefined> {
    if (title.trim().length === 0) {
      return undefined
    }
    const col = new UserCollection()
    col.id = id.length > 0 ? id : GrowthLocalStore.newId('col')
    col.title = title.trim()
    col.createdAt = AppointmentLocalStore.nowIso()
    col.sortOrder = GrowthLocalStore.collectionList().length
    const bundle = new CollectionBundle()
    let found = false
    for (const row of GrowthLocalStore.collectionList()) {
      if (row.id === col.id) {
        col.appointmentIds = row.appointmentIds
        col.iconKey = row.iconKey
        col.color = row.color
        col.sortOrder = row.sortOrder
        col.createdAt = row.createdAt
        bundle.collections.push(col)
        found = true
      } else {
        bundle.collections.push(row)
      }
    }
    if (!found) {
      bundle.collections.push(col)
    }
    await GrowthLocalStore.saveCollections(bundle)
    return col
  }

  static async addToCollection(collectionId: string, appointmentId: string): Promise<void> {
    const bundle = new CollectionBundle()
    for (const row of GrowthLocalStore.collectionList()) {
      if (row.id === collectionId) {
        let exists = false
        for (const aid of row.appointmentIds) {
          if (aid === appointmentId) {
            exists = true
            break
          }
        }
        if (!exists) {
          row.appointmentIds.push(appointmentId)
        }
        bundle.collections.push(row)
      } else {
        bundle.collections.push(row)
      }
    }
    await GrowthLocalStore.saveCollections(bundle)
  }

  static defaultTags(): UserTag[] {
    const defs: UserTag[] = []
    const names: string[] = ['紧急', '客户', '家庭', '学习']
    const colors: string[] = ['#DC2626', '#2563EB', '#059669', '#7C3AED']
    for (let i = 0; i < names.length; i++) {
      const t = new UserTag()
      t.id = `tag_${i}`
      t.name = names[i]
      t.color = colors[i]
      defs.push(t)
    }
    return defs
  }

  static async ensureDefaultTags(): Promise<void> {
    if (GrowthLocalStore.tagList().length > 0) {
      return
    }
    const bundle = new TagBundle()
    bundle.tags = GrowthService.defaultTags()
    await GrowthLocalStore.saveTags(bundle)
  }

  static tagList(): UserTag[] {
    if (GrowthLocalStore.tagList().length === 0) {
      return GrowthService.defaultTags()
    }
    return GrowthLocalStore.tagList()
  }

  static async toggleFavoriteTemplate(templateId: string): Promise<boolean> {
    const bundle = new FavoriteTemplateBundle()
    let nowFav = false
    for (const row of GrowthLocalStore.favoriteTemplates()) {
      if (row.templateId === templateId) {
        nowFav = false
      } else {
        bundle.items.push(row)
      }
    }
    if (!nowFav) {
      let wasFav = false
      for (const row of GrowthLocalStore.favoriteTemplates()) {
        if (row.templateId === templateId) {
          wasFav = true
          break
        }
      }
      if (!wasFav) {
        const ft = new FavoriteTemplate()
        ft.templateId = templateId
        ft.savedAt = AppointmentLocalStore.nowIso()
        bundle.items.push(ft)
        nowFav = true
      }
    }
    await GrowthLocalStore.saveFavoriteTemplates(bundle)
    await GrowthService.evaluateAchievements()
    return nowFav
  }

  static isTemplateFavorite(templateId: string): boolean {
    for (const row of GrowthLocalStore.favoriteTemplates()) {
      if (row.templateId === templateId) {
        return true
      }
    }
    return false
  }

  static async evaluateAchievements(): Promise<void> {
    const all = await AppointmentService.listAll()
    let doneCount = 0
    let favCount = 0
    for (const row of all) {
      if (row.isDone()) {
        doneCount += 1
      }
      if (row.favorite) {
        favCount += 1
      }
    }
    favCount += GrowthLocalStore.favoriteTemplates().length
    const streak = GrowthService.computeStreakDays()
    let planDone = 0
    for (const p of GrowthLocalStore.planList()) {
      if (p.status === 'done') {
        planDone += 1
      }
    }
    const progressFirst = doneCount >= 1 ? 1 : 0
    const bundle = new AchievementBundle()
    for (const def of GrowthService.achievementDefs()) {
      const state = new AchievementState()
      state.key = def.key
      let progress = 0
      if (def.key === 'first_complete') {
        progress = progressFirst
      } else if (def.key === 'complete_10' || def.key === 'complete_50') {
        progress = doneCount
      } else if (def.key === 'streak_7' || def.key === 'streak_30') {
        progress = streak
      } else if (def.key === 'favorite_5') {
        progress = favCount
      } else if (def.key === 'plan_done') {
        progress = planDone
      }
      state.progress = progress
      let prev: AchievementState | undefined = undefined
      for (const row of GrowthLocalStore.achievementList()) {
        if (row.key === def.key) {
          prev = row
          break
        }
      }
      if (progress >= def.target) {
        state.unlockedAt = prev !== undefined && prev.unlockedAt.length > 0 ?
          prev.unlockedAt : AppointmentLocalStore.nowIso()
      } else {
        state.unlockedAt = ''
      }
      bundle.states.push(state)
    }
    await GrowthLocalStore.saveAchievements(bundle)
  }

  static achievementStates(): AchievementState[] {
    const out: AchievementState[] = []
    const defs = GrowthService.achievementDefs()
    for (const def of defs) {
      let found: AchievementState | undefined = undefined
      for (const row of GrowthLocalStore.achievementList()) {
        if (row.key === def.key) {
          found = row
          break
        }
      }
      if (found !== undefined) {
        out.push(found)
      } else {
        const s = new AchievementState()
        s.key = def.key
        s.progress = 0
        out.push(s)
      }
    }
    return out
  }

  static defForKey(key: string): AchievementDef | undefined {
    for (const d of GrowthService.achievementDefs()) {
      if (d.key === key) {
        return d
      }
    }
    return undefined
  }

  static async snapshot(): Promise<GrowthSnapshot> {
    await GrowthService.ensureDefaultTags()
    const all = await AppointmentService.listAll()
    const today = AppointmentLocalStore.today()
    const snap = new GrowthSnapshot()
    snap.streakDays = GrowthService.computeStreakDays()
    snap.activePlanCount = (await GrowthService.activePlans()).length
    let fav = 0
    let doneTotal = 0
    let todayDone = 0
    let todayTotal = 0
    for (const row of all) {
      if (row.favorite) {
        fav += 1
      }
      if (row.isDone()) {
        doneTotal += 1
      }
      if (row.dueDate === today) {
        todayTotal += 1
        if (row.isDone()) {
          todayDone += 1
        }
      }
    }
    snap.favoriteCount = fav + GrowthLocalStore.favoriteTemplates().length
    snap.totalDone = doneTotal
    snap.todayDone = todayDone
    snap.todayTotal = todayTotal
    const states = GrowthService.achievementStates()
    snap.achievementTotal = states.length
    let unlocked = 0
    for (const s of states) {
      if (s.unlockedAt.length > 0) {
        unlocked += 1
      }
    }
    snap.achievementUnlocked = unlocked
    return snap
  }

  static async search(query: string): Promise<SearchResultRow[]> {
    const q = query.trim().toLowerCase()
    if (q.length === 0) {
      return []
    }
    const out: SearchResultRow[] = []
    const all = await AppointmentService.listAll()
    for (const row of all) {
      const hay = `${row.title} ${row.place} ${row.note} ${row.contactName}`.toLowerCase()
      if (hay.indexOf(q) >= 0) {
        const r = new SearchResultRow()
        r.kind = 'appointment'
        r.id = row.id
        r.title = row.title
        r.meta = row.dateTimeLabel()
        out.push(r)
      }
    }
    for (const plan of GrowthLocalStore.planList()) {
      const hay = `${plan.title} ${plan.description}`.toLowerCase()
      if (hay.indexOf(q) >= 0) {
        const r = new SearchResultRow()
        r.kind = 'plan'
        r.id = plan.id
        r.title = plan.title
        r.meta = `计划 · ${plan.doneCount}/${plan.targetCount}`
        out.push(r)
      }
    }
    for (const col of GrowthLocalStore.collectionList()) {
      if (col.title.toLowerCase().indexOf(q) >= 0) {
        const r = new SearchResultRow()
        r.kind = 'collection'
        r.id = col.id
        r.title = col.title
        r.meta = `专题 · ${col.appointmentIds.length} 条`
        out.push(r)
      }
    }
    return out
  }

  static countFavorites(all: AppointmentItem[]): number {
    let n = 0
    for (const row of all) {
      if (row.favorite) {
        n += 1
      }
    }
    return n + GrowthLocalStore.favoriteTemplates().length
  }
}
