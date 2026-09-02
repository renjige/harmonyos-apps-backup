import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { CraftCheckIn, CraftPlan, CraftPlanTask, CraftLastGuide } from '../models/CraftLocalModels'

const TAG = 'CraftLocalStore'
const STORE = 'craft_local_v1'
const KEY_PLANS = 'plansRaw'
const KEY_CHECKINS = 'checkinsRaw'
const KEY_ACH = 'achievementsRaw'
const KEY_LAST_GUIDE = 'lastGuideRaw'

export class CraftLocalStore {
  private static pref: preferences.Preferences | null = null
  private static ready: boolean = false

  static isReady(): boolean {
    return CraftLocalStore.ready
  }

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      CraftLocalStore.pref = await preferences.getPreferences(context, STORE)
      const plans = await CraftLocalStore.pref.get(KEY_PLANS, '')
      const checkins = await CraftLocalStore.pref.get(KEY_CHECKINS, '')
      const ach = await CraftLocalStore.pref.get(KEY_ACH, '')
      const guide = await CraftLocalStore.pref.get(KEY_LAST_GUIDE, '')
      AppStorage.setOrCreate(KEY_PLANS, typeof plans === 'string' ? plans : '')
      AppStorage.setOrCreate(KEY_CHECKINS, typeof checkins === 'string' ? checkins : '')
      AppStorage.setOrCreate(KEY_ACH, typeof ach === 'string' ? ach : '')
      AppStorage.setOrCreate(KEY_LAST_GUIDE, typeof guide === 'string' ? guide : '')
      CraftLocalStore.ready = true
      hilog.info(0x0000, TAG, 'local craft data restored')
    } catch {
      AppStorage.setOrCreate(KEY_PLANS, '')
      AppStorage.setOrCreate(KEY_CHECKINS, '')
      AppStorage.setOrCreate(KEY_ACH, '')
      AppStorage.setOrCreate(KEY_LAST_GUIDE, '')
      CraftLocalStore.ready = true
    }
  }

  static bumpRefresh(): void {
    const v = AppStorage.get<number>('craftDataEpoch') ?? 0
    AppStorage.setOrCreate('craftDataEpoch', v + 1)
  }

  private static async persist(key: string, value: string): Promise<void> {
    AppStorage.setOrCreate(key, value)
    if (CraftLocalStore.pref === null) {
      return
    }
    await CraftLocalStore.pref.put(key, value)
    await CraftLocalStore.pref.flush()
  }

  static plans(): CraftPlan[] {
    const raw = AppStorage.get<string>(KEY_PLANS) ?? ''
    if (raw.length === 0) {
      return []
    }
    const planMap: Map<string, CraftPlan> = new Map()
    const rows = raw.split('\n')
    for (const row of rows) {
      if (row.startsWith('P|')) {
        const p = row.split('|')
        if (p.length < 6) {
          continue
        }
        const plan = new CraftPlan()
        plan.id = p[1]
        plan.title = p[2]
        plan.category = p[3]
        plan.targetCount = parseInt(p[4])
        plan.dueDate = p[5]
        plan.status = p.length > 6 ? p[6] : 'active'
        plan.tasks = []
        planMap.set(plan.id, plan)
      } else if (row.startsWith('T|')) {
        const t = row.split('|')
        if (t.length < 5) {
          continue
        }
        const task = new CraftPlanTask()
        task.id = t[2]
        task.title = t[3]
        task.done = t[4] === '1'
        task.sourceGuideId = t.length > 5 ? t[5] : ''
        const plan = planMap.get(t[1])
        if (plan !== undefined) {
          plan.tasks.push(task)
        }
      }
    }
    const out: CraftPlan[] = []
    planMap.forEach((plan: CraftPlan) => {
      if (plan.status === 'active') {
        out.push(plan)
      }
    })
    return out
  }

  static allPlansIncludingArchived(): CraftPlan[] {
    const raw = AppStorage.get<string>(KEY_PLANS) ?? ''
    const planMap: Map<string, CraftPlan> = new Map()
    const rows = raw.split('\n')
    for (const row of rows) {
      if (row.startsWith('P|')) {
        const p = row.split('|')
        if (p.length < 6) {
          continue
        }
        const plan = new CraftPlan()
        plan.id = p[1]
        plan.title = p[2]
        plan.category = p[3]
        plan.targetCount = parseInt(p[4])
        plan.dueDate = p[5]
        plan.status = p.length > 6 ? p[6] : 'active'
        plan.tasks = []
        planMap.set(plan.id, plan)
      } else if (row.startsWith('T|')) {
        const t = row.split('|')
        if (t.length < 5) {
          continue
        }
        const task = new CraftPlanTask()
        task.id = t[2]
        task.title = t[3]
        task.done = t[4] === '1'
        task.sourceGuideId = t.length > 5 ? t[5] : ''
        const plan = planMap.get(t[1])
        if (plan !== undefined) {
          plan.tasks.push(task)
        }
      }
    }
    const out: CraftPlan[] = []
    planMap.forEach((plan: CraftPlan) => {
      out.push(plan)
    })
    return out
  }

  static async savePlans(plans: CraftPlan[]): Promise<void> {
    const lines: string[] = []
    for (const plan of plans) {
      lines.push(`P|${plan.id}|${plan.title}|${plan.category}|${plan.targetCount}|${plan.dueDate}|${plan.status}`)
      for (const task of plan.tasks) {
        const done = task.done ? '1' : '0'
        lines.push(`T|${plan.id}|${task.id}|${task.title}|${done}|${task.sourceGuideId}`)
      }
    }
    await CraftLocalStore.persist(KEY_PLANS, lines.join('\n'))
    CraftLocalStore.bumpRefresh()
  }

  static async addPlan(title: string, category: string, tasks: CraftPlanTask[]): Promise<CraftPlan> {
    const all = CraftLocalStore.allPlansIncludingArchived()
    const plan = new CraftPlan()
    plan.id = `plan_${Date.now()}`
    plan.title = title
    plan.category = category.length > 0 ? category : '综合'
    plan.targetCount = tasks.length > 0 ? tasks.length : 1
    plan.dueDate = CraftLocalStore.todayLabel()
    plan.status = 'active'
    plan.tasks = tasks
    all.unshift(plan)
    await CraftLocalStore.savePlans(all)
    return plan
  }

  static async togglePlanTask(planId: string, taskId: string): Promise<void> {
    const all = CraftLocalStore.allPlansIncludingArchived()
    for (const plan of all) {
      if (plan.id !== planId) {
        continue
      }
      for (const task of plan.tasks) {
        if (task.id === taskId) {
          task.done = !task.done
        }
      }
      if (plan.tasks.length > 0 && plan.completedCount() === plan.tasks.length) {
        plan.status = 'done'
      }
    }
    await CraftLocalStore.savePlans(all)
  }

  static checkIns(): CraftCheckIn[] {
    const raw = AppStorage.get<string>(KEY_CHECKINS) ?? ''
    if (raw.length === 0) {
      return []
    }
    const out: CraftCheckIn[] = []
    for (const row of raw.split('\n')) {
      const p = row.split('|')
      if (p.length < 2) {
        continue
      }
      const item = new CraftCheckIn()
      item.date = p[0]
      item.note = p.length > 1 ? p[1] : ''
      item.durationSec = p.length > 2 ? parseInt(p[2]) : 0
      out.push(item)
    }
    return out
  }

  static todayLabel(): string {
    const d = new Date()
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${y}-${mm}-${dd}`
  }

  static hasCheckInToday(): boolean {
    const today = CraftLocalStore.todayLabel()
    for (const c of CraftLocalStore.checkIns()) {
      if (c.date === today) {
        return true
      }
    }
    return false
  }

  static streakDays(): number {
    const set: string[] = []
    for (const c of CraftLocalStore.checkIns()) {
      if (!set.includes(c.date)) {
        set.push(c.date)
      }
    }
    set.sort((a, b) => (a < b ? 1 : -1))
    let streak = 0
    let cursor = CraftLocalStore.todayLabel()
    for (let i = 0; i < set.length; i++) {
      if (set[i] === cursor) {
        streak += 1
        cursor = CraftLocalStore.prevDay(cursor)
      } else if (i === 0 && set[i] === CraftLocalStore.prevDay(CraftLocalStore.todayLabel())) {
        cursor = set[i]
        streak += 1
        cursor = CraftLocalStore.prevDay(cursor)
      } else {
        break
      }
    }
    return streak
  }

  private static prevDay(label: string): string {
    const parts = label.split('-')
    if (parts.length < 3) {
      return label
    }
    const d = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]))
    d.setDate(d.getDate() - 1)
    const y = d.getFullYear()
    const m = d.getMonth() + 1
    const day = d.getDate()
    const mm = m < 10 ? `0${m}` : `${m}`
    const dd = day < 10 ? `0${day}` : `${day}`
    return `${y}-${mm}-${dd}`
  }

  static async checkInToday(note: string): Promise<void> {
    if (CraftLocalStore.hasCheckInToday()) {
      return
    }
    const list = CraftLocalStore.checkIns()
    const item = new CraftCheckIn()
    item.date = CraftLocalStore.todayLabel()
    item.note = note
    item.durationSec = 0
    list.unshift(item)
    const lines: string[] = []
    for (const c of list) {
      lines.push(`${c.date}|${c.note}|${c.durationSec}`)
    }
    await CraftLocalStore.persist(KEY_CHECKINS, lines.join('\n'))
    CraftLocalStore.bumpRefresh()
  }

  static unlockedAchievementIds(): string[] {
    const raw = AppStorage.get<string>(KEY_ACH) ?? ''
    if (raw.length === 0) {
      return []
    }
    return raw.split(',')
  }

  static async unlockAchievement(id: string): Promise<void> {
    const ids = CraftLocalStore.unlockedAchievementIds()
    if (ids.includes(id)) {
      return
    }
    ids.push(id)
    await CraftLocalStore.persist(KEY_ACH, ids.join(','))
    CraftLocalStore.bumpRefresh()
  }

  static lastGuide(): CraftLastGuide {
    const raw = AppStorage.get<string>(KEY_LAST_GUIDE) ?? ''
    const g = new CraftLastGuide()
    if (raw.length === 0) {
      return g
    }
    const p = raw.split('|')
    g.guideId = p[0]
    g.title = p.length > 1 ? p[1] : ''
    return g
  }

  static async setLastGuide(guideId: string, title: string): Promise<void> {
    await CraftLocalStore.persist(KEY_LAST_GUIDE, `${guideId}|${title}`)
  }
}
