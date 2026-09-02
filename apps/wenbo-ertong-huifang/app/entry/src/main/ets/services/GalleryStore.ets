import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { AppSettings, ArtworkItem, GalleryBundle } from '../models/DrawModels'

const STORE = 'kids_draw_gallery'
const KEY_BUNDLE = 'bundle'

class BundleWire {
  artworks: ArtworkItem[] = []
  totalStars: number = 0
  soundOn: boolean = true
  brushSize: string = 'mid'
  privacyAccepted: boolean = false
}

export class GalleryStore {
  private static pref: preferences.Preferences | null = null
  private static cache: GalleryBundle = new GalleryBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      GalleryStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await GalleryStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      GalleryStore.cache = GalleryStore.parse(raw)
      AppStorage.setOrCreate('privacyAccepted', GalleryStore.cache.settings.privacyAccepted)
    } catch {
      GalleryStore.cache = new GalleryBundle()
      AppStorage.setOrCreate('privacyAccepted', false)
    }
  }

  static snapshot(): GalleryBundle {
    return GalleryStore.cache
  }

  static settings(): AppSettings {
    return GalleryStore.cache.settings
  }

  static artworks(): ArtworkItem[] {
    return GalleryStore.cache.artworks
  }

  static privacyAccepted(): boolean {
    return GalleryStore.cache.settings.privacyAccepted
  }

  static async acceptPrivacy(): Promise<void> {
    GalleryStore.cache.settings.privacyAccepted = true
    AppStorage.setOrCreate('privacyAccepted', true)
    await GalleryStore.persist()
  }

  static async revokePrivacy(): Promise<void> {
    GalleryStore.cache.settings.privacyAccepted = false
    AppStorage.setOrCreate('privacyAccepted', false)
    await GalleryStore.persist()
  }

  static async addArtwork(item: ArtworkItem): Promise<void> {
    const next: ArtworkItem[] = []
    next.push(item)
    for (const a of GalleryStore.cache.artworks) {
      next.push(a)
    }
    GalleryStore.cache.artworks = next
    GalleryStore.cache.totalStars += 1
    await GalleryStore.persist()
  }

  static async updateTitle(id: string, title: string): Promise<void> {
    for (const a of GalleryStore.cache.artworks) {
      if (a.id === id) {
        a.title = title
      }
    }
    await GalleryStore.persist()
  }

  static async removeArtwork(id: string): Promise<void> {
    const next: ArtworkItem[] = []
    for (const a of GalleryStore.cache.artworks) {
      if (a.id !== id) {
        next.push(a)
      }
    }
    GalleryStore.cache.artworks = next
    await GalleryStore.persist()
  }

  static async clearCacheOnly(): Promise<void> {
    // 仅重置音效等偏好，不删作品
    GalleryStore.cache.settings.soundOn = true
    GalleryStore.cache.settings.brushSize = 'mid'
    await GalleryStore.persist()
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}`
  }

  static todayLabel(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms: string = m < 10 ? `0${m}` : `${m}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  private static async persist(): Promise<void> {
    if (!GalleryStore.pref) {
      return
    }
    const wire = new BundleWire()
    wire.artworks = GalleryStore.cache.artworks
    wire.totalStars = GalleryStore.cache.totalStars
    wire.soundOn = GalleryStore.cache.settings.soundOn
    wire.brushSize = GalleryStore.cache.settings.brushSize
    wire.privacyAccepted = GalleryStore.cache.settings.privacyAccepted
    await GalleryStore.pref.put(KEY_BUNDLE, JSON.stringify(wire))
    await GalleryStore.pref.flush()
  }

  private static parse(raw: string): GalleryBundle {
    const bundle = new GalleryBundle()
    if (raw.length === 0) {
      return bundle
    }
    try {
      const wire = JSON.parse(raw) as BundleWire
      bundle.artworks = wire.artworks ?? []
      bundle.totalStars = wire.totalStars ?? 0
      bundle.settings.soundOn = wire.soundOn !== false
      bundle.settings.brushSize = wire.brushSize ?? 'mid'
      bundle.settings.privacyAccepted = wire.privacyAccepted === true
    } catch {
      return new GalleryBundle()
    }
    return bundle
  }
}
