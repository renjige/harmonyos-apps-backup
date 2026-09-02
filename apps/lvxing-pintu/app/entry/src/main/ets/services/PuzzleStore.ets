import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  AppSettings,
  PuzzleBundle,
  PuzzlePiece,
  PuzzleStats,
  TagItem,
  TravelPuzzle
} from '../models/PuzzleModels'

const STORE = 'lvxing_pintu_local'
const KEY_BUNDLE = 'bundle'
const KEY_REV = 'puzzleRev'

export class PuzzleStore {
  private static pref: preferences.Preferences | null = null
  private static cache: PuzzleBundle = new PuzzleBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      PuzzleStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await PuzzleStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      PuzzleStore.cache = PuzzleStore.parseBundle(raw)
      PuzzleStore.ensureDefaultTags()
    } catch {
      PuzzleStore.cache = new PuzzleBundle()
      PuzzleStore.ensureDefaultTags()
    }
    PuzzleStore.bump()
  }

  static snapshot(): PuzzleBundle {
    return PuzzleStore.cache
  }

  static puzzles(): TravelPuzzle[] {
    return PuzzleStore.cache.puzzles
  }

  static sortedPuzzles(): TravelPuzzle[] {
    const copy: TravelPuzzle[] = []
    for (const item of PuzzleStore.cache.puzzles) {
      copy.push(item)
    }
    copy.sort((a: TravelPuzzle, b: TravelPuzzle): number => {
      return b.createdAt - a.createdAt
    })
    return copy
  }

  static favorites(): TravelPuzzle[] {
    const out: TravelPuzzle[] = []
    for (const item of PuzzleStore.sortedPuzzles()) {
      if (item.favorited) {
        out.push(item)
      }
    }
    return out
  }

  static tags(): TagItem[] {
    return PuzzleStore.cache.tags
  }

  static settings(): AppSettings {
    return PuzzleStore.cache.settings
  }

  static findPuzzle(id: string): TravelPuzzle | null {
    for (const item of PuzzleStore.cache.puzzles) {
      if (item.id === id) {
        return item
      }
    }
    return null
  }

  static stats(): PuzzleStats {
    const s = new PuzzleStats()
    s.tripCount = PuzzleStore.cache.puzzles.length
    const cities: string[] = []
    let photos = 0
    for (const p of PuzzleStore.cache.puzzles) {
      photos += p.pieces.length
      const loc = p.location.trim()
      if (loc.length > 0) {
        let exists = false
        for (const c of cities) {
          if (c === loc) {
            exists = true
            break
          }
        }
        if (!exists) {
          cities.push(loc)
        }
      }
    }
    s.cityCount = cities.length
    s.photoCount = photos
    return s
  }

  static locations(): string[] {
    const cities: string[] = []
    for (const p of PuzzleStore.sortedPuzzles()) {
      const loc = p.location.trim()
      if (loc.length === 0) {
        continue
      }
      let exists = false
      for (const c of cities) {
        if (c === loc) {
          exists = true
          break
        }
      }
      if (!exists) {
        cities.push(loc)
      }
    }
    return cities
  }

  static async savePuzzle(puzzle: TravelPuzzle): Promise<boolean> {
    try {
      const next = PuzzleStore.cloneBundle()
      let found = false
      const list: TravelPuzzle[] = []
      for (const item of next.puzzles) {
        if (item.id === puzzle.id) {
          list.push(puzzle)
          found = true
        } else {
          list.push(item)
        }
      }
      if (!found) {
        list.push(puzzle)
      }
      next.puzzles = list
      await PuzzleStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async deletePuzzle(id: string): Promise<boolean> {
    try {
      const next = PuzzleStore.cloneBundle()
      const list: TravelPuzzle[] = []
      for (const item of next.puzzles) {
        if (item.id !== id) {
          list.push(item)
        }
      }
      next.puzzles = list
      await PuzzleStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async toggleFavorite(id: string): Promise<boolean> {
    const item = PuzzleStore.findPuzzle(id)
    if (item === null) {
      return false
    }
    item.favorited = !item.favorited
    item.updatedAt = Date.now()
    return await PuzzleStore.savePuzzle(item)
  }

  static async saveSettings(settings: AppSettings): Promise<boolean> {
    try {
      const next = PuzzleStore.cloneBundle()
      next.settings = settings
      await PuzzleStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async addTag(name: string): Promise<boolean> {
    const trimmed = name.trim()
    if (trimmed.length === 0) {
      return false
    }
    for (const t of PuzzleStore.cache.tags) {
      if (t.name === trimmed) {
        return true
      }
    }
    try {
      const next = PuzzleStore.cloneBundle()
      const tag = new TagItem()
      tag.id = `tag_${Date.now()}`
      tag.name = trimmed
      const list: TagItem[] = []
      for (const item of next.tags) {
        list.push(item)
      }
      list.push(tag)
      next.tags = list
      await PuzzleStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static async clearAll(): Promise<boolean> {
    try {
      const next = new PuzzleBundle()
      next.settings = PuzzleStore.cache.settings
      PuzzleStore.ensureDefaultTagsOn(next)
      await PuzzleStore.persist(next)
      return true
    } catch {
      return false
    }
  }

  static newId(): string {
    return `puz_${Date.now()}_${Math.floor(Math.random() * 100000)}`
  }

  static newPiece(uri: string, index: number): PuzzlePiece {
    const piece = new PuzzlePiece()
    piece.id = `piece_${Date.now()}_${index}`
    piece.imageUri = uri
    piece.takenAt = Date.now() + index
    return piece
  }

  private static ensureDefaultTags(): void {
    PuzzleStore.ensureDefaultTagsOn(PuzzleStore.cache)
  }

  private static ensureDefaultTagsOn(bundle: PuzzleBundle): void {
    if (bundle.tags.length > 0) {
      return
    }
    const defaults: string[] = ['海岛', '古镇', '美食', '山川', '城市']
    const list: TagItem[] = []
    for (let i = 0; i < defaults.length; i++) {
      const t = new TagItem()
      t.id = `tag_default_${i}`
      t.name = defaults[i]
      list.push(t)
    }
    bundle.tags = list
  }

  private static bump(): void {
    const rev = AppStorage.get<number>(KEY_REV) ?? 0
    AppStorage.setOrCreate(KEY_REV, rev + 1)
  }

  private static cloneBundle(): PuzzleBundle {
    const raw = PuzzleStore.serializeBundle(PuzzleStore.cache)
    return PuzzleStore.parseBundle(raw)
  }

  private static async persist(bundle: PuzzleBundle): Promise<void> {
    PuzzleStore.cache = bundle
    if (PuzzleStore.pref !== null) {
      await PuzzleStore.pref.put(KEY_BUNDLE, PuzzleStore.serializeBundle(bundle))
      await PuzzleStore.pref.flush()
    }
    PuzzleStore.bump()
  }

  private static serializeBundle(bundle: PuzzleBundle): string {
    const obj = new PuzzleBundleJson()
    obj.puzzles = bundle.puzzles
    obj.tags = bundle.tags
    obj.settings = bundle.settings
    return JSON.stringify(obj)
  }

  private static parseBundle(raw: string): PuzzleBundle {
    const empty = new PuzzleBundle()
    if (raw.length === 0) {
      return empty
    }
    try {
      const parsed = JSON.parse(raw) as PuzzleBundleJson
      const bundle = new PuzzleBundle()
      if (parsed.puzzles !== undefined) {
        bundle.puzzles = PuzzleStore.mapPuzzles(parsed.puzzles)
      }
      if (parsed.tags !== undefined) {
        bundle.tags = PuzzleStore.mapTags(parsed.tags)
      }
      if (parsed.settings !== undefined) {
        bundle.settings = PuzzleStore.mapSettings(parsed.settings)
      } else {
        bundle.settings = new AppSettings()
      }
      return bundle
    } catch {
      return empty
    }
  }

  private static mapPuzzles(raw: TravelPuzzle[]): TravelPuzzle[] {
    const list: TravelPuzzle[] = []
    for (const item of raw) {
      const p = new TravelPuzzle()
      p.id = item.id ?? ''
      p.title = item.title ?? ''
      p.location = item.location ?? ''
      p.layoutType = item.layoutType ?? 'grid-4'
      p.favorited = item.favorited === true
      p.createdAt = item.createdAt ?? 0
      p.updatedAt = item.updatedAt ?? 0
      p.tags = item.tags ?? []
      p.pieces = PuzzleStore.mapPieces(item.pieces ?? [])
      list.push(p)
    }
    return list
  }

  private static mapPieces(raw: PuzzlePiece[]): PuzzlePiece[] {
    const list: PuzzlePiece[] = []
    for (const item of raw) {
      const piece = new PuzzlePiece()
      piece.id = item.id ?? ''
      piece.imageUri = item.imageUri ?? ''
      piece.caption = item.caption ?? ''
      piece.location = item.location ?? ''
      piece.takenAt = item.takenAt ?? 0
      list.push(piece)
    }
    list.sort((a: PuzzlePiece, b: PuzzlePiece): number => a.takenAt - b.takenAt)
    return list
  }

  private static mapTags(raw: TagItem[]): TagItem[] {
    const list: TagItem[] = []
    for (const item of raw) {
      const t = new TagItem()
      t.id = item.id ?? ''
      t.name = item.name ?? ''
      list.push(t)
    }
    return list
  }

  private static mapSettings(raw: AppSettings): AppSettings {
    const s = new AppSettings()
    s.displayName = raw.displayName ?? ''
    s.colorMode = raw.colorMode ?? 'system'
    s.darkFollowSystem = raw.darkFollowSystem !== false
    return s
  }
}

class PuzzleBundleJson {
  puzzles: TravelPuzzle[] = []
  tags: TagItem[] = []
  settings: AppSettings = new AppSettings()
}
