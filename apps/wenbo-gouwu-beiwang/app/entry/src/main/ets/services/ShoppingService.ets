import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import { CategorySuggest } from './CategorySuggest'
import { ShoppingCatalog } from './ShoppingCatalog'
import { ShoppingLocalStore } from './ShoppingLocalStore'
import { ShoppingNotifyService } from './ShoppingNotifyService'
import { ShoppingWidgetSync } from './ShoppingWidgetSync'
import { GrowthService } from './GrowthService'
import {
  CreateItemBody,
  CreateListBody,
  CreateMemoBody,
  CreateReminderBody,
  FrequentItem,
  ListData,
  LocalBundle,
  PatchListBody,
  PatchItemBody,
  RemainingRow,
  RestockRow,
  AisleGroup,
  SpendSnapshot,
  ShoppingCategory,
  ShoppingItem,
  ShoppingList,
  ShoppingMemoNote,
  ShoppingReminder,
  ShoppingTemplate,
  TemplateItemSeed,
  UpdateMemoBody,
  WeekStats
} from '../models/ShoppingModels'

const BASE = '/biz/shopping-memo'

export class ShoppingService {
  private static values<T>(data: ListData<T> | undefined): T[] {
    if (data === undefined) {
      return []
    }
    if (data.list !== undefined) {
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
    return `userId=${encodeURIComponent(ShoppingService.actorId())}`
  }

  static async templates(): Promise<ShoppingTemplate[]> {
    const res = await HttpClient.get<ListData<ShoppingTemplate>>(`${BASE}/templates`)
    const remote = res.code === 0 ? ShoppingService.values(res.data) : []
    return ShoppingCatalog.mergeTemplates(remote)
  }

  static async categories(): Promise<ShoppingCategory[]> {
    const res = await HttpClient.get<ListData<ShoppingCategory>>(`${BASE}/categories`)
    if (res.code === 0 && ShoppingService.values(res.data).length > 0) {
      return ShoppingService.values(res.data)
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

  static async lists(): Promise<ShoppingList[]> {
    return ShoppingLocalStore.lists()
  }

  static async items(listId: string): Promise<ShoppingItem[]> {
    if (listId.length === 0) {
      return ShoppingLocalStore.items()
    }
    return ShoppingLocalStore.itemsOf(listId)
  }

  static async memos(): Promise<ShoppingMemoNote[]> {
    return ShoppingService.sortMemos(ShoppingLocalStore.memos())
  }

  static async findMemo(id: string): Promise<ShoppingMemoNote | undefined> {
    for (const row of ShoppingLocalStore.memos()) {
      if (row.id === id) {
        return ShoppingLocalStore.cloneMemo(row)
      }
    }
    return undefined
  }

  static async reminders(): Promise<ShoppingReminder[]> {
    return ShoppingLocalStore.reminders()
  }

  static cloneMemoForEdit(source: ShoppingMemoNote): ShoppingMemoNote {
    return ShoppingLocalStore.cloneMemo(source)
  }

  static async findList(id: string): Promise<ShoppingList | undefined> {
    const all = ShoppingLocalStore.lists()
    for (const row of all) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  static async findTemplate(id: string): Promise<ShoppingTemplate | undefined> {
    const all = await ShoppingService.templates()
    for (const row of all) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  static async todayList(): Promise<ShoppingList | undefined> {
    const today = ShoppingLocalStore.today()
    const all = ShoppingLocalStore.lists()
    for (const row of all) {
      if (row.dueDate === today && row.status !== 'done') {
        return row
      }
    }
    for (const row of all) {
      if (row.dueDate === today) {
        return row
      }
    }
    for (const row of all) {
      if (row.status !== 'done') {
        return row
      }
    }
    if (all.length > 0) {
      return all[0]
    }
    return undefined
  }

  static async ensureTodayList(): Promise<ShoppingList> {
    const existing = await ShoppingService.todayList()
    if (existing !== undefined) {
      return existing
    }
    return ShoppingService.createList('今日购物', ShoppingLocalStore.today(), 'home_hero', '', '日常采购')
  }

  static async createList(title: string, dueDate: string, coverKey: string, templateId: string,
    kind: string = '日常采购'): Promise<ShoppingList> {
    const row = new ShoppingList()
    row.id = ShoppingLocalStore.newId('list')
    row.title = title
    row.dueDate = dueDate
    row.kind = kind.length > 0 ? kind : '日常采购'
    row.coverKey = coverKey.length > 0 && coverKey !== 'home_hero' ? coverKey : ShoppingCatalog.coverOfKind(row.kind)
    row.status = 'active'
    row.userId = ShoppingService.actorId()
    row.createdAt = ShoppingLocalStore.nowIso()
    row.updatedAt = row.createdAt
    const bundle = ShoppingLocalStore.snapshot()
    const next = new LocalBundle()
    next.lists = [row].concat(ShoppingLocalStore.copyLists(bundle.lists))
    next.items = ShoppingLocalStore.copyItems(bundle.items)
    next.memos = ShoppingLocalStore.copyMemos(bundle.memos)
    next.reminders = ShoppingLocalStore.copyReminders(bundle.reminders)
    await ShoppingLocalStore.saveBundle(next)
    if (templateId.length > 0) {
      await ShoppingService.applyTemplateItems(row.id, templateId)
    }
    void ShoppingService.pushList(row)
    void ShoppingWidgetSync.push()
    void GrowthService.onListCreated(title, row.id)
    return ShoppingLocalStore.cloneList(row)
  }

  static async duplicateList(listId: string): Promise<ShoppingList | undefined> {
    const source = await ShoppingService.findList(listId)
    if (source === undefined) {
      return undefined
    }
    const created = await ShoppingService.createList(`${source.title}（再买一次）`,
      ShoppingLocalStore.today(), source.coverKey, '', source.kind)
    const items = ShoppingLocalStore.itemsOf(listId)
    for (const it of items) {
      await ShoppingService.addItem(created.id, it.title, it.category, it.qty, it.remark, it.estPrice, it.tag)
    }
    return created
  }

  static async setListStatus(listId: string, status: string): Promise<void> {
    const bundle = ShoppingLocalStore.snapshot()
    const lists: ShoppingList[] = []
    for (const row of bundle.lists) {
      const copy = ShoppingLocalStore.cloneList(row)
      if (copy.id === listId) {
        copy.status = status
        copy.updatedAt = ShoppingLocalStore.nowIso()
      }
      lists.push(copy)
    }
    await ShoppingLocalStore.replaceAll(lists, ShoppingLocalStore.copyItems(bundle.items),
      ShoppingLocalStore.copyMemos(bundle.memos), ShoppingLocalStore.copyReminders(bundle.reminders))
    if (AuthService.isLoggedIn()) {
      const patch = new PatchListBody()
      patch.status = status
      patch.userId = ShoppingService.actorId()
      void HttpClient.patch<ShoppingList>(`${BASE}/lists/${listId}`, patch)
    }
    void ShoppingWidgetSync.push()
  }

  static async setListBudget(listId: string, budgetYuan: string): Promise<void> {
    const bundle = ShoppingLocalStore.snapshot()
    const lists: ShoppingList[] = []
    for (const row of bundle.lists) {
      const copy = ShoppingLocalStore.cloneList(row)
      if (copy.id === listId) {
        copy.budgetYuan = budgetYuan
        copy.updatedAt = ShoppingLocalStore.nowIso()
      }
      lists.push(copy)
    }
    await ShoppingLocalStore.replaceAll(lists, ShoppingLocalStore.copyItems(bundle.items),
      ShoppingLocalStore.copyMemos(bundle.memos), ShoppingLocalStore.copyReminders(bundle.reminders))
  }

  static async reopenList(listId: string): Promise<void> {
    const bundle = ShoppingLocalStore.snapshot()
    const lists: ShoppingList[] = []
    const items: ShoppingItem[] = []
    for (const row of bundle.lists) {
      const copy = ShoppingLocalStore.cloneList(row)
      if (copy.id === listId) {
        copy.status = 'active'
        copy.updatedAt = ShoppingLocalStore.nowIso()
      }
      lists.push(copy)
    }
    for (const it of bundle.items) {
      const copy = ShoppingLocalStore.cloneItem(it)
      if (copy.listId === listId && copy.completed) {
        copy.completed = false
        copy.updatedAt = ShoppingLocalStore.nowIso()
        void ShoppingService.patchItemRemote(copy)
      }
      items.push(copy)
    }
    await ShoppingLocalStore.replaceAll(lists, items, ShoppingLocalStore.copyMemos(bundle.memos),
      ShoppingLocalStore.copyReminders(bundle.reminders))
    if (AuthService.isLoggedIn()) {
      const patch = new PatchListBody()
      patch.status = 'active'
      patch.userId = ShoppingService.actorId()
      void HttpClient.patch<ShoppingList>(`${BASE}/lists/${listId}`, patch)
    }
    void ShoppingWidgetSync.push()
  }

  static async rescheduleReminders(): Promise<void> {
    if (!ShoppingNotifyService.notifyEnabled()) {
      return
    }
    const bundle = ShoppingLocalStore.snapshot()
    const reminders: ShoppingReminder[] = []
    for (const row of bundle.reminders) {
      const copy = ShoppingLocalStore.cloneReminder(row)
      const fire = ShoppingNotifyService.parseRemindAt(copy.remindAt)
      if (fire === undefined || fire.getTime() <= Date.now()) {
        reminders.push(copy)
        continue
      }
      const agentId = await ShoppingNotifyService.schedule(copy)
      copy.agentId = agentId
      reminders.push(copy)
    }
    await ShoppingLocalStore.replaceAll(ShoppingLocalStore.copyLists(bundle.lists),
      ShoppingLocalStore.copyItems(bundle.items), ShoppingLocalStore.copyMemos(bundle.memos), reminders)
  }

  static async applyTemplateItems(listId: string, templateId: string): Promise<void> {
    const tpl = await ShoppingService.findTemplate(templateId)
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
        await ShoppingService.addItem(listId, seed.title, cat, qty, '')
      }
    } catch {
      return
    }
  }

  static async addItem(listId: string, title: string, category: string, qty: string, remark: string,
    estPrice: string = '', tag: string = ''): Promise<ShoppingItem> {
    const row = new ShoppingItem()
    row.id = ShoppingLocalStore.newId('item')
    row.listId = listId
    row.title = title
    row.category = category.length > 0 ? category : CategorySuggest.suggest(title)
    row.qty = qty
    row.remark = remark
    row.estPrice = estPrice
    row.tag = tag
    row.completed = false
    row.userId = ShoppingService.actorId()
    row.updatedAt = ShoppingLocalStore.nowIso()
    const bundle = ShoppingLocalStore.snapshot()
    const next = new LocalBundle()
    next.lists = ShoppingLocalStore.copyLists(bundle.lists)
    next.items = [row].concat(ShoppingLocalStore.copyItems(bundle.items))
    next.memos = ShoppingLocalStore.copyMemos(bundle.memos)
    next.reminders = ShoppingLocalStore.copyReminders(bundle.reminders)
    await ShoppingLocalStore.saveBundle(next)
    await ShoppingService.refreshListStatus(listId)
    await ShoppingService.touchLibrary(row)
    void ShoppingService.pushItem(row)
    void ShoppingWidgetSync.push()
    return ShoppingLocalStore.cloneItem(row)
  }

  static async toggleItem(item: ShoppingItem): Promise<boolean> {
    const bundle = ShoppingLocalStore.snapshot()
    const nextItems: ShoppingItem[] = []
    let changed: ShoppingItem | undefined = undefined
    for (const it of bundle.items) {
      const copy = ShoppingLocalStore.cloneItem(it)
      if (copy.id === item.id) {
        copy.completed = !copy.completed
        copy.updatedAt = ShoppingLocalStore.nowIso()
        if (copy.completed) {
          copy.lastBoughtAt = ShoppingLocalStore.today()
          if (copy.paidPrice.length === 0 && copy.estPrice.length > 0) {
            copy.paidPrice = copy.estPrice
          }
        }
        changed = copy
      }
      nextItems.push(copy)
    }
    if (changed === undefined) {
      return false
    }
    await ShoppingLocalStore.replaceAll(ShoppingLocalStore.copyLists(bundle.lists), nextItems,
      ShoppingLocalStore.copyMemos(bundle.memos), ShoppingLocalStore.copyReminders(bundle.reminders))
    await ShoppingService.refreshListStatus(changed.listId)
    void ShoppingService.patchItemRemote(changed)
    void ShoppingWidgetSync.push()
    void GrowthService.onItemToggled(changed, changed.completed)
    return true
  }

  static async updateItem(itemId: string, title: string, category: string, qty: string, remark: string,
    estPrice: string, paidPrice: string, tag: string, assignee: string): Promise<boolean> {
    const bundle = ShoppingLocalStore.snapshot()
    const nextItems: ShoppingItem[] = []
    let changed: ShoppingItem | undefined = undefined
    for (const it of bundle.items) {
      const copy = ShoppingLocalStore.cloneItem(it)
      if (copy.id === itemId) {
        copy.title = title
        copy.category = category.length > 0 ? category : CategorySuggest.suggest(title)
        copy.qty = qty
        copy.remark = remark
        copy.estPrice = estPrice
        copy.paidPrice = paidPrice
        copy.tag = tag
        copy.assignee = assignee
        copy.updatedAt = ShoppingLocalStore.nowIso()
        changed = copy
      }
      nextItems.push(copy)
    }
    if (changed === undefined) {
      return false
    }
    await ShoppingLocalStore.replaceAll(ShoppingLocalStore.copyLists(bundle.lists), nextItems,
      ShoppingLocalStore.copyMemos(bundle.memos), ShoppingLocalStore.copyReminders(bundle.reminders))
    void ShoppingService.patchItemRemote(changed)
    void ShoppingWidgetSync.push()
    return true
  }

  static async refreshListStatus(listId: string): Promise<void> {
    const items = ShoppingLocalStore.itemsOf(listId)
    if (items.length === 0) {
      await ShoppingService.setListStatus(listId, 'active')
      return
    }
    let done = 0
    for (const it of items) {
      if (it.completed) {
        done += 1
      }
    }
    await ShoppingService.setListStatus(listId, done === items.length ? 'done' : 'active')
  }

  static async deleteList(id: string): Promise<boolean> {
    const bundle = ShoppingLocalStore.snapshot()
    const lists: ShoppingList[] = []
    for (const row of bundle.lists) {
      if (row.id !== id) {
        lists.push(ShoppingLocalStore.cloneList(row))
      }
    }
    const items: ShoppingItem[] = []
    for (const it of bundle.items) {
      if (it.listId !== id) {
        items.push(ShoppingLocalStore.cloneItem(it))
      }
    }
    await ShoppingLocalStore.replaceAll(lists, items, ShoppingLocalStore.copyMemos(bundle.memos),
      ShoppingLocalStore.copyReminders(bundle.reminders))
    if (AuthService.isLoggedIn()) {
      void HttpClient.delete<ShoppingList>(`${BASE}/lists/${id}?${ShoppingService.userQuery()}`)
    }
    void ShoppingWidgetSync.push()
    return true
  }

  static async saveMemo(note: ShoppingMemoNote, isNew: boolean): Promise<boolean> {
    if (note.title.trim().length === 0) {
      return false
    }
    const saved = ShoppingLocalStore.cloneMemo(note)
    saved.title = note.title.trim()
    saved.body = note.body.trim()
    saved.userId = ShoppingService.actorId()
    saved.updatedAt = ShoppingLocalStore.nowIso()
    if (isNew || saved.id.length === 0) {
      saved.id = ShoppingLocalStore.newId('memo')
    }
    const bundle = ShoppingLocalStore.snapshot()
    const memos: ShoppingMemoNote[] = []
    let found = false
    for (const row of bundle.memos) {
      if (row.id === saved.id) {
        memos.push(saved)
        found = true
      } else {
        memos.push(ShoppingLocalStore.cloneMemo(row))
      }
    }
    if (!found) {
      memos.unshift(saved)
    }
    await ShoppingLocalStore.replaceAll(ShoppingLocalStore.copyLists(bundle.lists),
      ShoppingLocalStore.copyItems(bundle.items), memos, ShoppingLocalStore.copyReminders(bundle.reminders))
    void ShoppingService.pushMemo(saved, !found || isNew)
    return true
  }

  static async deleteMemo(id: string): Promise<boolean> {
    if (id.length === 0) {
      return false
    }
    const bundle = ShoppingLocalStore.snapshot()
    const memos: ShoppingMemoNote[] = []
    let removed = false
    for (const m of bundle.memos) {
      if (m.id === id) {
        removed = true
      } else {
        memos.push(ShoppingLocalStore.cloneMemo(m))
      }
    }
    if (!removed) {
      return false
    }
    await ShoppingLocalStore.replaceAll(ShoppingLocalStore.copyLists(bundle.lists),
      ShoppingLocalStore.copyItems(bundle.items), memos, ShoppingLocalStore.copyReminders(bundle.reminders))
    if (AuthService.isLoggedIn()) {
      void HttpClient.delete<ShoppingMemoNote>(`${BASE}/memos/${id}?${ShoppingService.userQuery()}`)
    }
    return true
  }

  static async createReminder(title: string, listId: string, remindAt: string,
    cycle: string = 'once'): Promise<boolean> {
    const row = new ShoppingReminder()
    row.id = ShoppingLocalStore.newId('rmd')
    row.title = title
    row.listId = listId
    row.remindAt = remindAt
    row.cycle = cycle.length > 0 ? cycle : 'once'
    row.status = 'scheduled'
    row.userId = ShoppingService.actorId()
    const agentId = await ShoppingNotifyService.schedule(row)
    if (agentId <= 0) {
      const err = ShoppingNotifyService.lastError
      if (err === '已关闭提醒，可在「我的 → 通知设置」开启' ||
        err === '请在系统设置中开启通知' ||
        err === '通知服务未就绪' ||
        err === '提醒时间无效') {
        return false
      }
    }
    row.agentId = agentId
    const bundle = ShoppingLocalStore.snapshot()
    const next = new LocalBundle()
    next.lists = ShoppingLocalStore.copyLists(bundle.lists)
    next.items = ShoppingLocalStore.copyItems(bundle.items)
    next.memos = ShoppingLocalStore.copyMemos(bundle.memos)
    next.reminders = [row].concat(ShoppingLocalStore.copyReminders(bundle.reminders))
    await ShoppingLocalStore.saveBundle(next)
    void ShoppingService.pushReminder(row)
    ShoppingNotifyService.lastError = ''
    return true
  }

  static lastNotifyError(): string {
    return ShoppingNotifyService.lastError
  }

  static async deleteReminder(id: string): Promise<boolean> {
    const bundle = ShoppingLocalStore.snapshot()
    const reminders: ShoppingReminder[] = []
    for (const r of bundle.reminders) {
      if (r.id === id) {
        await ShoppingNotifyService.cancel(r.agentId)
      } else {
        reminders.push(ShoppingLocalStore.cloneReminder(r))
      }
    }
    await ShoppingLocalStore.replaceAll(ShoppingLocalStore.copyLists(bundle.lists),
      ShoppingLocalStore.copyItems(bundle.items), ShoppingLocalStore.copyMemos(bundle.memos), reminders)
    if (AuthService.isLoggedIn()) {
      void HttpClient.delete<ShoppingReminder>(`${BASE}/reminders/${id}?${ShoppingService.userQuery()}`)
    }
    return true
  }

  static weekStats(): WeekStats {
    const stats = new WeekStats()
    const lists = ShoppingLocalStore.lists()
    const items = ShoppingLocalStore.items()
    stats.listCount = lists.length
    stats.memoCount = ShoppingLocalStore.memos().length
    for (const row of lists) {
      if (row.status === 'done') {
        stats.doneCount += 1
      } else {
        stats.activeCount += 1
      }
    }
    stats.itemCount = items.length
    for (const it of items) {
      if (it.completed) {
        stats.checkedCount += 1
      } else {
        stats.remainCount += 1
      }
    }
    return stats
  }

  static frequentItems(): FrequentItem[] {
    const lib = ShoppingLocalStore.library()
    if (lib.length > 0) {
      const out: FrequentItem[] = []
      for (const row of lib) {
        if (out.length >= 12) {
          break
        }
        out.push(ShoppingLocalStore.cloneFreq(row))
      }
      return out
    }
    const counts: FrequentItem[] = []
    for (const it of ShoppingLocalStore.items()) {
      let found = false
      for (const row of counts) {
        if (row.title === it.title) {
          row.count += 1
          found = true
          break
        }
      }
      if (!found) {
        const row = new FrequentItem()
        row.title = it.title
        row.category = it.category
        row.qty = it.qty
        row.count = 1
        counts.push(row)
      }
    }
    for (let i = 0; i < counts.length; i++) {
      for (let j = i + 1; j < counts.length; j++) {
        if (counts[j].count > counts[i].count) {
          const tmp = counts[i]
          counts[i] = counts[j]
          counts[j] = tmp
        }
      }
    }
    const out: FrequentItem[] = []
    for (const row of counts) {
      if (out.length >= 8) {
        break
      }
      out.push(row)
    }
    return out
  }

  static remainingRows(): RemainingRow[] {
    const lists = ShoppingLocalStore.lists()
    const out: RemainingRow[] = []
    for (const list of lists) {
      if (list.status === 'done') {
        continue
      }
      for (const it of ShoppingLocalStore.itemsOf(list.id)) {
        if (it.completed) {
          continue
        }
        const row = new RemainingRow()
        row.listId = list.id
        row.listTitle = list.title
        row.itemId = it.id
        row.title = it.title
        row.qty = it.qty
        out.push(row)
        if (out.length >= 8) {
          return out
        }
      }
    }
    return out
  }

  static priceSum(items: ShoppingItem[]): number {
    let sum = 0
    for (const it of items) {
      const n = Number.parseFloat(it.estPrice)
      if (!Number.isNaN(n) && n > 0) {
        sum += n
      }
    }
    return Math.round(sum * 100) / 100
  }

  static pendingPriceSum(items: ShoppingItem[]): number {
    let sum = 0
    for (const it of items) {
      if (it.completed) {
        continue
      }
      const n = Number.parseFloat(it.estPrice)
      if (!Number.isNaN(n) && n > 0) {
        sum += n
      }
    }
    return Math.round(sum * 100) / 100
  }

  static paidPriceSum(items: ShoppingItem[]): number {
    let sum = 0
    for (const it of items) {
      if (!it.completed) {
        continue
      }
      const raw = it.paidPrice.length > 0 ? it.paidPrice : it.estPrice
      const n = Number.parseFloat(raw)
      if (!Number.isNaN(n) && n > 0) {
        sum += n
      }
    }
    return Math.round(sum * 100) / 100
  }

  static async toggleItemById(itemId: string): Promise<boolean> {
    for (const it of ShoppingLocalStore.items()) {
      if (it.id === itemId) {
        return ShoppingService.toggleItem(it)
      }
    }
    return false
  }

  static aisleGroups(items: ShoppingItem[]): AisleGroup[] {
    const out: AisleGroup[] = []
    const order = CategorySuggest.categories()
    for (const cat of order) {
      const titles: string[] = []
      for (const it of items) {
        if (!it.completed && it.category === cat) {
          titles.push(it.title)
        }
      }
      if (titles.length > 0) {
        const g = new AisleGroup()
        g.cat = cat
        g.titles = titles
        out.push(g)
      }
    }
    return out
  }

  static restockRows(): RestockRow[] {
    const today = ShoppingLocalStore.today()
    const pending: string[] = []
    for (const row of ShoppingService.remainingRows()) {
      pending.push(row.title)
    }
    const latest: RestockRow[] = []
    for (const it of ShoppingLocalStore.items()) {
      if (!it.completed) {
        continue
      }
      const day = it.lastBoughtAt.length >= 10 ? it.lastBoughtAt.substring(0, 10) :
        (it.updatedAt.length >= 10 ? it.updatedAt.substring(0, 10) : '')
      if (day.length < 10) {
        continue
      }
      let found: RestockRow | undefined = undefined
      for (const row of latest) {
        if (row.title === it.title) {
          found = row
          break
        }
      }
      if (found === undefined) {
        const row = new RestockRow()
        row.title = it.title
        row.category = it.category
        row.qty = it.qty
        row.lastBoughtAt = day
        latest.push(row)
      } else if (day > found.lastBoughtAt) {
        found.lastBoughtAt = day
        found.category = it.category
        found.qty = it.qty
      }
    }
    const out: RestockRow[] = []
    for (const row of latest) {
      if (pending.indexOf(row.title) >= 0) {
        continue
      }
      if (ShoppingService.daysBetween(row.lastBoughtAt, today) < 7) {
        continue
      }
      out.push(row)
      if (out.length >= 6) {
        break
      }
    }
    return out
  }

  private static daysBetween(fromDay: string, toDay: string): number {
    const a = ShoppingNotifyService.parseRemindAt(`${fromDay} 00:00`)
    const b = ShoppingNotifyService.parseRemindAt(`${toDay} 00:00`)
    if (a === undefined || b === undefined) {
      return 0
    }
    return Math.floor((b.getTime() - a.getTime()) / 86400000)
  }

  static shareText(list: ShoppingList, items: ShoppingItem[]): string {
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

  static doneCount(items: ShoppingItem[]): number {
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
      return '今天的购物清单已经完成'
    }
    if (remain === 1) {
      return '别忘了完成今天的购物清单'
    }
    return `你的采购清单还有 ${remain} 项`
  }

  static libraryItems(): FrequentItem[] {
    return ShoppingLocalStore.library()
  }

  static async pinToLibrary(title: string, category: string, qty: string, remark: string,
    estPrice: string): Promise<void> {
    const name = title.trim()
    if (name.length === 0) {
      return
    }
    const rows = ShoppingLocalStore.library()
    for (const row of rows) {
      if (row.title === name) {
        row.count += 1
        if (category.length > 0) {
          row.category = category
        }
        if (qty.length > 0) {
          row.qty = qty
        }
        if (remark.length > 0) {
          row.remark = remark
        }
        if (estPrice.length > 0) {
          row.estPrice = estPrice
        }
        await ShoppingLocalStore.saveLibrary(rows)
        return
      }
    }
    const row = new FrequentItem()
    row.title = name
    row.category = category
    row.qty = qty
    row.remark = remark
    row.estPrice = estPrice
    row.count = 1
    rows.unshift(row)
    await ShoppingLocalStore.saveLibrary(rows)
  }

  static async removeLibrary(title: string): Promise<void> {
    const rows: FrequentItem[] = []
    for (const row of ShoppingLocalStore.library()) {
      if (row.title !== title) {
        rows.push(row)
      }
    }
    await ShoppingLocalStore.saveLibrary(rows)
  }

  static async touchLibrary(item: ShoppingItem): Promise<void> {
    await ShoppingService.pinToLibrary(item.title, item.category, item.qty, item.remark, item.estPrice)
  }

  static historyLists(): ShoppingList[] {
    const out: ShoppingList[] = []
    for (const row of ShoppingLocalStore.lists()) {
      if (row.status === 'done') {
        out.push(row)
      }
    }
    return out
  }

  static starredLists(): ShoppingList[] {
    const out: ShoppingList[] = []
    for (const row of ShoppingLocalStore.lists()) {
      if (row.starred) {
        out.push(row)
      }
    }
    return out
  }

  static async toggleStar(listId: string): Promise<void> {
    await ShoppingService.patchListFlag(listId, 'star')
  }

  static async setListKind(listId: string, kind: string): Promise<void> {
    const bundle = ShoppingLocalStore.snapshot()
    const lists: ShoppingList[] = []
    for (const row of bundle.lists) {
      const copy = ShoppingLocalStore.cloneList(row)
      if (copy.id === listId) {
        copy.kind = kind
        copy.coverKey = ShoppingCatalog.coverOfKind(kind)
        copy.updatedAt = ShoppingLocalStore.nowIso()
      }
      lists.push(copy)
    }
    await ShoppingLocalStore.replaceAll(lists, ShoppingLocalStore.copyItems(bundle.items),
      ShoppingLocalStore.copyMemos(bundle.memos), ShoppingLocalStore.copyReminders(bundle.reminders))
  }

  static async setListMembers(listId: string, members: string): Promise<void> {
    const bundle = ShoppingLocalStore.snapshot()
    const lists: ShoppingList[] = []
    for (const row of bundle.lists) {
      const copy = ShoppingLocalStore.cloneList(row)
      if (copy.id === listId) {
        copy.members = members
        copy.updatedAt = ShoppingLocalStore.nowIso()
      }
      lists.push(copy)
    }
    await ShoppingLocalStore.replaceAll(lists, ShoppingLocalStore.copyItems(bundle.items),
      ShoppingLocalStore.copyMemos(bundle.memos), ShoppingLocalStore.copyReminders(bundle.reminders))
  }

  private static async patchListFlag(listId: string, flag: string): Promise<void> {
    const bundle = ShoppingLocalStore.snapshot()
    const lists: ShoppingList[] = []
    for (const row of bundle.lists) {
      const copy = ShoppingLocalStore.cloneList(row)
      if (copy.id === listId && flag === 'star') {
        copy.starred = !copy.starred
        copy.updatedAt = ShoppingLocalStore.nowIso()
      }
      lists.push(copy)
    }
    await ShoppingLocalStore.replaceAll(lists, ShoppingLocalStore.copyItems(bundle.items),
      ShoppingLocalStore.copyMemos(bundle.memos), ShoppingLocalStore.copyReminders(bundle.reminders))
  }

  static paidSum(items: ShoppingItem[]): number {
    let sum = 0
    for (const it of items) {
      const raw = it.paidPrice.length > 0 ? it.paidPrice : ''
      const n = Number.parseFloat(raw)
      if (!Number.isNaN(n) && n > 0) {
        sum += n
      }
    }
    return Math.round(sum * 100) / 100
  }

  static spendSnapshot(): SpendSnapshot {
    const out = new SpendSnapshot()
    const items = ShoppingLocalStore.items()
    out.itemCount = items.length
    out.estTotal = ShoppingService.priceSum(items)
    out.paidTotal = ShoppingService.paidSum(items)
    let buys = 0
    const names: FrequentItem[] = ShoppingService.frequentItems()
    for (const it of items) {
      if (it.completed) {
        buys += 1
      }
    }
    out.buyTimes = buys
    if (names.length > 0) {
      out.topName = names[0].title
    }
    return out
  }

  static sortItems(items: ShoppingItem[], mode: string): ShoppingItem[] {
    const out: ShoppingItem[] = []
    for (const it of items) {
      out.push(it)
    }
    if (mode === '状态') {
      const a: ShoppingItem[] = []
      const b: ShoppingItem[] = []
      for (const it of out) {
        if (it.completed) {
          b.push(it)
        } else {
          a.push(it)
        }
      }
      return a.concat(b)
    }
    if (mode === '时间') {
      for (let i = 0; i < out.length; i++) {
        for (let j = i + 1; j < out.length; j++) {
          if (out[j].updatedAt > out[i].updatedAt) {
            const tmp = out[i]
            out[i] = out[j]
            out[j] = tmp
          }
        }
      }
      return out
    }
    return out
  }

  static filterByTag(items: ShoppingItem[], tag: string): ShoppingItem[] {
    if (tag.length === 0 || tag === '全部') {
      return items
    }
    const out: ShoppingItem[] = []
    for (const it of items) {
      if (it.tag === tag) {
        out.push(it)
      }
    }
    return out
  }

  static extraLine(it: ShoppingItem): string {
    const bits: string[] = []
    if (it.qty.length > 0) {
      bits.push(it.qty)
    }
    if (it.tag.length > 0) {
      bits.push(it.tag)
    }
    if (it.estPrice.length > 0) {
      bits.push(`估${it.estPrice}`)
    }
    if (it.paidPrice.length > 0) {
      bits.push(`实付${it.paidPrice}`)
    }
    if (it.assignee.length > 0) {
      bits.push(it.assignee)
    }
    if (it.remark.length > 0 && bits.length === 0) {
      bits.push(it.remark)
    }
    let line = ''
    for (let i = 0; i < bits.length; i++) {
      line = i === 0 ? bits[i] : `${line} · ${bits[i]}`
    }
    return line
  }

  static async syncAfterLogin(): Promise<void> {
    await ShoppingService.claimLocalOwner()
    await ShoppingService.pullRemote()
    await ShoppingService.pushAllLocal()
    void ShoppingWidgetSync.push()
  }

  private static async claimLocalOwner(): Promise<void> {
    const uid = ShoppingService.actorId()
    const bundle = ShoppingLocalStore.snapshot()
    for (const row of bundle.lists) {
      if (row.userId.length === 0 || row.userId === 'local') {
        row.userId = uid
      }
    }
    for (const row of bundle.items) {
      if (row.userId.length === 0 || row.userId === 'local') {
        row.userId = uid
      }
    }
    for (const row of bundle.memos) {
      if (row.userId.length === 0 || row.userId === 'local') {
        row.userId = uid
      }
    }
    for (const row of bundle.reminders) {
      if (row.userId.length === 0 || row.userId === 'local') {
        row.userId = uid
      }
    }
    await ShoppingLocalStore.saveBundle(bundle)
  }

  private static idSet(ids: string[]): boolean {
    return ids.length >= 0
  }

  private static hasId(ids: string[], id: string): boolean {
    for (const x of ids) {
      if (x === id) {
        return true
      }
    }
    return false
  }

  private static async pullRemote(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const q = ShoppingService.userQuery()
    const listsRes = await HttpClient.get<ListData<ShoppingList>>(`${BASE}/lists?${q}`)
    const itemsRes = await HttpClient.get<ListData<ShoppingItem>>(`${BASE}/items?${q}`)
    const memosRes = await HttpClient.get<ListData<ShoppingMemoNote>>(`${BASE}/memos?${q}`)
    const rmdRes = await HttpClient.get<ListData<ShoppingReminder>>(`${BASE}/reminders?${q}`)
    const bundle = ShoppingLocalStore.snapshot()
    let lists = ShoppingLocalStore.copyLists(bundle.lists)
    let items = ShoppingLocalStore.copyItems(bundle.items)
    let memos = ShoppingLocalStore.copyMemos(bundle.memos)
    let reminders = ShoppingLocalStore.copyReminders(bundle.reminders)
    if (listsRes.code === 0) {
      lists = ShoppingService.mergeLists(lists, ShoppingService.values(listsRes.data))
    }
    if (itemsRes.code === 0) {
      items = ShoppingService.mergeItems(items, ShoppingService.values(itemsRes.data))
    }
    if (memosRes.code === 0) {
      memos = ShoppingService.mergeMemos(memos, ShoppingService.values(memosRes.data))
    }
    if (rmdRes.code === 0) {
      reminders = ShoppingService.mergeReminders(reminders, ShoppingService.values(rmdRes.data))
    }
    await ShoppingLocalStore.replaceAll(lists, items, memos, reminders)
  }

  private static mergeLists(local: ShoppingList[], remote: ShoppingList[]): ShoppingList[] {
    const out = ShoppingLocalStore.copyLists(local)
    for (const row of remote) {
      const mapped = ShoppingLocalStore.cloneList(row)
      if (mapped.id.length === 0) {
        continue
      }
      let found = false
      for (let i = 0; i < out.length; i++) {
        if (out[i].id === mapped.id) {
          out[i] = mapped
          found = true
          break
        }
      }
      if (!found) {
        out.unshift(mapped)
      }
    }
    return out
  }

  private static mergeItems(local: ShoppingItem[], remote: ShoppingItem[]): ShoppingItem[] {
    const out = ShoppingLocalStore.copyItems(local)
    for (const row of remote) {
      const mapped = ShoppingLocalStore.cloneItem(row)
      if (mapped.id.length === 0) {
        continue
      }
      let found = false
      for (let i = 0; i < out.length; i++) {
        if (out[i].id === mapped.id) {
          out[i] = mapped
          found = true
          break
        }
      }
      if (!found) {
        out.unshift(mapped)
      }
    }
    return out
  }

  private static mergeMemos(local: ShoppingMemoNote[], remote: ShoppingMemoNote[]): ShoppingMemoNote[] {
    const out = ShoppingLocalStore.copyMemos(local)
    for (const row of remote) {
      const mapped = ShoppingLocalStore.cloneMemo(row)
      if (mapped.id.length === 0 || mapped.title.length === 0) {
        continue
      }
      let found = false
      for (let i = 0; i < out.length; i++) {
        if (out[i].id === mapped.id) {
          out[i] = mapped
          found = true
          break
        }
      }
      if (!found) {
        out.unshift(mapped)
      }
    }
    return out
  }

  private static mergeReminders(local: ShoppingReminder[], remote: ShoppingReminder[]): ShoppingReminder[] {
    const out = ShoppingLocalStore.copyReminders(local)
    for (const row of remote) {
      const mapped = ShoppingLocalStore.cloneReminder(row)
      if (mapped.id.length === 0) {
        continue
      }
      let found = false
      for (let i = 0; i < out.length; i++) {
        if (out[i].id === mapped.id) {
          mapped.agentId = out[i].agentId
          out[i] = mapped
          found = true
          break
        }
      }
      if (!found) {
        out.unshift(mapped)
      }
    }
    return out
  }

  private static async pushAllLocal(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const q = ShoppingService.userQuery()
    const listsRes = await HttpClient.get<ListData<ShoppingList>>(`${BASE}/lists?${q}`)
    const itemsRes = await HttpClient.get<ListData<ShoppingItem>>(`${BASE}/items?${q}`)
    const memosRes = await HttpClient.get<ListData<ShoppingMemoNote>>(`${BASE}/memos?${q}`)
    const rmdRes = await HttpClient.get<ListData<ShoppingReminder>>(`${BASE}/reminders?${q}`)
    const remoteListIds: string[] = []
    const remoteItemIds: string[] = []
    const remoteMemoIds: string[] = []
    const remoteRmdIds: string[] = []
    if (listsRes.code === 0) {
      for (const row of ShoppingService.values(listsRes.data)) {
        remoteListIds.push(row.id)
      }
    }
    if (itemsRes.code === 0) {
      for (const row of ShoppingService.values(itemsRes.data)) {
        remoteItemIds.push(row.id)
      }
    }
    if (memosRes.code === 0) {
      for (const row of ShoppingService.values(memosRes.data)) {
        remoteMemoIds.push(row.id)
      }
    }
    if (rmdRes.code === 0) {
      for (const row of ShoppingService.values(rmdRes.data)) {
        remoteRmdIds.push(row.id)
      }
    }
    void ShoppingService.idSet(remoteListIds)
    for (const row of ShoppingLocalStore.lists()) {
      if (!ShoppingService.hasId(remoteListIds, row.id)) {
        await ShoppingService.pushList(row)
      }
    }
    for (const row of ShoppingLocalStore.items()) {
      if (!ShoppingService.hasId(remoteItemIds, row.id)) {
        await ShoppingService.pushItem(row)
      }
    }
    for (const row of ShoppingLocalStore.memos()) {
      if (!ShoppingService.hasId(remoteMemoIds, row.id)) {
        await ShoppingService.pushMemo(row, true)
      }
    }
    for (const row of ShoppingLocalStore.reminders()) {
      if (!ShoppingService.hasId(remoteRmdIds, row.id)) {
        await ShoppingService.pushReminder(row)
      }
    }
  }

  private static async pushList(row: ShoppingList): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const body = new CreateListBody()
    body.id = row.id
    body.title = row.title
    body.summary = row.summary
    body.dueDate = row.dueDate
    body.coverKey = row.coverKey
    body.status = row.status
    body.userId = ShoppingService.actorId()
    await HttpClient.post<ShoppingList>(`${BASE}/lists`, body)
  }

  private static async pushItem(row: ShoppingItem): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const body = new CreateItemBody()
    body.id = row.id
    body.title = row.title
    body.listId = row.listId
    body.category = row.category
    body.qty = row.qty
    body.remark = row.remark
    body.completed = row.completed
    body.userId = ShoppingService.actorId()
    await HttpClient.post<ShoppingItem>(`${BASE}/items`, body)
  }

  private static async patchItemRemote(row: ShoppingItem): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const patch = new PatchItemBody()
    patch.completed = row.completed
    patch.userId = ShoppingService.actorId()
    await HttpClient.patch<ShoppingItem>(`${BASE}/items/${row.id}`, patch)
  }

  private static async pushMemo(row: ShoppingMemoNote, isNew: boolean): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    if (isNew) {
      const body = new CreateMemoBody()
      body.id = row.id
      body.title = row.title
      body.body = row.body
      body.important = row.important
      body.remindAt = row.remindAt
      body.userId = ShoppingService.actorId()
      await HttpClient.post<ShoppingMemoNote>(`${BASE}/memos`, body)
      return
    }
    const update = new UpdateMemoBody()
    update.title = row.title
    update.body = row.body
    update.important = row.important
    update.remindAt = row.remindAt
    update.userId = ShoppingService.actorId()
    await HttpClient.put<ShoppingMemoNote>(`${BASE}/memos/${row.id}`, update)
  }

  private static async pushReminder(row: ShoppingReminder): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const body = new CreateReminderBody()
    body.id = row.id
    body.title = row.title
    body.listId = row.listId
    body.remindAt = row.remindAt
    body.userId = ShoppingService.actorId()
    await HttpClient.post<ShoppingReminder>(`${BASE}/reminders`, body)
  }

  private static sortMemos(rows: ShoppingMemoNote[]): ShoppingMemoNote[] {
    const out: ShoppingMemoNote[] = []
    for (const row of rows) {
      out.push(row)
    }
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
}
