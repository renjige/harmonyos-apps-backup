import { SessionStore } from './SessionStore'
import {
  GoalItem,
  HabitItem,
  LifeDates,
  LifeTag,
  MoodEntry,
  ReminderItem,
  TodoItem
} from '../models/LifeHubModels'

class MoodWire {
  id: string = ''
  date: string = ''
  moodId: string = ''
  note: string = ''
}

class MoodFile {
  items: MoodWire[] = []
}

class ReminderWire {
  id: string = ''
  title: string = ''
  category: string = ''
  date: string = ''
  time: string = ''
  enabled: boolean = true
  agentId: number = 0
}

class ReminderFile {
  items: ReminderWire[] = []
}

class TodoWire {
  id: string = ''
  title: string = ''
  category: string = ''
  done: boolean = false
  date: string = ''
}

class TodoFile {
  items: TodoWire[] = []
}

class TagWire {
  id: string = ''
  name: string = ''
  category: string = ''
  builtin: boolean = false
}

class TagFile {
  items: TagWire[] = []
}

class HabitWire {
  id: string = ''
  title: string = ''
  checkins: string[] = []
}

class HabitFile {
  items: HabitWire[] = []
}

class GoalWire {
  id: string = ''
  title: string = ''
  progress: number = 0
  status: string = ''
}

class GoalFile {
  items: GoalWire[] = []
}

/** 心情 / 提醒 / 待办 / 标签 / 打卡 / 目标 — 本机 Preferences */
export class LifeHubStore {
  static lastError: string = ''

  private static uid(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static notifyChanged(): void {
    const v = AppStorage.get<number>('lifeHubVersion') ?? 0
    AppStorage.setOrCreate('lifeHubVersion', v + 1)
  }

  private static key(kind: string): string {
    return `life_${kind}_${LifeHubStore.uid()}`
  }

  private static async writeItems(kind: string, jsonItems: string): Promise<void> {
    const uid = LifeHubStore.uid()
    if (uid.length === 0) {
      return
    }
    await SessionStore.writeRaw(LifeHubStore.key(kind), `{"items":[${jsonItems}]}`)
    LifeHubStore.notifyChanged()
  }

  static async loadMoods(): Promise<MoodEntry[]> {
    const raw = await SessionStore.readRaw(LifeHubStore.key('moods'))
    const out: MoodEntry[] = []
    if (raw.length === 0) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as MoodFile
      if (parsed === undefined || parsed.items === undefined) {
        return out
      }
      for (const w of parsed.items) {
        const row = new MoodEntry()
        row.id = w.id !== undefined && w.id !== null ? w.id : ''
        row.date = w.date !== undefined && w.date !== null ? w.date : ''
        row.moodId = w.moodId !== undefined && w.moodId !== null ? w.moodId : ''
        row.note = w.note !== undefined && w.note !== null ? w.note : ''
        if (row.id.length > 0) {
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  static async upsertMood(moodId: string, note: string, date: string): Promise<MoodEntry> {
    const list = await LifeHubStore.loadMoods()
    const day = date.length >= 10 ? date : LifeDates.todayIso()
    const next: MoodEntry[] = []
    let saved = new MoodEntry()
    let found = false
    for (const row of list) {
      if (row.date === day) {
        row.moodId = moodId
        row.note = note
        saved = row
        found = true
        next.push(row)
      } else {
        next.push(row)
      }
    }
    if (!found) {
      saved = MoodEntry.fromParts(LifeHubStore.newId('mood'), day, moodId, note)
      next.unshift(saved)
    }
    await LifeHubStore.saveMoods(next)
    return saved
  }

  static async saveMoods(items: MoodEntry[]): Promise<void> {
    let body = ''
    let first = true
    for (const row of items) {
      if (!first) {
        body += ','
      }
      first = false
      body += row.toJsonString()
    }
    await LifeHubStore.writeItems('moods', body)
  }

  static async moodOn(iso: string): Promise<MoodEntry | undefined> {
    const list = await LifeHubStore.loadMoods()
    for (const row of list) {
      if (row.date === iso) {
        return row
      }
    }
    return undefined
  }

  static async loadReminders(): Promise<ReminderItem[]> {
    const raw = await SessionStore.readRaw(LifeHubStore.key('reminders'))
    const out: ReminderItem[] = []
    if (raw.length === 0) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as ReminderFile
      if (parsed === undefined || parsed.items === undefined) {
        return out
      }
      for (const w of parsed.items) {
        const row = new ReminderItem()
        row.id = w.id !== undefined && w.id !== null ? w.id : ''
        row.title = w.title !== undefined && w.title !== null ? w.title : ''
        row.category = w.category !== undefined && w.category !== null ? w.category : 'life'
        row.date = w.date !== undefined && w.date !== null ? w.date : ''
        row.time = w.time !== undefined && w.time !== null ? w.time : '09:00'
        row.enabled = w.enabled !== false
        row.agentId = w.agentId !== undefined && w.agentId !== null ? w.agentId : 0
        if (row.id.length > 0) {
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  static async saveReminders(items: ReminderItem[]): Promise<void> {
    let body = ''
    let first = true
    for (const row of items) {
      if (!first) {
        body += ','
      }
      first = false
      body += row.toJsonString()
    }
    await LifeHubStore.writeItems('reminders', body)
  }

  static async upsertReminder(item: ReminderItem): Promise<void> {
    const list = await LifeHubStore.loadReminders()
    const next: ReminderItem[] = []
    let found = false
    for (const row of list) {
      if (row.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(row)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    await LifeHubStore.saveReminders(next)
  }

  static async removeReminder(id: string): Promise<ReminderItem | undefined> {
    const list = await LifeHubStore.loadReminders()
    const next: ReminderItem[] = []
    let removed: ReminderItem | undefined = undefined
    for (const row of list) {
      if (row.id === id) {
        removed = row
      } else {
        next.push(row)
      }
    }
    await LifeHubStore.saveReminders(next)
    return removed
  }

  static async loadTodos(): Promise<TodoItem[]> {
    const raw = await SessionStore.readRaw(LifeHubStore.key('todos'))
    const out: TodoItem[] = []
    if (raw.length === 0) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as TodoFile
      if (parsed === undefined || parsed.items === undefined) {
        return out
      }
      for (const w of parsed.items) {
        const row = new TodoItem()
        row.id = w.id !== undefined && w.id !== null ? w.id : ''
        row.title = w.title !== undefined && w.title !== null ? w.title : ''
        row.category = w.category !== undefined && w.category !== null ? w.category : 'life'
        row.done = w.done === true
        row.date = w.date !== undefined && w.date !== null ? w.date : ''
        if (row.id.length > 0) {
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  static async saveTodos(items: TodoItem[]): Promise<void> {
    let body = ''
    let first = true
    for (const row of items) {
      if (!first) {
        body += ','
      }
      first = false
      body += row.toJsonString()
    }
    await LifeHubStore.writeItems('todos', body)
  }

  static async upsertTodo(item: TodoItem): Promise<void> {
    const list = await LifeHubStore.loadTodos()
    const next: TodoItem[] = []
    let found = false
    for (const row of list) {
      if (row.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(row)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    await LifeHubStore.saveTodos(next)
  }

  static async removeTodo(id: string): Promise<void> {
    const list = await LifeHubStore.loadTodos()
    const next: TodoItem[] = []
    for (const row of list) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    await LifeHubStore.saveTodos(next)
  }

  static async loadTags(): Promise<LifeTag[]> {
    const raw = await SessionStore.readRaw(LifeHubStore.key('tags'))
    if (raw.length === 0) {
      const seeded = LifeHubStore.defaultTags()
      await LifeHubStore.saveTags(seeded)
      return seeded
    }
    const out: LifeTag[] = []
    try {
      const parsed = JSON.parse(raw) as TagFile
      if (parsed === undefined || parsed.items === undefined) {
        return LifeHubStore.defaultTags()
      }
      for (const w of parsed.items) {
        const row = new LifeTag()
        row.id = w.id !== undefined && w.id !== null ? w.id : ''
        row.name = w.name !== undefined && w.name !== null ? w.name : ''
        row.category = w.category !== undefined && w.category !== null ? w.category : 'custom'
        row.builtin = w.builtin === true
        if (row.id.length > 0) {
          out.push(row)
        }
      }
    } catch {
      return LifeHubStore.defaultTags()
    }
    if (out.length === 0) {
      return LifeHubStore.defaultTags()
    }
    return out
  }

  static defaultTags(): LifeTag[] {
    const photo = new LifeTag()
    photo.id = 'tag_photo'
    photo.name = '照片'
    photo.category = 'photo'
    photo.builtin = true
    const food = new LifeTag()
    food.id = 'tag_food'
    food.name = '美食'
    food.category = 'food'
    food.builtin = true
    const travel = new LifeTag()
    travel.id = 'tag_travel'
    travel.name = '旅行'
    travel.category = 'travel'
    travel.builtin = true
    const family = new LifeTag()
    family.id = 'tag_family'
    family.name = '家庭'
    family.category = 'family'
    family.builtin = true
    return [photo, food, travel, family]
  }

  static async saveTags(items: LifeTag[]): Promise<void> {
    let body = ''
    let first = true
    for (const row of items) {
      if (!first) {
        body += ','
      }
      first = false
      body += row.toJsonString()
    }
    await LifeHubStore.writeItems('tags', body)
  }

  static async addTag(name: string, category: string): Promise<LifeTag | undefined> {
    const trimmed = name.trim()
    if (trimmed.length === 0) {
      LifeHubStore.lastError = '请填写标签名称'
      return undefined
    }
    const list = await LifeHubStore.loadTags()
    for (const row of list) {
      if (row.name === trimmed) {
        LifeHubStore.lastError = '该标签已存在'
        return undefined
      }
    }
    const tag = new LifeTag()
    tag.id = LifeHubStore.newId('tag')
    tag.name = trimmed
    tag.category = category.length > 0 ? category : 'custom'
    tag.builtin = false
    list.push(tag)
    await LifeHubStore.saveTags(list)
    return tag
  }

  static async removeTag(id: string): Promise<boolean> {
    const list = await LifeHubStore.loadTags()
    const next: LifeTag[] = []
    let removed = false
    for (const row of list) {
      if (row.id === id) {
        if (row.builtin) {
          LifeHubStore.lastError = '内置分类不可删除'
          return false
        }
        removed = true
      } else {
        next.push(row)
      }
    }
    if (removed) {
      await LifeHubStore.saveTags(next)
    }
    return removed
  }

  static async loadHabits(): Promise<HabitItem[]> {
    const raw = await SessionStore.readRaw(LifeHubStore.key('habits'))
    const out: HabitItem[] = []
    if (raw.length === 0) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as HabitFile
      if (parsed === undefined || parsed.items === undefined) {
        return out
      }
      for (const w of parsed.items) {
        const row = new HabitItem()
        row.id = w.id !== undefined && w.id !== null ? w.id : ''
        row.title = w.title !== undefined && w.title !== null ? w.title : ''
        row.checkins = w.checkins !== undefined && w.checkins !== null ? w.checkins : []
        if (row.id.length > 0) {
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  static async saveHabits(items: HabitItem[]): Promise<void> {
    let body = ''
    let first = true
    for (const row of items) {
      if (!first) {
        body += ','
      }
      first = false
      body += row.toJsonString()
    }
    await LifeHubStore.writeItems('habits', body)
  }

  static async upsertHabit(item: HabitItem): Promise<void> {
    const list = await LifeHubStore.loadHabits()
    const next: HabitItem[] = []
    let found = false
    for (const row of list) {
      if (row.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(row)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    await LifeHubStore.saveHabits(next)
  }

  static async removeHabit(id: string): Promise<void> {
    const list = await LifeHubStore.loadHabits()
    const next: HabitItem[] = []
    for (const row of list) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    await LifeHubStore.saveHabits(next)
  }

  static async toggleHabit(id: string, iso: string): Promise<void> {
    const list = await LifeHubStore.loadHabits()
    for (const row of list) {
      if (row.id === id) {
        const nextDates: string[] = []
        let found = false
        for (const d of row.checkins) {
          if (d === iso) {
            found = true
          } else {
            nextDates.push(d)
          }
        }
        if (!found) {
          nextDates.push(iso)
        }
        row.checkins = nextDates
      }
    }
    await LifeHubStore.saveHabits(list)
  }

  static async loadGoals(): Promise<GoalItem[]> {
    const raw = await SessionStore.readRaw(LifeHubStore.key('goals'))
    const out: GoalItem[] = []
    if (raw.length === 0) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as GoalFile
      if (parsed === undefined || parsed.items === undefined) {
        return out
      }
      for (const w of parsed.items) {
        const row = new GoalItem()
        row.id = w.id !== undefined && w.id !== null ? w.id : ''
        row.title = w.title !== undefined && w.title !== null ? w.title : ''
        row.progress = w.progress !== undefined && w.progress !== null ? w.progress : 0
        row.status = w.status !== undefined && w.status !== null ? w.status : 'active'
        if (row.id.length > 0) {
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  static async saveGoals(items: GoalItem[]): Promise<void> {
    let body = ''
    let first = true
    for (const row of items) {
      if (!first) {
        body += ','
      }
      first = false
      body += row.toJsonString()
    }
    await LifeHubStore.writeItems('goals', body)
  }

  static async upsertGoal(item: GoalItem): Promise<void> {
    const list = await LifeHubStore.loadGoals()
    const next: GoalItem[] = []
    let found = false
    for (const row of list) {
      if (row.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(row)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    await LifeHubStore.saveGoals(next)
  }

  static async removeGoal(id: string): Promise<void> {
    const list = await LifeHubStore.loadGoals()
    const next: GoalItem[] = []
    for (const row of list) {
      if (row.id !== id) {
        next.push(row)
      }
    }
    await LifeHubStore.saveGoals(next)
  }
}
