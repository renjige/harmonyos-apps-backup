import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  ActivityLog,
  AppSettings,
  CategoryItem,
  CollectionNote,
  CollectionPlan,
  DomainBucket,
  ExportPayload,
  LabelBucket,
  SearchHit,
  TagItem,
  TimelineEvent,
  TreasureAlbum,
  TreasureBundle,
  TreasureItem,
  WishItem,
  YearBucket
} from '../models/TreasureModels'
import { AchievementService } from './AchievementService'
import { CompletenessUtil } from './CompletenessUtil'

const STORE = 'treasure_archive'
const KEY_BUNDLE = 'bundle'
const KEY_REV = 'treasureRev'

export class TreasureStore {
  private static pref: preferences.Preferences | null = null
  private static cache: TreasureBundle = new TreasureBundle()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      TreasureStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await TreasureStore.pref.get(KEY_BUNDLE, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      TreasureStore.cache = TreasureStore.parseBundle(raw)
      TreasureStore.ensureDefaults()
    } catch {
      TreasureStore.cache = new TreasureBundle()
      TreasureStore.ensureDefaults()
    }
    TreasureStore.bump()
  }

  static snapshot(): TreasureBundle {
    return TreasureStore.cache
  }

  static activeItems(): TreasureItem[] {
    const out: TreasureItem[] = []
    for (const item of TreasureStore.cache.items) {
      if (item.deletedAt <= 0) {
        out.push(item)
      }
    }
    return out
  }

  static trashedItems(): TreasureItem[] {
    const out: TreasureItem[] = []
    for (const item of TreasureStore.cache.items) {
      if (item.deletedAt > 0) {
        out.push(item)
      }
    }
    out.sort((a: TreasureItem, b: TreasureItem): number => b.deletedAt - a.deletedAt)
    return out
  }

  static findItem(id: string): TreasureItem | null {
    for (const item of TreasureStore.cache.items) {
      if (item.id === id) {
        return item
      }
    }
    return null
  }

  static categories(): CategoryItem[] {
    const copy: CategoryItem[] = []
    for (const c of TreasureStore.cache.categories) {
      copy.push(c)
    }
    copy.sort((a: CategoryItem, b: CategoryItem): number => a.sortOrder - b.sortOrder)
    return copy
  }

  static tags(): TagItem[] {
    return TreasureStore.cache.tags
  }

  static albums(): TreasureAlbum[] {
    return TreasureStore.cache.albums
  }

  static plans(): CollectionPlan[] {
    return TreasureStore.cache.plans
  }

  static wishes(): WishItem[] {
    return TreasureStore.cache.wishes
  }

  static activities(): ActivityLog[] {
    const copy: ActivityLog[] = []
    for (const a of TreasureStore.cache.activities) {
      copy.push(a)
    }
    copy.sort((a: ActivityLog, b: ActivityLog): number => b.createdAt - a.createdAt)
    return copy
  }

  static settings(): AppSettings {
    return TreasureStore.cache.settings
  }

  static recentItems(limit: number): TreasureItem[] {
    const copy: TreasureItem[] = []
    for (const item of TreasureStore.activeItems()) {
      copy.push(item)
    }
    copy.sort((a: TreasureItem, b: TreasureItem): number => b.createdAt - a.createdAt)
    const out: TreasureItem[] = []
    for (const item of copy) {
      if (out.length < limit) {
        out.push(item)
      }
    }
    return out
  }

  static pendingItems(): TreasureItem[] {
    const out: TreasureItem[] = []
    for (const item of TreasureStore.activeItems()) {
      if (item.listStatus === '待整理' || item.archiveStatus === '刚入藏' ||
        CompletenessUtil.percent(item) < 80) {
        out.push(item)
      }
    }
    return out
  }

  static findPlan(id: string): CollectionPlan | null {
    for (const p of TreasureStore.cache.plans) {
      if (p.id === id) {
        return p
      }
    }
    return null
  }

  static findAlbum(id: string): TreasureAlbum | null {
    for (const a of TreasureStore.cache.albums) {
      if (a.id === id) {
        return a
      }
    }
    return null
  }

  static notes(): CollectionNote[] {
    return TreasureStore.cache.notes
  }

  static findNote(id: string): CollectionNote | null {
    for (const n of TreasureStore.cache.notes) {
      if (n.id === id) {
        return n
      }
    }
    return null
  }

  static itemsInAlbum(albumId: string): TreasureItem[] {
    const album = TreasureStore.findAlbum(albumId)
    if (album === null) {
      return []
    }
    const out: TreasureItem[] = []
    for (const id of album.itemIds) {
      const item = TreasureStore.findItem(id)
      if (item !== null && item.deletedAt <= 0) {
        out.push(item)
      }
    }
    return out
  }

  static itemsByDomain(domainKey: string): TreasureItem[] {
    const out: TreasureItem[] = []
    for (const item of TreasureStore.activeItems()) {
      for (const c of TreasureStore.categories()) {
        if (c.id === item.categoryId && c.domainKey === domainKey) {
          out.push(item)
          break
        }
      }
    }
    return out
  }

  static itemsOnDate(dateKey: string): TreasureItem[] {
    const out: TreasureItem[] = []
    for (const item of TreasureStore.activeItems()) {
      if (TreasureStore.dateKeyFromTs(item.createdAt) === dateKey) {
        out.push(item)
      }
    }
    return out
  }

  static planDoneCount(plan: CollectionPlan): number {
    let count = plan.itemIds.length
    for (const item of TreasureStore.activeItems()) {
      if (item.planId === plan.id) {
        let linked = false
        for (const id of plan.itemIds) {
          if (id === item.id) {
            linked = true
            break
          }
        }
        if (!linked) {
          count += 1
        }
      }
    }
    return count
  }

  static wishTemplateRows(): string[][] {
    const rows: string[][] = []
    rows.push(['旅行纪念清单', '记录旅途带回的小物与纪念', '待收藏'])
    rows.push(['搬家纪念清单', '整理搬家时值得留下的物件', '待整理'])
    rows.push(['童年收藏整理', '回顾童年时期的收藏与纪念', '待整理'])
    rows.push(['节日纪念物', '记录节日相关的珍藏与礼物', '待收藏'])
    rows.push(['书籍收藏清单', '规划想读与已藏的书籍', '想寻找'])
    return rows
  }

  static async addItemToAlbum(albumId: string, itemId: string): Promise<boolean> {
    const album = TreasureStore.findAlbum(albumId)
    if (album === null) {
      return false
    }
    for (const id of album.itemIds) {
      if (id === itemId) {
        return true
      }
    }
    album.itemIds.push(itemId)
    return TreasureStore.saveAlbum(album)
  }

  static async removeItemFromAlbum(albumId: string, itemId: string): Promise<boolean> {
    const album = TreasureStore.findAlbum(albumId)
    if (album === null) {
      return false
    }
    const next: string[] = []
    for (const id of album.itemIds) {
      if (id !== itemId) {
        next.push(id)
      }
    }
    album.itemIds = next
    return TreasureStore.saveAlbum(album)
  }

  static planProgress(plan: CollectionPlan): number {
    if (plan.targetCount <= 0) {
      return 0
    }
    let count = plan.itemIds.length
    for (const item of TreasureStore.activeItems()) {
      if (item.planId === plan.id) {
        let linked = false
        for (const id of plan.itemIds) {
          if (id === item.id) {
            linked = true
            break
          }
        }
        if (!linked) {
          count += 1
        }
      }
    }
    return Math.min(100, Math.round((count / plan.targetCount) * 100))
  }

  static domainBuckets(): DomainBucket[] {
    const defs: string[][] = [
      ['books', '书籍', '#4A3F35'],
      ['memory', '纪念', '#2C3E42'],
      ['travel', '旅行', '#5C6B58'],
      ['hobby', '兴趣', '#8A7A62'],
      ['family', '家庭', '#6B6458'],
      ['life', '生活', '#85827B']
    ]
    const out: DomainBucket[] = []
    for (const d of defs) {
      const b = new DomainBucket()
      b.key = d[0]
      b.label = d[1]
      b.tone = d[2]
      b.count = 0
      for (const c of TreasureStore.categories()) {
        if (c.domainKey === d[0]) {
          for (const item of TreasureStore.activeItems()) {
            if (item.categoryId === c.id) {
              b.count += 1
            }
          }
        }
      }
      out.push(b)
    }
    return out
  }

  static search(keyword: string): SearchHit[] {
    const q = keyword.trim().toLowerCase()
    if (q.length === 0) {
      return []
    }
    const out: SearchHit[] = []
    for (const item of TreasureStore.activeItems()) {
      if (item.name.toLowerCase().includes(q) || item.story.toLowerCase().includes(q) ||
        item.keywords.toLowerCase().includes(q)) {
        const h = new SearchHit()
        h.kind = 'item'
        h.title = item.name
        h.subtitle = TreasureStore.categoryName(item.categoryId)
        h.refId = item.id
        out.push(h)
      }
    }
    for (const a of TreasureStore.albums()) {
      if (a.name.toLowerCase().includes(q) || a.intro.toLowerCase().includes(q)) {
        const h = new SearchHit()
        h.kind = 'album'
        h.title = a.name
        h.subtitle = `${a.itemIds.length} 件`
        h.refId = a.id
        out.push(h)
      }
    }
    for (const p of TreasureStore.plans()) {
      if (p.name.toLowerCase().includes(q)) {
        const h = new SearchHit()
        h.kind = 'plan'
        h.title = p.name
        h.subtitle = `${TreasureStore.planProgress(p)}%`
        h.refId = p.id
        out.push(h)
      }
    }
    return out
  }

  static activitiesOnDate(dateKey: string): ActivityLog[] {
    const out: ActivityLog[] = []
    for (const a of TreasureStore.cache.activities) {
      if (a.dateKey === dateKey) {
        out.push(a)
      }
    }
    return out
  }

  static datesWithActivity(): string[] {
    const seen: string[] = []
    for (const a of TreasureStore.cache.activities) {
      let exists = false
      for (const d of seen) {
        if (d === a.dateKey) {
          exists = true
          break
        }
      }
      if (!exists) {
        seen.push(a.dateKey)
      }
    }
    return seen
  }

  static categoryName(id: string): string {
    for (const c of TreasureStore.cache.categories) {
      if (c.id === id) {
        return c.name
      }
    }
    return '未分类'
  }

  static tagName(id: string): string {
    for (const t of TreasureStore.cache.tags) {
      if (t.id === id) {
        return t.name
      }
    }
    return ''
  }

  static filteredItems(categoryId: string): TreasureItem[] {
    const out: TreasureItem[] = []
    for (const item of TreasureStore.activeItems()) {
      if (categoryId.length === 0 || item.categoryId === categoryId) {
        out.push(item)
      }
    }
    out.sort((a: TreasureItem, b: TreasureItem): number => b.updatedAt - a.updatedAt)
    return out
  }

  static itemsByTagName(tagName: string): TreasureItem[] {
    let tagId = ''
    for (const t of TreasureStore.cache.tags) {
      if (t.name === tagName) {
        tagId = t.id
        break
      }
    }
    const out: TreasureItem[] = []
    for (const item of TreasureStore.activeItems()) {
      let hit = false
      for (const id of item.tagIds) {
        if (id === tagId) {
          hit = true
          break
        }
      }
      if (hit) {
        out.push(item)
      }
    }
    return out
  }

  static avgCompleteness(): number {
    const items = TreasureStore.activeItems()
    if (items.length === 0) {
      return 0
    }
    let sum = 0
    for (const item of items) {
      sum += CompletenessUtil.percent(item)
    }
    return Math.round(sum / items.length)
  }

  static incompleteItems(): TreasureItem[] {
    const out: TreasureItem[] = []
    for (const item of TreasureStore.activeItems()) {
      if (CompletenessUtil.percent(item) < 100) {
        out.push(item)
      }
    }
    out.sort((a: TreasureItem, b: TreasureItem): number =>
      CompletenessUtil.percent(a) - CompletenessUtil.percent(b))
    return out
  }

  static organizedCount(): number {
    let n = 0
    for (const item of TreasureStore.activeItems()) {
      if (item.archiveStatus === '已整理' || item.archiveStatus === '重点珍藏' ||
        item.archiveStatus === '已归档') {
        n += 1
      }
    }
    return n
  }

  static highlightCount(): number {
    let n = 0
    for (const item of TreasureStore.activeItems()) {
      if (item.archiveStatus === '重点珍藏') {
        n += 1
      }
    }
    return n
  }

  static monthAddedCount(): number {
    const now = new Date()
    const ym = `${now.getFullYear()}-${TreasureStore.pad2(now.getMonth() + 1)}`
    let n = 0
    for (const item of TreasureStore.activeItems()) {
      const d = new Date(item.createdAt)
      const key = `${d.getFullYear()}-${TreasureStore.pad2(d.getMonth() + 1)}`
      if (key === ym) {
        n += 1
      }
    }
    return n
  }

  static yearBuckets(): YearBucket[] {
    const map: Map<string, number> = new Map()
    for (const item of TreasureStore.activeItems()) {
      let year = ''
      if (item.acquiredAt.length >= 4) {
        year = item.acquiredAt.substring(0, 4)
      } else {
        year = `${new Date(item.createdAt).getFullYear()}`
      }
      const prev = map.get(year) ?? 0
      map.set(year, prev + 1)
    }
    const out: YearBucket[] = []
    map.forEach((count: number, year: string) => {
      const b = new YearBucket()
      b.year = year
      b.count = count
      out.push(b)
    })
    out.sort((a: YearBucket, b: YearBucket): number => b.year.localeCompare(a.year))
    return out
  }

  static categoryBuckets(): LabelBucket[] {
    const out: LabelBucket[] = []
    for (const c of TreasureStore.categories()) {
      let count = 0
      for (const item of TreasureStore.activeItems()) {
        if (item.categoryId === c.id) {
          count += 1
        }
      }
      const b = new LabelBucket()
      b.label = c.name
      b.count = count
      out.push(b)
    }
    return out
  }

  static themeBuckets(): LabelBucket[] {
    const themes: string[] = ['旅行记忆', '家族记忆', '特别纪念', '长期收藏']
    const out: LabelBucket[] = []
    for (const theme of themes) {
      const b = new LabelBucket()
      b.label = theme
      b.count = TreasureStore.itemsByTheme(theme).length
      out.push(b)
    }
    return out
  }

  static itemsByTheme(theme: string): TreasureItem[] {
    if (theme === '旅行记忆') {
      return TreasureStore.mergeByTagOrSource('旅行纪念', '旅行')
    }
    if (theme === '家族记忆') {
      return TreasureStore.mergeByTagOrSource('家族记忆', '家传')
    }
    if (theme === '特别纪念') {
      return TreasureStore.mergeByTagOrSource('纪念意义', '赠送')
    }
    return TreasureStore.itemsByTagName('长期收藏')
  }

  private static mergeByTagOrSource(tagName: string, source: string): TreasureItem[] {
    const byTag = TreasureStore.itemsByTagName(tagName)
    const out: TreasureItem[] = []
    for (const item of byTag) {
      out.push(item)
    }
    for (const item of TreasureStore.activeItems()) {
      if (item.source === source) {
        let exists = false
        for (const x of out) {
          if (x.id === item.id) {
            exists = true
            break
          }
        }
        if (!exists) {
          out.push(item)
        }
      }
    }
    return out
  }

  static statusBuckets(): LabelBucket[] {
    const statuses: string[] = ['刚入藏', '已整理', '重点珍藏', '已归档']
    const out: LabelBucket[] = []
    for (const st of statuses) {
      let count = 0
      for (const item of TreasureStore.activeItems()) {
        if (item.archiveStatus === st) {
          count += 1
        }
      }
      const b = new LabelBucket()
      b.label = st
      b.count = count
      out.push(b)
    }
    return out
  }

  static newId(): string {
    return `t_${Date.now()}_${Math.floor(Math.random() * 100000)}`
  }

  static async saveItem(item: TreasureItem, logKind: string = ''): Promise<boolean> {
    const isNew = item.createdAt <= 0
    item.updatedAt = Date.now()
    if (isNew) {
      item.createdAt = item.updatedAt
    }
    if (item.timeline.length === 0 && item.acquiredAt.length > 0) {
      const e = new TimelineEvent()
      e.id = TreasureStore.newId()
      e.period = item.acquiredAt.replace('-', '.')
      e.label = '开始收藏'
      item.timeline.push(e)
    }
    let replaced = false
    for (let i = 0; i < TreasureStore.cache.items.length; i++) {
      if (TreasureStore.cache.items[i].id === item.id) {
        TreasureStore.cache.items[i] = item
        replaced = true
        break
      }
    }
    if (!replaced) {
      TreasureStore.cache.items.push(item)
    }
    const label = isNew ? `收藏「${item.name}」` : `更新「${item.name}」`
    await TreasureStore.logActivity(logKind.length > 0 ? logKind : (isNew ? 'item_added' : 'item_updated'), label, item.id)
    const ok = await TreasureStore.persist()
    if (ok) {
      await AchievementService.syncUnlocks()
    }
    return ok
  }

  static async touchView(id: string): Promise<void> {
    const item = TreasureStore.findItem(id)
    if (item === null) {
      return
    }
    item.lastViewedAt = Date.now()
    await TreasureStore.persist()
  }

  static async softDelete(id: string): Promise<boolean> {
    const item = TreasureStore.findItem(id)
    if (item === null) {
      return false
    }
    item.deletedAt = Date.now()
    return TreasureStore.persist()
  }

  static async restore(id: string): Promise<boolean> {
    const item = TreasureStore.findItem(id)
    if (item === null) {
      return false
    }
    item.deletedAt = 0
    return TreasureStore.persist()
  }

  static async purge(id: string): Promise<boolean> {
    const next: TreasureItem[] = []
    for (const item of TreasureStore.cache.items) {
      if (item.id !== id) {
        next.push(item)
      }
    }
    TreasureStore.cache.items = next
    return TreasureStore.persist()
  }

  static async saveCategory(cat: CategoryItem): Promise<boolean> {
    let replaced = false
    for (let i = 0; i < TreasureStore.cache.categories.length; i++) {
      if (TreasureStore.cache.categories[i].id === cat.id) {
        TreasureStore.cache.categories[i] = cat
        replaced = true
        break
      }
    }
    if (!replaced) {
      TreasureStore.cache.categories.push(cat)
    }
    return TreasureStore.persist()
  }

  static async removeCategory(id: string): Promise<boolean> {
    const next: CategoryItem[] = []
    for (const c of TreasureStore.cache.categories) {
      if (c.id !== id) {
        next.push(c)
      }
    }
    TreasureStore.cache.categories = next
    for (const item of TreasureStore.cache.items) {
      if (item.categoryId === id) {
        item.categoryId = ''
      }
    }
    return TreasureStore.persist()
  }

  static async saveTag(tag: TagItem): Promise<boolean> {
    let replaced = false
    for (let i = 0; i < TreasureStore.cache.tags.length; i++) {
      if (TreasureStore.cache.tags[i].id === tag.id) {
        TreasureStore.cache.tags[i] = tag
        replaced = true
        break
      }
    }
    if (!replaced) {
      TreasureStore.cache.tags.push(tag)
    }
    return TreasureStore.persist()
  }

  static async removeTag(id: string): Promise<boolean> {
    const next: TagItem[] = []
    for (const t of TreasureStore.cache.tags) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    TreasureStore.cache.tags = next
    for (const item of TreasureStore.cache.items) {
      const kept: string[] = []
      for (const tid of item.tagIds) {
        if (tid !== id) {
          kept.push(tid)
        }
      }
      item.tagIds = kept
    }
    return TreasureStore.persist()
  }

  static async saveAlbum(album: TreasureAlbum): Promise<boolean> {
    const isNew = album.createdAt <= 0
    let replaced = false
    for (let i = 0; i < TreasureStore.cache.albums.length; i++) {
      if (TreasureStore.cache.albums[i].id === album.id) {
        TreasureStore.cache.albums[i] = album
        replaced = true
        break
      }
    }
    if (!replaced) {
      if (album.createdAt <= 0) {
        album.createdAt = Date.now()
      }
      TreasureStore.cache.albums.push(album)
    }
    if (isNew) {
      await TreasureStore.logActivity('album_created', `创建主题「${album.name}」`, album.id)
    }
    const ok = await TreasureStore.persist()
    if (ok) {
      await AchievementService.syncUnlocks()
    }
    return ok
  }

  static async savePlan(plan: CollectionPlan): Promise<boolean> {
    let replaced = false
    for (let i = 0; i < TreasureStore.cache.plans.length; i++) {
      if (TreasureStore.cache.plans[i].id === plan.id) {
        TreasureStore.cache.plans[i] = plan
        replaced = true
        break
      }
    }
    if (!replaced) {
      if (plan.createdAt <= 0) {
        plan.createdAt = Date.now()
      }
      TreasureStore.cache.plans.push(plan)
    }
    if (TreasureStore.planProgress(plan) >= 100 && plan.completedAt <= 0) {
      plan.completedAt = Date.now()
      await TreasureStore.logActivity('plan_completed', `完成计划「${plan.name}」`, plan.id)
    }
    const ok = await TreasureStore.persist()
    if (ok) {
      await AchievementService.syncUnlocks()
    }
    return ok
  }

  static async removePlan(id: string): Promise<boolean> {
    const next: CollectionPlan[] = []
    for (const p of TreasureStore.cache.plans) {
      if (p.id !== id) {
        next.push(p)
      }
    }
    TreasureStore.cache.plans = next
    return TreasureStore.persist()
  }

  static async saveWish(wish: WishItem): Promise<boolean> {
    let replaced = false
    for (let i = 0; i < TreasureStore.cache.wishes.length; i++) {
      if (TreasureStore.cache.wishes[i].id === wish.id) {
        TreasureStore.cache.wishes[i] = wish
        replaced = true
        break
      }
    }
    if (!replaced) {
      if (wish.createdAt <= 0) {
        wish.createdAt = Date.now()
      }
      TreasureStore.cache.wishes.push(wish)
    }
    return TreasureStore.persist()
  }

  static async removeWish(id: string): Promise<boolean> {
    const next: WishItem[] = []
    for (const w of TreasureStore.cache.wishes) {
      if (w.id !== id) {
        next.push(w)
      }
    }
    TreasureStore.cache.wishes = next
    return TreasureStore.persist()
  }

  static async saveNote(note: CollectionNote): Promise<boolean> {
    let replaced = false
    for (let i = 0; i < TreasureStore.cache.notes.length; i++) {
      if (TreasureStore.cache.notes[i].id === note.id) {
        TreasureStore.cache.notes[i] = note
        replaced = true
        break
      }
    }
    if (!replaced) {
      if (note.createdAt <= 0) {
        note.createdAt = Date.now()
      }
      TreasureStore.cache.notes.push(note)
    }
    return TreasureStore.persist()
  }

  static async removeNote(id: string): Promise<boolean> {
    const next: CollectionNote[] = []
    for (const n of TreasureStore.cache.notes) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    TreasureStore.cache.notes = next
    return TreasureStore.persist()
  }

  static async logActivity(kind: string, label: string, refId: string): Promise<void> {
    const a = new ActivityLog()
    a.id = TreasureStore.newId()
    a.kind = kind
    a.label = label
    a.refId = refId
    a.createdAt = Date.now()
    a.dateKey = TreasureStore.dateKey(a.createdAt)
    TreasureStore.cache.activities.push(a)
  }

  static async removeAlbum(id: string): Promise<boolean> {
    const next: TreasureAlbum[] = []
    for (const a of TreasureStore.cache.albums) {
      if (a.id !== id) {
        next.push(a)
      }
    }
    TreasureStore.cache.albums = next
    return TreasureStore.persist()
  }

  static async saveSettings(settings: AppSettings): Promise<boolean> {
    TreasureStore.cache.settings = settings
    return TreasureStore.persist()
  }

  static buildExport(scope: string, refId: string): ExportPayload {
    let items: TreasureItem[] = TreasureStore.activeItems()
    if (scope === 'category' && refId.length > 0) {
      items = TreasureStore.filteredItems(refId)
    }
    if (scope === 'album' && refId.length > 0) {
      items = []
      for (const a of TreasureStore.cache.albums) {
        if (a.id === refId) {
          for (const id of a.itemIds) {
            const item = TreasureStore.findItem(id)
            if (item !== null && item.deletedAt <= 0) {
              items.push(item)
            }
          }
          break
        }
      }
    }
    const lines: string[] = []
    lines.push('# 珍藏空间 · 档案导出')
    lines.push(`导出时间：${TreasureStore.nowLabel()}`)
    lines.push(`共 ${items.length} 件藏品`)
    lines.push('')
    for (const item of items) {
      lines.push(`## ${item.name}`)
      lines.push(`- 分类：${TreasureStore.categoryName(item.categoryId)}`)
      lines.push(`- 获得：${item.acquiredAt}`)
      lines.push(`- 来源：${item.source}`)
      lines.push(`- 状态：${item.archiveStatus}`)
      lines.push(`- 位置：${item.storageLocation}`)
      lines.push(`- 完整度：${CompletenessUtil.percent(item)}%`)
      if (item.story.length > 0) {
        lines.push(`- 故事：${item.story}`)
      }
      lines.push('')
    }
    const payload = new ExportPayload()
    payload.exportedAt = TreasureStore.nowLabel()
    payload.itemCount = items.length
    payload.text = lines.join('\n')
    return payload
  }

  private static ensureDefaults(): void {
    if (TreasureStore.cache.categories.length === 0) {
      const rows: string[][] = [
        ['书籍', 'books'], ['文具', 'life'], ['纪念物', 'memory'], ['工艺品', 'hobby'],
        ['老物件', 'memory'], ['兴趣物品', 'hobby'], ['旅行纪念', 'travel'],
        ['家庭珍藏', 'family'], ['个人收藏', 'life']
      ]
      let order = 0
      for (const row of rows) {
        const c = new CategoryItem()
        c.id = TreasureStore.newId()
        c.name = row[0]
        c.domainKey = row[1]
        c.sortOrder = order
        order += 1
        TreasureStore.cache.categories.push(c)
      }
    }
    if (TreasureStore.cache.tags.length === 0) {
      const names: string[] = ['特别纪念', '限量', '喜爱', '旅行', '童年', '家庭', '重要', '待整理']
      for (const name of names) {
        const t = new TagItem()
        t.id = TreasureStore.newId()
        t.name = name
        TreasureStore.cache.tags.push(t)
      }
    }
  }

  private static parseBundle(raw: string): TreasureBundle {
    const bundle = new TreasureBundle()
    if (raw.length === 0) {
      return bundle
    }
    try {
      const parsed = JSON.parse(raw) as Record<string, object>
      const itemsRaw = parsed['items']
      if (itemsRaw !== undefined && Array.isArray(itemsRaw)) {
        const items = itemsRaw as object[]
        for (let i = 0; i < items.length; i++) {
          bundle.items.push(TreasureItem.fromJson(items[i]))
        }
      }
      const catsRaw = parsed['categories']
      if (catsRaw !== undefined && Array.isArray(catsRaw)) {
        const cats = catsRaw as object[]
        for (let i = 0; i < cats.length; i++) {
          bundle.categories.push(CategoryItem.fromJson(cats[i]))
        }
      }
      const tagsRaw = parsed['tags']
      if (tagsRaw !== undefined && Array.isArray(tagsRaw)) {
        const tags = tagsRaw as object[]
        for (let i = 0; i < tags.length; i++) {
          bundle.tags.push(TagItem.fromJson(tags[i]))
        }
      }
      const albumsRaw = parsed['albums']
      if (albumsRaw !== undefined && Array.isArray(albumsRaw)) {
        const albums = albumsRaw as object[]
        for (let i = 0; i < albums.length; i++) {
          bundle.albums.push(TreasureAlbum.fromJson(albums[i]))
        }
      }
      const plansRaw = parsed['plans']
      if (plansRaw !== undefined && Array.isArray(plansRaw)) {
        const plans = plansRaw as object[]
        for (let i = 0; i < plans.length; i++) {
          bundle.plans.push(CollectionPlan.fromJson(plans[i]))
        }
      }
      const wishesRaw = parsed['wishes']
      if (wishesRaw !== undefined && Array.isArray(wishesRaw)) {
        const wishes = wishesRaw as object[]
        for (let i = 0; i < wishes.length; i++) {
          bundle.wishes.push(WishItem.fromJson(wishes[i]))
        }
      }
      const notesRaw = parsed['notes']
      if (notesRaw !== undefined && Array.isArray(notesRaw)) {
        const notes = notesRaw as object[]
        for (let i = 0; i < notes.length; i++) {
          bundle.notes.push(CollectionNote.fromJson(notes[i]))
        }
      }
      const actsRaw = parsed['activities']
      if (actsRaw !== undefined && Array.isArray(actsRaw)) {
        const acts = actsRaw as object[]
        for (let i = 0; i < acts.length; i++) {
          bundle.activities.push(ActivityLog.fromJson(acts[i]))
        }
      }
      const settingsRaw = parsed['settings']
      if (settingsRaw !== undefined) {
        bundle.settings = AppSettings.fromJson(settingsRaw as object)
      }
    } catch {
      return new TreasureBundle()
    }
    return bundle
  }

  private static async persist(): Promise<boolean> {
    if (TreasureStore.pref === null) {
      return false
    }
    try {
      const payload = JSON.stringify({
        items: TreasureStore.cache.items,
        categories: TreasureStore.cache.categories,
        tags: TreasureStore.cache.tags,
        albums: TreasureStore.cache.albums,
        plans: TreasureStore.cache.plans,
        wishes: TreasureStore.cache.wishes,
        notes: TreasureStore.cache.notes,
        activities: TreasureStore.cache.activities,
        settings: TreasureStore.cache.settings
      })
      await TreasureStore.pref.put(KEY_BUNDLE, payload)
      await TreasureStore.pref.flush()
      TreasureStore.bump()
      return true
    } catch {
      return false
    }
  }

  static bump(): void {
    const rev = AppStorage.get<number>('treasureRev') ?? 0
    AppStorage.setOrCreate('treasureRev', rev + 1)
  }

  static dateLabel(ts: number): string {
    if (ts <= 0) {
      return ''
    }
    const d = new Date(ts)
    return `${d.getFullYear()}.${TreasureStore.pad2(d.getMonth() + 1)}`
  }

  static dateKeyFromTs(ts: number): string {
    const d = new Date(ts)
    return `${d.getFullYear()}-${TreasureStore.pad2(d.getMonth() + 1)}-${TreasureStore.pad2(d.getDate())}`
  }

  static dateKey(ts: number): string {
    return TreasureStore.dateKeyFromTs(ts)
  }

  private static pad2(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }

  private static nowLabel(): string {
    const d = new Date()
    return `${d.getFullYear()}-${TreasureStore.pad2(d.getMonth() + 1)}-${TreasureStore.pad2(d.getDate())} ${TreasureStore.pad2(d.getHours())}:${TreasureStore.pad2(d.getMinutes())}`
  }
}
