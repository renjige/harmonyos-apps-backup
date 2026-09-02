import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import { CategorySuggest } from './CategorySuggest'
import { FamilyLocalStore } from './FamilyLocalStore'
import { FamilyNotifyService } from './FamilyNotifyService'
import { FamilyMedia } from './FamilyMedia'
import {
  CreateItemBody,
  CreateListBody,
  CreateMemoBody,
  CreateReminderBody,
  ListData,
  LocalBundle,
  PatchItemBody,
  PatchListBody,
  ShoppingCategory,
  FamilyTask,
  FamilyList,
  FamilyNote,
  FamilyReminder,
  FamilyTemplate,
  TemplateItemSeed,
  UpdateMemoBody
} from '../models/FamilyModels'

const BASE = '/biz/family-memo'

export class FamilyService {
  private static values<T>(data: ListData<T> | undefined): T[] {
    if (data === undefined) {
      return []
    }
    if (data.list !== undefined && data.list.length > 0) {
      return data.list
    }
    if (data.items !== undefined) {
      return data.items
    }
    return []
  }

  static actorId(): string {
    const name = AppStorage.get<string>('currentUsername') ?? ''
    if (name.length > 0) {
      return name
    }
    return 'local'
  }

  private static userQuery(): string {
    return `userId=${encodeURIComponent(FamilyService.actorId())}`
  }

  static async templates(): Promise<FamilyTemplate[]> {
    const res = await HttpClient.get<ListData<FamilyTemplate>>(`${BASE}/templates`)
    return res.code === 0 ? FamilyService.values(res.data) : []
  }

  static async categories(): Promise<ShoppingCategory[]> {
    const res = await HttpClient.get<ListData<ShoppingCategory>>(`${BASE}/categories`)
    if (res.code === 0 && FamilyService.values(res.data).length > 0) {
      return FamilyService.values(res.data)
    }
    const fallback: ShoppingCategory[] = []
    const titles = CategorySuggest.categories()
    for (let i = 0; i < titles.length; i++) {
      const c = new ShoppingCategory()
      c.id = `local_cat_${i}`
      c.title = titles[i]
      fallback.push(c)
    }
    return fallback
  }

  static async lists(): Promise<FamilyList[]> {
    return FamilyLocalStore.lists()
  }

  static async items(listId: string): Promise<FamilyTask[]> {
    if (listId.length === 0) {
      return FamilyLocalStore.items()
    }
    return FamilyLocalStore.itemsOf(listId)
  }

  static async memos(): Promise<FamilyNote[]> {
    return FamilyService.sortMemos(FamilyLocalStore.memos())
  }

  static async reminders(): Promise<FamilyReminder[]> {
    return FamilyLocalStore.reminders()
  }

  static cloneMemoForEdit(source: FamilyNote): FamilyNote {
    return FamilyLocalStore.cloneMemo(source)
  }

  private static sortMemos(rows: FamilyNote[]): FamilyNote[] {
    const out: FamilyNote[] = FamilyLocalStore.copyMemos(rows)
    for (let i = 0; i < out.length; i++) {
      for (let j = i + 1; j < out.length; j++) {
        const a = out[i]
        const b = out[j]
        let swap = false
        if (a.important !== b.important) {
          swap = !a.important && b.important
        } else {
          const ta = a.updatedAt.length > 0 ? a.updatedAt : a.remindAt
          const tb = b.updatedAt.length > 0 ? b.updatedAt : b.remindAt
          swap = ta < tb
        }
        if (swap) {
          out[i] = b
          out[j] = a
        }
      }
    }
    return out
  }

  static async findList(id: string): Promise<FamilyList | undefined> {
    const all = FamilyLocalStore.lists()
    for (const row of all) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  static async findTemplate(id: string): Promise<FamilyTemplate | undefined> {
    const all = await FamilyService.templates()
    for (const row of all) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  static async todayList(): Promise<FamilyList | undefined> {
    const today = FamilyLocalStore.today()
    const all = FamilyLocalStore.lists()
    for (const row of all) {
      if (row.dueDate === today && row.status !== 'done') {
        return row
      }
    }
    for (const row of all) {
      if (row.status !== 'done') {
        return row
      }
    }
    for (const row of all) {
      if (row.dueDate === today) {
        return row
      }
    }
    return undefined
  }

  static async ensureTodayList(): Promise<FamilyList> {
    const existing = await FamilyService.todayList()
    if (existing !== undefined) {
      return existing
    }
    return FamilyService.createList('今日家庭', FamilyLocalStore.today(), FamilyMedia.nextCoverKey(FamilyLocalStore.lists().length), '')
  }

  static async createList(title: string, dueDate: string, coverKey: string, templateId: string): Promise<FamilyList> {
    const row = new FamilyList()
    row.id = FamilyLocalStore.newId('list')
    row.title = title
    row.dueDate = dueDate
    row.coverKey = coverKey.length > 0 ? coverKey : FamilyMedia.nextCoverKey(FamilyLocalStore.lists().length)
    row.status = 'active'
    row.userId = FamilyService.actorId()
    row.createdAt = FamilyLocalStore.nowIso()
    row.updatedAt = row.createdAt
    const bundle = FamilyLocalStore.snapshot()
    const next = new LocalBundle()
    next.lists = [row].concat(FamilyLocalStore.copyLists(bundle.lists))
    next.items = FamilyLocalStore.copyItems(bundle.items)
    next.memos = FamilyLocalStore.copyMemos(bundle.memos)
    next.reminders = FamilyLocalStore.copyReminders(bundle.reminders)
    await FamilyLocalStore.saveBundle(next)
    if (templateId.length > 0) {
      await FamilyService.applyTemplateItems(row.id, templateId)
    }
    void FamilyService.pushList(row)
    return FamilyLocalStore.cloneList(row)
  }

  static async setListStatus(listId: string, status: string): Promise<void> {
    const bundle = FamilyLocalStore.snapshot()
    const lists: FamilyList[] = []
    for (const row of bundle.lists) {
      const copy = FamilyLocalStore.cloneList(row)
      if (copy.id === listId) {
        copy.status = status
        copy.updatedAt = FamilyLocalStore.nowIso()
      }
      lists.push(copy)
    }
    await FamilyLocalStore.replaceAll(lists, FamilyLocalStore.copyItems(bundle.items),
      FamilyLocalStore.copyMemos(bundle.memos), FamilyLocalStore.copyReminders(bundle.reminders))
    if (AuthService.isLoggedIn()) {
      const patch = new PatchListBody()
      patch.status = status
      patch.userId = FamilyService.actorId()
      void HttpClient.patch<FamilyList>(`${BASE}/lists/${listId}`, patch)
    }
  }

  static async applyTemplateItems(listId: string, templateId: string): Promise<void> {
    const tpl = await FamilyService.findTemplate(templateId)
    if (tpl === undefined || tpl.itemsJson.length === 0) {
      return
    }
    try {
      const seeds = JSON.parse(tpl.itemsJson) as TemplateItemSeed[]
      for (const seed of seeds) {
        if (seed.title === undefined || seed.title.length === 0) {
          continue
        }
        const cat = seed.category !== undefined && seed.category.length > 0 ? seed.category : CategorySuggest.suggest(seed.title)
        const qty = seed.qty !== undefined ? seed.qty : ''
        await FamilyService.addItem(listId, seed.title, cat, qty, '')
      }
    } catch {
      return
    }
  }

  static async addItem(listId: string, title: string, category: string, qty: string, remark: string): Promise<FamilyTask> {
    const row = new FamilyTask()
    row.id = FamilyLocalStore.newId('item')
    row.listId = listId
    row.title = title
    row.category = category.length > 0 ? category : CategorySuggest.suggest(title)
    row.qty = qty
    row.remark = remark
    row.completed = false
    row.userId = FamilyService.actorId()
    row.updatedAt = FamilyLocalStore.nowIso()
    const bundle = FamilyLocalStore.snapshot()
    const next = new LocalBundle()
    next.lists = FamilyLocalStore.copyLists(bundle.lists)
    next.items = [row].concat(FamilyLocalStore.copyItems(bundle.items))
    next.memos = FamilyLocalStore.copyMemos(bundle.memos)
    next.reminders = FamilyLocalStore.copyReminders(bundle.reminders)
    await FamilyLocalStore.saveBundle(next)
    await FamilyService.refreshListStatus(listId)
    void FamilyService.pushItem(row)
    return FamilyLocalStore.cloneItem(row)
  }

  static async toggleItem(item: FamilyTask): Promise<boolean> {
    const bundle = FamilyLocalStore.snapshot()
    const nextItems: FamilyTask[] = []
    let changed: FamilyTask | undefined = undefined
    for (const it of bundle.items) {
      const copy = FamilyLocalStore.cloneItem(it)
      if (copy.id === item.id) {
        copy.completed = !copy.completed
        copy.updatedAt = FamilyLocalStore.nowIso()
        changed = copy
      }
      nextItems.push(copy)
    }
    if (changed === undefined) {
      return false
    }
    await FamilyLocalStore.replaceAll(FamilyLocalStore.copyLists(bundle.lists), nextItems,
      FamilyLocalStore.copyMemos(bundle.memos), FamilyLocalStore.copyReminders(bundle.reminders))
    await FamilyService.refreshListStatus(changed.listId)
    void FamilyService.patchItemRemote(changed)
    return true
  }

  static async refreshListStatus(listId: string): Promise<void> {
    const items = FamilyLocalStore.itemsOf(listId)
    if (items.length === 0) {
      await FamilyService.setListStatus(listId, 'active')
      return
    }
    let done = 0
    for (const it of items) {
      if (it.completed) {
        done += 1
      }
    }
    await FamilyService.setListStatus(listId, done === items.length ? 'done' : 'active')
  }

  static async deleteList(id: string): Promise<boolean> {
    const bundle = FamilyLocalStore.snapshot()
    const lists: FamilyList[] = []
    for (const row of bundle.lists) {
      if (row.id !== id) {
        lists.push(FamilyLocalStore.cloneList(row))
      }
    }
    const items: FamilyTask[] = []
    for (const it of bundle.items) {
      if (it.listId !== id) {
        items.push(FamilyLocalStore.cloneItem(it))
      }
    }
    await FamilyLocalStore.replaceAll(lists, items, FamilyLocalStore.copyMemos(bundle.memos),
      FamilyLocalStore.copyReminders(bundle.reminders))
    if (AuthService.isLoggedIn()) {
      void HttpClient.delete<FamilyList>(`${BASE}/lists/${id}?${FamilyService.userQuery()}`)
    }
    return true
  }

  static async saveMemo(note: FamilyNote, isNew: boolean): Promise<boolean> {
    if (note.title.trim().length === 0) {
      return false
    }
    const saved = FamilyLocalStore.cloneMemo(note)
    saved.title = note.title.trim()
    saved.body = note.body.trim()
    saved.userId = FamilyService.actorId()
    saved.updatedAt = FamilyLocalStore.nowIso()
    if (isNew || saved.id.length === 0) {
      saved.id = FamilyLocalStore.newId('memo')
    }
    const bundle = FamilyLocalStore.snapshot()
    const memos: FamilyNote[] = []
    let found = false
    for (const row of bundle.memos) {
      if (row.id === saved.id) {
        memos.push(saved)
        found = true
      } else {
        memos.push(FamilyLocalStore.cloneMemo(row))
      }
    }
    if (!found) {
      memos.unshift(saved)
    }
    await FamilyLocalStore.replaceAll(FamilyLocalStore.copyLists(bundle.lists),
      FamilyLocalStore.copyItems(bundle.items), memos, FamilyLocalStore.copyReminders(bundle.reminders))
    void FamilyService.pushMemo(saved, !found || isNew)
    return true
  }

  static async deleteMemo(id: string): Promise<boolean> {
    if (id.length === 0) {
      return false
    }
    const bundle = FamilyLocalStore.snapshot()
    const memos: FamilyNote[] = []
    let removed = false
    for (const m of bundle.memos) {
      if (m.id === id) {
        removed = true
      } else {
        memos.push(FamilyLocalStore.cloneMemo(m))
      }
    }
    if (!removed) {
      return false
    }
    await FamilyLocalStore.replaceAll(FamilyLocalStore.copyLists(bundle.lists),
      FamilyLocalStore.copyItems(bundle.items), memos, FamilyLocalStore.copyReminders(bundle.reminders))
    if (AuthService.isLoggedIn()) {
      void HttpClient.delete<FamilyNote>(`${BASE}/notes/${id}?${FamilyService.userQuery()}`)
    }
    return true
  }

  static async createReminder(title: string, listId: string, remindAt: string, cycle: string): Promise<boolean> {
    const row = new FamilyReminder()
    row.id = FamilyLocalStore.newId('rmd')
    row.title = title
    row.listId = listId
    row.remindAt = remindAt
    row.status = 'scheduled'
    row.userId = FamilyService.actorId()
    row.cycle = cycle.length > 0 ? cycle : 'once'
    const ok = await FamilyNotifyService.schedule(row)
    row.agentId = FamilyNotifyService.lastAgentId
    const bundle = FamilyLocalStore.snapshot()
    const next = new LocalBundle()
    next.lists = FamilyLocalStore.copyLists(bundle.lists)
    next.items = FamilyLocalStore.copyItems(bundle.items)
    next.memos = FamilyLocalStore.copyMemos(bundle.memos)
    next.reminders = [row].concat(FamilyLocalStore.copyReminders(bundle.reminders))
    await FamilyLocalStore.saveBundle(next)
    void FamilyService.pushReminder(row)
    return ok
  }

  static lastNotifyError(): string {
    return FamilyNotifyService.lastError
  }

  static async deleteReminder(id: string): Promise<boolean> {
    const bundle = FamilyLocalStore.snapshot()
    const reminders: FamilyReminder[] = []
    for (const r of bundle.reminders) {
      if (r.id === id) {
        await FamilyNotifyService.cancel(r.agentId)
      } else {
        reminders.push(FamilyLocalStore.cloneReminder(r))
      }
    }
    await FamilyLocalStore.replaceAll(FamilyLocalStore.copyLists(bundle.lists),
      FamilyLocalStore.copyItems(bundle.items), FamilyLocalStore.copyMemos(bundle.memos), reminders)
    if (AuthService.isLoggedIn()) {
      void HttpClient.delete<FamilyReminder>(`${BASE}/reminders/${id}?${FamilyService.userQuery()}`)
    }
    return true
  }

  private static async pushList(row: FamilyList): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const body = new CreateListBody()
    body.title = row.title
    body.dueDate = row.dueDate
    body.coverKey = row.coverKey
    body.userId = FamilyService.actorId()
    void HttpClient.post<FamilyList>(`${BASE}/lists`, body)
  }

  private static async pushItem(row: FamilyTask): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const body = new CreateItemBody()
    body.title = row.title
    body.listId = row.listId
    body.category = row.category
    body.qty = row.qty
    body.remark = row.remark
    body.userId = FamilyService.actorId()
    void HttpClient.post<FamilyTask>(`${BASE}/tasks`, body)
  }

  private static async patchItemRemote(row: FamilyTask): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const patch = new PatchItemBody()
    patch.completed = row.completed
    patch.userId = FamilyService.actorId()
    void HttpClient.patch<FamilyTask>(`${BASE}/tasks/${row.id}`, patch)
  }

  private static async pushMemo(note: FamilyNote, isNew: boolean): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    if (isNew) {
      const body = new CreateMemoBody()
      body.title = note.title
      body.body = note.body
      body.important = note.important
      body.remindAt = note.remindAt
      body.userId = FamilyService.actorId()
      void HttpClient.post<FamilyNote>(`${BASE}/notes`, body)
      return
    }
    const update = new UpdateMemoBody()
    update.title = note.title
    update.body = note.body
    update.important = note.important
    update.remindAt = note.remindAt
    update.userId = FamilyService.actorId()
    void HttpClient.put<FamilyNote>(`${BASE}/notes/${note.id}`, update)
  }

  private static async pushReminder(row: FamilyReminder): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const body = new CreateReminderBody()
    body.title = row.title
    body.listId = row.listId
    body.remindAt = row.remindAt
    body.userId = FamilyService.actorId()
    void HttpClient.post<FamilyReminder>(`${BASE}/reminders`, body)
  }

  static shareText(list: FamilyList, items: FamilyTask[]): string {
    let done = 0
    for (const it of items) {
      if (it.completed) {
        done += 1
      }
    }
    let text = `${list.title}（${done}/${items.length}）\n`
    for (const it of items) {
      const mark = it.completed ? '✓' : '○'
      const extra = it.qty.length > 0 ? `  ${it.qty}` : ''
      text = `${text}${mark} ${it.title}${extra}\n`
    }
    return text
  }

  static doneCount(items: FamilyTask[]): number {
    let done = 0
    for (const it of items) {
      if (it.completed) {
        done += 1
      }
    }
    return done
  }

  static reminderCopy(remain: number): string {
    if (remain <= 0) {
      return '看看今天的家庭事项是否都完成了'
    }
    if (remain === 1) {
      return '别忘了完成今天剩下的 1 件家庭事项'
    }
    return `今天还有 ${remain} 件家庭事项待完成`
  }
}
