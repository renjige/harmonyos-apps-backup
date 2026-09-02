import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { SportRecord } from '../models/SportModels'
import { SportModelClone } from './SportModelClone'
import { PlanSyncService } from './PlanSyncService'

const STORE_NAME = 'sport_journal_v1'
const KEY_RECORDS = 'sport_records_json'

export class SportStore {
  private static pref: preferences.Preferences | null = null
  private static cache: SportRecord[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SportStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await SportStore.pref.get(KEY_RECORDS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      SportStore.cache = SportStore.parseRecords(text)
    } catch {
      SportStore.cache = []
    }
  }

  static list(): SportRecord[] {
    const copy: SportRecord[] = []
    for (const item of SportStore.cache) {
      copy.push(SportModelClone.record(item))
    }
    copy.sort((a: SportRecord, b: SportRecord) => {
      if (a.recordDate === b.recordDate) {
        return b.createdAt.localeCompare(a.createdAt)
      }
      return b.recordDate.localeCompare(a.recordDate)
    })
    return copy
  }

  static recent(limit: number): SportRecord[] {
    const all = SportStore.list()
    const out: SportRecord[] = []
    for (let i = 0; i < all.length && i < limit; i++) {
      out.push(all[i])
    }
    return out
  }

  static findById(id: string): SportRecord | null {
    for (const item of SportStore.cache) {
      if (item.id === id) {
        return SportModelClone.record(item)
      }
    }
    return null
  }

  static byDate(dateKey: string): SportRecord[] {
    const out: SportRecord[] = []
    for (const item of SportStore.cache) {
      if (item.recordDate === dateKey) {
        out.push(item)
      }
    }
    out.sort((a: SportRecord, b: SportRecord) => b.createdAt.localeCompare(a.createdAt))
    return out
  }

  static datesWithRecords(): string[] {
    const set: string[] = []
    for (const item of SportStore.cache) {
      let hit = false
      for (const d of set) {
        if (d === item.recordDate) {
          hit = true
          break
        }
      }
      if (!hit && item.recordDate.length > 0) {
        set.push(item.recordDate)
      }
    }
    return set
  }

  static async save(record: SportRecord): Promise<void> {
    let found = false
    const next: SportRecord[] = []
    for (const item of SportStore.cache) {
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
    SportStore.cache = next
    await SportStore.flush()
    await PlanSyncService.applyRecord(record)
    SportStore.bumpDataEpoch()
  }

  static async remove(id: string): Promise<void> {
    const next: SportRecord[] = []
    for (const item of SportStore.cache) {
      if (item.id !== id) {
        next.push(item)
      }
    }
    SportStore.cache = next
    await SportStore.flush()
    SportStore.bumpDataEpoch()
  }

  static notifyDataChanged(): void {
    SportStore.bumpDataEpoch()
  }

  private static bumpDataEpoch(): void {
    const next = (AppStorage.get<number>('sportDataEpoch') ?? 0) + 1
    AppStorage.setOrCreate('sportDataEpoch', next)
  }

  private static async flush(): Promise<void> {
    if (SportStore.pref === null) {
      return
    }
    await SportStore.pref.put(KEY_RECORDS, JSON.stringify(SportStore.cache))
    await SportStore.pref.flush()
  }

  private static parseRecords(text: string): SportRecord[] {
    try {
      const arr = JSON.parse(text) as object[]
      const out: SportRecord[] = []
      for (const raw of arr) {
        const r = SportStore.mapRecord(raw)
        if (r.id.length > 0) {
          out.push(r)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static mapRecord(raw: object): SportRecord {
    const r = new SportRecord()
    const o = raw as Record<string, string | number>
    r.id = typeof o['id'] === 'string' ? o['id'] : ''
    r.sportType = typeof o['sportType'] === 'string' ? o['sportType'] : '跑步'
    r.recordDate = typeof o['recordDate'] === 'string' ? o['recordDate'] : ''
    r.durationMin = typeof o['durationMin'] === 'number' ? o['durationMin'] : 0
    r.distanceKm = typeof o['distanceKm'] === 'number' ? o['distanceKm'] : 0
    r.paceMinPerKm = typeof o['paceMinPerKm'] === 'number' ? o['paceMinPerKm'] : 0
    r.heartRate = typeof o['heartRate'] === 'number' ? o['heartRate'] : 0
    r.calories = typeof o['calories'] === 'number' ? o['calories'] : 0
    r.tags = typeof o['tags'] === 'string' ? o['tags'] : ''
    r.note = typeof o['note'] === 'string' ? o['note'] : ''
    r.feeling = typeof o['feeling'] === 'string' ? o['feeling'] : ''
    r.weather = typeof o['weather'] === 'string' ? o['weather'] : ''
    r.takeaway = typeof o['takeaway'] === 'string' ? o['takeaway'] : ''
    r.nextFocus = typeof o['nextFocus'] === 'string' ? o['nextFocus'] : ''
    r.createdAt = typeof o['createdAt'] === 'string' ? o['createdAt'] : ''
    return r
  }
}
