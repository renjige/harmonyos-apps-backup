import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { BreathSessionItem, JournalItem, MoodItem } from '../models/CoolPlanModels'

const TAG = 'CoolPlanLocalStore'
const STORE_NAME = 'cool_plan_local'
const KEY_MOODS = 'moods_json'
const KEY_SESSIONS = 'sessions_json'
const KEY_JOURNALS = 'journals_json'
const KEY_REMIND = 'remind_time'

/** 游客本地心情 / 呼吸 / 心语 / 提醒设置（Preferences + flush） */
export class CoolPlanLocalStore {
  private static pref: preferences.Preferences | null = null
  private static ready: boolean = false

  static isReady(): boolean {
    return CoolPlanLocalStore.ready
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      CoolPlanLocalStore.pref = await preferences.getPreferences(context, STORE_NAME)
      CoolPlanLocalStore.ready = true
      hilog.info(0x0000, TAG, 'local store ready')
    } catch {
      CoolPlanLocalStore.ready = true
      hilog.error(0x0000, TAG, 'local store init failed')
    }
  }

  static todayKey(): string {
    const d = new Date()
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static moodBaseIndex(mood: string): number {
    if (mood === '愉悦') {
      return 85
    }
    if (mood === '平静') {
      return 75
    }
    if (mood === '专注') {
      return 70
    }
    if (mood === '疲惫') {
      return 45
    }
    if (mood === '焦虑') {
      return 35
    }
    return 60
  }

  static async saveMood(mood: string, noteDate: string, coolIndex: number): Promise<MoodItem> {
    const rows = await CoolPlanLocalStore.loadMoods()
    const filtered: MoodItem[] = []
    for (const row of rows) {
      if (row.noteDate !== noteDate) {
        filtered.push(row)
      }
    }
    const id = `local_mood_${Date.now()}`
    const item = MoodItem.fromLocal(id, mood, noteDate, coolIndex)
    filtered.unshift(item)
    await CoolPlanLocalStore.writeJson(KEY_MOODS, CoolPlanLocalStore.moodsToJson(filtered))
    return item
  }

  static async loadMoods(): Promise<MoodItem[]> {
    const raw = await CoolPlanLocalStore.readString(KEY_MOODS)
    return CoolPlanLocalStore.parseMoods(raw)
  }

  static async moodForDate(noteDate: string): Promise<MoodItem | undefined> {
    const rows = await CoolPlanLocalStore.loadMoods()
    for (const row of rows) {
      if (row.noteDate === noteDate) {
        return row
      }
    }
    return undefined
  }

  static async saveBreathSession(modeId: string, title: string, durationSec: number, noteDate: string): Promise<BreathSessionItem> {
    const rows = await CoolPlanLocalStore.loadBreathSessions()
    const id = `local_breath_${Date.now()}`
    const item = BreathSessionItem.fromLocal(id, modeId, title, durationSec, noteDate)
    rows.unshift(item)
    await CoolPlanLocalStore.writeJson(KEY_SESSIONS, CoolPlanLocalStore.sessionsToJson(rows))
    return item
  }

  static async loadBreathSessions(): Promise<BreathSessionItem[]> {
    const raw = await CoolPlanLocalStore.readString(KEY_SESSIONS)
    return CoolPlanLocalStore.parseSessions(raw)
  }

  static async saveJournal(title: string, body: string, mood: string, noteDate: string): Promise<JournalItem> {
    const rows = await CoolPlanLocalStore.loadJournals()
    const filtered: JournalItem[] = []
    for (const row of rows) {
      if (row.noteDate !== noteDate) {
        filtered.push(row)
      }
    }
    const id = `local_journal_${Date.now()}`
    const item = JournalItem.fromLocal(id, title, body, mood, noteDate)
    filtered.unshift(item)
    await CoolPlanLocalStore.writeJson(KEY_JOURNALS, CoolPlanLocalStore.journalsToJson(filtered))
    return item
  }

  static async loadJournals(): Promise<JournalItem[]> {
    const raw = await CoolPlanLocalStore.readString(KEY_JOURNALS)
    return CoolPlanLocalStore.parseJournals(raw)
  }

  static async journalForDate(noteDate: string): Promise<JournalItem | undefined> {
    const rows = await CoolPlanLocalStore.loadJournals()
    for (const row of rows) {
      if (row.noteDate === noteDate) {
        return row
      }
    }
    return undefined
  }

  static async deleteJournal(id: string): Promise<void> {
    const rows = await CoolPlanLocalStore.loadJournals()
    const filtered: JournalItem[] = []
    for (const row of rows) {
      if (row.id !== id) {
        filtered.push(row)
      }
    }
    await CoolPlanLocalStore.writeJson(KEY_JOURNALS, CoolPlanLocalStore.journalsToJson(filtered))
  }

  static async deleteMood(id: string): Promise<void> {
    const rows = await CoolPlanLocalStore.loadMoods()
    const filtered: MoodItem[] = []
    for (const row of rows) {
      if (row.id !== id) {
        filtered.push(row)
      }
    }
    await CoolPlanLocalStore.writeJson(KEY_MOODS, CoolPlanLocalStore.moodsToJson(filtered))
  }

  static async clearUserRecords(): Promise<void> {
    await CoolPlanLocalStore.writeJson(KEY_MOODS, '')
    await CoolPlanLocalStore.writeJson(KEY_SESSIONS, '')
    await CoolPlanLocalStore.writeJson(KEY_JOURNALS, '')
  }

  static async getRemindTime(): Promise<string> {
    const v = await CoolPlanLocalStore.readString(KEY_REMIND)
    return v.length > 0 ? v : '21:00'
  }

  static async setRemindTime(value: string): Promise<void> {
    await CoolPlanLocalStore.writeString(KEY_REMIND, value)
  }

  static async computeTodayCoolIndex(): Promise<number> {
    const today = CoolPlanLocalStore.todayKey()
    const mood = await CoolPlanLocalStore.moodForDate(today)
    let base = 60
    if (mood !== undefined) {
      base = mood.coolIndex > 0 ? mood.coolIndex : CoolPlanLocalStore.moodBaseIndex(mood.mood)
    }
    const sessions = await CoolPlanLocalStore.loadBreathSessions()
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

  private static async readString(key: string): Promise<string> {
    if (CoolPlanLocalStore.pref === null) {
      return ''
    }
    try {
      const v = await CoolPlanLocalStore.pref.get(key, '')
      return typeof v === 'string' ? v : ''
    } catch {
      return ''
    }
  }

  private static async writeString(key: string, value: string): Promise<void> {
    if (CoolPlanLocalStore.pref === null) {
      return
    }
    try {
      await CoolPlanLocalStore.pref.put(key, value)
      await CoolPlanLocalStore.pref.flush()
    } catch {
      hilog.error(0x0000, TAG, 'write failed')
    }
  }

  private static async writeJson(key: string, value: string): Promise<void> {
    await CoolPlanLocalStore.writeString(key, value)
  }

  private static moodsToJson(rows: MoodItem[]): string {
    const parts: string[] = []
    for (const row of rows) {
      parts.push(`${row.id}|${row.mood}|${row.noteDate}|${row.coolIndex}`)
    }
    return parts.join('\n')
  }

  private static parseMoods(raw: string): MoodItem[] {
    const out: MoodItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('|')
      if (parts.length < 4) {
        continue
      }
      const coolRaw = Number(parts[3])
      const cool = isNaN(coolRaw) ? 0 : coolRaw
      out.push(MoodItem.fromLocal(parts[0], parts[1], parts[2], cool))
    }
    return out
  }

  private static sessionsToJson(rows: BreathSessionItem[]): string {
    const parts: string[] = []
    for (const row of rows) {
      parts.push(`${row.id}|${row.modeId}|${row.title}|${row.durationSec}|${row.noteDate}`)
    }
    return parts.join('\n')
  }

  private static parseSessions(raw: string): BreathSessionItem[] {
    const out: BreathSessionItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('|')
      if (parts.length < 5) {
        continue
      }
      const secRaw = Number(parts[3])
      const sec = isNaN(secRaw) ? 0 : secRaw
      out.push(BreathSessionItem.fromLocal(parts[0], parts[1], parts[2], sec, parts[4]))
    }
    return out
  }

  private static journalsToJson(rows: JournalItem[]): string {
    const parts: string[] = []
    for (const row of rows) {
      const safeBody = row.body.replace(/\|/g, ' ')
      parts.push(`${row.id}|${row.title}|${safeBody}|${row.mood}|${row.noteDate}`)
    }
    return parts.join('\n')
  }

  private static parseJournals(raw: string): JournalItem[] {
    const out: JournalItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('|')
      if (parts.length < 5) {
        continue
      }
      out.push(JournalItem.fromLocal(parts[0], parts[1], parts[2], parts[3], parts[4]))
    }
    return out
  }
}
