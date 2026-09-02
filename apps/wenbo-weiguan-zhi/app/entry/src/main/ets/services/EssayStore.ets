import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { MicroEssay } from '../models/EssayModels'
import { DateHelper } from './DateHelper'
import { GrowthStore } from './GrowthStore'

const STORE = 'weiguan_essay_v1'
const KEY_ENTRIES = 'essays'
const KEY_DRAFT_PREFIX = 'draft_'

export class EssayStore {
  private static pref: preferences.Preferences | null = null
  private static memoryEntries: string = ''

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      EssayStore.pref = await preferences.getPreferences(context, STORE)
      const existing = await EssayStore.pref.get(KEY_ENTRIES, '')
      EssayStore.memoryEntries = `${existing}`
    } catch {
      EssayStore.pref = null
    }
  }

  static async loadAll(): Promise<MicroEssay[]> {
    const raw = await EssayStore.getString(KEY_ENTRIES, '')
    return EssayStore.parseEntries(raw)
  }

  static async persistAll(items: MicroEssay[]): Promise<void> {
    await EssayStore.persistEntries(items)
    EssayStore.notifyChange()
  }

  static async saveEssay(essay: MicroEssay): Promise<void> {
    essay.recomputeWordCount()
    essay.updatedAt = Date.now()
    await GrowthStore.attachActiveTheme(essay)
    const list = await EssayStore.loadAll()
    const next: MicroEssay[] = []
    let found = false
    for (const it of list) {
      if (it.id === essay.id) {
        next.push(essay)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(essay)
    }
    next.sort((a, b) => b.updatedAt - a.updatedAt)
    await GrowthStore.relinkEssayThemes(next)
    await EssayStore.persistEntries(next)
    await EssayStore.clearDraft(essay.id)
    try {
      const toast = await GrowthStore.syncAfterSave(next)
      if (toast.length > 0) {
        AppStorage.setOrCreate('growthToast', toast)
      }
    } catch {
      // 成长联动失败不影响随笔已保存
    }
    EssayStore.notifyChange()
  }

  static async deleteEssay(id: string): Promise<void> {
    const list = await EssayStore.loadAll()
    const next: MicroEssay[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await EssayStore.persistEntries(next)
    await EssayStore.clearDraft(id)
    await GrowthStore.removeEssay(id)
    await GrowthStore.syncAfterSave(next)
    EssayStore.notifyChange()
  }

  static async findById(id: string): Promise<MicroEssay | undefined> {
    const list = await EssayStore.loadAll()
    for (const it of list) {
      if (it.id === id) {
        return it
      }
    }
    return undefined
  }

  static async saveDraft(id: string, title: string, body: string, tagsCsv: string, imagePath: string): Promise<void> {
    const payload = [title, body, tagsCsv, imagePath].join('\u0001')
    await EssayStore.putString(`${KEY_DRAFT_PREFIX}${id}`, payload, false)
  }

  static async loadDraft(id: string): Promise<MicroEssay | undefined> {
    const raw = await EssayStore.getString(`${KEY_DRAFT_PREFIX}${id}`, '')
    if (raw.length === 0) {
      return undefined
    }
    const parts = raw.split('\u0001')
    const e = new MicroEssay()
    e.id = id
    e.title = parts.length > 0 ? parts[0] : ''
    e.body = parts.length > 1 ? parts[1] : ''
    e.tagsCsv = parts.length > 2 ? parts[2] : ''
    e.imagePath = parts.length > 3 ? parts[3] : ''
    return e
  }

  static async clearDraft(id: string): Promise<void> {
    await EssayStore.putString(`${KEY_DRAFT_PREFIX}${id}`, '')
  }

  static async toggleFavorite(id: string): Promise<void> {
    const found = await EssayStore.findById(id)
    if (found === undefined) {
      return
    }
    found.favorite = !found.favorite
    await EssayStore.saveEssay(found)
  }

  static async loadRecentUpdated(limit: number): Promise<MicroEssay[]> {
    const list = await EssayStore.loadAll()
    const out: MicroEssay[] = []
    for (let i = 0; i < list.length && i < limit; i++) {
      out.push(list[i])
    }
    return out
  }

  static async loadRecentBrowsed(limit: number): Promise<MicroEssay[]> {
    const list = await EssayStore.loadAll()
    const opened: MicroEssay[] = []
    for (const it of list) {
      if (it.lastOpenedAt > 0) {
        opened.push(it)
      }
    }
    opened.sort((a, b) => b.lastOpenedAt - a.lastOpenedAt)
    const out: MicroEssay[] = []
    for (let i = 0; i < opened.length && i < limit; i++) {
      out.push(opened[i])
    }
    return out
  }

  static async markOpened(id: string): Promise<void> {
    const found = await EssayStore.findById(id)
    if (found === undefined) {
      return
    }
    found.lastOpenedAt = Date.now()
    const list = await EssayStore.loadAll()
    const next: MicroEssay[] = []
    for (const it of list) {
      if (it.id === id) {
        next.push(found)
      } else {
        next.push(it)
      }
    }
    await EssayStore.persistEntries(next)
  }

  static async findRandomInMonth(year: number, month: number): Promise<MicroEssay | undefined> {
    const list = await EssayStore.loadAll()
    const monthList = GrowthStore.loadMonthEssays(list, year, month)
    if (monthList.length === 0) {
      return undefined
    }
    const idx = Math.floor(Math.random() * monthList.length)
    return monthList[idx]
  }

  static async findRandom(): Promise<MicroEssay | undefined> {
    const list = await EssayStore.loadAll()
    if (list.length === 0) {
      return undefined
    }
    const idx = Math.floor(Math.random() * list.length)
    return list[idx]
  }

  static async loadByDate(dateKey: string): Promise<MicroEssay[]> {
    const list = await EssayStore.loadAll()
    const want = DateHelper.normalizeKey(dateKey)
    const out: MicroEssay[] = []
    for (const it of list) {
      if (EssayStore.resolvedDateKey(it) === want) {
        out.push(it)
      }
    }
    return out
  }

  static resolvedDateKey(it: MicroEssay): string {
    const n = DateHelper.normalizeKey(it.dateKey)
    if (n.length > 0) {
      return n
    }
    if (it.createdAt > 0) {
      return DateHelper.keyFromDate(new Date(it.createdAt))
    }
    if (it.updatedAt > 0) {
      return DateHelper.keyFromDate(new Date(it.updatedAt))
    }
    return ''
  }

  static isInWeek(it: MicroEssay): boolean {
    const today = DateHelper.todayKey()
    const weekStart = DateHelper.addDaysKey(today, -6)
    const key = EssayStore.resolvedDateKey(it)
    if (key.length > 0 && key >= weekStart && key <= today) {
      return true
    }
    const ts = it.updatedAt > 0 ? it.updatedAt : it.createdAt
    if (ts <= 0) {
      return false
    }
    return ts >= Date.now() - 7 * 24 * 60 * 60 * 1000
  }

  static async loadWeek(): Promise<MicroEssay[]> {
    const list = await EssayStore.loadAll()
    const out: MicroEssay[] = []
    for (const it of list) {
      if (EssayStore.isInWeek(it)) {
        out.push(it)
      }
    }
    return out
  }

  private static notifyChange(): void {
    const cur = AppStorage.get<number>('essayDataEpoch') ?? 0
    AppStorage.setOrCreate('essayDataEpoch', cur + 1)
  }

  static async exportMarkdown(): Promise<string> {
    const list = await EssayStore.loadAll()
    const lines: string[] = []
    lines.push('# 微观志 — 导出')
    lines.push('')
    lines.push(`共 ${list.length} 篇 · ${new Date().toLocaleString()}`)
    lines.push('')
    for (const it of list) {
      lines.push('---')
      lines.push(`## ${it.title.length > 0 ? it.title : '无标题'}`)
      lines.push('')
      lines.push(`> ${it.dateKey} · ${it.wordCount} 字`)
      if (it.tagsCsv.length > 0) {
        lines.push('')
        lines.push(`标签：${it.tagsCsv.replace(/,/g, ' · ')}`)
      }
      lines.push('')
      lines.push(it.body)
      lines.push('')
    }
    return lines.join('\n')
  }

  static async exportPlainText(): Promise<string> {
    const list = await EssayStore.loadAll()
    const lines: string[] = []
    lines.push('微观志 — 导出')
    lines.push(`共 ${list.length} 篇`)
    lines.push('')
    for (const it of list) {
      lines.push('---')
      lines.push(it.title.length > 0 ? it.title : '无标题')
      lines.push(`${it.dateKey} · ${it.wordCount} 字`)
      if (it.tagsCsv.length > 0) {
        lines.push(`标签：${it.tagsCsv}`)
      }
      lines.push('')
      lines.push(MicroEssay.stripMarkup(it.body))
      lines.push('')
    }
    return lines.join('\n')
  }

  private static async persistEntries(items: MicroEssay[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(EssayStore.serialize(it))
    }
    await EssayStore.putString(KEY_ENTRIES, lines.join('\n'))
  }

  private static serialize(it: MicroEssay): string {
    const title = it.title.replace(/\n/g, ' ')
    const body = it.body.replace(/\n/g, '\\n')
    const tags = it.tagsCsv.replace(/,/g, '，')
    return [
      it.id, title, body, tags, it.imagePath, `${it.wordCount}`,
      `${it.createdAt}`, `${it.updatedAt}`, it.dateKey,
      it.favorite ? '1' : '0', it.senseKey,
      it.albumId, it.themeId, it.kind, `${it.lastOpenedAt}`, it.contrastSourceIdsCsv
    ].join('\t')
  }

  private static parseEntries(raw: string): MicroEssay[] {
    const out: MicroEssay[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 9) {
        continue
      }
      const e = new MicroEssay()
      e.id = parts[0]
      e.title = parts[1]
      e.body = parts[2].replace(/\\n/g, '\n')
      e.tagsCsv = parts[3].replace(/，/g, ',')
      e.imagePath = parts[4]
      e.wordCount = parseInt(parts[5], 10)
      e.createdAt = parseInt(parts[6], 10)
      e.updatedAt = parseInt(parts[7], 10)
      e.dateKey = DateHelper.normalizeKey(parts[8])
      if (e.dateKey.length === 0) {
        e.dateKey = DateHelper.normalizeKey(parts[8].replace(/\./g, '-'))
      }
      if (e.dateKey.length === 0 && e.createdAt > 0) {
        e.dateKey = DateHelper.keyFromDate(new Date(e.createdAt))
      }
      if (e.dateKey.length === 0 && e.updatedAt > 0) {
        e.dateKey = DateHelper.keyFromDate(new Date(e.updatedAt))
      }
      if (parts.length >= 10) {
        e.favorite = parts[9] === '1'
      }
      if (parts.length >= 11) {
        e.senseKey = parts[10]
      }
      if (parts.length >= 12) {
        e.albumId = parts[11]
      }
      if (parts.length >= 13) {
        e.themeId = parts[12]
      }
      if (parts.length >= 14) {
        e.kind = parts[13]
      }
      if (parts.length >= 15) {
        e.lastOpenedAt = parseInt(parts[14], 10)
        if (Number.isNaN(e.lastOpenedAt)) {
          e.lastOpenedAt = 0
        }
      }
      if (parts.length >= 16) {
        e.contrastSourceIdsCsv = parts[15]
      }
      if (Number.isNaN(e.wordCount)) {
        e.wordCount = 0
      }
      e.recomputeWordCount()
      out.push(e)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (EssayStore.pref === null) {
      if (key === KEY_ENTRIES && EssayStore.memoryEntries.length > 0) {
        return EssayStore.memoryEntries
      }
      return fallback
    }
    try {
      const v = await EssayStore.pref.get(key, fallback)
      const text = `${v}`
      if (key === KEY_ENTRIES) {
        if (text.length > 0) {
          EssayStore.memoryEntries = text
          return text
        }
        if (EssayStore.memoryEntries.length > 0) {
          return EssayStore.memoryEntries
        }
      }
      return text
    } catch {
      if (key === KEY_ENTRIES && EssayStore.memoryEntries.length > 0) {
        return EssayStore.memoryEntries
      }
      return fallback
    }
  }

  private static async putString(key: string, value: string, flushNow: boolean = true): Promise<void> {
    if (key === KEY_ENTRIES) {
      EssayStore.memoryEntries = value
    }
    if (EssayStore.pref === null) {
      return
    }
    try {
      await EssayStore.pref.put(key, value)
      if (flushNow) {
        await EssayStore.pref.flush()
      }
    } catch {
      // keep memory copy
    }
  }
}
