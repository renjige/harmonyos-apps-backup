export class MoodItem {
  id: string = ''
  label: string = ''
  icon: string = ''
}

export class CornerTag {
  id: string = ''
  name: string = ''
  custom: boolean = true
}

export class CornerEntry {
  id: string = ''
  body: string = ''
  mood: string = 'calm'
  tagCsv: string = ''
  photoPath: string = ''
  entryDate: string = ''
  createdAt: number = 0
  updatedAt: number = 0

  tagList(): string[] {
    if (this.tagCsv.length === 0) {
      return []
    }
    return this.tagCsv.split(',')
  }
}

export class CornerSettings {
  darkMode: boolean = false
  reminderEnabled: boolean = false
  reminderHour: number = 21
  reminderMinute: number = 30
  reminderAgentId: number = 0
  nickname: string = ''
}

export class CornerBundle {
  entries: CornerEntry[] = []
  tags: CornerTag[] = []
  settings: CornerSettings = new CornerSettings()
}

export class DateGroup {
  date: string = ''
  label: string = ''
  items: CornerEntry[] = []
}

export class TagCount {
  id: string = ''
  name: string = ''
  count: number = 0
}

export class CornerStats {
  total: number = 0
  streak: number = 0
  monthCount: number = 0
  tags: TagCount[] = []
}
