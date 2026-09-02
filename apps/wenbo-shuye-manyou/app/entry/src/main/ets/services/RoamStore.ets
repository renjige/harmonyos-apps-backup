import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  ReadLogEntry, ReadLogFile, ReadLogWire, RoamNote, RoamNoteFile, RoamNoteWire, RoamStats, ThemeTagCount
} from '../models/RoamModels'
import { RoamBizService } from './RoamBizService'

const STORE_NAME = 'shuyemanyou_local'
const KEY_FAVORITES = 'favorites_json'
const KEY_READ_LATER = 'read_later_json'
const KEY_FINISHED = 'finished_json'
const KEY_READ_LOG = 'read_log_json'
const KEY_NOTES = 'notes_json'
const KEY_DARK = 'dark_mode'
const MAX_NOTE_LEN = 200

export class RoamStore {
  private static pref: preferences.Preferences | null = null
  private static favorites: string[] = []
  private static readLater: string[] = []
  private static finished: string[] = []
  private static readLog: ReadLogEntry[] = []
  private static notes: RoamNote[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      RoamStore.pref = await preferences.getPreferences(context, STORE_NAME)
      RoamStore.favorites = RoamStore.parseIdList(await RoamStore.pref.get(KEY_FAVORITES, '[]'))
      RoamStore.readLater = RoamStore.parseIdList(await RoamStore.pref.get(KEY_READ_LATER, '[]'))
      RoamStore.finished = RoamStore.parseIdList(await RoamStore.pref.get(KEY_FINISHED, '[]'))
      const logRaw = await RoamStore.pref.get(KEY_READ_LOG, '[]')
      const logStr: string = typeof logRaw === 'string' ? logRaw : '[]'
      RoamStore.readLog = RoamStore.parseReadLog(logStr)
      const noteRaw = await RoamStore.pref.get(KEY_NOTES, '[]')
      const noteStr: string = typeof noteRaw === 'string' ? noteRaw : '[]'
      RoamStore.notes = RoamStore.parseNotes(noteStr)
      const dark = await RoamStore.pref.get(KEY_DARK, false)
      AppStorage.setOrCreate('darkModeOn', dark === true)
    } catch {
      RoamStore.favorites = []
      RoamStore.readLater = []
      RoamStore.finished = []
      RoamStore.readLog = []
      RoamStore.notes = []
    }
  }

  static isFavorite(id: string): boolean {
    return RoamStore.contains(RoamStore.favorites, id)
  }

  static isReadLater(id: string): boolean {
    return RoamStore.contains(RoamStore.readLater, id)
  }

  static isFinished(id: string): boolean {
    return RoamStore.contains(RoamStore.finished, id)
  }

  static async toggleFavorite(excerptId: string, bookTitle: string, theme: string): Promise<void> {
    if (RoamStore.isFavorite(excerptId)) {
      RoamStore.favorites = RoamStore.removeId(RoamStore.favorites, excerptId)
      await RoamStore.flushIds(KEY_FAVORITES, RoamStore.favorites)
    } else {
      RoamStore.favorites = RoamStore.prependId(RoamStore.favorites, excerptId)
      await RoamStore.flushIds(KEY_FAVORITES, RoamStore.favorites)
      await RoamStore.appendLog(excerptId, bookTitle, theme, 'favorite')
    }
    RoamStore.bump()
  }

  static async toggleReadLater(excerptId: string, bookTitle: string, theme: string): Promise<void> {
    if (RoamStore.isReadLater(excerptId)) {
      RoamStore.readLater = RoamStore.removeId(RoamStore.readLater, excerptId)
      await RoamStore.flushIds(KEY_READ_LATER, RoamStore.readLater)
    } else {
      RoamStore.readLater = RoamStore.prependId(RoamStore.readLater, excerptId)
      await RoamStore.flushIds(KEY_READ_LATER, RoamStore.readLater)
      await RoamStore.appendLog(excerptId, bookTitle, theme, 'readLater')
    }
    RoamStore.bump()
  }

  static async markFinished(excerptId: string, bookTitle: string, theme: string): Promise<void> {
    if (!RoamStore.isFinished(excerptId)) {
      RoamStore.finished = RoamStore.prependId(RoamStore.finished, excerptId)
      await RoamStore.flushIds(KEY_FINISHED, RoamStore.finished)
      await RoamStore.appendLog(excerptId, bookTitle, theme, 'finished')
      RoamStore.bump()
    }
  }

  static sortedReadLog(): ReadLogEntry[] {
    const work: ReadLogEntry[] = []
    for (const row of RoamStore.readLog) {
      work.push(row)
    }
    const out: ReadLogEntry[] = []
    while (work.length > 0) {
      let best: ReadLogEntry | undefined = undefined
      for (const row of work) {
        if (best === undefined || row.at > best.at) {
          best = row
        }
      }
      if (best === undefined) {
        break
      }
      out.push(best)
      const next: ReadLogEntry[] = []
      for (const row of work) {
        if (row.id !== best.id) {
          next.push(row)
        }
      }
      work.length = 0
      for (const row of next) {
        work.push(row)
      }
    }
    return out
  }

  static notesAll(): RoamNote[] {
    const out: RoamNote[] = []
    for (const n of RoamStore.notes) {
      out.push(n)
    }
    return out
  }

  static findNote(id: string): RoamNote | undefined {
    for (const n of RoamStore.notes) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static async saveNote(note: RoamNote): Promise<void> {
    const trimmed = note.body.length > MAX_NOTE_LEN ?
      note.body.substring(0, MAX_NOTE_LEN) : note.body
    note.body = trimmed
    note.updatedAt = Date.now()
    if (note.createdAt === 0) {
      note.createdAt = note.updatedAt
    }
    const next: RoamNote[] = []
    let replaced = false
    for (const n of RoamStore.notes) {
      if (n.id === note.id) {
        next.push(note)
        replaced = true
      } else {
        next.push(n)
      }
    }
    if (!replaced) {
      next.unshift(note)
    }
    RoamStore.notes = next
    await RoamStore.flushNotes()
    RoamStore.bump()
  }

  static async removeNote(id: string): Promise<void> {
    const next: RoamNote[] = []
    for (const n of RoamStore.notes) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    RoamStore.notes = next
    await RoamStore.flushNotes()
    RoamStore.bump()
  }

  static stats(): RoamStats {
    const s = new RoamStats()
    s.favorites = RoamStore.favorites.length
    s.readLater = RoamStore.readLater.length
    s.finished = RoamStore.finished.length
    s.notes = RoamStore.notes.length
    const dayKeys: string[] = []
    for (const row of RoamStore.readLog) {
      const d = new Date(row.at)
      const key = `${d.getFullYear()}-${d.getMonth()}-${d.getDate()}`
      let seen = false
      for (const k of dayKeys) {
        if (k === key) {
          seen = true
          break
        }
      }
      if (!seen) {
        dayKeys.push(key)
      }
    }
    s.readDays = dayKeys.length
    return s
  }

  static themeTags(): ThemeTagCount[] {
    const counts: ThemeTagCount[] = []
    const ids: string[] = []
    for (const id of RoamStore.favorites) {
      ids.push(id)
    }
    for (const id of RoamStore.finished) {
      if (!RoamStore.contains(ids, id)) {
        ids.push(id)
      }
    }
    for (const id of ids) {
      const excerpt = RoamBizService.findCachedExcerpt(id)
      if (excerpt === undefined || excerpt.theme.length === 0) {
        continue
      }
      let found: ThemeTagCount | undefined = undefined
      for (const row of counts) {
        if (row.tag === excerpt.theme) {
          found = row
          break
        }
      }
      if (found === undefined) {
        const t = new ThemeTagCount()
        t.tag = excerpt.theme
        t.count = 1
        counts.push(t)
      } else {
        found.count += 1
      }
    }
    const out: ThemeTagCount[] = []
    while (counts.length > 0) {
      let best: ThemeTagCount | undefined = undefined
      for (const row of counts) {
        if (best === undefined || row.count > best.count) {
          best = row
        }
      }
      if (best === undefined) {
        break
      }
      out.push(best)
      const next: ThemeTagCount[] = []
      for (const row of counts) {
        if (row.tag !== best.tag) {
          next.push(row)
        }
      }
      counts.length = 0
      for (const row of next) {
        counts.push(row)
      }
    }
    return out
  }

  static async setDark(on: boolean): Promise<void> {
    AppStorage.setOrCreate('darkModeOn', on)
    await RoamStore.putBool(KEY_DARK, on)
    RoamStore.bump()
  }

  static newNoteId(): string {
    return `note_${Date.now()}_${RoamStore.notes.length}`
  }

  static bump(): void {
    const n = AppStorage.get<number>('roamRefresh') ?? 0
    AppStorage.setOrCreate('roamRefresh', n + 1)
  }

  private static async appendLog(excerptId: string, bookTitle: string, theme: string,
    action: string): Promise<void> {
    const row = new ReadLogEntry()
    row.id = `log_${Date.now()}_${RoamStore.readLog.length}`
    row.excerptId = excerptId
    row.bookTitle = bookTitle
    row.theme = theme
    row.action = action
    row.at = Date.now()
    const next: ReadLogEntry[] = [row]
    for (const old of RoamStore.readLog) {
      next.push(old)
    }
    RoamStore.readLog = next
    await RoamStore.flushReadLog()
  }

  private static contains(list: string[], id: string): boolean {
    for (const row of list) {
      if (row === id) {
        return true
      }
    }
    return false
  }

  private static prependId(list: string[], id: string): string[] {
    const next: string[] = [id]
    for (const row of list) {
      if (row !== id) {
        next.push(row)
      }
    }
    return next
  }

  private static removeId(list: string[], id: string): string[] {
    const next: string[] = []
    for (const row of list) {
      if (row !== id) {
        next.push(row)
      }
    }
    return next
  }

  private static parseIdList(raw: preferences.ValueType): string[] {
    const out: string[] = []
    const text = typeof raw === 'string' ? raw : '[]'
    try {
      const parsed = JSON.parse(text) as string[]
      for (const s of parsed) {
        if (typeof s === 'string' && s.length > 0) {
          out.push(s)
        }
      }
    } catch {
      return out
    }
    return out
  }

  private static parseReadLog(raw: string): ReadLogEntry[] {
    const out: ReadLogEntry[] = []
    if (raw.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as ReadLogWire[]
      const file = new ReadLogFile()
      file.items = parsed
      for (const w of file.items) {
        out.push(ReadLogEntry.fromWire(w))
      }
    } catch {
      return out
    }
    return out
  }

  private static parseNotes(raw: string): RoamNote[] {
    const out: RoamNote[] = []
    if (raw.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as RoamNoteWire[]
      const file = new RoamNoteFile()
      file.items = parsed
      for (const w of file.items) {
        out.push(RoamNote.fromWire(w))
      }
    } catch {
      return out
    }
    return out
  }

  private static async flushIds(key: string, ids: string[]): Promise<void> {
    await RoamStore.putString(key, JSON.stringify(ids))
  }

  private static async flushReadLog(): Promise<void> {
    const parts: string[] = []
    for (const row of RoamStore.readLog) {
      parts.push(row.toJsonString())
    }
    await RoamStore.putString(KEY_READ_LOG, `[${parts.join(',')}]`)
  }

  private static async flushNotes(): Promise<void> {
    const parts: string[] = []
    for (const n of RoamStore.notes) {
      parts.push(n.toJsonString())
    }
    await RoamStore.putString(KEY_NOTES, `[${parts.join(',')}]`)
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (RoamStore.pref === null) {
      return
    }
    try {
      await RoamStore.pref.put(key, value)
      await RoamStore.pref.flush()
    } catch {
      return
    }
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (RoamStore.pref === null) {
      return
    }
    try {
      await RoamStore.pref.put(key, value)
      await RoamStore.pref.flush()
    } catch {
      return
    }
  }
}
