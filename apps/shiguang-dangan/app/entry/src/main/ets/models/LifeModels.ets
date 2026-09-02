export class LifePlan {
  id: string = ''
  title: string = ''
  planType: string = 'week'
  startDate: string = ''
  endDate: string = ''
  status: string = 'active'
  createdAt: number = 0
  isFavorite: boolean = false

  static createNew(title: string): LifePlan {
    const p = new LifePlan()
    p.id = `plan_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    p.title = title
    p.planType = 'week'
    p.startDate = ''
    p.endDate = ''
    p.status = 'active'
    p.createdAt = Date.now()
    return p
  }
}

export class PlanTask {
  id: string = ''
  planId: string = ''
  title: string = ''
  done: boolean = false
  sortOrder: number = 0

  static createNew(planId: string, title: string): PlanTask {
    const t = new PlanTask()
    t.id = `ptask_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    t.planId = planId
    t.title = title
    t.done = false
    t.sortOrder = 0
    return t
  }
}

export class HabitItem {
  id: string = ''
  name: string = ''
  createdAt: number = 0

  static createNew(name: string): HabitItem {
    const h = new HabitItem()
    h.id = `habit_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    h.name = name
    h.createdAt = Date.now()
    return h
  }
}

export class GoalItem {
  id: string = ''
  title: string = ''
  targetLabel: string = ''
  currentNum: number = 0
  targetNum: number = 1
  unit: string = ''
  startDate: string = ''
  endDate: string = ''
  status: string = 'active'
  createdAt: number = 0

  static createNew(title: string): GoalItem {
    const g = new GoalItem()
    g.id = `goal_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    g.title = title
    g.targetLabel = ''
    g.currentNum = 0
    g.targetNum = 1
    g.unit = ''
    g.startDate = ''
    g.endDate = ''
    g.status = 'active'
    g.createdAt = Date.now()
    return g
  }

  progressPercent(): number {
    if (this.targetNum <= 0) {
      return 0
    }
    const pct = Math.round((this.currentNum / this.targetNum) * 100)
    return pct > 100 ? 100 : pct
  }
}

export class ImportantMoment {
  id: string = ''
  title: string = ''
  dateKey: string = ''
  description: string = ''
  category: string = '纪念'
  useCountdown: boolean = false
  done: boolean = false
  createdAt: number = 0
  isFavorite: boolean = false

  static createNew(title: string, dateKey: string): ImportantMoment {
    const m = new ImportantMoment()
    m.id = `moment_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    m.title = title
    m.dateKey = dateKey
    m.description = ''
    m.category = '纪念'
    m.useCountdown = true
    m.done = false
    m.createdAt = Date.now()
    return m
  }
}

export class InspirationItem {
  id: string = ''
  text: string = ''
  categoryKey: string = 'idea'
  status: string = 'idea'
  tags: string[] = []
  createdAt: number = 0
  isFavorite: boolean = false

  static createNew(text: string): InspirationItem {
    const i = new InspirationItem()
    i.id = `insp_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    i.text = text
    i.categoryKey = 'idea'
    i.status = 'idea'
    i.tags = []
    i.createdAt = Date.now()
    return i
  }
}

export class ThemeAlbum {
  id: string = ''
  title: string = ''
  summary: string = ''
  coverTone: string = 'warm'
  itemRefs: string = ''

  static createNew(title: string): ThemeAlbum {
    const a = new ThemeAlbum()
    a.id = `album_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    a.title = title
    a.summary = ''
    a.coverTone = 'warm'
    a.itemRefs = ''
    return a
  }

  refList(): string[] {
    if (this.itemRefs.length === 0) {
      return []
    }
    const parts = this.itemRefs.split(',')
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }
}

export class ChecklistItem {
  id: string = ''
  category: string = 'want_done'
  title: string = ''
  status: string = 'pending'

  static createNew(title: string, category: string): ChecklistItem {
    const c = new ChecklistItem()
    c.id = `chk_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    c.category = category
    c.title = title
    c.status = 'pending'
    return c
  }

  static categoryLabel(key: string): string {
    if (key === 'want_done') {
      return '想完成'
    }
    if (key === 'want_learn') {
      return '想学'
    }
    if (key === 'want_go') {
      return '想去'
    }
    if (key === 'want_try') {
      return '想试'
    }
    if (key === 'want_change') {
      return '想改变'
    }
    if (key === 'want_collect') {
      return '想收藏'
    }
    return key
  }

  static allCategories(): string[] {
    return ['want_done', 'want_learn', 'want_go', 'want_try', 'want_change', 'want_collect']
  }
}

export class ExperienceEntry {
  id: string = ''
  question: string = ''
  method: string = ''
  result: string = ''
  note: string = ''
  createdAt: number = 0

  static createNew(question: string): ExperienceEntry {
    const e = new ExperienceEntry()
    e.id = `exp_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    e.question = question
    e.method = ''
    e.result = ''
    e.note = ''
    e.createdAt = Date.now()
    return e
  }
}

export class FavoriteFolder {
  id: string = ''
  name: string = ''

  static createNew(name: string): FavoriteFolder {
    const f = new FavoriteFolder()
    f.id = `ff_${Date.now()}_${Math.floor(Math.random() * 10000)}`
    f.name = name
    return f
  }
}

export class WeeklyActivityBar {
  label: string = ''
  count: number = 0

  static make(label: string, count: number): WeeklyActivityBar {
    const w = new WeeklyActivityBar()
    w.label = label
    w.count = count
    return w
  }
}

export class PlanProgress {
  done: number = 0
  total: number = 0

  static make(done: number, total: number): PlanProgress {
    const p = new PlanProgress()
    p.done = done
    p.total = total
    return p
  }
}

export class DashboardSummary {
  streakDays: number = 0
  todayPlanDone: number = 0
  todayPlanTotal: number = 0
  favoriteCount: number = 0
  achievementUnlocked: number = 0
  achievementTotal: number = 0
  onThisDayTitle: string = ''
  onThisDayBody: string = ''
}

export class AchievementDef {
  id: string = ''
  title: string = ''
  description: string = ''
  emoji: string = ''

  static make(id: string, title: string, desc: string, emoji: string): AchievementDef {
    const a = new AchievementDef()
    a.id = id
    a.title = title
    a.description = desc
    a.emoji = emoji
    return a
  }

  static catalog(): AchievementDef[] {
    const out: AchievementDef[] = []
    out.push(AchievementDef.make('first_archive', '第一份档案', '创建第一份人生档案', '📁'))
    out.push(AchievementDef.make('first_node', '首个节点', '添加第一个时间节点', '📍'))
    out.push(AchievementDef.make('streak_7', '连续7天', '连续7天有记录', '🔥'))
    out.push(AchievementDef.make('streak_30', '连续30天', '连续30天有记录', '⭐'))
    out.push(AchievementDef.make('plans_5', '计划达人', '完成5项计划任务', '✅'))
    out.push(AchievementDef.make('habit_7', '习惯一周', '同一习惯连续打卡7天', '🌱'))
    out.push(AchievementDef.make('fav_10', '收藏十件', '收藏10条内容', '💛'))
    out.push(AchievementDef.make('archive_10', '档案十份', '累计10份档案', '🗂️'))
    out.push(AchievementDef.make('theme_album_1', '第一本主题册', '创建第一本主题册', '📚'))
    out.push(AchievementDef.make('checklist_5', '清单五件', '人生清单完成5项', '☑️'))
    out.push(AchievementDef.make('experience_3', '经验三条', '经验库积累3条', '💡'))
    return out
  }
}
