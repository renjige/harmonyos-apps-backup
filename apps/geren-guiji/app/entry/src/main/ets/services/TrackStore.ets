import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { TrackRecord } from '../models/TrackModels'

const STORE_NAME = 'track_local_v2'
const KEY_TRACKS = 'footprints_json'

export class TrackStore {
  private static pref: preferences.Preferences | null = null
  private static cache: TrackRecord[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      TrackStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await TrackStore.pref.get(KEY_TRACKS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      TrackStore.cache = TrackStore.parseRecords(text)
    } catch {
      TrackStore.cache = []
    }
  }

  static list(): TrackRecord[] {
    return TrackStore.cache.slice().reverse()
  }

  static recent(limit: number): TrackRecord[] {
    const all = TrackStore.list()
    const out: TrackRecord[] = []
    for (let i = 0; i < all.length && i < limit; i++) {
      out.push(all[i])
    }
    return out
  }

  static findById(id: string): TrackRecord | null {
    for (const item of TrackStore.cache) {
      if (item.id === id) {
        return item
      }
    }
    return null
  }

  static async save(record: TrackRecord): Promise<void> {
    let found = false
    const next: TrackRecord[] = []
    for (const item of TrackStore.cache) {
      if (item.id === record.id) {
        next.push(record)
        found = true
      } else {
        next.push(item)
      }
    }
    if (!found) {
      next.push(record)
    }
    TrackStore.cache = next
    await TrackStore.flush()
  }

  static async remove(id: string): Promise<void> {
    const next: TrackRecord[] = []
    for (const item of TrackStore.cache) {
      if (item.id !== id) {
        next.push(item)
      }
    }
    TrackStore.cache = next
    await TrackStore.flush()
  }

  static async removeMany(ids: string[]): Promise<void> {
    const next: TrackRecord[] = []
    for (const item of TrackStore.cache) {
      let hit = false
      for (const id of ids) {
        if (item.id === id) {
          hit = true
          break
        }
      }
      if (!hit) {
        next.push(item)
      }
    }
    TrackStore.cache = next
    await TrackStore.flush()
  }

  private static async flush(): Promise<void> {
    if (TrackStore.pref === null) {
      return
    }
    await TrackStore.pref.put(KEY_TRACKS, JSON.stringify(TrackStore.cache))
    await TrackStore.pref.flush()
  }

  private static parseRecords(text: string): TrackRecord[] {
    try {
      const arr = JSON.parse(text) as object[]
      const out: TrackRecord[] = []
      if (!Array.isArray(arr)) {
        return out
      }
      for (const raw of arr) {
        const rec = TrackStore.mapRecord(raw)
        if (rec.id.length > 0) {
          out.push(rec)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static mapRecord(raw: object): TrackRecord {
    const rec = new TrackRecord()
    const obj = raw as Record<string, string | number>
    rec.id = typeof obj['id'] === 'string' ? obj['id'] : ''
    rec.title = typeof obj['title'] === 'string' ? obj['title'] : ''
    rec.placeName = typeof obj['placeName'] === 'string' ? obj['placeName'] : ''
    rec.note = typeof obj['note'] === 'string' ? obj['note'] : ''
    rec.startedAt = typeof obj['startedAt'] === 'string' ? obj['startedAt'] : ''
    rec.endedAt = typeof obj['endedAt'] === 'string' ? obj['endedAt'] : ''
    rec.durationSec = typeof obj['durationSec'] === 'number' ? obj['durationSec'] : 0
    rec.distanceM = typeof obj['distanceM'] === 'number' ? obj['distanceM'] : 0
    rec.status = typeof obj['status'] === 'string' ? obj['status'] : 'manual'
    return rec
  }
}
