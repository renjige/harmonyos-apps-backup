import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { JournalItem } from '../models/JournalModels'
import { JournalImageCatalog } from './JournalImageCatalog'

/** 本机沙箱照片索引：避免服务端丢弃 local: 后回读成预置封面 */
export class LocalPhotoStore {
  private static pref: preferences.Preferences | null = null
  private static ids: string[] = []
  private static payloads: string[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      LocalPhotoStore.pref = await preferences.getPreferences(context, 'journal_photos')
      const rawValue = await LocalPhotoStore.pref.get('index', '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      LocalPhotoStore.parseIndex(raw)
    } catch {
      LocalPhotoStore.pref = null
    }
  }

  static keysOf(id: string): string[] {
    for (let i = 0; i < LocalPhotoStore.ids.length; i++) {
      if (LocalPhotoStore.ids[i] === id) {
        return LocalPhotoStore.splitKeys(LocalPhotoStore.payloads[i])
      }
    }
    return []
  }

  static async save(id: string, keys: string[]): Promise<void> {
    const localOnly: string[] = []
    for (let i = 0; i < keys.length; i++) {
      if (JournalImageCatalog.isLocalKey(keys[i])) {
        localOnly.push(keys[i])
      }
    }
    if (id.length === 0 || localOnly.length === 0) {
      return
    }
    LocalPhotoStore.upsertMemory(id, LocalPhotoStore.joinKeys(localOnly))
    if (LocalPhotoStore.pref === null) {
      return
    }
    await LocalPhotoStore.pref.put('index', LocalPhotoStore.serializeIndex())
    await LocalPhotoStore.pref.flush()
  }

  static apply(item: JournalItem): JournalItem {
    const stored = LocalPhotoStore.keysOf(item.id)
    if (stored.length === 0) {
      return item
    }
    const merged: string[] = []
    for (let i = 0; i < item.imageKeys.length; i++) {
      merged.push(item.imageKeys[i])
    }
    for (let i = 0; i < stored.length; i++) {
      if (merged.indexOf(stored[i]) < 0) {
        merged.push(stored[i])
      }
    }
    if (merged.length === 0) {
      return item
    }
    item.imageKeys = merged
    if (item.coverKey.length === 0) {
      item.coverKey = merged[0]
    }
    item.photoCount = merged.length
    return item
  }

  private static upsertMemory(id: string, payload: string): void {
    for (let i = 0; i < LocalPhotoStore.ids.length; i++) {
      if (LocalPhotoStore.ids[i] === id) {
        LocalPhotoStore.payloads[i] = payload
        return
      }
    }
    LocalPhotoStore.ids.push(id)
    LocalPhotoStore.payloads.push(payload)
  }

  private static parseIndex(raw: string): void {
    LocalPhotoStore.ids = []
    LocalPhotoStore.payloads = []
    if (raw.length === 0) {
      return
    }
    const rows = raw.split('|||')
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i]
      const sep = row.indexOf('===')
      if (sep > 0) {
        LocalPhotoStore.ids.push(row.substring(0, sep))
        LocalPhotoStore.payloads.push(row.substring(sep + 3))
      }
    }
  }

  private static serializeIndex(): string {
    const parts: string[] = []
    for (let i = 0; i < LocalPhotoStore.ids.length; i++) {
      parts.push(`${LocalPhotoStore.ids[i]}===${LocalPhotoStore.payloads[i]}`)
    }
    return parts.join('|||')
  }

  private static joinKeys(keys: string[]): string {
    return keys.join(';;')
  }

  private static splitKeys(payload: string): string[] {
    if (payload.length === 0) {
      return []
    }
    return payload.split(';;')
  }
}
