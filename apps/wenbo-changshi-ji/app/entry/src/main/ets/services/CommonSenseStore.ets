import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { CommonSenseStats } from '../models/CommonSenseModels'
import { CommonSenseTime } from '../models/CommonSenseModels'
import { CommonSenseDetailNav } from './CommonSenseDetailNav'
import { CommonSenseLocalService } from './CommonSenseLocalService'
import { LearningHubService } from './LearningHubService'

const STORE_NAME = 'changshiji_local'
const KEY_FAVORITES = 'favorites_json'
const KEY_READS = 'reads_json'
const KEY_NOTES = 'notes_json'
const KEY_CHECKINS = 'checkins_json'
const KEY_FOLDERS = 'folders_json'
const KEY_FONT = 'font_scale'
const KEY_DARK = 'dark_mode'

export class CommonSenseStore {
  private static pref: preferences.Preferences | null = null
  private static favorites: string[] = []
  private static reads: string[] = []
  private static notes: NoteEntry[] = []
  private static checkins: string[] = []
  private static folders: string[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      CommonSenseStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const rawFav = await CommonSenseStore.pref.get(KEY_FAVORITES, '[]')
      const favStr: string = typeof rawFav === 'string' ? rawFav : '[]'
      CommonSenseStore.favorites = CommonSenseStore.parseIdList(favStr)
      const rawRead = await CommonSenseStore.pref.get(KEY_READS, '[]')
      const readStr: string = typeof rawRead === 'string' ? rawRead : '[]'
      CommonSenseStore.reads = CommonSenseStore.parseIdList(readStr)
      const rawNotes = await CommonSenseStore.pref.get(KEY_NOTES, '[]')
      const noteStr: string = typeof rawNotes === 'string' ? rawNotes : '[]'
      CommonSenseStore.notes = CommonSenseStore.parseNotes(noteStr)
      const rawCheck = await CommonSenseStore.pref.get(KEY_CHECKINS, '[]')
      const checkStr: string = typeof rawCheck === 'string' ? rawCheck : '[]'
      CommonSenseStore.checkins = CommonSenseStore.parseIdList(checkStr)
      const rawFolders = await CommonSenseStore.pref.get(KEY_FOLDERS, '[]')
      const folderStr: string = typeof rawFolders === 'string' ? rawFolders : '[]'
      CommonSenseStore.folders = CommonSenseStore.parseIdList(folderStr)
      const fontRaw = await CommonSenseStore.pref.get(KEY_FONT, 1.0)
      const fontVal: number = typeof fontRaw === 'number' ? fontRaw : 1.0
      AppStorage.setOrCreate('fontScale', fontVal)
      const dark = await CommonSenseStore.pref.get(KEY_DARK, false)
      AppStorage.setOrCreate('darkModeOn', dark === true)
    } catch {
      CommonSenseStore.favorites = []
      CommonSenseStore.reads = []
      CommonSenseStore.notes = []
      CommonSenseStore.checkins = []
      CommonSenseStore.folders = []
    }
  }

  static isFavorite(id: string): boolean {
    return CommonSenseStore.contains(CommonSenseStore.favorites, id)
  }

  static favoriteIds(): string[] {
    return CommonSenseStore.copyIds(CommonSenseStore.favorites)
  }

  static readIds(): string[] {
    return CommonSenseStore.copyIds(CommonSenseStore.reads)
  }

  static folderNames(): string[] {
    return CommonSenseStore.copyIds(CommonSenseStore.folders)
  }

  static fontScale(): number {
    const v = AppStorage.get<number>('fontScale')
    if (v !== undefined && v > 0) {
      return v
    }
    return 1.0
  }

  static isCheckedIn(dateKey: string): boolean {
    return CommonSenseStore.contains(CommonSenseStore.checkins, dateKey)
  }

  static noteFor(factId: string): string {
    for (const row of CommonSenseStore.notes) {
      if (row.factId === factId) {
        return row.text
      }
    }
    return ''
  }

  static stats(): CommonSenseStats {
    const s = new CommonSenseStats()
    s.favorites = CommonSenseStore.favorites.length
    s.readDays = CommonSenseStore.checkins.length
    s.checkInStreak = CommonSenseStore.computeStreak()
    s.readCount = CommonSenseStore.reads.length
    s.mastered = CommonSenseLocalService.masteredCount()
    s.lists = CommonSenseLocalService.listCount()
    return s
  }

  static checkInDayKeys(): string[] {
    return CommonSenseStore.copyIds(CommonSenseStore.checkins)
  }

  static async toggleFavorite(id: string, title: string = ''): Promise<boolean> {
    if (CommonSenseStore.isFavorite(id)) {
      CommonSenseStore.favorites = CommonSenseStore.removeId(CommonSenseStore.favorites, id)
      await CommonSenseStore.flushIds(KEY_FAVORITES, CommonSenseStore.favorites)
      CommonSenseStore.bump()
      return false
    }
    CommonSenseStore.favorites = CommonSenseStore.prependId(CommonSenseStore.favorites, id)
    await CommonSenseStore.flushIds(KEY_FAVORITES, CommonSenseStore.favorites)
    if (title.length > 0) {
      void LearningHubService.onFavorite(id, title, true)
    }
    CommonSenseStore.bump()
    return true
  }

  static async markRead(id: string, title: string = '', category: string = ''): Promise<void> {
    if (id.length === 0) {
      return
    }
    CommonSenseStore.reads = CommonSenseStore.removeId(CommonSenseStore.reads, id)
    CommonSenseStore.reads = CommonSenseStore.prependId(CommonSenseStore.reads, id)
    await CommonSenseStore.flushIds(KEY_READS, CommonSenseStore.reads)
    AppStorage.setOrCreate('lastReadFactId', id)
    if (title.length > 0) {
      void LearningHubService.onRead(id, title, category)
    }
    CommonSenseStore.bump()
  }

  static async saveNote(factId: string, text: string): Promise<void> {
    const next: NoteEntry[] = []
    let replaced = false
    for (const row of CommonSenseStore.notes) {
      if (row.factId === factId) {
        const entry = new NoteEntry()
        entry.factId = factId
        entry.text = text
        next.push(entry)
        replaced = true
      } else {
        next.push(row)
      }
    }
    if (!replaced) {
      const entry = new NoteEntry()
      entry.factId = factId
      entry.text = text
      next.push(entry)
    }
    CommonSenseStore.notes = next
    await CommonSenseStore.flushNotes()
    CommonSenseStore.bump()
  }

  static async checkInToday(): Promise<boolean> {
    const today = CommonSenseTime.todayKey()
    if (CommonSenseStore.isCheckedIn(today)) {
      return false
    }
    CommonSenseStore.checkins = CommonSenseStore.prependId(CommonSenseStore.checkins, today)
    await CommonSenseStore.flushIds(KEY_CHECKINS, CommonSenseStore.checkins)
    void LearningHubService.onCheckIn()
    CommonSenseStore.bump()
    return true
  }

  static async setFontScale(scale: number): Promise<void> {
    const val = scale < 0.85 ? 0.85 : (scale > 1.35 ? 1.35 : scale)
    AppStorage.setOrCreate('fontScale', val)
    if (CommonSenseStore.pref !== null) {
      await CommonSenseStore.pref.put(KEY_FONT, val)
      await CommonSenseStore.pref.flush()
    }
  }

  static async setDark(on: boolean): Promise<void> {
    AppStorage.setOrCreate('darkModeOn', on)
    AppStorage.setOrCreate('colorMode', on ? 'dark' : 'light')
    if (CommonSenseStore.pref !== null) {
      await CommonSenseStore.pref.put(KEY_DARK, on)
      await CommonSenseStore.pref.flush()
    }
  }

  static exportFavoritesText(titles: string[]): string {
    let text = '【常识集 · 我的收藏】\n'
    for (let i = 0; i < titles.length; i++) {
      text += `${i + 1}. ${titles[i]}\n`
    }
    text += '\n— 来自常识集 App'
    return text
  }

  static async clearCache(): Promise<void> {
    CommonSenseStore.bump()
  }

  private static computeStreak(): number {
    if (CommonSenseStore.checkins.length === 0) {
      return 0
    }
    const sorted = CommonSenseStore.copyIds(CommonSenseStore.checkins)
    sorted.sort()
    let streak = 0
    const today = CommonSenseTime.todayKey()
    let cursor = today
    for (let i = 0; i < 366; i++) {
      if (CommonSenseStore.contains(sorted, cursor)) {
        streak = streak + 1
        cursor = CommonSenseStore.prevDayKey(cursor)
      } else {
        break
      }
    }
    return streak
  }

  private static prevDayKey(dateKey: string): string {
    const parts = dateKey.split('-')
    if (parts.length < 3) {
      return dateKey
    }
    const y = parseInt(parts[0], 10)
    const m = parseInt(parts[1], 10)
    const d = parseInt(parts[2], 10)
    const dt = new Date(y, m - 1, d)
    dt.setDate(dt.getDate() - 1)
    const nm = dt.getMonth() + 1
    const nd = dt.getDate()
    const ms = nm < 10 ? `0${nm}` : `${nm}`
    const ds = nd < 10 ? `0${nd}` : `${nd}`
    return `${dt.getFullYear()}-${ms}-${ds}`
  }

  private static bump(): void {
    CommonSenseDetailNav.bumpRefresh()
  }

  private static contains(list: string[], id: string): boolean {
    for (const row of list) {
      if (row === id) {
        return true
      }
    }
    return false
  }

  private static copyIds(list: string[]): string[] {
    const copy: string[] = []
    for (const id of list) {
      copy.push(id)
    }
    return copy
  }

  private static prependId(list: string[], id: string): string[] {
    const next: string[] = [id]
    for (const row of list) {
      if (row !== id) {
        next.push(row)
      }
    }
    return next
  }

  private static removeId(list: string[], id: string): string[] {
    const next: string[] = []
    for (const row of list) {
      if (row !== id) {
        next.push(row)
      }
    }
    return next
  }

  private static parseIdList(text: string): string[] {
    const out: string[] = []
    if (text.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(text) as string[]
      for (const id of parsed) {
        out.push(id)
      }
    } catch {
      return out
    }
    return out
  }

  private static parseNotes(text: string): NoteEntry[] {
    const out: NoteEntry[] = []
    if (text.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(text) as NoteEntryWire[]
      for (const row of parsed) {
        const entry = new NoteEntry()
        entry.factId = row.factId
        entry.text = row.text
        out.push(entry)
      }
    } catch {
      return out
    }
    return out
  }

  private static async flushIds(key: string, ids: string[]): Promise<void> {
    if (CommonSenseStore.pref === null) {
      return
    }
    let json = '['
    for (let i = 0; i < ids.length; i++) {
      if (i > 0) {
        json += ','
      }
      json += JSON.stringify(ids[i])
    }
    json += ']'
    await CommonSenseStore.pref.put(key, json)
    await CommonSenseStore.pref.flush()
  }

  private static async flushNotes(): Promise<void> {
    if (CommonSenseStore.pref === null) {
      return
    }
    const wires: NoteEntryWire[] = []
    for (const row of CommonSenseStore.notes) {
      const w = new NoteEntryWire()
      w.factId = row.factId
      w.text = row.text
      wires.push(w)
    }
    await CommonSenseStore.pref.put(KEY_NOTES, JSON.stringify(wires))
    await CommonSenseStore.pref.flush()
  }
}

class NoteEntry {
  factId: string = ''
  text: string = ''
}

class NoteEntryWire {
  factId: string = ''
  text: string = ''
}
