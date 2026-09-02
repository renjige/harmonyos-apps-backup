import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { HuntNote, HuntProgressState, HuntRecord } from '../models/PoetryModels'
import { PoetryNav } from './PoetryNav'
import { Theme } from '../components/design-system/Theme'

const STORE = 'shici_xunbao_progress'
const KEY = 'state'

export class HuntProgressStore {
  private static pref: preferences.Preferences | null = null
  private static cache: HuntProgressState = new HuntProgressState()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      HuntProgressStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await HuntProgressStore.pref.get(KEY, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      HuntProgressStore.cache = HuntProgressStore.parse(raw)
    } catch {
      HuntProgressStore.cache = new HuntProgressState()
    }
    HuntProgressStore.applyTheme()
    HuntProgressStore.publish()
  }

  static snapshot(): HuntProgressState {
    return HuntProgressStore.cache
  }

  static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  static greeting(): string {
    const h = new Date().getHours()
    if (h < 11) {
      return '晨卷初展，来寻一首好诗'
    }
    if (h < 17) {
      return '午后披卷，闯一关点亮诗地'
    }
    return '夜读未央，墨香里寻宝'
  }

  static isFavorite(id: string): boolean {
    return HuntProgressStore.cache.favorites.indexOf(id) >= 0
  }

  static isCleared(id: string): boolean {
    return HuntProgressStore.cache.clearedLevelIds.indexOf(id) >= 0
  }

  static isPlaceOn(id: string): boolean {
    return HuntProgressStore.cache.unlockedPlaceIds.indexOf(id) >= 0
  }

  static isMedalOn(id: string): boolean {
    return HuntProgressStore.cache.medalIds.indexOf(id) >= 0
  }

  static hiddenReady(): boolean {
    return HuntProgressStore.hasAll(['ph_lv_13', 'ph_lv_14', 'ph_lv_15'])
  }

  static noteFor(poemId: string): HuntNote | undefined {
    for (const n of HuntProgressStore.cache.notes) {
      if (n.poemId === poemId) {
        return n
      }
    }
    return undefined
  }

  static async toggleFavorite(id: string): Promise<void> {
    const next: string[] = []
    let found = false
    for (const x of HuntProgressStore.cache.favorites) {
      if (x === id) {
        found = true
      } else {
        next.push(x)
      }
    }
    if (!found) {
      next.push(id)
    }
    HuntProgressStore.cache.favorites = next
    HuntProgressStore.refreshMedals()
    await HuntProgressStore.flush()
  }

  static async saveNote(poemId: string, title: string, body: string): Promise<void> {
    const next: HuntNote[] = []
    let replaced = false
    for (const n of HuntProgressStore.cache.notes) {
      if (n.poemId === poemId) {
        if (body.trim().length > 0) {
          const row = new HuntNote()
          row.poemId = poemId
          row.title = title
          row.body = body.trim()
          row.at = HuntProgressStore.todayKey()
          next.push(row)
        }
        replaced = true
      } else {
        next.push(n)
      }
    }
    if (!replaced && body.trim().length > 0) {
      const row = new HuntNote()
      row.poemId = poemId
      row.title = title
      row.body = body.trim()
      row.at = HuntProgressStore.todayKey()
      next.push(row)
    }
    HuntProgressStore.cache.notes = next
    await HuntProgressStore.flush()
  }

  static async completeLevel(levelId: string, title: string, coins: number, placeId: string): Promise<void> {
    if (HuntProgressStore.cache.clearedLevelIds.indexOf(levelId) < 0) {
      HuntProgressStore.cache.clearedLevelIds.push(levelId)
      HuntProgressStore.cache.coins = HuntProgressStore.cache.coins + coins
    }
    if (placeId.length > 0 && HuntProgressStore.cache.unlockedPlaceIds.indexOf(placeId) < 0) {
      HuntProgressStore.cache.unlockedPlaceIds.push(placeId)
    }
    HuntProgressStore.cache.hiddenUnlocked = HuntProgressStore.hiddenReady()
    const rec = new HuntRecord()
    rec.levelId = levelId
    rec.title = title
    rec.coins = coins
    rec.at = HuntProgressStore.todayKey()
    const records: HuntRecord[] = []
    records.push(rec)
    let n = 0
    for (const old of HuntProgressStore.cache.records) {
      if (n >= 39) {
        break
      }
      records.push(old)
      n++
    }
    HuntProgressStore.cache.records = records
    HuntProgressStore.refreshMedals()
    await HuntProgressStore.flush()
  }

  static async setFontScale(scale: number): Promise<void> {
    HuntProgressStore.cache.fontScale = scale
    await HuntProgressStore.flush()
  }

  static async setColorMode(mode: string): Promise<void> {
    HuntProgressStore.cache.colorMode = mode
    HuntProgressStore.applyTheme()
    await HuntProgressStore.flush()
  }

  static async clearLocalCache(): Promise<void> {
    AppStorage.setOrCreate('poemCacheJson', '')
    AppStorage.setOrCreate('placeCacheJson', '')
    AppStorage.setOrCreate('levelCacheJson', '')
    PoetryNav.bump()
  }

  private static hasAll(ids: string[]): boolean {
    for (const id of ids) {
      if (HuntProgressStore.cache.clearedLevelIds.indexOf(id) < 0) {
        return false
      }
    }
    return true
  }

  private static refreshMedals(): void {
    const ids: string[] = []
    if (HuntProgressStore.cache.clearedLevelIds.length >= 1) {
      ids.push('ph_md_first')
    }
    if (HuntProgressStore.cache.coins >= 50) {
      ids.push('ph_md_coins50')
    }
    if (HuntProgressStore.cache.unlockedPlaceIds.length >= 5) {
      ids.push('ph_md_places5')
    }
    if (HuntProgressStore.cache.favorites.length >= 20) {
      ids.push('ph_md_library20')
    }
    if (HuntProgressStore.hasAll(['ph_lv_09', 'ph_lv_10', 'ph_lv_11', 'ph_lv_12'])) {
      ids.push('ph_md_master')
    }
    if (HuntProgressStore.cache.hiddenUnlocked || HuntProgressStore.cache.clearedLevelIds.indexOf('ph_lv_16') >= 0) {
      ids.push('ph_md_hidden')
    }
    HuntProgressStore.cache.medalIds = ids
  }

  private static applyTheme(): void {
    const mode = HuntProgressStore.cache.colorMode
    if (mode === 'dark') {
      Theme.setColorMode('dark')
    } else if (mode === 'light') {
      Theme.setColorMode('light')
    } else {
      Theme.setColorMode('system')
    }
  }

  private static parse(raw: string): HuntProgressState {
    const state = new HuntProgressState()
    if (raw.length === 0) {
      return state
    }
    try {
      const obj = JSON.parse(raw) as HuntProgressState
      state.coins = obj.coins ?? 0
      if (obj.clearedLevelIds !== undefined) {
        state.clearedLevelIds = obj.clearedLevelIds
      }
      if (obj.unlockedPlaceIds !== undefined) {
        state.unlockedPlaceIds = obj.unlockedPlaceIds
      }
      if (obj.favorites !== undefined) {
        state.favorites = obj.favorites
      }
      if (obj.medalIds !== undefined) {
        state.medalIds = obj.medalIds
      }
      if (obj.notes !== undefined) {
        state.notes = obj.notes
      }
      if (obj.records !== undefined) {
        state.records = obj.records
      }
      state.hiddenUnlocked = obj.hiddenUnlocked === true
      state.fontScale = obj.fontScale ?? 100
      if (obj.colorMode !== undefined && obj.colorMode.length > 0) {
        state.colorMode = obj.colorMode
      }
    } catch {
      return new HuntProgressState()
    }
    return state
  }

  private static async flush(): Promise<void> {
    HuntProgressStore.publish()
    if (HuntProgressStore.pref === null) {
      return
    }
    try {
      await HuntProgressStore.pref.put(KEY, JSON.stringify(HuntProgressStore.cache))
      await HuntProgressStore.pref.flush()
    } catch {
      return
    }
  }

  private static publish(): void {
    AppStorage.setOrCreate('huntCoins', HuntProgressStore.cache.coins)
    AppStorage.setOrCreate('huntCleared', HuntProgressStore.cache.clearedLevelIds.length)
    AppStorage.setOrCreate('huntPlaces', HuntProgressStore.cache.unlockedPlaceIds.length)
    AppStorage.setOrCreate('huntFavs', HuntProgressStore.cache.favorites.length)
    AppStorage.setOrCreate('huntFontScale', HuntProgressStore.cache.fontScale)
    AppStorage.setOrCreate('huntColorMode', HuntProgressStore.cache.colorMode)
    AppStorage.setOrCreate('huntHidden', HuntProgressStore.cache.hiddenUnlocked)
    PoetryNav.bump()
  }
}
