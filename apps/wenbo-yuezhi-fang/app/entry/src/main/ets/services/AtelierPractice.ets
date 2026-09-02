import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { PracticeItem } from '../models/PracticeModels'
import { AtelierJson } from './AtelierJson'
import { AtelierTime } from '../models/AtelierModels'

const STORE_NAME = 'yuezhifang_local'
const KEY_WORK = 'work_json'

/** 工坊课业本机账本。新用户为空，不预置他人记录。 */
export class AtelierPractice {
  private static pref: preferences.Preferences | null = null
  private static items: PracticeItem[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      AtelierPractice.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await AtelierPractice.pref.get(KEY_WORK, '{"list":[]}')
      const text: string = typeof raw === 'string' ? raw : '{"list":[]}'
      AtelierPractice.items = AtelierPractice.decode(text)
    } catch {
      AtelierPractice.items = []
    }
  }

  static all(): PracticeItem[] {
    const out: PracticeItem[] = []
    for (const row of AtelierPractice.items) {
      out.push(row)
    }
    return out
  }

  static count(): number {
    return AtelierPractice.items.length
  }

  static find(id: string): PracticeItem | undefined {
    for (const row of AtelierPractice.items) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  static async save(item: PracticeItem): Promise<PracticeItem> {
    if (item.id.length === 0) {
      item.id = `w_${Date.now()}`
    }
    if (item.dateKey.length === 0) {
      item.dateKey = AtelierTime.todayKey()
    }
    const next: PracticeItem[] = []
    let replaced = false
    for (const row of AtelierPractice.items) {
      if (row.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(row)
      }
    }
    if (!replaced) {
      next.unshift(item)
    }
    AtelierPractice.items = next
    await AtelierPractice.flush()
    return item
  }

  static async remove(id: string): Promise<void> {
    const next: PracticeItem[] = []
    for (const row of AtelierPractice.items) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    AtelierPractice.items = next
    await AtelierPractice.flush()
  }

  private static decode(text: string): PracticeItem[] {
    const out: PracticeItem[] = []
    const blobs = AtelierJson.listObjects(text)
    for (const obj of blobs) {
      const id = AtelierJson.readField(obj, 'id')
      if (id.length === 0) {
        continue
      }
      const minsRaw = AtelierJson.readField(obj, 'minutes')
      const mins = Number(minsRaw)
      out.push(PracticeItem.of(
        id,
        AtelierJson.readField(obj, 'kind'),
        AtelierJson.readField(obj, 'cardId'),
        AtelierJson.readField(obj, 'title'),
        AtelierJson.readField(obj, 'fieldA'),
        AtelierJson.readField(obj, 'fieldB'),
        AtelierJson.readField(obj, 'fieldC'),
        mins === mins && mins > 0 ? mins : 0,
        AtelierJson.readField(obj, 'dateKey')
      ))
    }
    return out
  }

  private static async flush(): Promise<void> {
    if (AtelierPractice.pref === null) {
      return
    }
    let json = '{"list":['
    for (let i = 0; i < AtelierPractice.items.length; i++) {
      if (i > 0) {
        json += ','
      }
      json += AtelierPractice.items[i].toJsonString()
    }
    json += ']}'
    await AtelierPractice.pref.put(KEY_WORK, json)
    await AtelierPractice.pref.flush()
  }
}
