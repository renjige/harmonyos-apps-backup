/** 事项效率 — 平台 /biz/task-efficiency Wire 模型（ArkTS strict） */

export class TaskItemWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  category: string = ''
  categoryId: string = ''
  color: string = ''
  priority: string = ''
  dueDate: string = ''
  dueTime: string = ''
  tags: string[] = []
  userId: string = ''
  habitId: string = ''
  logDate: string = ''
  completedAt: string = ''
  streakDays: number = 0
  targetDays: number = 0
  iconKey: string = ''
  sortOrder: number = 0
  readMinutes: number = 0
  createdAt: string = ''
  updatedAt: string = ''
  timeSlot: string = ''
  lane: string = ''
  focusSeconds: number = 0
  focusReady: boolean = false
  closeReason: string = ''
}

export class TaskItem {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  category: string = ''
  categoryId: string = ''
  color: string = ''
  priority: string = ''
  dueDate: string = ''
  dueTime: string = ''
  tags: string[] = []
  userId: string = ''
  habitId: string = ''
  logDate: string = ''
  completedAt: string = ''
  streakDays: number = 0
  targetDays: number = 0
  iconKey: string = ''
  readMinutes: number = 0
  createdAt: string = ''
  timeSlot: string = ''
  lane: string = ''
  focusSeconds: number = 0
  focusReady: boolean = false
  closeReason: string = ''

  static fromWire(w: TaskItemWire): TaskItem {
    const item = new TaskItem()
    item.id = w.id ?? ''
    item.title = w.title ?? ''
    item.subtitle = w.subtitle ?? ''
    item.status = w.status ?? ''
    item.summary = w.summary ?? ''
    item.body = w.body ?? ''
    item.description = w.description ?? ''
    const coverKey = w.coverKey ?? ''
    if (coverKey.length > 0) {
      item.coverKey = coverKey
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      item.coverKey = w.coverMedia
    }
    item.category = w.category ?? ''
    item.categoryId = w.categoryId ?? ''
    item.color = w.color ?? ''
    item.priority = w.priority ?? 'medium'
    item.dueDate = w.dueDate ?? ''
    item.dueTime = w.dueTime ?? ''
    item.tags = w.tags ?? []
    item.userId = w.userId ?? ''
    item.habitId = w.habitId ?? ''
    item.logDate = w.logDate ?? ''
    item.completedAt = w.completedAt ?? ''
    item.streakDays = w.streakDays ?? 0
    item.targetDays = w.targetDays ?? 0
    item.iconKey = w.iconKey ?? ''
    item.readMinutes = w.readMinutes ?? 0
    item.createdAt = w.createdAt ?? ''
    item.timeSlot = w.timeSlot ?? ''
    item.lane = w.lane ?? ''
    item.focusSeconds = w.focusSeconds ?? 0
    item.focusReady = w.focusReady === true
    item.closeReason = w.closeReason ?? ''
    return item
  }

  isDone(): boolean {
    return this.status === 'done'
  }

  isCommitment(): boolean {
    return this.lane === 'commitment'
  }

  isWaitlist(): boolean {
    return this.lane !== 'commitment'
  }

  slotLabel(): string {
    if (this.timeSlot === 'afternoon') {
      return '午后'
    }
    if (this.timeSlot === 'evening') {
      return '晚间'
    }
    if (this.timeSlot === 'morning') {
      return '上午'
    }
    return '未排期'
  }

  laneLabel(): string {
    return this.isCommitment() ? '今日承诺' : '候补池'
  }

  priorityLabel(): string {
    if (this.priority === 'high') {
      return '高'
    }
    if (this.priority === 'low') {
      return '低'
    }
    return '中'
  }
}

export class TaskListPayload {
  list: TaskItemWire[] = []
}

export class CategoryItem {
  id: string = ''
  title: string = ''
  color: string = ''
  summary: string = ''

  static fromWire(w: TaskItemWire): CategoryItem {
    const item = new CategoryItem()
    item.id = w.id
    item.title = w.title
    item.color = w.color ?? '#2563EB'
    item.summary = w.summary ?? ''
    return item
  }
}

export class TagPresetItem {
  id: string = ''
  title: string = ''
  color: string = ''

  static fromWire(w: TaskItemWire): TagPresetItem {
    const item = new TagPresetItem()
    item.id = w.id
    item.title = w.title
    item.color = w.color ?? '#2563EB'
    return item
  }
}

export class StatsData {
  todayTotal: number = 0
  todayDone: number = 0
  completionRate: number = 0
  totalDone: number = 0
  totalTasks: number = 0
  habitCount: number = 0
  checkInToday: number = 0
}

export class KpiItem {
  label: string = ''
  value: string = ''
  trend: string = ''
}

export class KpiListPayload {
  list: KpiItem[] = []
}

export class MessageItem {
  id: string = ''
  title: string = ''
  body: string = ''
  createdAt: string = ''

  static fromWire(w: TaskItemWire): MessageItem {
    const m = new MessageItem()
    m.id = w.id
    m.title = w.title
    m.body = w.body ?? w.summary ?? w.description ?? ''
    m.createdAt = w.createdAt ?? ''
    return m
  }
}

export class CreateTaskRequest {
  title: string = ''
  summary: string = ''
  description: string = ''
  priority: string = 'medium'
  dueDate: string = ''
  dueTime: string = ''
  category: string = ''
  categoryId: string = ''
  tags: string[] = []
  userId: string = ''
  timeSlot: string = 'morning'
  lane: string = 'commitment'
  wantCommitment: boolean = true

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"summary":${JSON.stringify(this.summary)},"description":${JSON.stringify(this.description)},"priority":${JSON.stringify(this.priority)},"dueDate":${JSON.stringify(this.dueDate)},"dueTime":${JSON.stringify(this.dueTime)},"category":${JSON.stringify(this.category)},"categoryId":${JSON.stringify(this.categoryId)},"tags":${JSON.stringify(this.tags)},"userId":${JSON.stringify(this.userId)},"timeSlot":${JSON.stringify(this.timeSlot)},"lane":${JSON.stringify(this.lane)},"wantCommitment":${this.wantCommitment}}`
  }
}

export class UpdateTaskRequest {
  title: string = ''
  summary: string = ''
  description: string = ''
  priority: string = ''
  dueDate: string = ''
  dueTime: string = ''
  category: string = ''
  categoryId: string = ''
  tags: string[] = []
  userId: string = ''
  timeSlot: string = ''
  lane: string = ''
  closeReason: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"summary":${JSON.stringify(this.summary)},"description":${JSON.stringify(this.description)},"priority":${JSON.stringify(this.priority)},"dueDate":${JSON.stringify(this.dueDate)},"dueTime":${JSON.stringify(this.dueTime)},"category":${JSON.stringify(this.category)},"categoryId":${JSON.stringify(this.categoryId)},"tags":${JSON.stringify(this.tags)},"userId":${JSON.stringify(this.userId)},"timeSlot":${JSON.stringify(this.timeSlot)},"lane":${JSON.stringify(this.lane)},"closeReason":${JSON.stringify(this.closeReason)}}`
  }
}

export class PatchTaskStatusRequest {
  status: string = 'done'
  userId: string = ''

  toJsonString(): string {
    return `{"status":${JSON.stringify(this.status)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class FocusSessionRequest {
  seconds: number = 60
  userId: string = ''

  toJsonString(): string {
    return `{"seconds":${this.seconds},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateHabitRequest {
  title: string = ''
  description: string = ''
  targetDays: number = 21
  iconKey: string = 'check'
  userId: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"description":${JSON.stringify(this.description)},"targetDays":${this.targetDays},"iconKey":${JSON.stringify(this.iconKey)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class CreateHabitLogRequest {
  habitId: string = ''
  userId: string = ''
  logDate: string = ''

  toJsonString(): string {
    return `{"habitId":${JSON.stringify(this.habitId)},"userId":${JSON.stringify(this.userId)},"logDate":${JSON.stringify(this.logDate)}}`
  }
}
