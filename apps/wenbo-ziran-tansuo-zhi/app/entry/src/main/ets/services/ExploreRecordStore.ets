import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { ExploreRecord, ExploreStats } from '../models/ExploreRecordModels'

const STORE = 'nq_explore_records_v1'
const KEY_RECORDS = 'records'

export class ExploreRecordStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ExploreRecordStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ExploreRecordStore.pref = null
    }
  }

  static async loadAll(): Promise<ExploreRecord[]> {
    const raw = await ExploreRecordStore.getString(KEY_RECORDS, '')
    return ExploreRecordStore.parseRecords(raw)
  }

  static async findById(id: string): Promise<ExploreRecord | undefined> {
    const list = await ExploreRecordStore.loadAll()
    for (const r of list) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async save(record: ExploreRecord): Promise<boolean> {
    if (record.title.trim().length === 0) {
      return false
    }
    const list = await ExploreRecordStore.loadAll()
    const next: ExploreRecord[] = []
    let replaced = false
    for (const r of list) {
      if (r.id === record.id) {
        next.push(record)
        replaced = true
      } else {
        next.push(r)
      }
    }
    if (!replaced) {
      next.push(record)
    }
    next.sort((a, b) => b.createdAt - a.createdAt)
    await ExploreRecordStore.persist(next)
    ExploreRecordStore.bumpRefresh()
    return true
  }

  static async remove(id: string): Promise<void> {
    const list = await ExploreRecordStore.loadAll()
    const next: ExploreRecord[] = []
    for (const r of list) {
      if (r.id !== id) {
        next.push(r)
      }
    }
    await ExploreRecordStore.persist(next)
    ExploreRecordStore.bumpRefresh()
  }

  static async computeStats(): Promise<ExploreStats> {
    const list = await ExploreRecordStore.loadAll()
    const stats = new ExploreStats()
    stats.recordCount = list.length
    const locSet: string[] = []
    let mileage = 0
    for (const r of list) {
      const loc = r.location.trim()
      if (loc.length > 0) {
        let found = false
        for (const x of locSet) {
          if (x === loc) {
            found = true
          }
        }
        if (!found) {
          locSet.push(loc)
        }
      }
      if (r.lat !== 0 || r.lng !== 0) {
        mileage += 3.5
      } else if (loc.length > 0) {
        mileage += 2
      }
    }
    stats.locationCount = locSet.length
    stats.mileageKm = Math.round(mileage * 10) / 10
    return stats
  }

  static async recordsWithCoords(): Promise<ExploreRecord[]> {
    const list = await ExploreRecordStore.loadAll()
    const out: ExploreRecord[] = []
    for (const r of list) {
      if (r.lat !== 0 || r.lng !== 0 || r.location.trim().length > 0) {
        out.push(r)
      }
    }
    return out
  }

  private static bumpRefresh(): void {
    const token = AppStorage.get<number>('recordRefreshToken') ?? 0
    AppStorage.setOrCreate('recordRefreshToken', token + 1)
  }

  private static async persist(items: ExploreRecord[]): Promise<void> {
    const lines: string[] = []
    for (const r of items) {
      lines.push(ExploreRecordStore.serialize(r))
    }
    await ExploreRecordStore.putString(KEY_RECORDS, lines.join('\n'))
  }

  private static serialize(r: ExploreRecord): string {
    const title = r.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const location = r.location.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const body = r.body.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const photos = r.photoPaths.replace(/\t/g, ' ').replace(/\n/g, ' ')
    return [
      r.id, title, location, r.date, r.weather, body, photos,
      `${r.lat}`, `${r.lng}`, `${r.createdAt}`
    ].join('\t')
  }

  private static parseRecords(raw: string): ExploreRecord[] {
    const out: ExploreRecord[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 10) {
        continue
      }
      const r = new ExploreRecord()
      r.id = parts[0]
      r.title = parts[1]
      r.location = parts[2]
      r.date = parts[3]
      r.weather = parts[4]
      r.body = parts[5]
      r.photoPaths = parts[6]
      r.lat = parseFloat(parts[7])
      r.lng = parseFloat(parts[8])
      r.createdAt = parseInt(parts[9], 10)
      out.push(r)
    }
    out.sort((a, b) => b.createdAt - a.createdAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ExploreRecordStore.pref === null) {
      return fallback
    }
    try {
      const v = await ExploreRecordStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ExploreRecordStore.pref === null) {
      return
    }
    try {
      await ExploreRecordStore.pref.put(key, value)
      await ExploreRecordStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
