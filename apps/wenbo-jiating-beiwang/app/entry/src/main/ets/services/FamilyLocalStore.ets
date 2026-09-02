import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  LocalBundle,
  FamilyTask,
  FamilyList,
  FamilyNote,
  FamilyReminder
} from '../models/FamilyModels'

const STORE = 'family_memo_local'
const KEY_BUNDLE = 'bundle'
const KEY_ONBOARD = 'onboardingDone'
const KEY_NOTIFY = 'notifyEnabled'
const KEY_APPEARANCE = 'appearance'

class BundleWire {
  lists: FamilyList[] = []
  items: FamilyTask[] = []
  memos: FamilyNote[] = []
  reminders: FamilyReminder[] = []
}

export class FamilyLocalStore {
  private static pref: preferences.Preferences | null = null
  private static cache: LocalBundle = new LocalBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      FamilyLocalStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await FamilyLocalStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      FamilyLocalStore.cache = FamilyLocalStore.parseBundle(raw)
      const onboardValue = await FamilyLocalStore.pref.get(KEY_ONBOARD, false)
      AppStorage.setOrCreate(KEY_ONBOARD, onboardValue === true)
      const notifyValue = await FamilyLocalStore.pref.get(KEY_NOTIFY, true)
      AppStorage.setOrCreate(KEY_NOTIFY, notifyValue !== false)
      const appearValue = await FamilyLocalStore.pref.get(KEY_APPEARANCE, 'system')
      const appear: string = typeof appearValue === 'string' ? appearValue : 'system'
      AppStorage.setOrCreate(KEY_APPEARANCE, appear)
    } catch {
      FamilyLocalStore.cache = new LocalBundle()
      AppStorage.setOrCreate(KEY_ONBOARD, false)
      AppStorage.setOrCreate(KEY_NOTIFY, true)
      AppStorage.setOrCreate(KEY_APPEARANCE, 'system')
    }
  }

  static snapshot(): LocalBundle {
    return FamilyLocalStore.cache
  }

  static lists(): FamilyList[] {
    return FamilyLocalStore.copyLists(FamilyLocalStore.cache.lists)
  }

  static items(): FamilyTask[] {
    return FamilyLocalStore.copyItems(FamilyLocalStore.cache.items)
  }

  static memos(): FamilyNote[] {
    return FamilyLocalStore.copyMemos(FamilyLocalStore.cache.memos)
  }

  static reminders(): FamilyReminder[] {
    return FamilyLocalStore.copyReminders(FamilyLocalStore.cache.reminders)
  }

  static itemsOf(listId: string): FamilyTask[] {
    const out: FamilyTask[] = []
    for (const it of FamilyLocalStore.cache.items) {
      if (it.listId === listId) {
        out.push(FamilyLocalStore.cloneItem(it))
      }
    }
    return out
  }

  static async saveBundle(next: LocalBundle): Promise<void> {
    FamilyLocalStore.cache = next
    await FamilyLocalStore.putString(KEY_BUNDLE, FamilyLocalStore.serializeBundle(next))
  }

  static serializeBundle(bundle: LocalBundle): string {
    const wire = new BundleWire()
    wire.lists = bundle.lists
    wire.items = bundle.items
    wire.memos = bundle.memos
    wire.reminders = bundle.reminders
    return JSON.stringify(wire)
  }

  static async replaceAll(lists: FamilyList[], items: FamilyTask[],
    memos: FamilyNote[], reminders: FamilyReminder[]): Promise<void> {
    const next = new LocalBundle()
    next.lists = lists
    next.items = items
    next.memos = memos
    next.reminders = reminders
    await FamilyLocalStore.saveBundle(next)
  }

  static async setOnboardingDone(): Promise<void> {
    AppStorage.setOrCreate(KEY_ONBOARD, true)
    await FamilyLocalStore.putBool(KEY_ONBOARD, true)
  }

  static async setNotifyEnabled(enabled: boolean): Promise<void> {
    AppStorage.setOrCreate(KEY_NOTIFY, enabled)
    await FamilyLocalStore.putBool(KEY_NOTIFY, enabled)
  }

  static async setAppearance(mode: string): Promise<void> {
    AppStorage.setOrCreate(KEY_APPEARANCE, mode)
    await FamilyLocalStore.putString(KEY_APPEARANCE, mode)
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (FamilyLocalStore.pref === null) {
      return
    }
    try {
      await FamilyLocalStore.pref.put(key, value)
      await FamilyLocalStore.pref.flush()
    } catch {
    }
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (FamilyLocalStore.pref === null) {
      return
    }
    try {
      await FamilyLocalStore.pref.put(key, value)
      await FamilyLocalStore.pref.flush()
    } catch {
    }
  }

  static nowIso(): string {
    return new Date().toISOString()
  }

  static today(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms: string = m < 10 ? `0${m}` : `${m}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}_${FamilyLocalStore.cache.lists.length}_${FamilyLocalStore.cache.items.length}`
  }

  static cloneList(row: FamilyList): FamilyList {
    const out = new FamilyList()
    out.id = row.id ?? ''
    out.title = row.title ?? ''
    out.summary = row.summary ?? ''
    out.body = row.body ?? ''
    out.status = row.status ?? 'active'
    out.dueDate = row.dueDate ?? ''
    out.coverKey = row.coverKey ?? 'home_hero'
    out.userId = row.userId ?? ''
    out.createdAt = row.createdAt ?? ''
    out.updatedAt = row.updatedAt ?? ''
    return out
  }

  static cloneItem(row: FamilyTask): FamilyTask {
    const out = new FamilyTask()
    out.id = row.id ?? ''
    out.listId = row.listId ?? ''
    out.title = row.title ?? ''
    out.category = row.category ?? '其他'
    out.qty = row.qty ?? ''
    out.remark = row.remark ?? ''
    out.completed = row.completed === true
    out.userId = row.userId ?? ''
    out.updatedAt = row.updatedAt ?? ''
    return out
  }

  static cloneMemo(row: FamilyNote): FamilyNote {
    const out = new FamilyNote()
    out.id = row.id ?? ''
    out.title = row.title ?? ''
    out.body = row.body ?? ''
    out.important = row.important === true
    out.remindAt = row.remindAt ?? ''
    out.userId = row.userId ?? ''
    out.updatedAt = row.updatedAt ?? ''
    return out
  }

  static cloneReminder(row: FamilyReminder): FamilyReminder {
    const out = new FamilyReminder()
    out.id = row.id ?? ''
    out.listId = row.listId ?? ''
    out.title = row.title ?? ''
    out.remindAt = row.remindAt ?? ''
    out.status = row.status ?? 'scheduled'
    out.userId = row.userId ?? ''
    out.agentId = row.agentId ?? 0
    out.cycle = row.cycle ?? 'once'
    return out
  }

  static copyLists(rows: FamilyList[]): FamilyList[] {
    const out: FamilyList[] = []
    for (const row of rows) {
      out.push(FamilyLocalStore.cloneList(row))
    }
    return out
  }

  static copyItems(rows: FamilyTask[]): FamilyTask[] {
    const out: FamilyTask[] = []
    for (const row of rows) {
      out.push(FamilyLocalStore.cloneItem(row))
    }
    return out
  }

  static copyMemos(rows: FamilyNote[]): FamilyNote[] {
    const out: FamilyNote[] = []
    for (const row of rows) {
      out.push(FamilyLocalStore.cloneMemo(row))
    }
    return out
  }

  static copyReminders(rows: FamilyReminder[]): FamilyReminder[] {
    const out: FamilyReminder[] = []
    for (const row of rows) {
      out.push(FamilyLocalStore.cloneReminder(row))
    }
    return out
  }

  private static parseBundle(raw: string): LocalBundle {
    const empty = new LocalBundle()
    if (raw.length === 0) {
      return empty
    }
    try {
      const parsed = JSON.parse(raw) as BundleWire
      const out = new LocalBundle()
      if (parsed.lists !== undefined) {
        out.lists = FamilyLocalStore.copyLists(parsed.lists)
      }
      if (parsed.items !== undefined) {
        out.items = FamilyLocalStore.copyItems(parsed.items)
      }
      if (parsed.memos !== undefined) {
        out.memos = FamilyLocalStore.copyMemos(parsed.memos)
      }
      if (parsed.reminders !== undefined) {
        out.reminders = FamilyLocalStore.copyReminders(parsed.reminders)
      }
      return out
    } catch {
      return empty
    }
  }
}
