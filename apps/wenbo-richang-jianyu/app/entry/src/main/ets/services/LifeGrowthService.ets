import { JournalItem } from '../models/JournalModels'
import {
  AchievementBadge,
  ActivityEvent,
  DeskSnapshot,
  HomeTaskRow,
  PeriodReview,
  PlanItem,
  SearchHit
} from '../models/LifeGrowthModels'
import { GoalItem, HabitItem, LifeDates, MoodEntry, TodoItem, DayCount } from '../models/LifeHubModels'
import { JournalBizService } from './JournalBizService'
import { LifeGrowthStore } from './LifeGrowthStore'
import { LifeHubStore } from './LifeHubStore'

class MoodName {
  static label(id: string): string {
    if (id === 'calm') {
      return '平静'
    }
    if (id === 'joy') {
      return '愉快'
    }
    if (id === 'tired') {
      return '疲惫'
    }
    if (id === 'down') {
      return '低落'
    }
    if (id === 'focus') {
      return '专注'
    }
    return id.length > 0 ? id : '心情'
  }
}

/** 由真实笺语与生活数据计算笺台 / 回顾 / 成就 / 动态 / 搜索 */
export class LifeGrowthService {
  static async loadDesk(userId: string): Promise<DeskSnapshot> {
    const desk = new DeskSnapshot()
    if (userId.length === 0) {
      return desk
    }
    const today = LifeDates.todayIso()
    const diaries = await JournalBizService.cachedDiaries(userId)
    const remoteNeed = diaries.length === 0
    const allDiaries = remoteNeed ? await JournalBizService.loadDiaries(userId) : diaries
    const moods = await LifeHubStore.loadMoods()
    const todos = await LifeHubStore.loadTodos()
    const habits = await LifeHubStore.loadHabits()
    const plans = await LifeGrowthStore.loadPlans()
    const goals = await LifeHubStore.loadGoals()
    const topics = await LifeGrowthStore.loadTopics()
    const favs = await JournalBizService.loadFavorites(userId)
    const badges = LifeGrowthService.evaluate(allDiaries, moods, todos, habits, goals, plans, favs.length, topics.length)

    desk.diaryCount = allDiaries.length
    desk.favoriteCount = favs.length
    desk.unlockedCount = LifeGrowthService.unlockedOf(badges)
    desk.badgeTotal = badges.length
    desk.streakDays = LifeGrowthService.maxStreak(habits)

    let todayDiary: JournalItem | undefined = undefined
    for (const d of allDiaries) {
      if (d.recordDate === today) {
        todayDiary = d
        break
      }
    }
    desk.diaryDone = todayDiary !== undefined
    if (todayDiary !== undefined) {
      desk.diaryTitle = todayDiary.title.length > 0 ? todayDiary.title : '已有一页今日记录'
      if (todayDiary.coverKey.length > 0) {
        desk.coverKey = todayDiary.coverKey
      }
    }

    let todayMood: MoodEntry | undefined = undefined
    for (const m of moods) {
      if (m.date === today) {
        todayMood = m
        break
      }
    }
    desk.moodDone = todayMood !== undefined
    desk.moodLabel = todayMood !== undefined ? MoodName.label(todayMood.moodId) : '尚未记录心情'

    desk.habitTotal = habits.length
    const tasks: HomeTaskRow[] = []
    for (const h of habits) {
      const checked = h.checkedOn(today)
      if (checked) {
        desk.habitDone += 1
      }
      tasks.push(HomeTaskRow.of(h.id, 'habit', h.title, checked, `连续 ${h.streak()} 天`))
    }

    let todoDoneAll = 0
    for (const t of todos) {
      if (t.done) {
        todoDoneAll += 1
      }
      const todayRow = t.date === today || (t.date.length === 0 && !t.done)
      if (todayRow || t.date === today) {
        desk.todoTotal += 1
        if (t.done) {
          desk.todoDone += 1
        }
        tasks.push(HomeTaskRow.of(t.id, 'todo', t.title, t.done, LifeGrowthService.todoCat(t.category)))
      }
    }
    desk.doneCount = todoDoneAll
    desk.tasks = tasks

    const active = LifeGrowthService.firstActivePlan(plans)
    if (active !== undefined) {
      desk.planTotal = active.tasks.length
      desk.planDone = active.doneCount()
    }

    let slots = 2
    let doneSlots = 0
    if (desk.moodDone) {
      doneSlots += 1
    }
    if (desk.diaryDone) {
      doneSlots += 1
    }
    if (desk.habitTotal > 0) {
      slots += desk.habitTotal
      doneSlots += desk.habitDone
    }
    if (desk.todoTotal > 0) {
      slots += desk.todoTotal
      doneSlots += desk.todoDone
    }
    if (desk.planTotal > 0) {
      slots += desk.planTotal
      doneSlots += desk.planDone
    }
    desk.progressPct = slots > 0 ? Math.floor(doneSlots * 100 / slots) : 0
    desk.progressHint = `已完成 ${doneSlots} / ${slots}`
    desk.recentActs = LifeGrowthService.takeActs(
      LifeGrowthService.buildActivities(allDiaries, moods, todos, habits, plans), 4)
    return desk
  }

  static async loadBadges(userId: string): Promise<AchievementBadge[]> {
    if (userId.length === 0) {
      return LifeGrowthService.evaluate([], [], [], [], [], [], 0, 0)
    }
    const diaries = await JournalBizService.loadDiaries(userId)
    const moods = await LifeHubStore.loadMoods()
    const todos = await LifeHubStore.loadTodos()
    const habits = await LifeHubStore.loadHabits()
    const goals = await LifeHubStore.loadGoals()
    const plans = await LifeGrowthStore.loadPlans()
    const favs = await JournalBizService.loadFavorites(userId)
    const topics = await LifeGrowthStore.loadTopics()
    return LifeGrowthService.evaluate(diaries, moods, todos, habits, goals, plans, favs.length, topics.length)
  }

  static async loadActivities(userId: string): Promise<ActivityEvent[]> {
    if (userId.length === 0) {
      return []
    }
    const diaries = await JournalBizService.loadDiaries(userId)
    const moods = await LifeHubStore.loadMoods()
    const todos = await LifeHubStore.loadTodos()
    const habits = await LifeHubStore.loadHabits()
    const plans = await LifeGrowthStore.loadPlans()
    return LifeGrowthService.buildActivities(diaries, moods, todos, habits, plans)
  }

  static async loadWeekReview(userId: string): Promise<PeriodReview> {
    return LifeGrowthService.loadPeriod(userId, LifeDates.weekStartIso(), LifeDates.todayIso(), '本周回顾')
  }

  static async loadMonthReview(userId: string): Promise<PeriodReview> {
    const today = LifeDates.todayIso()
    return LifeGrowthService.loadPeriod(userId, `${today.substring(0, 7)}-01`, today, '本月回顾')
  }

  static async searchAll(userId: string, query: string, kind: string, tag: string): Promise<SearchHit[]> {
    const q = query.trim()
    const out: SearchHit[] = []
    if (userId.length === 0) {
      return out
    }
    const diaries = await JournalBizService.loadDiaries(userId)
    const todos = await LifeHubStore.loadTodos()
    const habits = await LifeHubStore.loadHabits()
    const plans = await LifeGrowthStore.loadPlans()
    const favs = await JournalBizService.loadFavorites(userId)
    if (kind.length === 0 || kind === 'diary') {
      for (const d of diaries) {
        if (LifeGrowthService.hitText(q, d.title, d.summary, d.body) && LifeGrowthService.hitTag(tag, d.tags)) {
          out.push(SearchHit.of(`d_${d.id}`, 'diary', d.title.length > 0 ? d.title : '无题笺语', d.recordDate, d.id))
        }
      }
    }
    if (kind.length === 0 || kind === 'todo') {
      for (const t of todos) {
        if (LifeGrowthService.hitText(q, t.title, t.category, '') && (tag.length === 0 || t.category === tag)) {
          out.push(SearchHit.of(`t_${t.id}`, 'todo', t.title, t.done ? '已完成' : '待完成', t.id))
        }
      }
    }
    if (kind.length === 0 || kind === 'habit') {
      for (const h of habits) {
        if (LifeGrowthService.hitText(q, h.title, '', '')) {
          out.push(SearchHit.of(`h_${h.id}`, 'habit', h.title, `连续 ${h.streak()} 天`, h.id))
        }
      }
    }
    if (kind.length === 0 || kind === 'plan') {
      for (const p of plans) {
        if (LifeGrowthService.hitText(q, p.title, p.note, '')) {
          out.push(SearchHit.of(`p_${p.id}`, 'plan', p.title, `${p.progressPct()}% · ${p.cycle}`, p.id))
        }
      }
    }
    if (kind.length === 0 || kind === 'fav') {
      for (const f of favs) {
        if (LifeGrowthService.hitText(q, f.title, f.content, f.summary)) {
          out.push(SearchHit.of(`f_${f.id}`, 'fav', f.title, '语句收藏', f.id))
        }
      }
    }
    return out
  }

  static evaluate(
    diaries: JournalItem[],
    moods: MoodEntry[],
    todos: TodoItem[],
    habits: HabitItem[],
    goals: GoalItem[],
    plans: PlanItem[],
    favCount: number,
    topicCount: number
  ): AchievementBadge[] {
    const today = LifeDates.todayIso()
    const weekStart = LifeDates.weekStartIso()
    let doneTodos = 0
    let weekTodo = 0
    for (const t of todos) {
      if (t.done) {
        doneTodos += 1
        if (LifeDates.inRange(t.date, weekStart, today)) {
          weekTodo += 1
        }
      }
    }
    let checkins = 0
    let weekHabit = 0
    for (const h of habits) {
      for (const d of h.checkins) {
        checkins += 1
        if (LifeDates.inRange(d, weekStart, today)) {
          weekHabit += 1
        }
      }
    }
    let weekDiary = 0
    for (const d of diaries) {
      if (LifeDates.inRange(d.recordDate, weekStart, today)) {
        weekDiary += 1
      }
    }
    let weekMood = 0
    for (const m of moods) {
      if (LifeDates.inRange(m.date, weekStart, today)) {
        weekMood += 1
      }
    }
    let goalDone = false
    for (const g of goals) {
      if (g.status === 'done' || g.progress >= 100) {
        goalDone = true
      }
    }
    const streak = LifeGrowthService.maxStreak(habits)
    const out: AchievementBadge[] = []
    out.push(LifeGrowthService.badge('first_page', '初笺', '写下第一页', diaries.length >= 1, `已写 ${diaries.length} 页`))
    out.push(LifeGrowthService.badge('week_writer', '七日笺', '累计 7 页', diaries.length >= 7, `已写 ${diaries.length} 页`))
    out.push(LifeGrowthService.badge('month_writer', '满月笺', '累计 30 页', diaries.length >= 30, `已写 ${diaries.length} 页`))
    out.push(LifeGrowthService.badge('mood_7', '心情轨迹', '记录 7 天心情', moods.length >= 7, `已记 ${moods.length} 天`))
    out.push(LifeGrowthService.badge('streak_3', '三日不断', '习惯连续 3 天', streak >= 3, `最长 ${streak} 天`))
    out.push(LifeGrowthService.badge('streak_7', '一周坚持', '习惯连续 7 天', streak >= 7, `最长 ${streak} 天`))
    out.push(LifeGrowthService.badge('streak_30', '月度自律', '习惯连续 30 天', streak >= 30, `最长 ${streak} 天`))
    out.push(LifeGrowthService.badge('todo_10', '清单达人', '完成 10 件待办', doneTodos >= 10, `已完成 ${doneTodos} 件`))
    out.push(LifeGrowthService.badge('goal_done', '目标达成', '完成一个生活目标', goalDone, goalDone ? '已点亮' : '尚未完成'))
    out.push(LifeGrowthService.badge('favorite_5', '收藏家', '收藏 5 条语句', favCount >= 5, `已藏 ${favCount} 条`))
    out.push(LifeGrowthService.badge('checkin_10', '打卡达人', '累计打卡 10 次', checkins >= 10, `已打卡 ${checkins} 次`))
    out.push(LifeGrowthService.badge('plan_first', '有计划的人', '创建第一个生活计划', plans.length >= 1, `计划 ${plans.length} 个`))
    out.push(LifeGrowthService.badge('topic_first', '专题作者', '创建第一个生活专题', topicCount >= 1, `专题 ${topicCount} 个`))
    out.push(LifeGrowthService.badge('week_full', '完整的一周', '本周同时有笺语、心情、打卡与待办',
      weekDiary > 0 && weekMood > 0 && weekHabit > 0 && weekTodo > 0, '四件事都做过才点亮'))
    return out
  }

  private static async loadPeriod(userId: string, start: string, end: string, title: string): Promise<PeriodReview> {
    const row = new PeriodReview()
    row.title = title
    if (userId.length === 0) {
      row.summary = '登录后，这里会用你自己的记录写成回顾。'
      return row
    }
    let diaries = await JournalBizService.cachedDiaries(userId)
    if (diaries.length === 0) {
      diaries = await JournalBizService.loadDiaries(userId)
    }
    const moods = await LifeHubStore.loadMoods()
    const todos = await LifeHubStore.loadTodos()
    const habits = await LifeHubStore.loadHabits()
    for (const d of diaries) {
      if (LifeDates.inRange(d.recordDate, start, end)) {
        row.diaryCount += 1
      }
    }
    for (const m of moods) {
      if (LifeDates.inRange(m.date, start, end)) {
        row.moodCount += 1
      }
    }
    for (const t of todos) {
      if (t.done && LifeDates.inRange(t.date, start, end)) {
        row.todoDone += 1
      }
    }
    for (const h of habits) {
      for (const d of h.checkins) {
        if (LifeDates.inRange(d, start, end)) {
          row.habitHits += 1
        }
      }
    }
    if (row.diaryCount + row.moodCount + row.habitHits + row.todoDone === 0) {
      row.summary = '这段日子还是空白。写一页、记个心情，回顾就会慢慢长出来。'
    } else {
      row.summary = `这段时间写下 ${row.diaryCount} 页笺语，记录 ${row.moodCount} 天心情，` +
        `打卡 ${row.habitHits} 次，完成 ${row.todoDone} 件待办。`
    }
    return row
  }

  static buildActivities(
    diaries: JournalItem[],
    moods: MoodEntry[],
    todos: TodoItem[],
    habits: HabitItem[],
    plans: PlanItem[]
  ): ActivityEvent[] {
    const out: ActivityEvent[] = []
    for (const d of diaries) {
      out.push(ActivityEvent.of(`diary_${d.id}`, 'diary',
        d.title.length > 0 ? `写下「${d.title}」` : '写下新的一页', d.recordDate, d.id))
    }
    for (const m of moods) {
      out.push(ActivityEvent.of(`mood_${m.id}`, 'mood', `心情 · ${MoodName.label(m.moodId)}`, m.date, m.id))
    }
    for (const t of todos) {
      if (t.done) {
        out.push(ActivityEvent.of(`todo_${t.id}`, 'todo', `完成待办「${t.title}」`, t.date, t.id))
      }
    }
    for (const h of habits) {
      for (const d of h.checkins) {
        out.push(ActivityEvent.of(`habit_${h.id}_${d}`, 'habit', `打卡「${h.title}」`, d, h.id))
      }
    }
    for (const p of plans) {
      if (p.status === 'done') {
        out.push(ActivityEvent.of(`plan_${p.id}`, 'plan', `完成计划「${p.title}」`, p.endDate, p.id))
      }
    }
    out.sort((a: ActivityEvent, b: ActivityEvent) => {
      if (a.date === b.date) {
        return 0
      }
      return a.date < b.date ? 1 : -1
    })
    return out
  }

  private static takeActs(list: ActivityEvent[], n: number): ActivityEvent[] {
    const out: ActivityEvent[] = []
    for (const row of list) {
      if (out.length < n) {
        out.push(row)
      }
    }
    return out
  }

  private static firstActivePlan(plans: PlanItem[]): PlanItem | undefined {
    for (const p of plans) {
      if (p.status !== 'done') {
        return p
      }
    }
    if (plans.length > 0) {
      return plans[0]
    }
    return undefined
  }

  private static maxStreak(habits: HabitItem[]): number {
    let max = 0
    for (const h of habits) {
      const s = h.streak()
      if (s > max) {
        max = s
      }
    }
    return max
  }

  private static unlockedOf(badges: AchievementBadge[]): number {
    let n = 0
    for (const b of badges) {
      if (b.unlocked) {
        n += 1
      }
    }
    return n
  }

  static async loadActivePlans(userId: string, limit: number = 2): Promise<PlanItem[]> {
    if (userId.length === 0) {
      return []
    }
    const all = await LifeGrowthStore.loadPlans()
    const out: PlanItem[] = []
    for (const p of all) {
      if (p.status !== 'done' && out.length < limit) {
        out.push(p)
      }
    }
    for (const p of all) {
      if (p.status === 'done' && out.length < limit) {
        out.push(p)
      }
    }
    return out
  }

  static async loadWeekTrend(userId: string): Promise<DayCount[]> {
    const out: DayCount[] = []
    let i = 6
    while (i >= 0) {
      const row = new DayCount()
      row.iso = LifeDates.shiftIso(LifeDates.todayIso(), -i)
      row.count = 0
      out.push(row)
      i -= 1
    }
    if (userId.length === 0) {
      return out
    }
    let list = await JournalBizService.cachedDiaries(userId)
    if (list.length === 0) {
      list = await JournalBizService.loadDiaries(userId)
    }
    for (const d of list) {
      const iso = d.recordDate.length >= 10 ? d.recordDate.substring(0, 10) : ''
      for (const row of out) {
        if (row.iso === iso) {
          row.count += 1
        }
      }
    }
    return out
  }

  private static badge(id: string, title: string, hint: string, unlocked: boolean, detail: string): AchievementBadge {
    return AchievementBadge.of(id, title, hint, unlocked, detail)
  }

  private static todoCat(id: string): string {
    if (id === 'work') {
      return '工作'
    }
    if (id === 'study') {
      return '学习'
    }
    return '生活'
  }

  private static hitText(q: string, a: string, b: string, c: string): boolean {
    if (q.length === 0) {
      return true
    }
    return a.indexOf(q) >= 0 || b.indexOf(q) >= 0 || c.indexOf(q) >= 0
  }

  private static hitTag(tag: string, tags: string[]): boolean {
    if (tag.length === 0) {
      return true
    }
    for (const t of tags) {
      if (t === tag) {
        return true
      }
    }
    return false
  }
}
