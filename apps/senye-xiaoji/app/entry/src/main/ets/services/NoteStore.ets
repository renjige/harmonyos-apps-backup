import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { NoteFile, NoteItem, NoteWire, TagStat } from '../models/NoteModels'
import { NoteDateUtil } from './NoteDateUtil'
import { TagEngine } from './TagEngine'

const STORE_NAME = 'senye_notes_local'
const KEY_NOTES = 'notes_json'
const KEY_DARK = 'dark_mode'
const KEY_CUSTOM_TAGS = 'custom_tags'

export class NoteStore {
  private static pref: preferences.Preferences | null = null
  private static notes: NoteItem[] = []
  private static extraTags: string[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      NoteStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const rawValue = await NoteStore.pref.get(KEY_NOTES, '[]')
      const raw: string = typeof rawValue === 'string' ? rawValue : '[]'
      NoteStore.notes = NoteStore.parseNotes(raw)
      const dark = await NoteStore.pref.get(KEY_DARK, false)
      const tagsRawValue = await NoteStore.pref.get(KEY_CUSTOM_TAGS, '[]')
      const tagsRaw: string = typeof tagsRawValue === 'string' ? tagsRawValue : '[]'
      NoteStore.extraTags = NoteStore.parseTags(tagsRaw)
      AppStorage.setOrCreate('darkModeOn', dark === true)
      Theme.setColorMode(dark === true ? 'dark' : 'light')
    } catch {
      NoteStore.notes = []
    }
  }

  static all(): NoteItem[] {
    const copy: NoteItem[] = []
    for (const n of NoteStore.notes) {
      copy.push(n)
    }
    return copy
  }

  static sorted(): NoteItem[] {
    const work: NoteItem[] = NoteStore.all()
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
    for (const n of NoteStore.notes) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static byDate(iso: string): NoteItem[] {
    const out: NoteItem[] = []
    for (const n of NoteStore.sorted()) {
      if (n.noteDate === iso) {
        out.push(n)
      }
    }
    return out
  }

  static datesWithNotes(): string[] {
    const out: string[] = []
    for (const n of NoteStore.notes) {
      let seen = false
      for (const d of out) {
        if (d === n.noteDate) {
          seen = true
        }
      }
      if (!seen && n.noteDate.length > 0) {
        out.push(n.noteDate)
      }
    }
    return out
  }

  static async save(item: NoteItem): Promise<void> {
    const next: NoteItem[] = []
    let replaced = false
    for (const n of NoteStore.notes) {
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
    NoteStore.notes = next
    await NoteStore.flushNotes()
    NoteStore.bump()
  }

  static async remove(id: string): Promise<void> {
    const next: NoteItem[] = []
    for (const n of NoteStore.notes) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    NoteStore.notes = next
    await NoteStore.flushNotes()
    NoteStore.bump()
  }

  static usedTagNames(): string[] {
    const out: string[] = []
    for (const n of NoteStore.notes) {
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
    for (const t of NoteStore.extraTags) {
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

  static tagStats(): TagStat[] {
    const names: string[] = []
    const counts: number[] = []
    for (const n of NoteStore.notes) {
      for (const t of n.tagList()) {
        let idx = -1
        for (let i = 0; i < names.length; i++) {
          if (names[i] === t) {
            idx = i
          }
        }
        if (idx >= 0) {
          counts[idx] += 1
        } else {
          names.push(t)
          counts.push(1)
        }
      }
    }
    const out: TagStat[] = []
    for (let i = 0; i < names.length; i++) {
      const s = new TagStat()
      s.name = names[i]
      s.count = counts[i]
      out.push(s)
    }
    return out
  }

  static byTag(tag: string): NoteItem[] {
    const out: NoteItem[] = []
    for (const n of NoteStore.sorted()) {
      for (const t of n.tagList()) {
        if (t === tag) {
          out.push(n)
          break
        }
      }
    }
    return out
  }

  static streakDays(): number {
    const set: string[] = NoteStore.datesWithNotes()
    if (set.length === 0) {
      return 0
    }
    let cursor = NoteDateUtil.todayIso()
    let hasToday = false
    for (const d of set) {
      if (d === cursor) {
        hasToday = true
      }
    }
    if (!hasToday) {
      const y = new Date()
      y.setDate(y.getDate() - 1)
      cursor = NoteDateUtil.toIso(y)
    }
    let streak = 0
    while (true) {
      let hit = false
      for (const d of set) {
        if (d === cursor) {
          hit = true
        }
      }
      if (!hit) {
        break
      }
      streak += 1
      const parts = cursor.split('-')
      const dt = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]))
      dt.setDate(dt.getDate() - 1)
      cursor = NoteDateUtil.toIso(dt)
    }
    return streak
  }

  static async addCustomTag(tag: string): Promise<void> {
    const t = tag.trim()
    if (t.length === 0) {
      return
    }
    for (const e of NoteStore.extraTags) {
      if (e === t) {
        return
      }
    }
    NoteStore.extraTags.push(t)
    await NoteStore.flushTags()
    NoteStore.bump()
  }

  static async removeCustomTag(tag: string): Promise<void> {
    const next: string[] = []
    for (const t of NoteStore.extraTags) {
      if (t !== tag) {
        next.push(t)
      }
    }
    NoteStore.extraTags = next
    await NoteStore.flushTags()
    NoteStore.bump()
  }

  static customTags(): string[] {
    const copy: string[] = []
    for (const t of NoteStore.extraTags) {
      copy.push(t)
    }
    return copy
  }

  static exportText(): string {
    const lines: string[] = ['森野小记 · 文字导出', `导出时间：${NoteDateUtil.displayDate(NoteDateUtil.todayIso())}`]
    for (const n of NoteStore.sorted()) {
      lines.push('')
      lines.push(`${n.noteDate} ${n.timeLabel}`)
      lines.push(n.body)
      if (n.tagsCsv.length > 0) {
        lines.push(`标签：${n.tagsCsv}`)
      }
      if (n.locationLabel.length > 0) {
        lines.push(`位置：${n.locationLabel}`)
      }
    }
    return lines.join('\n')
  }

  static async setDark(on: boolean): Promise<void> {
    AppStorage.setOrCreate('darkModeOn', on)
    Theme.setColorMode(on ? 'dark' : 'light')
    await NoteStore.putBool(KEY_DARK, on)
    NoteStore.bump()
  }

  static suggestTags(body: string): string[] {
    return TagEngine.suggest(body)
  }

  static search(query: string): NoteItem[] {
    return TagEngine.search(NoteStore.sorted(), query)
  }

  static similarTags(): string[] {
    return TagEngine.similarGroups(NoteStore.notes)
  }

  static bump(): void {
    const n = AppStorage.get<number>('noteRefresh') ?? 0
    AppStorage.setOrCreate('noteRefresh', n + 1)
  }

  private static async flushNotes(): Promise<void> {
    const parts: string[] = []
    for (const n of NoteStore.notes) {
      parts.push(n.toJsonString())
    }
    await NoteStore.putString(KEY_NOTES, `[${parts.join(',')}]`)
  }

  private static async flushTags(): Promise<void> {
    const parts: string[] = []
    for (const t of NoteStore.extraTags) {
      parts.push(JSON.stringify(t))
    }
    await NoteStore.putString(KEY_CUSTOM_TAGS, `[${parts.join(',')}]`)
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
    if (NoteStore.pref === null) {
      return
    }
    await NoteStore.pref.put(key, value)
    await NoteStore.pref.flush()
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (NoteStore.pref === null) {
      return
    }
    await NoteStore.pref.put(key, value)
    await NoteStore.pref.flush()
  }
}
