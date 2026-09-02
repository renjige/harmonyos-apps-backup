import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { MoodRecord } from '../models/MoodModels'

const STORE = 'yuehen_mood_v1'
const KEY_ENTRIES = 'entries'

export class MoodStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      MoodStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      MoodStore.pref = null
    }
  }

  static async loadAll(): Promise<MoodRecord[]> {
    const raw = await MoodStore.getString(KEY_ENTRIES, '')
    return MoodStore.parseRecords(raw)
  }

  static async saveRecord(record: MoodRecord): Promise<void> {
    record.updatedAt = Date.now()
    const list = await MoodStore.loadAll()
    const next: MoodRecord[] = []
    let found = false
    for (const it of list) {
      if (it.id === record.id || it.dateKey === record.dateKey) {
        if (!found) {
          if (it.id.length > 0 && record.id.length === 0) {
            record.id = it.id
          }
          next.push(record)
          found = true
        }
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(record)
    }
    next.sort((a, b) => b.dateKey.localeCompare(a.dateKey))
    await MoodStore.persistRecords(next)
  }

  static async deleteRecord(id: string): Promise<void> {
    const list = await MoodStore.loadAll()
    const next: MoodRecord[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await MoodStore.persistRecords(next)
  }

  static async findByDateKey(dateKey: string): Promise<MoodRecord | undefined> {
    const list = await MoodStore.loadAll()
    for (const it of list) {
      if (it.dateKey === dateKey) {
        return it
      }
    }
    return undefined
  }

  static async findById(id: string): Promise<MoodRecord | undefined> {
    const list = await MoodStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async recordsInMonth(year: number, month: number): Promise<MoodRecord[]> {
    const prefix = `${year}-${month < 10 ? '0' + month : month}`
    const list = await MoodStore.loadAll()
    const out: MoodRecord[] = []
    for (const it of list) {
      if (it.dateKey.startsWith(prefix)) {
        out.push(it)
      }
    }
    out.sort((a, b) => a.dateKey.localeCompare(b.dateKey))
    return out
  }

  static async clearAll(): Promise<void> {
    await MoodStore.putString(KEY_ENTRIES, '')
  }

  static async exportAllText(): Promise<string> {
    const list = await MoodStore.loadAll()
    const lines: string[] = []
    lines.push('月痕集 — 情绪记录导出')
    lines.push(`共 ${list.length} 天`)
    lines.push('')
    for (const it of list) {
      lines.push('---')
      lines.push(it.dateKey)
      lines.push(`情绪：${it.emotions.join('、')}`)
      lines.push(`能量：${it.score}/10`)
      lines.push(it.diary)
      if (it.imagePath.length > 0) {
        lines.push(`配图：${it.imagePath}`)
      }
      lines.push('')
    }
    return lines.join('\n')
  }

  private static async persistRecords(items: MoodRecord[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(MoodStore.serialize(it))
    }
    await MoodStore.putString(KEY_ENTRIES, lines.join('\n'))
  }

  private static serialize(it: MoodRecord): string {
    const diary = it.diary.replace(/\n/g, '\\n')
    const emotions = it.emotions.join(',')
    return [
      it.id, it.dateKey, emotions, diary, it.imagePath,
      `${it.score}`, `${it.createdAt}`, `${it.updatedAt}`
    ].join('\t')
  }

  private static parseRecords(raw: string): MoodRecord[] {
    const out: MoodRecord[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 8) {
        continue
      }
      const r = new MoodRecord()
      r.id = parts[0]
      r.dateKey = parts[1]
      r.emotions = parts[2].length > 0 ? parts[2].split(',') : []
      r.diary = parts[3].replace(/\\n/g, '\n')
      r.imagePath = parts[4]
      r.score = parseInt(parts[5], 10)
      r.createdAt = parseInt(parts[6], 10)
      r.updatedAt = parseInt(parts[7], 10)
      out.push(r)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (MoodStore.pref === null) {
      return fallback
    }
    try {
      const v = await MoodStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (MoodStore.pref === null) {
      return
    }
    try {
      await MoodStore.pref.put(key, value)
      await MoodStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
