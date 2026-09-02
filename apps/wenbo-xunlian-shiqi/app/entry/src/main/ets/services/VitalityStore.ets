import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { VitalityState } from '../models/TrainingModels'
import { DateHelper } from './DateHelper'

const STORE_NAME = 'training_vitality_v1'
const KEY = 'vitality_json'

export class VitalityStore {
  private static pref: preferences.Preferences | null = null
  private static cache: VitalityState = new VitalityState()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      VitalityStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const raw = await VitalityStore.pref.get(KEY, '')
      const text: string = typeof raw === 'string' ? raw : ''
      VitalityStore.cache = VitalityStore.parse(text)
      VitalityStore.rollDay()
    } catch {
      VitalityStore.cache = new VitalityState()
    }
  }

  static get(): VitalityState {
    VitalityStore.rollDay()
    return VitalityStore.cache
  }

  static async save(state: VitalityState): Promise<void> {
    VitalityStore.cache = state
    if (VitalityStore.pref === null) {
      return
    }
    await VitalityStore.pref.put(KEY, JSON.stringify(state))
    await VitalityStore.pref.flush()
  }

  private static rollDay(): void {
    const today = DateHelper.todayKey()
    if (VitalityStore.cache.taskDate === today) {
      return
    }
    VitalityStore.cache.taskDate = today
    VitalityStore.cache.warmDone = false
    VitalityStore.cache.trainDone = false
    VitalityStore.cache.noteDone = false
  }

  private static parse(text: string): VitalityState {
    const s = new VitalityState()
    if (text.length === 0) {
      return s
    }
    try {
      const o = JSON.parse(text) as Record<string, string | number | boolean>
      s.points = typeof o['points'] === 'number' ? o['points'] : 0
      s.skinId = typeof o['skinId'] === 'string' ? o['skinId'] : 'dawn'
      s.taskDate = typeof o['taskDate'] === 'string' ? o['taskDate'] : ''
      s.warmDone = o['warmDone'] === true
      s.trainDone = o['trainDone'] === true
      s.noteDone = o['noteDone'] === true
    } catch {
      return s
    }
    return s
  }
}
