import { common } from '@kit.AbilityKit'
import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import { AppointmentLocalStore } from './AppointmentLocalStore'
import { NotificationService } from './NotificationService'
import { ScheduleEngine } from './ScheduleEngine'
import { AppointmentTools } from './AppointmentTools'
import { GrowthService } from './GrowthService'
import {
  AppointmentFormDraft,
  AppointmentItem,
  AppointmentListPayload,
  AppointmentTemplate,
  AppointmentWire,
  CreateAppointmentRequest,
  LocalAppointmentBundle,
  UpdateAppointmentRequest,
  WeekDigest,
  MonthInsights,
  FreeSlot,
  ImportPreview
} from '../models/AppointmentModels'
import { EmptyPayload } from '../models/ApiModels'

const BASE = '/biz/task-efficiency'

export class AppointmentService {
  static lastError: string = ''
  static lastConflictTitle: string = ''

  static actorId(): string {
    const name = AppStorage.get<string>('currentUsername') ?? ''
    if (name.length > 0) {
      return name
    }
    return 'local'
  }

  private static mapItems(wires: AppointmentWire[]): AppointmentItem[] {
    const out: AppointmentItem[] = []
    for (const w of wires) {
      out.push(AppointmentItem.fromWire(w))
    }
    return out
  }

  static async templates(): Promise<AppointmentTemplate[]> {
    const res = await HttpClient.get<AppointmentListPayload>(`${BASE}/tips`)
    if (res.code !== 0 || res.data === undefined) {
      return []
    }
    const list = res.data.list
    if (list === undefined) {
      return []
    }
    const out: AppointmentTemplate[] = []
    for (const w of list) {
      out.push(AppointmentTemplate.fromWire(w))
    }
    return out
  }

  static async listAll(): Promise<AppointmentItem[]> {
    if (AuthService.isLoggedIn()) {
      const uid = AppointmentService.actorId()
      const res = await HttpClient.get<AppointmentListPayload>(
        `${BASE}/tasks?userId=${encodeURIComponent(uid)}`
      )
      if (res.code === 0 && res.data !== undefined && res.data.list !== undefined) {
        const remote = AppointmentService.mapItems(res.data.list)
        if (remote.length > 0) {
          return ScheduleEngine.sortPinned(AppointmentService.sortByDateTime(remote))
        }
      }
    }
    const local: AppointmentItem[] = []
    for (const row of AppointmentLocalStore.items()) {
      local.push(AppointmentItem.hydrate(row))
    }
    return ScheduleEngine.sortPinned(AppointmentService.sortByDateTime(local))
  }

  static async findById(id: string): Promise<AppointmentItem | undefined> {
    if (AuthService.isLoggedIn()) {
      const uid = AppointmentService.actorId()
      const res = await HttpClient.get<AppointmentWire>(
        `${BASE}/tasks/${id}?userId=${encodeURIComponent(uid)}`
      )
      if (res.code === 0 && res.data !== undefined) {
        return AppointmentItem.fromWire(res.data)
      }
    }
    for (const row of AppointmentLocalStore.items()) {
      if (row.id === id) {
        return row
      }
    }
    return undefined
  }

  static async listToday(): Promise<AppointmentItem[]> {
    const today = AppointmentLocalStore.today()
    const all = await AppointmentService.listAll()
    const out: AppointmentItem[] = []
    for (const row of all) {
      if (row.dueDate === today && !row.isDone()) {
        out.push(row)
      }
    }
    return out
  }

  static async listTodayAll(): Promise<AppointmentItem[]> {
    const today = AppointmentLocalStore.today()
    const all = await AppointmentService.listAll()
    const out: AppointmentItem[] = []
    for (const row of all) {
      if (row.dueDate === today) {
        out.push(row)
      }
    }
    return out
  }

  static async listFuture(): Promise<AppointmentItem[]> {
    const today = AppointmentLocalStore.today()
    const all = await AppointmentService.listAll()
    const out: AppointmentItem[] = []
    for (const row of all) {
      if (!row.isDone() && row.dueDate >= today) {
        out.push(row)
      }
    }
    return out
  }

  static async listDone(): Promise<AppointmentItem[]> {
    const all = await AppointmentService.listAll()
    const out: AppointmentItem[] = []
    for (const row of all) {
      if (row.isDone()) {
        out.push(row)
      }
    }
    return out
  }

  static async listByDate(iso: string): Promise<AppointmentItem[]> {
    const all = await AppointmentService.listAll()
    const out: AppointmentItem[] = []
    for (const row of all) {
      if (row.dueDate === iso) {
        out.push(row)
      }
    }
    return out
  }

  static async weekDigest(): Promise<WeekDigest> {
    return ScheduleEngine.digest(await AppointmentService.listAll())
  }

  static async monthInsights(): Promise<MonthInsights> {
    return ScheduleEngine.monthInsights(await AppointmentService.listAll())
  }

  static async conflictSlots(draft: AppointmentFormDraft): Promise<FreeSlot[]> {
    const item = AppointmentService.itemFromDraft(draft)
    const all = await AppointmentService.listAll()
    return ScheduleEngine.suggestFreeSlots(item, all, 3)
  }

  static draftFromItem(item: AppointmentItem): AppointmentFormDraft {
    const draft = new AppointmentFormDraft()
    draft.id = item.id
    draft.title = item.title
    draft.dueDate = item.dueDate
    draft.dueTime = item.dueTime
    draft.note = item.note
    draft.repeatType = item.repeatType
    draft.remindBeforeKey = item.remindBeforeKey
    draft.customMinutes = `${item.remindBeforeMinutes}`
    draft.templateId = item.templateId
    draft.place = item.place
    draft.scene = item.scene
    draft.durationMin = item.durationMin
    draft.priority = item.priority
    draft.pinned = item.pinned
    draft.prepLine = item.prepLine
    draft.contactName = item.contactName
    draft.bufferMin = item.bufferMin
    draft.allDay = item.allDay
    draft.planId = item.planId
    return draft
  }

  static itemFromDraft(draft: AppointmentFormDraft): AppointmentItem {
    const item = new AppointmentItem()
    item.id = draft.id
    item.title = draft.title.trim()
    item.dueDate = draft.dueDate
    item.dueTime = draft.dueTime
    item.note = draft.note.trim()
    item.repeatType = draft.repeatType
    item.remindBeforeKey = draft.remindBeforeKey
    if (draft.remindBeforeKey === 'custom') {
      const mins = parseInt(draft.customMinutes, 10)
      item.remindBeforeMinutes = Number.isNaN(mins) ? 60 : mins
    } else {
      item.remindBeforeMinutes = AppointmentItem.minutesFromKey(draft.remindBeforeKey)
    }
    item.templateId = draft.templateId
    item.userId = AppointmentService.actorId()
    item.status = 'pending'
    item.place = draft.place.trim()
    item.scene = draft.scene.length > 0 ? draft.scene : ScheduleEngine.classifyScene(item.title, item.note)
    item.durationMin = draft.durationMin > 0 ? draft.durationMin : 60
    item.priority = draft.priority
    item.pinned = draft.pinned
    item.prepLine = draft.prepLine.length > 0 ? draft.prepLine : ScheduleEngine.defaultPrep(item.scene)
    item.prepMask = ''
    item.contactName = draft.contactName.trim()
    item.bufferMin = draft.bufferMin > 0 ? draft.bufferMin : 0
    item.allDay = draft.allDay
    item.planId = draft.planId.length > 0 ? draft.planId : item.planId
    if (draft.allDay && item.dueTime.length === 0) {
      item.dueTime = '09:00'
    }
    item.remindAt = NotificationService.computeRemindAt(item)
    return item
  }

  static async saveDraft(draft: AppointmentFormDraft, context: common.UIAbilityContext): Promise<AppointmentItem | undefined> {
    AppointmentService.lastError = ''
    AppointmentService.lastConflictTitle = ''
    if (draft.title.trim().length === 0) {
      AppointmentService.lastError = '请填写约定标题'
      return undefined
    }
    if (draft.dueDate.length === 0) {
      AppointmentService.lastError = '请选择日期'
      return undefined
    }
    const isNew = draft.id.length === 0
    const item = AppointmentService.itemFromDraft(draft)
    if (!draft.allowOverlap && !item.allDay) {
      const all = await AppointmentService.listAll()
      const conflicts = ScheduleEngine.conflictsOf(item, all)
      if (conflicts.length > 0) {
        AppointmentService.lastConflictTitle = conflicts[0].title
        AppointmentService.lastError = `与「${conflicts[0].title}」时间重叠，再点一次仍可保存`
        return undefined
      }
    }
    if (AuthService.isLoggedIn()) {
      const saved = await AppointmentService.saveRemote(item, isNew)
      if (saved !== undefined) {
        void NotificationService.scheduleForAppointment(saved, context)
        await AppointmentLocalStore.rememberFav(saved.place, saved.contactName)
        if (isNew) {
          await GrowthService.onAppointmentCreated(saved)
        }
        return saved
      }
    }
    const savedLocal = await AppointmentService.saveLocal(item, isNew)
    if (savedLocal !== undefined) {
      void NotificationService.scheduleForAppointment(savedLocal, context)
      await AppointmentLocalStore.rememberFav(savedLocal.place, savedLocal.contactName)
      if (isNew) {
        await GrowthService.onAppointmentCreated(savedLocal)
      }
    }
    return savedLocal
  }

  private static fillUpdate(item: AppointmentItem): UpdateAppointmentRequest {
    const update = new UpdateAppointmentRequest()
    update.title = item.title
    update.summary = item.note
    update.description = item.note
    update.dueDate = item.dueDate
    update.dueTime = item.dueTime
    update.reminderType = item.repeatType
    update.remindAt = item.remindAt
    update.note = item.note
    update.tags = AppointmentItem.tagsFromItem(item)
    update.userId = AppointmentService.actorId()
    update.category = item.scene
    update.priority = item.priority
    update.location = item.place
    update.body = item.followUp
    update.status = item.status
    return update
  }

  private static async saveRemote(item: AppointmentItem, isNew: boolean): Promise<AppointmentItem | undefined> {
    const tags = AppointmentItem.tagsFromItem(item)
    if (isNew) {
      const body = new CreateAppointmentRequest()
      body.title = item.title
      body.summary = item.note
      body.description = item.note
      body.dueDate = item.dueDate
      body.dueTime = item.dueTime
      body.reminderType = item.repeatType
      body.remindAt = item.remindAt
      body.note = item.note
      body.tags = tags
      body.userId = AppointmentService.actorId()
      body.category = item.scene
      body.priority = item.priority
      body.location = item.place
      body.body = item.followUp
      const res = await HttpClient.post<AppointmentWire>(`${BASE}/tasks`, body)
      if (res.code === 0 && res.data !== undefined) {
        return AppointmentItem.fromWire(res.data)
      }
      AppointmentService.lastError = res.message.length > 0 ? res.message : '创建失败'
      return undefined
    }
    const update = AppointmentService.fillUpdate(item)
    const res = await HttpClient.put<AppointmentWire>(`${BASE}/tasks/${item.id}`, update)
    if (res.code === 0 && res.data !== undefined) {
      return AppointmentItem.fromWire(res.data)
    }
    AppointmentService.lastError = res.message.length > 0 ? res.message : '保存失败'
    return undefined
  }

  private static async saveLocal(item: AppointmentItem, isNew: boolean): Promise<AppointmentItem | undefined> {
    const bundle = AppointmentLocalStore.snapshot()
    const saved = AppointmentService.cloneItem(item)
    saved.userId = AppointmentService.actorId()
    saved.updatedAt = AppointmentLocalStore.nowIso()
    if (isNew) {
      saved.id = AppointmentLocalStore.newId('appt')
      saved.createdAt = saved.updatedAt
    } else if (saved.id.length === 0) {
      return undefined
    }
    const items: AppointmentItem[] = []
    let found = false
    for (const row of bundle.items) {
      if (!isNew && row.id === saved.id) {
        items.push(saved)
        found = true
      } else {
        items.push(row)
      }
    }
    if (isNew) {
      items.unshift(saved)
    } else if (!found) {
      items.unshift(saved)
    }
    const next = new LocalAppointmentBundle()
    next.items = items
    await AppointmentLocalStore.saveBundle(next)
    return saved
  }

  static async persistItem(item: AppointmentItem, context: common.UIAbilityContext): Promise<boolean> {
    item.remindAt = NotificationService.computeRemindAt(item)
    if (AuthService.isLoggedIn()) {
      const saved = await AppointmentService.saveRemote(item, false)
      if (saved === undefined) {
        return false
      }
      void NotificationService.scheduleForAppointment(saved, context)
      return true
    }
    const saved = await AppointmentService.saveLocal(item, false)
    if (saved === undefined) {
      return false
    }
    void NotificationService.scheduleForAppointment(saved, context)
    return true
  }

  static async postpone(id: string, addMin: number, context: common.UIAbilityContext): Promise<boolean> {
    const item = await AppointmentService.findById(id)
    if (item === undefined) {
      AppointmentService.lastError = '约定不存在'
      return false
    }
    const shifted = ScheduleEngine.shift(item.dueDate, item.dueTime, addMin)
    item.dueDate = shifted.dueDate
    item.dueTime = shifted.dueTime
    return AppointmentService.persistItem(item, context)
  }

  static async togglePin(id: string, context: common.UIAbilityContext): Promise<boolean> {
    const item = await AppointmentService.findById(id)
    if (item === undefined) {
      return false
    }
    item.pinned = !item.pinned
    return AppointmentService.persistItem(item, context)
  }

  static async togglePrep(id: string, index: number, context: common.UIAbilityContext): Promise<AppointmentItem | undefined> {
    const item = await AppointmentService.findById(id)
    if (item === undefined) {
      return undefined
    }
    const names = item.prepLine.split('|')
    item.prepMask = ScheduleEngine.toggleMask(item.prepMask, index, names.length)
    const ok = await AppointmentService.persistItem(item, context)
    return ok ? item : undefined
  }

  static async complete(id: string, context: common.UIAbilityContext, followUp: string = ''): Promise<boolean> {
    AppointmentService.lastError = ''
    const before = await AppointmentService.findById(id)
    if (before === undefined) {
      AppointmentService.lastError = '约定不存在'
      return false
    }
    if (followUp.length > 0) {
      before.followUp = followUp
    }
    before.status = 'done'
    const ok = await AppointmentService.persistItem(before, context)
    if (ok) {
      await NotificationService.cancelForAppointment(id)
      await AppointmentService.spawnNextOccurrence(before, context)
      await GrowthService.onAppointmentCompleted(before)
    }
    return ok
  }

  private static async spawnNextOccurrence(source: AppointmentItem, context: common.UIAbilityContext): Promise<void> {
    if (source.repeatType === 'once') {
      return
    }
    const draft = AppointmentService.draftFromItem(source)
    draft.id = ''
    draft.dueDate = ScheduleEngine.nextRepeatDate(source.dueDate, source.repeatType)
    draft.allowOverlap = false
    draft.pinned = false
    draft.prepLine = source.prepLine
    void AppointmentService.saveDraft(draft, context)
  }

  static async reopen(id: string, context: common.UIAbilityContext): Promise<boolean> {
    const item = await AppointmentService.findById(id)
    if (item === undefined) {
      return false
    }
    item.status = 'pending'
    return AppointmentService.persistItem(item, context)
  }

  static async remove(id: string): Promise<boolean> {
    AppointmentService.lastError = ''
    if (AuthService.isLoggedIn()) {
      const uid = AppointmentService.actorId()
      const path = `${BASE}/tasks/${id}?userId=${encodeURIComponent(uid)}`
      const res = await HttpClient.delete<EmptyPayload>(path)
      if (res.code === 0) {
        await NotificationService.cancelForAppointment(id)
        return true
      }
      AppointmentService.lastError = res.message.length > 0 ? res.message : '删除失败'
      return false
    }
    const bundle = AppointmentLocalStore.snapshot()
    const items: AppointmentItem[] = []
    let removed = false
    for (const row of bundle.items) {
      if (row.id === id) {
        removed = true
      } else {
        items.push(row)
      }
    }
    if (!removed) {
      return false
    }
    const next = new LocalAppointmentBundle()
    next.items = items
    await AppointmentLocalStore.saveBundle(next)
    await NotificationService.cancelForAppointment(id)
    return true
  }

  static shareText(item: AppointmentItem): string {
    let text = `【约定提醒】${item.title}\n`
    text = `${text}时间：${item.dateTimeLabel()}（${item.durationMin}分钟）\n`
    text = `${text}场景：${item.sceneLabel()} · ${item.remindBeforeLabel()} · ${item.repeatLabel()}\n`
    if (item.place.length > 0) {
      text = `${text}地点：${item.place}\n`
    }
    if (item.contactName.length > 0) {
      text = `${text}相关人：${item.contactName}\n`
    }
    const leave = ScheduleEngine.leaveByLabel(item)
    if (leave.length > 0) {
      text = `${text}${leave}\n`
    }
    if (item.note.length > 0) {
      text = `${text}备注：${item.note}\n`
    }
    const prep = ScheduleEngine.prepProgress(item)
    if (prep.length > 0) {
      text = `${text}${prep}\n`
    }
    return text
  }

  static draftFromTemplate(tpl: AppointmentTemplate, overrides: AppointmentFormDraft | undefined = undefined): AppointmentFormDraft {
    const draft = new AppointmentFormDraft()
    draft.title = tpl.title
    draft.dueDate = AppointmentLocalStore.today()
    draft.dueTime = tpl.defaultTime.length > 0 ? tpl.defaultTime : '09:00'
    draft.note = tpl.summary.length > 0 ? tpl.summary : tpl.body
    draft.templateId = tpl.id
    draft.scene = tpl.scene.length > 0 ? tpl.scene : ScheduleEngine.classifyScene(tpl.title, tpl.body)
    draft.durationMin = tpl.durationMin > 0 ? tpl.durationMin : 60
    draft.prepLine = tpl.prepLine.length > 0 ? tpl.prepLine : ScheduleEngine.defaultPrep(draft.scene)
    draft.repeatType = tpl.repeatType.length > 0 ? tpl.repeatType : 'once'
    draft.remindBeforeKey = tpl.remindBeforeKey.length > 0 ? tpl.remindBeforeKey : '60'
    if (overrides !== undefined) {
      if (overrides.title.trim().length > 0) {
        draft.title = overrides.title.trim()
      }
      if (overrides.dueDate.length > 0) {
        draft.dueDate = overrides.dueDate
      }
      if (overrides.dueTime.length > 0) {
        draft.dueTime = overrides.dueTime
      }
      if (overrides.contactName.length > 0) {
        draft.contactName = overrides.contactName
      }
      if (overrides.prepLine.length > 0) {
        draft.prepLine = overrides.prepLine
      }
      if (overrides.durationMin > 0) {
        draft.durationMin = overrides.durationMin
      }
      if (overrides.bufferMin > 0) {
        draft.bufferMin = overrides.bufferMin
      }
    }
    return draft
  }

  static async createFromTemplate(tpl: AppointmentTemplate, context: common.UIAbilityContext): Promise<AppointmentItem | undefined> {
    const draft = AppointmentService.draftFromTemplate(tpl)
    return AppointmentService.saveDraft(draft, context)
  }

  static async createFromTemplateDraft(draft: AppointmentFormDraft, context: common.UIAbilityContext): Promise<AppointmentItem | undefined> {
    return AppointmentService.saveDraft(draft, context)
  }

  static async createFromRhythm(category: string, context: common.UIAbilityContext): Promise<AppointmentItem | undefined> {
    if (category === '深度事务') {
      const draft = new AppointmentFormDraft()
      draft.title = '深度事务'
      draft.dueDate = AppointmentLocalStore.today()
      draft.dueTime = '09:30'
      draft.scene = 'work'
      draft.durationMin = 90
      draft.remindBeforeKey = '60'
      draft.prepLine = '关闭通知|准备材料|整段时间'
      draft.note = '按智能整理建议预留不被打断的整段时间'
      return AppointmentService.saveDraft(draft, context)
    }
    const templates = await AppointmentService.templates()
    for (const tpl of templates) {
      if (tpl.title === category) {
        return AppointmentService.createFromTemplate(tpl, context)
      }
    }
    AppointmentService.lastError = '未找到对应模板'
    return undefined
  }

  static cloneItem(source: AppointmentItem): AppointmentItem {
    const item = new AppointmentItem()
    item.id = source.id
    item.title = source.title
    item.status = source.status
    item.dueDate = source.dueDate
    item.dueTime = source.dueTime
    item.note = source.note
    item.repeatType = source.repeatType
    item.remindBeforeKey = source.remindBeforeKey
    item.remindBeforeMinutes = source.remindBeforeMinutes
    item.remindAt = source.remindAt
    item.templateId = source.templateId
    item.userId = source.userId
    item.createdAt = source.createdAt
    item.updatedAt = source.updatedAt
    item.place = source.place
    item.scene = source.scene
    item.durationMin = source.durationMin
    item.priority = source.priority
    item.pinned = source.pinned
    item.prepLine = source.prepLine
    item.prepMask = source.prepMask
    item.followUp = source.followUp
    item.contactName = source.contactName
    item.bufferMin = source.bufferMin
    item.allDay = source.allDay
    item.checkedIn = source.checkedIn
    item.favorite = source.favorite
    item.tagIds = source.tagIds
    item.collectionIds = source.collectionIds
    item.planId = source.planId
    return item
  }

  static async listMissed(): Promise<AppointmentItem[]> {
    return AppointmentTools.missed(await AppointmentService.listAll())
  }

  static async weekSlots(durationMin: number): Promise<FreeSlot[]> {
    return AppointmentTools.weekFreeSlots(await AppointmentService.listAll(), durationMin)
  }

  static async duplicateTomorrow(id: string, context: common.UIAbilityContext): Promise<AppointmentItem | undefined> {
    const item = await AppointmentService.findById(id)
    if (item === undefined) {
      AppointmentService.lastError = '约定不存在'
      return undefined
    }
    const draft = AppointmentService.draftFromItem(item)
    draft.id = ''
    draft.dueDate = ScheduleEngine.addDays(item.dueDate, 1)
    draft.pinned = false
    draft.allowOverlap = false
    return AppointmentService.saveDraft(draft, context)
  }

  static async postponeAllMissed(context: common.UIAbilityContext): Promise<number> {
    const missed = await AppointmentService.listMissed()
    const tomorrow = ScheduleEngine.addDays(AppointmentLocalStore.today(), 1)
    let count = 0
    for (const row of missed) {
      row.dueDate = tomorrow
      const ok = await AppointmentService.persistItem(row, context)
      if (ok) {
        count += 1
      }
    }
    return count
  }

  static async listFavorites(): Promise<AppointmentItem[]> {
    const all = await AppointmentService.listAll()
    const out: AppointmentItem[] = []
    for (const row of all) {
      if (row.favorite) {
        out.push(row)
      }
    }
    return out
  }

  static async toggleFavorite(id: string, context: common.UIAbilityContext): Promise<boolean> {
    const item = await AppointmentService.findById(id)
    if (item === undefined) {
      return false
    }
    item.favorite = !item.favorite
    const ok = await AppointmentService.persistItem(item, context)
    if (ok) {
      await GrowthService.onAppointmentFavorite(item, item.favorite)
    }
    return ok
  }

  static async toggleCheckIn(id: string, context: common.UIAbilityContext): Promise<boolean> {
    const item = await AppointmentService.findById(id)
    if (item === undefined) {
      return false
    }
    item.checkedIn = !item.checkedIn
    const ok = await AppointmentService.persistItem(item, context)
    if (ok) {
      await GrowthService.onCheckIn(item)
    }
    return ok
  }

  static async importPreviews(rows: ImportPreview[], context: common.UIAbilityContext): Promise<number> {
    let count = 0
    for (const row of rows) {
      row.draft.allowOverlap = true
      const saved = await AppointmentService.saveDraft(row.draft, context)
      if (saved !== undefined) {
        count += 1
      }
    }
    return count
  }

  private static sortByDateTime(rows: AppointmentItem[]): AppointmentItem[] {
    const out: AppointmentItem[] = []
    for (const row of rows) {
      out.push(row)
    }
    for (let i = 0; i < out.length; i++) {
      for (let j = i + 1; j < out.length; j++) {
        const a = out[i]
        const b = out[j]
        const ka = `${a.dueDate}${a.dueTime}`
        const kb = `${b.dueDate}${b.dueTime}`
        if (ka > kb) {
          out[i] = b
          out[j] = a
        }
      }
    }
    return out
  }
}
