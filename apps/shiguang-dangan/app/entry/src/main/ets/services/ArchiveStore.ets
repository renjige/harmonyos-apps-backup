import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  Archive, ArchiveCategory, TimelineNode, UserProfile
} from '../models/ArchiveModels'
import { DateHelper } from './DateHelper'
import { LifeStore } from './LifeStore'

const STORE = 'shiguang_archive_v1'
const KEY_ARCHIVES = 'archives'
const KEY_NODES = 'nodes'
const KEY_CATEGORIES = 'categories'
const KEY_TAGS = 'tags'
const KEY_PROFILE = 'profile'
const KEY_ACTIVITY_DATES = 'activityDates'

export class ArchiveStore {
  private static pref: preferences.Preferences | null = null

  static bumpRevision(): void {
    const rev = AppStorage.get<number>('archiveDataRev') ?? 0
    AppStorage.setOrCreate('archiveDataRev', rev + 1)
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ArchiveStore.pref = await preferences.getPreferences(context, STORE)
      await ArchiveStore.ensureDefaults()
    } catch {
      ArchiveStore.pref = null
    }
  }

  static async ensureDefaults(): Promise<void> {
    const cats = await ArchiveStore.loadCategories()
    if (cats.length === 0) {
      await ArchiveStore.persistCategories(ArchiveCategory.defaults())
    }
  }

  static async loadArchives(): Promise<Archive[]> {
    const raw = await ArchiveStore.getString(KEY_ARCHIVES, '')
    return ArchiveStore.parseArchives(raw)
  }

  static async findArchive(id: string): Promise<Archive | undefined> {
    const list = await ArchiveStore.loadArchives()
    for (const a of list) {
      if (a.id === id) {
        return a
      }
    }
    return undefined
  }

  static async saveArchive(archive: Archive): Promise<void> {
    archive.updatedAt = Date.now()
    const list = await ArchiveStore.loadArchives()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === archive.id) {
        list[i] = archive
        found = true
      }
    }
    if (!found) {
      list.push(archive)
    }
    list.sort((a, b) => b.updatedAt - a.updatedAt)
    await ArchiveStore.persistArchives(list)
  }

  static async deleteArchive(id: string): Promise<void> {
    const list = await ArchiveStore.loadArchives()
    const next: Archive[] = []
    for (const a of list) {
      if (a.id !== id) {
        next.push(a)
      }
    }
    await ArchiveStore.persistArchives(next)
    const nodes = await ArchiveStore.loadNodes()
    const kept: TimelineNode[] = []
    for (const n of nodes) {
      if (n.archiveId !== id) {
        kept.push(n)
      }
    }
    await ArchiveStore.persistNodes(kept)
  }

  static async loadNodes(): Promise<TimelineNode[]> {
    const raw = await ArchiveStore.getString(KEY_NODES, '')
    return ArchiveStore.parseNodes(raw)
  }

  static async nodesForArchive(archiveId: string): Promise<TimelineNode[]> {
    const list = await ArchiveStore.loadNodes()
    const out: TimelineNode[] = []
    for (const n of list) {
      if (n.archiveId === archiveId) {
        out.push(n)
      }
    }
    out.sort((a, b) => DateHelper.compareKeys(a.dateKey, b.dateKey))
    return out
  }

  static async findNode(id: string): Promise<TimelineNode | undefined> {
    const list = await ArchiveStore.loadNodes()
    for (const n of list) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static async saveNode(node: TimelineNode): Promise<void> {
    const list = await ArchiveStore.loadNodes()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === node.id) {
        list[i] = node
        found = true
      }
    }
    if (!found) {
      list.push(node)
    }
    await ArchiveStore.persistNodes(list)
    const archive = await ArchiveStore.findArchive(node.archiveId)
    if (archive !== undefined) {
      if (archive.status === 'pending') {
        archive.status = 'organized'
      }
      archive.updatedAt = Date.now()
      await ArchiveStore.saveArchive(archive)
    }
    ArchiveStore.bumpRevision()
  }

  static async deleteNode(id: string): Promise<void> {
    const list = await ArchiveStore.loadNodes()
    const next: TimelineNode[] = []
    for (const n of list) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    await ArchiveStore.persistNodes(next)
    ArchiveStore.bumpRevision()
  }

  static async loadCategories(): Promise<ArchiveCategory[]> {
    const raw = await ArchiveStore.getString(KEY_CATEGORIES, '')
    return ArchiveStore.parseCategories(raw)
  }

  static async saveCategories(categories: ArchiveCategory[]): Promise<void> {
    await ArchiveStore.persistCategories(categories)
  }

  static categoryLabel(categories: ArchiveCategory[], key: string): string {
    for (const c of categories) {
      if (c.key === key) {
        return c.label
      }
    }
    return key
  }

  static async loadTags(): Promise<string[]> {
    const raw = await ArchiveStore.getString(KEY_TAGS, '')
    if (raw.length === 0) {
      return []
    }
    const parts = raw.split('|')
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0 && !out.includes(t)) {
        out.push(t)
      }
    }
    return out
  }

  static async addTag(tag: string): Promise<void> {
    const trimmed = tag.trim()
    if (trimmed.length === 0) {
      return
    }
    const tags = await ArchiveStore.loadTags()
    if (!tags.includes(trimmed)) {
      tags.push(trimmed)
      await ArchiveStore.putString(KEY_TAGS, tags.join('|'))
    }
  }

  static async removeTag(tag: string): Promise<void> {
    const tags = await ArchiveStore.loadTags()
    const next: string[] = []
    for (const t of tags) {
      if (t !== tag) {
        next.push(t)
      }
    }
    await ArchiveStore.putString(KEY_TAGS, next.join('|'))
  }

  static async loadProfile(): Promise<UserProfile> {
    const raw = await ArchiveStore.getString(KEY_PROFILE, '')
    const p = new UserProfile()
    if (raw.length === 0) {
      return p
    }
    const parts = raw.split('\t')
    if (parts.length >= 1) {
      p.nickname = parts[0]
    }
    if (parts.length >= 2) {
      p.themeMode = parts[1]
    }
    return p
  }

  static async saveProfile(profile: UserProfile): Promise<void> {
    const line = `${profile.nickname}\t${profile.themeMode}`
    await ArchiveStore.putString(KEY_PROFILE, line)
  }

  static completionPercent(archive: Archive, nodeCount: number): number {
    let score = 10
    if (archive.summary.trim().length >= 10) {
      score += 20
    }
    if (archive.startDate.length > 0) {
      score += 15
    }
    if (archive.tags.length > 0) {
      score += 10
    }
    const nodeScore = nodeCount * 15
    score += nodeScore > 45 ? 45 : nodeScore
    if (score > 100) {
      return 100
    }
    return score
  }

  static async pendingArchives(): Promise<Archive[]> {
    const list = await ArchiveStore.loadArchives()
    const out: Archive[] = []
    for (const a of list) {
      if (a.status === 'pending') {
        out.push(a)
      }
    }
    return out
  }

  static async recentArchives(limit: number): Promise<Archive[]> {
    const list = await ArchiveStore.loadArchives()
    const out: Archive[] = []
    for (let i = 0; i < list.length && i < limit; i++) {
      out.push(list[i])
    }
    return out
  }

  static async recentNodes(limit: number): Promise<TimelineNode[]> {
    const list = await ArchiveStore.loadNodes()
    list.sort((a, b) => b.createdAt - a.createdAt)
    const out: TimelineNode[] = []
    for (let i = 0; i < list.length && i < limit; i++) {
      out.push(list[i])
    }
    return out
  }

  static async favoriteArchives(): Promise<Archive[]> {
    const list = await ArchiveStore.loadArchives()
    const out: Archive[] = []
    for (const a of list) {
      if (a.isFavorite) {
        out.push(a)
      }
    }
    return out
  }

  static async countFavorites(): Promise<number> {
    const list = await ArchiveStore.loadArchives()
    let cnt = 0
    for (const a of list) {
      if (a.isFavorite) {
        cnt++
      }
    }
    return cnt
  }

  static async toggleArchiveFavorite(id: string): Promise<void> {
    const archive = await ArchiveStore.findArchive(id)
    if (archive === undefined) {
      return
    }
    archive.isFavorite = !archive.isFavorite
    await ArchiveStore.saveArchive(archive)
  }

  static async toggleNodeImportant(id: string): Promise<void> {
    const node = await ArchiveStore.findNode(id)
    if (node === undefined) {
      return
    }
    node.isImportant = !node.isImportant
    await ArchiveStore.saveNode(node)
  }

  static async addCategory(label: string): Promise<void> {
    const trimmed = label.trim()
    if (trimmed.length === 0) {
      return
    }
    const cats = await ArchiveStore.loadCategories()
    const key = `cat_${Date.now()}`
    const c = ArchiveCategory.make(key, trimmed, cats.length)
    cats.push(c)
    await ArchiveStore.persistCategories(cats)
  }

  static async removeCategory(key: string): Promise<void> {
    const cats = await ArchiveStore.loadCategories()
    const next: ArchiveCategory[] = []
    for (const c of cats) {
      if (c.key !== key) {
        next.push(c)
      }
    }
    await ArchiveStore.persistCategories(next)
  }

  static async renameCategory(key: string, label: string): Promise<void> {
    const trimmed = label.trim()
    if (trimmed.length === 0) {
      return
    }
    const cats = await ArchiveStore.loadCategories()
    for (const c of cats) {
      if (c.key === key) {
        c.label = trimmed
      }
    }
    await ArchiveStore.persistCategories(cats)
  }

  static async nodesOnDate(dateKey: string): Promise<TimelineNode[]> {
    const list = await ArchiveStore.loadNodes()
    const out: TimelineNode[] = []
    for (const n of list) {
      if (n.dateKey === dateKey) {
        out.push(n)
      }
    }
    out.sort((a, b) => DateHelper.compareKeys(a.dateKey, b.dateKey))
    return out
  }

  static async nodesOnDayMonth(day: number, month: number): Promise<TimelineNode[]> {
    const list = await ArchiveStore.loadNodes()
    const out: TimelineNode[] = []
    for (const n of list) {
      if (DateHelper.sameMonthDay(n.dateKey, day, month)) {
        out.push(n)
      }
    }
    out.sort((a, b) => DateHelper.compareKeys(a.dateKey, b.dateKey))
    return out
  }

  static async recordActivityDate(dateKey: string): Promise<void> {
    const raw = await ArchiveStore.getString(KEY_ACTIVITY_DATES, '')
    const parts = raw.length > 0 ? raw.split('|') : []
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0 && t !== dateKey && !out.includes(t)) {
        out.push(t)
      }
    }
    out.push(dateKey)
    out.sort((a, b) => b.localeCompare(a))
    await ArchiveStore.putString(KEY_ACTIVITY_DATES, out.join('|'))
  }

  static async loadActivityDateKeys(): Promise<string[]> {
    const raw = await ArchiveStore.getString(KEY_ACTIVITY_DATES, '')
    if (raw.length === 0) {
      return []
    }
    const out: string[] = []
    const parts = raw.split('|')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0 && !out.includes(t)) {
        out.push(t)
      }
    }
    return out
  }

  static async hasActivityOnDate(dateKey: string): Promise<boolean> {
    const keys = await ArchiveStore.loadActivityDateKeys()
    for (const k of keys) {
      if (k === dateKey) {
        return true
      }
    }
    return false
  }

  static async computeStreakDays(): Promise<number> {
    const raw = await ArchiveStore.getString(KEY_ACTIVITY_DATES, '')
    if (raw.length === 0) {
      return 0
    }
    const parts = raw.split('|')
    const dateSet: Set<string> = new Set()
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        dateSet.add(t)
      }
    }
    if (dateSet.size === 0) {
      return 0
    }
    let offset = 0
    if (!dateSet.has(DateHelper.todayKey())) {
      offset = 1
    }
    let streak = 0
    for (let i = offset; i < 400; i++) {
      const key = DateHelper.daysAgoKey(i)
      if (dateSet.has(key)) {
        streak++
      } else {
        break
      }
    }
    return streak
  }

  static async clearAll(): Promise<void> {
    await ArchiveStore.putString(KEY_ARCHIVES, '')
    await ArchiveStore.putString(KEY_NODES, '')
    await ArchiveStore.putString(KEY_TAGS, '')
    await ArchiveStore.putString(KEY_ACTIVITY_DATES, '')
    await ArchiveStore.persistCategories(ArchiveCategory.defaults())
    await LifeStore.clearAll()
  }

  static async exportJson(): Promise<string> {
    const archives = await ArchiveStore.loadArchives()
    const nodes = await ArchiveStore.loadNodes()
    const categories = await ArchiveStore.loadCategories()
    const tags = await ArchiveStore.loadTags()
    const profile = await ArchiveStore.loadProfile()
    const lifeJson = await LifeStore.exportJson()
    const lines: string[] = []
    lines.push('{')
    lines.push(`"app":"时光档案",`)
    lines.push(`"exportedAt":${Date.now()},`)
    lines.push(`"nickname":"${ArchiveStore.escape(profile.nickname)}",`)
    lines.push(`"tags":${ArchiveStore.jsonStringArray(tags)},`)
    lines.push('"categories":[')
    for (let i = 0; i < categories.length; i++) {
      const c = categories[i]
      lines.push(`{"key":"${c.key}","label":"${ArchiveStore.escape(c.label)}"}${i < categories.length - 1 ? ',' : ''}`)
    }
    lines.push('],')
    lines.push('"archives":[')
    for (let i = 0; i < archives.length; i++) {
      const a = archives[i]
      lines.push('{')
      lines.push(`"id":"${a.id}",`)
      lines.push(`"title":"${ArchiveStore.escape(a.title)}",`)
      lines.push(`"categoryKey":"${a.categoryKey}",`)
      lines.push(`"startDate":"${a.startDate}",`)
      lines.push(`"endDate":"${a.endDate}",`)
      lines.push(`"summary":"${ArchiveStore.escape(a.summary)}",`)
      lines.push(`"mood":"${ArchiveStore.escape(a.mood)}",`)
      lines.push(`"oneLineSummary":"${ArchiveStore.escape(a.oneLineSummary)}",`)
      lines.push(`"tags":${ArchiveStore.jsonStringArray(a.tags)},`)
      lines.push(`"status":"${a.status}",`)
      lines.push(`"isFavorite":${a.isFavorite ? 'true' : 'false'}`)
      lines.push(`}${i < archives.length - 1 ? ',' : ''}`)
    }
    lines.push('],')
    lines.push('"nodes":[')
    for (let i = 0; i < nodes.length; i++) {
      const n = nodes[i]
      lines.push('{')
      lines.push(`"id":"${n.id}",`)
      lines.push(`"archiveId":"${n.archiveId}",`)
      lines.push(`"dateKey":"${n.dateKey}",`)
      lines.push(`"title":"${ArchiveStore.escape(n.title)}",`)
      lines.push(`"whatHappened":"${ArchiveStore.escape(n.whatHappened)}",`)
      lines.push(`"whyImportant":"${ArchiveStore.escape(n.whyImportant)}",`)
      lines.push(`"feeling":"${ArchiveStore.escape(n.feeling)}",`)
      lines.push(`"afterChange":"${ArchiveStore.escape(n.afterChange)}",`)
      lines.push(`"tags":${ArchiveStore.jsonStringArray(n.tags)}`)
      lines.push(`}${i < nodes.length - 1 ? ',' : ''}`)
    }
    lines.push('],')
    lines.push(`"life":${lifeJson}`)
    lines.push('}')
    return lines.join('')
  }

  private static escape(s: string): string {
    return s.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, ' ')
  }

  private static jsonStringArray(arr: string[]): string {
    const parts: string[] = []
    for (const s of arr) {
      parts.push(`"${ArchiveStore.escape(s)}"`)
    }
    return `[${parts.join(',')}]`
  }

  private static serializeArchive(a: Archive): string {
    const tags = a.tags.join(',')
    const title = a.title.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const summary = a.summary.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const mood = a.mood.replace(/\t/g, ' ')
    const oneLine = a.oneLineSummary.replace(/\t/g, ' ').replace(/\n/g, ' ')
    return [
      a.id, title, a.categoryKey, a.startDate, a.endDate, summary, tags, a.status,
      `${a.createdAt}`, `${a.updatedAt}`, a.isFavorite ? '1' : '0', mood, oneLine
    ].join('\t')
  }

  private static parseArchives(raw: string): Archive[] {
    const out: Archive[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 10) {
        continue
      }
      const a = new Archive()
      a.id = parts[0]
      a.title = parts[1]
      a.categoryKey = parts[2]
      a.startDate = parts[3]
      a.endDate = parts[4]
      a.summary = parts[5]
      a.tags = ArchiveStore.splitTags(parts[6])
      a.status = parts[7]
      a.createdAt = parseInt(parts[8], 10)
      a.updatedAt = parseInt(parts[9], 10)
      if (parts.length >= 11) {
        a.isFavorite = parts[10] === '1'
      }
      if (parts.length >= 12) {
        a.mood = parts[11]
      }
      if (parts.length >= 13) {
        a.oneLineSummary = parts[12]
      }
      out.push(a)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static serializeNode(n: TimelineNode): string {
    const tags = n.tags.join(',')
    return [
      n.id, n.archiveId, n.dateKey,
      n.title.replace(/\t/g, ' ').replace(/\n/g, ' '),
      n.whatHappened.replace(/\t/g, ' ').replace(/\n/g, ' '),
      n.whyImportant.replace(/\t/g, ' ').replace(/\n/g, ' '),
      n.feeling.replace(/\t/g, ' ').replace(/\n/g, ' '),
      n.afterChange.replace(/\t/g, ' ').replace(/\n/g, ' '),
      tags, `${n.createdAt}`, n.isImportant ? '1' : '0'
    ].join('\t')
  }

  private static parseNodes(raw: string): TimelineNode[] {
    const out: TimelineNode[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 10) {
        continue
      }
      const n = new TimelineNode()
      n.id = parts[0]
      n.archiveId = parts[1]
      n.dateKey = parts[2]
      n.title = parts[3]
      n.whatHappened = parts[4]
      n.whyImportant = parts[5]
      n.feeling = parts[6]
      n.afterChange = parts[7]
      n.tags = ArchiveStore.splitTags(parts[8])
      n.createdAt = parseInt(parts[9], 10)
      if (parts.length >= 11) {
        n.isImportant = parts[10] === '1'
      }
      out.push(n)
    }
    return out
  }

  private static serializeCategory(c: ArchiveCategory): string {
    return `${c.key}\t${c.label}\t${c.sortOrder}`
  }

  private static parseCategories(raw: string): ArchiveCategory[] {
    const out: ArchiveCategory[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 3) {
        continue
      }
      const c = new ArchiveCategory()
      c.key = parts[0]
      c.label = parts[1]
      c.sortOrder = parseInt(parts[2], 10)
      out.push(c)
    }
    out.sort((a, b) => a.sortOrder - b.sortOrder)
    return out
  }

  private static splitTags(raw: string): string[] {
    if (raw.length === 0) {
      return []
    }
    const parts = raw.split(',')
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private static async persistArchives(items: Archive[]): Promise<void> {
    const lines: string[] = []
    for (const a of items) {
      lines.push(ArchiveStore.serializeArchive(a))
    }
    await ArchiveStore.putString(KEY_ARCHIVES, lines.join('\n'))
  }

  private static async persistNodes(items: TimelineNode[]): Promise<void> {
    const lines: string[] = []
    for (const n of items) {
      lines.push(ArchiveStore.serializeNode(n))
    }
    await ArchiveStore.putString(KEY_NODES, lines.join('\n'))
  }

  private static async persistCategories(items: ArchiveCategory[]): Promise<void> {
    const lines: string[] = []
    for (const c of items) {
      lines.push(ArchiveStore.serializeCategory(c))
    }
    await ArchiveStore.putString(KEY_CATEGORIES, lines.join('\n'))
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ArchiveStore.pref === null) {
      return fallback
    }
    try {
      const v = await ArchiveStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ArchiveStore.pref === null) {
      return
    }
    try {
      await ArchiveStore.pref.put(key, value)
      await ArchiveStore.pref.flush()
    } catch {
    }
  }
}
