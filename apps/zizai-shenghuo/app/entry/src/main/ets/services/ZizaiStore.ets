import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  DayWeatherMock, HabitDayRecord, HabitDef, MoodOption, MoodRecord, TodoItem, UserProfile, WisdomItem
} from '../models/ZizaiModels'
import { WisdomData } from '../constants/WisdomData'
import { DateHelper } from './DateHelper'

const STORE = 'zizai_local_v1'
const KEY_MOODS = 'moods'
const KEY_FAVS = 'fav_wisdom'
const KEY_TODOS = 'todos'
const KEY_HABITS = 'habit_days'
const KEY_PROFILE = 'profile'

export class ZizaiStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ZizaiStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ZizaiStore.pref = null
    }
    await ZizaiStore.ensureTodayTodos()
  }

  static defaultHabits(): HabitDef[] {
    const defs: string[][] = [
      ['h1', '早起', 'refresh'],
      ['h2', '饮水', 'check'],
      ['h3', '运动', 'biz'],
      ['h4', '阅读', 'message'],
      ['h5', '早睡', 'home'],
      ['h6', '感恩', 'star']
    ]
    const out: HabitDef[] = []
    for (const d of defs) {
      const h = new HabitDef()
      h.id = d[0]
      h.title = d[1]
      h.iconName = d[2]
      out.push(h)
    }
    return out
  }

  static defaultTodos(): TodoItem[] {
    const defs: string[][] = [
      ['t1', '今日运动 20 分钟', '运动'],
      ['t2', '阅读 10 页', '阅读'],
      ['t3', '23:00 前休息', '作息'],
      ['t4', '喝够 8 杯水', '健康']
    ]
    const out: TodoItem[] = []
    for (const d of defs) {
      const t = new TodoItem()
      t.id = d[0]
      t.title = d[1]
      t.category = d[2]
      out.push(t)
    }
    return out
  }

  static todayWisdom(): WisdomItem {
    return WisdomData.forToday()
  }

  static weatherMock(): DayWeatherMock {
    const w = new DayWeatherMock()
    const m = new Date().getMonth() + 1
    if (m >= 3 && m <= 5) {
      w.condition = '晴间多云'
      w.tempHigh = 24
      w.tempLow = 14
      w.solarTerm = '春分前后 · 万物生长'
    } else if (m >= 6 && m <= 8) {
      w.condition = '多云'
      w.tempHigh = 32
      w.tempLow = 24
      w.solarTerm = '夏至前后 · 昼长夜短'
    } else if (m >= 9 && m <= 11) {
      w.condition = '凉爽'
      w.tempHigh = 22
      w.tempLow = 12
      w.solarTerm = '秋分前后 · 天高气爽'
    } else {
      w.condition = '晴'
      w.tempHigh = 12
      w.tempLow = 2
      w.solarTerm = '冬至前后 · 宜早休息'
    }
    return w
  }

  static async loadFavorites(): Promise<string[]> {
    const raw = await ZizaiStore.getString(KEY_FAVS, '')
    if (raw.length === 0) {
      return []
    }
    return raw.split(',').filter((s: string) => s.length > 0)
  }

  static async isFavorite(wisdomId: string): Promise<boolean> {
    const favs = await ZizaiStore.loadFavorites()
    for (const id of favs) {
      if (id === wisdomId) {
        return true
      }
    }
    return false
  }

  static async toggleFavorite(wisdomId: string): Promise<boolean> {
    const favs = await ZizaiStore.loadFavorites()
    const next: string[] = []
    let removed = false
    for (const id of favs) {
      if (id === wisdomId) {
        removed = true
      } else {
        next.push(id)
      }
    }
    if (!removed) {
      next.push(wisdomId)
    }
    await ZizaiStore.setString(KEY_FAVS, next.join(','))
    return !removed
  }

  static async loadMood(dateKey: string): Promise<MoodRecord | undefined> {
    const all = await ZizaiStore.loadAllMoods()
    for (const m of all) {
      if (m.dateKey === dateKey) {
        return m
      }
    }
    return undefined
  }

  static async loadAllMoods(): Promise<MoodRecord[]> {
    const raw = await ZizaiStore.getString(KEY_MOODS, '')
    if (raw.length === 0) {
      return []
    }
    const lines = raw.split('\n')
    const out: MoodRecord[] = []
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 5) {
        continue
      }
      const m = new MoodRecord()
      m.dateKey = parts[0]
      m.moodKey = parts[1]
      m.moodLabel = parts[2]
      m.note = parts[3]
      m.gratitude = parts[4].split('|').filter((g: string) => g.length > 0)
      m.updatedAt = parts.length >= 6 ? parseInt(parts[5], 10) : 0
      out.push(m)
    }
    out.sort((a, b) => b.dateKey.localeCompare(a.dateKey))
    return out
  }

  static async saveMood(moodKey: string, note: string, gratitude: string[]): Promise<void> {
    const opt = MoodOption.find(moodKey)
    const rec = new MoodRecord()
    rec.dateKey = DateHelper.todayKey()
    rec.moodKey = moodKey
    rec.moodLabel = opt !== undefined ? opt.label : '一般'
    rec.note = note.trim()
    rec.gratitude = gratitude.filter((g: string) => g.trim().length > 0).slice(0, 3)
    rec.updatedAt = Date.now()
    const all = await ZizaiStore.loadAllMoods()
    const next: MoodRecord[] = []
    for (const m of all) {
      if (m.dateKey !== rec.dateKey) {
        next.push(m)
      }
    }
    next.push(rec)
    await ZizaiStore.persistMoods(next)
  }

  static async moodKeysInMonth(year: number, month: number): Promise<string[]> {
    const prefix = `${year}-${month < 10 ? '0' : ''}${month}`
    const all = await ZizaiStore.loadAllMoods()
    const keys: string[] = []
    for (const m of all) {
      if (m.dateKey.startsWith(prefix)) {
        keys.push(m.dateKey)
      }
    }
    return keys
  }

  static async loadTodos(): Promise<TodoItem[]> {
    const raw = await ZizaiStore.getString(KEY_TODOS, '')
    if (raw.length === 0) {
      return ZizaiStore.defaultTodos()
    }
    const lines = raw.split('\n')
    const out: TodoItem[] = []
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 4) {
        continue
      }
      const t = new TodoItem()
      t.id = parts[0]
      t.title = parts[1]
      t.isCompleted = parts[2] === '1'
      t.category = parts[3]
      out.push(t)
    }
    return out.length > 0 ? out : ZizaiStore.defaultTodos()
  }

  static async toggleTodo(id: string): Promise<void> {
    const list = await ZizaiStore.loadTodos()
    for (const t of list) {
      if (t.id === id) {
        t.isCompleted = !t.isCompleted
      }
    }
    await ZizaiStore.persistTodos(list)
  }

  static async todayProgress(): Promise<number> {
    const list = await ZizaiStore.loadTodos()
    if (list.length === 0) {
      return 0
    }
    let done = 0
    for (const t of list) {
      if (t.isCompleted) {
        done++
      }
    }
    return Math.round((done / list.length) * 100)
  }

  static async loadHabitRecord(dateKey: string): Promise<HabitDayRecord> {
    const all = await ZizaiStore.loadAllHabitRecords()
    for (const r of all) {
      if (r.dateKey === dateKey) {
        return r
      }
    }
    const empty = new HabitDayRecord()
    empty.dateKey = dateKey
    return empty
  }

  static async loadAllHabitRecords(): Promise<HabitDayRecord[]> {
    const raw = await ZizaiStore.getString(KEY_HABITS, '')
    if (raw.length === 0) {
      return []
    }
    const lines = raw.split('\n')
    const out: HabitDayRecord[] = []
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      const r = new HabitDayRecord()
      r.dateKey = parts[0]
      r.habitIds = parts.length >= 2 && parts[1].length > 0 ? parts[1].split('|') : []
      out.push(r)
    }
    return out
  }

  static async toggleHabit(habitId: string): Promise<void> {
    const key = DateHelper.todayKey()
    const rec = await ZizaiStore.loadHabitRecord(key)
    rec.dateKey = key
    let has = false
    const nextIds: string[] = []
    for (const id of rec.habitIds) {
      if (id === habitId) {
        has = true
      } else {
        nextIds.push(id)
      }
    }
    if (!has) {
      nextIds.push(habitId)
    }
    rec.habitIds = nextIds
    const all = await ZizaiStore.loadAllHabitRecords()
    const next: HabitDayRecord[] = []
    for (const r of all) {
      if (r.dateKey !== key) {
        next.push(r)
      }
    }
    next.push(rec)
    await ZizaiStore.persistHabits(next)
  }

  static async habitStreak(habitId: string): Promise<number> {
    const days = DateHelper.lastNDays(7)
    const all = await ZizaiStore.loadAllHabitRecords()
    let streak = 0
    for (const day of days) {
      let hit = false
      for (const r of all) {
        if (r.dateKey === day) {
          for (const id of r.habitIds) {
            if (id === habitId) {
              hit = true
            }
          }
        }
      }
      if (hit) {
        streak++
      } else if (streak > 0) {
        break
      }
    }
    return streak
  }

  static async loadProfile(): Promise<UserProfile> {
    const raw = await ZizaiStore.getString(KEY_PROFILE, '')
    const p = new UserProfile()
    if (raw.length === 0) {
      return p
    }
    const parts = raw.split('\t')
    if (parts.length >= 1) {
      p.nickname = parts[0]
    }
    if (parts.length >= 2) {
      p.darkMode = parts[1] === '1'
    }
    return p
  }

  static async saveProfile(p: UserProfile): Promise<void> {
    const val = `${p.nickname}\t${p.darkMode ? '1' : '0'}`
    await ZizaiStore.setString(KEY_PROFILE, val)
  }

  static async clearAllData(): Promise<void> {
    await ZizaiStore.setString(KEY_MOODS, '')
    await ZizaiStore.setString(KEY_FAVS, '')
    await ZizaiStore.setString(KEY_TODOS, '')
    await ZizaiStore.setString(KEY_HABITS, '')
  }

  private static async ensureTodayTodos(): Promise<void> {
    const raw = await ZizaiStore.getString(KEY_TODOS, '')
    if (raw.length === 0) {
      await ZizaiStore.persistTodos(ZizaiStore.defaultTodos())
    }
  }

  private static async persistMoods(list: MoodRecord[]): Promise<void> {
    const lines: string[] = []
    for (const m of list) {
      const g = m.gratitude.join('|')
      lines.push(`${m.dateKey}\t${m.moodKey}\t${m.moodLabel}\t${m.note}\t${g}\t${m.updatedAt}`)
    }
    await ZizaiStore.setString(KEY_MOODS, lines.join('\n'))
  }

  private static async persistTodos(list: TodoItem[]): Promise<void> {
    const lines: string[] = []
    for (const t of list) {
      lines.push(`${t.id}\t${t.title}\t${t.isCompleted ? '1' : '0'}\t${t.category}`)
    }
    await ZizaiStore.setString(KEY_TODOS, lines.join('\n'))
  }

  private static async persistHabits(list: HabitDayRecord[]): Promise<void> {
    const lines: string[] = []
    for (const r of list) {
      lines.push(`${r.dateKey}\t${r.habitIds.join('|')}`)
    }
    await ZizaiStore.setString(KEY_HABITS, lines.join('\n'))
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ZizaiStore.pref === null) {
      return fallback
    }
    try {
      const v = await ZizaiStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async setString(key: string, value: string): Promise<void> {
    if (ZizaiStore.pref === null) {
      return
    }
    try {
      await ZizaiStore.pref.put(key, value)
      await ZizaiStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
