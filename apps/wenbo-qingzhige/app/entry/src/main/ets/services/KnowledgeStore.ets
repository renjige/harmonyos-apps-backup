import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { KnowledgeFile, KnowledgeItem, KnowledgeWire, SparkFile, SparkItem, SparkWire } from '../models/KnowledgeModels'
import { AuthService } from './AuthService'
import { KnowledgeBizService } from './KnowledgeBizService'
import { KnowledgeTime } from './CategorySuggest'

const STORE_NAME = 'qingzhige_local'
const KEY_NOTES = 'knowledge_json'
const KEY_SPARKS = 'sparks_json'
const KEY_SEEDED = 'samples_seeded'
const KEY_DARK = 'dark_mode'
const KEY_STREAK = 'review_streak'
const KEY_STREAK_DAY = 'review_streak_day'
const KEY_REVIEW_TOTAL = 'review_total'
const KEY_HISTORY = 'search_history'

export class KnowledgeStore {
  private static pref: preferences.Preferences | null = null
  private static notes: KnowledgeItem[] = []
  private static sparks: SparkItem[] = []
  private static streak: number = 0
  private static streakDay: string = ''
  private static reviewTotal: number = 0
  private static history: string[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      KnowledgeStore.pref = await preferences.getPreferences(context, STORE_NAME)
      const rawNotes = await KnowledgeStore.pref.get(KEY_NOTES, '[]')
      const notesStr: string = typeof rawNotes === 'string' ? rawNotes : '[]'
      KnowledgeStore.notes = KnowledgeStore.parseNotes(notesStr)
      const rawSparks = await KnowledgeStore.pref.get(KEY_SPARKS, '[]')
      const sparksStr: string = typeof rawSparks === 'string' ? rawSparks : '[]'
      KnowledgeStore.sparks = KnowledgeStore.parseSparks(sparksStr)
      const seeded = await KnowledgeStore.pref.get(KEY_SEEDED, false)
      if (seeded !== true && KnowledgeStore.notes.length === 0) {
        await KnowledgeStore.seedSamples()
      }
      const dark = await KnowledgeStore.pref.get(KEY_DARK, false)
      AppStorage.setOrCreate('darkModeOn', dark === true)
      const streakVal = await KnowledgeStore.pref.get(KEY_STREAK, 0)
      KnowledgeStore.streak = typeof streakVal === 'number' ? streakVal : 0
      const streakDayVal = await KnowledgeStore.pref.get(KEY_STREAK_DAY, '')
      KnowledgeStore.streakDay = typeof streakDayVal === 'string' ? streakDayVal : ''
      const totalVal = await KnowledgeStore.pref.get(KEY_REVIEW_TOTAL, 0)
      KnowledgeStore.reviewTotal = typeof totalVal === 'number' ? totalVal : 0
      const histVal = await KnowledgeStore.pref.get(KEY_HISTORY, '[]')
      const histStr: string = typeof histVal === 'string' ? histVal : '[]'
      KnowledgeStore.history = KnowledgeStore.parseHistory(histStr)
    } catch {
      KnowledgeStore.notes = []
      KnowledgeStore.sparks = []
    }
  }

  static all(): KnowledgeItem[] {
    const copy: KnowledgeItem[] = []
    for (const n of KnowledgeStore.notes) {
      copy.push(n)
    }
    return copy
  }

  static sparksAll(): SparkItem[] {
    const copy: SparkItem[] = []
    for (const n of KnowledgeStore.sparks) {
      copy.push(n)
    }
    return copy
  }

  static find(id: string): KnowledgeItem | undefined {
    for (const n of KnowledgeStore.notes) {
      if (n.id === id) {
        return n
      }
    }
    return undefined
  }

  static sorted(): KnowledgeItem[] {
    const work: KnowledgeItem[] = KnowledgeStore.all()
    const result: KnowledgeItem[] = []
    while (work.length > 0) {
      let best: KnowledgeItem | undefined = undefined
      for (const n of work) {
        if (best === undefined) {
          best = n
        } else if (n.source !== best.source) {
          if (n.source === 'user') {
            best = n
          }
        } else if (n.updatedAt > best.updatedAt) {
          best = n
        }
      }
      if (best === undefined) {
        break
      }
      result.push(best)
      const next: KnowledgeItem[] = []
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

  static byCategory(cat: string): KnowledgeItem[] {
    const all = KnowledgeStore.sorted()
    if (cat === '全部' || cat.length === 0) {
      return all
    }
    const out: KnowledgeItem[] = []
    for (const n of all) {
      if (n.category === cat) {
        out.push(n)
      }
    }
    return out
  }

  static favorites(): KnowledgeItem[] {
    const out: KnowledgeItem[] = []
    for (const n of KnowledgeStore.sorted()) {
      if (n.favorited) {
        out.push(n)
      }
    }
    return out
  }

  static recentFavorites(limit: number): KnowledgeItem[] {
    return KnowledgeStore.take(KnowledgeStore.favorites(), limit)
  }

  static recentUser(limit: number): KnowledgeItem[] {
    const out: KnowledgeItem[] = []
    for (const n of KnowledgeStore.sorted()) {
      if (n.source === 'user') {
        out.push(n)
      }
    }
    return KnowledgeStore.take(out, limit)
  }

  static reviewQueue(): KnowledgeItem[] {
    const today = KnowledgeTime.todayIso()
    const out: KnowledgeItem[] = []
    for (const n of KnowledgeStore.sorted()) {
      if (n.inReview && !KnowledgeTime.sameDay(n.rememberedAt, today)) {
        out.push(n)
      }
    }
    return out
  }

  static search(query: string): KnowledgeItem[] {
    const q = query.trim()
    if (q.length === 0) {
      return []
    }
    const out: KnowledgeItem[] = []
    for (const n of KnowledgeStore.sorted()) {
      if (n.title.indexOf(q) >= 0 || n.body.indexOf(q) >= 0 ||
        n.tags.indexOf(q) >= 0 || n.category.indexOf(q) >= 0) {
        out.push(n)
      }
    }
    return out
  }

  static searchHistory(): string[] {
    const copy: string[] = []
    for (const h of KnowledgeStore.history) {
      copy.push(h)
    }
    return copy
  }

  static async pushHistory(query: string): Promise<void> {
    const q = query.trim()
    if (q.length === 0) {
      return
    }
    const next: string[] = [q]
    for (const h of KnowledgeStore.history) {
      if (h !== q && next.length < 8) {
        next.push(h)
      }
    }
    KnowledgeStore.history = next
    await KnowledgeStore.putString(KEY_HISTORY, JSON.stringify(next))
  }

  static async clearHistory(): Promise<void> {
    KnowledgeStore.history = []
    await KnowledgeStore.putString(KEY_HISTORY, '[]')
  }

  static async save(item: KnowledgeItem): Promise<void> {
    const next: KnowledgeItem[] = []
    let replaced = false
    for (const n of KnowledgeStore.notes) {
      if (n.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(n)
      }
    }
    if (!replaced) {
      next.unshift(item)
    }
    KnowledgeStore.notes = next
    await KnowledgeStore.flushNotes()
    KnowledgeStore.bump()
    if (AuthService.isLoggedIn() && item.source === 'user') {
      void KnowledgeBizService.syncKnowledge(item)
    }
  }

  static async remove(id: string): Promise<void> {
    const next: KnowledgeItem[] = []
    for (const n of KnowledgeStore.notes) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    KnowledgeStore.notes = next
    await KnowledgeStore.flushNotes()
    KnowledgeStore.bump()
  }

  static async saveSpark(item: SparkItem): Promise<void> {
    const next: SparkItem[] = []
    let replaced = false
    for (const n of KnowledgeStore.sparks) {
      if (n.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(n)
      }
    }
    if (!replaced) {
      next.unshift(item)
    }
    KnowledgeStore.sparks = next
    await KnowledgeStore.flushSparks()
    KnowledgeStore.bump()
    if (AuthService.isLoggedIn()) {
      void KnowledgeBizService.syncSpark(item)
    }
  }

  static async removeSpark(id: string): Promise<void> {
    const next: SparkItem[] = []
    for (const n of KnowledgeStore.sparks) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    KnowledgeStore.sparks = next
    await KnowledgeStore.flushSparks()
    KnowledgeStore.bump()
  }

  static async toggleFavorite(id: string): Promise<void> {
    const found = KnowledgeStore.find(id)
    if (found === undefined) {
      return
    }
    found.favorited = !found.favorited
    found.updatedAt = Date.now()
    await KnowledgeStore.save(found)
  }

  static async markRead(id: string): Promise<void> {
    const found = KnowledgeStore.find(id)
    if (found === undefined) {
      return
    }
    found.readAt = Date.now()
    found.updatedAt = Date.now()
    await KnowledgeStore.save(found)
  }

  static async addToReview(id: string): Promise<void> {
    const found = KnowledgeStore.find(id)
    if (found === undefined) {
      return
    }
    found.inReview = true
    found.updatedAt = Date.now()
    await KnowledgeStore.save(found)
  }

  static async remember(id: string): Promise<void> {
    const found = KnowledgeStore.find(id)
    if (found === undefined) {
      return
    }
    found.rememberedAt = Date.now()
    found.updatedAt = Date.now()
    await KnowledgeStore.save(found)
    await KnowledgeStore.noteReviewDone()
  }

  static streakDays(): number {
    return KnowledgeStore.streak
  }

  static reviewCount(): number {
    return KnowledgeStore.reviewTotal
  }

  static async setDark(on: boolean): Promise<void> {
    AppStorage.setOrCreate('darkModeOn', on)
    await KnowledgeStore.putBool(KEY_DARK, on)
    KnowledgeStore.bump()
  }

  static bump(): void {
    const n = AppStorage.get<number>('knowledgeRefresh') ?? 0
    AppStorage.setOrCreate('knowledgeRefresh', n + 1)
  }

  static newId(prefix: string): string {
    return `${prefix}_${Date.now()}_${KnowledgeStore.notes.length}`
  }

  static newSparkId(): string {
    return `spark_${Date.now()}_${KnowledgeStore.sparks.length}`
  }

  private static async noteReviewDone(): Promise<void> {
    const today = KnowledgeTime.todayIso()
    KnowledgeStore.reviewTotal += 1
    await KnowledgeStore.putNumber(KEY_REVIEW_TOTAL, KnowledgeStore.reviewTotal)
    if (KnowledgeStore.streakDay === today) {
      return
    }
    const yesterday = KnowledgeStore.yesterdayIso()
    if (KnowledgeStore.streakDay === yesterday) {
      KnowledgeStore.streak += 1
    } else {
      KnowledgeStore.streak = 1
    }
    KnowledgeStore.streakDay = today
    await KnowledgeStore.putNumber(KEY_STREAK, KnowledgeStore.streak)
    await KnowledgeStore.putString(KEY_STREAK_DAY, today)
  }

  private static yesterdayIso(): string {
    const d = new Date()
    d.setDate(d.getDate() - 1)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms = m < 10 ? `0${m}` : `${m}`
    const ds = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  private static take(list: KnowledgeItem[], limit: number): KnowledgeItem[] {
    const out: KnowledgeItem[] = []
    for (const n of list) {
      if (out.length >= limit) {
        break
      }
      out.push(n)
    }
    return out
  }

  private static async seedSamples(): Promise<void> {
    const now = Date.now()
    KnowledgeStore.notes = [
      KnowledgeStore.makeSample('lk_ft_01', '为什么雨后的空气闻起来更加清新？',
        '雨水会帮助空气中的部分颗粒物沉降，同时植物释放的气味物质更容易被察觉，因此雨后常会产生清新的气味感受。这是常见的生活体验，感受会因地点与天气而不同。',
        '生活', '气味,天气,观察', 'cover_life', now),
      KnowledgeStore.makeSample('lk_ft_02', '为什么玻璃上的水珠是圆的？',
        '水分子之间互相吸引，会尽量让表面积变小。在玻璃等表面上，这种表面张力常让水滴呈现接近圆形的轮廓。表面是否亲水、是否有油膜，也会改变水珠的形状。',
        '生活', '表面张力,日常', 'cover_life', now - 1000),
      KnowledgeStore.makeSample('lk_ft_03', '为什么天空通常是蓝色的？',
        '阳光进入大气后，较短波长的蓝光更容易被空气分子散射到各个方向，所以白天我们看到的天空往往偏蓝。日出日落时路径更长，蓝光被散射得更多，天空会偏向暖色。',
        '科普', '光,散射', 'cover_science', now - 2000),
      KnowledgeStore.makeSample('lk_ft_04', '为什么阅读会让人更容易产生长期记忆？',
        '阅读需要主动理解、联想和偶尔复述。这些加工会帮助信息留下更稳定的记忆痕迹，而不是一扫而过。效果因人而异，它不是保证成绩的方法，只是一种更认真的接触方式。',
        '阅读', '记忆,阅读', 'cover_reading', now - 3000),
      KnowledgeStore.makeSample('lk_ft_05', '为什么任务拆分后更容易完成？',
        '把大任务拆成可执行的小步骤，能降低启动阻力，也更容易看见进度，从而更愿意继续做下去。拆分本身不能代替努力，只是让下一步变得更清楚。',
        '工作', '方法,专注', 'cover_work', now - 4000),
      KnowledgeStore.makeSample('lk_ft_06', '为什么有些声音会让人感觉特别舒服？',
        '规律、柔和、可预期的声音更容易让人放松。这种感受因人而异，也受环境和心情影响，不必追求统一标准，更不是治疗效果。',
        '兴趣', '听觉,感受', 'cover_interest', now - 5000)
    ]
    await KnowledgeStore.flushNotes()
    await KnowledgeStore.putBool(KEY_SEEDED, true)
  }

  private static makeSample(id: string, title: string, body: string, category: string,
    tags: string, coverKey: string, ts: number): KnowledgeItem {
    const n = new KnowledgeItem()
    n.id = id
    n.title = title
    n.body = body
    n.category = category
    n.tags = tags
    n.coverKey = coverKey
    n.source = 'featured'
    n.inReview = true
    n.createdAt = ts
    n.updatedAt = ts
    return n
  }

  private static async flushNotes(): Promise<void> {
    const parts: string[] = []
    for (const n of KnowledgeStore.notes) {
      parts.push(n.toJsonString())
    }
    await KnowledgeStore.putString(KEY_NOTES, `[${parts.join(',')}]`)
  }

  private static async flushSparks(): Promise<void> {
    const parts: string[] = []
    for (const n of KnowledgeStore.sparks) {
      parts.push(n.toJsonString())
    }
    await KnowledgeStore.putString(KEY_SPARKS, `[${parts.join(',')}]`)
  }

  private static parseNotes(raw: string): KnowledgeItem[] {
    const out: KnowledgeItem[] = []
    if (raw.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as KnowledgeWire[]
      const file = new KnowledgeFile()
      file.items = parsed
      for (const w of file.items) {
        out.push(KnowledgeItem.fromWire(w))
      }
    } catch {
      return out
    }
    return out
  }

  private static parseSparks(raw: string): SparkItem[] {
    const out: SparkItem[] = []
    if (raw.length < 2) {
      return out
    }
    try {
      const parsed = JSON.parse(raw) as SparkWire[]
      const file = new SparkFile()
      file.items = parsed
      for (const w of file.items) {
        out.push(SparkItem.fromWire(w))
      }
    } catch {
      return out
    }
    return out
  }

  private static parseHistory(raw: string): string[] {
    const out: string[] = []
    try {
      const parsed = JSON.parse(raw) as string[]
      for (const s of parsed) {
        if (typeof s === 'string') {
          out.push(s)
        }
      }
    } catch {
      return out
    }
    return out
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (KnowledgeStore.pref === null) {
      return
    }
    try {
      await KnowledgeStore.pref.put(key, value)
      await KnowledgeStore.pref.flush()
    } catch {
      return
    }
  }

  private static async putBool(key: string, value: boolean): Promise<void> {
    if (KnowledgeStore.pref === null) {
      return
    }
    try {
      await KnowledgeStore.pref.put(key, value)
      await KnowledgeStore.pref.flush()
    } catch {
      return
    }
  }

  private static async putNumber(key: string, value: number): Promise<void> {
    if (KnowledgeStore.pref === null) {
      return
    }
    try {
      await KnowledgeStore.pref.put(key, value)
      await KnowledgeStore.pref.flush()
    } catch {
      return
    }
  }
}
