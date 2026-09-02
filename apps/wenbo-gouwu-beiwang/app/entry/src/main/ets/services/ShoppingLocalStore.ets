import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  FrequentItem,
  LocalBundle,
  ShoppingItem,
  ShoppingList,
  ShoppingMemoNote,
  ShoppingReminder,
  WidgetPayload
} from '../models/ShoppingModels'

const STORE = 'shopping_memo_local'
const KEY_BUNDLE = 'bundle'
const KEY_ONBOARD = 'onboardingDone'
const KEY_NOTIFY = 'notifyEnabled'
const KEY_APPEARANCE = 'appearance'
const KEY_WIDGET = 'widgetSnapshot'
const KEY_FORM_IDS = 'formIds'
const KEY_LIBRARY = 'library'

class BundleWire {
  lists: ShoppingList[] = []
  items: ShoppingItem[] = []
  memos: ShoppingMemoNote[] = []
  reminders: ShoppingReminder[] = []
}

class LibraryFile {
  items: FrequentItem[] = []
}

export class ShoppingLocalStore {
  private static pref: preferences.Preferences | null = null
  private static cache: LocalBundle = new LocalBundle()
  private static libCache: FrequentItem[] = []

  static async init(context: common.Context): Promise<void> {
    try {
      ShoppingLocalStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await ShoppingLocalStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      ShoppingLocalStore.cache = ShoppingLocalStore.parseBundle(raw)
      const onboardValue = await ShoppingLocalStore.pref.get(KEY_ONBOARD, false)
      AppStorage.setOrCreate(KEY_ONBOARD, onboardValue === true)
      const notifyValue = await ShoppingLocalStore.pref.get(KEY_NOTIFY, true)
      AppStorage.setOrCreate(KEY_NOTIFY, notifyValue !== false)
      const appearValue = await ShoppingLocalStore.pref.get(KEY_APPEARANCE, 'system')
      const appear: string = typeof appearValue === 'string' ? appearValue : 'system'
      AppStorage.setOrCreate(KEY_APPEARANCE, appear)
      const libRaw = await ShoppingLocalStore.pref.get(KEY_LIBRARY, '')
      const libText: string = typeof libRaw === 'string' ? libRaw : ''
      ShoppingLocalStore.libCache = ShoppingLocalStore.parseLibrary(libText)
      await ShoppingLocalStore.writeWidgetSnapshot()
    } catch {
      ShoppingLocalStore.cache = new LocalBundle()
      AppStorage.setOrCreate(KEY_ONBOARD, false)
      AppStorage.setOrCreate(KEY_NOTIFY, true)
      AppStorage.setOrCreate(KEY_APPEARANCE, 'system')
      ShoppingLocalStore.libCache = []
    }
  }

  static snapshot(): LocalBundle {
    return ShoppingLocalStore.cache
  }

  static lists(): ShoppingList[] {
    return ShoppingLocalStore.copyLists(ShoppingLocalStore.cache.lists)
  }

  static items(): ShoppingItem[] {
    return ShoppingLocalStore.copyItems(ShoppingLocalStore.cache.items)
  }

  static memos(): ShoppingMemoNote[] {
    return ShoppingLocalStore.copyMemos(ShoppingLocalStore.cache.memos)
  }

  static reminders(): ShoppingReminder[] {
    return ShoppingLocalStore.copyReminders(ShoppingLocalStore.cache.reminders)
  }

  static itemsOf(listId: string): ShoppingItem[] {
    const out: ShoppingItem[] = []
    for (const it of ShoppingLocalStore.cache.items) {
      if (it.listId === listId) {
        out.push(ShoppingLocalStore.cloneItem(it))
      }
    }
    return out
  }

  static async saveBundle(next: LocalBundle): Promise<void> {
    ShoppingLocalStore.cache = next
    await ShoppingLocalStore.putString(KEY_BUNDLE, ShoppingLocalStore.serializeBundle(next))
    await ShoppingLocalStore.writeWidgetSnapshot()
  }

  static serializeBundle(bundle: LocalBundle): string {
    const wire = new BundleWire()
    wire.lists = bundle.lists
    wire.items = bundle.items
    wire.memos = bundle.memos
    wire.reminders = bundle.reminders
    return JSON.stringify(wire)
  }

  static async replaceAll(lists: ShoppingList[], items: ShoppingItem[],
    memos: ShoppingMemoNote[], reminders: ShoppingReminder[]): Promise<void> {
    const next = new LocalBundle()
    next.lists = lists
    next.items = items
    next.memos = memos
    next.reminders = reminders
    await ShoppingLocalStore.saveBundle(next)
  }

  static async setOnboardingDone(): Promise<void> {
    AppStorage.setOrCreate(KEY_ONBOARD, true)
    await ShoppingLocalStore.putBool(KEY_ONBOARD, true)
  }

  static async setNotifyEnabled(enabled: boolean): Promise<void> {
    AppStorage.setOrCreate(KEY_NOTIFY, enabled)
    await ShoppingLocalStore.putBool(KEY_NOTIFY, enabled)
  }

  static async setAppearance(mode: string): Promise<void> {
    AppStorage.setOrCreate(KEY_APPEARANCE, mode)
    await ShoppingLocalStore.putString(KEY_APPEARANCE, mode)
  }

  static widgetPayload(): WidgetPayload {
    const data = new WidgetPayload()
    const today = ShoppingLocalStore.today()
    let list: ShoppingList | undefined = undefined
    for (const row of ShoppingLocalStore.cache.lists) {
      if (row.dueDate === today && row.status !== 'done') {
        list = row
        break
      }
    }
    if (list === undefined) {
      for (const row of ShoppingLocalStore.cache.lists) {
        if (row.status !== 'done') {
          list = row
          break
        }
      }
    }
    if (list === undefined) {
      data.title = '购物备忘'
      data.progress = '还没有购物清单'
      data.remain = '点此打开应用'
      data.preview = '从记下第一件物品开始'
      return data
    }
    let total = 0
    let done = 0
    const names: string[] = []
    for (const it of ShoppingLocalStore.cache.items) {
      if (it.listId !== list.id) {
        continue
      }
      total += 1
      if (it.completed) {
        done += 1
      } else if (names.length < 3) {
        names.push(it.title)
      }
    }
    data.title = list.title.length > 0 ? list.title : '今日购物'
    data.progress = `${done} / ${total} 已完成`
    data.remain = total > done ? `还剩 ${total - done} 项` : '清单已完成'
    data.preview = names.length > 0 ? names.join('、') : '打开应用继续勾选'
    return data
  }

  static async writeWidgetSnapshot(): Promise<void> {
    const data = ShoppingLocalStore.widgetPayload()
    const raw = `{"title":${JSON.stringify(data.title)},"progress":${JSON.stringify(data.progress)},"remain":${JSON.stringify(data.remain)},"preview":${JSON.stringify(data.preview)}}`
    await ShoppingLocalStore.putString(KEY_WIDGET, raw)
  }

  static async readWidgetSnapshot(context: common.Context): Promise<WidgetPayload> {
    const data = new WidgetPayload()
    try {
      const pref = await preferences.getPreferences(context, STORE)
      const rawValue = await pref.get(KEY_WIDGET, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      if (raw.length === 0) {
        return data
      }
      const parsed = JSON.parse(raw) as WidgetPayload
      data.title = parsed.title ?? data.title
      data.progress = parsed.progress ?? data.progress
      data.remain = parsed.remain ?? ''
      data.preview = parsed.preview ?? ''
    } catch {
    }
    return data
  }

  static async rememberFormId(formId: string): Promise<void> {
    if (formId.length === 0) {
      return
    }
    const ids = await ShoppingLocalStore.formIds()
    for (const id of ids) {
      if (id === formId) {
        return
      }
    }
    ids.push(formId)
    await ShoppingLocalStore.putString(KEY_FORM_IDS, ids.join(','))
  }

  static async forgetFormId(formId: string): Promise<void> {
    const ids = await ShoppingLocalStore.formIds()
    const next: string[] = []
    for (const id of ids) {
      if (id !== formId) {
        next.push(id)
      }
    }
    await ShoppingLocalStore.putString(KEY_FORM_IDS, next.join(','))
  }

  static async formIds(): Promise<string[]> {
    if (ShoppingLocalStore.pref === null) {
      return []
    }
    try {
      const rawValue = await ShoppingLocalStore.pref.get(KEY_FORM_IDS, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      if (raw.length === 0) {
        return []
      }
      return raw.split(',')
    } catch {
      return []
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ShoppingLocalStore.pref === null) {
      return
    }
    try {
      await ShoppingLocalStore.pref.put(key, value)
      await ShoppingLocalStore.pref.flush()
    } catch {
    }
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (ShoppingLocalStore.pref === null) {
      return
    }
    try {
      await ShoppingLocalStore.pref.put(key, value)
      await ShoppingLocalStore.pref.flush()
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
    return `${prefix}_${Date.now()}_${ShoppingLocalStore.cache.lists.length}_${ShoppingLocalStore.cache.items.length}_${ShoppingLocalStore.cache.memos.length}`
  }

  static cloneList(row: ShoppingList): ShoppingList {
    const out = new ShoppingList()
    out.id = row.id ?? ''
    out.title = row.title ?? ''
    out.summary = row.summary ?? ''
    out.body = row.body ?? ''
    out.status = row.status ?? 'active'
    out.dueDate = row.dueDate ?? ''
    out.coverKey = row.coverKey ?? 'home_hero'
    out.budgetYuan = row.budgetYuan ?? ''
    out.kind = row.kind !== undefined && row.kind.length > 0 ? row.kind : '日常采购'
    out.starred = row.starred === true
    out.members = row.members ?? ''
    out.userId = row.userId ?? ''
    out.createdAt = row.createdAt ?? ''
    out.updatedAt = row.updatedAt ?? ''
    return out
  }

  static cloneItem(row: ShoppingItem): ShoppingItem {
    const out = new ShoppingItem()
    out.id = row.id ?? ''
    out.listId = row.listId ?? ''
    out.title = row.title ?? ''
    out.category = row.category ?? '其他'
    out.qty = row.qty ?? ''
    out.remark = row.remark ?? ''
    out.estPrice = row.estPrice ?? ''
    out.paidPrice = row.paidPrice ?? ''
    out.tag = row.tag ?? ''
    out.assignee = row.assignee ?? ''
    out.lastBoughtAt = row.lastBoughtAt ?? ''
    out.completed = row.completed === true
    out.userId = row.userId ?? ''
    out.updatedAt = row.updatedAt ?? ''
    return out
  }

  static cloneMemo(row: ShoppingMemoNote): ShoppingMemoNote {
    const out = new ShoppingMemoNote()
    out.id = row.id ?? ''
    out.title = row.title ?? ''
    out.body = row.body ?? ''
    out.important = row.important === true
    out.remindAt = row.remindAt ?? ''
    out.userId = row.userId ?? ''
    out.updatedAt = row.updatedAt ?? ''
    return out
  }

  static cloneReminder(row: ShoppingReminder): ShoppingReminder {
    const out = new ShoppingReminder()
    out.id = row.id ?? ''
    out.listId = row.listId ?? ''
    out.title = row.title ?? ''
    out.remindAt = row.remindAt ?? ''
    out.cycle = row.cycle !== undefined && row.cycle.length > 0 ? row.cycle : 'once'
    out.status = row.status ?? 'scheduled'
    out.userId = row.userId ?? ''
    out.agentId = row.agentId ?? 0
    return out
  }

  static copyLists(rows: ShoppingList[]): ShoppingList[] {
    const out: ShoppingList[] = []
    for (const row of rows) {
      out.push(ShoppingLocalStore.cloneList(row))
    }
    return out
  }

  static copyItems(rows: ShoppingItem[]): ShoppingItem[] {
    const out: ShoppingItem[] = []
    for (const row of rows) {
      out.push(ShoppingLocalStore.cloneItem(row))
    }
    return out
  }

  static copyMemos(rows: ShoppingMemoNote[]): ShoppingMemoNote[] {
    const out: ShoppingMemoNote[] = []
    for (const row of rows) {
      out.push(ShoppingLocalStore.cloneMemo(row))
    }
    return out
  }

  static copyReminders(rows: ShoppingReminder[]): ShoppingReminder[] {
    const out: ShoppingReminder[] = []
    for (const row of rows) {
      out.push(ShoppingLocalStore.cloneReminder(row))
    }
    return out
  }

  static library(): FrequentItem[] {
    const out: FrequentItem[] = []
    for (const row of ShoppingLocalStore.libCache) {
      out.push(ShoppingLocalStore.cloneFreq(row))
    }
    return out
  }

  static async saveLibrary(rows: FrequentItem[]): Promise<void> {
    const next: FrequentItem[] = []
    for (const row of rows) {
      next.push(ShoppingLocalStore.cloneFreq(row))
    }
    ShoppingLocalStore.libCache = next
    const file = new LibraryFile()
    file.items = next
    await ShoppingLocalStore.putString(KEY_LIBRARY, JSON.stringify(file))
  }

  static cloneFreq(row: FrequentItem): FrequentItem {
    const out = new FrequentItem()
    out.title = row.title ?? ''
    out.category = row.category ?? ''
    out.qty = row.qty ?? ''
    out.remark = row.remark ?? ''
    out.estPrice = row.estPrice ?? ''
    out.count = row.count ?? 0
    return out
  }

  private static parseLibrary(raw: string): FrequentItem[] {
    if (raw.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(raw) as LibraryFile
      const out: FrequentItem[] = []
      if (parsed.items === undefined) {
        return out
      }
      for (const row of parsed.items) {
        out.push(ShoppingLocalStore.cloneFreq(row))
      }
      return out
    } catch {
      return []
    }
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
        out.lists = ShoppingLocalStore.copyLists(parsed.lists)
      }
      if (parsed.items !== undefined) {
        out.items = ShoppingLocalStore.copyItems(parsed.items)
      }
      if (parsed.memos !== undefined) {
        out.memos = ShoppingLocalStore.copyMemos(parsed.memos)
      }
      if (parsed.reminders !== undefined) {
        out.reminders = ShoppingLocalStore.copyReminders(parsed.reminders)
      }
      return out
    } catch {
      return empty
    }
  }
}
