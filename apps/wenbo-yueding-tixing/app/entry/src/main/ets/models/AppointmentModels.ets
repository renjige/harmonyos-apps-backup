/** 约定提醒 — 平台 /biz/task-efficiency Wire 与本地模型（ArkTS strict） */

export class AppointmentWire {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  status: string = ''
  summary: string = ''
  body: string = ''
  description: string = ''
  coverKey: string = ''
  coverMedia: string = ''
  dueDate: string = ''
  dueTime: string = ''
  itemDate: string = ''
  startTime: string = ''
  reminderType: string = ''
  remindAt: string = ''
  note: string = ''
  templateId: string = ''
  tags: string[] = []
  userId: string = ''
  completedAt: string = ''
  createdAt: string = ''
  updatedAt: string = ''
  category: string = ''
  priority: string = ''
  location: string = ''
}

export class AppointmentItem {
  id: string = ''
  title: string = ''
  status: string = 'pending'
  dueDate: string = ''
  dueTime: string = ''
  note: string = ''
  /** once | daily | weekly | monthly */
  repeatType: string = 'once'
  remindBeforeKey: string = '60'
  remindBeforeMinutes: number = 60
  remindAt: string = ''
  templateId: string = ''
  userId: string = ''
  createdAt: string = ''
  updatedAt: string = ''
  place: string = ''
  /** work | life | study | health */
  scene: string = 'life'
  durationMin: number = 60
  /** normal | high */
  priority: string = 'normal'
  pinned: boolean = false
  prepLine: string = ''
  prepMask: string = ''
  followUp: string = ''
  /** 相关人 / 参与方 */
  contactName: string = ''
  /** 预留路上分钟数 */
  bufferMin: number = 0
  allDay: boolean = false
  checkedIn: boolean = false
  favorite: boolean = false
  tagIds: string[] = []
  collectionIds: string[] = []
  planId: string = ''

  static fromWire(w: AppointmentWire): AppointmentItem {
    const item = new AppointmentItem()
    item.id = w.id ?? ''
    item.title = w.title ?? ''
    item.status = w.status ?? 'pending'
    const date = w.dueDate ?? w.itemDate ?? ''
    item.dueDate = date
    const time = w.dueTime ?? w.startTime ?? ''
    item.dueTime = time
    item.note = w.note ?? w.description ?? ''
    item.repeatType = w.reminderType ?? 'once'
    item.remindAt = w.remindAt ?? ''
    item.templateId = w.templateId ?? ''
    item.userId = w.userId ?? ''
    item.createdAt = w.createdAt ?? ''
    item.updatedAt = w.updatedAt ?? ''
    item.place = w.location ?? ''
    item.scene = w.category ?? 'life'
    item.priority = w.priority === 'high' ? 'high' : 'normal'
    item.followUp = w.body ?? ''
    AppointmentItem.applyTags(item, AppointmentItem.safeTags(w.tags))
    return item
  }

  static applyTags(item: AppointmentItem, tags: string[]): void {
    const prepNames: string[] = []
    for (const tag of tags) {
      if (tag.startsWith('before:')) {
        const raw = tag.slice(7)
        if (raw.startsWith('custom:')) {
          item.remindBeforeKey = 'custom'
          const mins = parseInt(raw.slice(7), 10)
          item.remindBeforeMinutes = Number.isNaN(mins) ? 60 : mins
        } else {
          item.remindBeforeKey = raw
          item.remindBeforeMinutes = AppointmentItem.minutesFromKey(raw)
        }
      } else if (tag.startsWith('scene:')) {
        item.scene = tag.slice(6)
      } else if (tag.startsWith('dur:')) {
        const d = parseInt(tag.slice(4), 10)
        item.durationMin = Number.isNaN(d) ? 60 : d
      } else if (tag === 'pin:1') {
        item.pinned = true
      } else if (tag.startsWith('loc:') && item.place.length === 0) {
        item.place = tag.slice(4)
      } else if (tag.startsWith('plist:')) {
        item.prepLine = tag.slice(6)
      } else if (tag.startsWith('pmask:')) {
        item.prepMask = tag.slice(6)
      } else if (tag.startsWith('follow:') && item.followUp.length === 0) {
        item.followUp = tag.slice(7)
      } else if (tag.startsWith('who:') && item.contactName.length === 0) {
        item.contactName = tag.slice(4)
      } else if (tag.startsWith('buf:')) {
        const b = parseInt(tag.slice(4), 10)
        item.bufferMin = Number.isNaN(b) ? 0 : b
      } else if (tag === 'allday:1') {
        item.allDay = true
      } else if (tag === 'in:1') {
        item.checkedIn = true
      } else if (tag === 'fav:1') {
        item.favorite = true
      } else if (tag.startsWith('utag:')) {
        item.tagIds.push(tag.slice(5))
      } else if (tag.startsWith('col:')) {
        item.collectionIds.push(tag.slice(4))
      } else if (tag.startsWith('plan:')) {
        item.planId = tag.slice(5)
      }
      if (tag.startsWith('prep:')) {
        prepNames.push(tag.slice(5))
      }
    }
    if (item.prepLine.length === 0 && prepNames.length > 0) {
      let line = ''
      for (let i = 0; i < prepNames.length; i++) {
        line = i === 0 ? prepNames[i] : `${line}|${prepNames[i]}`
      }
      item.prepLine = line
    }
  }

  static minutesFromKey(key: string): number {
    if (key === '10') {
      return 10
    }
    if (key === '60') {
      return 60
    }
    if (key === '1440') {
      return 1440
    }
    return 60
  }

  static tagsFromItem(item: AppointmentItem): string[] {
    const tags: string[] = []
    if (item.remindBeforeKey === 'custom') {
      tags.push(`before:custom:${item.remindBeforeMinutes}`)
    } else {
      tags.push(`before:${item.remindBeforeKey}`)
    }
    tags.push(`scene:${item.scene}`)
    tags.push(`dur:${item.durationMin}`)
    if (item.pinned) {
      tags.push('pin:1')
    }
    if (item.place.length > 0) {
      tags.push(`loc:${item.place}`)
    }
    if (item.prepLine.length > 0) {
      tags.push(`plist:${item.prepLine}`)
    }
    if (item.prepMask.length > 0) {
      tags.push(`pmask:${item.prepMask}`)
    }
    if (item.followUp.length > 0) {
      tags.push(`follow:${item.followUp}`)
    }
    if (item.contactName.length > 0) {
      tags.push(`who:${item.contactName}`)
    }
    if (item.bufferMin > 0) {
      tags.push(`buf:${item.bufferMin}`)
    }
    if (item.allDay) {
      tags.push('allday:1')
    }
    if (item.checkedIn) {
      tags.push('in:1')
    }
    if (item.favorite) {
      tags.push('fav:1')
    }
    for (const tid of item.tagIds) {
      tags.push(`utag:${tid}`)
    }
    for (const cid of item.collectionIds) {
      tags.push(`col:${cid}`)
    }
    if (item.planId.length > 0) {
      tags.push(`plan:${item.planId}`)
    }
    return tags
  }

  isDone(): boolean {
    return this.status === 'done'
  }

  isImportant(): boolean {
    return this.priority === 'high'
  }

  dateTimeLabel(): string {
    if (this.dueDate.length === 0) {
      return '未设日期'
    }
    if (this.dueTime.length > 0) {
      return `${this.dueDate} ${this.dueTime}`
    }
    return this.dueDate
  }

  timeRangeLabel(): string {
    if (this.allDay) {
      return '全天'
    }
    if (this.dueTime.length === 0) {
      return '未设时间'
    }
    return `${this.dueTime} · ${this.durationMin} 分钟`
  }

  repeatLabel(): string {
    if (this.repeatType === 'daily') {
      return '每天'
    }
    if (this.repeatType === 'weekly') {
      return '每周'
    }
    if (this.repeatType === 'monthly') {
      return '每月'
    }
    return '不重复'
  }

  remindBeforeLabel(): string {
    if (this.remindBeforeKey === '10') {
      return '提前 10 分钟'
    }
    if (this.remindBeforeKey === '60') {
      return '提前 1 小时'
    }
    if (this.remindBeforeKey === '1440') {
      return '提前 1 天'
    }
    return `提前 ${this.remindBeforeMinutes} 分钟`
  }

  sceneLabel(): string {
    if (this.scene === 'work') {
      return '工作'
    }
    if (this.scene === 'study') {
      return '学习'
    }
    if (this.scene === 'health') {
      return '健康'
    }
    return '生活'
  }

  static hydrate(raw: AppointmentItem): AppointmentItem {
    const item = new AppointmentItem()
    item.id = raw.id ?? ''
    item.title = raw.title ?? ''
    item.status = raw.status ?? 'pending'
    item.dueDate = raw.dueDate ?? ''
    item.dueTime = raw.dueTime ?? ''
    item.note = raw.note ?? ''
    item.repeatType = raw.repeatType ?? 'once'
    item.remindBeforeKey = raw.remindBeforeKey ?? '60'
    item.remindBeforeMinutes = raw.remindBeforeMinutes > 0 ? raw.remindBeforeMinutes : 60
    item.remindAt = raw.remindAt ?? ''
    item.templateId = raw.templateId ?? ''
    item.userId = raw.userId ?? ''
    item.createdAt = raw.createdAt ?? ''
    item.updatedAt = raw.updatedAt ?? ''
    item.place = raw.place ?? ''
    item.scene = raw.scene ?? 'life'
    item.durationMin = raw.durationMin > 0 ? raw.durationMin : 60
    item.priority = raw.priority === 'high' ? 'high' : 'normal'
    item.pinned = raw.pinned === true
    item.prepLine = raw.prepLine ?? ''
    item.prepMask = raw.prepMask ?? ''
    item.followUp = raw.followUp ?? ''
    item.contactName = raw.contactName ?? ''
    item.bufferMin = raw.bufferMin > 0 ? raw.bufferMin : 0
    item.allDay = raw.allDay === true
    item.checkedIn = raw.checkedIn === true
    item.favorite = raw.favorite === true
    item.tagIds = raw.tagIds !== undefined ? raw.tagIds : []
    item.collectionIds = raw.collectionIds !== undefined ? raw.collectionIds : []
    item.planId = raw.planId ?? ''
    return item
  }

  static safeTags(tags: string[] | undefined): string[] {
    if (tags === undefined) {
      return []
    }
    const out: string[] = []
    try {
      for (const tag of tags) {
        out.push(tag)
      }
    } catch {
      return out
    }
    return out
  }
}

export class PrepItem {
  name: string = ''
  done: boolean = false
  index: number = 0
}

export class AppointmentTemplate {
  id: string = ''
  title: string = ''
  subtitle: string = ''
  summary: string = ''
  body: string = ''
  coverKey: string = ''
  scene: string = 'life'
  durationMin: number = 60
  defaultTime: string = '09:00'
  prepLine: string = ''
  repeatType: string = 'once'
  remindBeforeKey: string = '60'

  static fromWire(w: AppointmentWire): AppointmentTemplate {
    const tpl = new AppointmentTemplate()
    tpl.id = w.id ?? ''
    tpl.title = w.title ?? ''
    tpl.subtitle = w.subtitle ?? ''
    tpl.summary = w.summary ?? ''
    tpl.body = w.body ?? w.description ?? ''
    const cover = w.coverKey ?? ''
    if (cover.length > 0) {
      tpl.coverKey = cover
    } else if (w.coverMedia !== undefined && w.coverMedia.length > 0) {
      tpl.coverKey = w.coverMedia
    }
    tpl.scene = w.category ?? 'life'
    const repeat = w.reminderType ?? 'once'
    tpl.repeatType = repeat === 'yearly' ? 'once' : repeat
    AppointmentTemplate.applyTags(tpl, AppointmentItem.safeTags(w.tags))
    return tpl
  }

  static applyTags(tpl: AppointmentTemplate, tags: string[]): void {
    for (const tag of tags) {
      if (tag.startsWith('dur:')) {
        const d = parseInt(tag.slice(4), 10)
        tpl.durationMin = Number.isNaN(d) ? 60 : d
      } else if (tag.startsWith('time:')) {
        tpl.defaultTime = tag.slice(5)
      } else if (tag.startsWith('plist:')) {
        tpl.prepLine = tag.slice(6)
      } else if (tag.startsWith('scene:')) {
        tpl.scene = tag.slice(6)
      } else if (tag.startsWith('before:')) {
        const raw = tag.slice(7)
        if (!raw.startsWith('custom:')) {
          tpl.remindBeforeKey = raw
        }
      }
    }
  }
}

export class AppointmentListPayload {
  list: AppointmentWire[] = []
}

export class LocalAppointmentBundle {
  items: AppointmentItem[] = []
}

export class CreateAppointmentRequest {
  title: string = ''
  summary: string = ''
  description: string = ''
  dueDate: string = ''
  dueTime: string = ''
  reminderType: string = 'once'
  remindAt: string = ''
  note: string = ''
  tags: string[] = []
  userId: string = ''
  category: string = 'life'
  priority: string = 'normal'
  location: string = ''
  body: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"summary":${JSON.stringify(this.summary)},` +
      `"description":${JSON.stringify(this.description)},"dueDate":${JSON.stringify(this.dueDate)},` +
      `"dueTime":${JSON.stringify(this.dueTime)},"reminderType":${JSON.stringify(this.reminderType)},` +
      `"remindAt":${JSON.stringify(this.remindAt)},"note":${JSON.stringify(this.note)},` +
      `"tags":${JSON.stringify(this.tags)},"userId":${JSON.stringify(this.userId)},` +
      `"category":${JSON.stringify(this.category)},"priority":${JSON.stringify(this.priority)},` +
      `"location":${JSON.stringify(this.location)},"body":${JSON.stringify(this.body)}}`
  }
}

export class UpdateAppointmentRequest {
  title: string = ''
  summary: string = ''
  description: string = ''
  dueDate: string = ''
  dueTime: string = ''
  reminderType: string = ''
  remindAt: string = ''
  note: string = ''
  tags: string[] = []
  userId: string = ''
  category: string = ''
  priority: string = ''
  location: string = ''
  body: string = ''
  status: string = ''

  toJsonString(): string {
    return `{"title":${JSON.stringify(this.title)},"summary":${JSON.stringify(this.summary)},` +
      `"description":${JSON.stringify(this.description)},"dueDate":${JSON.stringify(this.dueDate)},` +
      `"dueTime":${JSON.stringify(this.dueTime)},"reminderType":${JSON.stringify(this.reminderType)},` +
      `"remindAt":${JSON.stringify(this.remindAt)},"note":${JSON.stringify(this.note)},` +
      `"tags":${JSON.stringify(this.tags)},"userId":${JSON.stringify(this.userId)},` +
      `"category":${JSON.stringify(this.category)},"priority":${JSON.stringify(this.priority)},` +
      `"location":${JSON.stringify(this.location)},"body":${JSON.stringify(this.body)},` +
      `"status":${JSON.stringify(this.status)}}`
  }
}

export class PatchAppointmentStatusRequest {
  status: string = 'done'
  userId: string = ''

  toJsonString(): string {
    return `{"status":${JSON.stringify(this.status)},"userId":${JSON.stringify(this.userId)}}`
  }
}

export class AppointmentFormDraft {
  id: string = ''
  title: string = ''
  dueDate: string = ''
  dueTime: string = ''
  note: string = ''
  repeatType: string = 'once'
  remindBeforeKey: string = '60'
  customMinutes: string = '120'
  templateId: string = ''
  place: string = ''
  scene: string = 'life'
  durationMin: number = 60
  priority: string = 'normal'
  pinned: boolean = false
  prepLine: string = ''
  allowOverlap: boolean = false
  contactName: string = ''
  bufferMin: number = 0
  allDay: boolean = false
  planId: string = ''
}

export class FreeSlot {
  date: string = ''
  time: string = ''
  label: string = ''
}

export class MonthInsights {
  totalCount: number = 0
  doneCount: number = 0
  rateText: string = '—'
  streakDays: number = 0
  workCount: number = 0
  lifeCount: number = 0
  studyCount: number = 0
  healthCount: number = 0
  busiestHour: string = '暂无'
  repeatActive: number = 0
  suggestion: string = ''
}

export class WeekDigest {
  doneCount: number = 0
  totalCount: number = 0
  pendingCount: number = 0
  missedCount: number = 0
  conflictCount: number = 0
  rateText: string = '0%'
  busiestDay: string = '暂无'
  suggestion: string = ''
  workCount: number = 0
  lifeCount: number = 0
  studyCount: number = 0
  healthCount: number = 0
}

export class GapSlot {
  start: string = ''
  end: string = ''
  label: string = ''
}

export class NextHint {
  hasNext: boolean = false
  title: string = ''
  countdown: string = ''
  timeLabel: string = ''
  id: string = ''
}

export class ImportPreview {
  title: string = ''
  whenLabel: string = ''
  draft: AppointmentFormDraft = new AppointmentFormDraft()
}
