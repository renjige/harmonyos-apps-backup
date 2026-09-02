import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { HazardItem } from '../models/HazardModels'

const STORE = 'site_hazard_local'
const KEY_HAZARDS = 'hazards'
const KEY_INSPECT_COUNT = 'inspectCountToday'
const KEY_INSPECT_DAY = 'inspectDay'
const KEY_SYNC_PAUSED = 'syncPaused'

export class HazardLocalStore {
  private static pref: preferences.Preferences | null = null
  private static cache: HazardItem[] = []
  private static ownerId: string = 'local'
  private static remoteSyncPaused: boolean = false

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      HazardLocalStore.pref = await preferences.getPreferences(context, STORE)
      HazardLocalStore.ownerId = HazardLocalStore.resolveOwnerId()
      await HazardLocalStore.loadOwnerData()
    } catch {
      HazardLocalStore.cache = []
      HazardLocalStore.remoteSyncPaused = false
      AppStorage.setOrCreate('todayInspectLocal', 0)
    }
  }

  static resolveOwnerId(): string {
    const name = AppStorage.get<string>('currentUsername') ?? ''
    if (name.length > 0) {
      return name
    }
    return 'local'
  }

  static currentOwnerId(): string {
    return HazardLocalStore.ownerId
  }

  static isRemoteSyncPaused(): boolean {
    return HazardLocalStore.remoteSyncPaused
  }

  static async switchOwner(ownerId: string): Promise<void> {
    const next = ownerId.length > 0 ? ownerId : 'local'
    if (next === HazardLocalStore.ownerId) {
      return
    }
    HazardLocalStore.ownerId = next
    await HazardLocalStore.loadOwnerData()
    if (!HazardLocalStore.isRemoteSyncPaused()) {
      AppStorage.setOrCreate('hazardDataEpoch', (AppStorage.get<number>('hazardDataEpoch') ?? 0) + 1)
    }
  }

  static async resumeRemoteSync(): Promise<void> {
    HazardLocalStore.remoteSyncPaused = false
    if (HazardLocalStore.pref === null) {
      return
    }
    await HazardLocalStore.pref.put(HazardLocalStore.syncPausedKey(), false)
    await HazardLocalStore.pref.flush()
  }

  private static async loadOwnerData(): Promise<void> {
    if (HazardLocalStore.pref === null) {
      HazardLocalStore.cache = []
      HazardLocalStore.remoteSyncPaused = false
      AppStorage.setOrCreate('todayInspectLocal', 0)
      return
    }
    const rawValue = await HazardLocalStore.pref.get(HazardLocalStore.hazardsKey(), '')
    const raw: string = typeof rawValue === 'string' ? rawValue : ''
    HazardLocalStore.cache = HazardLocalStore.parse(raw)
    if (HazardLocalStore.cache.length === 0) {
      const legacy = await HazardLocalStore.pref.get(KEY_HAZARDS, '')
      const legacyRaw: string = typeof legacy === 'string' ? legacy : ''
      if (legacyRaw.length > 1 && HazardLocalStore.ownerId === 'local') {
        HazardLocalStore.cache = HazardLocalStore.parse(legacyRaw)
        await HazardLocalStore.saveAll(HazardLocalStore.cache)
        await HazardLocalStore.pref.delete(KEY_HAZARDS)
        await HazardLocalStore.pref.flush()
      }
    }
    const pausedValue = await HazardLocalStore.pref.get(HazardLocalStore.syncPausedKey(), false)
    HazardLocalStore.remoteSyncPaused = pausedValue === true
    const today = HazardLocalStore.todayKey()
    const dayValue = await HazardLocalStore.pref.get(HazardLocalStore.inspectDayKey(), '')
    const day: string = typeof dayValue === 'string' ? dayValue : ''
    if (day === today) {
      const n = await HazardLocalStore.pref.get(HazardLocalStore.inspectCountKey(), 0)
      const count = typeof n === 'number' ? n : 0
      AppStorage.setOrCreate('todayInspectLocal', count)
    } else {
      AppStorage.setOrCreate('todayInspectLocal', 0)
    }
  }

  static all(): HazardItem[] {
    return HazardLocalStore.cache
  }

  static async saveAll(items: HazardItem[]): Promise<void> {
    HazardLocalStore.cache = items
    let json = '['
    for (let i = 0; i < items.length; i++) {
      if (i > 0) {
        json += ','
      }
      json += items[i].toJsonString()
    }
    json += ']'
    if (HazardLocalStore.pref === null) {
      return
    }
    await HazardLocalStore.pref.put(HazardLocalStore.hazardsKey(), json)
    await HazardLocalStore.pref.flush()
  }

  static async upsert(item: HazardItem): Promise<void> {
    await HazardLocalStore.resumeRemoteSync()
    const next: HazardItem[] = []
    let found = false
    for (const row of HazardLocalStore.cache) {
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
    await HazardLocalStore.saveAll(next)
  }

  static async clearAll(): Promise<void> {
    HazardLocalStore.cache = []
    HazardLocalStore.remoteSyncPaused = true
    AppStorage.setOrCreate('todayInspectLocal', 0)
    AppStorage.setOrCreate('hazardDataEpoch', (AppStorage.get<number>('hazardDataEpoch') ?? 0) + 1)
    if (HazardLocalStore.pref === null) {
      return
    }
    await HazardLocalStore.pref.put(HazardLocalStore.hazardsKey(), '[]')
    await HazardLocalStore.pref.put(HazardLocalStore.inspectDayKey(), '')
    await HazardLocalStore.pref.put(HazardLocalStore.inspectCountKey(), 0)
    await HazardLocalStore.pref.put(HazardLocalStore.syncPausedKey(), true)
    await HazardLocalStore.clearLegacyKeys()
    await HazardLocalStore.pref.flush()
  }

  private static async clearLegacyKeys(): Promise<void> {
    if (HazardLocalStore.pref === null) {
      return
    }
    await HazardLocalStore.pref.delete(KEY_HAZARDS)
    await HazardLocalStore.pref.delete(KEY_INSPECT_DAY)
    await HazardLocalStore.pref.delete(KEY_INSPECT_COUNT)
  }

  static async bumpInspect(): Promise<void> {
    await HazardLocalStore.resumeRemoteSync()
    if (HazardLocalStore.pref === null) {
      return
    }
    const today = HazardLocalStore.todayKey()
    const dayValue = await HazardLocalStore.pref.get(HazardLocalStore.inspectDayKey(), '')
    const day: string = typeof dayValue === 'string' ? dayValue : ''
    let count = 1
    if (day === today) {
      const n = await HazardLocalStore.pref.get(HazardLocalStore.inspectCountKey(), 0)
      count = (typeof n === 'number' ? n : 0) + 1
    }
    await HazardLocalStore.pref.put(HazardLocalStore.inspectDayKey(), today)
    await HazardLocalStore.pref.put(HazardLocalStore.inspectCountKey(), count)
    await HazardLocalStore.pref.flush()
    AppStorage.setOrCreate('todayInspectLocal', count)
  }

  static todayInspect(): number {
    return AppStorage.get<number>('todayInspectLocal') ?? 0
  }

  static todayKey(): string {
    return HazardLocalStore.dateKey(new Date())
  }

  static dateKey(d: Date): string {
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  static isSameLocalDay(iso: string, dayKey: string): boolean {
    if (iso.length === 0) {
      return false
    }
    const d = new Date(iso)
    const ts = d.getTime()
    if (Number.isNaN(ts)) {
      return iso.length >= 10 && iso.substring(0, 10) === dayKey
    }
    return HazardLocalStore.dateKey(d) === dayKey
  }

  private static hazardsKey(): string {
    return `${KEY_HAZARDS}_${HazardLocalStore.ownerId}`
  }

  private static inspectDayKey(): string {
    return `${KEY_INSPECT_DAY}_${HazardLocalStore.ownerId}`
  }

  private static inspectCountKey(): string {
    return `${KEY_INSPECT_COUNT}_${HazardLocalStore.ownerId}`
  }

  private static syncPausedKey(): string {
    return `${KEY_SYNC_PAUSED}_${HazardLocalStore.ownerId}`
  }

  private static parse(raw: string): HazardItem[] {
    if (raw.length < 2) {
      return []
    }
    try {
      const arr = JSON.parse(raw) as HazardItem[]
      const mapped: HazardItem[] = []
      for (const row of arr) {
        mapped.push(HazardItem.from(row))
      }
      return mapped
    } catch {
      return []
    }
  }
}
