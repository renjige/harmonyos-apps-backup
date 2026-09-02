import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  AtlasNote, ChallengeProgress, DisplayPrefs, DomainStat, ExplorationState,
  FavoriteFolder, TaskCompletion, TimelineEvent, UserDiscovery, UserTopic
} from '../models/ExplorationModels'
import { AtlasCatalog, AtlasItem } from '../data/AtlasCatalog'
import { ExploreBadgeBank } from '../data/ExploreBadgeBank'
import { TaskBank, ExploreTaskTemplate } from '../data/TaskBank'
import { ChallengeTrack } from '../data/ChallengeTrack'

const STORE = 'element_explorer_v2'
const KEY = 'state'

export class ExplorationStore {
  private static pref: preferences.Preferences | null = null
  private static cache: ExplorationState = new ExplorationState()

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ExplorationStore.pref = await preferences.getPreferences(context, STORE)
      const rawValue = await ExplorationStore.pref.get(KEY, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      ExplorationStore.cache = ExplorationStore.parse(raw)
    } catch {
      ExplorationStore.cache = new ExplorationState()
    }
    if (ExplorationStore.cache.discoveries.length === 0 && !ExplorationStore.cache.samplesDismissed) {
      ExplorationStore.seedSamples()
    }
    await ExplorationStore.seedDefaultFoldersIfNeeded()
    await ExplorationStore.touchOpenDay()
    ExplorationStore.refreshBadges()
    ExplorationStore.publish()
  }

  static snapshot(): ExplorationState {
    return ExplorationStore.cache
  }

  static todayKey(): string {
    const d = new Date()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  static daySeed(): number {
    const d = new Date()
    return d.getFullYear() * 1000 + d.getMonth() * 32 + d.getDate()
  }

  static dailyAtlas(): AtlasItem {
    const all = AtlasCatalog.all()
    const idx = ExplorationStore.daySeed() % all.length
    return all[idx]
  }

  static dailyTasks(): ExploreTaskTemplate[] {
    return TaskBank.pickDaily(3, ExplorationStore.daySeed())
  }

  static isTaskDone(taskId: string): boolean {
    const today = ExplorationStore.todayKey()
    for (const t of ExplorationStore.cache.taskCompletions) {
      if (t.taskId === taskId && t.dateKey === today && t.done) {
        return true
      }
    }
    return false
  }

  static todayTaskDoneCount(): number {
    const tasks = ExplorationStore.dailyTasks()
    let n = 0
    for (const t of tasks) {
      if (ExplorationStore.isTaskDone(t.id)) {
        n++
      }
    }
    return n
  }

  static async completeTask(taskId: string): Promise<void> {
    const today = ExplorationStore.todayKey()
    let found = false
    for (const t of ExplorationStore.cache.taskCompletions) {
      if (t.taskId === taskId && t.dateKey === today) {
        t.done = true
        found = true
      }
    }
    if (!found) {
      const tc = new TaskCompletion()
      tc.taskId = taskId
      tc.dateKey = today
      tc.done = true
      ExplorationStore.cache.taskCompletions.push(tc)
    }
    ExplorationStore.pushTimeline('task', '完成任务', TaskBank.find(taskId)?.title ?? taskId)
    ExplorationStore.refreshBadges()
    await ExplorationStore.flush()
  }

  static discoveryCount(): number {
    return ExplorationStore.cache.discoveries.filter((d) => !d.isSample).length
  }

  static myAtlasCount(): number {
    let n = ExplorationStore.cache.discoveries.filter((d) => !d.isSample).length
    for (const note of ExplorationStore.cache.atlasNotes) {
      if (note.status === 'known' || note.status === 'favorite') {
        n++
      }
    }
    return n
  }

  static favoriteCount(): number {
    return ExplorationStore.cache.favoriteAtlasIds.length + ExplorationStore.cache.favoriteDiscoveryIds.length
  }

  static computeLevel(): number {
    const xp = ExplorationStore.myAtlasCount() * 8 + ExplorationStore.todayTaskDoneCount() * 2 +
      ExplorationStore.cache.streakDays * 3
    if (xp < 15) return 1
    if (xp < 40) return 2
    if (xp < 80) return 3
    if (xp < 130) return 4
    if (xp < 200) return 5
    if (xp < 280) return 6
    return 7
  }

  static levelTitle(): string {
    const lv = ExplorationStore.computeLevel()
    if (lv <= 1) return '探索新手'
    if (lv <= 3) return '发现达人'
    if (lv <= 5) return '知识收藏家'
    return '探索达人'
  }

  static domainStats(): DomainStat[] {
    const cats: string[][] = [
      ['nature', '自然'], ['life', '生活'], ['science', '科学'], ['culture', '人文'], ['fun', '趣味']
    ]
    const list: DomainStat[] = []
    for (const c of cats) {
      const ds = new DomainStat()
      ds.category = c[0]
      ds.label = c[1]
      ds.total = AtlasCatalog.byCategory(c[0]).length
      ds.count = ExplorationStore.countInCategory(c[0])
      list.push(ds)
    }
    return list
  }

  private static countInCategory(cat: string): number {
    let n = 0
    for (const d of ExplorationStore.cache.discoveries) {
      if (!d.isSample && d.category === cat) n++
    }
    for (const note of ExplorationStore.cache.atlasNotes) {
      if (note.status === 'known' || note.status === 'favorite') {
        const item = AtlasCatalog.findById(note.atlasId)
        if (item !== undefined && item.category === cat) n++
      }
    }
    return n
  }

  static findDiscovery(id: string): UserDiscovery | undefined {
    for (const d of ExplorationStore.cache.discoveries) {
      if (d.id === id) return d
    }
    return undefined
  }

  static recentDiscoveries(limit: number): UserDiscovery[] {
    const list: UserDiscovery[] = []
    const sorted = ExplorationStore.cache.discoveries.slice()
    sorted.sort((a, b) => b.updatedAt - a.updatedAt)
    for (const d of sorted) {
      if (list.length >= limit) break
      list.push(d)
    }
    return list
  }

  static async saveDiscovery(input: UserDiscovery): Promise<void> {
    const now = Date.now()
    let existing: UserDiscovery | undefined = undefined
    for (const d of ExplorationStore.cache.discoveries) {
      if (d.id === input.id) {
        existing = d
        break
      }
    }
    if (existing !== undefined) {
      existing.title = input.title
      existing.category = input.category
      existing.tags = input.tags
      existing.status = input.status
      existing.description = input.description
      existing.whyInteresting = input.whyInteresting
      existing.feeling = input.feeling
      existing.learned = input.learned
      existing.placeText = input.placeText
      existing.dateKey = input.dateKey
      existing.atlasRefId = input.atlasRefId
      existing.updatedAt = now
    } else {
      const d = new UserDiscovery()
      d.id = input.id.length > 0 ? input.id : `${now}`
      d.title = input.title
      d.category = input.category
      d.tags = input.tags
      d.status = input.status
      d.description = input.description
      d.whyInteresting = input.whyInteresting
      d.feeling = input.feeling
      d.learned = input.learned
      d.placeText = input.placeText
      d.dateKey = input.dateKey.length > 0 ? input.dateKey : ExplorationStore.todayKey()
      d.atlasRefId = input.atlasRefId
      d.isSample = false
      d.createdAt = now
      d.updatedAt = now
      ExplorationStore.cache.discoveries.unshift(d)
      ExplorationStore.pushTimeline('discovery', '新建发现', d.title)
      ExplorationStore.mergeCustomTags(d.tags)
    }
    ExplorationStore.refreshBadges()
    await ExplorationStore.flush()
  }

  static async deleteDiscovery(id: string): Promise<void> {
    const next: UserDiscovery[] = []
    for (const d of ExplorationStore.cache.discoveries) {
      if (d.id !== id) next.push(d)
    }
    ExplorationStore.cache.discoveries = next
    const fav: string[] = []
    for (const f of ExplorationStore.cache.favoriteDiscoveryIds) {
      if (f !== id) fav.push(f)
    }
    ExplorationStore.cache.favoriteDiscoveryIds = fav
    ExplorationStore.refreshBadges()
    await ExplorationStore.flush()
  }

  static async dismissSamples(): Promise<void> {
    const next: UserDiscovery[] = []
    for (const d of ExplorationStore.cache.discoveries) {
      if (!d.isSample) next.push(d)
    }
    ExplorationStore.cache.discoveries = next
    ExplorationStore.cache.samplesDismissed = true
    await ExplorationStore.flush()
  }

  static getAtlasNote(atlasId: string): AtlasNote {
    for (const n of ExplorationStore.cache.atlasNotes) {
      if (n.atlasId === atlasId) return n
    }
    const note = new AtlasNote()
    note.atlasId = atlasId
    note.status = 'unknown'
    return note
  }

  static async saveAtlasNote(atlasId: string, status: string, myNote: string): Promise<void> {
    let found = false
    for (const n of ExplorationStore.cache.atlasNotes) {
      if (n.atlasId === atlasId) {
        n.status = status
        n.myNote = myNote
        n.updatedAt = Date.now()
        found = true
      }
    }
    if (!found) {
      const note = new AtlasNote()
      note.atlasId = atlasId
      note.status = status
      note.myNote = myNote
      note.updatedAt = Date.now()
      ExplorationStore.cache.atlasNotes.push(note)
    }
    const item = AtlasCatalog.findById(atlasId)
    if (item !== undefined && (status === 'known' || status === 'exploring')) {
      ExplorationStore.pushTimeline('atlas', '探索图鉴', item.name)
    }
    ExplorationStore.refreshBadges()
    await ExplorationStore.flush()
  }

  static isFavoriteAtlas(id: string): boolean {
    return ExplorationStore.cache.favoriteAtlasIds.indexOf(id) >= 0
  }

  static async toggleFavoriteAtlas(id: string): Promise<boolean> {
    const next: string[] = []
    let found = false
    for (const x of ExplorationStore.cache.favoriteAtlasIds) {
      if (x === id) found = true
      else next.push(x)
    }
    if (!found) next.push(id)
    ExplorationStore.cache.favoriteAtlasIds = next
    ExplorationStore.refreshBadges()
    await ExplorationStore.flush()
    return !found
  }

  static async toggleFavoriteDiscovery(id: string): Promise<boolean> {
    const next: string[] = []
    let found = false
    for (const x of ExplorationStore.cache.favoriteDiscoveryIds) {
      if (x === id) found = true
      else next.push(x)
    }
    if (!found) next.push(id)
    ExplorationStore.cache.favoriteDiscoveryIds = next
    ExplorationStore.refreshBadges()
    await ExplorationStore.flush()
    return !found
  }

  static async completeChallengeDay(day: number): Promise<void> {
    if (ExplorationStore.cache.challenge.completedDays.indexOf(day) < 0) {
      ExplorationStore.cache.challenge.completedDays.push(day)
      ExplorationStore.cache.challenge.currentDay = day + 1
    }
    const step = ChallengeTrack.findDay(day)
    if (step !== undefined) {
      ExplorationStore.pushTimeline('challenge', '挑战进度', step.title)
    }
    ExplorationStore.refreshBadges()
    await ExplorationStore.flush()
  }

  static wisdomTips(): string[] {
    const tips: string[] = []
    const domains = ExplorationStore.domainStats()
    let maxCat = 'nature'
    let maxCount = 0
    for (const d of domains) {
      if (d.count > maxCount) {
        maxCount = d.count
        maxCat = d.category
      }
    }
    let minCat = 'life'
    let minCount = 9999
    for (const d of domains) {
      if (d.count < minCount && d.total > 0) {
        minCount = d.count
        minCat = d.category
      }
    }
    if (maxCount > 0) {
      const label = ExplorationStore.categoryLabel(maxCat)
      const weak = ExplorationStore.categoryLabel(minCat)
      tips.push(`你最近在「${label}」领域探索较多，可以试试「${weak}」方向。`)
    }
    const pending = ExplorationStore.dailyTasks().filter((t) => !ExplorationStore.isTaskDone(t.id))
    if (pending.length > 0) {
      tips.push(`今日还有 ${pending.length} 项探索任务待完成。`)
    }
    if (ExplorationStore.favoriteCount() > 0) {
      tips.push('去收藏夹回顾之前标记的内容，会有新发现。')
    }
    if (tips.length === 0) {
      tips.push('从今天的一个小发现开始，建立你的探索图鉴。')
    }
    return tips
  }

  static categoryLabel(cat: string): string {
    if (cat === 'nature') return '自然'
    if (cat === 'life') return '生活'
    if (cat === 'science') return '科学'
    if (cat === 'culture') return '人文'
    return '趣味'
  }

  static lookbackHint(): string {
    for (const ev of ExplorationStore.cache.timeline) {
      const days = ExplorationStore.daysBetween(ev.dateKey, ExplorationStore.todayKey())
      if (days >= 7 && days <= 10) {
        return `${days} 天前，你${ev.detail.length > 0 ? ev.detail : '完成了一次探索'}。`
      }
    }
    return ''
  }

  private static daysBetween(from: string, to: string): number {
    const a = Date.parse(`${from}T00:00:00`)
    const b = Date.parse(`${to}T00:00:00`)
    if (Number.isNaN(a) || Number.isNaN(b)) return 0
    return Math.round((b - a) / (86400000))
  }

  static themeMode(): string {
    const m = ExplorationStore.cache.displayPrefs.themeMode
    return m.length > 0 ? m : 'system'
  }

  static async saveThemeMode(mode: string): Promise<void> {
    ExplorationStore.cache.displayPrefs.themeMode = mode
    await ExplorationStore.flush()
  }

  static privacyAccepted(): boolean {
    return ExplorationStore.cache.displayPrefs.privacyAccepted
  }

  static async savePrivacyAccepted(v: boolean): Promise<void> {
    ExplorationStore.cache.displayPrefs.privacyAccepted = v
    AppStorage.setOrCreate('privacyAccepted', v)
    await ExplorationStore.flush()
  }

  static async clearCache(): Promise<void> {
    AppStorage.setOrCreate('localCacheEpoch', Date.now())
  }

  static searchHistory(): string[] {
    return ExplorationStore.cache.searchHistory
  }

  static async pushSearchHistory(q: string): Promise<void> {
    const key = q.trim()
    if (key.length === 0) return
    const next: string[] = [key]
    for (const h of ExplorationStore.cache.searchHistory) {
      if (h !== key && next.length < 12) next.push(h)
    }
    ExplorationStore.cache.searchHistory = next
    await ExplorationStore.flush()
  }

  static allTopics(): UserTopic[] {
    return ExplorationStore.cache.userTopics
  }

  static findTopic(id: string): UserTopic | undefined {
    for (const t of ExplorationStore.cache.userTopics) {
      if (t.id === id) return t
    }
    return undefined
  }

  static async saveTopic(input: UserTopic): Promise<void> {
    const now = Date.now()
    let found = false
    for (const t of ExplorationStore.cache.userTopics) {
      if (t.id === input.id && input.id.length > 0) {
        t.title = input.title
        t.summary = input.summary
        t.discoveryIds = input.discoveryIds
        t.atlasIds = input.atlasIds
        found = true
      }
    }
    if (!found) {
      const t = new UserTopic()
      t.id = input.id.length > 0 ? input.id : `topic_${now}`
      t.title = input.title
      t.summary = input.summary
      t.discoveryIds = input.discoveryIds
      t.atlasIds = input.atlasIds
      t.createdAt = now
      ExplorationStore.cache.userTopics.push(t)
      ExplorationStore.pushTimeline('topic', '创建专题', t.title)
    }
    ExplorationStore.refreshBadges()
    await ExplorationStore.flush()
  }

  static async deleteTopic(id: string): Promise<void> {
    const next: UserTopic[] = []
    for (const t of ExplorationStore.cache.userTopics) {
      if (t.id !== id) next.push(t)
    }
    ExplorationStore.cache.userTopics = next
    await ExplorationStore.flush()
  }

  static touchTopicsPanel(): void {
    void ExplorationStore.completeTask('task_topic_touch')
  }

  static allFolders(): FavoriteFolder[] {
    return ExplorationStore.cache.favoriteFolders
  }

  static async saveFolder(name: string): Promise<void> {
    const f = new FavoriteFolder()
    f.id = `folder_${Date.now()}`
    f.name = name.trim()
    f.createdAt = Date.now()
    ExplorationStore.cache.favoriteFolders.push(f)
    await ExplorationStore.flush()
  }

  static async seedDefaultFoldersIfNeeded(): Promise<void> {
    if (ExplorationStore.cache.favoriteFolders.length > 0) {
      return
    }
    const names: string[] = ['我喜欢的植物', '有趣的科学', '生活发现', '旅行探索']
    let i = 0
    for (const name of names) {
      const f = new FavoriteFolder()
      f.id = `folder_seed_${i}`
      f.name = name
      f.createdAt = Date.now()
      ExplorationStore.cache.favoriteFolders.push(f)
      i++
    }
    await ExplorationStore.flush()
  }

  static favoriteAtlasItems(): AtlasItem[] {
    const list: AtlasItem[] = []
    for (const id of ExplorationStore.cache.favoriteAtlasIds) {
      const item = AtlasCatalog.findById(id)
      if (item !== undefined) list.push(item)
    }
    return list
  }

  static favoriteDiscoveries(): UserDiscovery[] {
    const list: UserDiscovery[] = []
    for (const id of ExplorationStore.cache.favoriteDiscoveryIds) {
      const d = ExplorationStore.findDiscovery(id)
      if (d !== undefined) list.push(d)
    }
    return list
  }

  static myKnownAtlasItems(): AtlasItem[] {
    const list: AtlasItem[] = []
    for (const note of ExplorationStore.cache.atlasNotes) {
      if (note.status === 'known' || note.status === 'favorite') {
        const item = AtlasCatalog.findById(note.atlasId)
        if (item !== undefined) list.push(item)
      }
    }
    return list
  }

  static eventsOnDate(dateKey: string): TimelineEvent[] {
    const list: TimelineEvent[] = []
    for (const ev of ExplorationStore.cache.timeline) {
      if (ev.dateKey === dateKey) list.push(ev)
    }
    return list
  }

  static discoveriesOnDate(dateKey: string): UserDiscovery[] {
    const list: UserDiscovery[] = []
    for (const d of ExplorationStore.cache.discoveries) {
      if (d.dateKey === dateKey) list.push(d)
    }
    return list
  }

  static mergeCustomTags(tags: string[]): void {
    for (const t of tags) {
      const key = t.trim()
      if (key.length === 0) continue
      if (ExplorationStore.cache.customTags.indexOf(key) >= 0) continue
      if (ExplorationStore.cache.customTags.length >= 20) break
      ExplorationStore.cache.customTags.push(key)
    }
  }

  private static seedSamples(): void {
    const samples: string[][] = [
      ['sample_1', '路边的银杏叶', 'nature', '叶片像小扇子，秋天会变黄。', '自然'],
      ['sample_2', '电梯里的镜面', 'life', '反射让空间看起来更大。', '生活'],
      ['sample_3', '雨后的彩虹', 'science', '阳光穿过水滴发生折射。', '科学']
    ]
    const now = Date.now()
    for (const s of samples) {
      const d = new UserDiscovery()
      d.id = s[0]
      d.title = s[1]
      d.category = s[2]
      d.description = s[3]
      d.whyInteresting = '示例：第一次观察身边事物'
      d.status = 'exploring'
      d.dateKey = ExplorationStore.todayKey()
      d.isSample = true
      d.createdAt = now
      d.updatedAt = now
      d.tags = ['示例']
      ExplorationStore.cache.discoveries.push(d)
    }
  }

  private static pushTimeline(kind: string, title: string, detail: string): void {
    const ev = new TimelineEvent()
    ev.id = `${Date.now()}`
    ev.kind = kind
    ev.title = title
    ev.detail = detail
    ev.dateKey = ExplorationStore.todayKey()
    ev.at = Date.now()
    const list: TimelineEvent[] = [ev]
    let n = 0
    for (const old of ExplorationStore.cache.timeline) {
      if (n >= 99) break
      list.push(old)
      n++
    }
    ExplorationStore.cache.timeline = list
  }

  private static refreshBadges(): void {
    ExplorationStore.cache.badgeIds = ExploreBadgeBank.evaluate(ExplorationStore.cache)
  }

  private static async touchOpenDay(): Promise<void> {
    const today = ExplorationStore.todayKey()
    if (ExplorationStore.cache.lastOpenDate === today) return
    if (ExplorationStore.isYesterday(ExplorationStore.cache.lastOpenDate, today)) {
      ExplorationStore.cache.streakDays++
    } else if (ExplorationStore.cache.lastOpenDate.length === 0) {
      ExplorationStore.cache.streakDays = 1
    } else {
      ExplorationStore.cache.streakDays = 1
    }
    ExplorationStore.cache.lastOpenDate = today
  }

  private static isYesterday(last: string, today: string): boolean {
    if (last.length === 0) return false
    const t = Date.parse(`${today}T00:00:00`)
    const l = Date.parse(`${last}T00:00:00`)
    if (Number.isNaN(t) || Number.isNaN(l)) return false
    return t - l === 86400000
  }

  private static parse(raw: string): ExplorationState {
    const state = new ExplorationState()
    if (raw.length === 0) return state
    try {
      const obj = JSON.parse(raw) as ExplorationState
      if (obj.discoveries !== undefined) state.discoveries = obj.discoveries
      if (obj.atlasNotes !== undefined) state.atlasNotes = obj.atlasNotes
      if (obj.favoriteAtlasIds !== undefined) state.favoriteAtlasIds = obj.favoriteAtlasIds
      if (obj.favoriteDiscoveryIds !== undefined) state.favoriteDiscoveryIds = obj.favoriteDiscoveryIds
      if (obj.badgeIds !== undefined) state.badgeIds = obj.badgeIds
      if (obj.timeline !== undefined) state.timeline = obj.timeline
      if (obj.taskCompletions !== undefined) state.taskCompletions = obj.taskCompletions
      if (obj.customTags !== undefined) state.customTags = obj.customTags
      if (obj.favoriteDiscoveryIds !== undefined) state.favoriteDiscoveryIds = obj.favoriteDiscoveryIds
      if (obj.favoriteFolders !== undefined) state.favoriteFolders = obj.favoriteFolders
      if (obj.userTopics !== undefined) state.userTopics = obj.userTopics
      if (obj.searchHistory !== undefined) state.searchHistory = obj.searchHistory
      if (obj.challenge !== undefined) {
        const ch = new ChallengeProgress()
        ch.trackId = obj.challenge.trackId ?? 'week7'
        ch.currentDay = obj.challenge.currentDay ?? 0
        ch.completedDays = obj.challenge.completedDays ?? []
        ch.startedAt = obj.challenge.startedAt ?? ''
        state.challenge = ch
      }
      state.streakDays = obj.streakDays ?? 0
      if (obj.lastOpenDate !== undefined) state.lastOpenDate = obj.lastOpenDate
      state.samplesDismissed = obj.samplesDismissed === true
      if (obj.displayPrefs !== undefined) {
        const dp = new DisplayPrefs()
        dp.themeMode = obj.displayPrefs.themeMode ?? 'system'
        dp.privacyAccepted = obj.displayPrefs.privacyAccepted === true
        state.displayPrefs = dp
      }
    } catch {
      return new ExplorationState()
    }
    return state
  }

  private static async flush(): Promise<void> {
    ExplorationStore.publish()
    if (ExplorationStore.pref === null) return
    try {
      await ExplorationStore.pref.put(KEY, JSON.stringify(ExplorationStore.cache))
      await ExplorationStore.pref.flush()
    } catch {
      return
    }
  }

  private static publish(): void {
    AppStorage.setOrCreate('exploreCount', ExplorationStore.myAtlasCount())
    AppStorage.setOrCreate('discoveryCount', ExplorationStore.discoveryCount())
    AppStorage.setOrCreate('favoriteCount', ExplorationStore.favoriteCount())
    AppStorage.setOrCreate('explorerLevel', ExplorationStore.computeLevel())
    AppStorage.setOrCreate('explorerLevelTitle', ExplorationStore.levelTitle())
    AppStorage.setOrCreate('streakDays', ExplorationStore.cache.streakDays)
    AppStorage.setOrCreate('badgeCount', ExplorationStore.cache.badgeIds.length)
    AppStorage.setOrCreate('taskDoneToday', ExplorationStore.todayTaskDoneCount())
    AppStorage.setOrCreate('taskTotalToday', ExplorationStore.dailyTasks().length)
    AppStorage.setOrCreate('topicCount', ExplorationStore.cache.userTopics.length)
    AppStorage.setOrCreate('privacyAccepted', ExplorationStore.cache.displayPrefs.privacyAccepted)
    const rev = (AppStorage.get<number>('progressRev') ?? 0) + 1
    AppStorage.setOrCreate('progressRev', rev)
  }
}
