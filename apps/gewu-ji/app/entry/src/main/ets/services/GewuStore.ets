import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { TraceStats, UserProfile } from '../models/KnowledgeModels'
import { KnowledgeCatalog } from './KnowledgeCatalog'
import { DateHelper } from './DateHelper'
import { FieldStore } from '../services/FieldStore'
import { HomeRefresh } from '../services/HomeRefresh'
import { AtlasKind, AtlasStat } from '../models/FieldModels'

const STORE = 'gewu_trace_v1'
const KEY_READ_DATES = 'readDates'
const KEY_FAVORITES = 'favoriteIds'
const KEY_DEEPEN = 'deepenIds'
const KEY_PROFILE = 'profile'
const KEY_NOTES = 'notes'
const KEY_INQUIRY = 'inquiry'
const KEY_INTRO = 'productIntroSeen'

export class GewuStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      GewuStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      GewuStore.pref = null
    }
    await FieldStore.init(context)
    const favs = await GewuStore.favoriteIds()
    await FieldStore.setFavCount(favs.length)
  }

  static async needsProductIntro(): Promise<boolean> {
    const v = await GewuStore.getString(KEY_INTRO, '0')
    return v !== '1'
  }

  static async markProductIntroSeen(): Promise<void> {
    await GewuStore.putString(KEY_INTRO, '1')
  }

  static async readDates(): Promise<string[]> {
    const raw = await GewuStore.getString(KEY_READ_DATES, '')
    return GewuStore.splitLines(raw)
  }

  static async favoriteIds(): Promise<string[]> {
    const raw = await GewuStore.getString(KEY_FAVORITES, '')
    return GewuStore.splitLines(raw)
  }

  static async deepenIds(): Promise<string[]> {
    const raw = await GewuStore.getString(KEY_DEEPEN, '')
    return GewuStore.splitLines(raw)
  }

  static async isReadToday(): Promise<boolean> {
    const today = DateHelper.todayKey()
    const dates = await GewuStore.readDates()
    for (const d of dates) {
      if (d === today) {
        return true
      }
    }
    return false
  }

  static async isFavorite(id: string): Promise<boolean> {
    const ids = await GewuStore.favoriteIds()
    for (const item of ids) {
      if (item === id) {
        return true
      }
    }
    return false
  }

  static async isDeepen(id: string): Promise<boolean> {
    const ids = await GewuStore.deepenIds()
    for (const item of ids) {
      if (item === id) {
        return true
      }
    }
    return false
  }

  static async markReadToday(): Promise<void> {
    const today = DateHelper.todayKey()
    const dates = await GewuStore.readDates()
    let exists = false
    for (const d of dates) {
      if (d === today) {
        exists = true
      }
    }
    if (!exists) {
      dates.push(today)
      dates.sort()
      await GewuStore.putString(KEY_READ_DATES, dates.join('\n'))
      await FieldStore.completeQuest('read')
      const obj = KnowledgeCatalog.todayObject()
      await FieldStore.logEvent('read', obj.title, obj.id)
      await FieldStore.evaluateBadges()
    }
    HomeRefresh.bump()
  }

  static async toggleFavorite(id: string): Promise<boolean> {
    const ids = await GewuStore.favoriteIds()
    const next: string[] = []
    let removed = false
    for (const item of ids) {
      if (item === id) {
        removed = true
      } else {
        next.push(item)
      }
    }
    if (!removed) {
      next.push(id)
    }
    await GewuStore.putString(KEY_FAVORITES, next.join('\n'))
    await FieldStore.setFavCount(next.length)
    if (!removed) {
      await FieldStore.completeQuest('collect')
      const obj = KnowledgeCatalog.resolveById(id)
      const title = obj !== undefined ? obj.title : id
      await FieldStore.logEvent('fav', title, id)
      if (obj !== undefined && obj.atlasKind === '植物图鉴') {
        await FieldStore.completeQuest('plant')
      }
    }
    HomeRefresh.bump()
    return !removed
  }

  static async toggleDeepen(id: string): Promise<boolean> {
    const ids = await GewuStore.deepenIds()
    const next: string[] = []
    let removed = false
    for (const item of ids) {
      if (item === id) {
        removed = true
      } else {
        next.push(item)
      }
    }
    if (!removed) {
      next.push(id)
    }
    await GewuStore.putString(KEY_DEEPEN, next.join('\n'))
    HomeRefresh.bump()
    return !removed
  }

  static async loadProfile(): Promise<UserProfile> {
    const raw = await GewuStore.getString(KEY_PROFILE, '')
    const p = new UserProfile()
    if (raw.length === 0) {
      return p
    }
    const parts = raw.split('\t')
    if (parts.length >= 1) {
      p.nickname = parts[0]
    }
    if (parts.length >= 2 && parts[1].length > 0) {
      p.themeMode = parts[1]
    }
    return p
  }

  static async saveProfile(profile: UserProfile): Promise<void> {
    const line = `${profile.nickname}\t${profile.themeMode}`
    await GewuStore.putString(KEY_PROFILE, line)
  }

  static async stats(): Promise<TraceStats> {
    const s = new TraceStats()
    const dates = await GewuStore.readDates()
    const favs = await GewuStore.favoriteIds()
    const deepens = await GewuStore.deepenIds()
    s.readDays = dates.length
    s.favoriteCount = favs.length
    s.deepenCount = deepens.length
    s.noteCount = (await GewuStore.journalObjectIds()).length
    s.totalPool = KnowledgeCatalog.loadPool().length
    s.recordCount = (await FieldStore.loadRecords()).length
    s.albumCount = await FieldStore.albumCount()
    s.questDone = await FieldStore.questDoneCount()
    s.exploreStreak = await FieldStore.recordStreak()
    if (s.readDays === 0 && s.recordCount === 0) {
      s.streakHint = '从今日一格或一条观察记录开始，积累格物足迹'
    } else if (s.exploreStreak > 0) {
      s.streakHint = `观察连续 ${s.exploreStreak} 天 · 已阅读 ${s.readDays} 天`
    } else if (s.readDays < 7) {
      s.streakHint = `已阅读 ${s.readDays} 天，坚持每日一格`
    } else {
      s.streakHint = `已阅读 ${s.readDays} 天，格物致知渐入佳境`
    }
    return s
  }

  static async atlasStats(): Promise<AtlasStat[]> {
    const favs = await GewuStore.favoriteIds()
    const recs = await FieldStore.loadRecords()
    const kinds = AtlasKind.all()
    const out: AtlasStat[] = []
    for (const k of kinds) {
      const s = new AtlasStat()
      s.kind = k
      const items = KnowledgeCatalog.filterByAtlas(k)
      s.total = items.length
      let n = 0
      for (const item of items) {
        let hit = false
        for (const id of favs) {
          if (id === item.id) {
            hit = true
          }
        }
        for (const r of recs) {
          if (r.subjectId === item.id) {
            hit = true
          }
        }
        if (hit) {
          n++
        }
      }
      s.saved = n
      out.push(s)
    }
    return out
  }

  static async clearCache(): Promise<void> {
    await GewuStore.flush()
  }

  static async flush(): Promise<void> {
    if (GewuStore.pref === null) {
      return
    }
    try {
      await GewuStore.pref.flush()
    } catch {
      // ignore
    }
  }

  static async loadNote(id: string): Promise<string> {
    return await GewuStore.lookupPair(KEY_NOTES, id)
  }

  static async saveNote(id: string, text: string): Promise<void> {
    const trimmed = text.trim()
    if (trimmed.length === 0) {
      await GewuStore.removePair(KEY_NOTES, id)
      return
    }
    await GewuStore.upsertPair(KEY_NOTES, id, trimmed)
  }

  static async deleteNote(id: string): Promise<void> {
    await GewuStore.removePair(KEY_NOTES, id)
  }

  static async noteObjectIds(): Promise<string[]> {
    return await GewuStore.pairIds(KEY_NOTES)
  }

  static async inquiryObjectIds(): Promise<string[]> {
    return await GewuStore.pairIds(KEY_INQUIRY)
  }

  static async journalObjectIds(): Promise<string[]> {
    const notes = await GewuStore.noteObjectIds()
    const inquiry = await GewuStore.inquiryObjectIds()
    const out: string[] = []
    for (const id of notes) {
      out.push(id)
    }
    for (const id of inquiry) {
      let exists = false
      for (const item of out) {
        if (item === id) {
          exists = true
        }
      }
      if (!exists) {
        out.push(id)
      }
    }
    return out
  }

  static async loadInquiry(id: string): Promise<string[]> {
    const out: string[] = ['', '', '']
    if (id.length === 0) {
      return out
    }
    out[0] = await GewuStore.getString(`inq_a_${id}`, '')
    out[1] = await GewuStore.getString(`inq_b_${id}`, '')
    out[2] = await GewuStore.getString(`inq_c_${id}`, '')
    if (out[0].length > 0 || out[1].length > 0 || out[2].length > 0) {
      return out
    }
    const raw = await GewuStore.lookupPair(KEY_INQUIRY, id)
    if (raw.length === 0) {
      return out
    }
    let parts: string[] = raw.split('|||')
    if (parts.length < 2) {
      parts = raw.split('\u0001')
    }
    if (parts.length >= 1) {
      out[0] = parts[0]
    }
    if (parts.length >= 2) {
      out[1] = parts[1]
    }
    if (parts.length >= 3) {
      out[2] = parts[2]
    }
    if (out[0].length > 0 || out[1].length > 0 || out[2].length > 0) {
      await GewuStore.saveInquiry(id, out[0], out[1], out[2])
    }
    return out
  }

  static async saveInquiry(id: string, a1: string, a2: string, a3: string): Promise<void> {
    if (id.length === 0) {
      return
    }
    await GewuStore.putString(`inq_a_${id}`, a1)
    await GewuStore.putString(`inq_b_${id}`, a2)
    await GewuStore.putString(`inq_c_${id}`, a3)
    await GewuStore.upsertPair(KEY_INQUIRY, id, `${a1}|||${a2}|||${a3}`)
    HomeRefresh.bump()
  }

  private static encodeBody(text: string): string {
    return text.split('\n').join('\\n').split('\t').join(' ')
  }

  private static decodeBody(text: string): string {
    return text.split('\\n').join('\n')
  }

  private static async lookupPair(storeKey: string, id: string): Promise<string> {
    const lines = await GewuStore.splitLines(await GewuStore.getString(storeKey, ''))
    for (const line of lines) {
      const idx = line.indexOf('\t')
      if (idx <= 0) {
        continue
      }
      if (line.substring(0, idx) === id) {
        return GewuStore.decodeBody(line.substring(idx + 1))
      }
    }
    return ''
  }

  private static async pairIds(storeKey: string): Promise<string[]> {
    const lines = await GewuStore.splitLines(await GewuStore.getString(storeKey, ''))
    const out: string[] = []
    for (const line of lines) {
      const idx = line.indexOf('\t')
      if (idx > 0) {
        out.push(line.substring(0, idx))
      }
    }
    return out
  }

  private static async upsertPair(storeKey: string, id: string, body: string): Promise<void> {
    const lines = await GewuStore.splitLines(await GewuStore.getString(storeKey, ''))
    const next: string[] = []
    let found = false
    const encoded = `${id}\t${GewuStore.encodeBody(body)}`
    for (const line of lines) {
      const idx = line.indexOf('\t')
      if (idx > 0 && line.substring(0, idx) === id) {
        next.push(encoded)
        found = true
      } else {
        next.push(line)
      }
    }
    if (!found) {
      next.push(encoded)
    }
    await GewuStore.putString(storeKey, next.join('\n'))
  }

  private static async removePair(storeKey: string, id: string): Promise<void> {
    const lines = await GewuStore.splitLines(await GewuStore.getString(storeKey, ''))
    const next: string[] = []
    for (const line of lines) {
      const idx = line.indexOf('\t')
      if (idx > 0 && line.substring(0, idx) === id) {
        continue
      }
      next.push(line)
    }
    await GewuStore.putString(storeKey, next.join('\n'))
  }

  static async objectsForFolio(favoritesOnly: boolean, readOnly: boolean): Promise<string[]> {
    if (favoritesOnly) {
      return await GewuStore.favoriteIds()
    }
    if (readOnly) {
      return await GewuStore.deepenIds()
    }
    const favs = await GewuStore.favoriteIds()
    const readDates = await GewuStore.readDates()
    if (readDates.length === 0 && favs.length === 0) {
      return []
    }
    const out: string[] = []
    for (const id of favs) {
      let exists = false
      for (const item of out) {
        if (item === id) {
          exists = true
        }
      }
      if (!exists) {
        out.push(id)
      }
    }
    return out
  }

  static async readDateForObject(id: string): Promise<string> {
    const todayObj = KnowledgeCatalog.todayObject()
    if (todayObj.id === id && await GewuStore.isReadToday()) {
      return DateHelper.todayKey()
    }
    return ''
  }

  private static splitLines(raw: string): string[] {
    const out: string[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length > 0) {
        out.push(line)
      }
    }
    return out
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (GewuStore.pref === null) {
      return fallback
    }
    try {
      const v = await GewuStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (GewuStore.pref === null) {
      return
    }
    try {
      await GewuStore.pref.put(key, value)
      await GewuStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
