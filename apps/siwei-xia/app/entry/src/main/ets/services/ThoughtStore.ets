import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { ThoughtCard, TagStat } from '../models/ThoughtModels'
import { AppContextService } from './AppContextService'
import { ImagePathUtil } from './ImagePathUtil'
import { ClassifyService } from './ClassifyService'

const STORE = 'siwei_xia_v1'
const KEY_CARDS = 'cards'
const KEY_EXTRA = 'extra_tags'
const DAY_MS = 86400000
const RETAIN_DAYS = 30

export class ThoughtStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ThoughtStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ThoughtStore.pref = null
    }
  }

  static async ensureReady(): Promise<void> {
    if (ThoughtStore.pref !== null) {
      return
    }
    const ctx = AppContextService.getContext()
    if (ctx !== null) {
      await ThoughtStore.init(ctx)
    }
  }

  static async extraTags(): Promise<string[]> {
    const raw = await ThoughtStore.getString(KEY_EXTRA, '')
    const out: string[] = []
    if (raw.length === 0) {
      return out
    }
    const parts = raw.split(',')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  static async addExtraTag(name: string): Promise<void> {
    const n = name.trim()
    if (n.length === 0) {
      return
    }
    const list = await ThoughtStore.extraTags()
    for (const it of list) {
      if (it === n) {
        return
      }
    }
    list.push(n)
    await ThoughtStore.putString(KEY_EXTRA, list.join(','))
    ThoughtStore.bump()
  }

  private static async setExtraTags(list: string[]): Promise<void> {
    const cleaned: string[] = []
    for (const it of list) {
      ClassifyService.pushUnique(cleaned, it)
    }
    await ThoughtStore.putString(KEY_EXTRA, cleaned.join(','))
  }

  /** 灵感页点选：默认标签 + 用户新增 + 已用于卡片的标签 */
  static async pickableTagNames(): Promise<string[]> {
    const names: string[] = ['工作', '生活', '灵感', '项目', '阅读']
    for (const e of await ThoughtStore.extraTags()) {
      ClassifyService.pushUnique(names, e)
    }
    const stats = await ThoughtStore.tagStats()
    for (const s of stats) {
      if (s.name !== '未分类') {
        ClassifyService.pushUnique(names, s.name)
      }
    }
    return names
  }

  static async loadActive(): Promise<ThoughtCard[]> {
    const all = await ThoughtStore.loadAll()
    const out: ThoughtCard[] = []
    for (const it of all) {
      if (it.deletedAt === 0 && it.archived === 0) {
        out.push(it)
      }
    }
    return out
  }

  static async loadTrash(): Promise<ThoughtCard[]> {
    const all = await ThoughtStore.loadAll()
    const out: ThoughtCard[] = []
    for (const it of all) {
      if (it.deletedAt > 0) {
        out.push(it)
      }
    }
    return out
  }

  static async loadAll(): Promise<ThoughtCard[]> {
    const raw = await ThoughtStore.getString(KEY_CARDS, '')
    const list = ThoughtStore.parseCards(raw)
    const now = Date.now()
    const kept: ThoughtCard[] = []
    let purged = false
    for (const it of list) {
      if (it.deletedAt > 0 && now - it.deletedAt > RETAIN_DAYS * DAY_MS) {
        purged = true
        continue
      }
      kept.push(it)
    }
    if (purged) {
      await ThoughtStore.persist(kept)
    }
    return kept
  }

  static async save(card: ThoughtCard): Promise<void> {
    card.updatedAt = Date.now()
    card.imagePath = ImagePathUtil.normalizeStored(card.imagePath)
    const list = await ThoughtStore.loadAll()
    const next: ThoughtCard[] = []
    let found = false
    for (const it of list) {
      if (it.id === card.id) {
        next.push(card)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.unshift(card)
    }
    await ThoughtStore.persist(next)
    ThoughtStore.bump()
  }

  static async softDelete(id: string): Promise<void> {
    const list = await ThoughtStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        it.deletedAt = Date.now()
        it.updatedAt = it.deletedAt
      }
    }
    await ThoughtStore.persist(list)
    ThoughtStore.bump()
  }

  static async restore(id: string): Promise<void> {
    const list = await ThoughtStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        it.deletedAt = 0
        it.updatedAt = Date.now()
      }
    }
    await ThoughtStore.persist(list)
    ThoughtStore.bump()
  }

  static async purge(id: string): Promise<void> {
    const list = await ThoughtStore.loadAll()
    const next: ThoughtCard[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await ThoughtStore.persist(next)
    ThoughtStore.bump()
  }

  static async findById(id: string): Promise<ThoughtCard | undefined> {
    const list = await ThoughtStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async byShelf(shelf: string): Promise<ThoughtCard[]> {
    const list = await ThoughtStore.loadActive()
    if (shelf.length === 0 || shelf === '全部') {
      return list
    }
    const out: ThoughtCard[] = []
    for (const it of list) {
      if (it.shelf === shelf) {
        out.push(it)
      }
    }
    return out
  }

  static async byTag(tag: string): Promise<ThoughtCard[]> {
    const list = await ThoughtStore.loadActive()
    if (tag.length === 0) {
      return list
    }
    const out: ThoughtCard[] = []
    for (const it of list) {
      const tags = it.tags()
      for (const t of tags) {
        if (t === tag) {
          out.push(it)
          break
        }
      }
    }
    return out
  }

  static async search(q: string): Promise<ThoughtCard[]> {
    const needle = q.trim().toLowerCase()
    const list = await ThoughtStore.loadActive()
    if (needle.length === 0) {
      return list
    }
    const out: ThoughtCard[] = []
    for (const it of list) {
      const hay = `${it.body} ${it.tagsCsv}`.toLowerCase()
      if (hay.indexOf(needle) >= 0) {
        out.push(it)
      }
    }
    return out
  }

  static async tagStats(): Promise<TagStat[]> {
    const list = await ThoughtStore.loadActive()
    const names: string[] = []
    const counts: number[] = []
    for (const it of list) {
      const tags = it.tags()
      if (tags.length === 0) {
        ThoughtStore.addCount(names, counts, '未分类')
      } else {
        for (const t of tags) {
          ThoughtStore.addCount(names, counts, t)
        }
      }
    }
    const out: TagStat[] = []
    for (let i = 0; i < names.length; i++) {
      const s = new TagStat()
      s.name = names[i]
      s.count = counts[i]
      out.push(s)
    }
    return out
  }

  static async renameTag(from: string, to: string): Promise<void> {
    const nextName = to.trim()
    if (from.length === 0 || nextName.length === 0 || from === nextName) {
      return
    }
    const list = await ThoughtStore.loadAll()
    for (const it of list) {
      const tags = it.tags()
      const mapped: string[] = []
      for (const t of tags) {
        mapped.push(t === from ? nextName : t)
      }
      it.tagsCsv = mapped.join(',')
      it.updatedAt = Date.now()
    }
    await ThoughtStore.persist(list)

    const extras = await ThoughtStore.extraTags()
    const nextExtras: string[] = []
    let replaced = false
    for (const t of extras) {
      if (t === from) {
        ClassifyService.pushUnique(nextExtras, nextName)
        replaced = true
      } else {
        ClassifyService.pushUnique(nextExtras, t)
      }
    }
    if (!replaced) {
      ClassifyService.pushUnique(nextExtras, nextName)
    }
    await ThoughtStore.setExtraTags(nextExtras)
    ThoughtStore.bump()
  }

  static async removeTag(name: string): Promise<void> {
    const list = await ThoughtStore.loadAll()
    for (const it of list) {
      const tags = it.tags()
      const mapped: string[] = []
      for (const t of tags) {
        if (t !== name) {
          mapped.push(t)
        }
      }
      it.tagsCsv = mapped.join(',')
      it.updatedAt = Date.now()
    }
    await ThoughtStore.persist(list)

    const extras = await ThoughtStore.extraTags()
    const nextExtras: string[] = []
    for (const t of extras) {
      if (t !== name) {
        nextExtras.push(t)
      }
    }
    await ThoughtStore.setExtraTags(nextExtras)
    ThoughtStore.bump()
  }

  static async exportText(markdown: boolean): Promise<string> {
    const list = await ThoughtStore.loadActive()
    const lines: string[] = []
    if (markdown) {
      lines.push('# 思维匣导出')
      lines.push('')
    } else {
      lines.push('思维匣导出')
      lines.push('')
    }
    for (const it of list) {
      if (markdown) {
        lines.push(`## ${it.titleLine()}`)
        if (it.tagsCsv.length > 0) {
          lines.push(`标签：${it.tagsCsv}`)
        }
        lines.push('')
        lines.push(it.body)
        lines.push('')
      } else {
        lines.push('---')
        lines.push(it.titleLine())
        lines.push(it.tagsCsv)
        lines.push(it.body)
        lines.push('')
      }
    }
    return lines.join('\n')
  }

  private static addCount(names: string[], counts: number[], name: string): void {
    for (let i = 0; i < names.length; i++) {
      if (names[i] === name) {
        counts[i] = counts[i] + 1
        return
      }
    }
    names.push(name)
    counts.push(1)
  }

  private static bump(): void {
    const n = AppStorage.get<number>('tbReload') ?? 0
    AppStorage.setOrCreate('tbReload', n + 1)
  }

  private static async persist(items: ThoughtCard[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(ThoughtStore.serialize(it))
    }
    await ThoughtStore.putString(KEY_CARDS, lines.join('\n'))
  }

  private static serialize(it: ThoughtCard): string {
    return [
      it.id,
      `${it.createdAt}`,
      `${it.updatedAt}`,
      `${it.deletedAt}`,
      `${it.archived}`,
      `${it.mapX}`,
      `${it.mapY}`,
      ThoughtStore.enc(it.tagsCsv),
      ThoughtStore.enc(it.imagePath),
      ThoughtStore.enc(it.shelf),
      ThoughtStore.enc(it.body)
    ].join('|')
  }

  private static parseCards(raw: string): ThoughtCard[] {
    const out: ThoughtCard[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('|')
      if (p.length < 10) {
        continue
      }
      const c = new ThoughtCard()
      c.id = p[0]
      c.createdAt = parseInt(p[1], 10)
      c.updatedAt = parseInt(p[2], 10)
      c.deletedAt = parseInt(p[3], 10)
      c.archived = parseInt(p[4], 10)
      c.mapX = parseInt(p[5], 10)
      c.mapY = parseInt(p[6], 10)
      c.tagsCsv = ThoughtStore.dec(p[7])
      c.imagePath = ImagePathUtil.normalizeStored(ThoughtStore.dec(p[8]))
      if (p.length >= 11) {
        c.shelf = ThoughtStore.dec(p[9])
        c.body = ThoughtStore.dec(p.slice(10).join('|'))
      } else {
        c.shelf = '想法'
        c.body = ThoughtStore.dec(p.slice(9).join('|'))
      }
      out.push(c)
    }
    return out
  }

  private static enc(s: string): string {
    return s.split('\\').join('\\\\').split('\n').join('\\n').split('|').join('\\p')
  }

  private static dec(s: string): string {
    return s.split('\\p').join('|').split('\\n').join('\n').split('\\\\').join('\\')
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    await ThoughtStore.ensureReady()
    if (ThoughtStore.pref === null) {
      return fallback
    }
    try {
      const v = await ThoughtStore.pref.get(key, fallback)
      if (typeof v === 'string') {
        return v
      }
      return fallback
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    await ThoughtStore.ensureReady()
    if (ThoughtStore.pref === null) {
      return
    }
    try {
      await ThoughtStore.pref.put(key, value)
      await ThoughtStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
