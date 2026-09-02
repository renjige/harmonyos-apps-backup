import { HttpClient } from './HttpClient'
import {
  AchievementItem,
  AchievementListData,
  CalendarMarksData,
  CompleteMicroGoalBody,
  CreateMicroGoalBody,
  InsightItem,
  InsightListData,
  MicroGoalItem,
  MicroGoalListData,
  MicroGoalStats,
  UserIdBody,
  mapAchievements,
  mapInsights,
  mapMicroGoals,
} from '../models/MicroGoalModels'

export class StepBizService {
  static todayKey(): string {
    return new Date().toISOString().slice(0, 10)
  }

  static currentUserId(): string {
    return AppStorage.get<string>('currentUsername') ?? ''
  }

  static async loadTodayGoals(): Promise<MicroGoalItem[]> {
    const uid = StepBizService.currentUserId()
    const date = StepBizService.todayKey()
    const q = uid.length > 0 ? `?userId=${encodeURIComponent(uid)}&date=${date}` : `?date=${date}`
    const res = await HttpClient.get<MicroGoalListData>(`/biz/morning-habit/micro-goals${q}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return mapMicroGoals(res.data.list as object[])
    }
    return []
  }

  static async loadGoalsByDate(date: string): Promise<MicroGoalItem[]> {
    const uid = StepBizService.currentUserId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<MicroGoalListData>(
      `/biz/morning-habit/micro-goals?userId=${encodeURIComponent(uid)}&date=${date}`,
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return mapMicroGoals(res.data.list as object[])
    }
    return []
  }

  static async createGoal(title: string, description: string, category: string): Promise<MicroGoalItem | null> {
    const body = new CreateMicroGoalBody()
    body.title = title
    body.description = description
    body.category = category
    body.goalDate = StepBizService.todayKey()
    body.userId = StepBizService.currentUserId()
    const res = await HttpClient.post<MicroGoalItem>('/biz/morning-habit/micro-goals', body)
    if (res.code === 0 && res.data !== undefined) {
      return mapMicroGoals([res.data as object])[0]
    }
    return null
  }

  static async completeGoal(id: string, note: string): Promise<boolean> {
    const body = new CompleteMicroGoalBody()
    body.note = note
    body.userId = StepBizService.currentUserId()
    const res = await HttpClient.post<MicroGoalItem>(
      `/biz/morning-habit/micro-goals/${id}/complete`,
      body,
    )
    return res.code === 0
  }

  static async deleteGoal(id: string): Promise<boolean> {
    const body = new UserIdBody()
    body.userId = StepBizService.currentUserId()
    const res = await HttpClient.post<object>(`/biz/morning-habit/micro-goals/${id}/delete`, body)
    return res.code === 0
  }

  static async loadStats(): Promise<MicroGoalStats> {
    const uid = StepBizService.currentUserId()
    const fallback = new MicroGoalStats()
    if (uid.length === 0) {
      return fallback
    }
    const res = await HttpClient.get<MicroGoalStats>(
      `/biz/morning-habit/micro-stats?userId=${encodeURIComponent(uid)}`,
    )
    if (res.code === 0 && res.data !== undefined) {
      const s = new MicroGoalStats()
      const d = res.data as MicroGoalStats
      s.streakDays = d.streakDays ?? 0
      s.completionRate = d.completionRate ?? 0
      s.totalDoneDays = d.totalDoneDays ?? 0
      s.monthDoneDays = d.monthDoneDays ?? 0
      s.monthTotalDays = d.monthTotalDays ?? new Date().getDate()
      s.todayTotal = d.todayTotal ?? 0
      s.todayDone = d.todayDone ?? 0
      return s
    }
    return fallback
  }

  static async loadCalendar(): Promise<CalendarMarksData> {
    const uid = StepBizService.currentUserId()
    const empty = new CalendarMarksData()
    if (uid.length === 0) {
      return empty
    }
    const res = await HttpClient.get<CalendarMarksData>(
      `/biz/morning-habit/micro-stats?userId=${encodeURIComponent(uid)}`,
    )
    if (res.code === 0 && res.data !== undefined) {
      const out = new CalendarMarksData()
      const d = res.data as CalendarMarksData
      out.calendarMarks = d.calendarMarks ?? {}
      out.categoryStats = d.categoryStats ?? {}
      return out
    }
    return empty
  }

  static async loadJournal(keyword: string): Promise<MicroGoalItem[]> {
    const uid = StepBizService.currentUserId()
    if (uid.length === 0) {
      return []
    }
    const q = keyword.length > 0
      ? `?userId=${encodeURIComponent(uid)}&keyword=${encodeURIComponent(keyword)}`
      : `?userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<MicroGoalListData>(`/biz/morning-habit/journal${q}`)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return mapMicroGoals(res.data.list as object[])
    }
    return []
  }

  static async loadInsights(): Promise<InsightItem[]> {
    const res = await HttpClient.get<InsightListData>('/biz/morning-habit/insights')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return mapInsights(res.data.list as object[])
    }
    return []
  }

  static async loadAchievements(): Promise<AchievementItem[]> {
    const res = await HttpClient.get<AchievementListData>('/biz/morning-habit/achievements')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return mapAchievements(res.data.list as object[])
    }
    return []
  }

  static suggestMicroGoals(history: MicroGoalItem[], templates: InsightItem[]): string[] {
    const out: string[] = []
    const seen = new Set<string>()
    for (const h of history) {
      if (h.category.length > 0 && !seen.has(h.title)) {
        seen.add(h.title)
        out.push(h.title)
      }
      if (out.length >= 2) {
        break
      }
    }
    const defaults = ['读 5 页书', '做 10 个深蹲', '写 3 行日记', '整理桌面 5 分钟', '深呼吸 2 分钟']
    for (const d of defaults) {
      if (out.length >= 3) {
        break
      }
      if (!seen.has(d)) {
        out.push(d)
        seen.add(d)
      }
    }
    if (templates.length > 0 && out.length < 3) {
      out.push(`参考：${templates[0].title}`)
    }
    return out.slice(0, 3)
  }
}
