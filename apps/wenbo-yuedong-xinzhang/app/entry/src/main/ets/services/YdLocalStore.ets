import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import {
  YdBadgeItem, YdChapterItem, YdCheckIn, YdFavoriteRef, YdGoalItem, YdHomeSummary, YdHourSlot,
  YdMilestoneItem, YdReviewStats, YdSearchHit, YdTag, YdTaskItem, YdTimelineEvent,
  YdUserProfile, YdWeekDayStat
} from '../models/YdModels'

const STORE = 'yuedong_xinzhang_v1'
const KEY_TASKS = 'tasks_v1'
const KEY_GOALS = 'goals_v1'
const KEY_CHAPTERS = 'chapters_v1'
const KEY_PROFILE = 'profile_v1'
const KEY_DARK = 'dark_v1'
const KEY_STREAK = 'streak_v1'
const KEY_LAST_ACTIVE = 'last_active_v1'
const KEY_DAILY_NOTES = 'daily_notes_v1'
const KEY_FAVORITES = 'favorites_v1'
const KEY_CHECKINS = 'checkins_v1'
const KEY_TAGS = 'tags_v1'
const KEY_ENTITY_TAGS = 'entity_tags_v1'

export class YdLocalStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      YdLocalStore.pref = await preferences.getPreferences(context, STORE)
    } catch {
      YdLocalStore.pref = null
    }
  }

  static async loadTasksForDate(dateKey: string): Promise<YdTaskItem[]> {
    const all = await YdLocalStore.loadAllTasks()
    const out: YdTaskItem[] = []
    for (const t of all) {
      if (t.dateKey === dateKey) {
        out.push(t)
      }
    }
    return YdLocalStore.sortTasks(out)
  }

  static cloneTask(source: YdTaskItem): YdTaskItem {
    const t = new YdTaskItem()
    t.id = source.id
    t.title = source.title
    t.timeSlot = source.timeSlot
    t.priority = source.priority
    t.done = source.done
    t.dateKey = source.dateKey
    t.createdAt = source.createdAt
    t.domain = source.domain
    t.durationMin = source.durationMin
    t.note = source.note
    return t
  }

  static async loadAllTasks(): Promise<YdTaskItem[]> {
    const raw = await YdLocalStore.getString(KEY_TASKS, '')
    return YdLocalStore.parseTasks(raw)
  }

  static async createTask(title: string, timeSlot: string, priority: string, domain: string,
    durationMin: number): Promise<YdTaskItem> {
    const item = new YdTaskItem()
    item.id = YdTaskItem.newId()
    item.title = title
    item.timeSlot = timeSlot
    item.priority = priority
    item.domain = domain
    item.durationMin = durationMin
    item.dateKey = YdTaskItem.todayKey()
    item.createdAt = Date.now()
    const list = await YdLocalStore.loadAllTasks()
    list.push(item)
    await YdLocalStore.persistTasks(list)
    return item
  }

  static async updateTask(item: YdTaskItem): Promise<void> {
    const list = await YdLocalStore.loadAllTasks()
    const next: YdTaskItem[] = []
    for (const t of list) {
      if (t.id === item.id) {
        next.push(item)
      } else {
        next.push(t)
      }
    }
    await YdLocalStore.persistTasks(next)
  }

  static async addFocusMinutes(id: string, minutes: number): Promise<void> {
    const list = await YdLocalStore.loadAllTasks()
    const next: YdTaskItem[] = []
    for (const t of list) {
      if (t.id === id) {
        t.durationMin = t.durationMin + minutes
      }
      next.push(t)
    }
    await YdLocalStore.persistTasks(next)
  }

  static buildHourSlots(tasks: YdTaskItem[]): YdHourSlot[] {
    const slots: YdHourSlot[] = []
    for (let h = 7; h <= 21; h++) {
      const slot = new YdHourSlot()
      slot.hour = h
      slot.label = h < 10 ? `0${h}:00` : `${h}:00`
      const items: YdTaskItem[] = []
      for (const t of tasks) {
        if (t.hourKey() === h) {
          items.push(t)
        }
      }
      slot.items = items
      slots.push(slot)
    }
    return slots
  }

  static async setTaskDone(id: string, done: boolean): Promise<void> {
    const list = await YdLocalStore.loadAllTasks()
    let changed = false
    const next: YdTaskItem[] = []
    for (const t of list) {
      if (t.id === id) {
        if (t.done !== done) {
          t.done = done
          changed = true
        }
      }
      next.push(t)
    }
    if (!changed) {
      return
    }
    await YdLocalStore.persistTasks(next)
    if (done) {
      await YdLocalStore.touchStreak()
    }
  }

  static async toggleTaskDone(id: string): Promise<void> {
    const found = await YdLocalStore.findTask(id)
    if (found === undefined) {
      return
    }
    await YdLocalStore.setTaskDone(id, !found.done)
  }

  static async deleteTask(id: string): Promise<void> {
    const list = await YdLocalStore.loadAllTasks()
    const next: YdTaskItem[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    await YdLocalStore.persistTasks(next)
  }

  static async findTask(id: string): Promise<YdTaskItem | undefined> {
    const list = await YdLocalStore.loadAllTasks()
    for (const t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static async loadActiveGoals(): Promise<YdGoalItem[]> {
    const all = await YdLocalStore.loadAllGoals()
    const out: YdGoalItem[] = []
    for (const g of all) {
      if (!g.archived) {
        out.push(g)
      }
    }
    return out
  }

  static async loadArchivedGoals(): Promise<YdGoalItem[]> {
    const all = await YdLocalStore.loadAllGoals()
    const out: YdGoalItem[] = []
    for (const g of all) {
      if (g.archived) {
        out.push(g)
      }
    }
    return out
  }

  static async loadDailyNote(dateKey: string): Promise<string> {
    const raw = await YdLocalStore.getString(KEY_DAILY_NOTES, '')
    if (raw.trim().length === 0) {
      return ''
    }
    for (const line of raw.split('\n')) {
      if (line.trim().length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length >= 2 && p[0] === dateKey) {
        return p.slice(1).join('\t').replace(/¶/g, '\n')
      }
    }
    return ''
  }

  static async saveDailyNote(dateKey: string, text: string): Promise<void> {
    const raw = await YdLocalStore.getString(KEY_DAILY_NOTES, '')
    const lines: string[] = []
    let found = false
    const esc = text.replace(/\n/g, '¶').replace(/\t/g, ' ')
    for (const line of raw.split('\n')) {
      if (line.trim().length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length >= 1 && p[0] === dateKey) {
        if (esc.trim().length > 0) {
          lines.push(`${dateKey}\t${esc}`)
        }
        found = true
      } else {
        lines.push(line)
      }
    }
    if (!found && esc.trim().length > 0) {
      lines.push(`${dateKey}\t${esc}`)
    }
    await YdLocalStore.putString(KEY_DAILY_NOTES, lines.join('\n'))
  }

  static async loadChapterPeriodNotes(startKey: string, endKey: string): Promise<string> {
    const raw = await YdLocalStore.getString(KEY_DAILY_NOTES, '')
    const blocks: string[] = []
    for (const line of raw.split('\n')) {
      if (line.trim().length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length >= 2 && p[0] >= startKey && p[0] <= endKey) {
        const body = p.slice(1).join('\t').replace(/¶/g, '\n')
        if (body.trim().length > 0) {
          blocks.push(`${p[0]}：${body}`)
        }
      }
    }
    return blocks.join('\n\n')
  }

  static async computeWeekDayStats(): Promise<YdWeekDayStat[]> {
    const tasks = await YdLocalStore.loadAllTasks()
    const out: YdWeekDayStat[] = []
    const labels = ['一', '二', '三', '四', '五', '六', '日']
    const today = new Date()
    for (let i = 6; i >= 0; i--) {
      const d = new Date(today)
      d.setDate(d.getDate() - i)
      const y = d.getFullYear()
      const m = d.getMonth() + 1
      const ds = d.getDate()
      const ms = m < 10 ? `0${m}` : `${m}`
      const dd = ds < 10 ? `0${ds}` : `${ds}`
      const key = `${y}-${ms}-${dd}`
      const stat = new YdWeekDayStat()
      stat.dateKey = key
      stat.weekday = labels[(d.getDay() + 6) % 7]
      for (const t of tasks) {
        if (t.dateKey === key) {
          stat.totalCount++
          if (t.done) {
            stat.doneCount++
          }
        }
      }
      out.push(stat)
    }
    return out
  }

  static async buildWeeklyReportText(): Promise<string> {
    const stats = await YdLocalStore.computeReviewStats()
    const week = await YdLocalStore.computeWeekDayStats()
    const lines: string[] = []
    lines.push('【跃动新章 · 本周执行摘要】')
    lines.push(`完成 ${stats.weekDone} 步 · 投入 ${stats.workMin + stats.studyMin + stats.lifeMin} 分钟`)
    lines.push(`工作 ${stats.workMin} 分 / 学习 ${stats.studyMin} 分 / 生活 ${stats.lifeMin} 分`)
    lines.push(`连续 ${stats.streakDays} 天 · 跃动指数 ${stats.leapIndex}`)
    lines.push('')
    lines.push('近 7 日：')
    for (const d of week) {
      lines.push(`${d.weekday} ${d.dateKey}：${d.doneCount}/${d.totalCount}`)
    }
    const chapters = await YdLocalStore.loadAllChapters()
    let closed = 0
    for (const c of chapters) {
      if (c.closed) {
        closed++
      }
    }
    lines.push('')
    lines.push(`已收官篇章 ${closed} 篇`)
    return lines.join('\n')
  }

  static async exportAllChaptersText(): Promise<string> {
    const chapters = await YdLocalStore.loadAllChapters()
    if (chapters.length === 0) {
      return '暂无篇章档案'
    }
    const blocks: string[] = ['【跃动新章 · 篇章档案导出】', '']
    for (const c of chapters) {
      blocks.push(YdLocalStore.exportChapterText(c))
      blocks.push('')
    }
    return blocks.join('\n')
  }

  static async loadAllGoals(): Promise<YdGoalItem[]> {
    const raw = await YdLocalStore.getString(KEY_GOALS, '')
    return YdLocalStore.parseGoals(raw)
  }

  static async findGoal(id: string): Promise<YdGoalItem | undefined> {
    const list = await YdLocalStore.loadAllGoals()
    for (const g of list) {
      if (g.id === id) {
        return g
      }
    }
    return undefined
  }

  static async createGoal(title: string, summary: string, milestoneTitles: string[]): Promise<YdGoalItem> {
    const g = new YdGoalItem()
    g.id = YdGoalItem.newId()
    g.title = title
    g.summary = summary
    g.createdAt = Date.now()
    const ms: YdMilestoneItem[] = []
    for (const t of milestoneTitles) {
      const m = new YdMilestoneItem()
      m.id = YdMilestoneItem.newId()
      m.title = t.trim()
      if (m.title.length > 0) {
        ms.push(m)
      }
    }
    g.milestones = ms
    const list = await YdLocalStore.loadAllGoals()
    list.push(g)
    await YdLocalStore.persistGoals(list)
    return g
  }

  static async toggleMilestone(goalId: string, milestoneId: string): Promise<void> {
    const list = await YdLocalStore.loadAllGoals()
    const next: YdGoalItem[] = []
    for (const g of list) {
      if (g.id === goalId) {
        const ms: YdMilestoneItem[] = []
        for (const m of g.milestones) {
          if (m.id === milestoneId) {
            m.done = !m.done
          }
          ms.push(m)
        }
        g.milestones = ms
        if (g.progressPercent() >= 100) {
          g.archived = true
        }
      }
      next.push(g)
    }
    await YdLocalStore.persistGoals(next)
  }

  static async deleteGoal(id: string): Promise<void> {
    const list = await YdLocalStore.loadAllGoals()
    const next: YdGoalItem[] = []
    for (const g of list) {
      if (g.id !== id) {
        next.push(g)
      }
    }
    await YdLocalStore.persistGoals(next)
  }

  static async loadProfile(): Promise<YdUserProfile> {
    const raw = await YdLocalStore.getString(KEY_PROFILE, '')
    if (raw.length === 0) {
      return new YdUserProfile()
    }
    const p = new YdUserProfile()
    const parts = raw.split('\t')
    if (parts.length >= 1) {
      p.nickname = parts[0]
    }
    if (parts.length >= 2) {
      p.avatarKey = parts[1]
    }
    return p
  }

  static async saveProfile(profile: YdUserProfile): Promise<void> {
    await YdLocalStore.putString(KEY_PROFILE, `${profile.nickname}\t${profile.avatarKey}`)
  }

  static async isDarkMode(): Promise<boolean> {
    return (await YdLocalStore.getString(KEY_DARK, '0')) === '1'
  }

  static async setDarkMode(on: boolean): Promise<void> {
    await YdLocalStore.putString(KEY_DARK, on ? '1' : '0')
  }

  static async computeReviewStats(): Promise<YdReviewStats> {
    const stats = new YdReviewStats()
    const today = YdTaskItem.todayKey()
    const tasks = await YdLocalStore.loadAllTasks()
    for (const t of tasks) {
      if (t.dateKey === today) {
        stats.todayTotal++
        if (t.done) {
          stats.todayDone++
        }
      }
      if (t.done && YdLocalStore.isDateKeyWithinDays(t.dateKey, 7)) {
        stats.weekDone++
        if (t.domain === 'study') {
          stats.studyMin += t.durationMin
        } else if (t.domain === 'life') {
          stats.lifeMin += t.durationMin
        } else {
          stats.workMin += t.durationMin
        }
      }
      if (t.done && YdLocalStore.isDateKeyWithinDays(t.dateKey, 30)) {
        stats.monthDone++
      }
    }
    if (stats.todayTotal > 0) {
      stats.completionRate = Math.floor((stats.todayDone * 100) / stats.todayTotal)
    }
    stats.streakDays = await YdLocalStore.getStreak()
    const chapters = await YdLocalStore.loadAllChapters()
    let closed = 0
    let hasOpen = false
    for (const c of chapters) {
      if (c.closed) {
        closed++
      } else {
        hasOpen = true
      }
    }
    stats.chapterClosed = closed
    const goals = await YdLocalStore.loadAllGoals()
    let goalScore = 0
    if (goals.length > 0) {
      let sum = 0
      for (const g of goals) {
        sum += g.progressPercent()
      }
      goalScore = Math.floor(sum / goals.length / 5)
    }
    let leap = Math.floor(stats.completionRate * 0.4)
    leap += Math.min(stats.streakDays * 5, 25)
    leap += Math.min(goalScore, 20)
    leap += hasOpen ? 8 : 0
    leap += Math.min(closed * 6, 18)
    if (leap > 100) {
      leap = 100
    }
    stats.leapIndex = leap
    return stats
  }

  static async loadBadges(): Promise<YdBadgeItem[]> {
    const streak = await YdLocalStore.getStreak()
    const stats = await YdLocalStore.computeReviewStats()
    const badges: YdBadgeItem[] = []
    const b1 = new YdBadgeItem()
    b1.id = 'streak3'
    b1.title = '连续3天'
    b1.desc = '连续完成日程 3 天'
    b1.thresholdDays = 3
    b1.unlocked = streak >= 3
    badges.push(b1)
    const b2 = new YdBadgeItem()
    b2.id = 'streak7'
    b2.title = '连续7天'
    b2.desc = '连续完成日程 7 天'
    b2.thresholdDays = 7
    b2.unlocked = streak >= 7
    badges.push(b2)
    const b3 = new YdBadgeItem()
    b3.id = 'week10'
    b3.title = '本周十项'
    b3.desc = '本周完成 10 项任务'
    b3.thresholdDays = 0
    b3.unlocked = stats.weekDone >= 10
    badges.push(b3)
    const b4 = new YdBadgeItem()
    b4.id = 'goal1'
    b4.title = '首目标达成'
    b4.desc = '完成第一个长期目标'
    b4.thresholdDays = 0
    const goals = await YdLocalStore.loadAllGoals()
    let archived = 0
    for (const g of goals) {
      if (g.archived) {
        archived++
      }
    }
    b4.unlocked = archived >= 1
    badges.push(b4)
    const b5 = new YdBadgeItem()
    b5.id = 'chapter1'
    b5.title = '写下第一章'
    b5.desc = '完成一次章末复盘并收官'
    b5.thresholdDays = 0
    b5.unlocked = stats.chapterClosed >= 1
    badges.push(b5)
    const b6 = new YdBadgeItem()
    b6.id = 'streak30'
    b6.title = '连续30天'
    b6.desc = '连续跃动 30 天'
    b6.unlocked = streak >= 30
    badges.push(b6)
    const b7 = new YdBadgeItem()
    b7.id = 'month30'
    b7.title = '本月30步'
    b7.desc = '本月完成 30 项任务'
    b7.unlocked = stats.monthDone >= 30
    badges.push(b7)
    const b8 = new YdBadgeItem()
    b8.id = 'chapter3'
    b8.title = '三章收官'
    b8.desc = '完成 3 次章末复盘收官'
    b8.unlocked = stats.chapterClosed >= 3
    badges.push(b8)
    const favs = await YdLocalStore.loadFavorites()
    const b9 = new YdBadgeItem()
    b9.id = 'fav5'
    b9.title = '收藏达人'
    b9.desc = '收藏 5 条以上内容'
    b9.unlocked = favs.length >= 5
    badges.push(b9)
    const checkins = await YdLocalStore.loadAllCheckIns()
    const b10 = new YdBadgeItem()
    b10.id = 'checkin7'
    b10.title = '打卡一周'
    b10.desc = '累计跃动打卡 7 天'
    b10.unlocked = checkins.length >= 7
    badges.push(b10)
    const b11 = new YdBadgeItem()
    b11.id = 'leap80'
    b11.title = '跃动高手'
    b11.desc = '跃动指数达到 80'
    b11.unlocked = stats.leapIndex >= 80
    badges.push(b11)
    const b12 = new YdBadgeItem()
    b12.id = 'note7'
    b12.title = '微记习惯'
    b12.desc = '累计写 7 天今日微记'
    b12.unlocked = await YdLocalStore.countDailyNotes() >= 7
    badges.push(b12)
    return badges
  }

  static async computeHomeSummary(): Promise<YdHomeSummary> {
    const stats = await YdLocalStore.computeReviewStats()
    const tasks = await YdLocalStore.loadAllTasks()
    const s = new YdHomeSummary()
    s.taskTotal = tasks.length
    s.todayDone = stats.todayDone
    s.todayTotal = stats.todayTotal
    s.streakDays = stats.streakDays
    s.leapIndex = stats.leapIndex
    s.favoriteCount = (await YdLocalStore.loadFavorites()).length
    s.checkInToday = await YdLocalStore.hasCheckInToday()
    let done = 0
    for (const t of tasks) {
      if (t.done) {
        done++
      }
    }
    s.taskDoneAll = done
    return s
  }

  static async loadFavorites(): Promise<YdFavoriteRef[]> {
    const raw = await YdLocalStore.getString(KEY_FAVORITES, '')
    if (raw.trim().length === 0) {
      return []
    }
    const out: YdFavoriteRef[] = []
    for (const line of raw.split('\n')) {
      if (line.trim().length === 0) {
        continue
      }
      const p = line.split('|')
      if (p.length < 5) {
        continue
      }
      const f = new YdFavoriteRef()
      f.id = p[0]
      f.entityType = p[1]
      f.entityId = p[2]
      f.title = p[3]
      f.createdAt = parseInt(p[4], 10)
      out.push(f)
    }
    out.sort((a, b) => b.createdAt - a.createdAt)
    return out
  }

  static async isFavorite(entityType: string, entityId: string): Promise<boolean> {
    const list = await YdLocalStore.loadFavorites()
    for (const f of list) {
      if (f.entityType === entityType && f.entityId === entityId) {
        return true
      }
    }
    return false
  }

  static async toggleFavorite(entityType: string, entityId: string, title: string): Promise<boolean> {
    const list = await YdLocalStore.loadFavorites()
    const next: YdFavoriteRef[] = []
    let removed = false
    for (const f of list) {
      if (f.entityType === entityType && f.entityId === entityId) {
        removed = true
      } else {
        next.push(f)
      }
    }
    if (!removed) {
      const f = new YdFavoriteRef()
      f.id = YdFavoriteRef.newId()
      f.entityType = entityType
      f.entityId = entityId
      f.title = title
      f.createdAt = Date.now()
      next.push(f)
    }
    await YdLocalStore.persistFavorites(next)
    return !removed
  }

  static async saveCheckIn(note: string): Promise<void> {
    const key = YdTaskItem.todayKey()
    const list = await YdLocalStore.loadAllCheckIns()
    const next: YdCheckIn[] = []
    let found = false
    for (const c of list) {
      if (c.dateKey === key) {
        const u = new YdCheckIn()
        u.dateKey = key
        u.note = note
        u.createdAt = Date.now()
        next.push(u)
        found = true
      } else {
        next.push(c)
      }
    }
    if (!found) {
      const u = new YdCheckIn()
      u.dateKey = key
      u.note = note
      u.createdAt = Date.now()
      next.push(u)
    }
    await YdLocalStore.persistCheckIns(next)
    await YdLocalStore.touchStreak()
  }

  static async hasCheckInToday(): Promise<boolean> {
    const key = YdTaskItem.todayKey()
    for (const c of await YdLocalStore.loadAllCheckIns()) {
      if (c.dateKey === key) {
        return true
      }
    }
    return false
  }

  static async loadCheckInForDate(dateKey: string): Promise<YdCheckIn | undefined> {
    for (const c of await YdLocalStore.loadAllCheckIns()) {
      if (c.dateKey === dateKey) {
        return c
      }
    }
    return undefined
  }

  static async loadAllCheckIns(): Promise<YdCheckIn[]> {
    const raw = await YdLocalStore.getString(KEY_CHECKINS, '')
    if (raw.trim().length === 0) {
      return []
    }
    const out: YdCheckIn[] = []
    for (const line of raw.split('\n')) {
      if (line.trim().length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length < 2) {
        continue
      }
      const c = new YdCheckIn()
      c.dateKey = p[0]
      c.note = p.slice(1).join('\t').replace(/¶/g, '\n')
      if (p.length >= 3) {
        c.createdAt = parseInt(p[p.length - 1], 10)
      }
      out.push(c)
    }
    return out
  }

  static async loadTags(): Promise<YdTag[]> {
    const raw = await YdLocalStore.getString(KEY_TAGS, '')
    if (raw.trim().length === 0) {
      return []
    }
    const out: YdTag[] = []
    for (const line of raw.split('\n')) {
      if (line.trim().length === 0) {
        continue
      }
      const p = line.split('|')
      if (p.length < 3) {
        continue
      }
      const t = new YdTag()
      t.id = p[0]
      t.label = p[1]
      t.colorKey = p[2]
      out.push(t)
    }
    return out
  }

  static async createTag(label: string, colorKey: string): Promise<string> {
    const text = label.trim()
    if (text.length === 0 || text.length > 8) {
      return '标签 1～8 字'
    }
    const t = new YdTag()
    t.id = YdTag.newId()
    t.label = text
    t.colorKey = colorKey
    const list = await YdLocalStore.loadTags()
    list.push(t)
    await YdLocalStore.persistTags(list)
    return ''
  }

  static async deleteTag(id: string): Promise<void> {
    const list = await YdLocalStore.loadTags()
    const next: YdTag[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    await YdLocalStore.persistTags(next)
  }

  static async getEntityTagIds(entityType: string, entityId: string): Promise<string[]> {
    const raw = await YdLocalStore.getString(KEY_ENTITY_TAGS, '')
    for (const line of raw.split('\n')) {
      if (line.trim().length === 0) {
        continue
      }
      const p = line.split('|')
      if (p.length >= 3 && p[0] === entityType && p[1] === entityId) {
        if (p[2].length === 0) {
          return []
        }
        return p[2].split(',')
      }
    }
    return []
  }

  static async setEntityTagIds(entityType: string, entityId: string, tagIds: string[]): Promise<void> {
    const raw = await YdLocalStore.getString(KEY_ENTITY_TAGS, '')
    const lines: string[] = []
    let found = false
    const joined = tagIds.join(',')
    for (const line of raw.split('\n')) {
      if (line.trim().length === 0) {
        continue
      }
      const p = line.split('|')
      if (p.length >= 2 && p[0] === entityType && p[1] === entityId) {
        if (joined.length > 0) {
          lines.push(`${entityType}|${entityId}|${joined}`)
        }
        found = true
      } else {
        lines.push(line)
      }
    }
    if (!found && joined.length > 0) {
      lines.push(`${entityType}|${entityId}|${joined}`)
    }
    await YdLocalStore.putString(KEY_ENTITY_TAGS, lines.join('\n'))
  }

  static async buildTimeline(maxDays: number): Promise<YdTimelineEvent[]> {
    const events: YdTimelineEvent[] = []
    const tasks = await YdLocalStore.loadAllTasks()
    for (const t of tasks) {
      if (!YdLocalStore.isDateKeyWithinDays(t.dateKey, maxDays)) {
        continue
      }
      const e1 = new YdTimelineEvent()
      e1.id = `tl_tc_${t.id}`
      e1.dateKey = t.dateKey
      e1.timeMs = t.createdAt
      e1.kind = 'task_create'
      e1.title = t.title
      e1.refType = 'task'
      e1.refId = t.id
      events.push(e1)
      if (t.done) {
        const e2 = new YdTimelineEvent()
        e2.id = `tl_td_${t.id}`
        e2.dateKey = t.dateKey
        e2.timeMs = t.createdAt + 60000
        e2.kind = 'task_done'
        e2.title = t.title
        e2.refType = 'task'
        e2.refId = t.id
        events.push(e2)
      }
    }
    const chapters = await YdLocalStore.loadAllChapters()
    for (const c of chapters) {
      if (YdLocalStore.isDateKeyWithinDays(c.startKey, maxDays)) {
        const e = new YdTimelineEvent()
        e.id = `tl_co_${c.id}`
        e.dateKey = c.startKey
        e.timeMs = c.createdAt
        e.kind = 'chapter_open'
        e.title = c.title
        e.refType = 'chapter'
        e.refId = c.id
        events.push(e)
      }
      if (c.closed && c.recap.length > 0) {
        const e = new YdTimelineEvent()
        e.id = `tl_cc_${c.id}`
        e.dateKey = c.endKey.length > 0 ? c.endKey : c.startKey
        e.timeMs = c.createdAt + 120000
        e.kind = 'chapter_close'
        e.title = `${c.title} · 收官`
        e.refType = 'chapter'
        e.refId = c.id
        events.push(e)
      }
    }
    const goals = await YdLocalStore.loadAllGoals()
    for (const g of goals) {
      if (g.archived) {
        const e = new YdTimelineEvent()
        e.id = `tl_ga_${g.id}`
        e.dateKey = YdTaskItem.todayKey()
        e.timeMs = g.createdAt
        e.kind = 'goal_archive'
        e.title = g.title
        e.refType = 'goal'
        e.refId = g.id
        events.push(e)
      }
    }
    for (const c of await YdLocalStore.loadAllCheckIns()) {
      if (YdLocalStore.isDateKeyWithinDays(c.dateKey, maxDays)) {
        const e = new YdTimelineEvent()
        e.id = `tl_ci_${c.dateKey}`
        e.dateKey = c.dateKey
        e.timeMs = c.createdAt > 0 ? c.createdAt : YdLocalStore.dateKeyToMs(c.dateKey)
        e.kind = 'checkin'
        e.title = c.note.length > 0 ? c.note : '今日跃动打卡'
        e.refType = 'checkin'
        e.refId = c.dateKey
        events.push(e)
      }
    }
    const noteRaw = await YdLocalStore.getString(KEY_DAILY_NOTES, '')
    for (const line of noteRaw.split('\n')) {
      if (line.trim().length === 0) {
        continue
      }
      const p = line.split('\t')
      if (p.length >= 2 && YdLocalStore.isDateKeyWithinDays(p[0], maxDays)) {
        const e = new YdTimelineEvent()
        e.id = `tl_nt_${p[0]}`
        e.dateKey = p[0]
        e.timeMs = YdLocalStore.dateKeyToMs(p[0])
        e.kind = 'note'
        const body = p.slice(1).join('\t').replace(/¶/g, '\n')
        e.title = body.length > 24 ? `${body.substring(0, 24)}…` : body
        e.refType = 'note'
        e.refId = p[0]
        events.push(e)
      }
    }
    events.sort((a, b) => b.timeMs - a.timeMs)
    return events
  }

  static async buildRecentActivity(limit: number): Promise<YdTimelineEvent[]> {
    const all = await YdLocalStore.buildTimeline(30)
    const out: YdTimelineEvent[] = []
    for (let i = 0; i < all.length && i < limit; i++) {
      out.push(all[i])
    }
    return out
  }

  static async searchAll(keyword: string, entityFilter: string, tagId: string = '',
    daysBack: number = 0): Promise<YdSearchHit[]> {
    const q = keyword.trim().toLowerCase()
    const hits: YdSearchHit[] = []
    const allowEmptyKeyword = tagId.length > 0 || daysBack > 0
    if (q.length === 0 && !allowEmptyKeyword) {
      return hits
    }
    const tagLabels = await YdLocalStore.loadTags()
    let tagLabel = ''
    for (const t of tagLabels) {
      if (t.id === tagId) {
        tagLabel = t.label.toLowerCase()
      }
    }
    if (entityFilter === 'all' || entityFilter === 'task') {
      for (const t of await YdLocalStore.loadAllTasks()) {
        if (!await YdLocalStore.matchSearchFilters(t.dateKey, t.id, 'task', q, tagId, tagLabel, daysBack,
          t.title, t.note)) {
          continue
        }
        const h = new YdSearchHit()
        h.entityType = 'task'
        h.entityId = t.id
        h.title = t.title
        h.subtitle = `${t.dateKey} · ${t.domainLabel()}`
        h.dateKey = t.dateKey
        hits.push(h)
      }
    }
    if (entityFilter === 'all' || entityFilter === 'chapter') {
      for (const c of await YdLocalStore.loadAllChapters()) {
        if (!await YdLocalStore.matchSearchFilters(c.startKey, c.id, 'chapter', q, tagId, tagLabel, daysBack,
          c.title, c.recap)) {
          continue
        }
        const h = new YdSearchHit()
        h.entityType = 'chapter'
        h.entityId = c.id
        h.title = c.title
        h.subtitle = `${c.themeLabel()} · ${c.closed ? '已收官' : '进行中'}`
        h.dateKey = c.startKey
        hits.push(h)
      }
    }
    if (entityFilter === 'all' || entityFilter === 'goal') {
      for (const g of await YdLocalStore.loadAllGoals()) {
        if (!await YdLocalStore.matchSearchFilters(YdTaskItem.todayKey(), g.id, 'goal', q, tagId, tagLabel, daysBack,
          g.title, g.summary)) {
          continue
        }
        const h = new YdSearchHit()
        h.entityType = 'goal'
        h.entityId = g.id
        h.title = g.title
        h.subtitle = g.archived ? '已达成' : '进行中'
        h.dateKey = YdTaskItem.todayKey()
        hits.push(h)
      }
    }
    if (entityFilter === 'all' || entityFilter === 'note') {
      const raw = await YdLocalStore.getString(KEY_DAILY_NOTES, '')
      for (const line of raw.split('\n')) {
        if (line.trim().length === 0) {
          continue
        }
        const p = line.split('\t')
        if (p.length >= 2) {
          const body = p.slice(1).join('\t')
          const dk = p[0]
          if (daysBack > 0 && !YdLocalStore.isDateKeyWithinDays(dk, daysBack)) {
            continue
          }
          if (tagId.length > 0) {
            continue
          }
          if (q.length > 0 && !body.toLowerCase().includes(q)) {
            continue
          }
          const h = new YdSearchHit()
          h.entityType = 'note'
          h.entityId = dk
          h.title = body.length > 32 ? `${body.substring(0, 32)}…` : body
          h.subtitle = `微记 · ${dk}`
          h.dateKey = dk
          hits.push(h)
        }
      }
    }
    return hits
  }

  private static async matchSearchFilters(dateKey: string, entityId: string, entityType: string,
    q: string, tagId: string, tagLabel: string, daysBack: number, title: string, body: string): Promise<boolean> {
    if (daysBack > 0 && !YdLocalStore.isDateKeyWithinDays(dateKey, daysBack)) {
      return false
    }
    if (tagId.length > 0) {
      const ids = await YdLocalStore.getEntityTagIds(entityType, entityId)
      let has = false
      for (const id of ids) {
        if (id === tagId) {
          has = true
        }
      }
      if (!has) {
        return false
      }
    }
    if (q.length === 0) {
      return true
    }
    if (title.toLowerCase().includes(q) || body.toLowerCase().includes(q)) {
      return true
    }
    if (tagLabel.length > 0 && tagLabel.includes(q)) {
      return true
    }
    return false
  }

  static async buildMonthlyReviewText(): Promise<string> {
    const stats = await YdLocalStore.computeReviewStats()
    const lines: string[] = []
    lines.push('【跃动新章 · 本月回顾】')
    lines.push(`本月完成 ${stats.monthDone} 步`)
    lines.push(`工作 ${stats.workMin} 分 / 学习 ${stats.studyMin} 分 / 生活 ${stats.lifeMin} 分`)
    lines.push(`连续 ${stats.streakDays} 天 · 跃动指数 ${stats.leapIndex}`)
    lines.push(`已收官篇章 ${stats.chapterClosed} 篇`)
    return lines.join('\n')
  }

  static async buildYearlyReviewText(): Promise<string> {
    const tasks = await YdLocalStore.loadAllTasks()
    let done = 0
    for (const t of tasks) {
      if (t.done) {
        done++
      }
    }
    const stats = await YdLocalStore.computeReviewStats()
    const lines: string[] = []
    lines.push('【跃动新章 · 年度成长摘要】')
    lines.push(`累计任务 ${tasks.length} 项 · 已完成 ${done} 项`)
    lines.push(`跃动指数 ${stats.leapIndex} · 连续 ${stats.streakDays} 天`)
    lines.push(`收官篇章 ${stats.chapterClosed} 篇 · 收藏 ${(await YdLocalStore.loadFavorites()).length} 条`)
    lines.push(`打卡 ${(await YdLocalStore.loadAllCheckIns()).length} 天`)
    return lines.join('\n')
  }

  static async countDailyNotes(): Promise<number> {
    const raw = await YdLocalStore.getString(KEY_DAILY_NOTES, '')
    let n = 0
    for (const line of raw.split('\n')) {
      if (line.trim().length > 0) {
        n++
      }
    }
    return n
  }

  private static async persistFavorites(items: YdFavoriteRef[]): Promise<void> {
    const lines: string[] = []
    for (const f of items) {
      const esc = (s: string): string => s.replace(/\|/g, '/').replace(/\n/g, ' ')
      lines.push(`${esc(f.id)}|${esc(f.entityType)}|${esc(f.entityId)}|${esc(f.title)}|${f.createdAt}`)
    }
    await YdLocalStore.putString(KEY_FAVORITES, lines.join('\n'))
  }

  private static async persistCheckIns(items: YdCheckIn[]): Promise<void> {
    const lines: string[] = []
    for (const c of items) {
      const esc = c.note.replace(/\n/g, '¶').replace(/\t/g, ' ')
      lines.push(`${c.dateKey}\t${esc}\t${c.createdAt}`)
    }
    await YdLocalStore.putString(KEY_CHECKINS, lines.join('\n'))
  }

  private static async persistTags(items: YdTag[]): Promise<void> {
    const lines: string[] = []
    for (const t of items) {
      lines.push(`${t.id}|${t.label}|${t.colorKey}`)
    }
    await YdLocalStore.putString(KEY_TAGS, lines.join('\n'))
  }

  static async clearAllData(): Promise<void> {
    await YdLocalStore.putString(KEY_TASKS, '')
    await YdLocalStore.putString(KEY_GOALS, '')
    await YdLocalStore.putString(KEY_CHAPTERS, '')
    await YdLocalStore.putString(KEY_DAILY_NOTES, '')
    await YdLocalStore.putString(KEY_FAVORITES, '')
    await YdLocalStore.putString(KEY_CHECKINS, '')
    await YdLocalStore.putString(KEY_TAGS, '')
    await YdLocalStore.putString(KEY_ENTITY_TAGS, '')
    await YdLocalStore.putString(KEY_STREAK, '0')
    await YdLocalStore.putString(KEY_LAST_ACTIVE, '')
  }

  static async loadAllChapters(): Promise<YdChapterItem[]> {
    const raw = await YdLocalStore.getString(KEY_CHAPTERS, '')
    return YdLocalStore.parseChapters(raw)
  }

  static async findActiveChapter(): Promise<YdChapterItem | undefined> {
    const list = await YdLocalStore.loadAllChapters()
    for (const c of list) {
      if (!c.closed) {
        return c
      }
    }
    return undefined
  }

  static async findChapter(id: string): Promise<YdChapterItem | undefined> {
    const list = await YdLocalStore.loadAllChapters()
    for (const c of list) {
      if (c.id === id) {
        return c
      }
    }
    return undefined
  }

  static async createChapter(title: string, theme: string, days: number): Promise<string> {
    const open = await YdLocalStore.findActiveChapter()
    if (open !== undefined) {
      return '请先为进行中的篇章写复盘并收官'
    }
    const t = title.trim()
    if (t.length < 2) {
      return '请填写篇章标题'
    }
    const c = new YdChapterItem()
    c.id = YdChapterItem.newId()
    c.title = t
    c.theme = theme
    c.startKey = YdTaskItem.todayKey()
    c.endKey = YdLocalStore.offsetDateKey(c.startKey, days)
    c.createdAt = Date.now()
    const list = await YdLocalStore.loadAllChapters()
    list.push(c)
    await YdLocalStore.persistChapters(list)
    return ''
  }

  static async closeChapter(id: string, recap: string): Promise<string> {
    const text = recap.trim()
    if (text.length < 20) {
      return '章末复盘至少写 20 字，才能收官这一章'
    }
    const list = await YdLocalStore.loadAllChapters()
    const next: YdChapterItem[] = []
    for (const c of list) {
      if (c.id === id) {
        c.recap = text
        c.closed = true
      }
      next.push(c)
    }
    await YdLocalStore.persistChapters(next)
    await YdLocalStore.touchStreak()
    return ''
  }

  static async saveChapterRecap(id: string, recap: string): Promise<void> {
    const list = await YdLocalStore.loadAllChapters()
    const next: YdChapterItem[] = []
    for (const c of list) {
      if (c.id === id) {
        c.recap = recap
      }
      next.push(c)
    }
    await YdLocalStore.persistChapters(next)
  }

  static async deleteChapter(id: string): Promise<void> {
    const list = await YdLocalStore.loadAllChapters()
    const next: YdChapterItem[] = []
    for (const c of list) {
      if (c.id !== id) {
        next.push(c)
      }
    }
    await YdLocalStore.persistChapters(next)
  }

  static exportChapterText(c: YdChapterItem): string {
    return `《${c.title}》\n主题：${c.themeLabel()}\n周期：${c.startKey} ~ ${c.endKey}\n\n章末复盘：\n${c.recap}`
  }

  private static async touchStreak(): Promise<void> {
    const today = YdTaskItem.todayKey()
    const last = await YdLocalStore.getString(KEY_LAST_ACTIVE, '')
    let streak = await YdLocalStore.getStreak()
    if (last === today) {
      return
    }
    const yesterday = YdLocalStore.offsetDateKey(today, -1)
    if (last === yesterday) {
      streak++
    } else {
      streak = 1
    }
    await YdLocalStore.putString(KEY_STREAK, `${streak}`)
    await YdLocalStore.putString(KEY_LAST_ACTIVE, today)
  }

  private static dateKeyToMs(key: string): number {
    const parts = key.split('-')
    if (parts.length !== 3) {
      return 0
    }
    const y = parseInt(parts[0], 10)
    const m = parseInt(parts[1], 10) - 1
    const d = parseInt(parts[2], 10)
    if (Number.isNaN(y) || Number.isNaN(m) || Number.isNaN(d)) {
      return 0
    }
    return new Date(y, m, d).getTime()
  }

  private static isDateKeyWithinDays(key: string, days: number): boolean {
    const ms = YdLocalStore.dateKeyToMs(key)
    if (ms === 0) {
      return false
    }
    const start = new Date()
    start.setHours(0, 0, 0, 0)
    start.setDate(start.getDate() - (days - 1))
    return ms >= start.getTime()
  }

  private static async getStreak(): Promise<number> {
    const raw = await YdLocalStore.getString(KEY_STREAK, '0')
    const n = parseInt(raw, 10)
    return Number.isNaN(n) ? 0 : n
  }

  private static offsetDateKey(key: string, deltaDays: number): string {
    const parts = key.split('-')
    if (parts.length !== 3) {
      return key
    }
    const y = parseInt(parts[0], 10)
    const m = parseInt(parts[1], 10) - 1
    const d = parseInt(parts[2], 10)
    const dt = new Date(y, m, d)
    dt.setDate(dt.getDate() + deltaDays)
    const ny = dt.getFullYear()
    const nm = dt.getMonth() + 1
    const nd = dt.getDate()
    const ms = nm < 10 ? `0${nm}` : `${nm}`
    const ds = nd < 10 ? `0${nd}` : `${nd}`
    return `${ny}-${ms}-${ds}`
  }

  private static sortTasks(items: YdTaskItem[]): YdTaskItem[] {
    const copy: YdTaskItem[] = []
    for (const it of items) {
      copy.push(it)
    }
    copy.sort((a, b) => {
      if (a.done !== b.done) {
        return a.done ? 1 : -1
      }
      const pa = a.priority === 'high' ? 0 : a.priority === 'medium' ? 1 : 2
      const pb = b.priority === 'high' ? 0 : b.priority === 'medium' ? 1 : 2
      if (pa !== pb) {
        return pa - pb
      }
      if (a.timeSlot.length > 0 && b.timeSlot.length > 0 && a.timeSlot !== b.timeSlot) {
        return a.timeSlot < b.timeSlot ? -1 : 1
      }
      return b.createdAt - a.createdAt
    })
    return copy
  }

  private static async persistTasks(items: YdTaskItem[]): Promise<void> {
    const lines: string[] = []
    for (const it of items) {
      lines.push(YdLocalStore.serializeTask(it))
    }
    await YdLocalStore.putString(KEY_TASKS, lines.join('\n'))
  }

  private static serializeTask(t: YdTaskItem): string {
    const esc = (s: string): string => s.replace(/\|/g, '/').replace(/\n/g, ' ')
    return `${esc(t.id)}|${esc(t.title)}|${esc(t.timeSlot)}|${esc(t.priority)}|${t.done ? '1' : '0'}|${esc(t.dateKey)}|${t.createdAt}|${esc(t.domain)}|${t.durationMin}|${esc(t.note)}`
  }

  private static parseTasks(raw: string): YdTaskItem[] {
    if (raw.trim().length === 0) {
      return []
    }
    const out: YdTaskItem[] = []
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.trim().length === 0) {
        continue
      }
      const p = line.split('|')
      if (p.length < 7) {
        continue
      }
      const t = new YdTaskItem()
      t.id = p[0]
      t.title = p[1]
      t.timeSlot = p[2]
      t.priority = p[3]
      t.done = p[4] === '1'
      t.dateKey = p[5]
      t.createdAt = parseInt(p[6], 10)
      if (p.length >= 8) {
        t.domain = p[7]
      }
      if (p.length >= 9) {
        t.durationMin = parseInt(p[8], 10)
        if (Number.isNaN(t.durationMin)) {
          t.durationMin = 30
        }
      }
      if (p.length >= 10) {
        t.note = p[9]
      }
      out.push(t)
    }
    return out
  }

  private static async persistGoals(items: YdGoalItem[]): Promise<void> {
    const lines: string[] = []
    for (const g of items) {
      lines.push(YdLocalStore.serializeGoal(g))
    }
    await YdLocalStore.putString(KEY_GOALS, lines.join('\n'))
  }

  private static serializeGoal(g: YdGoalItem): string {
    const esc = (s: string): string => s.replace(/\|/g, '/').replace(/\n/g, ' ')
    const ms: string[] = []
    for (const m of g.milestones) {
      ms.push(`${esc(m.id)}~${esc(m.title)}~${m.done ? '1' : '0'}`)
    }
    return `${esc(g.id)}|${esc(g.title)}|${esc(g.summary)}|${g.archived ? '1' : '0'}|${g.createdAt}|${ms.join(',')}`
  }

  private static parseGoals(raw: string): YdGoalItem[] {
    if (raw.trim().length === 0) {
      return []
    }
    const out: YdGoalItem[] = []
    for (const line of raw.split('\n')) {
      if (line.trim().length === 0) {
        continue
      }
      const p = line.split('|')
      if (p.length < 5) {
        continue
      }
      const g = new YdGoalItem()
      g.id = p[0]
      g.title = p[1]
      g.summary = p[2]
      g.archived = p[3] === '1'
      g.createdAt = parseInt(p[4], 10)
      g.milestones = []
      if (p.length >= 6 && p[5].length > 0) {
        for (const chunk of p[5].split(',')) {
          const mp = chunk.split('~')
          if (mp.length >= 3) {
            const m = new YdMilestoneItem()
            m.id = mp[0]
            m.title = mp[1]
            m.done = mp[2] === '1'
            g.milestones.push(m)
          }
        }
      }
      out.push(g)
    }
    return out
  }

  private static async persistChapters(items: YdChapterItem[]): Promise<void> {
    const lines: string[] = []
    for (const c of items) {
      lines.push(YdLocalStore.serializeChapter(c))
    }
    await YdLocalStore.putString(KEY_CHAPTERS, lines.join('\n'))
  }

  private static serializeChapter(c: YdChapterItem): string {
    const esc = (s: string): string => s.replace(/\|/g, '/').replace(/\n/g, '¶')
    return `${esc(c.id)}|${esc(c.title)}|${esc(c.theme)}|${esc(c.startKey)}|${esc(c.endKey)}|${c.closed ? '1' : '0'}|${c.createdAt}|${esc(c.recap)}`
  }

  private static parseChapters(raw: string): YdChapterItem[] {
    if (raw.trim().length === 0) {
      return []
    }
    const out: YdChapterItem[] = []
    for (const line of raw.split('\n')) {
      if (line.trim().length === 0) {
        continue
      }
      const p = line.split('|')
      if (p.length < 7) {
        continue
      }
      const c = new YdChapterItem()
      c.id = p[0]
      c.title = p[1]
      c.theme = p[2]
      c.startKey = p[3]
      c.endKey = p[4]
      c.closed = p[5] === '1'
      c.createdAt = parseInt(p[6], 10)
      if (p.length >= 8) {
        c.recap = p[7].replace(/¶/g, '\n')
      }
      out.push(c)
    }
    return out
  }

  private static async getString(key: string, def: string): Promise<string> {
    if (YdLocalStore.pref === null) {
      return def
    }
    try {
      const v = await YdLocalStore.pref.get(key, def)
      return `${v}`
    } catch {
      return def
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (YdLocalStore.pref === null) {
      return
    }
    try {
      await YdLocalStore.pref.put(key, value)
      await YdLocalStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
