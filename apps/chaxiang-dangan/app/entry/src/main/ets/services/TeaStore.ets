import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  AppSettings,
  CustomBin,
  TagItem,
  TeaBundle,
  TeaItem,
  TeaList,
  TeaPlan,
  TastingRecord,
  ThemeAlbum
} from '../models/TeaModels'
import { DateFormatUtil } from '../components/design-system/DateFormatUtil'

const STORE = 'chaxiang_dangan_v1'
const KEY_BUNDLE = 'bundle'
let seq: number = 0

export class TeaStore {
  private static pref: preferences.Preferences | null = null
  private static cache: TeaBundle = new TeaBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      TeaStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await TeaStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      TeaStore.cache = TeaStore.parseBundle(raw)
      TeaStore.ensureDefaults()
    } catch {
      TeaStore.cache = new TeaBundle()
      TeaStore.ensureDefaults()
    }
    TeaStore.bump()
  }

  static snapshot(): TeaBundle {
    return TeaStore.cache
  }

  static teas(): TeaItem[] {
    return TeaStore.cache.teas
  }

  static tastings(): TastingRecord[] {
    const list = TeaStore.cache.tastings.slice()
    list.sort((a: TastingRecord, b: TastingRecord): number => b.createdAt - a.createdAt)
    return list
  }

  static lists(): TeaList[] {
    return TeaStore.cache.lists
  }

  static albums(): ThemeAlbum[] {
    return TeaStore.cache.albums
  }

  static plans(): TeaPlan[] {
    return TeaStore.cache.plans
  }

  static tags(): TagItem[] {
    return TeaStore.cache.tags
  }

  static bins(): CustomBin[] {
    return TeaStore.cache.bins
  }

  static settings(): AppSettings {
    return TeaStore.cache.settings
  }

  static findTea(id: string): TeaItem | null {
    for (const t of TeaStore.cache.teas) {
      if (t.id === id) {
        return t
      }
    }
    return null
  }

  static findTasting(id: string): TastingRecord | null {
    for (const t of TeaStore.cache.tastings) {
      if (t.id === id) {
        return t
      }
    }
    return null
  }

  static findList(id: string): TeaList | null {
    for (const t of TeaStore.cache.lists) {
      if (t.id === id) {
        return t
      }
    }
    return null
  }

  static findAlbum(id: string): ThemeAlbum | null {
    for (const t of TeaStore.cache.albums) {
      if (t.id === id) {
        return t
      }
    }
    return null
  }

  static tastingsOfTea(teaId: string): TastingRecord[] {
    const out: TastingRecord[] = []
    for (const t of TeaStore.tastings()) {
      if (t.teaId === teaId) {
        out.push(t)
      }
    }
    return out
  }

  static lastTasting(): TastingRecord | null {
    const all = TeaStore.tastings()
    if (all.length === 0) {
      return null
    }
    return all[0]
  }

  static todayTastings(): TastingRecord[] {
    const today = DateFormatUtil.formatDate(new Date())
    const out: TastingRecord[] = []
    for (const t of TeaStore.cache.tastings) {
      if (t.dateKey === today) {
        out.push(t)
      }
    }
    return out
  }

  static teasByType(typeKey: string): TeaItem[] {
    const out: TeaItem[] = []
    for (const t of TeaStore.cache.teas) {
      if (t.typeKey === typeKey) {
        out.push(t)
      }
    }
    return out
  }

  static teasByBin(binId: string): TeaItem[] {
    const out: TeaItem[] = []
    for (const t of TeaStore.cache.teas) {
      if (t.binId === binId) {
        out.push(t)
      }
    }
    return out
  }

  static teasByStatus(status: string): TeaItem[] {
    const out: TeaItem[] = []
    for (const t of TeaStore.cache.teas) {
      if (t.stockStatus === status) {
        out.push(t)
      }
    }
    return out
  }

  static newId(prefix: string): string {
    seq += 1
    return `${prefix}${Date.now()}_${seq}`
  }

  static async saveTea(item: TeaItem): Promise<boolean> {
    item.updatedAt = Date.now()
    if (item.createdAt <= 0) {
      item.createdAt = item.updatedAt
    }
    let found = false
    for (let i = 0; i < TeaStore.cache.teas.length; i++) {
      if (TeaStore.cache.teas[i].id === item.id) {
        TeaStore.cache.teas[i] = item
        found = true
      }
    }
    if (!found) {
      TeaStore.cache.teas.unshift(item)
    }
    return TeaStore.persist()
  }

  static async deleteTea(id: string, cascade: boolean): Promise<boolean> {
    const next: TeaItem[] = []
    for (const t of TeaStore.cache.teas) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    TeaStore.cache.teas = next
    if (cascade) {
      const keep: TastingRecord[] = []
      for (const r of TeaStore.cache.tastings) {
        if (r.teaId !== id) {
          keep.push(r)
        }
      }
      TeaStore.cache.tastings = keep
    }
    for (const list of TeaStore.cache.lists) {
      list.teaIds = TeaStore.withoutId(list.teaIds, id)
    }
    for (const album of TeaStore.cache.albums) {
      album.teaIds = TeaStore.withoutId(album.teaIds, id)
    }
    return TeaStore.persist()
  }

  static async saveTasting(rec: TastingRecord): Promise<boolean> {
    if (rec.createdAt <= 0) {
      rec.createdAt = Date.now()
    }
    let found = false
    for (let i = 0; i < TeaStore.cache.tastings.length; i++) {
      if (TeaStore.cache.tastings[i].id === rec.id) {
        TeaStore.cache.tastings[i] = rec
        found = true
      }
    }
    if (!found) {
      TeaStore.cache.tastings.unshift(rec)
    }
    return TeaStore.persist()
  }

  static async deleteTasting(id: string): Promise<boolean> {
    const next: TastingRecord[] = []
    for (const t of TeaStore.cache.tastings) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    TeaStore.cache.tastings = next
    return TeaStore.persist()
  }

  static async saveList(list: TeaList): Promise<boolean> {
    if (list.createdAt <= 0) {
      list.createdAt = Date.now()
    }
    let found = false
    for (let i = 0; i < TeaStore.cache.lists.length; i++) {
      if (TeaStore.cache.lists[i].id === list.id) {
        TeaStore.cache.lists[i] = list
        found = true
      }
    }
    if (!found) {
      TeaStore.cache.lists.unshift(list)
    }
    return TeaStore.persist()
  }

  static async deleteList(id: string): Promise<boolean> {
    const next: TeaList[] = []
    for (const t of TeaStore.cache.lists) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    TeaStore.cache.lists = next
    return TeaStore.persist()
  }

  static async saveAlbum(album: ThemeAlbum): Promise<boolean> {
    if (album.createdAt <= 0) {
      album.createdAt = Date.now()
    }
    let found = false
    for (let i = 0; i < TeaStore.cache.albums.length; i++) {
      if (TeaStore.cache.albums[i].id === album.id) {
        TeaStore.cache.albums[i] = album
        found = true
      }
    }
    if (!found) {
      TeaStore.cache.albums.unshift(album)
    }
    return TeaStore.persist()
  }

  static async deleteAlbum(id: string): Promise<boolean> {
    const next: ThemeAlbum[] = []
    for (const t of TeaStore.cache.albums) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    TeaStore.cache.albums = next
    return TeaStore.persist()
  }

  static async savePlan(plan: TeaPlan): Promise<boolean> {
    if (plan.createdAt <= 0) {
      plan.createdAt = Date.now()
    }
    let found = false
    for (let i = 0; i < TeaStore.cache.plans.length; i++) {
      if (TeaStore.cache.plans[i].id === plan.id) {
        TeaStore.cache.plans[i] = plan
        found = true
      }
    }
    if (!found) {
      TeaStore.cache.plans.unshift(plan)
    }
    return TeaStore.persist()
  }

  static async deletePlan(id: string): Promise<boolean> {
    const next: TeaPlan[] = []
    for (const t of TeaStore.cache.plans) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    TeaStore.cache.plans = next
    return TeaStore.persist()
  }

  static async saveTag(tag: TagItem): Promise<boolean> {
    let found = false
    for (let i = 0; i < TeaStore.cache.tags.length; i++) {
      if (TeaStore.cache.tags[i].id === tag.id) {
        TeaStore.cache.tags[i] = tag
        found = true
      }
    }
    if (!found) {
      TeaStore.cache.tags.push(tag)
    }
    return TeaStore.persist()
  }

  static async saveBin(bin: CustomBin): Promise<boolean> {
    let found = false
    for (let i = 0; i < TeaStore.cache.bins.length; i++) {
      if (TeaStore.cache.bins[i].id === bin.id) {
        TeaStore.cache.bins[i] = bin
        found = true
      }
    }
    if (!found) {
      TeaStore.cache.bins.push(bin)
    }
    return TeaStore.persist()
  }

  static async saveSettings(s: AppSettings): Promise<boolean> {
    TeaStore.cache.settings = s
    return TeaStore.persist()
  }

  static addTeaToList(listId: string, teaId: string): Promise<boolean> {
    const list = TeaStore.findList(listId)
    if (list === null) {
      return Promise.resolve(false)
    }
    for (const id of list.teaIds) {
      if (id === teaId) {
        return Promise.resolve(true)
      }
    }
    list.teaIds.push(teaId)
    return TeaStore.saveList(list)
  }

  static addTeaToAlbum(albumId: string, teaId: string): Promise<boolean> {
    const album = TeaStore.findAlbum(albumId)
    if (album === null) {
      return Promise.resolve(false)
    }
    for (const id of album.teaIds) {
      if (id === teaId) {
        return Promise.resolve(true)
      }
    }
    album.teaIds.push(teaId)
    return TeaStore.saveAlbum(album)
  }

  static search(q: string): TeaItem[] {
    const needle = q.trim()
    if (needle.length === 0) {
      return TeaStore.cache.teas
    }
    const out: TeaItem[] = []
    for (const t of TeaStore.cache.teas) {
      const blob = `${t.name}${t.brand}${t.origin}${t.yearText}${t.story}${t.review}`
      if (blob.indexOf(needle) >= 0) {
        out.push(t)
      }
    }
    return out
  }

  static exportJson(): string {
    return JSON.stringify(TeaStore.cache)
  }

  static bump(): void {
    const cur = AppStorage.get<number>('teaRev')
    AppStorage.setOrCreate('teaRev', (cur !== undefined ? cur : 0) + 1)
  }

  private static withoutId(ids: string[], drop: string): string[] {
    const next: string[] = []
    for (const id of ids) {
      if (id !== drop) {
        next.push(id)
      }
    }
    return next
  }

  private static ensureDefaults(): void {
    if (TeaStore.cache.tags.length === 0) {
      TeaStore.cache.tags = TagItem.defaults()
    }
  }

  private static parseBundle(raw: string): TeaBundle {
    const bundle = new TeaBundle()
    if (raw.length === 0) {
      return bundle
    }
    try {
      const parsed = JSON.parse(raw) as Record<string, object>
      const teasRaw = parsed['teas']
      if (teasRaw !== undefined && Array.isArray(teasRaw)) {
        const teas = teasRaw as object[]
        for (let i = 0; i < teas.length; i++) {
          bundle.teas.push(TeaItem.fromJson(teas[i]))
        }
      }
      const tastingsRaw = parsed['tastings']
      if (tastingsRaw !== undefined && Array.isArray(tastingsRaw)) {
        const tastings = tastingsRaw as object[]
        for (let i = 0; i < tastings.length; i++) {
          bundle.tastings.push(TastingRecord.fromJson(tastings[i]))
        }
      }
      const listsRaw = parsed['lists']
      if (listsRaw !== undefined && Array.isArray(listsRaw)) {
        const lists = listsRaw as object[]
        for (let i = 0; i < lists.length; i++) {
          bundle.lists.push(TeaList.fromJson(lists[i]))
        }
      }
      const albumsRaw = parsed['albums']
      if (albumsRaw !== undefined && Array.isArray(albumsRaw)) {
        const albums = albumsRaw as object[]
        for (let i = 0; i < albums.length; i++) {
          bundle.albums.push(ThemeAlbum.fromJson(albums[i]))
        }
      }
      const plansRaw = parsed['plans']
      if (plansRaw !== undefined && Array.isArray(plansRaw)) {
        const plans = plansRaw as object[]
        for (let i = 0; i < plans.length; i++) {
          bundle.plans.push(TeaPlan.fromJson(plans[i]))
        }
      }
      const tagsRaw = parsed['tags']
      if (tagsRaw !== undefined && Array.isArray(tagsRaw)) {
        const tags = tagsRaw as object[]
        for (let i = 0; i < tags.length; i++) {
          bundle.tags.push(TagItem.fromJson(tags[i]))
        }
      }
      const binsRaw = parsed['bins']
      if (binsRaw !== undefined && Array.isArray(binsRaw)) {
        const bins = binsRaw as object[]
        for (let i = 0; i < bins.length; i++) {
          bundle.bins.push(CustomBin.fromJson(bins[i]))
        }
      }
      const settingsRaw = parsed['settings']
      if (settingsRaw !== undefined) {
        bundle.settings = AppSettings.fromJson(settingsRaw as object)
      }
    } catch {
      return new TeaBundle()
    }
    return bundle
  }

  private static async persist(): Promise<boolean> {
    // 先 bump，保证首页/茶库/记录在写盘前后都能立刻重算
    TeaStore.bump()
    if (TeaStore.pref === null) {
      return false
    }
    try {
      const payload = JSON.stringify({
        teas: TeaStore.cache.teas,
        tastings: TeaStore.cache.tastings,
        lists: TeaStore.cache.lists,
        albums: TeaStore.cache.albums,
        plans: TeaStore.cache.plans,
        tags: TeaStore.cache.tags,
        bins: TeaStore.cache.bins,
        settings: TeaStore.cache.settings
      })
      await TeaStore.pref.put(KEY_BUNDLE, payload)
      await TeaStore.pref.flush()
      return true
    } catch {
      return false
    }
  }
}
