import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { SportRecord } from '../models/SportRecord'

const STORE = 'yundong_tuce_v1'
const KEY_RECORDS = 'records'

export class RecordStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      RecordStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      RecordStore.pref = null
    }
  }

  static async loadAll(): Promise<SportRecord[]> {
    const raw = await RecordStore.getString(KEY_RECORDS, '')
    return RecordStore.parseRecords(raw)
  }

  static async saveRecord(record: SportRecord): Promise<void> {
    record.updatedAt = Date.now()
    const list = await RecordStore.loadAll()
    const next: SportRecord[] = []
    let found = false
    for (const it of list) {
      if (it.id === record.id) {
        next.push(record)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(record)
    }
    next.sort((a, b) => b.updatedAt - a.updatedAt)
    await RecordStore.persistRecords(next)
  }

  static async deleteRecord(id: string): Promise<void> {
    const list = await RecordStore.loadAll()
    const next: SportRecord[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await RecordStore.persistRecords(next)
  }

  static async findById(id: string): Promise<SportRecord | undefined> {
    const list = await RecordStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async toggleFavorite(id: string): Promise<boolean> {
    const found = await RecordStore.findById(id)
    if (found === undefined) {
      return false
    }
    found.favorited = !found.favorited
    await RecordStore.saveRecord(found)
    return found.favorited
  }

  static async exportText(): Promise<string> {
    const list = await RecordStore.loadAll()
    const lines: string[] = []
    lines.push('运动图册 — 数据导出')
    lines.push(`共 ${list.length} 条记录`)
    lines.push('')
    for (const it of list) {
      lines.push('---')
      lines.push(`${it.date} ${it.time} · ${it.displayTitle()}`)
      lines.push(`类型: ${SportTypeOptionLabel(it.sportType)}`)
      if (it.summaryLine().length > 0) {
        lines.push(it.summaryLine())
      }
      if (it.note.length > 0) {
        lines.push(it.note)
      }
      lines.push('')
    }
    return lines.join('\n')
  }

  static async exportJson(): Promise<string> {
    const list = await RecordStore.loadAll()
    const rows: ExportRow[] = []
    for (const it of list) {
      const row = new ExportRow()
      row.id = it.id
      row.sportType = it.sportType
      row.customTag = it.customTag
      row.date = it.date
      row.time = it.time
      row.duration = it.duration
      row.distance = it.distance
      row.calories = it.calories
      row.weight = it.weight
      row.note = it.note
      row.photos = it.photos
      rows.push(row)
    }
    const payload = new ExportPayload()
    payload.app = '运动图册'
    payload.count = rows.length
    payload.items = rows
    return JSON.stringify(payload)
  }

  private static async persistRecords(items: SportRecord[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(RecordStore.serialize(it))
    }
    await RecordStore.putString(KEY_RECORDS, lines.join('\n'))
  }

  private static serialize(it: SportRecord): string {
    const note = it.note.replace(/\n/g, '\\n')
    const tag = it.customTag.replace(/\t/g, ' ')
    const photos = it.photos.join('|')
    return [
      it.id, it.sportType, tag, it.date, it.time,
      `${it.duration}`, `${it.distance}`, `${it.calories}`, `${it.weight}`,
      note, photos, `${it.createdAt}`, `${it.updatedAt}`, it.favorited ? '1' : '0'
    ].join('\t')
  }

  private static parseRecords(raw: string): SportRecord[] {
    const out: SportRecord[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 13) {
        continue
      }
      const r = new SportRecord()
      r.id = parts[0]
      r.sportType = parts[1]
      r.customTag = parts[2]
      r.date = parts[3]
      r.time = parts[4]
      r.duration = parseInt(parts[5], 10)
      r.distance = parseFloat(parts[6])
      r.calories = parseInt(parts[7], 10)
      r.weight = parseFloat(parts[8])
      r.note = parts[9].replace(/\\n/g, '\n')
      if (parts[10].length > 0) {
        r.photos = parts[10].split('|')
      }
      r.createdAt = parseInt(parts[11], 10)
      r.updatedAt = parseInt(parts[12], 10)
      if (parts.length >= 14) {
        r.favorited = parts[13] === '1'
      }
      out.push(r)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (RecordStore.pref === null) {
      return fallback
    }
    try {
      const v = await RecordStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (RecordStore.pref === null) {
      return
    }
    try {
      await RecordStore.pref.put(key, value)
      await RecordStore.pref.flush()
    } catch {
      // ignore
    }
  }
}

function SportTypeOptionLabel(id: string): string {
  const opts = ['running', 'fitness', 'yoga', 'cycling', 'swimming', 'basketball', 'other']
  const labels = ['跑步', '健身', '瑜伽', '骑行', '游泳', '篮球', '其他']
  for (let i = 0; i < opts.length; i++) {
    if (opts[i] === id) {
      return labels[i]
    }
  }
  return '其他'
}

class ExportRow {
  id: string = ''
  sportType: string = ''
  customTag: string = ''
  date: string = ''
  time: string = ''
  duration: number = 0
  distance: number = 0
  calories: number = 0
  weight: number = 0
  note: string = ''
  photos: string[] = []
}

class ExportPayload {
  app: string = ''
  count: number = 0
  items: ExportRow[] = []
}
