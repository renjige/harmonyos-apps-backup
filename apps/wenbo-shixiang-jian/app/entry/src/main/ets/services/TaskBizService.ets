import { HttpClient } from './HttpClient'
import { EmptyPayload } from '../models/ApiModels'
import {
  CategoryItem,
  CreateHabitLogRequest,
  CreateHabitRequest,
  CreateTaskRequest,
  KpiItem,
  KpiListPayload,
  MessageItem,
  PatchTaskStatusRequest,
  StatsData,
  TagPresetItem,
  TaskItem,
  TaskItemWire,
  TaskListPayload,
  UpdateTaskRequest,
  FocusSessionRequest
} from '../models/TaskModels'

export class TaskBizService {
  static lastError: string = ''

  static todayLocal(): string {
    const d = new Date()
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  private static userId(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  private static mapItems(wires: TaskItemWire[]): TaskItem[] {
    const out: TaskItem[] = []
    for (const w of wires) {
      out.push(TaskItem.fromWire(w))
    }
    return out
  }

  static async loadCategories(): Promise<CategoryItem[]> {
    const res = await HttpClient.get<TaskListPayload>('/biz/task-efficiency/categories')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: CategoryItem[] = []
      for (const w of res.data.list) {
        out.push(CategoryItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async loadTagPresets(): Promise<TagPresetItem[]> {
    const res = await HttpClient.get<TaskListPayload>('/biz/task-efficiency/tag-presets')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: TagPresetItem[] = []
      for (const w of res.data.list) {
        out.push(TagPresetItem.fromWire(w))
      }
      return out
    }
    return []
  }

  static async loadTips(): Promise<TaskItem[]> {
    const res = await HttpClient.get<TaskListPayload>('/biz/task-efficiency/tips')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return TaskBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findTip(id: string): Promise<TaskItem | undefined> {
    const res = await HttpClient.get<TaskItemWire>(`/biz/task-efficiency/tips/${id}`)
    if (res.code === 0 && res.data !== undefined && res.data !== null) {
      return TaskItem.fromWire(res.data)
    }
    return undefined
  }

  static async loadTasks(userId: string, category: string = '', status: string = '',
    dueDate: string = ''): Promise<TaskItem[]> {
    const uid = userId.length > 0 ? userId : TaskBizService.userId()
    if (uid.length === 0) {
      return []
    }
    let path = `/biz/task-efficiency/tasks?userId=${encodeURIComponent(uid)}`
    if (category.length > 0) {
      path += `&category=${encodeURIComponent(category)}`
    }
    if (status.length > 0) {
      path += `&status=${encodeURIComponent(status)}`
    }
    if (dueDate.length > 0) {
      path += `&dueDate=${encodeURIComponent(dueDate)}`
    }
    const res = await HttpClient.get<TaskListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return TaskBizService.mapItems(res.data.list)
    }
    return []
  }

  static async findTask(id: string): Promise<TaskItem | undefined> {
    TaskBizService.lastError = ''
    const uid = TaskBizService.userId()
    if (uid.length === 0) {
      TaskBizService.lastError = '请先登录后查看事项详情'
      return undefined
    }
    const path = `/biz/task-efficiency/tasks/${id}?userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<TaskItemWire>(path)
    if (res.code === 0 && res.data !== undefined && res.data !== null) {
      return TaskItem.fromWire(res.data)
    }
    TaskBizService.lastError = res.message.length > 0 ? res.message : '事项不存在或无权查看'
    return undefined
  }

  static async createTask(req: CreateTaskRequest): Promise<TaskItem | undefined> {
    TaskBizService.lastError = ''
    if (req.userId.length === 0) {
      req.userId = TaskBizService.userId()
    }
    if (req.userId.length === 0) {
      TaskBizService.lastError = '请先登录后再创建事项'
      return undefined
    }
    const res = await HttpClient.postJson<TaskItemWire>('/biz/task-efficiency/tasks', req.toJsonString())
    if (res.code === 0 && res.data !== undefined && res.data !== null) {
      return TaskItem.fromWire(res.data)
    }
    TaskBizService.lastError = res.message.length > 0 ? res.message : '创建失败，请稍后重试'
    return undefined
  }

  static async updateTask(id: string, req: UpdateTaskRequest): Promise<TaskItem | undefined> {
    TaskBizService.lastError = ''
    if (req.userId.length === 0) {
      req.userId = TaskBizService.userId()
    }
    const res = await HttpClient.putJson<TaskItemWire>(
      `/biz/task-efficiency/tasks/${id}`,
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined && res.data !== null) {
      return TaskItem.fromWire(res.data)
    }
    TaskBizService.lastError = res.message.length > 0 ? res.message : '保存失败，请稍后重试'
    return undefined
  }

  static async patchTaskStatus(id: string, status: string): Promise<TaskItem | undefined> {
    TaskBizService.lastError = ''
    const req = new PatchTaskStatusRequest()
    req.status = status
    req.userId = TaskBizService.userId()
    const res = await HttpClient.postJson<TaskItemWire>(
      `/biz/task-efficiency/tasks/${id}/status`,
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined && res.data !== null) {
      return TaskItem.fromWire(res.data)
    }
    TaskBizService.lastError = res.message.length > 0 ? res.message : '状态更新失败'
    return undefined
  }

  static async recordFocus(id: string, seconds: number): Promise<TaskItem | undefined> {
    TaskBizService.lastError = ''
    const req = new FocusSessionRequest()
    req.seconds = seconds
    req.userId = TaskBizService.userId()
    if (req.userId.length === 0) {
      TaskBizService.lastError = '请先登录后再专注'
      return undefined
    }
    const res = await HttpClient.postJson<TaskItemWire>(
      `/biz/task-efficiency/tasks/${id}/focus`,
      req.toJsonString()
    )
    if (res.code === 0 && res.data !== undefined && res.data !== null) {
      return TaskItem.fromWire(res.data)
    }
    TaskBizService.lastError = res.message.length > 0 ? res.message : '专注记录失败'
    return undefined
  }

  static async setLane(id: string, item: TaskItem, lane: string, timeSlot: string): Promise<TaskItem | undefined> {
    const req = new UpdateTaskRequest()
    req.title = item.title
    req.description = item.description
    req.dueDate = item.dueDate
    req.priority = item.priority
    req.tags = item.tags
    req.category = item.category
    req.categoryId = item.categoryId
    req.userId = TaskBizService.userId()
    req.timeSlot = timeSlot
    req.lane = lane
    req.closeReason = item.closeReason
    return TaskBizService.updateTask(id, req)
  }

  static async setCloseReason(id: string, item: TaskItem, reason: string): Promise<TaskItem | undefined> {
    const req = new UpdateTaskRequest()
    req.title = item.title
    req.description = item.description
    req.dueDate = item.dueDate
    req.priority = item.priority
    req.tags = item.tags
    req.category = item.category
    req.categoryId = item.categoryId
    req.userId = TaskBizService.userId()
    req.timeSlot = item.timeSlot
    req.lane = item.lane
    req.closeReason = reason
    return TaskBizService.updateTask(id, req)
  }

  static async loadHabits(userId: string): Promise<TaskItem[]> {
    const uid = userId.length > 0 ? userId : TaskBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<TaskListPayload>(
      `/biz/task-efficiency/habits?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return TaskBizService.mapItems(res.data.list)
    }
    return []
  }

  static async loadHabitLogs(userId: string, logDate: string = ''): Promise<TaskItem[]> {
    const uid = userId.length > 0 ? userId : TaskBizService.userId()
    if (uid.length === 0) {
      return []
    }
    let path = `/biz/task-efficiency/habit-logs?userId=${encodeURIComponent(uid)}`
    if (logDate.length > 0) {
      path += `&logDate=${encodeURIComponent(logDate)}`
    }
    const res = await HttpClient.get<TaskListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out = TaskBizService.mapItems(res.data.list)
      if (logDate.length === 0) {
        return out
      }
      const filtered: TaskItem[] = []
      for (const item of out) {
        if (item.logDate === logDate) {
          filtered.push(item)
        }
      }
      return filtered
    }
    return []
  }

  static async createHabit(req: CreateHabitRequest): Promise<TaskItem | undefined> {
    TaskBizService.lastError = ''
    if (req.userId.length === 0) {
      req.userId = TaskBizService.userId()
    }
    if (req.userId.length === 0) {
      TaskBizService.lastError = '请先登录后再创建习惯'
      return undefined
    }
    const res = await HttpClient.postJson<TaskItemWire>('/biz/task-efficiency/habits', req.toJsonString())
    if (res.code === 0 && res.data !== undefined && res.data !== null) {
      return TaskItem.fromWire(res.data)
    }
    TaskBizService.lastError = res.message.length > 0 ? res.message : '创建失败，请稍后重试'
    return undefined
  }

  static async checkInHabit(habitId: string): Promise<boolean> {
    TaskBizService.lastError = ''
    const req = new CreateHabitLogRequest()
    req.habitId = habitId
    req.userId = TaskBizService.userId()
    req.logDate = TaskBizService.todayLocal()
    if (req.userId.length === 0) {
      TaskBizService.lastError = '请先登录后再打卡'
      return false
    }
    const res = await HttpClient.postJson<TaskItemWire>(
      '/biz/task-efficiency/habit-logs',
      req.toJsonString()
    )
    if (res.code !== 0) {
      TaskBizService.lastError = res.message.length > 0 ? res.message : '打卡失败'
    }
    return res.code === 0
  }

  static async deleteTask(id: string): Promise<boolean> {
    TaskBizService.lastError = ''
    const uid = TaskBizService.userId()
    if (uid.length === 0) {
      TaskBizService.lastError = '请先登录'
      return false
    }
    const path = `/biz/task-efficiency/tasks/${id}?userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.delete<EmptyPayload>(path)
    if (res.code !== 0) {
      TaskBizService.lastError = res.message.length > 0 ? res.message : '删除失败'
    }
    return res.code === 0
  }

  static async deleteHabit(id: string): Promise<boolean> {
    TaskBizService.lastError = ''
    const uid = TaskBizService.userId()
    if (uid.length === 0) {
      TaskBizService.lastError = '请先登录'
      return false
    }
    const path = `/biz/task-efficiency/habits/${id}?userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.delete<EmptyPayload>(path)
    if (res.code !== 0) {
      TaskBizService.lastError = res.message.length > 0 ? res.message : '删除失败'
    }
    return res.code === 0
  }

  static async search(q: string, userId: string): Promise<TaskItem[]> {
    const uid = userId.length > 0 ? userId : TaskBizService.userId()
    if (uid.length === 0 || q.trim().length === 0) {
      return []
    }
    const path = `/biz/task-efficiency/search?q=${encodeURIComponent(q.trim())}&userId=${encodeURIComponent(uid)}`
    const res = await HttpClient.get<TaskListPayload>(path)
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return TaskBizService.mapItems(res.data.list)
    }
    return []
  }

  static async loadCompleted(userId: string): Promise<TaskItem[]> {
    const uid = userId.length > 0 ? userId : TaskBizService.userId()
    if (uid.length === 0) {
      return []
    }
    const res = await HttpClient.get<TaskListPayload>(
      `/biz/task-efficiency/completed?userId=${encodeURIComponent(uid)}`
    )
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return TaskBizService.mapItems(res.data.list)
    }
    return []
  }

  static async loadStats(userId: string): Promise<StatsData> {
    const uid = userId.length > 0 ? userId : TaskBizService.userId()
    let path = '/biz/task-efficiency/stats'
    if (uid.length > 0) {
      path += `?userId=${encodeURIComponent(uid)}`
    }
    const res = await HttpClient.get<StatsData>(path)
    if (res.code === 0 && res.data !== undefined) {
      return res.data
    }
    return new StatsData()
  }

  static async loadKpis(): Promise<KpiItem[]> {
    const res = await HttpClient.get<KpiListPayload>('/biz/task-efficiency/kpis')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      return res.data.list
    }
    return []
  }

  static async loadMessages(): Promise<MessageItem[]> {
    const res = await HttpClient.get<TaskListPayload>('/biz/task-efficiency/messages')
    if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
      const out: MessageItem[] = []
      for (const w of res.data.list) {
        out.push(MessageItem.fromWire(w))
      }
      return out
    }
    return []
  }
}
