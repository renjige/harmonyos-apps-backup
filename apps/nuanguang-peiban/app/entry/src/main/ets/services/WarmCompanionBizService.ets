import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import { WarmCompanionLocalStore } from './WarmCompanionLocalStore'
import {
  BadgeItem,
  BadgeListPayload,
  BadgeWire,
  BreathModeItem,
  BreathModeListPayload,
  BreathModeWire,
  BreathSessionBody,
  BreathSessionItem,
  BreathSessionListPayload,
  BreathSessionWire,
  DailyPayload,
  EmptyOk,
  MoodBody,
  MoodFeedbackItem,
  MoodFeedbackPayload,
  MoodFeedbackWire,
  MoodItem,
  MoodListPayload,
  MoodWire,
  NoiseTrackItem,
  NoiseTrackListPayload,
  NoiseTrackWire,
  QuoteItem,
  QuoteListPayload,
  QuoteWire,
  WarmCompanionStats
} from '../models/WarmCompanionModels'

export class WarmCompanionBizService {
  static async loadDailyQuote(): Promise<QuoteItem | undefined> {
    const res = await HttpClient.get<DailyPayload>('/biz/warm-companion/daily')
    if (res.code === 0 && res.data !== undefined && res.data.quote !== undefined) {
      return QuoteItem.fromWire(res.data.quote)
    }
    const all = await WarmCompanionBizService.loadQuotes()
    if (all.length > 0) {
      return all[0]
    }
    return undefined
  }

  static async loadQuotes(): Promise<QuoteItem[]> {
    const res = await HttpClient.get<QuoteListPayload>('/biz/warm-companion/quotes')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: QuoteItem[] = []
      for (const w of res.data.list) {
        out.push(QuoteItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findQuote(id: string): Promise<QuoteItem | undefined> {
    const res = await HttpClient.get<QuoteWire>(`/biz/warm-companion/quotes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return QuoteItem.fromWire(res.data)
    }
    const all = await WarmCompanionBizService.loadQuotes()
    for (const q of all) {
      if (q.id === id) {
        return q
      }
    }
    return undefined
  }

  static async loadBreathModes(): Promise<BreathModeItem[]> {
    const res = await HttpClient.get<BreathModeListPayload>('/biz/warm-companion/breath-modes')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: BreathModeItem[] = []
      for (const w of res.data.list) {
        out.push(BreathModeItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async findBreathMode(id: string): Promise<BreathModeItem | undefined> {
    const res = await HttpClient.get<BreathModeWire>(`/biz/warm-companion/breath-modes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return BreathModeItem.fromWire(res.data)
    }
    const all = await WarmCompanionBizService.loadBreathModes()
    for (const m of all) {
      if (m.id === id) {
        return m
      }
    }
    return undefined
  }

  static async loadNoiseTracks(): Promise<NoiseTrackItem[]> {
    const res = await HttpClient.get<NoiseTrackListPayload>('/biz/warm-companion/noise-tracks')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: NoiseTrackItem[] = []
      for (const w of res.data.list) {
        out.push(NoiseTrackItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async loadMoodFeedback(mood: string): Promise<MoodFeedbackItem | undefined> {
    const res = await HttpClient.get<MoodFeedbackPayload>(`/biz/warm-companion/mood-feedback?mood=${mood}`)
    if (res.code === 0 && res.data !== undefined) {
      if (res.data.feedback !== undefined) {
        return MoodFeedbackItem.fromWire(res.data.feedback)
      }
      if (res.data.list !== undefined && res.data.list.length > 0) {
        return MoodFeedbackItem.fromWire(res.data.list[0])
      }
    }
    return undefined
  }

  static async loadBadges(): Promise<BadgeItem[]> {
    const res = await HttpClient.get<BadgeListPayload>('/biz/warm-companion/badges')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: BadgeItem[] = []
      for (const w of res.data.list) {
        out.push(BadgeItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async recordMood(mood: string, body: string, noteDate: string): Promise<boolean> {
    if (AuthService.isLoggedIn()) {
      const uid = AuthService.currentUsername()
      const req = new MoodBody()
      req.mood = mood
      req.body = body
      req.noteDate = noteDate
      req.userId = uid
      const res = await HttpClient.post<MoodWire>('/biz/warm-companion/moods', req)
      return res.code === 0
    }
    await WarmCompanionLocalStore.saveMoodRecord(mood, body, noteDate)
    return true
  }

  static async loadMoods(): Promise<MoodItem[]> {
    if (AuthService.isLoggedIn()) {
      const uid = AuthService.currentUsername()
      const res = await HttpClient.get<MoodListPayload>(`/biz/warm-companion/moods?userId=${uid}`)
      if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
        const out: MoodItem[] = []
        for (const w of res.data.list) {
          out.push(MoodItem.fromWire(w))
        }
        return out
      }
      return []
    }
    return WarmCompanionLocalStore.loadMoods()
  }

  static async deleteMood(id: string): Promise<boolean> {
    if (AuthService.isLoggedIn()) {
      const uid = AuthService.currentUsername()
      const res = await HttpClient.delete<EmptyOk>(`/biz/warm-companion/moods/${id}?userId=${uid}`, new EmptyOk())
      return res.code === 0
    }
    await WarmCompanionLocalStore.deleteMood(id)
    return true
  }

  static async recordBreathSession(modeId: string, title: string, durationSec: number, noteDate: string): Promise<boolean> {
    if (AuthService.isLoggedIn()) {
      const uid = AuthService.currentUsername()
      const body = new BreathSessionBody()
      body.modeId = modeId
      body.title = title
      body.durationSec = durationSec
      body.noteDate = noteDate
      body.userId = uid
      const res = await HttpClient.post<BreathSessionWire>('/biz/warm-companion/breath-sessions', body)
      return res.code === 0
    }
    await WarmCompanionLocalStore.saveBreathSession(modeId, title, durationSec, noteDate)
    return true
  }

  static async loadBreathSessions(): Promise<BreathSessionItem[]> {
    if (AuthService.isLoggedIn()) {
      const uid = AuthService.currentUsername()
      const res = await HttpClient.get<BreathSessionListPayload>(`/biz/warm-companion/breath-sessions?userId=${uid}`)
      if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
        const out: BreathSessionItem[] = []
        for (const w of res.data.list) {
          out.push(BreathSessionItem.fromWire(w))
        }
        return out
      }
      return []
    }
    return WarmCompanionLocalStore.loadBreathSessions()
  }

  static async loadStats(): Promise<WarmCompanionStats> {
    const stats = new WarmCompanionStats()
    const moods = await WarmCompanionBizService.loadMoods()
    const sessions = await WarmCompanionBizService.loadBreathSessions()
    stats.moodCount = moods.length
    let secTotal = 0
    for (const s of sessions) {
      secTotal += s.durationSec
    }
    stats.breathMinutes = Math.floor(secTotal / 60)
    stats.streakDays = WarmCompanionBizService.computeStreak(moods, sessions)
    stats.companionDays = stats.streakDays
    return stats
  }

  static computeStreak(moods: MoodItem[], sessions: BreathSessionItem[]): number {
    const activeDates: string[] = []
    for (const m of moods) {
      if (m.noteDate.length > 0) {
        activeDates.push(m.noteDate)
      }
    }
    for (const s of sessions) {
      if (s.noteDate.length > 0) {
        activeDates.push(s.noteDate)
      }
    }
    const unique: string[] = []
    for (const d of activeDates) {
      let found = false
      for (const u of unique) {
        if (u === d) {
          found = true
        }
      }
      if (!found) {
        unique.push(d)
      }
    }
    if (unique.length === 0) {
      return 0
    }
    let streak = 0
    let cursor = WarmCompanionLocalStore.todayKey()
    let guard = 0
    while (guard < 400) {
      let hit = false
      for (const d of unique) {
        if (d === cursor) {
          hit = true
        }
      }
      if (!hit) {
        break
      }
      streak += 1
      const parts = cursor.split('-')
      if (parts.length !== 3) {
        break
      }
      const y = Number.parseInt(parts[0], 10)
      const mo = Number.parseInt(parts[1], 10)
      const day = Number.parseInt(parts[2], 10)
      const prev = new Date(y, mo - 1, day)
      prev.setDate(prev.getDate() - 1)
      const py = prev.getFullYear()
      const pm = prev.getMonth() + 1
      const pd = prev.getDate()
      const ms = pm < 10 ? `0${pm}` : `${pm}`
      const ds = pd < 10 ? `0${pd}` : `${pd}`
      cursor = `${py}-${ms}-${ds}`
      guard += 1
    }
    return streak
  }

  static hasRecordOnDate(moods: MoodItem[], dateKey: string): boolean {
    for (const m of moods) {
      if (m.noteDate === dateKey) {
        return true
      }
    }
    return false
  }

  static greeting(): string {
    const hour = new Date().getHours()
    if (hour < 6) {
      return '夜深了，给心留一点空白'
    }
    if (hour < 11) {
      return '早安，愿你今日被温柔以待'
    }
    if (hour < 14) {
      return '午间片刻，慢下来呼吸'
    }
    if (hour < 18) {
      return '下午好，记得关照自己'
    }
    if (hour < 22) {
      return '傍晚时分，收一收心'
    }
    return '睡前呼吸，助你好眠'
  }

  static async syncLocalRecordsToCloud(): Promise<number> {
    if (!AuthService.isLoggedIn()) {
      return 0
    }
    const uid = AuthService.currentUsername()
    if (uid.length === 0 || uid === '未登录') {
      return 0
    }
    const localMoods = await WarmCompanionLocalStore.loadMoods()
    const localSessions = await WarmCompanionLocalStore.loadBreathSessions()
    if (localMoods.length === 0 && localSessions.length === 0) {
      return 0
    }
    let count = 0
    for (const m of localMoods) {
      const ok = await WarmCompanionBizService.recordMood(m.mood, m.body, m.noteDate)
      if (ok) {
        count += 1
      }
    }
    for (const s of localSessions) {
      const ok = await WarmCompanionBizService.recordBreathSession(s.modeId, s.title, s.durationSec, s.noteDate)
      if (ok) {
        count += 1
      }
    }
    if (count > 0) {
      await WarmCompanionLocalStore.clearUserRecords()
    }
    return count
  }
}
