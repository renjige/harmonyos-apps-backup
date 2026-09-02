import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import { CategorySuggest } from './CategorySuggest'
import { TaskLocalStore } from './TaskLocalStore'
import { ActivityService } from './ActivityService'
import { CheckInService } from './CheckInService'
import { AchievementService } from './AchievementService'
import { GoalService } from './GoalService'
import {
  CreateTaskBody,
  FamilyCategory,
  FamilyNotice,
  FamilyRhythm,
  FamilyTaskItem,
  ListPayload,
  PatchTaskBody,
  TaskDates
} from '../models/FamilyTaskModels'

const BASE = '/biz/family-task'

export class TaskService {
  private static values<T>(data: ListPayload<T> | undefined): T[] {
    if (data === undefined) {
      return []
    }
    return data.list.length > 0 ? data.list : data.items
  }

  static actorId(): string {
    const name = AppStorage.get<string>('currentUsername') ?? ''
    if (name.length > 0) {
      return name
    }
    return 'local'
  }

  static async categories(): Promise<FamilyCategory[]> {
    const res = await HttpClient.get<ListPayload<FamilyCategory>>(`${BASE}/categories`)
    if (res.code === 0 && TaskService.values(res.data).length > 0) {
      return TaskService.values(res.data)
    }
    const titles = CategorySuggest.categories()
    const fallback: FamilyCategory[] = []
    for (let i = 0; i < titles.length; i++) {
      const c = new FamilyCategory()
      c.id = `local_cat_${i}`
      c.title = titles[i]
      c.coverKey = CategorySuggest.coverKey(titles[i])
      fallback.push(c)
    }
    return fallback
  }

  static async rhythm(): Promise<FamilyRhythm[]> {
    const res = await HttpClient.get<ListPayload<FamilyRhythm>>(`${BASE}/rhythm`)
    return res.code === 0 ? TaskService.values(res.data) : []
  }

  static async notices(): Promise<FamilyNotice[]> {
    const res = await HttpClient.get<ListPayload<FamilyNotice>>(`${BASE}/messages`)
    if (res.code === 0) {
      return TaskService.values(res.data)
    }
    const res2 = await HttpClient.get<ListPayload<FamilyNotice>>('/messages')
    return res2.code === 0 ? TaskService.values(res2.data) : []
  }

  static async all(): Promise<FamilyTaskItem[]> {
    const local = TaskService.sortTasks(TaskService.cloneList(TaskLocalStore.tasks()))
    if (!AuthService.isLoggedIn()) {
      return local
    }
    const uid = encodeURIComponent(TaskService.actorId())
    const res = await HttpClient.get<ListPayload<FamilyTaskItem>>(`${BASE}/tasks?userId=${uid}`)
    if (res.code !== 0) {
      return local
    }
    const remote = TaskService.values(res.data)
    if (remote.length === 0) {
      return local
    }
    const mapped: FamilyTaskItem[] = []
    for (const row of remote) {
      mapped.push(TaskLocalStore.mapTask(row))
    }
    const merged = TaskService.mergeTasks(local, mapped)
    await TaskLocalStore.saveTasks(merged)
    return TaskService.sortTasks(merged)
  }

  /** 登录后：本机任务归属当前账号，并确保看板能读到本地待办。 */
  static async onAuthChanged(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const uid = TaskService.actorId()
    const tasks = TaskLocalStore.tasks().slice()
    let changed = false
    for (const row of tasks) {
      if (row.userId.length === 0 || row.userId === 'local') {
        row.userId = uid
        changed = true
      }
    }
    if (changed) {
      await TaskLocalStore.saveTasks(tasks)
    }
    if (TaskLocalStore.tasks().length === 0) {
      await TaskLocalStore.seedWelcomeSamples()
    }
    await TaskService.all()
  }
  private static mergeTasks(local: FamilyTaskItem[], remote: FamilyTaskItem[]): FamilyTaskItem[] {
    const seen: string[] = []
    const out: FamilyTaskItem[] = []
    for (const row of remote) {
      out.push(row)
      seen.push(row.id)
    }
    for (const row of local) {
      let hit = false
      for (const id of seen) {
        if (id === row.id) {
          hit = true
          break
        }
      }
      if (!hit) {
        out.push(row)
      }
    }
    return out
  }

  static async byDate(date: string): Promise<FamilyTaskItem[]> {
    const all = await TaskService.all()
    const out: FamilyTaskItem[] = []
    for (const row of all) {
      if (row.date === date) {
        out.push(row)
      }
    }
    return out
  }

  static async today(): Promise<FamilyTaskItem[]> {
    return TaskService.byDate(TaskDates.today())
  }

  static pendingCount(rows: FamilyTaskItem[]): number {
    let n = 0
    for (const row of rows) {
      if (!row.completed) {
        n += 1
      }
    }
    return n
  }

  static doneCount(rows: FamilyTaskItem[]): number {
    return rows.length - TaskService.pendingCount(rows)
  }

  static progress(rows: FamilyTaskItem[]): number {
    if (rows.length === 0) {
      return 0
    }
    return Math.round((TaskService.doneCount(rows) * 100) / rows.length)
  }

  static async create(draft: FamilyTaskItem): Promise<FamilyTaskItem> {
    const row = new FamilyTaskItem()
    row.id = TaskLocalStore.newId()
    row.title = draft.title.trim()
    row.category = draft.category.length > 0 ? draft.category : CategorySuggest.suggest(draft.title)
    row.date = draft.date.length > 0 ? draft.date : TaskDates.today()
    row.time = draft.time
    row.completed = false
    row.reminder = draft.reminder
    row.repeatType = draft.repeatType
    row.remark = draft.remark
    row.assignee = draft.assignee
    row.userId = TaskService.actorId()
    row.createdAt = TaskLocalStore.nowIso()
    row.updatedAt = row.createdAt
    const next = TaskLocalStore.tasks().slice()
    next.unshift(row)
    await TaskLocalStore.saveTasks(next)
    if (AuthService.isLoggedIn()) {
      const body = new CreateTaskBody()
      body.title = row.title
      body.category = row.category
      body.date = row.date
      body.time = row.time
      body.reminder = row.reminder
      body.repeatType = row.repeatType
      body.remark = row.remark
      body.userId = row.userId
      const res = await HttpClient.post<FamilyTaskItem>(`${BASE}/tasks`, body)
      if (res.code === 0 && res.data !== undefined && res.data.id.length > 0) {
        row.id = res.data.id
        await TaskLocalStore.saveTasks(next)
      }
    }
    await ActivityService.log('create', 'task', row.id, row.title, `计划 · ${row.category}`)
    await AchievementService.evaluate()
    return row
  }

  static async update(row: FamilyTaskItem): Promise<void> {
    row.updatedAt = TaskLocalStore.nowIso()
    const next: FamilyTaskItem[] = []
    for (const it of TaskLocalStore.tasks()) {
      if (it.id === row.id) {
        next.push(row)
      } else {
        next.push(it)
      }
    }
    await TaskLocalStore.saveTasks(next)
    if (AuthService.isLoggedIn()) {
      const body = new PatchTaskBody()
      body.title = row.title
      body.category = row.category
      body.date = row.date
      body.time = row.time
      body.reminder = row.reminder
      body.repeatType = row.repeatType
      body.remark = row.remark
      body.completed = row.completed
      body.userId = TaskService.actorId()
      await HttpClient.put<FamilyTaskItem>(`${BASE}/tasks/${row.id}`, body)
    }
    await ActivityService.log('update', 'task', row.id, row.title, row.completed ? '标记完成' : '更新计划')
  }

  static async toggle(row: FamilyTaskItem): Promise<void> {
    row.completed = !row.completed
    await TaskService.update(row)
    if (row.completed) {
      await CheckInService.recordTaskDone()
      await ActivityService.log('complete', 'task', row.id, row.title, '完成计划')
      await GoalService.bumpProgressForTask()
      await AchievementService.evaluate()
      if (row.repeatType !== 'none') {
        const clone = new FamilyTaskItem()
        clone.title = row.title
        clone.category = row.category
        clone.date = TaskDates.nextRepeat(row.date, row.repeatType)
        clone.time = row.time
        clone.reminder = row.reminder
        clone.repeatType = row.repeatType
        clone.remark = row.remark
        clone.assignee = row.assignee
        await TaskService.create(clone)
      }
    }
  }

  static async remove(id: string): Promise<void> {
    let title = ''
    const next: FamilyTaskItem[] = []
    for (const it of TaskLocalStore.tasks()) {
      if (it.id === id) {
        title = it.title
      } else {
        next.push(it)
      }
    }
    await TaskLocalStore.saveTasks(next)
    if (title.length > 0) {
      await ActivityService.log('delete', 'task', id, title, '删除计划')
    }
    if (AuthService.isLoggedIn()) {
      await HttpClient.delete<FamilyTaskItem>(`${BASE}/tasks/${id}?userId=${encodeURIComponent(TaskService.actorId())}`)
    }
  }

  static async clearAll(): Promise<void> {
    const current = TaskLocalStore.tasks().slice()
    await TaskLocalStore.saveTasks([])
    if (AuthService.isLoggedIn()) {
      for (const row of current) {
        await HttpClient.delete<FamilyTaskItem>(`${BASE}/tasks/${row.id}?userId=${encodeURIComponent(TaskService.actorId())}`)
      }
    }
  }

  static exportText(): string {
    const rows = TaskLocalStore.tasks()
    return TaskLocalStore.serializeBundle(TaskLocalStore.snapshot()) + `\n共 ${rows.length} 件家庭事项`
  }

  static morning(rows: FamilyTaskItem[]): FamilyTaskItem[] {
    const out: FamilyTaskItem[] = []
    for (const row of rows) {
      if (!row.completed && row.period() === '上午') {
        out.push(row)
      }
    }
    return out
  }

  static afternoon(rows: FamilyTaskItem[]): FamilyTaskItem[] {
    const out: FamilyTaskItem[] = []
    for (const row of rows) {
      if (!row.completed && row.period() !== '上午') {
        out.push(row)
      }
    }
    return out
  }

  static completedOf(rows: FamilyTaskItem[]): FamilyTaskItem[] {
    const out: FamilyTaskItem[] = []
    for (const row of rows) {
      if (row.completed) {
        out.push(row)
      }
    }
    return out
  }

  static weekRows(all: FamilyTaskItem[], today: string): FamilyTaskItem[] {
    const out: FamilyTaskItem[] = []
    for (const row of all) {
      if (TaskDates.inSameWeek(row.date, today)) {
        out.push(row)
      }
    }
    return out
  }

  static topCategory(rows: FamilyTaskItem[]): string {
    const titles = CategorySuggest.categories()
    let best = '其他'
    let bestN = 0
    for (const title of titles) {
      let n = 0
      for (const row of rows) {
        if (row.category === title) {
          n += 1
        }
      }
      if (n > bestN) {
        bestN = n
        best = title
      }
    }
    return best
  }

  static categoryShare(rows: FamilyTaskItem[], title: string): number {
    if (rows.length === 0) {
      return 0
    }
    let n = 0
    for (const row of rows) {
      if (row.category === title) {
        n += 1
      }
    }
    return Math.round((n * 100) / rows.length)
  }

  static reviewLine(week: FamilyTaskItem[], rhythm: FamilyRhythm[]): string {
    const done = TaskService.doneCount(week)
    if (week.length === 0) {
      return '这周还很轻盈。记下第一件小事，家里就会慢慢有条理。'
    }
    const top = TaskService.topCategory(week)
    for (const r of rhythm) {
      if (top === '家务' && r.id.indexOf('chore') >= 0) {
        return r.body
      }
      if (r.id.indexOf('weekend') >= 0 && done > 0) {
        return r.body
      }
    }
    return `本周完成了 ${done} 件家庭事项。${top}安排最规律。`
  }

  static cloneItem(source: FamilyTaskItem): FamilyTaskItem {
    const item = new FamilyTaskItem()
    item.id = source.id
    item.title = source.title
    item.category = source.category
    item.date = source.date
    item.time = source.time
    item.completed = source.completed
    item.reminder = source.reminder
    item.repeatType = source.repeatType
    item.remark = source.remark
    item.assignee = source.assignee
    item.reminderAgentId = source.reminderAgentId
    item.userId = source.userId
    item.createdAt = source.createdAt
    item.updatedAt = source.updatedAt
    item.isSample = source.isSample
    return item
  }

  static cloneList(rows: FamilyTaskItem[]): FamilyTaskItem[] {
    const out: FamilyTaskItem[] = []
    for (const row of rows) {
      out.push(TaskService.cloneItem(row))
    }
    return out
  }

  static mapToggleList(rows: FamilyTaskItem[], id: string, completed: boolean): FamilyTaskItem[] {
    const out: FamilyTaskItem[] = []
    for (const row of rows) {
      const copy = TaskService.cloneItem(row)
      if (copy.id === id) {
        copy.completed = completed
      }
      out.push(copy)
    }
    return out
  }

  private static sortTasks(rows: FamilyTaskItem[]): FamilyTaskItem[] {
    const out = rows.slice()
    out.sort((a: FamilyTaskItem, b: FamilyTaskItem) => {
      const ka = `${a.date} ${a.time}`
      const kb = `${b.date} ${b.time}`
      return ka.localeCompare(kb)
    })
    return out
  }
}
