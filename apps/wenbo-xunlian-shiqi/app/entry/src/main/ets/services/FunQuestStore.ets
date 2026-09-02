import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { FunQuest } from '../models/TrainingModels'

const STORE_NAME = 'training_fun_quest_v1'
const KEY_QUESTS = 'fun_quests_json'

export class FunQuestStore {
  private static pref: preferences.Preferences | null = null
  private static cache: FunQuest[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      FunQuestStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await FunQuestStore.pref.get(KEY_QUESTS, '[]')
      const text: string = typeof raw === 'string' ? raw : '[]'
      FunQuestStore.cache = FunQuestStore.parseList(text)
    } catch {
      FunQuestStore.cache = []
    }
  }

  static list(): FunQuest[] {
    const copy = FunQuestStore.cache.slice()
    copy.sort((a: FunQuest, b: FunQuest) => b.createdAt.localeCompare(a.createdAt))
    return copy
  }

  static active(): FunQuest[] {
    const out: FunQuest[] = []
    for (const q of FunQuestStore.list()) {
      if (q.status === 'active') {
        out.push(q)
      }
    }
    return out
  }

  static findById(id: string): FunQuest | null {
    for (const q of FunQuestStore.cache) {
      if (q.id === id) {
        return q
      }
    }
    return null
  }

  static async saveItem(quest: FunQuest): Promise<void> {
    let found = false
    const next: FunQuest[] = []
    for (const item of FunQuestStore.cache) {
      if (item.id === quest.id) {
        next.push(quest)
        found = true
      } else {
        next.push(item)
      }
    }
    if (!found) {
      next.push(quest)
    }
    FunQuestStore.cache = next
    await FunQuestStore.flush()
  }

  static async deleteItem(id: string): Promise<void> {
    const next: FunQuest[] = []
    for (const item of FunQuestStore.cache) {
      if (item.id !== id) {
        next.push(item)
      }
    }
    FunQuestStore.cache = next
    await FunQuestStore.flush()
  }

  private static async flush(): Promise<void> {
    if (FunQuestStore.pref === null) {
      return
    }
    await FunQuestStore.pref.put(KEY_QUESTS, JSON.stringify(FunQuestStore.cache))
    await FunQuestStore.pref.flush()
  }

  private static parseList(text: string): FunQuest[] {
    try {
      const arr = JSON.parse(text) as object[]
      const out: FunQuest[] = []
      for (const raw of arr) {
        const q = FunQuestStore.mapOne(raw)
        if (q.id.length > 0) {
          out.push(q)
        }
      }
      return out
    } catch {
      return []
    }
  }

  private static mapOne(raw: object): FunQuest {
    const q = new FunQuest()
    const o = raw as Record<string, string | number>
    q.id = typeof o['id'] === 'string' ? o['id'] : ''
    q.title = typeof o['title'] === 'string' ? o['title'] : ''
    q.theme = typeof o['theme'] === 'string' ? o['theme'] : '随心练'
    q.sportType = typeof o['sportType'] === 'string' ? o['sportType'] : '全部'
    q.targetKind = typeof o['targetKind'] === 'string' ? o['targetKind'] : 'sessions'
    q.targetValue = typeof o['targetValue'] === 'number' ? o['targetValue'] : 3
    q.weekStart = typeof o['weekStart'] === 'string' ? o['weekStart'] : ''
    q.note = typeof o['note'] === 'string' ? o['note'] : ''
    q.status = typeof o['status'] === 'string' ? o['status'] : 'active'
    q.createdAt = typeof o['createdAt'] === 'string' ? o['createdAt'] : ''
    return q
  }
}
