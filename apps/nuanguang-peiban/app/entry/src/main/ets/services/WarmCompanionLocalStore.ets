import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { BreathSessionItem, MoodItem } from '../models/WarmCompanionModels'

const TAG = 'WarmCompanionLocalStore'
const STORE_NAME = 'warm_companion_local'
const KEY_MOODS = 'moods_json'
const KEY_SESSIONS = 'sessions_json'
const KEY_NICKNAME = 'nickname'
const KEY_REMIND = 'remind_time'
const KEY_NOTIFY = 'notify_enabled'

/** 游客本地心情 / 呼吸 / 昵称 / 提醒（Preferences + flush） */
export class WarmCompanionLocalStore {
  private static pref: preferences.Preferences | null = null
  private static ready: boolean = false

  static isReady(): boolean {
    return WarmCompanionLocalStore.ready
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      WarmCompanionLocalStore.pref = await preferences.getPreferences(context, STORE_NAME)
      WarmCompanionLocalStore.ready = true
      hilog.info(0x0000, TAG, 'local store ready')
    } catch {
      WarmCompanionLocalStore.ready = true
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

  static dateKeyOffset(daysAgo: number): string {
    const d = new Date()
    d.setDate(d.getDate() - daysAgo)
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static async saveMoodRecord(mood: string, body: string, noteDate: string): Promise<MoodItem> {
    const rows = await WarmCompanionLocalStore.loadMoods()
    const filtered: MoodItem[] = []
    for (const row of rows) {
      if (row.noteDate !== noteDate) {
        filtered.push(row)
      }
    }
    const id = `local_mood_${Date.now()}`
    const item = MoodItem.fromLocal(id, mood, body, noteDate)
    filtered.unshift(item)
    await WarmCompanionLocalStore.writeJson(KEY_MOODS, WarmCompanionLocalStore.moodsToJson(filtered))
    return item
  }

  static async loadMoods(): Promise<MoodItem[]> {
    const raw = await WarmCompanionLocalStore.readString(KEY_MOODS)
    return WarmCompanionLocalStore.parseMoods(raw)
  }

  static async moodForDate(noteDate: string): Promise<MoodItem | undefined> {
    const rows = await WarmCompanionLocalStore.loadMoods()
    for (const row of rows) {
      if (row.noteDate === noteDate) {
        return row
      }
    }
    return undefined
  }

  static async saveBreathSession(modeId: string, title: string, durationSec: number, noteDate: string): Promise<BreathSessionItem> {
    const rows = await WarmCompanionLocalStore.loadBreathSessions()
    const id = `local_breath_${Date.now()}`
    const item = BreathSessionItem.fromLocal(id, modeId, title, durationSec, noteDate)
    rows.unshift(item)
    await WarmCompanionLocalStore.writeJson(KEY_SESSIONS, WarmCompanionLocalStore.sessionsToJson(rows))
    return item
  }

  static async loadBreathSessions(): Promise<BreathSessionItem[]> {
    const raw = await WarmCompanionLocalStore.readString(KEY_SESSIONS)
    return WarmCompanionLocalStore.parseSessions(raw)
  }

  static async deleteMood(id: string): Promise<void> {
    const rows = await WarmCompanionLocalStore.loadMoods()
    const filtered: MoodItem[] = []
    for (const row of rows) {
      if (row.id !== id) {
        filtered.push(row)
      }
    }
    await WarmCompanionLocalStore.writeJson(KEY_MOODS, WarmCompanionLocalStore.moodsToJson(filtered))
  }

  static async clearUserRecords(): Promise<void> {
    await WarmCompanionLocalStore.writeJson(KEY_MOODS, '')
    await WarmCompanionLocalStore.writeJson(KEY_SESSIONS, '')
  }

  static async getNickname(): Promise<string> {
    const v = await WarmCompanionLocalStore.readString(KEY_NICKNAME)
    return v
  }

  static async setNickname(value: string): Promise<void> {
    await WarmCompanionLocalStore.writeString(KEY_NICKNAME, value)
  }

  static async getRemindTime(): Promise<string> {
    const v = await WarmCompanionLocalStore.readString(KEY_REMIND)
    return v.length > 0 ? v : '21:00'
  }

  static async setRemindTime(value: string): Promise<void> {
    await WarmCompanionLocalStore.writeString(KEY_REMIND, value)
  }

  static async getNotifyEnabled(): Promise<boolean> {
    const v = await WarmCompanionLocalStore.readString(KEY_NOTIFY)
    return v !== '0'
  }

  static async setNotifyEnabled(enabled: boolean): Promise<void> {
    await WarmCompanionLocalStore.writeString(KEY_NOTIFY, enabled ? '1' : '0')
  }

  private static async readString(key: string): Promise<string> {
    if (WarmCompanionLocalStore.pref === null) {
      return ''
    }
    try {
      const v = await WarmCompanionLocalStore.pref.get(key, '')
      return typeof v === 'string' ? v : ''
    } catch {
      return ''
    }
  }

  private static async writeString(key: string, value: string): Promise<void> {
    if (WarmCompanionLocalStore.pref === null) {
      return
    }
    try {
      await WarmCompanionLocalStore.pref.put(key, value)
      await WarmCompanionLocalStore.pref.flush()
    } catch {
      hilog.error(0x0000, TAG, 'write failed')
    }
  }

  private static async writeJson(key: string, value: string): Promise<void> {
    await WarmCompanionLocalStore.writeString(key, value)
  }

  private static moodsToJson(rows: MoodItem[]): string {
    const parts: string[] = []
    for (const row of rows) {
      const safeBody = row.body.replace(/\|/g, ' ').replace(/\n/g, ' ')
      parts.push(`${row.id}|${row.mood}|${safeBody}|${row.noteDate}`)
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
      out.push(MoodItem.fromLocal(parts[0], parts[1], parts[2], parts[3]))
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
}
