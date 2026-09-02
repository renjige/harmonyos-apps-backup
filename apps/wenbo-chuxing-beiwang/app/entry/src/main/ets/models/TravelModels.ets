export class TravelTemplate {
  id: string = ''
  title: string = ''
  destination: string = ''
  days: number = 0
  summary: string = ''
  body: string = ''
  subtitle: string = ''
  coverKey: string = ''
}

export class TripItem {
  id: string = ''
  title: string = ''
  destination: string = ''
  startDate: string = ''
  endDate: string = ''
  summary: string = ''
  coverKey: string = ''
  progress: number = 0
  statusLabel: string = '准备中'
}

export class ItineraryItem {
  id: string = ''
  tripId: string = ''
  itemDate: string = ''
  startTime: string = ''
  endTime: string = ''
  title: string = ''
  location: string = ''
  note: string = ''
  completed: boolean = false
}

export class ChecklistPreset {
  id: string = ''
  title: string = ''
  category: string = ''
  summary: string = ''
}

export class ChecklistItem {
  id: string = ''
  tripId: string = ''
  category: string = '用品'
  title: string = ''
  status: string = 'pending'
  completed: boolean = false
}

export class ReminderItem {
  id: string = ''
  tripId: string = ''
  reminderType: string = '自定义'
  title: string = ''
  remindAt: string = ''
  note: string = ''
  completed: boolean = false
  status: string = 'pending'
}

export class SystemNotice {
  id: string = ''
  title: string = ''
  body: string = ''
  type: string = 'system'
  read: boolean = false
  createdAt: string = ''
}

export class NoteItem {
  id: string = ''
  tripId: string = ''
  title: string = ''
  body: string = ''
  updatedAt: string = ''
}

export class TravelTip {
  id: string = ''
  title: string = ''
  summary: string = ''
  body: string = ''
  readMinutes: number = 0
}

export class ListData<T> {
  list: T[] | undefined = undefined
  items: T[] | undefined = undefined
}

export class CreateTripRequest {
  title: string = ''
  destination: string = ''
  startDate: string = ''
  endDate: string = ''
  summary: string = ''
  userId: string = ''
}

export class CreateItineraryRequest {
  title: string = ''
  tripId: string = ''
  itemDate: string = ''
  startTime: string = ''
  endTime: string = ''
  location: string = ''
  note: string = ''
  userId: string = ''
}

export class CreateChecklistRequest {
  title: string = ''
  category: string = ''
  tripId: string = ''
  userId: string = ''
}

export class CreateReminderRequest {
  title: string = ''
  reminderType: string = ''
  remindAt: string = ''
  note: string = ''
  tripId: string = ''
  userId: string = ''
}

export class CreateNoteRequest {
  title: string = ''
  body: string = ''
  tripId: string = ''
  userId: string = ''
}

export class CompletionRequest {
  completed: boolean = false
  status: string = ''
  userId: string = ''
}

export class TravelEditSeed {
  id: string = ''
  title: string = ''
  destination: string = ''
  startDate: string = ''
  endDate: string = ''
  detail: string = ''
  category: string = '证件'
  reminderType: string = '出发'
  remindAt: string = ''
  startTime: string = ''
  tripId: string = ''
}
