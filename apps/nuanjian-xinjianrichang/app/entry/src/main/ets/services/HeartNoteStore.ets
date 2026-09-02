import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { NoteFile, NoteItem, NoteWire } from '../models/NoteModels'

const STORE_NAME = 'heart_note_local'
const KEY_NOTES = 'notes_json'
const KEY_MOOD = 'today_mood'
const KEY_MOOD_DATE = 'today_mood_date'
const KEY_DARK = 'dark_mode'
const KEY_FONT = 'font_level'
const KEY_REMIND = 'daily_remind'

export class HeartNoteStore {
  private static pref: preferences.Preferences | null = null
  private static notes: NoteItem[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      HeartNoteStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const rawValue = await HeartNoteStore.pref.get(KEY_NOTES, '[]')
      const raw: string = typeof rawValue === 'string' ? rawValue : '[]'
      HeartNoteStore.notes = HeartNoteStore.parseNotes(raw)
      const mood = await HeartNoteStore.pref.get(KEY_MOOD, '')
      const moodDate = await HeartNoteStore.pref.get(KEY_MOOD_DATE, '')
      const dark = await HeartNoteStore.pref.get(KEY_DARK, false)
      const font = await HeartNoteStore.pref.get(KEY_FONT, 1)
      const remind = await HeartNoteStore.pref.get(KEY_REMIND, false)
      AppStorage.setOrCreate('todayMood', typeof mood === 'string' ? mood : '')
      AppStorage.setOrCreate('todayMoodDate', typeof moodDate === 'string' ? moodDate : '')
      AppStorage.setOrCreate('darkModeOn', dark === true)
      AppStorage.setOrCreate('fontLevel', typeof font === 'number' ? font : 1)
      AppStorage.setOrCreate('dailyRemindOn', remind === true)
    } catch {
      HeartNoteStore.notes = []
    }
  }

  static all(): NoteItem[] {
    const copy: NoteItem[] = []
    for (const n of HeartNoteStore.notes) {
      copy.push(n)
    }
    return copy
  }

  static recent(limit: number): NoteItem[] {
    const all = HeartNoteStore.sorted()
    const out: NoteItem[] = []
    for (const n of all) {
      if (out.length >= limit) {
        break
      }
      out.push(n)
    }
    return out
  }

  static sorted(): NoteItem[] {
    const work: NoteItem[] = HeartNoteStore.all()
    const result: NoteItem[] = []
    while (work.length > 0) {
      let best: NoteItem | undefined = undefined
      for (const n of work) {
        if (best === undefined || n.createdAt > best.createdAt) {
          best = n
        }
      }
      if (best === undefined) {
        break
      }
      result.push(best)
      const next: NoteItem[] = []
      for (const n of work) {
        if (n.id !== best.id) {
          next.push(n)
        }
      }
      work.length = 0
      for (const n of next) {
        work.push(n)
      }
    }
    return result
  }

  static find(id: string): NoteItem | undefined {
    for (const n of HeartNoteStore.notes) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static async save(item: NoteItem): Promise<void> {
    const next: NoteItem[] = []
    let replaced = false
    for (const n of HeartNoteStore.notes) {
      if (n.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(n)
      }
    }
    if (!replaced) {
      next.unshift(item)
    }
    HeartNoteStore.notes = next
    await HeartNoteStore.flushNotes()
    HeartNoteStore.bump()
  }

  static async remove(id: string): Promise<void> {
    const next: NoteItem[] = []
    for (const n of HeartNoteStore.notes) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    HeartNoteStore.notes = next
    await HeartNoteStore.flushNotes()
    HeartNoteStore.bump()
  }

  static async clearAll(): Promise<void> {
    HeartNoteStore.notes = []
    await HeartNoteStore.flushNotes()
    HeartNoteStore.bump()
  }

  static hasOnDate(iso: string): boolean {
    for (const n of HeartNoteStore.notes) {
      if (n.noteDate === iso) {
        return true
      }
    }
    return false
  }

  static bump(): void {
    const n = AppStorage.get<number>('noteRefresh') ?? 0
    AppStorage.setOrCreate('noteRefresh', n + 1)
  }

  static exportText(): string {
    const lines: string[] = ['心笺日常 · 导出']
    for (const n of HeartNoteStore.sorted()) {
      lines.push('')
      lines.push(`${n.noteDate} ${n.period} · ${n.title}`)
      lines.push(n.body)
    }
    return lines.join('\n')
  }

  static async setTodayMood(mood: string, dateIso: string): Promise<void> {
    AppStorage.setOrCreate('todayMood', mood)
    AppStorage.setOrCreate('todayMoodDate', dateIso)
    await HeartNoteStore.putString(KEY_MOOD, mood)
    await HeartNoteStore.putString(KEY_MOOD_DATE, dateIso)
  }

  static async setDark(on: boolean): Promise<void> {
    AppStorage.setOrCreate('darkModeOn', on)
    await HeartNoteStore.putBool(KEY_DARK, on)
    HeartNoteStore.bump()
  }

  static async setFontLevel(level: number): Promise<void> {
    AppStorage.setOrCreate('fontLevel', level)
    await HeartNoteStore.putNumber(KEY_FONT, level)
    HeartNoteStore.bump()
  }

  static async setRemind(on: boolean): Promise<void> {
    AppStorage.setOrCreate('dailyRemindOn', on)
    await HeartNoteStore.putBool(KEY_REMIND, on)
    HeartNoteStore.bump()
  }

  private static async flushNotes(): Promise<void> {
    const parts: string[] = []
    for (const n of HeartNoteStore.notes) {
      parts.push(n.toJsonString())
    }
    const json = `[${parts.join(',')}]`
    await HeartNoteStore.putString(KEY_NOTES, json)
  }

  private static parseNotes(raw: string): NoteItem[] {
    const out: NoteItem[] = []
    if (raw.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as NoteWire[]
      if (parsed === undefined || parsed === null) {
        return out
      }
      const file = new NoteFile()
      file.items = parsed
      for (const w of file.items) {
        out.push(NoteItem.fromWire(w))
      }
    } catch {
      return out
    }
    return out
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (HeartNoteStore.pref === null) {
      return
    }
    await HeartNoteStore.pref.put(key, value)
    await HeartNoteStore.pref.flush()
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (HeartNoteStore.pref === null) {
      return
    }
    await HeartNoteStore.pref.put(key, value)
    await HeartNoteStore.pref.flush()
  }

  private static async putNumber(key: string, value: number): Promise<void> {
    if (HeartNoteStore.pref === null) {
      return
    }
    await HeartNoteStore.pref.put(key, value)
    await HeartNoteStore.pref.flush()
  }
}
