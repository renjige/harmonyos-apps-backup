import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  Thought, ReadingRecord, KnowledgeCard, Spark, ThemeSpace, JianProfile
} from '../models/JianModels'
import { DateHelper } from './DateHelper'

const STORE = 'Jian_xu_v1'
const KEY_THOUGHTS = 'thoughts'
const KEY_READINGS = 'readings'
const KEY_CARDS = 'cards'
const KEY_SPARKS = 'sparks'
const KEY_THEMES = 'themes'
const KEY_TAGS = 'tags'
const KEY_PROFILE = 'profile'
const KEY_ACTIVITY = 'activityDates'
const KEY_UNLOCKED = 'unlockedAchievements'
const KEY_ONBOARDING = 'onboardingSeen'

export class JianStore {
  private static pref: preferences.Preferences | null = null
  /** 同进程读写缓存：避免 Preferences 未就绪时 put 静默失败、首页一直读到空 */
  private static mem: Map<string, string> = new Map()

  static bumpRevision(): void {
    const rev = (AppStorage.get<number>('jianDataRev') ?? 0) + 1
    // set 才能稳定通知 @StorageProp/@Watch；仅 setOrCreate 时部分机型不触发重绘
    if (!AppStorage.set('jianDataRev', rev)) {
      AppStorage.setOrCreate('jianDataRev', rev)
    }
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      JianStore.pref = await preferences.getPreferences(context, STORE)
      await JianStore.hydrateMemFromPref()
    } catch {
      JianStore.pref = null
    }
  }

  private static async hydrateMemFromPref(): Promise<void> {
    if (JianStore.pref === null) {
      return
    }
    const keys: string[] = [
      KEY_THOUGHTS, KEY_READINGS, KEY_CARDS, KEY_SPARKS, KEY_THEMES,
      KEY_TAGS, KEY_PROFILE, KEY_ACTIVITY, KEY_UNLOCKED, KEY_ONBOARDING
    ]
    for (const key of keys) {
      try {
        const v = await JianStore.pref.get(key, '')
        if (typeof v === 'string' && v.length > 0) {
          JianStore.mem.set(key, v)
        }
      } catch {
        // ignore single-key hydrate failure
      }
    }
  }

  static async loadThoughts(): Promise<Thought[]> {
    return JianStore.parseThoughts(await JianStore.getString(KEY_THOUGHTS, ''))
  }

  static async findThought(id: string): Promise<Thought | undefined> {
    const list = await JianStore.loadThoughts()
    for (const t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async saveThought(item: Thought): Promise<void> {
    item.updatedAt = Date.now()
    const list = await JianStore.loadThoughts()
    const next = JianStore.upsertThought(list, item)
    await JianStore.putString(KEY_THOUGHTS, JianStore.serializeThoughts(next))
    await JianStore.recordActivity()
    await JianStore.mergeTags(item.tags)
    JianStore.bumpRevision()
  }

  static async deleteThought(id: string): Promise<void> {
    const list = await JianStore.loadThoughts()
    const next: Thought[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    await JianStore.putString(KEY_THOUGHTS, JianStore.serializeThoughts(next))
    JianStore.bumpRevision()
  }

  static async loadReadings(): Promise<ReadingRecord[]> {
    return JianStore.parseReadings(await JianStore.getString(KEY_READINGS, ''))
  }

  static async findReading(id: string): Promise<ReadingRecord | undefined> {
    const list = await JianStore.loadReadings()
    for (const r of list) {
      if (r.id === id) {
        return r
      }
    }
    return undefined
  }

  static async saveReading(item: ReadingRecord): Promise<void> {
    item.updatedAt = Date.now()
    const list = await JianStore.loadReadings()
    const next = JianStore.upsertReading(list, item)
    await JianStore.putString(KEY_READINGS, JianStore.serializeReadings(next))
    await JianStore.recordActivity()
    await JianStore.mergeTags(item.tags)
    JianStore.bumpRevision()
  }

  static async deleteReading(id: string): Promise<void> {
    const list = await JianStore.loadReadings()
    const next: ReadingRecord[] = []
    for (const r of list) {
      if (r.id !== id) {
        next.push(r)
      }
    }
    await JianStore.putString(KEY_READINGS, JianStore.serializeReadings(next))
    JianStore.bumpRevision()
  }

  static async loadCards(): Promise<KnowledgeCard[]> {
    return JianStore.parseCards(await JianStore.getString(KEY_CARDS, ''))
  }

  static async findCard(id: string): Promise<KnowledgeCard | undefined> {
    const list = await JianStore.loadCards()
    for (const c of list) {
      if (c.id === id) {
        return c
      }
    }
    return undefined
  }

  static async saveCard(item: KnowledgeCard): Promise<void> {
    item.updatedAt = Date.now()
    const list = await JianStore.loadCards()
    const next = JianStore.upsertCard(list, item)
    await JianStore.putString(KEY_CARDS, JianStore.serializeCards(next))
    await JianStore.recordActivity()
    await JianStore.mergeTags(item.tags)
    JianStore.bumpRevision()
  }

  static async deleteCard(id: string): Promise<void> {
    const list = await JianStore.loadCards()
    const next: KnowledgeCard[] = []
    for (const c of list) {
      if (c.id !== id) {
        next.push(c)
      }
    }
    await JianStore.putString(KEY_CARDS, JianStore.serializeCards(next))
    JianStore.bumpRevision()
  }

  static async loadSparks(): Promise<Spark[]> {
    return JianStore.parseSparks(await JianStore.getString(KEY_SPARKS, ''))
  }

  static async findSpark(id: string): Promise<Spark | undefined> {
    const list = await JianStore.loadSparks()
    for (const s of list) {
      if (s.id === id) {
        return s
      }
    }
    return undefined
  }

  static async saveSpark(item: Spark): Promise<void> {
    item.updatedAt = Date.now()
    const list = await JianStore.loadSparks()
    const next = JianStore.upsertSpark(list, item)
    await JianStore.putString(KEY_SPARKS, JianStore.serializeSparks(next))
    await JianStore.recordActivity()
    await JianStore.mergeTags(item.tags)
    JianStore.bumpRevision()
  }

  static async deleteSpark(id: string): Promise<void> {
    const list = await JianStore.loadSparks()
    const next: Spark[] = []
    for (const s of list) {
      if (s.id !== id) {
        next.push(s)
      }
    }
    await JianStore.putString(KEY_SPARKS, JianStore.serializeSparks(next))
    JianStore.bumpRevision()
  }

  static async loadThemes(): Promise<ThemeSpace[]> {
    return JianStore.parseThemes(await JianStore.getString(KEY_THEMES, ''))
  }

  static async findTheme(id: string): Promise<ThemeSpace | undefined> {
    const list = await JianStore.loadThemes()
    for (const t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async saveTheme(item: ThemeSpace): Promise<void> {
    item.updatedAt = Date.now()
    const list = await JianStore.loadThemes()
    const next = JianStore.upsertTheme(list, item)
    await JianStore.putString(KEY_THEMES, JianStore.serializeThemes(next))
    await JianStore.recordActivity()
    JianStore.bumpRevision()
  }

  static async deleteTheme(id: string): Promise<void> {
    const list = await JianStore.loadThemes()
    const next: ThemeSpace[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    await JianStore.putString(KEY_THEMES, JianStore.serializeThemes(next))
    await JianStore.unlinkTheme(id)
    JianStore.bumpRevision()
  }

  static async loadProfile(): Promise<JianProfile> {
    const raw = await JianStore.getString(KEY_PROFILE, '')
    const p = new JianProfile()
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

  static async saveProfile(p: JianProfile): Promise<void> {
    await JianStore.putString(KEY_PROFILE, `${JianStore.pack(p.nickname)}\t${p.themeMode}`)
  }

  static async loadTags(): Promise<string[]> {
    return JianStore.splitCsv(await JianStore.getString(KEY_TAGS, ''))
  }

  static async loadUnlocked(): Promise<string[]> {
    return JianStore.splitCsv(await JianStore.getString(KEY_UNLOCKED, ''))
  }

  static async saveUnlocked(ids: string[]): Promise<void> {
    await JianStore.putString(KEY_UNLOCKED, ids.join(','))
  }

  static async isOnboardingSeen(): Promise<boolean> {
    return (await JianStore.getString(KEY_ONBOARDING, '')) === '1'
  }

  static async markOnboardingSeen(): Promise<void> {
    await JianStore.putString(KEY_ONBOARDING, '1')
  }

  static async computeStreakDays(): Promise<number> {
    const raw = await JianStore.getString(KEY_ACTIVITY, '')
    if (raw.length === 0) {
      return 0
    }
    const dateSet: Set<string> = new Set()
    const parts = raw.split('|')
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        dateSet.add(t)
      }
    }
    let offset = 0
    if (!dateSet.has(DateHelper.todayKey())) {
      offset = 1
    }
    let streak = 0
    for (let i = offset; i < 400; i++) {
      if (dateSet.has(DateHelper.daysAgoKey(i))) {
        streak++
      } else {
        break
      }
    }
    return streak
  }

  static async clearAll(): Promise<void> {
    await JianStore.putString(KEY_THOUGHTS, '')
    await JianStore.putString(KEY_READINGS, '')
    await JianStore.putString(KEY_CARDS, '')
    await JianStore.putString(KEY_SPARKS, '')
    await JianStore.putString(KEY_THEMES, '')
    await JianStore.putString(KEY_TAGS, '')
    await JianStore.putString(KEY_ACTIVITY, '')
    await JianStore.putString(KEY_UNLOCKED, '')
    JianStore.bumpRevision()
  }

  static async exportJson(): Promise<string> {
    const thoughts = await JianStore.loadThoughts()
    const readings = await JianStore.loadReadings()
    const cards = await JianStore.loadCards()
    const sparks = await JianStore.loadSparks()
    const themes = await JianStore.loadThemes()
    const lines: string[] = []
    lines.push('{"app":"思维笺",')
    lines.push(`"exportedAt":${Date.now()},`)
    lines.push(`"thoughts":${thoughts.length},`)
    lines.push(`"readings":${readings.length},`)
    lines.push(`"cards":${cards.length},`)
    lines.push(`"sparks":${sparks.length},`)
    lines.push(`"themes":${themes.length}}`)
    const titles: string[] = []
    for (const t of thoughts) {
      titles.push(JianStore.escape(t.title))
    }
    return `${lines.join('')} titles:[${titles.join('|')}]`
  }

  private static async unlinkTheme(id: string): Promise<void> {
    const thoughts = await JianStore.loadThoughts()
    for (const t of thoughts) {
      t.themeIds = JianStore.withoutId(t.themeIds, id)
    }
    await JianStore.putString(KEY_THOUGHTS, JianStore.serializeThoughts(thoughts))
    const readings = await JianStore.loadReadings()
    for (const r of readings) {
      r.themeIds = JianStore.withoutId(r.themeIds, id)
    }
    await JianStore.putString(KEY_READINGS, JianStore.serializeReadings(readings))
    const cards = await JianStore.loadCards()
    for (const c of cards) {
      c.themeIds = JianStore.withoutId(c.themeIds, id)
    }
    await JianStore.putString(KEY_CARDS, JianStore.serializeCards(cards))
    const sparks = await JianStore.loadSparks()
    for (const s of sparks) {
      s.themeIds = JianStore.withoutId(s.themeIds, id)
    }
    await JianStore.putString(KEY_SPARKS, JianStore.serializeSparks(sparks))
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

  private static async recordActivity(): Promise<void> {
    const today = DateHelper.todayKey()
    const raw = await JianStore.getString(KEY_ACTIVITY, '')
    if (raw.indexOf(today) >= 0) {
      return
    }
    const next = raw.length === 0 ? today : `${raw}|${today}`
    await JianStore.putString(KEY_ACTIVITY, next)
  }

  private static async mergeTags(tags: string[]): Promise<void> {
    const all = await JianStore.loadTags()
    for (const t of tags) {
      if (t.length > 0 && !all.includes(t)) {
        all.push(t)
      }
    }
    await JianStore.putString(KEY_TAGS, all.join(','))
  }

  private static upsertThought(list: Thought[], item: Thought): Thought[] {
    const next: Thought[] = []
    let found = false
    for (const t of list) {
      if (t.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(item)
    }
    next.sort((a, b) => b.updatedAt - a.updatedAt)
    return next
  }

  private static upsertReading(list: ReadingRecord[], item: ReadingRecord): ReadingRecord[] {
    const next: ReadingRecord[] = []
    let found = false
    for (const t of list) {
      if (t.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(item)
    }
    next.sort((a, b) => b.updatedAt - a.updatedAt)
    return next
  }

  private static upsertCard(list: KnowledgeCard[], item: KnowledgeCard): KnowledgeCard[] {
    const next: KnowledgeCard[] = []
    let found = false
    for (const t of list) {
      if (t.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(item)
    }
    next.sort((a, b) => b.updatedAt - a.updatedAt)
    return next
  }

  private static upsertSpark(list: Spark[], item: Spark): Spark[] {
    const next: Spark[] = []
    let found = false
    for (const t of list) {
      if (t.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(item)
    }
    next.sort((a, b) => b.updatedAt - a.updatedAt)
    return next
  }

  private static upsertTheme(list: ThemeSpace[], item: ThemeSpace): ThemeSpace[] {
    const next: ThemeSpace[] = []
    let found = false
    for (const t of list) {
      if (t.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(item)
    }
    next.sort((a, b) => b.updatedAt - a.updatedAt)
    return next
  }

  private static serializeThoughts(list: Thought[]): string {
    const lines: string[] = []
    for (const t of list) {
      lines.push([
        t.id, JianStore.pack(t.title), t.categoryKey, t.kind, JianStore.pack(t.body),
        t.tags.join(','), t.status, t.themeIds.join(','), t.favorite ? '1' : '0',
        `${t.createdAt}`, `${t.updatedAt}`
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseThoughts(raw: string): Thought[] {
    const out: Thought[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 11) {
        continue
      }
      const t = new Thought()
      t.id = p[0]
      t.title = JianStore.unpack(p[1])
      t.categoryKey = p[2]
      t.kind = p[3]
      t.body = JianStore.unpack(p[4])
      t.tags = JianStore.splitCsv(p[5])
      t.status = p[6]
      t.themeIds = JianStore.splitCsv(p[7])
      t.favorite = p[8] === '1'
      t.createdAt = parseInt(p[9], 10)
      t.updatedAt = parseInt(p[10], 10)
      out.push(t)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static serializeReadings(list: ReadingRecord[]): string {
    const lines: string[] = []
    for (const r of list) {
      lines.push([
        r.id, JianStore.pack(r.title), r.sourceType, r.readAt,
        JianStore.pack(r.corePoints), JianStore.pack(r.myUnderstanding), JianStore.pack(r.harvest),
        r.tags.join(','), r.themeIds.join(','), r.favorite ? '1' : '0',
        `${r.createdAt}`, `${r.updatedAt}`
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseReadings(raw: string): ReadingRecord[] {
    const out: ReadingRecord[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 12) {
        continue
      }
      const r = new ReadingRecord()
      r.id = p[0]
      r.title = JianStore.unpack(p[1])
      r.sourceType = p[2]
      r.readAt = p[3]
      r.corePoints = JianStore.unpack(p[4])
      r.myUnderstanding = JianStore.unpack(p[5])
      r.harvest = JianStore.unpack(p[6])
      r.tags = JianStore.splitCsv(p[7])
      r.themeIds = JianStore.splitCsv(p[8])
      r.favorite = p[9] === '1'
      r.createdAt = parseInt(p[10], 10)
      r.updatedAt = parseInt(p[11], 10)
      out.push(r)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static serializeCards(list: KnowledgeCard[]): string {
    const lines: string[] = []
    for (const c of list) {
      lines.push([
        c.id, JianStore.pack(c.title), JianStore.pack(c.content), JianStore.pack(c.myUnderstanding),
        c.tags.join(','), c.themeIds.join(','), c.sourceType, c.sourceId, c.favorite ? '1' : '0',
        `${c.createdAt}`, `${c.updatedAt}`
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseCards(raw: string): KnowledgeCard[] {
    const out: KnowledgeCard[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 11) {
        continue
      }
      const c = new KnowledgeCard()
      c.id = p[0]
      c.title = JianStore.unpack(p[1])
      c.content = JianStore.unpack(p[2])
      c.myUnderstanding = JianStore.unpack(p[3])
      c.tags = JianStore.splitCsv(p[4])
      c.themeIds = JianStore.splitCsv(p[5])
      c.sourceType = p[6]
      c.sourceId = p[7]
      c.favorite = p[8] === '1'
      c.createdAt = parseInt(p[9], 10)
      c.updatedAt = parseInt(p[10], 10)
      out.push(c)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static serializeSparks(list: Spark[]): string {
    const lines: string[] = []
    for (const s of list) {
      lines.push([
        s.id, JianStore.pack(s.title), JianStore.pack(s.body), s.kind,
        s.tags.join(','), s.themeIds.join(','), s.favorite ? '1' : '0', s.promotedThoughtId,
        `${s.createdAt}`, `${s.updatedAt}`
      ].join('\t'))
    }
    return lines.join('\n')
  }

  private static parseSparks(raw: string): Spark[] {
    const out: Spark[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 10) {
        continue
      }
      const s = new Spark()
      s.id = p[0]
      s.title = JianStore.unpack(p[1])
      s.body = JianStore.unpack(p[2])
      s.kind = p[3]
      s.tags = JianStore.splitCsv(p[4])
      s.themeIds = JianStore.splitCsv(p[5])
      s.favorite = p[6] === '1'
      s.promotedThoughtId = p[7]
      s.createdAt = parseInt(p[8], 10)
      s.updatedAt = parseInt(p[9], 10)
      out.push(s)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static serializeThemes(list: ThemeSpace[]): string {
    const lines: string[] = []
    for (const t of list) {
      lines.push([
        t.id, JianStore.pack(t.title), JianStore.pack(t.summary), t.tags.join(','),
        `${t.createdAt}`, `${t.updatedAt}`
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
      if (line.length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 6) {
        continue
      }
      const t = new ThemeSpace()
      t.id = p[0]
      t.title = JianStore.unpack(p[1])
      t.summary = JianStore.unpack(p[2])
      t.tags = JianStore.splitCsv(p[3])
      t.createdAt = parseInt(p[4], 10)
      t.updatedAt = parseInt(p[5], 10)
      out.push(t)
    }
    out.sort((a, b) => b.updatedAt - a.updatedAt)
    return out
  }

  private static pack(s: string): string {
    return s.replace(/\t/g, ' ').replace(/\n/g, '¶')
  }

  private static unpack(s: string): string {
    return s.replace(/¶/g, '\n')
  }

  private static escape(s: string): string {
    return s.replace(/\\/g, '\\\\').replace(/"/g, '\\"')
  }

  private static splitCsv(raw: string): string[] {
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

  private static async getString(key: string, fallback: string): Promise<string> {
    const cached = JianStore.mem.get(key)
    if (cached !== undefined) {
      return cached
    }
    if (JianStore.pref === null) {
      return fallback
    }
    try {
      const v = await JianStore.pref.get(key, fallback)
      if (typeof v === 'string') {
        JianStore.mem.set(key, v)
        return v
      }
      return fallback
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    JianStore.mem.set(key, value)
    if (JianStore.pref === null) {
      return
    }
    try {
      await JianStore.pref.put(key, value)
      await JianStore.pref.flush()
    } catch {
      // 已写入 mem，同会话可读；落盘失败不阻断 UI 刷新
    }
  }
}
