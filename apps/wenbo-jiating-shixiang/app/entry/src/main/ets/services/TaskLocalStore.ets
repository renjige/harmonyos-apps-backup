import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  BundleWire,
  FamilyTaskItem,
  LocalBundle,
  TaskDates
} from '../models/FamilyTaskModels'
import { CategorySuggest } from './CategorySuggest'

const STORE = 'family_task_local'
const KEY_BUNDLE = 'bundle'
const KEY_ONBOARD = 'onboardingDone'
const KEY_NOTIFY = 'notifyEnabled'
const KEY_APPEARANCE = 'appearance'
const KEY_DEFAULT_REMIND = 'defaultReminder'

export class TaskLocalStore {
  private static pref: preferences.Preferences | null = null
  private static cache: LocalBundle = new LocalBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      TaskLocalStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await TaskLocalStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      TaskLocalStore.cache = TaskLocalStore.parseBundle(raw)
      const onboardValue = await TaskLocalStore.pref.get(KEY_ONBOARD, false)
      AppStorage.setOrCreate(KEY_ONBOARD, onboardValue === true)
      const notifyValue = await TaskLocalStore.pref.get(KEY_NOTIFY, true)
      AppStorage.setOrCreate(KEY_NOTIFY, notifyValue !== false)
      const appearValue = await TaskLocalStore.pref.get(KEY_APPEARANCE, 'system')
      const appear: string = typeof appearValue === 'string' ? appearValue : 'system'
      AppStorage.setOrCreate(KEY_APPEARANCE, appear)
      const remindValue = await TaskLocalStore.pref.get(KEY_DEFAULT_REMIND, 'none')
      const remind: string = typeof remindValue === 'string' ? remindValue : 'none'
      AppStorage.setOrCreate(KEY_DEFAULT_REMIND, remind)
    } catch {
      TaskLocalStore.cache = new LocalBundle()
      AppStorage.setOrCreate(KEY_ONBOARD, false)
      AppStorage.setOrCreate(KEY_NOTIFY, true)
      AppStorage.setOrCreate(KEY_APPEARANCE, 'system')
      AppStorage.setOrCreate(KEY_DEFAULT_REMIND, 'none')
    }
  }

  static snapshot(): LocalBundle {
    return TaskLocalStore.cache
  }

  static tasks(): FamilyTaskItem[] {
    return TaskLocalStore.cache.tasks
  }

  static async saveTasks(tasks: FamilyTaskItem[]): Promise<void> {
    const next = new LocalBundle()
    next.tasks = tasks
    TaskLocalStore.cache = next
    await TaskLocalStore.putString(KEY_BUNDLE, TaskLocalStore.serializeBundle(next))
  }

  static serializeBundle(bundle: LocalBundle): string {
    const wire = new BundleWire()
    wire.tasks = bundle.tasks
    return JSON.stringify(wire)
  }

  static async setOnboardingDone(): Promise<void> {
    AppStorage.setOrCreate(KEY_ONBOARD, true)
    await TaskLocalStore.putBool(KEY_ONBOARD, true)
  }

  static async setNotifyEnabled(enabled: boolean): Promise<void> {
    AppStorage.setOrCreate(KEY_NOTIFY, enabled)
    await TaskLocalStore.putBool(KEY_NOTIFY, enabled)
  }

  static async setAppearance(mode: string): Promise<void> {
    AppStorage.setOrCreate(KEY_APPEARANCE, mode)
    await TaskLocalStore.putString(KEY_APPEARANCE, mode)
  }

  static async setDefaultReminder(code: string): Promise<void> {
    AppStorage.setOrCreate(KEY_DEFAULT_REMIND, code)
    await TaskLocalStore.putString(KEY_DEFAULT_REMIND, code)
  }

  static nowIso(): string {
    return new Date().toISOString()
  }

  static newId(): string {
    return `ft_${Date.now()}`
  }

  static async seedWelcomeSamples(): Promise<void> {
    if (TaskLocalStore.cache.tasks.length > 0) {
      return
    }
    const today = TaskDates.today()
    const samples: FamilyTaskItem[] = []
    samples.push(TaskLocalStore.makeSample('购买早餐食材', '采购', today, '08:30'))
    samples.push(TaskLocalStore.makeSample('倒垃圾', '家务', today, '09:00'))
    samples.push(TaskLocalStore.makeSample('整理客厅', '家务', today, '10:00'))
    samples.push(TaskLocalStore.makeSample('接孩子', '孩子', today, '16:30'))
    samples.push(TaskLocalStore.makeSample('家庭晚餐', '家庭', today, '18:30'))
    await TaskLocalStore.saveTasks(samples)
  }

  private static makeSample(title: string, category: string, date: string, time: string): FamilyTaskItem {
    const row = new FamilyTaskItem()
    row.id = `sample_${title}`
    row.title = title
    row.category = category
    row.date = date
    row.time = time
    row.completed = false
    row.reminder = 'none'
    row.repeatType = 'none'
    row.userId = 'local'
    row.isSample = true
    row.createdAt = TaskLocalStore.nowIso()
    row.updatedAt = row.createdAt
    return row
  }

  static mapTask(row: FamilyTaskItem): FamilyTaskItem {
    const item = new FamilyTaskItem()
    item.id = row.id ?? ''
    item.title = row.title ?? ''
    item.category = row.category ?? '其他'
    item.date = row.date ?? ''
    item.time = row.time ?? ''
    item.completed = row.completed === true
    item.reminder = row.reminder ?? 'none'
    item.repeatType = row.repeatType ?? 'none'
    item.remark = row.remark ?? ''
    item.userId = row.userId ?? ''
    item.createdAt = row.createdAt ?? ''
    item.updatedAt = row.updatedAt ?? ''
    item.isSample = row.isSample === true
    if (item.category.length === 0) {
      item.category = CategorySuggest.suggest(item.title)
    }
    return item
  }

  private static parseBundle(raw: string): LocalBundle {
    const empty = new LocalBundle()
    if (raw.length === 0) {
      return empty
    }
    try {
      const parsed = JSON.parse(raw) as BundleWire
      const out = new LocalBundle()
      if (parsed.tasks !== undefined) {
        const mapped: FamilyTaskItem[] = []
        for (const row of parsed.tasks) {
          const item = TaskLocalStore.mapTask(row)
          if (item.title.length > 0) {
            mapped.push(item)
          }
        }
        out.tasks = mapped
      }
      return out
    } catch {
      return empty
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (TaskLocalStore.pref === null) {
      return
    }
    try {
      await TaskLocalStore.pref.put(key, value)
      await TaskLocalStore.pref.flush()
    } catch {
    }
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (TaskLocalStore.pref === null) {
      return
    }
    try {
      await TaskLocalStore.pref.put(key, value)
      await TaskLocalStore.pref.flush()
    } catch {
    }
  }
}
