import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { WisdomItem } from '../models/WisdomHallModels'

const STORE_NAME = 'suzhi_local'
const KEY_FAVORITES = 'favoritesJson'
const KEY_FONT_SCALE = 'fontScale'

export class LocalFavoriteEntry {
  kind: string = ''
  targetId: string = ''
  title: string = ''

  private static escapeJson(value: string): string {
    return value.replace(/\\/g, '\\\\').replace(/"/g, '\\"')
  }

  toJsonString(): string {
    return `{"kind":"${LocalFavoriteEntry.escapeJson(this.kind)}","targetId":"${LocalFavoriteEntry.escapeJson(this.targetId)}","title":"${LocalFavoriteEntry.escapeJson(this.title)}"}`
  }

  static fromJsonRow(row: LocalFavoriteJson): LocalFavoriteEntry {
    const entry = new LocalFavoriteEntry()
    entry.kind = row.kind
    entry.targetId = row.targetId
    entry.title = row.title
    return entry
  }
}

export class LocalFavoriteJson {
  kind: string = ''
  targetId: string = ''
  title: string = ''
}

export class SuzhiLocalStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      SuzhiLocalStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const scaleValue = await SuzhiLocalStore.pref.get(KEY_FONT_SCALE, 'medium')
      const scale: string = typeof scaleValue === 'string' ? scaleValue : 'medium'
      AppStorage.setOrCreate('fontScale', scale)
    } catch {
      AppStorage.setOrCreate('fontScale', 'medium')
    }
  }

  private static async readFavorites(): Promise<LocalFavoriteEntry[]> {
    if (SuzhiLocalStore.pref === null) {
      return []
    }
    const raw = await SuzhiLocalStore.pref.get(KEY_FAVORITES, '[]')
    const text: string = typeof raw === 'string' ? raw : '[]'
    const list: LocalFavoriteEntry[] = []
    try {
      const parsed = JSON.parse(text) as LocalFavoriteJson[]
      for (const row of parsed) {
        const entry = LocalFavoriteEntry.fromJsonRow(row)
        if (entry.targetId.length > 0) {
          list.push(entry)
        }
      }
    } catch {
      return []
    }
    return list
  }

  private static async writeFavorites(items: LocalFavoriteEntry[]): Promise<void> {
    if (SuzhiLocalStore.pref === null) {
      return
    }
    const parts: string[] = []
    for (const item of items) {
      parts.push(item.toJsonString())
    }
    await SuzhiLocalStore.pref.put(KEY_FAVORITES, `[${parts.join(',')}]`)
    await SuzhiLocalStore.pref.flush()
  }

  static async loadFavorites(): Promise<WisdomItem[]> {
    const entries = await SuzhiLocalStore.readFavorites()
    const items: WisdomItem[] = []
    for (const entry of entries) {
      const item = new WisdomItem()
      item.id = `${entry.kind}_${entry.targetId}`
      item.targetKind = entry.kind
      item.targetId = entry.targetId
      item.title = entry.title
      items.push(item)
    }
    return items
  }

  static async isFavorite(kind: string, targetId: string): Promise<boolean> {
    const entries = await SuzhiLocalStore.readFavorites()
    for (const entry of entries) {
      if (entry.kind === kind && entry.targetId === targetId) {
        return true
      }
    }
    return false
  }

  static async addFavorite(kind: string, targetId: string, title: string): Promise<boolean> {
    const entries = await SuzhiLocalStore.readFavorites()
    for (const entry of entries) {
      if (entry.kind === kind && entry.targetId === targetId) {
        return true
      }
    }
    const next = new LocalFavoriteEntry()
    next.kind = kind
    next.targetId = targetId
    next.title = title
    entries.push(next)
    await SuzhiLocalStore.writeFavorites(entries)
    AppStorage.setOrCreate('whRefresh', (AppStorage.get<number>('whRefresh') ?? 0) + 1)
    return true
  }

  static async removeFavorite(kind: string, targetId: string): Promise<boolean> {
    const entries = await SuzhiLocalStore.readFavorites()
    const kept: LocalFavoriteEntry[] = []
    for (const entry of entries) {
      if (!(entry.kind === kind && entry.targetId === targetId)) {
        kept.push(entry)
      }
    }
    await SuzhiLocalStore.writeFavorites(kept)
    AppStorage.setOrCreate('whRefresh', (AppStorage.get<number>('whRefresh') ?? 0) + 1)
    return true
  }

  static async setFontScale(scale: string): Promise<void> {
    AppStorage.setOrCreate('fontScale', scale)
    if (SuzhiLocalStore.pref !== null) {
      await SuzhiLocalStore.pref.put(KEY_FONT_SCALE, scale)
      await SuzhiLocalStore.pref.flush()
    }
  }

  static bodySize(): number {
    const scale = AppStorage.get<string>('fontScale') ?? 'medium'
    if (scale === 'small') {
      return 14
    }
    if (scale === 'large') {
      return 18
    }
    return 16
  }
}
