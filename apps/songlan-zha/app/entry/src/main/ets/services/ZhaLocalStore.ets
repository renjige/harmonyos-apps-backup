import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  ZhaAppStats, ZhaJournalEntry, ZhaNoteItem, ZhaQuoteConstants, ZhaQuoteItem, ZhaTodoItem
} from '../models/ZhaModels'
import { ZhaSmartParse } from './ZhaSmartParse'
import { Theme } from '../components/design-system/Theme'

const STORE = 'songlan_zha'
const KEY_NOTES = 'notes_v1'
const KEY_TODOS = 'todos_v1'
const KEY_JOURNALS = 'journals_v1'
const KEY_DARK = 'dark_v1'

export class ZhaDateHelper {
  static todayKey(): string {
    return ZhaDateHelper.keyFromDate(new Date())
  }

  static keyFromDate(d: Date): string {
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${y}-${ms}-${ds}`
  }

  static displayDate(d: Date): string {
    const names: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return `${d.getFullYear()}年${d.getMonth() + 1}月${d.getDate()}日 星期${names[d.getDay()]}`
  }

  static rotateIndex(count: number): number {
    if (count <= 0) {
      return 0
    }
    const start = new Date(2026, 0, 1).getTime()
    const diff = new Date().getTime() - start
    const day = Math.floor(diff / 86400000)
    const idx = day % count
    return idx < 0 ? idx + count : idx
  }

  static newId(): string {
    return `${Date.now()}_${Math.floor(Math.random() * 100000)}`
  }
}

export class ZhaLocalStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ZhaLocalStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ZhaLocalStore.pref = null
    }
  }

  static todayQuote(): ZhaQuoteItem {
    const quotes = ZhaQuoteConstants.quotes()
    const idx = ZhaDateHelper.rotateIndex(quotes.length)
    return quotes[idx]
  }

  static async loadNotes(): Promise<ZhaNoteItem[]> {
    const raw = await ZhaLocalStore.getString(KEY_NOTES, '')
    return ZhaLocalStore.parseNotes(raw)
  }

  static async saveNote(note: ZhaNoteItem): Promise<void> {
    const list = await ZhaLocalStore.loadNotes()
    const next: ZhaNoteItem[] = []
    let found = false
    for (const it of list) {
      if (it.id === note.id) {
        next.push(note)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.unshift(note)
    }
    next.sort((a, b) => b.updatedAt - a.updatedAt)
    await ZhaLocalStore.putString(KEY_NOTES, ZhaLocalStore.serializeNotes(next))
  }

  static async deleteNote(id: string): Promise<void> {
    const list = await ZhaLocalStore.loadNotes()
    const next: ZhaNoteItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ZhaLocalStore.putString(KEY_NOTES, ZhaLocalStore.serializeNotes(next))
  }

  static async findNote(id: string): Promise<ZhaNoteItem | undefined> {
    const list = await ZhaLocalStore.loadNotes()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async createNote(title: string, body: string): Promise<ZhaNoteItem> {
    const note = ZhaNoteItem.create(ZhaDateHelper.newId(), title, body)
    const autoTags = ZhaSmartParse.extractTags(`${title}\n${body}`)
    note.tags = autoTags
    note.updatedAt = Date.now()
    await ZhaLocalStore.saveNote(note)
    return note
  }

  static async updateNote(id: string, title: string, body: string): Promise<void> {
    const existing = await ZhaLocalStore.findNote(id)
    if (existing === undefined) {
      return
    }
    existing.title = title
    existing.body = body
    existing.tags = ZhaSmartParse.extractTags(`${title}\n${body}`)
    existing.updatedAt = Date.now()
    await ZhaLocalStore.saveNote(existing)
  }

  static async loadTodos(): Promise<ZhaTodoItem[]> {
    const raw = await ZhaLocalStore.getString(KEY_TODOS, '')
    return ZhaLocalStore.parseTodos(raw)
  }

  static async saveTodo(todo: ZhaTodoItem): Promise<void> {
    const list = await ZhaLocalStore.loadTodos()
    const next: ZhaTodoItem[] = []
    let found = false
    for (const it of list) {
      if (it.id === todo.id) {
        next.push(todo)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.unshift(todo)
    }
    await ZhaLocalStore.putString(KEY_TODOS, ZhaLocalStore.serializeTodos(next))
  }

  static async deleteTodo(id: string): Promise<void> {
    const list = await ZhaLocalStore.loadTodos()
    const next: ZhaTodoItem[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ZhaLocalStore.putString(KEY_TODOS, ZhaLocalStore.serializeTodos(next))
  }

  static async toggleTodoDone(id: string): Promise<void> {
    const list = await ZhaLocalStore.loadTodos()
    for (const it of list) {
      if (it.id === id) {
        it.done = !it.done
        it.completedAt = it.done ? Date.now() : 0
        break
      }
    }
    await ZhaLocalStore.putString(KEY_TODOS, ZhaLocalStore.serializeTodos(list))
  }

  static async findTodo(id: string): Promise<ZhaTodoItem | undefined> {
    const list = await ZhaLocalStore.loadTodos()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async createTodo(content: string, priority: string, dueDate: string): Promise<ZhaTodoItem> {
    const todo = ZhaTodoItem.create(ZhaDateHelper.newId(), content, priority, dueDate)
    await ZhaLocalStore.saveTodo(todo)
    return todo
  }

  static async loadJournals(): Promise<ZhaJournalEntry[]> {
    const raw = await ZhaLocalStore.getString(KEY_JOURNALS, '')
    return ZhaLocalStore.parseJournals(raw)
  }

  static async saveJournal(entry: ZhaJournalEntry): Promise<void> {
    const list = await ZhaLocalStore.loadJournals()
    const next: ZhaJournalEntry[] = []
    let found = false
    for (const it of list) {
      if (it.dateKey === entry.dateKey) {
        next.push(entry)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(entry)
    }
    await ZhaLocalStore.putString(KEY_JOURNALS, ZhaLocalStore.serializeJournals(next))
  }

  static async findJournal(dateKey: string): Promise<ZhaJournalEntry | undefined> {
    const list = await ZhaLocalStore.loadJournals()
    for (const it of list) {
      if (it.dateKey === dateKey) {
        return it
      }
    }
    return undefined
  }

  static async deleteJournal(dateKey: string): Promise<void> {
    const list = await ZhaLocalStore.loadJournals()
    const next: ZhaJournalEntry[] = []
    for (const it of list) {
      if (it.dateKey !== dateKey) {
        next.push(it)
      }
    }
    await ZhaLocalStore.putString(KEY_JOURNALS, ZhaLocalStore.serializeJournals(next))
  }

  static async clearCompletedTodos(): Promise<number> {
    const list = await ZhaLocalStore.loadTodos()
    const next: ZhaTodoItem[] = []
    let removed = 0
    for (const it of list) {
      if (!it.done) {
        next.push(it)
      } else {
        removed++
      }
    }
    await ZhaLocalStore.putString(KEY_TODOS, ZhaLocalStore.serializeTodos(next))
    return removed
  }

  static async clearAllData(): Promise<void> {
    await ZhaLocalStore.putString(KEY_NOTES, '')
    await ZhaLocalStore.putString(KEY_TODOS, '')
    await ZhaLocalStore.putString(KEY_JOURNALS, '')
  }

  static async isDarkMode(): Promise<boolean> {
    const raw = await ZhaLocalStore.getString(KEY_DARK, '0')
    return raw === '1'
  }

  static async setDarkMode(dark: boolean): Promise<void> {
    await ZhaLocalStore.putString(KEY_DARK, dark ? '1' : '0')
    Theme.applyDark(dark)
  }

  static async loadStats(): Promise<ZhaAppStats> {
    const stats = new ZhaAppStats()
    const notes = await ZhaLocalStore.loadNotes()
    stats.noteCount = notes.length
    const todos = await ZhaLocalStore.loadTodos()
    for (const t of todos) {
      if (t.done) {
        stats.todoDone++
      } else {
        stats.todoActive++
      }
    }
    const journals = await ZhaLocalStore.loadJournals()
    stats.journalDays = journals.length
    return stats
  }

  private static serializeNotes(items: ZhaNoteItem[]): string {
    const lines: string[] = []
    for (const it of items) {
      const tags = it.tags.join('|')
      const title = it.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
      const body = it.body.replace(/\t/g, ' ').replace(/\n/g, '\\n')
      lines.push(`${it.id}\t${title}\t${body}\t${tags}\t${it.createdAt}\t${it.updatedAt}`)
    }
    return lines.join('\n')
  }

  private static parseNotes(raw: string): ZhaNoteItem[] {
    const out: ZhaNoteItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 6) {
        continue
      }
      const n = ZhaNoteItem.create(parts[0], parts[1], parts[2].replace(/\\n/g, '\n'))
      const tagRaw = parts[3]
      if (tagRaw.length > 0) {
        const tags = tagRaw.split('|')
        for (const t of tags) {
          if (t.length > 0) {
            n.tags.push(t)
          }
        }
      }
      n.createdAt = parseInt(parts[4], 10)
      n.updatedAt = parseInt(parts[5], 10)
      out.push(n)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static serializeTodos(items: ZhaTodoItem[]): string {
    const lines: string[] = []
    for (const it of items) {
      const content = it.content.replace(/\t/g, ' ').replace(/\n/g, ' ')
      lines.push(`${it.id}\t${content}\t${it.priority}\t${it.done ? '1' : '0'}\t${it.dueDate}\t${it.createdAt}\t${it.completedAt}`)
    }
    return lines.join('\n')
  }

  private static parseTodos(raw: string): ZhaTodoItem[] {
    const out: ZhaTodoItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 7) {
        continue
      }
      const t = ZhaTodoItem.create(parts[0], parts[1], parts[2], parts[4])
      t.done = parts[3] === '1'
      t.createdAt = parseInt(parts[5], 10)
      t.completedAt = parseInt(parts[6], 10)
      out.push(t)
    }
    return out
  }

  private static serializeJournals(items: ZhaJournalEntry[]): string {
    const lines: string[] = []
    for (const it of items) {
      const content = it.content.replace(/\t/g, ' ').replace(/\n/g, '\\n')
      lines.push(`${it.dateKey}\t${it.mood}\t${content}\t${it.updatedAt}`)
    }
    return lines.join('\n')
  }

  private static parseJournals(raw: string): ZhaJournalEntry[] {
    const out: ZhaJournalEntry[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 4) {
        continue
      }
      const j = ZhaJournalEntry.create(parts[0], parts[1], parts[2].replace(/\\n/g, '\n'))
      j.updatedAt = parseInt(parts[3], 10)
      out.push(j)
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ZhaLocalStore.pref === null) {
      return fallback
    }
    try {
      const v = await ZhaLocalStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ZhaLocalStore.pref === null) {
      return
    }
    try {
      await ZhaLocalStore.pref.put(key, value)
      await ZhaLocalStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
