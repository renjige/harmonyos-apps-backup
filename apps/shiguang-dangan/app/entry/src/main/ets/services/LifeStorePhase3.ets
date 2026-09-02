import {
  ChecklistItem, ExperienceEntry, FavoriteFolder, ThemeAlbum, WeeklyActivityBar
} from '../models/LifeModels'
import { LifeStore } from './LifeStore'
import { DateHelper } from './DateHelper'

const KEY_THEME_ALBUMS = 'themeAlbums'
const KEY_CHECKLIST = 'checklist'
const KEY_EXPERIENCES = 'experiences'
const KEY_FAV_FOLDERS = 'favoriteFolders'
const KEY_PLAN_DONE_LOGS = 'planDoneLogs'

/** Phase 3 life data — shares LifeStore preferences */
export class LifeStorePhase3 {
  static async loadThemeAlbums(): Promise<ThemeAlbum[]> {
    const raw = await LifeStore.getRaw(KEY_THEME_ALBUMS, '')
    return LifeStorePhase3.parseAlbums(raw)
  }

  static async findThemeAlbum(id: string): Promise<ThemeAlbum | undefined> {
    const list = await LifeStorePhase3.loadThemeAlbums()
    for (const a of list) {
      if (a.id === id) {
        return a
      }
    }
    return undefined
  }

  static async saveThemeAlbum(album: ThemeAlbum): Promise<void> {
    const list = await LifeStorePhase3.loadThemeAlbums()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === album.id) {
        list[i] = album
        found = true
      }
    }
    if (!found) {
      list.push(album)
    }
    await LifeStore.putRaw(KEY_THEME_ALBUMS, LifeStorePhase3.serializeAlbums(list))
  }

  static async deleteThemeAlbum(id: string): Promise<void> {
    const list = await LifeStorePhase3.loadThemeAlbums()
    const next: ThemeAlbum[] = []
    for (const a of list) {
      if (a.id !== id) {
        next.push(a)
      }
    }
    await LifeStore.putRaw(KEY_THEME_ALBUMS, LifeStorePhase3.serializeAlbums(next))
  }

  static async loadChecklist(): Promise<ChecklistItem[]> {
    const raw = await LifeStore.getRaw(KEY_CHECKLIST, '')
    return LifeStorePhase3.parseChecklist(raw)
  }

  static async saveChecklistItem(item: ChecklistItem): Promise<void> {
    const list = await LifeStorePhase3.loadChecklist()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === item.id) {
        list[i] = item
        found = true
      }
    }
    if (!found) {
      list.push(item)
    }
    await LifeStore.putRaw(KEY_CHECKLIST, LifeStorePhase3.serializeChecklist(list))
  }

  static async deleteChecklistItem(id: string): Promise<void> {
    const list = await LifeStorePhase3.loadChecklist()
    const next: ChecklistItem[] = []
    for (const c of list) {
      if (c.id !== id) {
        next.push(c)
      }
    }
    await LifeStore.putRaw(KEY_CHECKLIST, LifeStorePhase3.serializeChecklist(next))
  }

  static async countChecklistDone(): Promise<number> {
    const list = await LifeStorePhase3.loadChecklist()
    let cnt = 0
    for (const c of list) {
      if (c.status === 'done') {
        cnt++
      }
    }
    return cnt
  }

  static async loadExperiences(): Promise<ExperienceEntry[]> {
    const raw = await LifeStore.getRaw(KEY_EXPERIENCES, '')
    return LifeStorePhase3.parseExperiences(raw)
  }

  static async saveExperience(entry: ExperienceEntry): Promise<void> {
    const list = await LifeStorePhase3.loadExperiences()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === entry.id) {
        list[i] = entry
        found = true
      }
    }
    if (!found) {
      list.push(entry)
    }
    await LifeStore.putRaw(KEY_EXPERIENCES, LifeStorePhase3.serializeExperiences(list))
  }

  static async deleteExperience(id: string): Promise<void> {
    const list = await LifeStorePhase3.loadExperiences()
    const next: ExperienceEntry[] = []
    for (const e of list) {
      if (e.id !== id) {
        next.push(e)
      }
    }
    await LifeStore.putRaw(KEY_EXPERIENCES, LifeStorePhase3.serializeExperiences(next))
  }

  static async loadFavoriteFolders(): Promise<FavoriteFolder[]> {
    const raw = await LifeStore.getRaw(KEY_FAV_FOLDERS, '')
    return LifeStorePhase3.parseFolders(raw)
  }

  static async saveFavoriteFolder(folder: FavoriteFolder): Promise<void> {
    const list = await LifeStorePhase3.loadFavoriteFolders()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === folder.id) {
        list[i] = folder
        found = true
      }
    }
    if (!found) {
      list.push(folder)
    }
    await LifeStore.putRaw(KEY_FAV_FOLDERS, LifeStorePhase3.serializeFolders(list))
  }

  static async deleteFavoriteFolder(id: string): Promise<void> {
    const list = await LifeStorePhase3.loadFavoriteFolders()
    const next: FavoriteFolder[] = []
    for (const f of list) {
      if (f.id !== id) {
        next.push(f)
      }
    }
    await LifeStore.putRaw(KEY_FAV_FOLDERS, LifeStorePhase3.serializeFolders(next))
  }

  static async logPlanTaskDone(taskId: string, dateKey: string): Promise<void> {
    const raw = await LifeStore.getRaw(KEY_PLAN_DONE_LOGS, '')
    const lines = raw.length > 0 ? raw.split('\n') : []
    const needle = `${taskId}\t${dateKey}`
    for (const line of lines) {
      if (line === needle) {
        return
      }
    }
    lines.push(needle)
    await LifeStore.putRaw(KEY_PLAN_DONE_LOGS, lines.join('\n'))
  }

  static async countPlanDoneOnDate(dateKey: string): Promise<number> {
    const raw = await LifeStore.getRaw(KEY_PLAN_DONE_LOGS, '')
    if (raw.length === 0) {
      return 0
    }
    let cnt = 0
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('\t')
      if (parts.length >= 2 && parts[1] === dateKey) {
        cnt++
      }
    }
    return cnt
  }

  static async clearPhase3(): Promise<void> {
    await LifeStore.putRaw(KEY_THEME_ALBUMS, '')
    await LifeStore.putRaw(KEY_CHECKLIST, '')
    await LifeStore.putRaw(KEY_EXPERIENCES, '')
    await LifeStore.putRaw(KEY_FAV_FOLDERS, '')
    await LifeStore.putRaw(KEY_PLAN_DONE_LOGS, '')
  }

  static async exportLifeJson(): Promise<string> {
    const albums = await LifeStorePhase3.loadThemeAlbums()
    const checklist = await LifeStorePhase3.loadChecklist()
    const experiences = await LifeStorePhase3.loadExperiences()
    const folders = await LifeStorePhase3.loadFavoriteFolders()
    const plans = await LifeStore.loadPlans()
    const tasks = await LifeStore.loadPlanTasks()
    const habits = await LifeStore.loadHabits()
    const goals = await LifeStore.loadGoals()
    const moments = await LifeStore.loadMoments()
    const inspirations = await LifeStore.loadInspirations()
    const lines: string[] = []
    lines.push('{')
    lines.push(`"plans":${plans.length},"tasks":${tasks.length},`)
    lines.push(`"habits":${habits.length},"goals":${goals.length},`)
    lines.push(`"moments":${moments.length},"inspirations":${inspirations.length},`)
    lines.push(`"themeAlbums":${albums.length},"checklist":${checklist.length},`)
    lines.push(`"experiences":${experiences.length},"favoriteFolders":${folders.length}`)
    lines.push('}')
    return lines.join('')
  }

  static async dailyActivityCount(dateKey: string, nodeCount: number): Promise<number> {
    const habits = await LifeStore.habitNamesOnDate(dateKey)
    const plansDone = await LifeStorePhase3.countPlanDoneOnDate(dateKey)
    return nodeCount + habits.length + plansDone
  }

  static async buildWeeklyActivityBars(): Promise<WeeklyActivityBar[]> {
    const bars: WeeklyActivityBar[] = []
    for (let i = 6; i >= 0; i--) {
      const dk = DateHelper.daysAgoKey(i)
      const d = new Date()
      d.setDate(d.getDate() - i)
      const label = `${d.getMonth() + 1}/${d.getDate()}`
      const habits = await LifeStore.habitNamesOnDate(dk)
      const plansDone = await LifeStorePhase3.countPlanDoneOnDate(dk)
      bars.push(WeeklyActivityBar.make(label, habits.length + plansDone))
    }
    return bars
  }

  private static serializeAlbums(items: ThemeAlbum[]): string {
    const lines: string[] = []
    for (const a of items) {
      lines.push([
        a.id,
        a.title.replace(/\t/g, ' '),
        a.summary.replace(/\t/g, ' '),
        a.coverTone,
        a.itemRefs.replace(/\t/g, ' ')
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseAlbums(raw: string): ThemeAlbum[] {
    const out: ThemeAlbum[] = []
    if (raw.length === 0) {
      return out
    }
    for (const line of raw.split('\n')) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 5) {
        continue
      }
      const a = new ThemeAlbum()
      a.id = parts[0]
      a.title = parts[1]
      a.summary = parts[2]
      a.coverTone = parts[3]
      a.itemRefs = parts[4]
      out.push(a)
    }
    return out
  }

  private static serializeChecklist(items: ChecklistItem[]): string {
    const lines: string[] = []
    for (const c of items) {
      lines.push([c.id, c.category, c.title.replace(/\t/g, ' '), c.status].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseChecklist(raw: string): ChecklistItem[] {
    const out: ChecklistItem[] = []
    if (raw.length === 0) {
      return out
    }
    for (const line of raw.split('\n')) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 4) {
        continue
      }
      const c = new ChecklistItem()
      c.id = parts[0]
      c.category = parts[1]
      c.title = parts[2]
      c.status = parts[3]
      out.push(c)
    }
    return out
  }

  private static serializeExperiences(items: ExperienceEntry[]): string {
    const lines: string[] = []
    for (const e of items) {
      lines.push([
        e.id,
        e.question.replace(/\t/g, ' '),
        e.method.replace(/\t/g, ' '),
        e.result.replace(/\t/g, ' '),
        e.note.replace(/\t/g, ' '),
        `${e.createdAt}`
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseExperiences(raw: string): ExperienceEntry[] {
    const out: ExperienceEntry[] = []
    if (raw.length === 0) {
      return out
    }
    for (const line of raw.split('\n')) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 6) {
        continue
      }
      const e = new ExperienceEntry()
      e.id = parts[0]
      e.question = parts[1]
      e.method = parts[2]
      e.result = parts[3]
      e.note = parts[4]
      e.createdAt = parseInt(parts[5], 10)
      out.push(e)
    }
    out.sort((a, b) => b.createdAt - a.createdAt)
    return out
  }

  private static serializeFolders(items: FavoriteFolder[]): string {
    const lines: string[] = []
    for (const f of items) {
      lines.push([f.id, f.name.replace(/\t/g, ' ')].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseFolders(raw: string): FavoriteFolder[] {
    const out: FavoriteFolder[] = []
    if (raw.length === 0) {
      return out
    }
    for (const line of raw.split('\n')) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 2) {
        continue
      }
      const f = new FavoriteFolder()
      f.id = parts[0]
      f.name = parts[1]
      out.push(f)
    }
    return out
  }
}
