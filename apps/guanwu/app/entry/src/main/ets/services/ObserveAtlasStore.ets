import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { ObserveSubject, CategoryOption } from '../models/ObserveCatalog'
import { ImagePathUtil } from './ImagePathUtil'

const STORE = 'guanwu_atlas_v1'
const KEY_ITEMS = 'subjects'

export class ObserveAtlasStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ObserveAtlasStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      ObserveAtlasStore.pref = null
    }
  }

  static async loadAll(): Promise<ObserveSubject[]> {
    const raw = await ObserveAtlasStore.getString(KEY_ITEMS, '')
    return ObserveAtlasStore.parse(raw)
  }

  static async findById(id: string): Promise<ObserveSubject | undefined> {
    const list = await ObserveAtlasStore.loadAll()
    for (const s of list) {
      if (s.id === id) {
        return s
      }
    }
    return undefined
  }

  static async findByName(name: string): Promise<ObserveSubject | undefined> {
    const n = name.trim()
    const list = await ObserveAtlasStore.loadAll()
    for (const s of list) {
      if (s.name === n) {
        return s
      }
    }
    return undefined
  }

  static async save(subject: ObserveSubject): Promise<boolean> {
    const name = subject.name.trim()
    if (name.length === 0 || name.length > 40) {
      return false
    }
    subject.name = name
    subject.traits = subject.traits.trim()
    subject.knowledge = subject.knowledge.trim()
    if (subject.knowledge.length === 0) {
      subject.knowledge = CategoryOption.knowledgeOf(subject.categoryKey)
    }
    if (subject.coverPath.length > 0) {
      subject.coverPath = ImagePathUtil.normalizeStored(subject.coverPath)
    }
    const list = await ObserveAtlasStore.loadAll()
    let found = false
    for (let i = 0; i < list.length; i++) {
      if (list[i].id === subject.id) {
        list[i] = subject
        found = true
      }
    }
    if (!found) {
      if (subject.id.length === 0) {
        const created = ObserveSubject.create(name, subject.categoryKey)
        created.traits = subject.traits
        created.knowledge = subject.knowledge
        created.coverPath = subject.coverPath
        created.tags = subject.tags
        created.remindWeekly = subject.remindWeekly
        list.push(created)
        subject.id = created.id
      } else {
        list.push(subject)
      }
    }
    await ObserveAtlasStore.persist(list)
    return true
  }

  static async ensureNamed(name: string, categoryKey: string, coverPath: string): Promise<string> {
    const trimmed = name.trim()
    if (trimmed.length === 0) {
      return ''
    }
    const existing = await ObserveAtlasStore.findByName(trimmed)
    if (existing !== undefined) {
      if (coverPath.length > 0 && existing.coverPath.length === 0) {
        existing.coverPath = ImagePathUtil.normalizeStored(coverPath)
        await ObserveAtlasStore.save(existing)
      }
      return existing.id
    }
    const created = ObserveSubject.create(trimmed, categoryKey)
    if (coverPath.length > 0) {
      created.coverPath = ImagePathUtil.normalizeStored(coverPath)
    }
    await ObserveAtlasStore.save(created)
    return created.id
  }

  static async deleteById(id: string): Promise<void> {
    const list = await ObserveAtlasStore.loadAll()
    const next: ObserveSubject[] = []
    for (const s of list) {
      if (s.id !== id) {
        next.push(s)
      }
    }
    await ObserveAtlasStore.persist(next)
  }

  static async filterByCategory(key: string): Promise<ObserveSubject[]> {
    const list = await ObserveAtlasStore.loadAll()
    if (key.length === 0 || key === 'all') {
      return list
    }
    const out: ObserveSubject[] = []
    for (const s of list) {
      if (s.categoryKey === key) {
        out.push(s)
      }
    }
    return out
  }

  private static async persist(items: ObserveSubject[]): Promise<void> {
    const lines: string[] = []
    for (const s of items) {
      const name = s.name.replace(/\t/g, ' ')
      const traits = s.traits.replace(/\t/g, ' ').replace(/\n/g, ' ')
      const knowledge = s.knowledge.replace(/\t/g, ' ').replace(/\n/g, ' ')
      const tags = s.tags.replace(/\t/g, ',')
      const weekly = s.remindWeekly ? '1' : '0'
      lines.push([s.id, name, s.categoryKey, traits, knowledge, s.coverPath, tags, `${s.createdAt}`, weekly].join('\t'))
    }
    await ObserveAtlasStore.putString(KEY_ITEMS, lines.join('\n'))
  }

  private static parse(raw: string): ObserveSubject[] {
    const out: ObserveSubject[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 8) {
        continue
      }
      const s = new ObserveSubject()
      s.id = parts[0]
      s.name = parts[1]
      s.categoryKey = parts[2]
      s.traits = parts[3]
      s.knowledge = parts[4]
      s.coverPath = parts[5]
      s.tags = parts[6]
      s.createdAt = parseInt(parts[7], 10)
      s.remindWeekly = parts.length >= 9 && parts[8] === '1'
      out.push(s)
    }
    out.sort((a, b) => b.createdAt - a.createdAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (ObserveAtlasStore.pref === null) {
      return fallback
    }
    try {
      const v = await ObserveAtlasStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (ObserveAtlasStore.pref === null) {
      return
    }
    try {
      await ObserveAtlasStore.pref.put(key, value)
      await ObserveAtlasStore.pref.flush()
    } catch {
    }
  }
}
