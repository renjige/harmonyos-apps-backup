import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { NoteFile, NoteItem, NoteWire } from '../models/SlipModels'
import { SlipDateUtil } from './SlipDateUtil'

const STORE_NAME = 'inspiration_slip_local'
const KEY_NOTES = 'notes_json'
const KEY_DARK = 'dark_mode'
const KEY_FONT = 'font_level'
const KEY_CUSTOM_TAGS = 'custom_tags'

export class SlipStore {
  private static pref: preferences.Preferences | null = null
  private static notes: NoteItem[] = []
  private static extraTags: string[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SlipStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const rawValue = await SlipStore.pref.get(KEY_NOTES, '[]')
      const raw: string = typeof rawValue === 'string' ? rawValue : '[]'
      SlipStore.notes = SlipStore.parseNotes(raw)
      const dark = await SlipStore.pref.get(KEY_DARK, false)
      const font = await SlipStore.pref.get(KEY_FONT, 1)
      const tagsRawValue = await SlipStore.pref.get(KEY_CUSTOM_TAGS, '[]')
      const tagsRaw: string = typeof tagsRawValue === 'string' ? tagsRawValue : '[]'
      SlipStore.extraTags = SlipStore.parseTags(tagsRaw)
      AppStorage.setOrCreate('darkModeOn', dark === true)
      AppStorage.setOrCreate('fontLevel', typeof font === 'number' ? font : 1)
    } catch {
      SlipStore.notes = []
    }
  }

  static all(): NoteItem[] {
    const copy: NoteItem[] = []
    for (const n of SlipStore.notes) {
      copy.push(n)
    }
    return copy
  }

  static customTags(): string[] {
    const copy: string[] = []
    for (const t of SlipStore.extraTags) {
      copy.push(t)
    }
    return copy
  }

  static recent(limit: number): NoteItem[] {
    const all = SlipStore.sorted()
    const out: NoteItem[] = []
    for (const n of all) {
      if (out.length >= limit) {
        break
      }
      out.push(n)
    }
    return out
  }

  static todayItems(): NoteItem[] {
    const today = SlipDateUtil.todayIso()
    const out: NoteItem[] = []
    for (const n of SlipStore.sorted()) {
      if (n.noteDate === today) {
        out.push(n)
      }
    }
    return out
  }

  static favorites(): NoteItem[] {
    const out: NoteItem[] = []
    for (const n of SlipStore.sorted()) {
      if (n.favorited) {
        out.push(n)
      }
    }
    return out
  }

  static sorted(): NoteItem[] {
    const work: NoteItem[] = SlipStore.all()
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
    for (const n of SlipStore.notes) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static randomOne(exceptId: string): NoteItem | undefined {
    const all = SlipStore.sorted()
    if (all.length === 0) {
      return undefined
    }
    if (all.length === 1) {
      return all[0]
    }
    const pool: NoteItem[] = []
    for (const n of all) {
      if (n.id !== exceptId) {
        pool.push(n)
      }
    }
    if (pool.length === 0) {
      return all[0]
    }
    const idx = Date.now() % pool.length
    let i = 0
    for (const n of pool) {
      if (i === idx) {
        return n
      }
      i += 1
    }
    return pool[0]
  }

  static usedTagNames(): string[] {
    const out: string[] = []
    for (const n of SlipStore.notes) {
      for (const t of n.tagList()) {
        let seen = false
        for (const e of out) {
          if (e === t) {
            seen = true
          }
        }
        if (!seen) {
          out.push(t)
        }
      }
    }
    for (const t of SlipStore.extraTags) {
      let seen = false
      for (const e of out) {
        if (e === t) {
          seen = true
        }
      }
      if (!seen) {
        out.push(t)
      }
    }
    return out
  }

  static async save(item: NoteItem): Promise<void> {
    const next: NoteItem[] = []
    let replaced = false
    for (const n of SlipStore.notes) {
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
    SlipStore.notes = next
    await SlipStore.flushNotes()
    SlipStore.bump()
  }

  static async remove(id: string): Promise<void> {
    const next: NoteItem[] = []
    for (const n of SlipStore.notes) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    SlipStore.notes = next
    await SlipStore.flushNotes()
    SlipStore.bump()
  }

  static async clearAll(): Promise<void> {
    SlipStore.notes = []
    await SlipStore.flushNotes()
    SlipStore.bump()
  }

  static async addCustomTag(tag: string): Promise<void> {
    const t = tag.trim()
    if (t.length === 0) {
      return
    }
    for (const e of SlipStore.extraTags) {
      if (e === t) {
        return
      }
    }
    SlipStore.extraTags.push(t)
    await SlipStore.flushTags()
    SlipStore.bump()
  }

  static bump(): void {
    const n = AppStorage.get<number>('noteRefresh') ?? 0
    AppStorage.setOrCreate('noteRefresh', n + 1)
  }

  static exportText(): string {
    const lines: string[] = ['灵感笺 · 文字导出']
    for (const n of SlipStore.sorted()) {
      lines.push('')
      lines.push(`${n.noteDate} ${n.timeLabel}`)
      if (n.title.length > 0) {
        lines.push(n.title)
      }
      lines.push(n.body)
      if (n.tagsCsv.length > 0) {
        lines.push(`#${n.tagsCsv.split(',').join(' #')}`)
      }
    }
    return lines.join('\n')
  }

  static exportJson(): string {
    const parts: string[] = []
    for (const n of SlipStore.sorted()) {
      parts.push(n.toJsonString())
    }
    return `[${parts.join(',')}]`
  }

  static async setDark(on: boolean): Promise<void> {
    AppStorage.setOrCreate('darkModeOn', on)
    await SlipStore.putBool(KEY_DARK, on)
    SlipStore.bump()
  }

  static async setFontLevel(level: number): Promise<void> {
    AppStorage.setOrCreate('fontLevel', level)
    await SlipStore.putNumber(KEY_FONT, level)
    SlipStore.bump()
  }

  private static async flushNotes(): Promise<void> {
    const parts: string[] = []
    for (const n of SlipStore.notes) {
      parts.push(n.toJsonString())
    }
    await SlipStore.putString(KEY_NOTES, `[${parts.join(',')}]`)
  }

  private static async flushTags(): Promise<void> {
    const parts: string[] = []
    for (const t of SlipStore.extraTags) {
      parts.push(JSON.stringify(t))
    }
    await SlipStore.putString(KEY_CUSTOM_TAGS, `[${parts.join(',')}]`)
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

  private static parseTags(raw: string): string[] {
    const out: string[] = []
    if (raw.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as string[]
      if (parsed === undefined || parsed === null) {
        return out
      }
      for (const t of parsed) {
        if (typeof t === 'string' && t.length > 0) {
          out.push(t)
        }
      }
    } catch {
      return out
    }
    return out
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (SlipStore.pref === null) {
      return
    }
    await SlipStore.pref.put(key, value)
    await SlipStore.pref.flush()
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (SlipStore.pref === null) {
      return
    }
    await SlipStore.pref.put(key, value)
    await SlipStore.pref.flush()
  }

  private static async putNumber(key: string, value: number): Promise<void> {
    if (SlipStore.pref === null) {
      return
    }
    await SlipStore.pref.put(key, value)
    await SlipStore.pref.flush()
  }
}
