export class JournalEntry {
  id: string = ''
  entryDate: string = ''
  mood: string = ''
  title: string = ''
  body: string = ''
  keyword: string = ''
  oneLiner: string = ''
  tags: string[] = []
  favorite: boolean = false
  createdAt: number = 0
  updatedAt: number = 0
}

export class PickupItem {
  id: string = ''
  kind: string = ''
  text: string = ''
  sourceId: string = ''
  createdAt: number = 0
}

export class TagItem {
  id: string = ''
  name: string = ''
  custom: boolean = false
}

export class RitualEntry {
  entryDate: string = ''
  joy: string = ''
  thanks: string = ''
  keep: string = ''
  skipped: boolean = false
}

export class AppSettings {
  displayName: string = ''
  reminderGentle: boolean = true
  showRitual: boolean = true
}

export class ShiyiBundle {
  journals: JournalEntry[] = []
  pickups: PickupItem[] = []
  tags: TagItem[] = []
  rituals: RitualEntry[] = []
  settings: AppSettings = new AppSettings()
}

export class MoodOption {
  id: string = ''
  label: string = ''
  mark: string = ''
  tint: string = ''
  coverKey: string = ''
}

export class PickupKindOption {
  id: string = ''
  label: string = ''
}

export class CalCell {
  date: string = ''
  day: number = 0
  inMonth: boolean = false
  hasEntry: boolean = false
  isToday: boolean = false
}

export class CalWeek {
  id: string = ''
  cells: CalCell[] = []
}

export class MonthInsight {
  year: number = 2026
  month: number = 1
  journalCount: number = 0
  topMoodLabel: string = ''
  topTag: string = ''
}

export class FilterChip {
  id: string = ''
  label: string = ''
}
