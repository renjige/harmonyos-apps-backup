import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { FavoriteItem, WorkItem } from '../models/CourtyardModels'

const STORE = 'courtyard_local'
const KEY_FAV = 'favorites_json'
const KEY_WORK = 'works_json'
const KEY_READ = 'read_ids'
const KEY_DETECT = 'detect_count'
const KEY_FONT = 'font_scale'
const KEY_BOOK = 'rhyme_book'
const KEY_THEME = 'color_mode'

/** 本机收藏 / 作品 / 进度 / 偏好；新用户空 */
export class CourtyardLocalStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      CourtyardLocalStore.pref = await preferences.getPreferences(context, STORE)
      const fav = await CourtyardLocalStore.getStr(KEY_FAV, '[]')
      const work = await CourtyardLocalStore.getStr(KEY_WORK, '[]')
      const read = await CourtyardLocalStore.getStr(KEY_READ, '')
      const detect = await CourtyardLocalStore.getNum(KEY_DETECT, 0)
      const font = await CourtyardLocalStore.getNum(KEY_FONT, 1)
      const book = await CourtyardLocalStore.getStr(KEY_BOOK, '平水韵')
      const mode = await CourtyardLocalStore.getStr(KEY_THEME, 'system')
      AppStorage.setOrCreate(KEY_FAV, fav)
      AppStorage.setOrCreate(KEY_WORK, work)
      AppStorage.setOrCreate(KEY_READ, read)
      AppStorage.setOrCreate(KEY_DETECT, detect)
      AppStorage.setOrCreate(KEY_FONT, font)
      AppStorage.setOrCreate(KEY_BOOK, book)
      AppStorage.setOrCreate(KEY_THEME, mode)
    } catch {
      AppStorage.setOrCreate(KEY_FAV, '[]')
      AppStorage.setOrCreate(KEY_WORK, '[]')
      AppStorage.setOrCreate(KEY_READ, '')
      AppStorage.setOrCreate(KEY_DETECT, 0)
      AppStorage.setOrCreate(KEY_FONT, 1)
      AppStorage.setOrCreate(KEY_BOOK, '平水韵')
      AppStorage.setOrCreate(KEY_THEME, 'system')
    }
  }

  static favorites(): FavoriteItem[] {
    const raw = AppStorage.get<string>(KEY_FAV) ?? '[]'
    try {
      const arr = JSON.parse(raw) as FavoriteItem[]
      return arr !== undefined && arr !== null ? arr : []
    } catch {
      return []
    }
  }

  static isFav(poemId: string): boolean {
    const list = CourtyardLocalStore.favorites()
    for (const f of list) {
      if (f.poemId === poemId) {
        return true
      }
    }
    return false
  }

  static async toggleFav(poemId: string): Promise<boolean> {
    const list = CourtyardLocalStore.favorites()
    const next: FavoriteItem[] = []
    let found = false
    for (const f of list) {
      if (f.poemId === poemId) {
        found = true
      } else {
        next.push(f)
      }
    }
    if (!found) {
      const item = new FavoriteItem()
      item.poemId = poemId
      item.tags = '默认'
      item.createdAt = `${Date.now()}`
      next.unshift(item)
    }
    await CourtyardLocalStore.putStr(KEY_FAV, JSON.stringify(next))
    AppStorage.setOrCreate(KEY_FAV, JSON.stringify(next))
    return !found
  }

  static works(): WorkItem[] {
    const raw = AppStorage.get<string>(KEY_WORK) ?? '[]'
    try {
      const arr = JSON.parse(raw) as WorkItem[]
      return arr !== undefined && arr !== null ? arr : []
    } catch {
      return []
    }
  }

  static findWork(id: string): WorkItem | undefined {
    const list = CourtyardLocalStore.works()
    for (const w of list) {
      if (w.id === id) {
        return w
      }
    }
    return undefined
  }

  static async saveWork(title: string, body: string, meterSummary: string): Promise<WorkItem> {
    const list = CourtyardLocalStore.works()
    const item = new WorkItem()
    item.id = `w_${Date.now()}`
    item.title = title.length > 0 ? title : '未题习作'
    item.body = body
    item.meterSummary = meterSummary
    item.createdAt = `${Date.now()}`
    list.unshift(item)
    await CourtyardLocalStore.putStr(KEY_WORK, JSON.stringify(list))
    AppStorage.setOrCreate(KEY_WORK, JSON.stringify(list))
    return item
  }

  static async removeWork(id: string): Promise<void> {
    const list = CourtyardLocalStore.works()
    const next: WorkItem[] = []
    for (const w of list) {
      if (w.id !== id) {
        next.push(w)
      }
    }
    await CourtyardLocalStore.putStr(KEY_WORK, JSON.stringify(next))
    AppStorage.setOrCreate(KEY_WORK, JSON.stringify(next))
  }

  static async markRead(poemId: string): Promise<void> {
    const raw = AppStorage.get<string>(KEY_READ) ?? ''
    if (raw.indexOf(poemId) >= 0) {
      return
    }
    const next = raw.length > 0 ? `${raw}|${poemId}` : poemId
    await CourtyardLocalStore.putStr(KEY_READ, next)
    AppStorage.setOrCreate(KEY_READ, next)
  }

  static readCount(): number {
    const raw = AppStorage.get<string>(KEY_READ) ?? ''
    if (raw.length === 0) {
      return 0
    }
    return raw.split('|').length
  }

  static async bumpDetect(): Promise<void> {
    const n = (AppStorage.get<number>(KEY_DETECT) ?? 0) + 1
    AppStorage.setOrCreate(KEY_DETECT, n)
    await CourtyardLocalStore.putNum(KEY_DETECT, n)
  }

  static detectCount(): number {
    return AppStorage.get<number>(KEY_DETECT) ?? 0
  }

  static rhymeBook(): string {
    return AppStorage.get<string>(KEY_BOOK) ?? '平水韵'
  }

  static async setRhymeBook(book: string): Promise<void> {
    AppStorage.setOrCreate(KEY_BOOK, book)
    await CourtyardLocalStore.putStr(KEY_BOOK, book)
  }

  static colorMode(): string {
    return AppStorage.get<string>(KEY_THEME) ?? 'system'
  }

  static async setColorMode(mode: string): Promise<void> {
    AppStorage.setOrCreate(KEY_THEME, mode)
    await CourtyardLocalStore.putStr(KEY_THEME, mode)
  }

  static fontScale(): number {
    return AppStorage.get<number>(KEY_FONT) ?? 1
  }

  static async setFontScale(v: number): Promise<void> {
    AppStorage.setOrCreate(KEY_FONT, v)
    await CourtyardLocalStore.putNum(KEY_FONT, v)
  }

  static async clearCache(): Promise<void> {
    AppStorage.setOrCreate('localCacheEpoch', Date.now())
  }

  private static async getStr(key: string, fallback: string): Promise<string> {
    if (CourtyardLocalStore.pref === null) {
      return fallback
    }
    const v = await CourtyardLocalStore.pref.get(key, fallback)
    return typeof v === 'string' ? v : fallback
  }

  private static async getNum(key: string, fallback: number): Promise<number> {
    if (CourtyardLocalStore.pref === null) {
      return fallback
    }
    const v = await CourtyardLocalStore.pref.get(key, fallback)
    return typeof v === 'number' ? v : fallback
  }

  private static async putStr(key: string, value: string): Promise<void> {
    if (CourtyardLocalStore.pref === null) {
      return
    }
    await CourtyardLocalStore.pref.put(key, value)
    await CourtyardLocalStore.pref.flush()
  }

  private static async putNum(key: string, value: number): Promise<void> {
    if (CourtyardLocalStore.pref === null) {
      return
    }
    await CourtyardLocalStore.pref.put(key, value)
    await CourtyardLocalStore.pref.flush()
  }
}
