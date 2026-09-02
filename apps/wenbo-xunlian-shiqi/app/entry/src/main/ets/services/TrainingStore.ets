import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { TrainingRecord } from '../models/TrainingModels'

const STORE_NAME = 'training_fun_v1'
const KEY_RECORDS = 'training_records_json'

export class TrainingStore {
  private static pref: preferences.Preferences | null = null
  private static cache: TrainingRecord[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      TrainingStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await TrainingStore.pref.get(KEY_RECORDS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      TrainingStore.cache = TrainingStore.parseRecords(text)
    } catch {
      TrainingStore.cache = []
    }
  }

  static list(): TrainingRecord[] {
    const copy = TrainingStore.cache.slice()
    copy.sort((a: TrainingRecord, b: TrainingRecord) => {
      if (a.recordDate === b.recordDate) {
        return b.createdAt.localeCompare(a.createdAt)
      }
      return b.recordDate.localeCompare(a.recordDate)
    })
    return copy
  }

  static recent(limit: number): TrainingRecord[] {
    const all = TrainingStore.list()
    const out: TrainingRecord[] = []
    for (let i = 0; i < all.length && i < limit; i++) {
      out.push(all[i])
    }
    return out
  }

  static findById(id: string): TrainingRecord | null {
    for (const item of TrainingStore.cache) {
      if (item.id === id) {
        return item
      }
    }
    return null
  }

  static byDate(dateKey: string): TrainingRecord[] {
    const out: TrainingRecord[] = []
    for (const item of TrainingStore.cache) {
      if (item.recordDate === dateKey) {
        out.push(item)
      }
    }
    out.sort((a: TrainingRecord, b: TrainingRecord) => b.createdAt.localeCompare(a.createdAt))
    return out
  }

  static datesWithRecords(): string[] {
    const set: string[] = []
    for (const item of TrainingStore.cache) {
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

  static async save(record: TrainingRecord): Promise<void> {
    await TrainingStore.saveItem(record)
  }

  static async saveItem(record: TrainingRecord): Promise<void> {
    let found = false
    const next: TrainingRecord[] = []
    for (const item of TrainingStore.cache) {
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
    TrainingStore.cache = next
    await TrainingStore.flush()
  }

  static async remove(id: string): Promise<void> {
    await TrainingStore.deleteItem(id)
  }

  static async deleteItem(id: string): Promise<void> {
    const next: TrainingRecord[] = []
    for (const item of TrainingStore.cache) {
      if (item.id !== id) {
        next.push(item)
      }
    }
    TrainingStore.cache = next
    await TrainingStore.flush()
  }

  private static async flush(): Promise<void> {
    if (TrainingStore.pref === null) {
      return
    }
    await TrainingStore.pref.put(KEY_RECORDS, JSON.stringify(TrainingStore.cache))
    await TrainingStore.pref.flush()
  }

  private static parseRecords(text: string): TrainingRecord[] {
    try {
      const arr = JSON.parse(text) as object[]
      const out: TrainingRecord[] = []
      for (const raw of arr) {
        const r = TrainingStore.mapRecord(raw)
        if (r.id.length > 0) {
          out.push(r)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static mapRecord(raw: object): TrainingRecord {
    const r = new TrainingRecord()
    const o = raw as Record<string, string | number>
    r.id = typeof o['id'] === 'string' ? o['id'] : ''
    r.trainingType = typeof o['trainingType'] === 'string' ? o['trainingType'] : '跑步'
    r.recordDate = typeof o['recordDate'] === 'string' ? o['recordDate'] : ''
    r.durationMin = typeof o['durationMin'] === 'number' ? o['durationMin'] : 0
    r.note = typeof o['note'] === 'string' ? o['note'] : ''
    r.harvest = typeof o['harvest'] === 'string' ? o['harvest'] : ''
    r.feeling = typeof o['feeling'] === 'string' ? o['feeling'] : '刚好'
    r.intensity = typeof o['intensity'] === 'string' ? o['intensity'] : '中'
    r.completeStatus = typeof o['completeStatus'] === 'string' && o['completeStatus'].length > 0 ? o['completeStatus'] : '已完成'
    r.createdAt = typeof o['createdAt'] === 'string' ? o['createdAt'] : ''
    return r
  }
}
