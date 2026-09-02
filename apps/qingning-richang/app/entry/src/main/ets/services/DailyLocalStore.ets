import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  DailyConstants, DailyQuoteItem, DailyStats, DailyTaskItem, MoodEntry, UserProfile
} from '../models/DailyModels'

const STORE = 'qingning_daily'
const KEY_MOODS = 'moods'
const KEY_TASK_DONE = 'task_done_dates'
const KEY_FAV_QUOTES = 'fav_quotes'
const KEY_PROFILE = 'profile'
const KEY_TASK_COUNT = 'task_done_count'

export class DateHelper {
  static todayKey(): string {
    const d = new Date()
    return DateHelper.keyFromDate(d)
  }

  static keyFromDate(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static weekdayLabel(d: Date): string {
    const names: string[] = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
    return names[d.getDay()]
  }

  static displayDate(d: Date): string {
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日 ${DateHelper.weekdayLabel(d)}`
  }

  static dayIndex(): number {
    const start = new Date(2026, 0, 1)
    const now = new Date()
    const diff = now.getTime() - start.getTime()
    return Math.floor(diff / 86400000)
  }

  static rotateIndex(count: number): number {
    if (count <= 0) {
      return 0
    }
    const idx = DateHelper.dayIndex() % count
    return idx < 0 ? idx + count : idx
  }
}

export class DailyLocalStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      DailyLocalStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      DailyLocalStore.pref = null
    }
  }

  static todayTask(): DailyTaskItem {
    const tasks = DailyConstants.tasks()
    const idx = DateHelper.rotateIndex(tasks.length)
    return tasks[idx]
  }

  static todayQuote(): DailyQuoteItem {
    const quotes = DailyConstants.quotes()
    const idx = DateHelper.rotateIndex(quotes.length)
    return quotes[idx]
  }

  static async isTaskDoneToday(): Promise<boolean> {
    const key = DateHelper.todayKey()
    const raw = await DailyLocalStore.getString(KEY_TASK_DONE, '')
    return raw.indexOf(key) >= 0
  }

  static async markTaskDoneToday(): Promise<void> {
    const key = DateHelper.todayKey()
    const raw = await DailyLocalStore.getString(KEY_TASK_DONE, '')
    if (raw.indexOf(key) >= 0) {
      return
    }
    const next = raw.length === 0 ? key : `${raw},${key}`
    await DailyLocalStore.putString(KEY_TASK_DONE, next)
    const count = await DailyLocalStore.getNumber(KEY_TASK_COUNT, 0)
    await DailyLocalStore.putNumber(KEY_TASK_COUNT, count + 1)
  }

  static async loadMoods(): Promise<MoodEntry[]> {
    const raw = await DailyLocalStore.getString(KEY_MOODS, '{"items":[]}')
    return DailyLocalStore.parseMoods(raw)
  }

  static async saveMood(entry: MoodEntry): Promise<void> {
    const list = await DailyLocalStore.loadMoods()
    const next: MoodEntry[] = []
    let found = false
    for (const it of list) {
      if (it.dateKey === entry.dateKey) {
        next.push(entry)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(entry)
    }
    await DailyLocalStore.saveMoods(next)
  }

  static async findMood(dateKey: string): Promise<MoodEntry | undefined> {
    const list = await DailyLocalStore.loadMoods()
    for (const it of list) {
      if (it.dateKey === dateKey) {
        return it
      }
    }
    return undefined
  }

  static async loadFavoriteQuoteIds(): Promise<string[]> {
    const raw = await DailyLocalStore.getString(KEY_FAV_QUOTES, '')
    if (raw.length === 0) {
      return []
    }
    const out: string[] = []
    const parts = raw.split(',')
    for (const p of parts) {
      if (p.length > 0) {
        out.push(p)
      }
    }
    return out
  }

  static async isQuoteFavorite(id: string): Promise<boolean> {
    const ids = await DailyLocalStore.loadFavoriteQuoteIds()
    for (const x of ids) {
      if (x === id) {
        return true
      }
    }
    return false
  }

  static async toggleQuoteFavorite(id: string): Promise<boolean> {
    const ids = await DailyLocalStore.loadFavoriteQuoteIds()
    const next: string[] = []
    let found = false
    for (const x of ids) {
      if (x === id) {
        found = true
      } else {
        next.push(x)
      }
    }
    if (!found) {
      next.push(id)
    }
    await DailyLocalStore.putString(KEY_FAV_QUOTES, next.join(','))
    return !found
  }

  static async loadProfile(): Promise<UserProfile> {
    const raw = await DailyLocalStore.getString(KEY_PROFILE, '')
    if (raw.length === 0) {
      return UserProfile.defaultProfile()
    }
    const p = UserProfile.defaultProfile()
    const nickMatch = raw.match(/"nickname":"([^"]*)"/)
    if (nickMatch !== null && nickMatch[1] !== undefined) {
      p.nickname = nickMatch[1]
    }
    return p
  }

  static async saveProfile(profile: UserProfile): Promise<void> {
    const body = `{"nickname":${JSON.stringify(profile.nickname)},"avatarKey":"default"}`
    await DailyLocalStore.putString(KEY_PROFILE, body)
  }

  static async loadStats(): Promise<DailyStats> {
    const stats = new DailyStats()
    const moods = await DailyLocalStore.loadMoods()
    stats.totalMoods = moods.length
    const favs = await DailyLocalStore.loadFavoriteQuoteIds()
    stats.favoriteCount = favs.length
    stats.taskDoneCount = await DailyLocalStore.getNumber(KEY_TASK_COUNT, 0)
    stats.streakDays = await DailyLocalStore.computeStreak()
    return stats
  }

  private static async computeStreak(): Promise<number> {
    const raw = await DailyLocalStore.getString(KEY_TASK_DONE, '')
    if (raw.length === 0) {
      return 0
    }
    const set = new Set<string>()
    const parts = raw.split(',')
    for (const p of parts) {
      if (p.length > 0) {
        set.add(p)
      }
    }
    let streak = 0
    const cursor = new Date()
    for (let i = 0; i < 365; i++) {
      const key = DateHelper.keyFromDate(cursor)
      if (set.has(key)) {
        streak++
      } else if (i > 0) {
        break
      }
      cursor.setDate(cursor.getDate() - 1)
    }
    return streak
  }

  private static async saveMoods(items: MoodEntry[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(DailyLocalStore.moodLine(it))
    }
    await DailyLocalStore.putString(KEY_MOODS, lines.join('\n'))
  }

  private static moodLine(it: MoodEntry): string {
    const note = it.note.replace(/\t/g, ' ').replace(/\n/g, ' ')
    return `${it.dateKey}\t${it.moodKey}\t${it.moodLabel}\t${note}\t${it.updatedAt}`
  }

  private static parseMoods(raw: string): MoodEntry[] {
    const out: MoodEntry[] = []
    if (raw.length === 0 || raw.indexOf('{"items"') === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 5) {
        continue
      }
      const e = MoodEntry.create(parts[0], parts[1], parts[2], parts[3])
      e.updatedAt = parseInt(parts[4], 10)
      out.push(e)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (DailyLocalStore.pref === null) {
      return fallback
    }
    try {
      const v = await DailyLocalStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (DailyLocalStore.pref === null) {
      return
    }
    try {
      await DailyLocalStore.pref.put(key, value)
      await DailyLocalStore.pref.flush()
    } catch {
      // ignore
    }
  }

  private static async getNumber(key: string, fallback: number): Promise<number> {
    if (DailyLocalStore.pref === null) {
      return fallback
    }
    try {
      const v = await DailyLocalStore.pref.get(key, fallback)
      return typeof v === 'number' ? v : parseInt(`${v}`, 10)
    } catch {
      return fallback
    }
  }

  private static async putNumber(key: string, value: number): Promise<void> {
    if (DailyLocalStore.pref === null) {
      return
    }
    try {
      await DailyLocalStore.pref.put(key, value)
      await DailyLocalStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
