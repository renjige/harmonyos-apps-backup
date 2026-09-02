import { TaskItem } from '../models/TaskModels'

/** 列表点击时缓存事项，详情页即时展示并后台刷新 */
export class TaskDetailCache {
  private static preview: TaskItem | undefined = undefined

  static save(item: TaskItem): void {
    const copy = new TaskItem()
    copy.id = item.id
    copy.title = item.title
    copy.subtitle = item.subtitle
    copy.status = item.status
    copy.summary = item.summary
    copy.body = item.body
    copy.description = item.description
    copy.coverKey = item.coverKey
    copy.category = item.category
    copy.categoryId = item.categoryId
    copy.color = item.color
    copy.priority = item.priority
    copy.dueDate = item.dueDate
    copy.dueTime = item.dueTime
    copy.tags = [...item.tags]
    copy.userId = item.userId
    copy.completedAt = item.completedAt
    copy.createdAt = item.createdAt
    copy.timeSlot = item.timeSlot
    copy.lane = item.lane
    copy.focusSeconds = item.focusSeconds
    copy.focusReady = item.focusReady
    copy.closeReason = item.closeReason
    TaskDetailCache.preview = copy
  }

  static peek(id: string): TaskItem | undefined {
    if (TaskDetailCache.preview !== undefined && TaskDetailCache.preview.id === id) {
      return TaskDetailCache.preview
    }
    return undefined
  }

  static clear(): void {
    TaskDetailCache.preview = undefined
  }
}
