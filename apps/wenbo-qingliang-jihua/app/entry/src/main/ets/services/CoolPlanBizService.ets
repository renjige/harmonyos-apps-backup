import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import { CoolPlanLocalStore } from './CoolPlanLocalStore'
import {
  BreathModeItem,
  BreathModeListPayload,
  BreathModeWire,
  BreathSessionBody,
  BreathSessionItem,
  BreathSessionListPayload,
  BreathSessionWire,
  CoolPlanStats,
  DailyPayload,
  EmptyOk,
  JournalBody,
  JournalItem,
  JournalListPayload,
  JournalUpdateBody,
  JournalWire,
  MoodBody,
  MoodItem,
  MoodListPayload,
  MoodWire,
  QuoteItem,
  QuoteListPayload,
  QuoteWire
} from '../models/CoolPlanModels'

export class CoolPlanBizService {
  static async loadDailyQuote(): Promise<QuoteItem | undefined> {
    const res = await HttpClient.get<DailyPayload>('/biz/cool-plan/daily')
    if (res.code === 0 && res.data !== undefined && res.data.quote !== undefined) {
      return QuoteItem.fromWire(res.data.quote)
    }
    const all = await CoolPlanBizService.loadQuotes()
    if (all.length > 0) {
      return all[0]
    }
    return undefined
  }

  static async loadQuotes(): Promise<QuoteItem[]> {
    const res = await HttpClient.get<QuoteListPayload>('/biz/cool-plan/quotes')
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
    const res = await HttpClient.get<QuoteWire>(`/biz/cool-plan/quotes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return QuoteItem.fromWire(res.data)
    }
    const all = await CoolPlanBizService.loadQuotes()
    for (const q of all) {
      if (q.id === id) {
        return q
      }
    }
    return undefined
  }

  static async loadBreathModes(): Promise<BreathModeItem[]> {
    const res = await HttpClient.get<BreathModeListPayload>('/biz/cool-plan/breath-modes')
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
    const res = await HttpClient.get<BreathModeWire>(`/biz/cool-plan/breath-modes/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return BreathModeItem.fromWire(res.data)
    }
    const all = await CoolPlanBizService.loadBreathModes()
    for (const m of all) {
      if (m.id === id) {
        return m
      }
    }
    return undefined
  }

  static async recordMood(mood: string, noteDate: string): Promise<boolean> {
    const coolIndex = CoolPlanLocalStore.moodBaseIndex(mood)
    if (AuthService.isLoggedIn()) {
      const uid = AuthService.currentUsername()
      const body = new MoodBody()
      body.mood = mood
      body.noteDate = noteDate
      body.coolIndex = coolIndex
      body.userId = uid
      const res = await HttpClient.post<MoodWire>('/biz/cool-plan/moods', body)
      return res.code === 0
    }
    await CoolPlanLocalStore.saveMood(mood, noteDate, coolIndex)
    return true
  }

  static async loadMoods(): Promise<MoodItem[]> {
    if (AuthService.isLoggedIn()) {
      const uid = AuthService.currentUsername()
      const res = await HttpClient.get<MoodListPayload>(`/biz/cool-plan/moods?userId=${uid}`)
      if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
        const out: MoodItem[] = []
        for (const w of res.data.list) {
          out.push(MoodItem.fromWire(w))
        }
        return out
      }
      return []
    }
    return CoolPlanLocalStore.loadMoods()
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
      const res = await HttpClient.post<BreathSessionWire>('/biz/cool-plan/breath-sessions', body)
      return res.code === 0
    }
    await CoolPlanLocalStore.saveBreathSession(modeId, title, durationSec, noteDate)
    return true
  }

  static async loadBreathSessions(): Promise<BreathSessionItem[]> {
    if (AuthService.isLoggedIn()) {
      const uid = AuthService.currentUsername()
      const res = await HttpClient.get<BreathSessionListPayload>(`/biz/cool-plan/breath-sessions?userId=${uid}`)
      if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
        const out: BreathSessionItem[] = []
        for (const w of res.data.list) {
          out.push(BreathSessionItem.fromWire(w))
        }
        return out
      }
      return []
    }
    return CoolPlanLocalStore.loadBreathSessions()
  }

  static async saveJournal(title: string, bodyText: string, mood: string, noteDate: string): Promise<boolean> {
    if (AuthService.isLoggedIn()) {
      const uid = AuthService.currentUsername()
      const journals = await CoolPlanBizService.loadJournals()
      let existingId = ''
      for (const j of journals) {
        if (j.noteDate === noteDate) {
          existingId = j.id
        }
      }
      if (existingId.length > 0) {
        const body = new JournalUpdateBody()
        body.title = title
        body.body = bodyText
        body.mood = mood
        body.userId = uid
        const res = await HttpClient.put<JournalWire>(`/biz/cool-plan/journals/${existingId}`, body)
        return res.code === 0
      }
      const body = new JournalBody()
      body.title = title
      body.body = bodyText
      body.mood = mood
      body.noteDate = noteDate
      body.userId = uid
      const res = await HttpClient.post<JournalWire>('/biz/cool-plan/journals', body)
      return res.code === 0
    }
    await CoolPlanLocalStore.saveJournal(title, bodyText, mood, noteDate)
    return true
  }

  static async deleteJournal(id: string): Promise<boolean> {
    if (AuthService.isLoggedIn()) {
      const uid = AuthService.currentUsername()
      const res = await HttpClient.delete<EmptyOk>(`/biz/cool-plan/journals/${id}?userId=${uid}`, new EmptyOk())
      return res.code === 0
    }
    await CoolPlanLocalStore.deleteJournal(id)
    return true
  }

  static async deleteMood(id: string): Promise<boolean> {
    if (AuthService.isLoggedIn()) {
      const uid = AuthService.currentUsername()
      const res = await HttpClient.delete<EmptyOk>(`/biz/cool-plan/moods/${id}?userId=${uid}`, new EmptyOk())
      return res.code === 0
    }
    await CoolPlanLocalStore.deleteMood(id)
    return true
  }

  static async moodForDate(noteDate: string): Promise<MoodItem | undefined> {
    const moods = await CoolPlanBizService.loadMoods()
    for (const m of moods) {
      if (m.noteDate === noteDate) {
        return m
      }
    }
    return undefined
  }

  static async journalForDate(noteDate: string): Promise<JournalItem | undefined> {
    const journals = await CoolPlanBizService.loadJournals()
    for (const j of journals) {
      if (j.noteDate === noteDate) {
        return j
      }
    }
    return undefined
  }

  static async loadJournals(): Promise<JournalItem[]> {
    if (AuthService.isLoggedIn()) {
      const uid = AuthService.currentUsername()
      const res = await HttpClient.get<JournalListPayload>(`/biz/cool-plan/journals?userId=${uid}`)
      if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
        const out: JournalItem[] = []
        for (const w of res.data.list) {
          out.push(JournalItem.fromWire(w))
        }
        return out
      }
      return []
    }
    return CoolPlanLocalStore.loadJournals()
  }

  static async todayCoolIndex(): Promise<number> {
    const today = CoolPlanLocalStore.todayKey()
    const moods = await CoolPlanBizService.loadMoods()
    let base = 60
    for (const m of moods) {
      if (m.noteDate === today) {
        base = m.coolIndex > 0 ? m.coolIndex : CoolPlanLocalStore.moodBaseIndex(m.mood)
      }
    }
    const sessions = await CoolPlanBizService.loadBreathSessions()
    let bonus = 0
    for (const s of sessions) {
      if (s.noteDate === today) {
        bonus += 3
      }
    }
    if (bonus > 15) {
      bonus = 15
    }
    const total = base + bonus
    return total > 100 ? 100 : total
  }

  static async loadStats(): Promise<CoolPlanStats> {
    const stats = new CoolPlanStats()
    const moods = await CoolPlanBizService.loadMoods()
    const sessions = await CoolPlanBizService.loadBreathSessions()
    const journals = await CoolPlanBizService.loadJournals()
    stats.moodCount = moods.length
    stats.journalCount = journals.length
    let secTotal = 0
    for (const s of sessions) {
      secTotal += s.durationSec
    }
    stats.breathMinutes = Math.floor(secTotal / 60)
    stats.todayCoolIndex = await CoolPlanBizService.todayCoolIndex()
    stats.streakDays = CoolPlanBizService.computeStreak(moods, sessions, journals)
    return stats
  }

  static computeStreak(moods: MoodItem[], sessions: BreathSessionItem[], journals: JournalItem[]): number {
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
    for (const j of journals) {
      if (j.noteDate.length > 0) {
        activeDates.push(j.noteDate)
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
    let cursor = CoolPlanLocalStore.todayKey()
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

  static greeting(): string {
    const hour = new Date().getHours()
    if (hour < 6) {
      return '夜深了，给心留一点空白'
    }
    if (hour < 11) {
      return '早安，愿你今日清凉'
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

  /** 登录成功后：将游客本机心情/呼吸/心语 upsert 到云端，再清空本机副本 */
  static async syncLocalRecordsToCloud(): Promise<number> {
    if (!AuthService.isLoggedIn()) {
      return 0
    }
    const uid = AuthService.currentUsername()
    if (uid.length === 0 || uid === '未登录') {
      return 0
    }
    const localMoods = await CoolPlanLocalStore.loadMoods()
    const localSessions = await CoolPlanLocalStore.loadBreathSessions()
    const localJournals = await CoolPlanLocalStore.loadJournals()
    if (localMoods.length === 0 && localSessions.length === 0 && localJournals.length === 0) {
      return 0
    }
    let count = 0
    for (const m of localMoods) {
      const body = new MoodBody()
      body.mood = m.mood
      body.noteDate = m.noteDate
      body.coolIndex = m.coolIndex > 0 ? m.coolIndex : CoolPlanLocalStore.moodBaseIndex(m.mood)
      body.userId = uid
      const res = await HttpClient.post<MoodWire>('/biz/cool-plan/moods', body)
      if (res.code === 0) {
        count += 1
      }
    }
    for (const j of localJournals) {
      const ok = await CoolPlanBizService.saveJournal(j.title, j.body, j.mood, j.noteDate)
      if (ok) {
        count += 1
      }
    }
    for (const s of localSessions) {
      const body = new BreathSessionBody()
      body.modeId = s.modeId
      body.title = s.title
      body.durationSec = s.durationSec
      body.noteDate = s.noteDate
      body.userId = uid
      const res = await HttpClient.post<BreathSessionWire>('/biz/cool-plan/breath-sessions', body)
      if (res.code === 0) {
        count += 1
      }
    }
    if (count > 0) {
      await CoolPlanLocalStore.clearUserRecords()
    }
    return count
  }
}
