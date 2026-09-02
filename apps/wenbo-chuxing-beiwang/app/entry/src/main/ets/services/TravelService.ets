import { HttpClient } from './HttpClient'
import { DateFormatUtil } from '../components/design-system/DateFormatUtil'
import { EmptyPayload } from '../models/ApiModels'
import {
  ChecklistItem,
  ChecklistPreset,
  CompletionRequest,
  CreateChecklistRequest,
  CreateItineraryRequest,
  CreateNoteRequest,
  CreateReminderRequest,
  CreateTripRequest,
  ItineraryItem,
  ListData,
  NoteItem,
  ReminderItem,
  SystemNotice,
  TravelTemplate,
  TravelTip,
  TripItem
} from '../models/TravelModels'

const BASE = '/biz/task-efficiency'

export class TravelService {
  private static currentUserId(): string {
    return AppStorage.get<string>('currentUsername') ?? ''
  }

  private static userQuery(): string {
    return `userId=${encodeURIComponent(TravelService.currentUserId())}`
  }

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

  static textOf(value: string): string {
    if (value !== undefined && value.length > 0) {
      return value
    }
    return ''
  }

  static numOf(value: number): number {
    if (value > 0) {
      return value
    }
    return 0
  }

  static percent(done: number, total: number): number {
    if (total <= 0) {
      return 0
    }
    const p = Math.floor((done * 100) / total)
    if (p < 0) {
      return 0
    }
    if (p > 100) {
      return 100
    }
    return p
  }

  static todayStr(): string {
    return DateFormatUtil.formatDate(new Date())
  }

  static addDays(base: string, days: number): string {
    const start = DateFormatUtil.parseDate(base)
    start.setDate(start.getDate() + days)
    return DateFormatUtil.formatDate(start)
  }

  static tripPhase(trip: TripItem): string {
    const today = TravelService.todayStr()
    if (trip.endDate.length > 0 && trip.endDate < today) {
      return '已结束'
    }
    if (trip.startDate.length > 0 && trip.startDate <= today &&
      (trip.endDate.length === 0 || trip.endDate >= today)) {
      return '出行中'
    }
    return '准备中'
  }

  private static flagDone(completed: boolean, status: string): boolean {
    if (completed === true) {
      return true
    }
    return status === 'done'
  }

  static mapTemplate(raw: TravelTemplate): TravelTemplate {
    const item = new TravelTemplate()
    item.id = TravelService.textOf(raw.id)
    item.title = TravelService.textOf(raw.title)
    item.destination = TravelService.textOf(raw.destination)
    item.days = TravelService.numOf(raw.days)
    item.summary = TravelService.textOf(raw.summary)
    item.body = TravelService.textOf(raw.body)
    item.subtitle = TravelService.textOf(raw.subtitle)
    item.coverKey = TravelService.textOf(raw.coverKey)
    return item
  }

  static mapTrip(raw: TripItem): TripItem {
    const item = new TripItem()
    item.id = TravelService.textOf(raw.id)
    item.title = TravelService.textOf(raw.title)
    item.destination = TravelService.textOf(raw.destination)
    item.startDate = TravelService.textOf(raw.startDate)
    item.endDate = TravelService.textOf(raw.endDate)
    item.summary = TravelService.textOf(raw.summary)
    item.coverKey = TravelService.textOf(raw.coverKey)
    item.progress = 0
    if (raw.progress > 0 && raw.progress <= 100) {
      item.progress = Math.floor(raw.progress)
    }
    item.statusLabel = TravelService.tripPhase(item)
    return item
  }

  static mapChecklist(raw: ChecklistItem): ChecklistItem {
    const item = new ChecklistItem()
    item.id = TravelService.textOf(raw.id)
    item.tripId = TravelService.textOf(raw.tripId)
    item.category = TravelService.textOf(raw.category)
    if (item.category.length === 0) {
      item.category = '用品'
    }
    item.title = TravelService.textOf(raw.title)
    item.status = TravelService.textOf(raw.status)
    item.completed = TravelService.flagDone(raw.completed, item.status)
    return item
  }

  static mapReminder(raw: ReminderItem): ReminderItem {
    const item = new ReminderItem()
    item.id = TravelService.textOf(raw.id)
    item.tripId = TravelService.textOf(raw.tripId)
    item.reminderType = TravelService.textOf(raw.reminderType)
    if (item.reminderType.length === 0) {
      item.reminderType = '自定义'
    }
    item.title = TravelService.textOf(raw.title)
    item.remindAt = TravelService.textOf(raw.remindAt)
    item.note = TravelService.textOf(raw.note)
    item.status = TravelService.textOf(raw.status)
    item.completed = TravelService.flagDone(raw.completed, item.status)
    return item
  }

  static mapItinerary(raw: ItineraryItem): ItineraryItem {
    const item = new ItineraryItem()
    item.id = TravelService.textOf(raw.id)
    item.tripId = TravelService.textOf(raw.tripId)
    item.itemDate = TravelService.textOf(raw.itemDate)
    item.startTime = TravelService.textOf(raw.startTime)
    item.endTime = TravelService.textOf(raw.endTime)
    item.title = TravelService.textOf(raw.title)
    item.location = TravelService.textOf(raw.location)
    item.note = TravelService.textOf(raw.note)
    item.completed = raw.completed === true
    return item
  }

  static mapNote(raw: NoteItem): NoteItem {
    const item = new NoteItem()
    item.id = TravelService.textOf(raw.id)
    item.tripId = TravelService.textOf(raw.tripId)
    item.title = TravelService.textOf(raw.title)
    item.body = TravelService.textOf(raw.body)
    item.updatedAt = TravelService.textOf(raw.updatedAt)
    return item
  }

  static mapPreset(raw: ChecklistPreset): ChecklistPreset {
    const item = new ChecklistPreset()
    item.id = TravelService.textOf(raw.id)
    item.title = TravelService.textOf(raw.title)
    item.category = TravelService.textOf(raw.category)
    item.summary = TravelService.textOf(raw.summary)
    return item
  }

  static mapNotice(raw: SystemNotice): SystemNotice {
    const item = new SystemNotice()
    item.id = TravelService.textOf(raw.id)
    item.title = TravelService.textOf(raw.title)
    item.body = TravelService.textOf(raw.body)
    item.type = TravelService.textOf(raw.type)
    item.read = raw.read === true
    item.createdAt = TravelService.textOf(raw.createdAt)
    return item
  }

  static mapTip(raw: TravelTip): TravelTip {
    const item = new TravelTip()
    item.id = TravelService.textOf(raw.id)
    item.title = TravelService.textOf(raw.title)
    item.summary = TravelService.textOf(raw.summary)
    item.body = TravelService.textOf(raw.body)
    item.readMinutes = TravelService.numOf(raw.readMinutes)
    return item
  }

  static attachProgress(trips: TripItem[], items: ChecklistItem[]): TripItem[] {
    const result: TripItem[] = []
    for (const trip of trips) {
      const mapped = TravelService.mapTrip(trip)
      let total = 0
      let done = 0
      for (const row of items) {
        if (row.tripId === mapped.id) {
          total += 1
          if (row.completed) {
            done += 1
          }
        }
      }
      if (total === 0) {
        for (const row of items) {
          if (row.tripId.length === 0) {
            total += 1
            if (row.completed) {
              done += 1
            }
          }
        }
      }
      mapped.progress = TravelService.percent(done, total)
      mapped.statusLabel = TravelService.tripPhase(mapped)
      result.push(mapped)
    }
    return result
  }

  static async templates(): Promise<TravelTemplate[]> {
    const res = await HttpClient.get<ListData<TravelTemplate>>(`${BASE}/templates`)
    const out: TravelTemplate[] = []
    if (res.code !== 0) {
      return out
    }
    for (const row of TravelService.values(res.data)) {
      out.push(TravelService.mapTemplate(row))
    }
    return out
  }

  static async presets(): Promise<ChecklistPreset[]> {
    const res = await HttpClient.get<ListData<ChecklistPreset>>(`${BASE}/checklist-presets`)
    const out: ChecklistPreset[] = []
    if (res.code !== 0) {
      return out
    }
    for (const row of TravelService.values(res.data)) {
      out.push(TravelService.mapPreset(row))
    }
    return out
  }

  static async tips(): Promise<TravelTip[]> {
    const res = await HttpClient.get<ListData<TravelTip>>(`${BASE}/tips`)
    const out: TravelTip[] = []
    if (res.code !== 0) {
      return out
    }
    for (const row of TravelService.values(res.data)) {
      out.push(TravelService.mapTip(row))
    }
    return out
  }

  static async trips(): Promise<TripItem[]> {
    const res = await HttpClient.get<ListData<TripItem>>(`${BASE}/trips?${TravelService.userQuery()}`)
    const out: TripItem[] = []
    if (res.code !== 0) {
      return out
    }
    for (const row of TravelService.values(res.data)) {
      out.push(TravelService.mapTrip(row))
    }
    return out
  }

  static async itinerary(tripId: string): Promise<ItineraryItem[]> {
    const tripQuery = tripId.length > 0 ? `&tripId=${encodeURIComponent(tripId)}` : ''
    const res = await HttpClient.get<ListData<ItineraryItem>>(
      `${BASE}/itinerary?${TravelService.userQuery()}${tripQuery}`
    )
    const out: ItineraryItem[] = []
    if (res.code !== 0) {
      return out
    }
    for (const row of TravelService.values(res.data)) {
      out.push(TravelService.mapItinerary(row))
    }
    return out
  }

  static async checklistItems(): Promise<ChecklistItem[]> {
    const res = await HttpClient.get<ListData<ChecklistItem>>(
      `${BASE}/checklist-items?${TravelService.userQuery()}`
    )
    const out: ChecklistItem[] = []
    if (res.code !== 0) {
      return out
    }
    for (const row of TravelService.values(res.data)) {
      out.push(TravelService.mapChecklist(row))
    }
    return out
  }

  static async reminders(): Promise<ReminderItem[]> {
    const res = await HttpClient.get<ListData<ReminderItem>>(
      `${BASE}/reminders?${TravelService.userQuery()}`
    )
    const out: ReminderItem[] = []
    if (res.code !== 0) {
      return out
    }
    for (const row of TravelService.values(res.data)) {
      out.push(TravelService.mapReminder(row))
    }
    return out
  }

  static async notices(): Promise<SystemNotice[]> {
    const res = await HttpClient.get<ListData<SystemNotice>>(`${BASE}/messages`)
    const out: SystemNotice[] = []
    if (res.code !== 0) {
      return out
    }
    for (const row of TravelService.values(res.data)) {
      out.push(TravelService.mapNotice(row))
    }
    return out
  }

  static async notes(): Promise<NoteItem[]> {
    const res = await HttpClient.get<ListData<NoteItem>>(`${BASE}/notes?${TravelService.userQuery()}`)
    const out: NoteItem[] = []
    if (res.code !== 0) {
      return out
    }
    for (const row of TravelService.values(res.data)) {
      out.push(TravelService.mapNote(row))
    }
    return out
  }

  static async createTrip(body: CreateTripRequest): Promise<TripItem | undefined> {
    body.userId = TravelService.currentUserId()
    const res = await HttpClient.post<TripItem>(`${BASE}/trips`, body)
    if (res.code !== 0 || res.data === undefined) {
      return undefined
    }
    return TravelService.mapTrip(res.data)
  }

  static async createItinerary(body: CreateItineraryRequest): Promise<boolean> {
    body.userId = TravelService.currentUserId()
    const res = await HttpClient.post<ItineraryItem>(`${BASE}/itinerary`, body)
    return res.code === 0
  }

  static async createChecklist(body: CreateChecklistRequest): Promise<boolean> {
    body.userId = TravelService.currentUserId()
    const res = await HttpClient.post<ChecklistItem>(`${BASE}/checklist-items`, body)
    return res.code === 0
  }

  static async createReminder(body: CreateReminderRequest): Promise<boolean> {
    body.userId = TravelService.currentUserId()
    const res = await HttpClient.post<ReminderItem>(`${BASE}/reminders`, body)
    return res.code === 0
  }

  static async createNote(body: CreateNoteRequest): Promise<boolean> {
    body.userId = TravelService.currentUserId()
    const res = await HttpClient.post<NoteItem>(`${BASE}/notes`, body)
    return res.code === 0
  }

  static async setChecklistCompleted(id: string, completed: boolean): Promise<boolean> {
    const body = new CompletionRequest()
    body.completed = completed
    body.status = completed ? 'done' : 'pending'
    body.userId = TravelService.currentUserId()
    const res = await HttpClient.patch<ChecklistItem>(`${BASE}/checklist-items/${id}/status`, body)
    return res.code === 0
  }

  static async setReminderCompleted(id: string, completed: boolean): Promise<boolean> {
    const body = new CompletionRequest()
    body.completed = completed
    body.status = completed ? 'done' : 'pending'
    body.userId = TravelService.currentUserId()
    const res = await HttpClient.patch<ReminderItem>(`${BASE}/reminders/${id}/status`, body)
    return res.code === 0
  }

  static checklistProgress(items: ChecklistItem[]): number[] {
    let done = 0
    let total = items.length
    for (const row of items) {
      if (row.completed) {
        done += 1
      }
    }
    const result: number[] = []
    result.push(done)
    result.push(total)
    result.push(TravelService.percent(done, total))
    return result
  }

  static async updateTrip(id: string, body: CreateTripRequest): Promise<boolean> {
    body.userId = TravelService.currentUserId()
    const res = await HttpClient.put<TripItem>(`${BASE}/trips/${id}`, body)
    return res.code === 0
  }

  static async deleteTrip(id: string): Promise<boolean> {
    const uid = encodeURIComponent(TravelService.currentUserId())
    const res = await HttpClient.delete<EmptyPayload>(`${BASE}/trips/${id}?userId=${uid}`)
    return res.code === 0
  }

  static async updateItinerary(id: string, body: CreateItineraryRequest): Promise<boolean> {
    body.userId = TravelService.currentUserId()
    const res = await HttpClient.put<ItineraryItem>(`${BASE}/itinerary/${id}`, body)
    return res.code === 0
  }

  static async deleteItinerary(id: string): Promise<boolean> {
    const uid = encodeURIComponent(TravelService.currentUserId())
    const res = await HttpClient.delete<EmptyPayload>(`${BASE}/itinerary/${id}?userId=${uid}`)
    return res.code === 0
  }

  static async updateChecklist(id: string, body: CreateChecklistRequest): Promise<boolean> {
    body.userId = TravelService.currentUserId()
    const res = await HttpClient.put<ChecklistItem>(`${BASE}/checklist-items/${id}`, body)
    return res.code === 0
  }

  static async deleteChecklist(id: string): Promise<boolean> {
    const uid = encodeURIComponent(TravelService.currentUserId())
    const res = await HttpClient.delete<EmptyPayload>(`${BASE}/checklist-items/${id}?userId=${uid}`)
    return res.code === 0
  }

  static async updateReminder(id: string, body: CreateReminderRequest): Promise<boolean> {
    body.userId = TravelService.currentUserId()
    const res = await HttpClient.put<ReminderItem>(`${BASE}/reminders/${id}`, body)
    return res.code === 0
  }

  static async deleteReminder(id: string): Promise<boolean> {
    const uid = encodeURIComponent(TravelService.currentUserId())
    const res = await HttpClient.delete<EmptyPayload>(`${BASE}/reminders/${id}?userId=${uid}`)
    return res.code === 0
  }

  static async updateNote(id: string, body: CreateNoteRequest): Promise<boolean> {
    body.userId = TravelService.currentUserId()
    const res = await HttpClient.put<NoteItem>(`${BASE}/notes/${id}`, body)
    return res.code === 0
  }

  static async deleteNote(id: string): Promise<boolean> {
    const uid = encodeURIComponent(TravelService.currentUserId())
    const res = await HttpClient.delete<EmptyPayload>(`${BASE}/notes/${id}?userId=${uid}`)
    return res.code === 0
  }

  static async importPresets(tripId: string): Promise<number> {
    const presets = await TravelService.presets()
    const existing = await TravelService.checklistItems()
    let count = 0
    for (const preset of presets) {
      let exists = false
      for (const item of existing) {
        if (item.title === preset.title && item.category === preset.category) {
          exists = true
          break
        }
      }
      if (exists) {
        continue
      }
      const body = new CreateChecklistRequest()
      body.title = preset.title
      body.category = preset.category
      body.tripId = tripId
      const ok = await TravelService.createChecklist(body)
      if (ok) {
        count += 1
      }
    }
    return count
  }

  static async applyTemplate(tpl: TravelTemplate): Promise<boolean> {
    const days = tpl.days > 0 ? tpl.days : 2
    const body = new CreateTripRequest()
    body.title = tpl.title
    body.destination = tpl.destination.length > 0 ? tpl.destination : tpl.title
    body.startDate = TravelService.todayStr()
    body.endDate = TravelService.addDays(body.startDate, days)
    body.summary = tpl.summary
    const trip = await TravelService.createTrip(body)
    if (trip === undefined) {
      return false
    }
    const first = new CreateItineraryRequest()
    first.title = '出发抵达与入住'
    first.tripId = trip.id
    first.itemDate = body.startDate
    first.startTime = '09:00'
    first.location = body.destination
    first.note = tpl.body.length > 0 ? tpl.body : tpl.summary
    await TravelService.createItinerary(first)
    const mid = new CreateItineraryRequest()
    mid.title = '核心游览与用餐'
    mid.tripId = trip.id
    mid.itemDate = TravelService.addDays(body.startDate, Math.max(1, Math.floor(days / 2)))
    mid.startTime = '10:00'
    mid.location = body.destination
    mid.note = '按模板安排主要活动，预留机动时间。'
    await TravelService.createItinerary(mid)
    const last = new CreateItineraryRequest()
    last.title = '返程与收尾核对'
    last.tripId = trip.id
    last.itemDate = body.endDate
    last.startTime = '16:00'
    last.location = body.destination
    last.note = '核对证件、票据与住宿信息后返程。'
    await TravelService.createItinerary(last)
    const remind = new CreateReminderRequest()
    remind.title = `${body.title} 出发提醒`
    remind.reminderType = '出发'
    remind.remindAt = body.startDate
    remind.note = '出发前再次核对清单与交通时间。'
    remind.tripId = trip.id
    await TravelService.createReminder(remind)
    await TravelService.importPresets(trip.id)
    return true
  }

  static daysUntil(dateStr: string): number {
    if (dateStr.length === 0) {
      return -1
    }
    const today = DateFormatUtil.parseDate(TravelService.todayStr())
    const target = DateFormatUtil.parseDate(dateStr)
    const diff = target.getTime() - today.getTime()
    return Math.floor(diff / 86400000)
  }

  static nearestUpcomingTrip(trips: TripItem[]): TripItem {
    const empty = new TripItem()
    let best: TripItem = empty
    let bestDays = 99999
    let found = false
    for (const trip of trips) {
      const days = TravelService.daysUntil(trip.startDate)
      if (days < 0) {
        continue
      }
      if (!found || days < bestDays) {
        best = trip
        bestDays = days
        found = true
      }
    }
    if (found) {
      return best
    }
    for (const trip of trips) {
      return trip
    }
    return empty
  }

  static async todayAgenda(): Promise<ItineraryItem[]> {
    const today = TravelService.todayStr()
    const trips = await TravelService.trips()
    const out: ItineraryItem[] = []
    for (const trip of trips) {
      const rows = await TravelService.itinerary(trip.id)
      for (const row of rows) {
        if (row.itemDate === today) {
          out.push(row)
        }
      }
    }
    return out
  }

  static upcomingReminders(items: ReminderItem[], limit: number): ReminderItem[] {
    const today = TravelService.todayStr()
    const out: ReminderItem[] = []
    for (const item of items) {
      if (item.completed) {
        continue
      }
      if (item.remindAt.length > 0 && item.remindAt >= today) {
        out.push(item)
      }
    }
    for (let i = 0; i < out.length - 1; i++) {
      for (let j = i + 1; j < out.length; j++) {
        if (out[j].remindAt < out[i].remindAt) {
          const tmp = out[i]
          out[i] = out[j]
          out[j] = tmp
        }
      }
    }
    const sliced: ReminderItem[] = []
    for (const row of out) {
      if (sliced.length >= limit) {
        break
      }
      sliced.push(row)
    }
    return sliced
  }

  static buildSummaryText(
    trip: TripItem,
    timeline: ItineraryItem[],
    checklist: ChecklistItem[],
    reminders: ReminderItem[],
    notes: NoteItem[]
  ): string {
    const lines: string[] = []
    lines.push(`【${trip.title}】出行概览`)
    lines.push(`目的地：${trip.destination}`)
    lines.push(`日期：${trip.startDate} 至 ${trip.endDate}`)
    lines.push(`状态：${TravelService.tripPhase(trip)} · 准备 ${trip.progress}%`)
    if (trip.summary.length > 0) {
      lines.push(`摘要：${trip.summary}`)
    }
    lines.push('')
    lines.push('每日安排')
    if (timeline.length === 0) {
      lines.push('- 暂无时间轴安排')
    } else {
      for (const row of timeline) {
        lines.push(`- ${row.itemDate} ${row.startTime} ${row.title} ${row.location}`)
      }
    }
    lines.push('')
    lines.push('打包清单')
    let done = 0
    let total = 0
    for (const row of checklist) {
      if (row.tripId === trip.id || row.tripId.length === 0) {
        total += 1
        if (row.completed) {
          done += 1
        }
        lines.push(`- [${row.completed ? 'x' : ' '}] ${row.category} ${row.title}`)
      }
    }
    if (total === 0) {
      lines.push('- 尚未添加清单事项')
    } else {
      lines.push(`完成 ${done}/${total}`)
    }
    lines.push('')
    lines.push('重要提醒')
    let remindCount = 0
    for (const row of reminders) {
      if (row.tripId === trip.id || row.tripId.length === 0) {
        remindCount += 1
        lines.push(`- ${row.remindAt} ${row.reminderType} ${row.title}`)
      }
    }
    if (remindCount === 0) {
      lines.push('- 暂无提醒')
    }
    lines.push('')
    lines.push('旅途备忘')
    let noteCount = 0
    for (const row of notes) {
      if (row.tripId === trip.id || row.tripId.length === 0) {
        noteCount += 1
        lines.push(`- ${row.title}：${row.body}`)
      }
    }
    if (noteCount === 0) {
      lines.push('- 暂无备忘')
    }
    return lines.join('\n')
  }
}
