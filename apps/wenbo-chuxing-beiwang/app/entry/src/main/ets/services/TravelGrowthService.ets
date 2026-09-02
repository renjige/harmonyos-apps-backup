import { preferences } from '@kit.ArkData'
import { HttpClient } from './HttpClient'
import { DateFormatUtil } from '../components/design-system/DateFormatUtil'
import {
  ChecklistItem,
  ItineraryItem,
  ListData,
  NoteItem,
  ReminderItem,
  TravelTemplate,
  TravelTip,
  TripItem
} from '../models/TravelModels'
import {
  AchievementItem,
  ActivityEvent,
  CreateHabitLogRequest,
  CreateHabitRequest,
  HabitLogRow,
  HabitRow,
  SearchResultItem,
  TravelFavorite,
  TravelStatsSnapshot,
  TripRecapItem
} from '../models/TravelGrowthModels'
import { TravelService } from './TravelService'

const BASE = '/biz/task-efficiency'
const PREP_HABIT_TITLE = '出发前准备打卡'

export class TravelGrowthService {
  private static pref: preferences.Preferences | null = null
  private static prepHabitId: string = ''

  static async bindPreferences(pref: preferences.Preferences): Promise<void> {
    TravelGrowthService.pref = pref
  }

  private static userId(): string {
    return AppStorage.get<string>('currentUsername') ?? ''
  }

  private static favKey(): string {
    return `growth_fav_${TravelGrowthService.userId()}`
  }

  private static achKey(): string {
    return `growth_ach_${TravelGrowthService.userId()}`
  }

  private static todayStr(): string {
    return DateFormatUtil.formatDate(new Date())
  }

  private static async readJsonArray(key: string): Promise<string[]> {
    if (TravelGrowthService.pref === null) {
      return []
    }
    const raw = await TravelGrowthService.pref.get(key, '[]')
    if (typeof raw !== 'string' || raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as string[]
      if (Array.isArray(parsed)) {
        return parsed
      }
    } catch {
      return []
    }
    return []
  }

  private static async writeJsonArray(key: string, rows: string[]): Promise<void> {
    if (TravelGrowthService.pref === null) {
      return
    }
    await TravelGrowthService.pref.put(key, JSON.stringify(rows))
    await TravelGrowthService.pref.flush()
  }

  static async listFavorites(): Promise<TravelFavorite[]> {
    const keys = await TravelGrowthService.readJsonArray(TravelGrowthService.favKey())
    const out: TravelFavorite[] = []
    for (const key of keys) {
      const parts = key.split(':')
      if (parts.length < 3) {
        continue
      }
      const fav = new TravelFavorite()
      fav.entityType = parts[0]
      fav.entityId = parts[1]
      fav.title = parts.slice(2).join(':')
      fav.id = key
      out.push(fav)
    }
    return out
  }

  static async isFavorite(entityType: string, entityId: string): Promise<boolean> {
    const keys = await TravelGrowthService.readJsonArray(TravelGrowthService.favKey())
    const target = `${entityType}:${entityId}:`
    for (const key of keys) {
      if (key.startsWith(target)) {
        return true
      }
    }
    return false
  }

  static async toggleFavorite(entityType: string, entityId: string, title: string): Promise<boolean> {
    const keys = await TravelGrowthService.readJsonArray(TravelGrowthService.favKey())
    const prefix = `${entityType}:${entityId}:`
    const next: string[] = []
    let removed = false
    for (const key of keys) {
      if (key.startsWith(prefix)) {
        removed = true
        continue
      }
      next.push(key)
    }
    if (!removed) {
      next.unshift(`${entityType}:${entityId}:${title}`)
    }
    await TravelGrowthService.writeJsonArray(TravelGrowthService.favKey(), next)
    return !removed
  }

  static async favoriteCount(): Promise<number> {
    const keys = await TravelGrowthService.readJsonArray(TravelGrowthService.favKey())
    return keys.length
  }

  private static async ensurePrepHabit(): Promise<string> {
    if (TravelGrowthService.prepHabitId.length > 0) {
      return TravelGrowthService.prepHabitId
    }
    const uid = TravelGrowthService.userId()
    if (uid.length === 0) {
      return ''
    }
    const res = await HttpClient.get<ListData<HabitRow>>(`${BASE}/habits?userId=${encodeURIComponent(uid)}`)
    if (res.code === 0 && res.data !== undefined) {
      const list = res.data.list ?? res.data.items ?? []
      for (const row of list) {
        if (row.title === PREP_HABIT_TITLE) {
          TravelGrowthService.prepHabitId = row.id
          return row.id
        }
      }
    }
    const body = new CreateHabitRequest()
    body.title = PREP_HABIT_TITLE
    body.description = '出发前每日核对清单与提醒'
    body.targetDays = 30
    body.iconKey = 'check'
    body.userId = uid
    const created = await HttpClient.post<HabitRow>(`${BASE}/habits`, body)
    if (created.code === 0 && created.data !== undefined) {
      TravelGrowthService.prepHabitId = created.data.id
      return created.data.id
    }
    return ''
  }

  static async checkInPrep(): Promise<boolean> {
    const habitId = await TravelGrowthService.ensurePrepHabit()
    if (habitId.length === 0) {
      return false
    }
    const body = new CreateHabitLogRequest()
    body.habitId = habitId
    body.userId = TravelGrowthService.userId()
    body.logDate = TravelGrowthService.todayStr()
    const res = await HttpClient.post<HabitLogRow>(`${BASE}/habit-logs`, body)
    return res.code === 0
  }

  static async prepCheckedToday(): Promise<boolean> {
    const habitId = await TravelGrowthService.ensurePrepHabit()
    if (habitId.length === 0) {
      return false
    }
    const uid = encodeURIComponent(TravelGrowthService.userId())
    const today = TravelGrowthService.todayStr()
    const res = await HttpClient.get<ListData<HabitLogRow>>(
      `${BASE}/habit-logs?userId=${uid}&habitId=${encodeURIComponent(habitId)}&logDate=${today}`
    )
    if (res.code !== 0 || res.data === undefined) {
      return false
    }
    const list = res.data.list ?? res.data.items ?? []
    return list.length > 0
  }

  static async prepStreakDays(): Promise<number> {
    const habitId = await TravelGrowthService.ensurePrepHabit()
    if (habitId.length === 0) {
      return 0
    }
    const uid = encodeURIComponent(TravelGrowthService.userId())
    const res = await HttpClient.get<ListData<HabitRow>>(`${BASE}/habits?userId=${uid}`)
    if (res.code !== 0 || res.data === undefined) {
      return 0
    }
    const list = res.data.list ?? res.data.items ?? []
    for (const row of list) {
      if (row.id === habitId) {
        return row.streakDays > 0 ? row.streakDays : 0
      }
    }
    return 0
  }

  static computeStats(
    trips: TripItem[],
    checklist: ChecklistItem[],
    favorites: TravelFavorite[],
    streak: number,
    notes: NoteItem[],
    reminders: ReminderItem[]
  ): TravelStatsSnapshot {
    const stats = new TravelStatsSnapshot()
    stats.tripCount = trips.length
    stats.favoriteCount = favorites.length
    stats.prepStreakDays = streak
    stats.noteCount = notes.length
    const destSet: string[] = []
    for (const trip of trips) {
      if (TravelService.tripPhase(trip) === '已结束') {
        stats.completedTrips += 1
      }
      if (trip.destination.length > 0 && !destSet.includes(trip.destination)) {
        destSet.push(trip.destination)
      }
    }
    stats.destinationCount = destSet.length
    for (const row of checklist) {
      stats.checklistTotal += 1
      if (row.completed) {
        stats.checklistDone += 1
      }
    }
    for (const row of reminders) {
      if (!row.completed) {
        stats.reminderPending += 1
      }
    }
    return stats
  }

  static buildActivities(
    trips: TripItem[],
    checklist: ChecklistItem[],
    notes: NoteItem[],
    favorites: TravelFavorite[]
  ): ActivityEvent[] {
    const out: ActivityEvent[] = []
    for (const trip of trips) {
      const ev = new ActivityEvent()
      ev.id = `trip_${trip.id}`
      ev.eventType = 'trip'
      ev.title = `创建行程「${trip.title}」`
      ev.subtitle = `${trip.destination} · ${trip.startDate}`
      ev.occurredAt = trip.startDate
      ev.tripId = trip.id
      ev.entityId = trip.id
      out.push(ev)
    }
    for (const row of checklist) {
      if (!row.completed) {
        continue
      }
      const ev = new ActivityEvent()
      ev.id = `chk_${row.id}`
      ev.eventType = 'checklist'
      ev.title = `完成清单「${row.title}」`
      ev.subtitle = row.category
      ev.entityId = row.id
      ev.tripId = row.tripId
      out.push(ev)
    }
    for (const note of notes) {
      const ev = new ActivityEvent()
      ev.id = `note_${note.id}`
      ev.eventType = 'note'
      ev.title = `更新备忘「${note.title}」`
      ev.subtitle = note.body.length > 24 ? `${note.body.substring(0, 24)}…` : note.body
      ev.occurredAt = note.updatedAt
      ev.entityId = note.id
      ev.tripId = note.tripId
      out.push(ev)
    }
    for (const fav of favorites) {
      const ev = new ActivityEvent()
      ev.id = `fav_${fav.id}`
      ev.eventType = 'favorite'
      ev.title = `收藏「${fav.title}」`
      ev.subtitle = fav.entityType
      ev.entityId = fav.entityId
      out.push(ev)
    }
    return out.slice(0, 12)
  }

  static evaluateAchievements(stats: TravelStatsSnapshot, streak: number): AchievementItem[] {
    const defs: AchievementItem[] = []
    const a1 = new AchievementItem()
    a1.key = 'first_trip'
    a1.title = '初次规划'
    a1.description = '创建第一条行程'
    a1.unlocked = stats.tripCount >= 1
    a1.iconKey = 'biz'
    defs.push(a1)
    const a2 = new AchievementItem()
    a2.key = 'checklist_10'
    a2.title = '清单达人'
    a2.description = '累计完成 10 项打包清单'
    a2.unlocked = stats.checklistDone >= 10
    a2.iconKey = 'check'
    defs.push(a2)
    const a3 = new AchievementItem()
    a3.key = 'streak_7'
    a3.title = '连续准备'
    a3.description = '出发前准备连续打卡 7 天'
    a3.unlocked = streak >= 7
    a3.iconKey = 'refresh'
    defs.push(a3)
    const a4 = new AchievementItem()
    a4.key = 'favorite_5'
    a4.title = '收藏达人'
    a4.description = '收藏 5 条模板或贴士'
    a4.unlocked = stats.favoriteCount >= 5
    a4.iconKey = 'star'
    defs.push(a4)
    const a5 = new AchievementItem()
    a5.key = 'trip_3'
    a5.title = '出行常客'
    a5.description = '累计创建 3 次行程'
    a5.unlocked = stats.tripCount >= 3
    a5.iconKey = 'chart'
    defs.push(a5)
    const a6 = new AchievementItem()
    a6.key = 'dest_3'
    a6.title = '足迹延伸'
    a6.description = '记录 3 个不同目的地'
    a6.unlocked = stats.destinationCount >= 3
    a6.iconKey = 'home'
    defs.push(a6)
    const a7 = new AchievementItem()
    a7.key = 'complete_trip'
    a7.title = '圆满返程'
    a7.description = '完成一次已结束行程'
    a7.unlocked = stats.completedTrips >= 1
    a7.iconKey = 'check'
    defs.push(a7)
    const a8 = new AchievementItem()
    a8.key = 'note_5'
    a8.title = '旅途记录者'
    a8.description = '写下 5 条旅途备忘'
    a8.unlocked = stats.noteCount >= 5
    a8.iconKey = 'message'
    defs.push(a8)
    return defs
  }

  static searchAll(
    query: string,
    trips: TripItem[],
    checklist: ChecklistItem[],
    notes: NoteItem[],
    templates: TravelTemplate[],
    tips: TravelTip[]
  ): SearchResultItem[] {
    const q = query.trim().toLowerCase()
    if (q.length === 0) {
      return []
    }
    const out: SearchResultItem[] = []
    const push = (group: string, entityType: string, id: string, title: string, subtitle: string): void => {
      const hay = `${title} ${subtitle}`.toLowerCase()
      if (!hay.includes(q)) {
        return
      }
      const row = new SearchResultItem()
      row.group = group
      row.entityType = entityType
      row.id = id
      row.title = title
      row.subtitle = subtitle
      out.push(row)
    }
    for (const trip of trips) {
      push('行程', 'trip', trip.id, trip.title, `${trip.destination} ${trip.summary}`)
    }
    for (const row of checklist) {
      push('清单', 'checklist', row.id, row.title, row.category)
    }
    for (const note of notes) {
      push('备忘', 'note', note.id, note.title, note.body)
    }
    for (const tpl of templates) {
      push('模板', 'template', tpl.id, tpl.title, `${tpl.destination} ${tpl.summary}`)
    }
    for (const tip of tips) {
      push('贴士', 'tip', tip.id, tip.title, tip.summary)
    }
    return out
  }

  static async buildRecaps(trips: TripItem[], checklist: ChecklistItem[]): Promise<TripRecapItem[]> {
    const out: TripRecapItem[] = []
    for (const trip of trips) {
      if (TravelService.tripPhase(trip) !== '已结束') {
        continue
      }
      const recap = new TripRecapItem()
      recap.tripId = trip.id
      recap.title = trip.title
      recap.destination = trip.destination
      recap.startDate = trip.startDate
      recap.endDate = trip.endDate
      recap.progress = trip.progress
      let done = 0
      let total = 0
      for (const row of checklist) {
        if (row.tripId === trip.id) {
          total += 1
          if (row.completed) {
            done += 1
          }
        }
      }
      recap.checklistDone = done
      recap.checklistTotal = total
      const timeline = await TravelService.itinerary(trip.id)
      recap.itineraryCount = timeline.length
      const notes = await TravelService.notes()
      let noteCount = 0
      for (const note of notes) {
        if (note.tripId === trip.id) {
          noteCount += 1
        }
      }
      recap.noteCount = noteCount
      out.push(recap)
    }
    return out
  }
}
