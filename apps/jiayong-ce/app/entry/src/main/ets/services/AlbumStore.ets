import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  AlbumBundle,
  Anniversary,
  AppSettings,
  BucketItem,
  FamilyActivity,
  FamilyMember,
  FamilyPhoto,
  FamilyProfile,
  MemoryCard,
  PhotoWrite,
  RecapMonth,
  RecapSummary,
  StorageStats,
  ThemeAlbum
} from '../models/AlbumModels'
import { ImagePathUtil } from './ImagePathUtil'
import { PhotoPickService } from './PhotoPickService'

const STORE = 'jiayong_ce_local'
const KEY_BUNDLE = 'bundle'

export class AlbumStore {
  private static pref: preferences.Preferences | null = null
  private static cache: AlbumBundle = new AlbumBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      AlbumStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await AlbumStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      AlbumStore.cache = AlbumStore.parseBundle(raw)
      AlbumStore.ensureDefaults()
    } catch {
      AlbumStore.cache = new AlbumBundle()
      AlbumStore.ensureDefaults()
    }
    AlbumStore.bump()
  }

  static profile(): FamilyProfile {
    return AlbumStore.cache.profile
  }

  static members(): FamilyMember[] {
    return AlbumStore.cache.members
  }

  static albums(): ThemeAlbum[] {
    return AlbumStore.cache.albums
  }

  static anniversaries(): Anniversary[] {
    return AlbumStore.cache.anniversaries
  }

  static settings(): AppSettings {
    return AlbumStore.cache.settings
  }

  static sortedPhotos(): FamilyPhoto[] {
    const copy: FamilyPhoto[] = []
    for (const item of AlbumStore.cache.photos) {
      copy.push(item)
    }
    copy.sort((a: FamilyPhoto, b: FamilyPhoto): number => b.takenAt - a.takenAt)
    return copy
  }

  static activities(): FamilyActivity[] {
    const copy: FamilyActivity[] = []
    for (const item of AlbumStore.cache.activities) {
      copy.push(item)
    }
    copy.sort((a: FamilyActivity, b: FamilyActivity): number => b.createdAt - a.createdAt)
    return copy
  }

  static findPhoto(id: string): FamilyPhoto | null {
    for (const item of AlbumStore.cache.photos) {
      if (item.id === id) {
        return item
      }
    }
    return null
  }

  static findMember(id: string): FamilyMember | null {
    for (const item of AlbumStore.cache.members) {
      if (item.id === id) {
        return item
      }
    }
    return null
  }

  static storageStats(): StorageStats {
    const s = new StorageStats()
    s.photoCount = AlbumStore.cache.photos.length
    s.favoriteCount = AlbumStore.favorites().length
    s.locationCount = AlbumStore.locations().length
    let used = 0
    for (const p of AlbumStore.cache.photos) {
      used += PhotoPickService.estimateFileSize(p.uri)
    }
    s.usedBytes = used
    return s
  }

  static formatBytes(bytes: number): string {
    if (bytes < 1024) {
      return `${bytes} B`
    }
    if (bytes < 1048576) {
      return `${Math.round(bytes / 1024)} KB`
    }
    if (bytes < 1073741824) {
      return `${(bytes / 1048576).toFixed(1)} MB`
    }
    return `${(bytes / 1073741824).toFixed(2)} GB`
  }

  static memoryToday(): FamilyPhoto[] {
    const now = new Date()
    const m = now.getMonth() + 1
    const d = now.getDate()
    const out: FamilyPhoto[] = []
    for (const p of AlbumStore.cache.photos) {
      const dt = new Date(p.takenAt)
      if (dt.getMonth() + 1 === m && dt.getDate() === d && dt.getFullYear() < now.getFullYear()) {
        out.push(p)
      }
    }
    return out
  }

  static upcomingAnniversaries(): Anniversary[] {
    const now = new Date()
    const m = now.getMonth() + 1
    const out: Anniversary[] = []
    for (const a of AlbumStore.cache.anniversaries) {
      if (a.month === m) {
        out.push(a)
      }
    }
    return out
  }

  static byMember(memberId: string): FamilyPhoto[] {
    const out: FamilyPhoto[] = []
    for (const p of AlbumStore.sortedPhotos()) {
      if (p.memberId === memberId) {
        out.push(p)
      }
    }
    return out
  }

  static byLocation(location: string): FamilyPhoto[] {
    const key = location.trim()
    const out: FamilyPhoto[] = []
    for (const p of AlbumStore.sortedPhotos()) {
      if (p.location.trim() === key) {
        out.push(p)
      }
    }
    return out
  }

  static byMonth(key: string): FamilyPhoto[] {
    const out: FamilyPhoto[] = []
    for (const p of AlbumStore.sortedPhotos()) {
      if (AlbumStore.monthKey(p.takenAt) === key) {
        out.push(p)
      }
    }
    return out
  }

  static byAlbum(albumId: string): FamilyPhoto[] {
    const out: FamilyPhoto[] = []
    for (const p of AlbumStore.sortedPhotos()) {
      if (p.albumId === albumId) {
        out.push(p)
      }
    }
    return out
  }

  static favorites(): FamilyPhoto[] {
    const out: FamilyPhoto[] = []
    for (const p of AlbumStore.sortedPhotos()) {
      if (p.favorited) {
        out.push(p)
      }
    }
    return out
  }

  static search(query: string): FamilyPhoto[] {
    const q = query.trim()
    if (q.length === 0) {
      return AlbumStore.sortedPhotos()
    }
    const out: FamilyPhoto[] = []
    for (const p of AlbumStore.sortedPhotos()) {
      if (p.caption.indexOf(q) >= 0 || p.location.indexOf(q) >= 0 || p.uploadedBy.indexOf(q) >= 0) {
        out.push(p)
      }
    }
    return out
  }

  static locations(): string[] {
    return AlbumStore.uniqueLocations()
  }

  static memberBuckets(): BucketItem[] {
    const items: BucketItem[] = []
    for (const m of AlbumStore.cache.members) {
      const b = new BucketItem()
      b.key = m.id
      b.label = `${m.name} · ${m.relation}`
      b.count = AlbumStore.byMember(m.id).length
      items.push(b)
    }
    return items
  }

  static locationBuckets(): BucketItem[] {
    const items: BucketItem[] = []
    for (const loc of AlbumStore.locations()) {
      const b = new BucketItem()
      b.key = loc
      b.label = loc
      b.count = AlbumStore.byLocation(loc).length
      items.push(b)
    }
    return items
  }

  static monthBuckets(): BucketItem[] {
    const keys = AlbumStore.uniqueMonths()
    keys.sort((a: string, b: string): number => b.localeCompare(a))
    const items: BucketItem[] = []
    for (const key of keys) {
      const b = new BucketItem()
      b.key = key
      b.label = key.replace('-', '年') + '月'
      b.count = AlbumStore.byMonth(key).length
      items.push(b)
    }
    return items
  }

  static timelineGroups(): MemoryCard[] {
    const groups: MemoryCard[] = []
    for (const p of AlbumStore.sortedPhotos()) {
      const dt = new Date(p.takenAt)
      const y = dt.getFullYear()
      const mo = dt.getMonth() + 1
      const d = dt.getDate()
      let found: MemoryCard | null = null
      for (const g of groups) {
        if (g.year === y && g.month === mo && g.day === d) {
          found = g
          break
        }
      }
      if (found === null) {
        const card = new MemoryCard()
        card.year = y
        card.month = mo
        card.day = d
        card.photos.push(p)
        groups.push(card)
      } else {
        found.photos.push(p)
      }
    }
    return groups
  }

  static recap(): RecapSummary {
    const s = new RecapSummary()
    const now = new Date()
    const ym = AlbumStore.monthKey(now.getTime())
    s.photoCount = AlbumStore.cache.photos.length
    s.favoriteCount = AlbumStore.favorites().length
    s.locationCount = AlbumStore.locations().length
    s.memberCount = AlbumStore.cache.members.length
    s.thisMonth = AlbumStore.byMonth(ym).length
    s.months = []
    const buckets = AlbumStore.monthBuckets()
    let n = 0
    for (const b of buckets) {
      if (n >= 6) {
        break
      }
      const row = new RecapMonth()
      row.label = b.label
      row.count = b.count
      s.months.push(row)
      n += 1
    }
    return s
  }

  static async saveSettings(settings: AppSettings): Promise<boolean> {
    AlbumStore.cache.settings = settings
    return AlbumStore.persist()
  }

  static async updateProfile(name: string): Promise<boolean> {
    AlbumStore.cache.profile.name = name.trim().length > 0 ? name.trim() : '我的家庭'
    return AlbumStore.persist()
  }

  static async addMember(name: string, relation: string): Promise<boolean> {
    const m = new FamilyMember()
    m.id = AlbumStore.newId('mem')
    m.name = name.trim()
    m.relation = relation.trim().length > 0 ? relation.trim() : '家人'
    m.avatarColor = AlbumStore.pickColor(AlbumStore.cache.members.length)
    m.isOwner = false
    AlbumStore.cache.members.push(m)
    return AlbumStore.persist()
  }

  static async addThemeAlbum(title: string): Promise<boolean> {
    const t = title.trim()
    if (t.length === 0) {
      return false
    }
    const a = new ThemeAlbum()
    a.id = AlbumStore.newId('alb')
    a.title = t
    a.createdAt = Date.now()
    AlbumStore.cache.albums.push(a)
    return AlbumStore.persist()
  }

  static async addAnniversary(title: string, month: number, day: number, note: string): Promise<boolean> {
    const t = title.trim()
    if (t.length === 0) {
      return false
    }
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return false
    }
    const a = new Anniversary()
    a.id = AlbumStore.newId('ann')
    a.title = t
    a.month = month
    a.day = day
    a.note = note.trim()
    AlbumStore.cache.anniversaries.push(a)
    return AlbumStore.persist()
  }

  static async deleteAnniversary(id: string): Promise<boolean> {
    const next: Anniversary[] = []
    for (const a of AlbumStore.cache.anniversaries) {
      if (a.id !== id) {
        next.push(a)
      }
    }
    AlbumStore.cache.anniversaries = next
    return AlbumStore.persist()
  }

  static async addPhotos(uris: string[], write: PhotoWrite, uploaderName: string): Promise<number> {
    let count = 0
    const now = Date.now()
    const taken = write.takenAt > 0 ? write.takenAt : now
    const loc = write.location.trim().length > 0 ? write.location.trim() : '家庭日常'
    for (const uri of uris) {
      if (uri.length === 0) {
        continue
      }
      const p = new FamilyPhoto()
      p.id = AlbumStore.newId('ph')
      p.uri = ImagePathUtil.normalizeStored(uri)
      p.caption = write.caption.trim()
      p.takenAt = taken
      p.memberId = write.memberId
      p.location = loc
      p.isVideo = false
      p.uploadedBy = uploaderName
      p.createdAt = now
      p.favorited = write.favorited
      p.albumId = write.albumId
      AlbumStore.cache.photos.push(p)

      const act = new FamilyActivity()
      act.id = AlbumStore.newId('act')
      act.memberId = write.memberId
      act.memberName = uploaderName
      act.action = 'upload'
      act.photoId = p.id
      act.caption = p.caption.length > 0 ? p.caption : `整理到「${loc}」`
      act.createdAt = now
      AlbumStore.cache.activities.push(act)
      count += 1
    }
    if (count > 0) {
      await AlbumStore.persist()
    }
    return count
  }

  static async updatePhoto(id: string, write: PhotoWrite): Promise<boolean> {
    const p = AlbumStore.findPhoto(id)
    if (p === null) {
      return false
    }
    p.caption = write.caption.trim()
    p.location = write.location.trim().length > 0 ? write.location.trim() : '家庭日常'
    p.memberId = write.memberId
    if (write.takenAt > 0) {
      p.takenAt = write.takenAt
    }
    p.albumId = write.albumId
    p.favorited = write.favorited
    return AlbumStore.persist()
  }

  static async toggleFavorite(id: string): Promise<boolean> {
    const p = AlbumStore.findPhoto(id)
    if (p === null) {
      return false
    }
    p.favorited = !p.favorited
    return AlbumStore.persist()
  }

  static async deletePhoto(id: string): Promise<boolean> {
    const next: FamilyPhoto[] = []
    for (const p of AlbumStore.cache.photos) {
      if (p.id !== id) {
        next.push(p)
      }
    }
    AlbumStore.cache.photos = next
    const acts: FamilyActivity[] = []
    for (const a of AlbumStore.cache.activities) {
      if (a.photoId !== id) {
        acts.push(a)
      }
    }
    AlbumStore.cache.activities = acts
    return AlbumStore.persist()
  }

  static async deletePhotos(ids: string[]): Promise<boolean> {
    const next: FamilyPhoto[] = []
    for (const p of AlbumStore.cache.photos) {
      let drop = false
      for (const id of ids) {
        if (p.id === id) {
          drop = true
          break
        }
      }
      if (!drop) {
        next.push(p)
      }
    }
    AlbumStore.cache.photos = next
    return AlbumStore.persist()
  }

  static inviteLink(): string {
    return `jiayongce://join/${AlbumStore.cache.profile.inviteCode}`
  }

  private static uniqueLocations(): string[] {
    const keys: string[] = []
    for (const p of AlbumStore.cache.photos) {
      const loc = p.location.trim()
      if (loc.length === 0) {
        continue
      }
      let exists = false
      for (const k of keys) {
        if (k === loc) {
          exists = true
          break
        }
      }
      if (!exists) {
        keys.push(loc)
      }
    }
    return keys
  }

  private static uniqueMonths(): string[] {
    const keys: string[] = []
    for (const p of AlbumStore.cache.photos) {
      const loc = AlbumStore.monthKey(p.takenAt)
      let exists = false
      for (const k of keys) {
        if (k === loc) {
          exists = true
          break
        }
      }
      if (!exists) {
        keys.push(loc)
      }
    }
    return keys
  }

  private static monthKey(ts: number): string {
    const d = new Date(ts)
    const m = d.getMonth() + 1
    const mm = m < 10 ? `0${m}` : `${m}`
    return `${d.getFullYear()}-${mm}`
  }

  private static ensureDefaults(): void {
    if (AlbumStore.cache.profile.inviteCode.length === 0) {
      AlbumStore.cache.profile.inviteCode = AlbumStore.newId('inv').slice(-8).toUpperCase()
    }
    if (AlbumStore.cache.members.length === 0) {
      const owner = new FamilyMember()
      owner.id = AlbumStore.newId('mem')
      owner.name = AlbumStore.cache.settings.displayName.length > 0
        ? AlbumStore.cache.settings.displayName : '我'
      owner.relation = '家长'
      owner.avatarColor = '#E8862E'
      owner.isOwner = true
      AlbumStore.cache.members.push(owner)
    }
    if (AlbumStore.cache.albums.length === 0) {
      AlbumStore.seedAlbums()
    }
  }

  private static seedAlbums(): void {
    const titles: string[] = ['日常点滴', '家庭出游', '生日纪念日']
    for (const t of titles) {
      const a = new ThemeAlbum()
      a.id = AlbumStore.newId('alb')
      a.title = t
      a.createdAt = Date.now()
      AlbumStore.cache.albums.push(a)
    }
  }

  private static pickColor(index: number): string {
    const palette: string[] = ['#E8862E', '#2D3A4A', '#6B8F71', '#C4A574', '#8B7355', '#5A7A9A']
    return palette[index % palette.length]
  }

  private static newId(prefix: string): string {
    return `${prefix}_${Date.now()}_${Math.floor(Math.random() * 100000)}`
  }

  private static bump(): void {
    const rev = AppStorage.get<number>('albumRev')
    const next = (typeof rev === 'number' ? rev : 0) + 1
    AppStorage.setOrCreate('albumRev', next)
  }

  private static async persist(): Promise<boolean> {
    if (AlbumStore.pref === null) {
      AlbumStore.bump()
      return true
    }
    try {
      await AlbumStore.pref.put(KEY_BUNDLE, JSON.stringify(AlbumStore.cache))
      await AlbumStore.pref.flush()
      AlbumStore.bump()
      return true
    } catch {
      AlbumStore.bump()
      return false
    }
  }

  private static parseBundle(raw: string): AlbumBundle {
    const bundle = new AlbumBundle()
    if (raw.length === 0) {
      return bundle
    }
    try {
      const data = JSON.parse(raw) as AlbumBundle
      if (data.photos !== undefined) {
        bundle.photos = AlbumStore.hydratePhotos(data.photos)
      }
      if (data.members !== undefined) {
        bundle.members = data.members
      }
      if (data.activities !== undefined) {
        bundle.activities = data.activities
      }
      if (data.albums !== undefined) {
        bundle.albums = data.albums
      }
      if (data.anniversaries !== undefined) {
        bundle.anniversaries = data.anniversaries
      }
      if (data.profile !== undefined) {
        bundle.profile = data.profile
      }
      if (data.settings !== undefined) {
        bundle.settings = data.settings
      }
    } catch {
    }
    return bundle
  }

  private static hydratePhotos(raw: FamilyPhoto[]): FamilyPhoto[] {
    const out: FamilyPhoto[] = []
    for (const item of raw) {
      const p = new FamilyPhoto()
      p.id = item.id
      p.uri = ImagePathUtil.normalizeStored(item.uri)
      p.caption = item.caption
      p.takenAt = item.takenAt
      p.memberId = item.memberId
      p.location = item.location.length > 0 ? item.location : '家庭日常'
      p.isVideo = item.isVideo
      p.uploadedBy = item.uploadedBy
      p.createdAt = item.createdAt
      p.favorited = item.favorited === true
      p.albumId = item.albumId !== undefined ? item.albumId : ''
      out.push(p)
    }
    return out
  }
}
