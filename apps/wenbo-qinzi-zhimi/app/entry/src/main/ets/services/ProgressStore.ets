import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { FavoriteCollection, TimelineEvent } from '../models/GrowthModels'
import { PlayRecord, PlanGoalState, ProgressState, PuzzleItem } from '../models/PuzzleModels'

const STORE = 'qinzi_zhimi_progress'
const LEGACY_KEY = 'state'
const GUEST_KEY = 'state:guest'
const DEFAULT_GOAL = 3

export class ProgressStore {
  private static pref: preferences.Preferences | null = null
  private static cache: ProgressState = new ProgressState()
  private static activeKey: string = GUEST_KEY

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      ProgressStore.pref = await preferences.getPreferences(context, STORE)
      await ProgressStore.migrateLegacyIfNeeded()
    } catch {
      ProgressStore.pref = null
    }
    ProgressStore.activeKey = ProgressStore.storageKey()
    await ProgressStore.loadActive()
    ProgressStore.sync()
  }

  static async switchAccount(): Promise<void> {
    const next = ProgressStore.storageKey()
    if (next === ProgressStore.activeKey) {
      ProgressStore.sync()
      ProgressStore.bumpAccount()
      return
    }
    ProgressStore.activeKey = next
    await ProgressStore.loadActive()
    ProgressStore.sync()
    ProgressStore.bumpAccount()
  }

  static snapshot(): ProgressState {
    return ProgressStore.cache
  }

  static dailyGoal(): number {
    const n = ProgressStore.cache.dailyGoalSet
    if (n === 3 || n === 5) {
      return n
    }
    return DEFAULT_GOAL
  }

  static todayKey(): string {
    return ProgressStore.keyOfDate(new Date())
  }

  static greeting(): string {
    const h = new Date().getHours()
    if (h < 11) {
      return '早上好，一起玩一个小谜题吧'
    }
    if (h < 17) {
      return '下午好，一起动动脑吧'
    }
    return '晚上好，来一题轻松的谜题吧'
  }

  static isFavorite(id: string): boolean {
    return ProgressStore.cache.favorites.indexOf(id) >= 0
  }

  static isMedalOn(id: string): boolean {
    return ProgressStore.cache.medalIds.indexOf(id) >= 0
  }

  static isCompleted(id: string): boolean {
    return ProgressStore.cache.completedIds.indexOf(id) >= 0
  }

  static isWrong(id: string): boolean {
    return ProgressStore.cache.wrongIds.indexOf(id) >= 0
  }

  static ensureDayBoundary(): void {
    const today = ProgressStore.todayKey()
    if (ProgressStore.cache.lastDate.length > 0 && ProgressStore.cache.lastDate !== today) {
      ProgressStore.cache.todayIds = []
    }
  }

  static displayStreak(): number {
    const today = ProgressStore.todayKey()
    const last = ProgressStore.cache.lastDate
    if (last.length === 0) {
      return 0
    }
    if (last === today) {
      return ProgressStore.cache.streak
    }
    if (ProgressStore.isYesterday(last, today)) {
      return ProgressStore.cache.streak
    }
    return 0
  }

  static todayProgress(): number {
    ProgressStore.ensureDayBoundary()
    return ProgressStore.cache.todayIds.length
  }

  static todayFamilyMatch(): number {
    const today = ProgressStore.todayKey()
    if (ProgressStore.cache.familyDate === today) {
      return ProgressStore.cache.familyMatch
    }
    return 0
  }

  static weekFamilyDone(): boolean {
    return ProgressStore.cache.weekFamilyDone && ProgressStore.cache.weekKey === ProgressStore.weekKey()
  }

  static currentWeekKey(): string {
    return ProgressStore.weekKey()
  }

  static keyOfDatePublic(d: Date): string {
    return ProgressStore.keyOfDate(d)
  }

  static dateInWeek(dateKey: string, weekStartKey: string): boolean {
    if (dateKey.length === 0 || weekStartKey.length === 0) {
      return false
    }
    const start = Date.parse(`${weekStartKey}T00:00:00`)
    const d = Date.parse(`${dateKey}T00:00:00`)
    if (Number.isNaN(start) || Number.isNaN(d)) {
      return false
    }
    const diff = d - start
    return diff >= 0 && diff < 7 * 24 * 60 * 60 * 1000
  }

  static timelineEvents(): TimelineEvent[] {
    if (ProgressStore.cache.timelineJson.length === 0) {
      return []
    }
    try {
      return JSON.parse(ProgressStore.cache.timelineJson) as TimelineEvent[]
    } catch {
      return []
    }
  }

  static collections(): FavoriteCollection[] {
    if (ProgressStore.cache.collectionsJson.length === 0) {
      return []
    }
    try {
      return JSON.parse(ProgressStore.cache.collectionsJson) as FavoriteCollection[]
    } catch {
      return []
    }
  }

  static planSnapshot(): PlanGoalState {
    const pg = ProgressStore.cache.planGoal
    if (pg.weekKey !== ProgressStore.weekKey()) {
      const fresh = new PlanGoalState()
      fresh.weekKey = ProgressStore.weekKey()
      fresh.targetCorrect = pg.targetCorrect > 0 ? pg.targetCorrect : 15
      fresh.targetFamily = pg.targetFamily > 0 ? pg.targetFamily : 1
      fresh.note = pg.note
      return fresh
    }
    return pg
  }

  static async savePlan(targetCorrect: number, targetFamily: number, note: string): Promise<void> {
    const pg = new PlanGoalState()
    pg.weekKey = ProgressStore.weekKey()
    pg.targetCorrect = targetCorrect > 0 ? targetCorrect : 15
    pg.targetFamily = targetFamily > 0 ? targetFamily : 1
    pg.note = note
    ProgressStore.cache.planGoal = pg
    await ProgressStore.flush()
    const t = AppStorage.get<number>('quizTick') ?? 0
    AppStorage.setOrCreate('quizTick', t + 1)
  }

  static async addCollection(title: string, tag: string): Promise<string> {
    const list = ProgressStore.collections()
    const c = new FavoriteCollection()
    c.id = `col_${Date.now()}`
    c.title = title
    c.tag = tag
    c.createdAt = ProgressStore.todayKey()
    const next: FavoriteCollection[] = []
    next.push(c)
    let n = 0
    for (const old of list) {
      if (n >= 19) {
        break
      }
      next.push(old)
      n++
    }
    ProgressStore.cache.collectionsJson = JSON.stringify(next)
    await ProgressStore.flush()
    return c.id
  }

  static async addToCollection(collectionId: string, puzzleId: string): Promise<void> {
    const next: FavoriteCollection[] = []
    for (const c of ProgressStore.collections()) {
      const copy = new FavoriteCollection()
      copy.id = c.id
      copy.title = c.title
      copy.tag = c.tag
      copy.createdAt = c.createdAt
      copy.puzzleIds = []
      for (const pid of c.puzzleIds) {
        copy.puzzleIds.push(pid)
      }
      if (copy.id === collectionId && copy.puzzleIds.indexOf(puzzleId) < 0) {
        copy.puzzleIds.push(puzzleId)
      }
      next.push(copy)
    }
    ProgressStore.cache.collectionsJson = JSON.stringify(next)
    await ProgressStore.flush()
  }

  static async removeCollection(id: string): Promise<void> {
    const next: FavoriteCollection[] = []
    for (const c of ProgressStore.collections()) {
      if (c.id !== id) {
        next.push(c)
      }
    }
    ProgressStore.cache.collectionsJson = JSON.stringify(next)
    await ProgressStore.flush()
  }

  static weeklyDots(): number[] {
    const out: number[] = []
    const today = new Date()
    for (let i = 6; i >= 0; i--) {
      const d = new Date(today.getTime() - i * 24 * 60 * 60 * 1000)
      const key = ProgressStore.keyOfDate(d)
      let count = 0
      for (const r of ProgressStore.cache.records) {
        if (r.at === key && r.correct) {
          count++
        }
      }
      out.push(count)
    }
    return out
  }

  static customPuzzles(): PuzzleItem[] {
    if (ProgressStore.cache.customJson.length === 0) {
      return []
    }
    try {
      const parsed = JSON.parse(ProgressStore.cache.customJson) as PuzzleItem[]
      return parsed
    } catch {
      return []
    }
  }

  static sync(): void {
    ProgressStore.ensureDayBoundary()
    ProgressStore.publish()
  }

  static async setDailyGoal(n: number): Promise<void> {
    ProgressStore.cache.dailyGoalSet = n === 5 ? 5 : 3
    await ProgressStore.flush()
  }

  static async setAgePref(band: string): Promise<void> {
    ProgressStore.cache.agePref = band
    await ProgressStore.flush()
  }

  static async toggleFavorite(id: string, title: string = ''): Promise<void> {
    const next: string[] = []
    let found = false
    for (const x of ProgressStore.cache.favorites) {
      if (x === id) {
        found = true
      } else {
        next.push(x)
      }
    }
    if (!found) {
      next.push(id)
      await ProgressStore.appendTimeline('favorite', id, title.length > 0 ? title : '收藏谜题', '加入收藏夹')
    } else {
      await ProgressStore.appendTimeline('unfavorite', id, title.length > 0 ? title : '取消收藏', '')
    }
    ProgressStore.cache.favorites = next
    await ProgressStore.flush()
  }

  static async saveCustom(item: PuzzleItem): Promise<void> {
    const list = ProgressStore.customPuzzles()
    const next: PuzzleItem[] = []
    next.push(item)
    let n = 0
    for (const old of list) {
      if (old.id === item.id) {
        continue
      }
      if (n >= 29) {
        break
      }
      next.push(old)
      n++
    }
    ProgressStore.cache.customJson = JSON.stringify(next)
    await ProgressStore.appendTimeline('custom_create', item.id, item.title, '家庭自定义谜题')
    await ProgressStore.flush()
  }

  static async removeCustom(id: string): Promise<void> {
    const next: PuzzleItem[] = []
    for (const p of ProgressStore.customPuzzles()) {
      if (p.id !== id) {
        next.push(p)
      }
    }
    ProgressStore.cache.customJson = JSON.stringify(next)
    await ProgressStore.flush()
  }

  static async recordAnswer(puzzleId: string, title: string, category: string, categoryLabel: string, correct: boolean): Promise<void> {
    const today = ProgressStore.todayKey()
    ProgressStore.ensureDayBoundary()
    if (correct) {
      if (ProgressStore.cache.lastDate !== today) {
        if (ProgressStore.cache.lastDate.length === 0) {
          ProgressStore.cache.streak = 1
        } else if (ProgressStore.isYesterday(ProgressStore.cache.lastDate, today)) {
          ProgressStore.cache.streak = ProgressStore.cache.streak + 1
        } else {
          ProgressStore.cache.streak = 1
        }
        ProgressStore.cache.lastDate = today
      }
      if (ProgressStore.cache.completedIds.indexOf(puzzleId) < 0) {
        ProgressStore.cache.completedIds.push(puzzleId)
      }
      if (ProgressStore.cache.todayIds.indexOf(puzzleId) < 0) {
        ProgressStore.cache.todayIds.push(puzzleId)
      }
      ProgressStore.dropWrong(puzzleId)
      if (category === 'visual') {
        ProgressStore.cache.visualCount = ProgressStore.cache.visualCount + 1
      }
      if (category === 'math') {
        ProgressStore.cache.mathCount = ProgressStore.cache.mathCount + 1
      }
    } else if (ProgressStore.cache.wrongIds.indexOf(puzzleId) < 0) {
      ProgressStore.cache.wrongIds.push(puzzleId)
    }
    const rec = new PlayRecord()
    rec.id = `${Date.now()}`
    rec.puzzleId = puzzleId
    rec.title = title
    rec.categoryLabel = categoryLabel
    rec.correct = correct
    rec.at = today
    const records: PlayRecord[] = []
    records.push(rec)
    let n = 0
    for (const old of ProgressStore.cache.records) {
      if (n >= 39) {
        break
      }
      records.push(old)
      n++
    }
    ProgressStore.cache.records = records
    ProgressStore.refreshMedals()
    const evType = correct ? 'answer_correct' : 'answer_wrong'
    const sub = correct ? '答对了' : '加入错题本'
    await ProgressStore.appendTimeline(evType, puzzleId, title, sub)
    await ProgressStore.flush()
  }

  static async recordFamily(matchPercent: number): Promise<void> {
    ProgressStore.cache.familyMatch = matchPercent
    ProgressStore.cache.familyDate = ProgressStore.todayKey()
    ProgressStore.cache.familyRounds = ProgressStore.cache.familyRounds + 1
    ProgressStore.cache.weekKey = ProgressStore.weekKey()
    ProgressStore.cache.weekFamilyDone = true
    ProgressStore.refreshMedals()
    await ProgressStore.appendTimeline('family_play', '', '亲子同屏', `默契 ${matchPercent}%`)
    await ProgressStore.flush()
  }

  private static storageKey(): string {
    const u = AppStorage.get<string>('currentUsername') ?? ''
    if (u.length === 0) {
      return GUEST_KEY
    }
    return `state:u:${u}`
  }

  private static bumpAccount(): void {
    const n = AppStorage.get<number>('accountEpoch') ?? 0
    AppStorage.setOrCreate('accountEpoch', n + 1)
    const t = AppStorage.get<number>('quizTick') ?? 0
    AppStorage.setOrCreate('quizTick', t + 1)
  }

  private static async migrateLegacyIfNeeded(): Promise<void> {
    if (ProgressStore.pref === null) {
      return
    }
    try {
      const dest = ProgressStore.storageKey()
      const destRaw = await ProgressStore.pref.get(dest, '')
      const destStr: string = typeof destRaw === 'string' ? destRaw : ''
      if (destStr.length > 0) {
        return
      }
      const oldRaw = await ProgressStore.pref.get(LEGACY_KEY, '')
      const old: string = typeof oldRaw === 'string' ? oldRaw : ''
      if (old.length === 0) {
        return
      }
      await ProgressStore.pref.put(dest, old)
      await ProgressStore.pref.flush()
    } catch {
      return
    }
  }

  private static async loadActive(): Promise<void> {
    if (ProgressStore.pref === null) {
      ProgressStore.cache = new ProgressState()
      return
    }
    try {
      const rawValue = await ProgressStore.pref.get(ProgressStore.activeKey, '')
      const raw: string = typeof rawValue === 'string' ? rawValue : ''
      ProgressStore.cache = ProgressStore.parse(raw)
    } catch {
      ProgressStore.cache = new ProgressState()
    }
  }

  private static async appendTimeline(type: string, puzzleId: string, title: string, subtitle: string): Promise<void> {
    const ev = new TimelineEvent()
    ev.id = `tl_${Date.now()}`
    ev.type = type
    ev.puzzleId = puzzleId
    ev.title = title
    ev.subtitle = subtitle
    ev.at = ProgressStore.todayKey()
    const list: TimelineEvent[] = []
    list.push(ev)
    let n = 0
    for (const old of ProgressStore.timelineEvents()) {
      if (n >= 59) {
        break
      }
      list.push(old)
      n++
    }
    ProgressStore.cache.timelineJson = JSON.stringify(list)
  }

  private static dropWrong(id: string): void {
    const next: string[] = []
    for (const x of ProgressStore.cache.wrongIds) {
      if (x !== id) {
        next.push(x)
      }
    }
    ProgressStore.cache.wrongIds = next
  }

  private static keyOfDate(d: Date): string {
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${mm}-${dd}`
  }

  private static weekKey(): string {
    const d = new Date()
    const wd = d.getDay() === 0 ? 7 : d.getDay()
    const monday = new Date(d.getTime() - (wd - 1) * 24 * 60 * 60 * 1000)
    return ProgressStore.keyOfDate(monday)
  }

  private static refreshMedals(): void {
    const ids: string[] = []
    if (ProgressStore.cache.completedIds.length >= 1) {
      ids.push('pcq_medal_first')
    }
    if (ProgressStore.cache.streak >= 3) {
      ids.push('pcq_medal_streak3')
    }
    if (ProgressStore.cache.completedIds.length >= 30) {
      ids.push('pcq_medal_puzzler')
    }
    if (ProgressStore.cache.familyRounds >= 1) {
      ids.push('pcq_medal_family')
    }
    if (ProgressStore.cache.visualCount >= 5) {
      ids.push('pcq_medal_observe')
    }
    if (ProgressStore.cache.mathCount >= 8) {
      ids.push('pcq_medal_math')
    }
    ProgressStore.cache.medalIds = ids
  }

  private static isYesterday(last: string, today: string): boolean {
    if (last.length === 0) {
      return false
    }
    const t = Date.parse(`${today}T00:00:00`)
    const l = Date.parse(`${last}T00:00:00`)
    if (Number.isNaN(t) || Number.isNaN(l)) {
      return false
    }
    return t - l === 24 * 60 * 60 * 1000
  }

  private static parse(raw: string): ProgressState {
    const state = new ProgressState()
    if (raw.length === 0) {
      return state
    }
    try {
      const obj = JSON.parse(raw) as ProgressState
      if (obj.completedIds !== undefined) {
        state.completedIds = obj.completedIds
      }
      if (obj.todayIds !== undefined) {
        state.todayIds = obj.todayIds
      }
      if (obj.lastDate !== undefined) {
        state.lastDate = obj.lastDate
      }
      state.streak = obj.streak ?? 0
      if (obj.favorites !== undefined) {
        state.favorites = obj.favorites
      }
      if (obj.records !== undefined) {
        state.records = obj.records
      }
      state.familyMatch = obj.familyMatch ?? 0
      if (obj.familyDate !== undefined) {
        state.familyDate = obj.familyDate
      }
      state.familyRounds = obj.familyRounds ?? 0
      state.visualCount = obj.visualCount ?? 0
      state.mathCount = obj.mathCount ?? 0
      if (obj.medalIds !== undefined) {
        state.medalIds = obj.medalIds
      }
      if (obj.wrongIds !== undefined) {
        state.wrongIds = obj.wrongIds
      }
      if (obj.customJson !== undefined && obj.customJson.length > 0) {
        state.customJson = obj.customJson
      }
      if (obj.agePref !== undefined && obj.agePref.length > 0) {
        state.agePref = obj.agePref
      }
      state.dailyGoalSet = obj.dailyGoalSet === 5 ? 5 : 3
      if (obj.weekKey !== undefined) {
        state.weekKey = obj.weekKey
      }
      state.weekFamilyDone = obj.weekFamilyDone === true
      if (obj.planGoal !== undefined) {
        state.planGoal = obj.planGoal
      }
      if (obj.collectionsJson !== undefined && obj.collectionsJson.length > 0) {
        state.collectionsJson = obj.collectionsJson
      }
      if (obj.timelineJson !== undefined && obj.timelineJson.length > 0) {
        state.timelineJson = obj.timelineJson
      }
    } catch {
      return new ProgressState()
    }
    return state
  }

  private static async flush(): Promise<void> {
    ProgressStore.publish()
    if (ProgressStore.pref === null) {
      return
    }
    try {
      await ProgressStore.pref.put(ProgressStore.activeKey, JSON.stringify(ProgressStore.cache))
      await ProgressStore.pref.flush()
    } catch {
      return
    }
  }

  private static publish(): void {
    AppStorage.setOrCreate('doneCount', ProgressStore.cache.completedIds.length)
    AppStorage.setOrCreate('streakDays', ProgressStore.displayStreak())
    AppStorage.setOrCreate('todayCount', ProgressStore.todayProgress())
    AppStorage.setOrCreate('familyMatch', ProgressStore.todayFamilyMatch())
    AppStorage.setOrCreate('wrongCount', ProgressStore.cache.wrongIds.length)
    AppStorage.setOrCreate('favoriteCount', ProgressStore.cache.favorites.length)
    AppStorage.setOrCreate('progressOwner', ProgressStore.activeKey)
  }
}
