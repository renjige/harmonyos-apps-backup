import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { MicroEssay } from '../models/EssayModels'
import { ObserveAlbum, ObserveBadge, ObserveEvent, ObserveTheme } from '../models/GrowthModels'
import { BadgeService } from './BadgeService'
import { DateHelper } from './DateHelper'
import { SenseCardService } from './SenseCardService'

const STORE = 'weiguan_growth_v1'
const KEY_ALBUMS = 'albums'
const KEY_THEMES = 'themes'
const KEY_BADGES = 'badges'

export class GrowthStore {
  private static pref: preferences.Preferences | null = null
  private static memAlbums: string = ''
  private static memThemes: string = ''
  private static memBadges: string = ''

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      GrowthStore.pref = await preferences.getPreferences(context, STORE)
      GrowthStore.memAlbums = `${await GrowthStore.pref.get(KEY_ALBUMS, '')}`
      GrowthStore.memThemes = `${await GrowthStore.pref.get(KEY_THEMES, '')}`
      GrowthStore.memBadges = `${await GrowthStore.pref.get(KEY_BADGES, '')}`
    } catch {
      GrowthStore.pref = null
    }
  }

  static async loadAlbums(): Promise<ObserveAlbum[]> {
    return GrowthStore.parseAlbums(await GrowthStore.getMem(KEY_ALBUMS))
  }

  static async loadThemes(): Promise<ObserveTheme[]> {
    return GrowthStore.parseThemes(await GrowthStore.getMem(KEY_THEMES))
  }

  static async loadBadges(): Promise<ObserveBadge[]> {
    return BadgeService.mergeCatalog(GrowthStore.parseBadges(await GrowthStore.getMem(KEY_BADGES)))
  }

  static async saveAlbum(album: ObserveAlbum): Promise<void> {
    const list = await GrowthStore.loadAlbums()
    const next: ObserveAlbum[] = []
    let found = false
    for (const it of list) {
      if (it.id === album.id) {
        next.push(album)
        found = true
      } else {
        next.push(it)
      }
    }
    if (!found) {
      next.push(album)
    }
    await GrowthStore.putMem(KEY_ALBUMS, GrowthStore.serializeAlbums(next))
  }

  static async deleteAlbum(id: string): Promise<void> {
    const list = await GrowthStore.loadAlbums()
    const next: ObserveAlbum[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await GrowthStore.putMem(KEY_ALBUMS, GrowthStore.serializeAlbums(next))
  }

  static async saveTheme(theme: ObserveTheme): Promise<void> {
    const list = await GrowthStore.loadThemes()
    const next: ObserveTheme[] = []
    let found = false
    for (const it of list) {
      if (it.id === theme.id) {
        next.push(theme)
        found = true
      } else {
        if (theme.isActive() && it.isActive()) {
          it.status = 'paused'
        }
        next.push(it)
      }
    }
    if (!found) {
      if (theme.isActive()) {
        for (const it of next) {
          if (it.isActive()) {
            it.status = 'paused'
          }
        }
      }
      next.push(theme)
    }
    await GrowthStore.putMem(KEY_THEMES, GrowthStore.serializeThemes(next))
  }

  static async deleteTheme(id: string): Promise<void> {
    const list = await GrowthStore.loadThemes()
    const next: ObserveTheme[] = []
    for (const it of list) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await GrowthStore.putMem(KEY_THEMES, GrowthStore.serializeThemes(next))
  }

  static async attachActiveTheme(essay: MicroEssay): Promise<void> {
    if (essay.themeId.length > 0) {
      return
    }
    const themes = await GrowthStore.loadThemes()
    const key = GrowthStore.essayDateKey(essay)
    for (const t of themes) {
      if (!t.isActive()) {
        continue
      }
      if (!SenseCardService.matchesThemeSense(t.senseKey, essay.senseKey, essay.body)) {
        continue
      }
      if (t.startKey.length > 0 && key.length > 0 && key < t.startKey) {
        continue
      }
      if (t.endKey.length > 0 && key.length > 0 && key > t.endKey) {
        continue
      }
      essay.themeId = t.id
      return
    }
  }

  static themeProgress(theme: ObserveTheme, essays: MicroEssay[]): number {
    let n = 0
    for (const it of essays) {
      if (GrowthStore.essayCountsForTheme(theme, it)) {
        n++
      }
    }
    return n
  }

  static essayCountsForTheme(theme: ObserveTheme, it: MicroEssay): boolean {
    if (it.themeId === theme.id) {
      return true
    }
    if (it.themeId.length > 0 && it.themeId !== theme.id) {
      return false
    }
    const key = GrowthStore.essayDateKey(it)
    if (key.length === 0) {
      return false
    }
    if (theme.startKey.length > 0 && key < theme.startKey) {
      return false
    }
    if (theme.endKey.length > 0 && key > theme.endKey) {
      return false
    }
    if (!SenseCardService.matchesThemeSense(theme.senseKey, it.senseKey, it.body)) {
      return false
    }
    return true
  }

  private static essayDateKey(it: MicroEssay): string {
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

  static async repairAndRelink(essays: MicroEssay[]): Promise<boolean> {
    const themes = await GrowthStore.loadThemes()
    let themeChanged = false
    const today = DateHelper.todayKey()
    const floor = DateHelper.addDaysKey(today, -29)
    for (const t of themes) {
      if (!t.isActive()) {
        continue
      }
      if (t.startKey.length === 0 || t.startKey > floor) {
        t.startKey = floor
        themeChanged = true
      }
      if (t.endKey.length === 0 || t.endKey < today) {
        t.endKey = DateHelper.addDaysKey(today, 29)
        themeChanged = true
      }
    }
    if (themeChanged) {
      await GrowthStore.putMem(KEY_THEMES, GrowthStore.serializeThemes(themes))
    }
    const essayChanged = await GrowthStore.relinkEssayThemes(essays)
    return themeChanged || essayChanged
  }

  static async relinkEssayThemes(essays: MicroEssay[]): Promise<boolean> {
    let changed = false
    for (const it of essays) {
      if (it.themeId.length > 0) {
        continue
      }
      const before = it.themeId
      await GrowthStore.attachActiveTheme(it)
      if (it.themeId !== before) {
        changed = true
      }
    }
    return changed
  }

  static async refreshThemeStatus(essays: MicroEssay[]): Promise<void> {
    const themes = await GrowthStore.loadThemes()
    let changed = false
    for (const t of themes) {
      if (!t.isActive()) {
        continue
      }
      const n = GrowthStore.themeProgress(t, essays)
      if (n >= t.targetCount) {
        t.status = 'done'
        changed = true
      }
    }
    if (changed) {
      await GrowthStore.putMem(KEY_THEMES, GrowthStore.serializeThemes(themes))
    }
  }

  static async syncAfterSave(essays: MicroEssay[]): Promise<string> {
    await GrowthStore.refreshThemeStatus(essays)
    const themes = await GrowthStore.loadThemes()
    const previous = await GrowthStore.loadBadges()
    const streak = GrowthStore.streakOf(essays)
    const fresh = BadgeService.newlyUnlocked(essays, themes, streak, previous)
    if (fresh.length === 0) {
      return ''
    }
    const merged = BadgeService.applyUnlocks(previous, fresh)
    await GrowthStore.putMem(KEY_BADGES, GrowthStore.serializeBadges(merged))
    return fresh[0].title
  }

  static async removeEssay(essayId: string): Promise<void> {
    const albums = await GrowthStore.loadAlbums()
    let changed = false
    for (const a of albums) {
      if (a.contains(essayId)) {
        a.removeEssay(essayId)
        changed = true
      }
    }
    if (changed) {
      await GrowthStore.putMem(KEY_ALBUMS, GrowthStore.serializeAlbums(albums))
    }
  }

  static async putEssayInAlbum(essayId: string, albumId: string): Promise<void> {
    const albums = await GrowthStore.loadAlbums()
    for (const a of albums) {
      if (a.id === albumId) {
        a.addEssay(essayId)
      } else {
        a.removeEssay(essayId)
      }
    }
    await GrowthStore.putMem(KEY_ALBUMS, GrowthStore.serializeAlbums(albums))
  }

  static async findAlbum(id: string): Promise<ObserveAlbum | undefined> {
    const list = await GrowthStore.loadAlbums()
    for (const a of list) {
      if (a.id === id) {
        return a
      }
    }
    return undefined
  }

  static async findTheme(id: string): Promise<ObserveTheme | undefined> {
    const list = await GrowthStore.loadThemes()
    for (const t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async activeTheme(): Promise<ObserveTheme | undefined> {
    const list = await GrowthStore.loadThemes()
    for (const t of list) {
      if (t.isActive()) {
        return t
      }
    }
    return undefined
  }

  static buildFootprint(essays: MicroEssay[], year: number, month: number): ObserveEvent[] {
    const prefix = GrowthStore.monthPrefix(year, month)
    const out: ObserveEvent[] = []
    for (const it of essays) {
      if (!it.dateKey.startsWith(prefix)) {
        continue
      }
      out.push(GrowthStore.eventOf(`${it.id}_w`, it, 'write', '写下观察'))
      if (it.favorite) {
        out.push(GrowthStore.eventOf(`${it.id}_f`, it, 'favorite', '珍藏'))
      }
      if (it.kind === 'contrast' || it.tagsCsv.indexOf('对照') >= 0) {
        out.push(GrowthStore.eventOf(`${it.id}_c`, it, 'contrast', '对照观察'))
      }
    }
    out.sort((a, b) => b.at - a.at)
    const cap: ObserveEvent[] = []
    const max = out.length < 20 ? out.length : 20
    for (let i = 0; i < max; i++) {
      cap.push(out[i])
    }
    return cap
  }

  private static eventOf(id: string, it: MicroEssay, type: string, fallback: string): ObserveEvent {
    const e = new ObserveEvent()
    e.id = id
    e.dateKey = it.dateKey
    e.at = it.updatedAt > 0 ? it.updatedAt : it.createdAt
    e.type = type
    e.essayId = it.id
    e.title = it.title.length > 0 ? it.title : fallback
    return e
  }

  static monthPrefix(year: number, month: number): string {
    const ms = month < 10 ? `0${month}` : `${month}`
    return `${year}-${ms}`
  }

  static loadMonthEssays(essays: MicroEssay[], year: number, month: number): MicroEssay[] {
    const prefix = GrowthStore.monthPrefix(year, month)
    const out: MicroEssay[] = []
    for (const it of essays) {
      if (it.dateKey.startsWith(prefix)) {
        out.push(it)
      }
    }
    return out
  }

  static loadYearEssays(essays: MicroEssay[], year: number): MicroEssay[] {
    const prefix = `${year}-`
    const out: MicroEssay[] = []
    for (const it of essays) {
      let key = DateHelper.normalizeKey(it.dateKey)
      if (key.length === 0 && it.createdAt > 0) {
        key = DateHelper.keyFromDate(new Date(it.createdAt))
      }
      if (key.startsWith(prefix)) {
        out.push(it)
      }
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  static streakOf(entries: MicroEssay[]): number {
    const keys: string[] = []
    for (const it of entries) {
      const key = it.dateKey
      if (key.length === 0) {
        continue
      }
      let exists = false
      for (const k of keys) {
        if (k === key) {
          exists = true
          break
        }
      }
      if (!exists) {
        keys.push(key)
      }
    }
    let streak = 0
    const cursor = new Date()
    for (let i = 0; i < 366; i++) {
      const key = DateHelper.keyFromDate(cursor)
      let hit = false
      for (const k of keys) {
        if (k === key) {
          hit = true
          break
        }
      }
      if (hit) {
        streak++
      } else if (i > 0) {
        break
      }
      cursor.setDate(cursor.getDate() - 1)
    }
    return streak
  }

  static todayWritten(essays: MicroEssay[]): boolean {
    const today = DateHelper.todayKey()
    for (const it of essays) {
      if (GrowthStore.essayDateKey(it) === today) {
        return true
      }
    }
    return false
  }

  private static async getMem(key: string): Promise<string> {
    if (key === KEY_ALBUMS) {
      return GrowthStore.readKey(KEY_ALBUMS, GrowthStore.memAlbums)
    }
    if (key === KEY_THEMES) {
      return GrowthStore.readKey(KEY_THEMES, GrowthStore.memThemes)
    }
    return GrowthStore.readKey(KEY_BADGES, GrowthStore.memBadges)
  }

  private static async readKey(key: string, memory: string): Promise<string> {
    if (GrowthStore.pref === null) {
      return memory
    }
    try {
      const v = `${await GrowthStore.pref.get(key, memory)}`
      if (v.length > 0) {
        return v
      }
      return memory
    } catch {
      return memory
    }
  }

  private static async putMem(key: string, value: string): Promise<void> {
    if (key === KEY_ALBUMS) {
      GrowthStore.memAlbums = value
    } else if (key === KEY_THEMES) {
      GrowthStore.memThemes = value
    } else {
      GrowthStore.memBadges = value
    }
    if (GrowthStore.pref === null) {
      return
    }
    try {
      await GrowthStore.pref.put(key, value)
      await GrowthStore.pref.flush()
    } catch {
    }
  }

  private static serializeAlbums(list: ObserveAlbum[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push([it.id, it.title.replace(/\t/g, ' '), `${it.createdAt}`, it.essayIdsCsv].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseAlbums(raw: string): ObserveAlbum[] {
    const out: ObserveAlbum[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('\t')
      if (parts.length < 3) {
        continue
      }
      const a = new ObserveAlbum()
      a.id = parts[0]
      a.title = parts[1]
      a.createdAt = parseInt(parts[2], 10)
      a.essayIdsCsv = parts.length >= 4 ? parts[3] : ''
      out.push(a)
    }
    return out
  }

  private static serializeThemes(list: ObserveTheme[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push([
        it.id, it.title.replace(/\t/g, ' '), it.senseKey, `${it.targetCount}`,
        it.startKey, it.endKey, it.status, `${it.createdAt}`
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseThemes(raw: string): ObserveTheme[] {
    const out: ObserveTheme[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('\t')
      if (parts.length < 8) {
        continue
      }
      const t = new ObserveTheme()
      t.id = parts[0]
      t.title = parts[1]
      t.senseKey = parts[2]
      t.targetCount = parseInt(parts[3], 10)
      t.startKey = parts[4]
      t.endKey = parts[5]
      t.status = parts[6]
      t.createdAt = parseInt(parts[7], 10)
      if (Number.isNaN(t.targetCount) || t.targetCount < 1) {
        t.targetCount = 7
      }
      out.push(t)
    }
    return out
  }

  private static serializeBadges(list: ObserveBadge[]): string {
    const lines: string[] = []
    for (const it of list) {
      lines.push(`${it.id}\t${it.unlockedAt}`)
    }
    return lines.join('\n')
  }

  private static parseBadges(raw: string): ObserveBadge[] {
    const out: ObserveBadge[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('\t')
      if (parts.length < 2) {
        continue
      }
      const b = new ObserveBadge()
      b.id = parts[0]
      b.unlockedAt = parseInt(parts[1], 10)
      if (Number.isNaN(b.unlockedAt)) {
        b.unlockedAt = 0
      }
      out.push(b)
    }
    return out
  }
}
