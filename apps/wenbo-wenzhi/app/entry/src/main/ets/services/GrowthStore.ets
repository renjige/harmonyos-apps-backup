import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  AchievementItem,
  ActivityEvent,
  CheckinRecord,
  DayCountItem,
  GrowthStats,
  StudyTask,
  UserNote
} from '../models/GrowthModels'
import { LearnStore } from './LearnStore'
import { VaultStore } from './VaultStore'

const STORE_NAME = 'wenzhi_growth'
const KEY_ACTIVITY = 'activity_json'
const KEY_TASKS = 'tasks_json'
const KEY_NOTES = 'notes_json'
const KEY_CHECKIN = 'checkin_json'
const KEY_ACHIEVE = 'achieve_json'
const KEY_DAY_BUCKETS = 'day_buckets_json'

export class GrowthStore {
  private static pref: preferences.Preferences | null = null
  private static activities: ActivityEvent[] = []
  private static tasks: StudyTask[] = []
  private static notes: UserNote[] = []
  private static checkins: CheckinRecord[] = []
  private static achievements: AchievementItem[] = []
  private static dayBuckets: DayCountItem[] = []

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      GrowthStore.pref = await preferences.getPreferences(context, STORE_NAME)
      GrowthStore.activities = GrowthStore.parseActivity(await GrowthStore.str(KEY_ACTIVITY, '[]'))
      GrowthStore.tasks = GrowthStore.parseTasks(await GrowthStore.str(KEY_TASKS, '[]'))
      GrowthStore.notes = GrowthStore.parseNotes(await GrowthStore.str(KEY_NOTES, '[]'))
      GrowthStore.checkins = GrowthStore.parseCheckins(await GrowthStore.str(KEY_CHECKIN, '[]'))
      GrowthStore.achievements = GrowthStore.parseAchievements(await GrowthStore.str(KEY_ACHIEVE, '[]'))
      GrowthStore.dayBuckets = GrowthStore.parseDayBuckets(await GrowthStore.str(KEY_DAY_BUCKETS, '[]'))
      GrowthStore.ensureAchievementDefs()
      GrowthStore.evaluateAchievements()
    } catch {
      GrowthStore.activities = []
      GrowthStore.ensureAchievementDefs()
    }
  }

  static recentActivities(limit: number): ActivityEvent[] {
    const out: ActivityEvent[] = []
    const max = limit > GrowthStore.activities.length ? GrowthStore.activities.length : limit
    for (let i = 0; i < max; i++) {
      out.push(GrowthStore.activities[i])
    }
    return out
  }

  static hasActivityToday(type: string): boolean {
    const key = GrowthStore.dayKeyNow()
    for (const e of GrowthStore.activities) {
      if (e.type === type && GrowthStore.dayKeyFromMs(e.createdAt) === key) {
        return true
      }
    }
    return false
  }

  static todayMissionDoneCount(): number {
    let n = 0
    if (GrowthStore.hasActivityToday('path')) {
      n += 1
    }
    if (GrowthStore.hasActivityToday('card')) {
      n += 1
    }
    if (GrowthStore.hasActivityToday('read')) {
      n += 1
    }
    return n
  }

  static allActivities(): ActivityEvent[] {
    return GrowthStore.copyActivities()
  }

  static noteAll(): UserNote[] {
    const out: UserNote[] = []
    for (const n of GrowthStore.notes) {
      out.push(n)
    }
    return out
  }

  static weekTasks(): StudyTask[] {
    const key = GrowthStore.weekKeyNow()
    const out: StudyTask[] = []
    for (const t of GrowthStore.tasks) {
      if (t.weekKey === key) {
        out.push(t)
      }
    }
    return out
  }

  static taskDoneCount(): number {
    let n = 0
    for (const t of GrowthStore.weekTasks()) {
      if (t.done) {
        n += 1
      }
    }
    return n
  }

  static taskTotalCount(): number {
    return GrowthStore.weekTasks().length
  }

  static achievementAll(): AchievementItem[] {
    const out: AchievementItem[] = []
    for (const a of GrowthStore.achievements) {
      out.push(a)
    }
    return out
  }

  static achievementUnlockedCount(): number {
    let n = 0
    for (const a of GrowthStore.achievements) {
      if (a.unlocked) {
        n += 1
      }
    }
    return n
  }

  static hasCheckinToday(): boolean {
    const key = GrowthStore.dayKeyNow()
    for (const c of GrowthStore.checkins) {
      if (c.dayKey === key) {
        return true
      }
    }
    return false
  }

  static weekCheckinCount(): number {
    const start = GrowthStore.weekStartMs()
    let n = 0
    for (const c of GrowthStore.checkins) {
      if (c.createdAt >= start) {
        n += 1
      }
    }
    return n
  }

  static monthCheckinCount(): number {
    const d = new Date()
    const prefix = `${d.getFullYear()}-${d.getMonth() + 1}-`
    let n = 0
    for (const c of GrowthStore.checkins) {
      if (c.dayKey.startsWith(prefix)) {
        n += 1
      }
    }
    return n
  }

  static weekDayCounts(): DayCountItem[] {
    return GrowthStore.recentDayCounts(7)
  }

  static recentDayCounts(totalDays: number): DayCountItem[] {
    const out: DayCountItem[] = []
    const n = totalDays > 0 ? totalDays : 7
    for (let i = n - 1; i >= 0; i--) {
      const item = new DayCountItem()
      const target = new Date()
      target.setDate(target.getDate() - i)
      item.dayKey = GrowthStore.dayKeyFromDate(target)
      item.label = `${target.getMonth() + 1}/${target.getDate()}`
      item.count = GrowthStore.bucketCount(item.dayKey)
      out.push(item)
    }
    return out
  }

  static categoryCollectCounts(): DayCountItem[] {
    const folders: string[] = ['生活百科', '科普知识', '历史文化', '学习知识', '健康常识', '趣味知识']
    const out: DayCountItem[] = []
    const all = VaultStore.all()
    for (const f of folders) {
      const item = new DayCountItem()
      item.dayKey = f
      item.label = f.length > 4 ? f.substring(0, 4) : f
      item.count = 0
      for (const c of all) {
        if (c.folder === f) {
          item.count += 1
        }
      }
      if (item.count > 0) {
        out.push(item)
      }
    }
    return out
  }

  static todayProgressPercent(): number {
    const goal = LearnStore.goal()
    if (goal <= 0) {
      return 0
    }
    const cur = LearnStore.todayCount()
    const p = cur / goal
    return p > 1 ? 1 : p
  }

  static buildStats(): GrowthStats {
    const s = new GrowthStats()
    s.asks = VaultStore.asks()
    s.collects = VaultStore.count()
    s.reads = LearnStore.reads()
    s.quizzes = LearnStore.quizTimes()
    s.cards = LearnStore.cardAll().length
    s.notes = GrowthStore.notes.length
    s.streak = VaultStore.streakDays()
    s.todayLearn = LearnStore.todayCount()
    s.dailyGoal = LearnStore.goal()
    return s
  }

  static async logActivity(type: string, title: string, refId: string, category: string): Promise<void> {
    const row = new ActivityEvent()
    row.id = `act_${Date.now()}`
    row.type = type
    row.title = title
    row.refId = refId
    row.category = category
    row.createdAt = Date.now()
    GrowthStore.activities.unshift(row)
    if (GrowthStore.activities.length > 120) {
      GrowthStore.activities = GrowthStore.activities.slice(0, 120)
    }
    GrowthStore.bumpDayBucket(GrowthStore.dayKeyNow())
    GrowthStore.evaluateAchievements()
    await GrowthStore.flush()
  }

  static async checkinToday(note: string): Promise<boolean> {
    if (GrowthStore.hasCheckinToday()) {
      return false
    }
    const row = new CheckinRecord()
    row.dayKey = GrowthStore.dayKeyNow()
    row.note = note
    row.createdAt = Date.now()
    GrowthStore.checkins.unshift(row)
    await VaultStore.markDailyRead()
    await LearnStore.addTodayProgress()
    const act = new ActivityEvent()
    act.id = `act_${Date.now()}`
    act.type = 'checkin'
    act.title = '完成今日学习打卡'
    act.refId = row.dayKey
    act.category = '打卡'
    act.createdAt = Date.now()
    GrowthStore.activities.unshift(act)
    GrowthStore.bumpDayBucket(row.dayKey)
    GrowthStore.evaluateAchievements()
    await GrowthStore.flush()
    return true
  }

  static async addTask(title: string): Promise<void> {
    const t = title.trim()
    if (t.length === 0) {
      return
    }
    const row = new StudyTask()
    row.id = `tsk_${Date.now()}`
    row.title = t
    row.weekKey = GrowthStore.weekKeyNow()
    row.createdAt = Date.now()
    GrowthStore.tasks.unshift(row)
    await GrowthStore.flush()
  }

  static async toggleTask(id: string): Promise<void> {
    for (const t of GrowthStore.tasks) {
      if (t.id === id) {
        t.done = !t.done
        if (t.done) {
          await GrowthStore.logActivity('task', `完成任务：${t.title}`, t.id, '计划')
        }
        break
      }
    }
    GrowthStore.evaluateAchievements()
    await GrowthStore.flush()
  }

  static async removeTask(id: string): Promise<void> {
    const next: StudyTask[] = []
    for (const t of GrowthStore.tasks) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    GrowthStore.tasks = next
    await GrowthStore.flush()
  }

  static async saveNote(title: string, body: string, category: string, userTag: string, id: string): Promise<void> {
    const now = Date.now()
    if (id.length > 0) {
      for (const n of GrowthStore.notes) {
        if (n.id === id) {
          n.title = title
          n.body = body
          n.category = category
          n.userTag = userTag
          n.updatedAt = now
          await GrowthStore.logActivity('note', `更新笔记：${title}`, n.id, category)
          await GrowthStore.flush()
          return
        }
      }
    }
    const row = new UserNote()
    row.id = `note_${now}`
    row.title = title
    row.body = body
    row.category = category
    row.userTag = userTag
    row.createdAt = now
    row.updatedAt = now
    GrowthStore.notes.unshift(row)
    await GrowthStore.logActivity('note', `新建笔记：${title}`, row.id, category)
    GrowthStore.evaluateAchievements()
    await GrowthStore.flush()
  }

  static async removeNote(id: string): Promise<void> {
    const next: UserNote[] = []
    for (const n of GrowthStore.notes) {
      if (n.id !== id) {
        next.push(n)
      }
    }
    GrowthStore.notes = next
    await GrowthStore.flush()
  }

  static noteById(id: string): UserNote | null {
    for (const n of GrowthStore.notes) {
      if (n.id === id) {
        return n
      }
    }
    return null
  }

  static evaluateAchievements(): void {
    const s = GrowthStore.buildStats()
    GrowthStore.setAchieve('first_ask', s.asks >= 1)
    GrowthStore.setAchieve('first_collect', s.collects >= 1)
    GrowthStore.setAchieve('streak_7', s.streak >= 7)
    GrowthStore.setAchieve('streak_30', s.streak >= 30)
    GrowthStore.setAchieve('quiz_10', s.quizzes >= 10)
    GrowthStore.setAchieve('quiz_50', s.quizzes >= 50)
    GrowthStore.setAchieve('collect_10', s.collects >= 10)
    GrowthStore.setAchieve('card_5', s.cards >= 5)
    GrowthStore.setAchieve('note_3', s.notes >= 3)
    GrowthStore.setAchieve('goal_done', s.todayLearn >= s.dailyGoal && s.dailyGoal > 0)
  }

  private static setAchieve(id: string, ok: boolean): void {
    for (const a of GrowthStore.achievements) {
      if (a.id === id && ok && !a.unlocked) {
        a.unlocked = true
        a.unlockedAt = Date.now()
      }
    }
  }

  private static ensureAchievementDefs(): void {
    if (GrowthStore.achievements.length >= 10) {
      return
    }
    GrowthStore.achievements = []
    GrowthStore.pushAchieve('first_ask', '初次提问', '完成第一次智慧提问')
    GrowthStore.pushAchieve('first_collect', '初识收藏', '把第一条解答收进知识库')
    GrowthStore.pushAchieve('streak_7', '坚持一周', '连续学习满 7 天')
    GrowthStore.pushAchieve('streak_30', '月度学者', '连续学习满 30 天')
    GrowthStore.pushAchieve('quiz_10', '答题新手', '累计答题 10 次')
    GrowthStore.pushAchieve('quiz_50', '答题达人', '累计答题 50 次')
    GrowthStore.pushAchieve('collect_10', '收藏达人', '收藏满 10 条')
    GrowthStore.pushAchieve('card_5', '卡片收藏家', '保存 5 张知识卡片')
    GrowthStore.pushAchieve('note_3', '笔记能手', '写下 3 篇个人笔记')
    GrowthStore.pushAchieve('goal_done', '今日达标', '达成一次每日学习目标')
  }

  private static pushAchieve(id: string, title: string, hint: string): void {
    const a = new AchievementItem()
    a.id = id
    a.title = title
    a.hint = hint
    GrowthStore.achievements.push(a)
  }

  private static bumpDayBucket(dayKey: string): void {
    let found = false
    for (const b of GrowthStore.dayBuckets) {
      if (b.dayKey === dayKey) {
        b.count += 1
        found = true
        break
      }
    }
    if (!found) {
      const item = new DayCountItem()
      item.dayKey = dayKey
      item.label = dayKey
      item.count = 1
      GrowthStore.dayBuckets.push(item)
    }
    if (GrowthStore.dayBuckets.length > 60) {
      GrowthStore.dayBuckets = GrowthStore.dayBuckets.slice(GrowthStore.dayBuckets.length - 60)
    }
  }

  private static bucketCount(dayKey: string): number {
    for (const b of GrowthStore.dayBuckets) {
      if (b.dayKey === dayKey) {
        return b.count
      }
    }
    return 0
  }

  private static dayKeyNow(): string {
    return GrowthStore.dayKeyFromDate(new Date())
  }

  private static dayKeyFromDate(d: Date): string {
    return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
  }

  private static dayKeyFromMs(ms: number): string {
    return GrowthStore.dayKeyFromDate(new Date(ms))
  }

  private static weekKeyNow(): string {
    const d = new Date()
    const one = new Date(d.getFullYear(), 0, 1)
    const dayMs = 86400000
    const dayOfYear = Math.floor((d.getTime() - one.getTime()) / dayMs) + 1
    const week = Math.ceil(dayOfYear / 7)
    return `${d.getFullYear()}-W${week}`
  }

  private static weekStartMs(): number {
    const d = new Date()
    const day = d.getDay()
    const diff = day === 0 ? 6 : day - 1
    return new Date(d.getFullYear(), d.getMonth(), d.getDate() - diff).getTime()
  }

  private static async str(key: string, fallback: string): Promise<string> {
    if (!GrowthStore.pref) {
      return fallback
    }
    try {
      const raw = await GrowthStore.pref.get(key, fallback)
      return typeof raw === 'string' ? raw : fallback
    } catch {
      return fallback
    }
  }

  private static async flush(): Promise<void> {
    if (!GrowthStore.pref) {
      return
    }
    try {
      await GrowthStore.pref.put(KEY_ACTIVITY, GrowthStore.encodeActivity())
      await GrowthStore.pref.put(KEY_TASKS, GrowthStore.encodeTasks())
      await GrowthStore.pref.put(KEY_NOTES, GrowthStore.encodeNotes())
      await GrowthStore.pref.put(KEY_CHECKIN, GrowthStore.encodeCheckins())
      await GrowthStore.pref.put(KEY_ACHIEVE, GrowthStore.encodeAchievements())
      await GrowthStore.pref.put(KEY_DAY_BUCKETS, GrowthStore.encodeDayBuckets())
      await GrowthStore.pref.flush()
    } catch {
    }
  }

  private static encodeActivity(): string {
    let json = '['
    for (let i = 0; i < GrowthStore.activities.length; i++) {
      const n = GrowthStore.activities[i]
      if (i > 0) {
        json += ','
      }
      json += `{"id":${JSON.stringify(n.id)},"type":${JSON.stringify(n.type)},` +
        `"title":${JSON.stringify(n.title)},"refId":${JSON.stringify(n.refId)},` +
        `"category":${JSON.stringify(n.category)},"createdAt":${n.createdAt}}`
    }
    json += ']'
    return json
  }

  private static encodeTasks(): string {
    let json = '['
    for (let i = 0; i < GrowthStore.tasks.length; i++) {
      const n = GrowthStore.tasks[i]
      if (i > 0) {
        json += ','
      }
      json += `{"id":${JSON.stringify(n.id)},"title":${JSON.stringify(n.title)},` +
        `"sourceType":${JSON.stringify(n.sourceType)},"sourceId":${JSON.stringify(n.sourceId)},` +
        `"done":${n.done},"weekKey":${JSON.stringify(n.weekKey)},"createdAt":${n.createdAt}}`
    }
    json += ']'
    return json
  }

  private static encodeNotes(): string {
    let json = '['
    for (let i = 0; i < GrowthStore.notes.length; i++) {
      const n = GrowthStore.notes[i]
      if (i > 0) {
        json += ','
      }
      json += `{"id":${JSON.stringify(n.id)},"title":${JSON.stringify(n.title)},` +
        `"body":${JSON.stringify(n.body)},"category":${JSON.stringify(n.category)},` +
        `"userTag":${JSON.stringify(n.userTag)},"createdAt":${n.createdAt},"updatedAt":${n.updatedAt}}`
    }
    json += ']'
    return json
  }

  private static encodeCheckins(): string {
    let json = '['
    for (let i = 0; i < GrowthStore.checkins.length; i++) {
      const n = GrowthStore.checkins[i]
      if (i > 0) {
        json += ','
      }
      json += `{"dayKey":${JSON.stringify(n.dayKey)},"note":${JSON.stringify(n.note)},` +
        `"createdAt":${n.createdAt}}`
    }
    json += ']'
    return json
  }

  private static encodeAchievements(): string {
    let json = '['
    for (let i = 0; i < GrowthStore.achievements.length; i++) {
      const n = GrowthStore.achievements[i]
      if (i > 0) {
        json += ','
      }
      json += `{"id":${JSON.stringify(n.id)},"title":${JSON.stringify(n.title)},` +
        `"hint":${JSON.stringify(n.hint)},"unlocked":${n.unlocked},"unlockedAt":${n.unlockedAt}}`
    }
    json += ']'
    return json
  }

  private static encodeDayBuckets(): string {
    let json = '['
    for (let i = 0; i < GrowthStore.dayBuckets.length; i++) {
      const n = GrowthStore.dayBuckets[i]
      if (i > 0) {
        json += ','
      }
      json += `{"dayKey":${JSON.stringify(n.dayKey)},"label":${JSON.stringify(n.label)},` +
        `"count":${n.count}}`
    }
    json += ']'
    return json
  }

  private static parseActivity(raw: string): ActivityEvent[] {
    const out: ActivityEvent[] = []
    try {
      const arr = JSON.parse(raw) as ActivityEvent[]
      if (arr) {
        for (const n of arr) {
          const row = new ActivityEvent()
          row.id = n.id
          row.type = n.type
          row.title = n.title
          row.refId = n.refId
          row.category = n.category
          row.createdAt = n.createdAt
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  private static parseTasks(raw: string): StudyTask[] {
    const out: StudyTask[] = []
    try {
      const arr = JSON.parse(raw) as StudyTask[]
      if (arr) {
        for (const n of arr) {
          const row = new StudyTask()
          row.id = n.id
          row.title = n.title
          row.sourceType = n.sourceType
          row.sourceId = n.sourceId
          row.done = n.done === true
          row.weekKey = n.weekKey
          row.createdAt = n.createdAt
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  private static parseNotes(raw: string): UserNote[] {
    const out: UserNote[] = []
    try {
      const arr = JSON.parse(raw) as UserNote[]
      if (arr) {
        for (const n of arr) {
          const row = new UserNote()
          row.id = n.id
          row.title = n.title
          row.body = n.body
          row.category = n.category
          row.userTag = n.userTag
          row.createdAt = n.createdAt
          row.updatedAt = n.updatedAt
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  private static parseCheckins(raw: string): CheckinRecord[] {
    const out: CheckinRecord[] = []
    try {
      const arr = JSON.parse(raw) as CheckinRecord[]
      if (arr) {
        for (const n of arr) {
          const row = new CheckinRecord()
          row.dayKey = n.dayKey
          row.note = n.note
          row.createdAt = n.createdAt
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  private static parseAchievements(raw: string): AchievementItem[] {
    const out: AchievementItem[] = []
    try {
      const arr = JSON.parse(raw) as AchievementItem[]
      if (arr) {
        for (const n of arr) {
          const row = new AchievementItem()
          row.id = n.id
          row.title = n.title
          row.hint = n.hint
          row.unlocked = n.unlocked === true
          row.unlockedAt = n.unlockedAt
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  private static parseDayBuckets(raw: string): DayCountItem[] {
    const out: DayCountItem[] = []
    try {
      const arr = JSON.parse(raw) as DayCountItem[]
      if (arr) {
        for (const n of arr) {
          const row = new DayCountItem()
          row.dayKey = n.dayKey
          row.label = n.label
          row.count = n.count
          out.push(row)
        }
      }
    } catch {
      return out
    }
    return out
  }

  private static copyActivities(): ActivityEvent[] {
    const out: ActivityEvent[] = []
    for (const n of GrowthStore.activities) {
      out.push(n)
    }
    return out
  }
}
