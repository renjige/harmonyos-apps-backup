import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { EssayFile, EssayItem, EssayWire, QuoteFav, TagStat } from '../models/EssayModels'
import { DawnMedia } from './DawnMedia'
import { EssayDateUtil } from './EssayDateUtil'
import { EssaySmartTag } from './EssaySmartTag'

const STORE_NAME = 'chenguang_jian_local'
const KEY_ESSAYS = 'essays_json'
const KEY_FAV = 'fav_quotes_json'
const KEY_QUOTE_DAY = 'last_quote_day'
const KEY_DARK = 'dark_mode'
const KEY_FONT = 'font_level'

export class EssayStore {
  private static pref: preferences.Preferences | null = null
  private static essays: EssayItem[] = []
  private static favs: QuoteFav[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      EssayStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const rawValue = await EssayStore.pref.get(KEY_ESSAYS, '[]')
      const raw: string = typeof rawValue === 'string' ? rawValue : '[]'
      EssayStore.essays = EssayStore.parseEssays(raw)
      const favRawVal = await EssayStore.pref.get(KEY_FAV, '[]')
      const favRaw: string = typeof favRawVal === 'string' ? favRawVal : '[]'
      EssayStore.favs = EssayStore.parseFavs(favRaw)
      const dark = await EssayStore.pref.get(KEY_DARK, false)
      const font = await EssayStore.pref.get(KEY_FONT, 1)
      const quoteDay = await EssayStore.pref.get(KEY_QUOTE_DAY, '')
      AppStorage.setOrCreate('darkModeOn', dark === true)
      AppStorage.setOrCreate('fontLevel', typeof font === 'number' ? font : 1)
      AppStorage.setOrCreate('lastQuoteDay', typeof quoteDay === 'string' ? quoteDay : '')
    } catch {
      EssayStore.essays = []
      EssayStore.favs = []
    }
  }

  static all(): EssayItem[] {
    const copy: EssayItem[] = []
    for (const n of EssayStore.essays) {
      copy.push(n)
    }
    return copy
  }

  static active(): EssayItem[] {
    const out: EssayItem[] = []
    for (const n of EssayStore.sorted()) {
      if (!n.isArchived) {
        out.push(n)
      }
    }
    return out
  }

  static sorted(): EssayItem[] {
    const work: EssayItem[] = EssayStore.all()
    const result: EssayItem[] = []
    while (work.length > 0) {
      let best: EssayItem | undefined = undefined
      for (const n of work) {
        if (best === undefined || n.createdAt > best.createdAt) {
          best = n
        }
      }
      if (best === undefined) {
        break
      }
      result.push(best)
      const next: EssayItem[] = []
      for (const n of work) {
        if (n.id !== best.id) {
          next.push(n)
        }
      }
      work.length = 0
      for (const n of next) {
        work.push(n)
      }
    }
    return result
  }

  static find(id: string): EssayItem | undefined {
    for (const n of EssayStore.essays) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static byTag(tag: string): EssayItem[] {
    const out: EssayItem[] = []
    for (const n of EssayStore.active()) {
      for (const t of n.tagList()) {
        if (t === tag) {
          out.push(n)
          break
        }
      }
    }
    return out
  }

  static byDate(iso: string): EssayItem[] {
    const out: EssayItem[] = []
    for (const n of EssayStore.active()) {
      if (EssayDateUtil.isoFromTs(n.createdAt) === iso) {
        out.push(n)
      }
    }
    return out
  }

  static datesInMonth(year: number, month: number): string[] {
    const prefix = month < 10 ? `${year}-0${month}-` : `${year}-${month}-`
    const out: string[] = []
    for (const n of EssayStore.active()) {
      const iso = EssayDateUtil.isoFromTs(n.createdAt)
      if (iso.indexOf(prefix) === 0) {
        let exists = false
        for (const d of out) {
          if (d === iso) {
            exists = true
          }
        }
        if (!exists) {
          out.push(iso)
        }
      }
    }
    return out
  }

  static tagStats(): TagStat[] {
    const names: string[] = []
    const counts: number[] = []
    for (const n of EssayStore.active()) {
      for (const t of n.tagList()) {
        let idx = -1
        for (let i = 0; i < names.length; i++) {
          if (names[i] === t) {
            idx = i
          }
        }
        if (idx < 0) {
          names.push(t)
          counts.push(1)
        } else {
          counts[idx] = counts[idx] + 1
        }
      }
    }
    const stats: TagStat[] = []
    for (let i = 0; i < names.length; i++) {
      const s = new TagStat()
      s.name = names[i]
      s.count = counts[i]
      stats.push(s)
    }
    const ordered: TagStat[] = []
    while (stats.length > 0) {
      let best: TagStat | undefined = undefined
      let bestI = 0
      for (let i = 0; i < stats.length; i++) {
        if (best === undefined || stats[i].count > best.count) {
          best = stats[i]
          bestI = i
        }
      }
      if (best === undefined) {
        break
      }
      ordered.push(best)
      stats.splice(bestI, 1)
    }
    return ordered
  }

  static totalCount(): number {
    return EssayStore.active().length
  }

  static totalWords(): number {
    let n = 0
    for (const e of EssayStore.active()) {
      n = n + e.wordCount()
    }
    return n
  }

  static streakDays(): number {
    const days: string[] = []
    for (const e of EssayStore.active()) {
      const iso = EssayDateUtil.isoFromTs(e.createdAt)
      let exists = false
      for (const d of days) {
        if (d === iso) {
          exists = true
        }
      }
      if (!exists) {
        days.push(iso)
      }
    }
    let streak = 0
    const cursor = new Date()
    while (true) {
      const iso = EssayDateUtil.isoFromDate(cursor)
      let hit = false
      for (const d of days) {
        if (d === iso) {
          hit = true
        }
      }
      if (!hit) {
        if (streak === 0 && iso === EssayDateUtil.todayIso()) {
          cursor.setDate(cursor.getDate() - 1)
          continue
        }
        break
      }
      streak += 1
      cursor.setDate(cursor.getDate() - 1)
      if (streak > 400) {
        break
      }
    }
    return streak
  }

  static async save(item: EssayItem): Promise<void> {
    item.updatedAt = Date.now()
    if (item.coverKey.length === 0) {
      item.coverKey = DawnMedia.keyForId(item.id)
    }
    const next: EssayItem[] = []
    let found = false
    for (const n of EssayStore.essays) {
      if (n.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(n)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    EssayStore.essays = next
    await EssayStore.flushEssays()
  }

  static async remove(id: string): Promise<void> {
    const next: EssayItem[] = []
    for (const n of EssayStore.essays) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    EssayStore.essays = next
    await EssayStore.flushEssays()
  }

  static async archive(id: string, archived: boolean): Promise<void> {
    const found = EssayStore.find(id)
    if (found === undefined) {
      return
    }
    found.isArchived = archived
    await EssayStore.save(found)
  }

  static createDraft(title: string, content: string, tags: string[], weather: string, align: string): EssayItem {
    const item = new EssayItem()
    item.id = EssayDateUtil.newId()
    item.title = title
    item.content = content
    item.tagsCsv = EssaySmartTag.csv(tags)
    item.weather = weather
    item.align = align
    item.coverKey = DawnMedia.keyForId(item.id)
    item.createdAt = Date.now()
    item.updatedAt = item.createdAt
    return item
  }

  static exportText(): string {
    let out = '晨光笺 导出\n\n'
    for (const e of EssayStore.sorted()) {
      if (e.isArchived) {
        continue
      }
      out = `${out}# ${e.displayTitle()}\n${EssayDateUtil.cardTime(e.createdAt)}`
      if (e.weather.length > 0) {
        out = `${out} · ${e.weather}`
      }
      out = `${out}\n${e.content}\n`
      if (e.tagsCsv.length > 0) {
        out = `${out}#${e.tagsCsv.split(',').join(' #')}\n`
      }
      out = `${out}\n---\n\n`
    }
    return out
  }

  static favQuotes(): QuoteFav[] {
    const copy: QuoteFav[] = []
    for (const f of EssayStore.favs) {
      copy.push(f)
    }
    return copy
  }

  static isFav(id: string): boolean {
    for (const f of EssayStore.favs) {
      if (f.id === id) {
        return true
      }
    }
    return false
  }

  static async toggleFav(id: string, title: string, body: string): Promise<boolean> {
    if (EssayStore.isFav(id)) {
      const next: QuoteFav[] = []
      for (const f of EssayStore.favs) {
        if (f.id !== id) {
          next.push(f)
        }
      }
      EssayStore.favs = next
      await EssayStore.flushFavs()
      return false
    }
    const q = new QuoteFav()
    q.id = id
    q.title = title
    q.body = body
    EssayStore.favs.unshift(q)
    await EssayStore.flushFavs()
    return true
  }

  static async markQuoteShown(iso: string): Promise<void> {
    AppStorage.setOrCreate('lastQuoteDay', iso)
    if (EssayStore.pref === null) {
      return
    }
    try {
      await EssayStore.pref.put(KEY_QUOTE_DAY, iso)
      await EssayStore.pref.flush()
    } catch {
      return
    }
  }

  static shouldShowQuote(): boolean {
    const last = AppStorage.get<string>('lastQuoteDay') ?? ''
    return last !== EssayDateUtil.todayIso()
  }

  static async setDark(on: boolean): Promise<void> {
    AppStorage.setOrCreate('darkModeOn', on)
    if (EssayStore.pref === null) {
      return
    }
    try {
      await EssayStore.pref.put(KEY_DARK, on)
      await EssayStore.pref.flush()
    } catch {
      return
    }
  }

  static async setFontLevel(level: number): Promise<void> {
    if (EssayStore.pref === null) {
      return
    }
    try {
      await EssayStore.pref.put(KEY_FONT, level)
      await EssayStore.pref.flush()
    } catch {
      return
    }
  }

  private static async flushEssays(): Promise<void> {
    if (EssayStore.pref === null) {
      return
    }
    let json = '['
    for (let i = 0; i < EssayStore.essays.length; i++) {
      if (i > 0) {
        json = `${json},`
      }
      json = `${json}${EssayStore.essays[i].toJsonString()}`
    }
    json = `${json}]`
    try {
      await EssayStore.pref.put(KEY_ESSAYS, json)
      await EssayStore.pref.flush()
    } catch {
      return
    }
  }

  private static async flushFavs(): Promise<void> {
    if (EssayStore.pref === null) {
      return
    }
    let json = '['
    for (let i = 0; i < EssayStore.favs.length; i++) {
      if (i > 0) {
        json = `${json},`
      }
      const f = EssayStore.favs[i]
      json = `${json}{"id":${JSON.stringify(f.id)},"title":${JSON.stringify(f.title)},"body":${JSON.stringify(f.body)}}`
    }
    json = `${json}]`
    try {
      await EssayStore.pref.put(KEY_FAV, json)
      await EssayStore.pref.flush()
    } catch {
      return
    }
  }

  private static parseEssays(raw: string): EssayItem[] {
    const out: EssayItem[] = []
    try {
      const arr = JSON.parse(raw) as EssayWire[]
      if (arr === undefined || arr === null) {
        return out
      }
      for (const w of arr) {
        out.push(EssayItem.fromWire(w))
      }
    } catch {
      return out
    }
    return out
  }

  private static parseFavs(raw: string): QuoteFav[] {
    const out: QuoteFav[] = []
    try {
      const arr = JSON.parse(raw) as QuoteFav[]
      if (arr === undefined || arr === null) {
        return out
      }
      for (const w of arr) {
        const q = new QuoteFav()
        q.id = w.id
        q.title = w.title
        q.body = w.body
        out.push(q)
      }
    } catch {
      return out
    }
    return out
  }
}
