import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  XingyuCodec, TagItem, ThemeSpace, Narrative, SparkItem, FavoriteItem
} from '../models/XingyuModels'
import { XingyuNav } from './XingyuNav'

const STORE = 'xingyu_archive_v1'

export class XingyuStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      XingyuStore.pref = await preferences.getPreferences(context, STORE)
      const tags = await XingyuStore.loadTags()
      if (tags.length === 0) {
        await XingyuStore.persistTags(TagItem.defaults())
      }
    } catch {
      XingyuStore.pref = null
    }
  }

  static async loadNarratives(): Promise<Narrative[]> {
    return XingyuStore.parseNarratives(await XingyuStore.getString('narratives', ''))
  }

  static async findNarrative(id: string): Promise<Narrative | undefined> {
    const list = await XingyuStore.loadNarratives()
    for (const n of list) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static async saveNarrative(item: Narrative): Promise<void> {
    item.updatedAt = Date.now()
    const list = await XingyuStore.loadNarratives()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === item.id) {
        list[i] = item
        found = true
      }
    }
    if (!found) {
      list.push(item)
    }
    list.sort((a, b) => b.updatedAt - a.updatedAt)
    await XingyuStore.putString('narratives', XingyuStore.dumpNarratives(list))
    XingyuNav.bump()
  }

  static async deleteNarrative(id: string): Promise<void> {
    const list = await XingyuStore.loadNarratives()
    const next: Narrative[] = []
    for (const n of list) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    await XingyuStore.putString('narratives', XingyuStore.dumpNarratives(next))
    await XingyuStore.removeFavoritesFor('narrative', id)
    XingyuNav.bump()
  }

  static async loadSparks(): Promise<SparkItem[]> {
    return XingyuStore.parseSparks(await XingyuStore.getString('sparks', ''))
  }

  static async findSpark(id: string): Promise<SparkItem | undefined> {
    const list = await XingyuStore.loadSparks()
    for (const s of list) {
      if (s.id === id) {
        return s
      }
    }
    return undefined
  }

  static async saveSpark(item: SparkItem): Promise<void> {
    item.updatedAt = Date.now()
    const list = await XingyuStore.loadSparks()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === item.id) {
        list[i] = item
        found = true
      }
    }
    if (!found) {
      list.push(item)
    }
    list.sort((a, b) => b.updatedAt - a.updatedAt)
    await XingyuStore.putString('sparks', XingyuStore.dumpSparks(list))
    XingyuNav.bump()
  }

  static async deleteSpark(id: string): Promise<void> {
    const list = await XingyuStore.loadSparks()
    const next: SparkItem[] = []
    for (const s of list) {
      if (s.id !== id) {
        next.push(s)
      }
    }
    await XingyuStore.putString('sparks', XingyuStore.dumpSparks(next))
    await XingyuStore.removeFavoritesFor('spark', id)
    XingyuNav.bump()
  }

  static async loadThemes(): Promise<ThemeSpace[]> {
    return XingyuStore.parseThemes(await XingyuStore.getString('themes', ''))
  }

  static async findTheme(id: string): Promise<ThemeSpace | undefined> {
    const list = await XingyuStore.loadThemes()
    for (const t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async saveTheme(item: ThemeSpace): Promise<void> {
    item.updatedAt = Date.now()
    const list = await XingyuStore.loadThemes()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === item.id) {
        list[i] = item
        found = true
      }
    }
    if (!found) {
      list.push(item)
    }
    list.sort((a, b) => b.updatedAt - a.updatedAt)
    await XingyuStore.putString('themes', XingyuStore.dumpThemes(list))
    XingyuNav.bump()
  }

  static async deleteTheme(id: string): Promise<void> {
    const list = await XingyuStore.loadThemes()
    const next: ThemeSpace[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    await XingyuStore.putString('themes', XingyuStore.dumpThemes(next))
    const ns = await XingyuStore.loadNarratives()
    for (const n of ns) {
      n.themeIds = XingyuStore.withoutId(n.themeIds, id)
    }
    await XingyuStore.putString('narratives', XingyuStore.dumpNarratives(ns))
    const sps = await XingyuStore.loadSparks()
    for (const s of sps) {
      s.themeIds = XingyuStore.withoutId(s.themeIds, id)
    }
    await XingyuStore.putString('sparks', XingyuStore.dumpSparks(sps))
    XingyuNav.bump()
  }

  static async loadTags(): Promise<TagItem[]> {
    return XingyuStore.parseTags(await XingyuStore.getString('tags', ''))
  }

  static async saveTag(item: TagItem): Promise<void> {
    const list = await XingyuStore.loadTags()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === item.id) {
        list[i] = item
        found = true
      }
    }
    if (!found) {
      list.push(item)
    }
    await XingyuStore.persistTags(list)
    XingyuNav.bump()
  }

  static async loadFavorites(): Promise<FavoriteItem[]> {
    return XingyuStore.parseFavs(await XingyuStore.getString('favorites', ''))
  }

  static async toggleFavorite(targetType: string, targetId: string, excerpt: string): Promise<boolean> {
    const list = await XingyuStore.loadFavorites()
    const next: FavoriteItem[] = []
    let existed = false
    for (const f of list) {
      if (f.targetType === targetType && f.targetId === targetId) {
        existed = true
      } else {
        next.push(f)
      }
    }
    if (!existed) {
      next.push(FavoriteItem.createNew(targetType, targetId, excerpt))
    }
    await XingyuStore.putString('favorites', XingyuStore.dumpFavs(next))
    if (targetType === 'narrative') {
      const n = await XingyuStore.findNarrative(targetId)
      if (n !== undefined) {
        n.isFavorite = !existed
        await XingyuStore.saveNarrative(n)
      }
    }
    if (targetType === 'spark') {
      const s = await XingyuStore.findSpark(targetId)
      if (s !== undefined) {
        s.isFavorite = !existed
        await XingyuStore.saveSpark(s)
      }
    }
    XingyuNav.bump()
    return !existed
  }

  static async narrativesOfTheme(themeId: string): Promise<Narrative[]> {
    const list = await XingyuStore.loadNarratives()
    const out: Narrative[] = []
    for (const n of list) {
      if (XingyuStore.hasId(n.themeIds, themeId)) {
        out.push(n)
      }
    }
    return out
  }

  static async sparksOfTheme(themeId: string): Promise<SparkItem[]> {
    const list = await XingyuStore.loadSparks()
    const out: SparkItem[] = []
    for (const s of list) {
      if (XingyuStore.hasId(s.themeIds, themeId)) {
        out.push(s)
      }
    }
    return out
  }

  static async searchAll(q: string): Promise<Narrative[]> {
    const needle = q.trim()
    const out: Narrative[] = []
    if (needle.length === 0) {
      return out
    }
    const list = await XingyuStore.loadNarratives()
    for (const n of list) {
      const blob = `${n.title} ${n.bodyText()} ${n.tags.join(' ')} ${n.dateKey}`
      if (blob.indexOf(needle) >= 0) {
        out.push(n)
      }
    }
    return out
  }

  static async searchSparks(q: string): Promise<SparkItem[]> {
    const needle = q.trim()
    const out: SparkItem[] = []
    if (needle.length === 0) {
      return out
    }
    const list = await XingyuStore.loadSparks()
    for (const s of list) {
      const blob = `${s.title} ${s.body} ${s.plan} ${s.tags.join(' ')} ${s.dateKey}`
      if (blob.indexOf(needle) >= 0) {
        out.push(s)
      }
    }
    return out
  }

  private static hasId(ids: string[], id: string): boolean {
    for (const x of ids) {
      if (x === id) {
        return true
      }
    }
    return false
  }

  private static withoutId(ids: string[], id: string): string[] {
    const out: string[] = []
    for (const x of ids) {
      if (x !== id) {
        out.push(x)
      }
    }
    return out
  }

  private static async removeFavoritesFor(targetType: string, targetId: string): Promise<void> {
    const list = await XingyuStore.loadFavorites()
    const next: FavoriteItem[] = []
    for (const f of list) {
      if (!(f.targetType === targetType && f.targetId === targetId)) {
        next.push(f)
      }
    }
    await XingyuStore.putString('favorites', XingyuStore.dumpFavs(next))
  }

  private static async persistTags(list: TagItem[]): Promise<void> {
    await XingyuStore.putString('tags', XingyuStore.dumpTags(list))
  }

  private static parseNarratives(raw: string): Narrative[] {
    const out: Narrative[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 13) {
        continue
      }
      const n = new Narrative()
      n.id = p[0]
      n.title = p[1]
      n.dateKey = p[2]
      n.templateKey = p[3]
      n.status = p[4]
      n.tags = XingyuCodec.splitCsv(p[5])
      n.themeIds = XingyuCodec.splitCsv(p[6])
      n.fieldA = p[7]
      n.fieldB = p[8]
      n.fieldC = p[9]
      n.isFavorite = p[10] === '1'
      n.createdAt = parseInt(p[11], 10)
      n.updatedAt = parseInt(p[12], 10)
      out.push(n)
    }
    return out
  }

  private static dumpNarratives(list: Narrative[]): string {
    const lines: string[] = []
    for (const n of list) {
      lines.push([
        n.id, XingyuCodec.clean(n.title), n.dateKey, n.templateKey, n.status,
        XingyuCodec.csv(n.tags), XingyuCodec.csv(n.themeIds),
        XingyuCodec.clean(n.fieldA), XingyuCodec.clean(n.fieldB), XingyuCodec.clean(n.fieldC),
        n.isFavorite ? '1' : '0', `${n.createdAt}`, `${n.updatedAt}`
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseSparks(raw: string): SparkItem[] {
    const out: SparkItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 12) {
        continue
      }
      const s = new SparkItem()
      s.id = p[0]
      s.title = p[1]
      s.kind = p[2]
      s.body = p[3]
      s.source = p[4]
      s.plan = p[5]
      s.dateKey = p[6]
      s.tags = XingyuCodec.splitCsv(p[7])
      s.themeIds = XingyuCodec.splitCsv(p[8])
      s.isFavorite = p[9] === '1'
      s.createdAt = parseInt(p[10], 10)
      s.updatedAt = parseInt(p[11], 10)
      out.push(s)
    }
    return out
  }

  private static dumpSparks(list: SparkItem[]): string {
    const lines: string[] = []
    for (const s of list) {
      lines.push([
        s.id, XingyuCodec.clean(s.title), s.kind, XingyuCodec.clean(s.body),
        XingyuCodec.clean(s.source), XingyuCodec.clean(s.plan), s.dateKey,
        XingyuCodec.csv(s.tags), XingyuCodec.csv(s.themeIds),
        s.isFavorite ? '1' : '0', `${s.createdAt}`, `${s.updatedAt}`
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseThemes(raw: string): ThemeSpace[] {
    const out: ThemeSpace[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 5) {
        continue
      }
      const t = new ThemeSpace()
      t.id = p[0]
      t.title = p[1]
      t.coverKey = p[2]
      t.createdAt = parseInt(p[3], 10)
      t.updatedAt = parseInt(p[4], 10)
      out.push(t)
    }
    return out
  }

  private static dumpThemes(list: ThemeSpace[]): string {
    const lines: string[] = []
    for (const t of list) {
      lines.push([t.id, XingyuCodec.clean(t.title), t.coverKey, `${t.createdAt}`, `${t.updatedAt}`].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseTags(raw: string): TagItem[] {
    const out: TagItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 3) {
        continue
      }
      out.push(TagItem.make(p[0], p[1], p[2] === '1'))
    }
    return out
  }

  private static dumpTags(list: TagItem[]): string {
    const lines: string[] = []
    for (const t of list) {
      lines.push([t.id, XingyuCodec.clean(t.name), t.systemTag ? '1' : '0'].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseFavs(raw: string): FavoriteItem[] {
    const out: FavoriteItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 5) {
        continue
      }
      const f = new FavoriteItem()
      f.id = p[0]
      f.targetType = p[1]
      f.targetId = p[2]
      f.excerpt = p[3]
      f.createdAt = parseInt(p[4], 10)
      out.push(f)
    }
    return out
  }

  private static dumpFavs(list: FavoriteItem[]): string {
    const lines: string[] = []
    for (const f of list) {
      lines.push([f.id, f.targetType, f.targetId, XingyuCodec.clean(f.excerpt), `${f.createdAt}`].join('\t'))
    }
    return lines.join('\n')
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (XingyuStore.pref === null) {
      return fallback
    }
    try {
      const v = await XingyuStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (XingyuStore.pref === null) {
      return
    }
    try {
      await XingyuStore.pref.put(key, value)
      await XingyuStore.pref.flush()
    } catch {
    }
  }
}
