import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

const STORE = 'team_observation_notes'
const KEY_NOTES = 'notes'

class NoteEntry {
  teamId: string = ''
  text: string = ''
}

export class TeamNoteItem {
  teamId: string = ''
  text: string = ''
}

class NoteBundle {
  entries: NoteEntry[] = []
}

export class TeamNoteStore {
  private static pref: preferences.Preferences | null = null
  private static cache: NoteBundle = new NoteBundle()

  static async init(context: common.Context): Promise<void> {
    try {
      TeamNoteStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await TeamNoteStore.pref.get(KEY_NOTES, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      TeamNoteStore.cache = TeamNoteStore.parse(raw)
    } catch {
      TeamNoteStore.cache = new NoteBundle()
    }
  }

  static getNote(teamId: string): string {
    for (const row of TeamNoteStore.cache.entries) {
      if (row.teamId === teamId) {
        return row.text
      }
    }
    return ''
  }

  static listAll(): TeamNoteItem[] {
    const out: TeamNoteItem[] = []
    for (const row of TeamNoteStore.cache.entries) {
      const item = new TeamNoteItem()
      item.teamId = row.teamId
      item.text = row.text
      out.push(item)
    }
    return out
  }

  static async saveNote(teamId: string, text: string): Promise<void> {
    const next = new NoteBundle()
    let found = false
    for (const row of TeamNoteStore.cache.entries) {
      if (row.teamId === teamId) {
        if (text.length > 0) {
          const entry = new NoteEntry()
          entry.teamId = teamId
          entry.text = text
          next.entries.push(entry)
        }
        found = true
      } else {
        next.entries.push(row)
      }
    }
    if (!found && text.length > 0) {
      const entry = new NoteEntry()
      entry.teamId = teamId
      entry.text = text
      next.entries.push(entry)
    }
    TeamNoteStore.cache = next
    await TeamNoteStore.flush()
  }

  private static parse(raw: string): NoteBundle {
    const bundle = new NoteBundle()
    if (raw.length === 0) {
      return bundle
    }
    try {
      const parsed = JSON.parse(raw) as NoteBundle
      if (parsed.entries !== undefined) {
        for (const row of parsed.entries) {
          const entry = new NoteEntry()
          entry.teamId = row.teamId ?? ''
          entry.text = row.text ?? ''
          if (entry.teamId.length > 0) {
            bundle.entries.push(entry)
          }
        }
      }
    } catch {
    }
    return bundle
  }

  private static async flush(): Promise<void> {
    if (TeamNoteStore.pref === null) {
      return
    }
    const parts: string[] = []
    for (const row of TeamNoteStore.cache.entries) {
      parts.push(`{"teamId":${JSON.stringify(row.teamId)},"text":${JSON.stringify(row.text)}}`)
    }
    const raw = `{"entries":[${parts.join(',')}]}`
    try {
      await TeamNoteStore.pref.put(KEY_NOTES, raw)
      await TeamNoteStore.pref.flush()
    } catch {
    }
  }
}
