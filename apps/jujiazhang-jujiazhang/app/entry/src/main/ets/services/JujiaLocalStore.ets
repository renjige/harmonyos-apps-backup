import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  DutySlot,
  FamilyMember,
  FamilyMemo,
  ChecklistLine,
  ChecklistPack,
  DiaryEntry,
  MaintenanceJob,
  FiredRecord,
  HomeItem,
  JujiaBundleWire,
  FavoriteRecord,
  ActivityEvent,
  CheckInRecord,
  AchievementState,
  FamilyGoal,
  GrowthWire
} from '../models/JujiaModels'

const STORE = 'jujiazhang_local'
const KEY_ITEMS = 'items'
const KEY_MEMOS = 'memos'
const KEY_MEMBERS = 'members'
const KEY_DUTIES = 'duties'
const KEY_FIRED = 'fired'
const KEY_CHECKLISTS = 'checklists'
const KEY_DIARIES = 'diaries'
const KEY_MAINTENANCE = 'maintenance'
const KEY_FAVORITES = 'favorites'
const KEY_ACTIVITIES = 'activities'
const KEY_CHECKINS = 'checkins'
const KEY_ACHIEVEMENTS = 'achievements'
const KEY_GOALS = 'goals'

export class JujiaLocalStore {
  private static pref: preferences.Preferences | null = null
  private static itemCache: HomeItem[] = []
  private static memoCache: FamilyMemo[] = []
  private static memberCache: FamilyMember[] = []
  private static dutyCache: DutySlot[] = []
  private static firedCache: FiredRecord[] = []
  private static checklistCache: ChecklistPack[] = []
  private static diaryCache: DiaryEntry[] = []
  private static maintenanceCache: MaintenanceJob[] = []
  private static favoriteCache: FavoriteRecord[] = []
  private static activityCache: ActivityEvent[] = []
  private static checkinCache: CheckInRecord[] = []
  private static achievementCache: AchievementState[] = []
  private static goalCache: FamilyGoal[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      JujiaLocalStore.pref = await preferences.getPreferences(context, STORE)
      const itemsRaw = await JujiaLocalStore.pref.get(KEY_ITEMS, '')
      const memosRaw = await JujiaLocalStore.pref.get(KEY_MEMOS, '')
      const membersRaw = await JujiaLocalStore.pref.get(KEY_MEMBERS, '')
      const dutiesRaw = await JujiaLocalStore.pref.get(KEY_DUTIES, '')
      const firedRaw = await JujiaLocalStore.pref.get(KEY_FIRED, '')
      const checklistRaw = await JujiaLocalStore.pref.get(KEY_CHECKLISTS, '')
      const diaryRaw = await JujiaLocalStore.pref.get(KEY_DIARIES, '')
      const maintenanceRaw = await JujiaLocalStore.pref.get(KEY_MAINTENANCE, '')
      JujiaLocalStore.itemCache = JujiaLocalStore.parseItems(typeof itemsRaw === 'string' ? itemsRaw : '')
      JujiaLocalStore.memoCache = JujiaLocalStore.parseMemos(typeof memosRaw === 'string' ? memosRaw : '')
      JujiaLocalStore.memberCache = JujiaLocalStore.parseMembers(typeof membersRaw === 'string' ? membersRaw : '')
      JujiaLocalStore.dutyCache = JujiaLocalStore.parseDuties(typeof dutiesRaw === 'string' ? dutiesRaw : '')
      JujiaLocalStore.firedCache = JujiaLocalStore.parseFired(typeof firedRaw === 'string' ? firedRaw : '')
      JujiaLocalStore.checklistCache = JujiaLocalStore.parseChecklists(typeof checklistRaw === 'string' ? checklistRaw : '')
      JujiaLocalStore.diaryCache = JujiaLocalStore.parseDiaries(typeof diaryRaw === 'string' ? diaryRaw : '')
      JujiaLocalStore.maintenanceCache = JujiaLocalStore.parseMaintenance(typeof maintenanceRaw === 'string' ? maintenanceRaw : '')
      const favRaw = await JujiaLocalStore.pref.get(KEY_FAVORITES, '')
      const actRaw = await JujiaLocalStore.pref.get(KEY_ACTIVITIES, '')
      const chkRaw = await JujiaLocalStore.pref.get(KEY_CHECKINS, '')
      const achRaw = await JujiaLocalStore.pref.get(KEY_ACHIEVEMENTS, '')
      const goalRaw = await JujiaLocalStore.pref.get(KEY_GOALS, '')
      JujiaLocalStore.favoriteCache = JujiaLocalStore.parseFavorites(typeof favRaw === 'string' ? favRaw : '')
      JujiaLocalStore.activityCache = JujiaLocalStore.parseActivities(typeof actRaw === 'string' ? actRaw : '')
      JujiaLocalStore.checkinCache = JujiaLocalStore.parseCheckins(typeof chkRaw === 'string' ? chkRaw : '')
      JujiaLocalStore.achievementCache = JujiaLocalStore.parseAchievements(typeof achRaw === 'string' ? achRaw : '')
      JujiaLocalStore.goalCache = JujiaLocalStore.parseGoals(typeof goalRaw === 'string' ? goalRaw : '')
    } catch {
      JujiaLocalStore.itemCache = []
      JujiaLocalStore.memoCache = []
      JujiaLocalStore.memberCache = []
      JujiaLocalStore.dutyCache = []
      JujiaLocalStore.firedCache = []
      JujiaLocalStore.checklistCache = []
      JujiaLocalStore.diaryCache = []
      JujiaLocalStore.maintenanceCache = []
      JujiaLocalStore.favoriteCache = []
      JujiaLocalStore.activityCache = []
      JujiaLocalStore.checkinCache = []
      JujiaLocalStore.achievementCache = []
      JujiaLocalStore.goalCache = []
    }
  }

  static favorites(): FavoriteRecord[] {
    return JujiaLocalStore.favoriteCache
  }

  static activities(): ActivityEvent[] {
    return JujiaLocalStore.activityCache
  }

  static checkins(): CheckInRecord[] {
    return JujiaLocalStore.checkinCache
  }

  static achievements(): AchievementState[] {
    return JujiaLocalStore.achievementCache
  }

  static goals(): FamilyGoal[] {
    return JujiaLocalStore.goalCache
  }

  static items(): HomeItem[] {
    return JujiaLocalStore.itemCache
  }

  static memos(): FamilyMemo[] {
    return JujiaLocalStore.memoCache
  }

  static members(): FamilyMember[] {
    return JujiaLocalStore.memberCache
  }

  static duties(): DutySlot[] {
    return JujiaLocalStore.dutyCache
  }

  static checklists(): ChecklistPack[] {
    return JujiaLocalStore.checklistCache
  }

  static diaries(): DiaryEntry[] {
    return JujiaLocalStore.diaryCache
  }

  static maintenanceJobs(): MaintenanceJob[] {
    return JujiaLocalStore.maintenanceCache
  }

  static nowIso(): string {
    return new Date().toISOString()
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static async saveItems(rows: HomeItem[]): Promise<void> {
    JujiaLocalStore.itemCache = rows
    const wire = new JujiaBundleWire()
    wire.items = rows
    await JujiaLocalStore.putString(KEY_ITEMS, JSON.stringify(wire))
  }

  static async saveMemos(rows: FamilyMemo[]): Promise<void> {
    JujiaLocalStore.memoCache = rows
    const wire = new JujiaBundleWire()
    wire.memos = rows
    await JujiaLocalStore.putString(KEY_MEMOS, JSON.stringify(wire))
  }

  static async saveMembers(rows: FamilyMember[]): Promise<void> {
    JujiaLocalStore.memberCache = rows
    const wire = new JujiaBundleWire()
    wire.members = rows
    await JujiaLocalStore.putString(KEY_MEMBERS, JSON.stringify(wire))
  }

  static async saveDuties(rows: DutySlot[]): Promise<void> {
    JujiaLocalStore.dutyCache = rows
    const wire = new JujiaBundleWire()
    wire.duties = rows
    await JujiaLocalStore.putString(KEY_DUTIES, JSON.stringify(wire))
  }

  static async saveChecklists(rows: ChecklistPack[]): Promise<void> {
    JujiaLocalStore.checklistCache = rows
    const wire = new JujiaBundleWire()
    wire.checklists = rows
    await JujiaLocalStore.putString(KEY_CHECKLISTS, JSON.stringify(wire))
  }

  static async saveDiaries(rows: DiaryEntry[]): Promise<void> {
    JujiaLocalStore.diaryCache = rows
    const wire = new JujiaBundleWire()
    wire.diaries = rows
    await JujiaLocalStore.putString(KEY_DIARIES, JSON.stringify(wire))
  }

  static async saveMaintenance(rows: MaintenanceJob[]): Promise<void> {
    JujiaLocalStore.maintenanceCache = rows
    const wire = new JujiaBundleWire()
    wire.maintenance = rows
    await JujiaLocalStore.putString(KEY_MAINTENANCE, JSON.stringify(wire))
  }

  static async saveFavorites(rows: FavoriteRecord[]): Promise<void> {
    JujiaLocalStore.favoriteCache = rows
    const wire = new GrowthWire()
    wire.favorites = rows
    await JujiaLocalStore.putString(KEY_FAVORITES, JSON.stringify(wire))
  }

  static async saveActivities(rows: ActivityEvent[]): Promise<void> {
    JujiaLocalStore.activityCache = rows
    const wire = new GrowthWire()
    wire.activities = rows
    await JujiaLocalStore.putString(KEY_ACTIVITIES, JSON.stringify(wire))
  }

  static async saveCheckins(rows: CheckInRecord[]): Promise<void> {
    JujiaLocalStore.checkinCache = rows
    const wire = new GrowthWire()
    wire.checkins = rows
    await JujiaLocalStore.putString(KEY_CHECKINS, JSON.stringify(wire))
  }

  static async saveAchievements(rows: AchievementState[]): Promise<void> {
    JujiaLocalStore.achievementCache = rows
    const wire = new GrowthWire()
    wire.achievements = rows
    await JujiaLocalStore.putString(KEY_ACHIEVEMENTS, JSON.stringify(wire))
  }

  static async saveGoals(rows: FamilyGoal[]): Promise<void> {
    JujiaLocalStore.goalCache = rows
    const wire = new GrowthWire()
    wire.goals = rows
    await JujiaLocalStore.putString(KEY_GOALS, JSON.stringify(wire))
  }

  static wasFiredToday(key: string, day: string): boolean {
    for (const row of JujiaLocalStore.firedCache) {
      if (row.key === key && row.day === day) {
        return true
      }
    }
    return false
  }

  static async markFired(key: string, day: string): Promise<void> {
    const next: FiredRecord[] = []
    for (const row of JujiaLocalStore.firedCache) {
      if (row.key !== key) {
        next.push(row)
      }
    }
    const rec = new FiredRecord()
    rec.key = key
    rec.day = day
    next.push(rec)
    JujiaLocalStore.firedCache = next
    const wire = new JujiaBundleWire()
    wire.fired = next
    await JujiaLocalStore.putString(KEY_FIRED, JSON.stringify(wire))
  }

  private static mapItem(row: HomeItem): HomeItem {
    const item = new HomeItem()
    item.id = row.id ?? ''
    item.name = row.name ?? ''
    item.category = row.category ?? '其他'
    item.purchaseDate = row.purchaseDate ?? ''
    item.expiryDate = row.expiryDate ?? ''
    item.location = row.location ?? ''
    item.remark = row.remark ?? ''
    item.room = row.room ?? ''
    item.customTag = row.customTag ?? ''
    item.remindLeadDays = row.remindLeadDays ?? 0
    item.reminderAgentId = row.reminderAgentId ?? 0
    item.userId = row.userId ?? ''
    item.createdAt = row.createdAt ?? ''
    item.updatedAt = row.updatedAt ?? ''
    return item
  }

  private static mapMemo(row: FamilyMemo): FamilyMemo {
    const memo = new FamilyMemo()
    memo.id = row.id ?? ''
    memo.title = row.title ?? ''
    memo.body = row.body ?? ''
    memo.tag = row.tag ?? '采购'
    memo.pinned = row.pinned === true
    memo.userId = row.userId ?? ''
    memo.createdAt = row.createdAt ?? ''
    memo.updatedAt = row.updatedAt ?? ''
    return memo
  }

  private static mapMember(row: FamilyMember): FamilyMember {
    const m = new FamilyMember()
    m.id = row.id ?? ''
    m.name = row.name ?? ''
    m.role = row.role ?? '家人'
    return m
  }

  private static mapDuty(row: DutySlot): DutySlot {
    const d = new DutySlot()
    d.weekday = row.weekday ?? 1
    d.chore = row.chore ?? ''
    d.memberId = row.memberId ?? ''
    d.memberName = row.memberName ?? ''
    return d
  }

  private static mapChecklist(row: ChecklistPack): ChecklistPack {
    const pack = new ChecklistPack()
    pack.id = row.id ?? ''
    pack.title = row.title ?? ''
    pack.kind = row.kind ?? '日用品'
    pack.userId = row.userId ?? ''
    pack.createdAt = row.createdAt ?? ''
    pack.updatedAt = row.updatedAt ?? ''
    const lines: ChecklistLine[] = []
    if (row.lines !== undefined) {
      for (const line of row.lines) {
        const ln = new ChecklistLine()
        ln.id = line.id ?? ''
        ln.text = line.text ?? ''
        ln.done = line.done === true
        if (ln.text.length > 0) {
          lines.push(ln)
        }
      }
    }
    pack.lines = lines
    return pack
  }

  private static mapDiary(row: DiaryEntry): DiaryEntry {
    const d = new DiaryEntry()
    d.id = row.id ?? ''
    d.title = row.title ?? ''
    d.body = row.body ?? ''
    d.mood = row.mood ?? '平常'
    d.userId = row.userId ?? ''
    d.createdAt = row.createdAt ?? ''
    d.updatedAt = row.updatedAt ?? ''
    return d
  }

  private static mapMaintenance(row: MaintenanceJob): MaintenanceJob {
    const job = new MaintenanceJob()
    job.id = row.id ?? ''
    job.title = row.title ?? ''
    job.room = row.room ?? '客厅'
    job.cycleDays = row.cycleDays ?? 90
    job.lastDoneDate = row.lastDoneDate ?? ''
    job.nextDueDate = row.nextDueDate ?? ''
    job.remark = row.remark ?? ''
    job.reminderAgentId = row.reminderAgentId ?? 0
    job.userId = row.userId ?? ''
    job.createdAt = row.createdAt ?? ''
    job.updatedAt = row.updatedAt ?? ''
    return job
  }

  private static parseItems(raw: string): HomeItem[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as JujiaBundleWire
      const out: HomeItem[] = []
      if (parsed.items !== undefined) {
        for (const row of parsed.items) {
          const item = JujiaLocalStore.mapItem(row as HomeItem)
          if (item.name.length > 0) {
            out.push(item)
          }
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseMemos(raw: string): FamilyMemo[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as JujiaBundleWire
      const out: FamilyMemo[] = []
      if (parsed.memos !== undefined) {
        for (const row of parsed.memos) {
          const memo = JujiaLocalStore.mapMemo(row as FamilyMemo)
          if (memo.title.length > 0) {
            out.push(memo)
          }
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseMembers(raw: string): FamilyMember[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as JujiaBundleWire
      const out: FamilyMember[] = []
      if (parsed.members !== undefined) {
        for (const row of parsed.members) {
          const m = JujiaLocalStore.mapMember(row as FamilyMember)
          if (m.name.length > 0) {
            out.push(m)
          }
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseDuties(raw: string): DutySlot[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as JujiaBundleWire
      const out: DutySlot[] = []
      if (parsed.duties !== undefined) {
        for (const row of parsed.duties) {
          const d = JujiaLocalStore.mapDuty(row as DutySlot)
          if (d.chore.length > 0) {
            out.push(d)
          }
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseChecklists(raw: string): ChecklistPack[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as JujiaBundleWire
      const out: ChecklistPack[] = []
      if (parsed.checklists !== undefined) {
        for (const row of parsed.checklists) {
          const pack = JujiaLocalStore.mapChecklist(row as ChecklistPack)
          if (pack.title.length > 0) {
            out.push(pack)
          }
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseDiaries(raw: string): DiaryEntry[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as JujiaBundleWire
      const out: DiaryEntry[] = []
      if (parsed.diaries !== undefined) {
        for (const row of parsed.diaries) {
          const d = JujiaLocalStore.mapDiary(row as DiaryEntry)
          if (d.title.length > 0) {
            out.push(d)
          }
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseMaintenance(raw: string): MaintenanceJob[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as JujiaBundleWire
      const out: MaintenanceJob[] = []
      if (parsed.maintenance !== undefined) {
        for (const row of parsed.maintenance) {
          const job = JujiaLocalStore.mapMaintenance(row as MaintenanceJob)
          if (job.title.length > 0) {
            out.push(job)
          }
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static mapFavorite(row: FavoriteRecord): FavoriteRecord {
    const f = new FavoriteRecord()
    f.id = row.id ?? ''
    f.targetType = row.targetType ?? 'task'
    f.targetId = row.targetId ?? ''
    f.title = row.title ?? ''
    f.createdAt = row.createdAt ?? ''
    return f
  }

  private static mapActivity(row: ActivityEvent): ActivityEvent {
    const e = new ActivityEvent()
    e.id = row.id ?? ''
    e.kind = row.kind ?? 'create'
    e.entityType = row.entityType ?? 'task'
    e.entityId = row.entityId ?? ''
    e.title = row.title ?? ''
    e.summary = row.summary ?? ''
    e.occurredAt = row.occurredAt ?? ''
    return e
  }

  private static mapCheckin(row: CheckInRecord): CheckInRecord {
    const c = new CheckInRecord()
    c.date = row.date ?? ''
    c.taskDoneCount = row.taskDoneCount ?? 0
    return c
  }

  private static mapAchievement(row: AchievementState): AchievementState {
    const a = new AchievementState()
    a.code = row.code ?? ''
    a.unlockedAt = row.unlockedAt ?? ''
    return a
  }

  private static mapGoal(row: FamilyGoal): FamilyGoal {
    const g = new FamilyGoal()
    g.id = row.id ?? ''
    g.title = row.title ?? ''
    g.targetCount = row.targetCount ?? 10
    g.currentCount = row.currentCount ?? 0
    g.unit = row.unit ?? '项'
    g.status = row.status ?? 'active'
    g.startDate = row.startDate ?? ''
    g.endDate = row.endDate ?? ''
    g.createdAt = row.createdAt ?? ''
    g.updatedAt = row.updatedAt ?? ''
    return g
  }

  private static parseFavorites(raw: string): FavoriteRecord[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as GrowthWire
      const out: FavoriteRecord[] = []
      for (const row of parsed.favorites) {
        const mapped = JujiaLocalStore.mapFavorite(row as FavoriteRecord)
        if (mapped.targetId.length > 0) {
          out.push(mapped)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseActivities(raw: string): ActivityEvent[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as GrowthWire
      const out: ActivityEvent[] = []
      for (const row of parsed.activities) {
        const mapped = JujiaLocalStore.mapActivity(row as ActivityEvent)
        if (mapped.title.length > 0) {
          out.push(mapped)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseCheckins(raw: string): CheckInRecord[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as GrowthWire
      const out: CheckInRecord[] = []
      for (const row of parsed.checkins) {
        const mapped = JujiaLocalStore.mapCheckin(row as CheckInRecord)
        if (mapped.date.length > 0) {
          out.push(mapped)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseAchievements(raw: string): AchievementState[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as GrowthWire
      const out: AchievementState[] = []
      for (const row of parsed.achievements) {
        const mapped = JujiaLocalStore.mapAchievement(row as AchievementState)
        if (mapped.code.length > 0) {
          out.push(mapped)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseGoals(raw: string): FamilyGoal[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as GrowthWire
      const out: FamilyGoal[] = []
      for (const row of parsed.goals) {
        const mapped = JujiaLocalStore.mapGoal(row as FamilyGoal)
        if (mapped.title.length > 0) {
          out.push(mapped)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static parseFired(raw: string): FiredRecord[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as JujiaBundleWire
      const out: FiredRecord[] = []
      if (parsed.fired !== undefined) {
        for (const row of parsed.fired) {
          const rec = row as FiredRecord
          const item = new FiredRecord()
          item.key = rec.key ?? ''
          item.day = rec.day ?? ''
          if (item.key.length > 0) {
            out.push(item)
          }
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (JujiaLocalStore.pref === null) {
      return
    }
    try {
      await JujiaLocalStore.pref.put(key, value)
      await JujiaLocalStore.pref.flush()
    } catch {
    }
  }
}
