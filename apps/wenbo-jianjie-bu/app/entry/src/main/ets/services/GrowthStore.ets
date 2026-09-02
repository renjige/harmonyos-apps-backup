import { preferences } from '@kit.ArkData'
import { AchievementDef, ActivityItem, CheckInRecord, ThinkingPlanWeek } from '../models/GrowthModels'
import { DateHelper } from './DateHelper'
import { AppContextService } from './AppContextService'
import { InsightStore } from './InsightStore'

const STORE = 'jianjiebu_v1'
const KEY_ACTIVITY = 'activities'
const KEY_PLAN = 'plan_week'
const KEY_CHECKIN = 'checkins'
const KEY_ACH = 'achievements'

export class GrowthStore {
  private static pref: preferences.Preferences | null = null

  static async ensurePref(): Promise<void> {
    if (GrowthStore.pref !== null) {
      return
    }
    const ctx = AppContextService.getContext()
    if (ctx === null) {
      return
    }
    try {
      GrowthStore.pref = await preferences.getPreferences(ctx, STORE)
    } catch {
      GrowthStore.pref = null
    }
  }

  static async logActivity(kind: string, refId: string, title: string): Promise<void> {
    await GrowthStore.ensurePref()
    const list = await GrowthStore.loadActivities()
    const item = new ActivityItem()
    item.id = `act_${Date.now()}`
    item.kind = kind
    item.refId = refId
    item.title = title
    item.dateKey = DateHelper.todayKey()
    item.createdAt = Date.now()
    list.unshift(item)
    const trimmed: ActivityItem[] = []
    for (let i = 0; i < list.length && i < 80; i++) {
      trimmed.push(list[i])
    }
    await GrowthStore.persistActivities(trimmed)
  }

  static async recentActivities(limit: number): Promise<ActivityItem[]> {
    const list = await GrowthStore.loadActivities()
    const out: ActivityItem[] = []
    for (let i = 0; i < list.length && i < limit; i++) {
      out.push(list[i])
    }
    return out
  }

  static async loadPlan(): Promise<ThinkingPlanWeek> {
    await GrowthStore.ensurePref()
    const wk = DateHelper.weekKey()
    const raw = await GrowthStore.getString(`${KEY_PLAN}_${wk}`, '')
    const plan = new ThinkingPlanWeek()
    plan.weekKey = wk
    if (raw.length === 0) {
      return plan
    }
    const parts = raw.split('\t')
    if (parts.length >= 7) {
      plan.goal1 = parts[0]
      plan.goal2 = parts[1]
      plan.goal3 = parts[2]
      plan.done1 = parts[3] === '1'
      plan.done2 = parts[4] === '1'
      plan.done3 = parts[5] === '1'
      plan.updatedAt = parseInt(parts[6], 10)
      if (parts.length >= 8) {
        plan.weekKey = parts[7]
      }
    }
    return plan
  }

  /** 根据本周见解自动同步计划完成态（与手动勾选合并） */
  static async syncPlanFromEntries(): Promise<ThinkingPlanWeek> {
    const plan = await GrowthStore.loadPlan()
    const wk = DateHelper.weekKey()
    const all = await InsightStore.loadAll()
    const today = DateHelper.todayKey()
    let auto1 = false
    let auto2 = false
    let auto3 = false
    for (const n of all) {
      if (DateHelper.weekKey(n.dateKey) !== wk) {
        continue
      }
      if (n.dateKey === today) {
        auto1 = true
      }
      if (n.tags.indexOf('今日一问') >= 0 || n.title === '今日一问') {
        auto1 = true
      }
      if (n.tags.indexOf('本周三问') >= 0 || n.title === '本周三问') {
        auto3 = true
      }
      if (n.verdict === 'hit' || n.verdict === 'miss' || n.verdict === 'revised') {
        auto2 = true
      }
    }
    plan.done1 = plan.done1 || auto1
    plan.done2 = plan.done2 || auto2
    plan.done3 = plan.done3 || auto3
    await GrowthStore.savePlan(plan)
    return plan
  }

  static async savePlan(plan: ThinkingPlanWeek): Promise<void> {
    await GrowthStore.ensurePref()
    plan.updatedAt = Date.now()
    const line = [plan.goal1, plan.goal2, plan.goal3,
      plan.done1 ? '1' : '0', plan.done2 ? '1' : '0', plan.done3 ? '1' : '0',
      `${plan.updatedAt}`, plan.weekKey].join('\t')
    await GrowthStore.putString(`${KEY_PLAN}_${plan.weekKey}`, line)
  }

  static async togglePlanSlot(index: number): Promise<ThinkingPlanWeek> {
    const plan = await GrowthStore.loadPlan()
    if (index === 0) {
      plan.done1 = !plan.done1
    } else if (index === 1) {
      plan.done2 = !plan.done2
    } else {
      plan.done3 = !plan.done3
    }
    await GrowthStore.savePlan(plan)
    if (plan.done1 || plan.done2 || plan.done3) {
      await GrowthStore.logActivity('plan', plan.weekKey, '更新了本周思考计划')
    }
    return plan
  }

  static async markPlanDone(index: number): Promise<void> {
    const plan = await GrowthStore.loadPlan()
    if (index === 0) {
      plan.done1 = true
    } else if (index === 1) {
      plan.done2 = true
    } else if (index === 2) {
      plan.done3 = true
    }
    await GrowthStore.savePlan(plan)
  }

  static async touchCheckIn(entryCount: number): Promise<void> {
    await GrowthStore.ensurePref()
    const today = DateHelper.todayKey()
    const map = await GrowthStore.loadCheckInMap()
    const rec = new CheckInRecord()
    rec.dateKey = today
    rec.entryCount = entryCount
    rec.note = map.get(today) !== undefined ? map.get(today)!.note : ''
    map.set(today, rec)
    await GrowthStore.persistCheckIns(map)
  }

  static async checkInToday(note: string): Promise<void> {
    await GrowthStore.ensurePref()
    const today = DateHelper.todayKey()
    const map = await GrowthStore.loadCheckInMap()
    const rec = map.get(today)
    const row = new CheckInRecord()
    row.dateKey = today
    row.note = note.trim()
    row.entryCount = rec !== undefined ? rec.entryCount : 0
    map.set(today, row)
    await GrowthStore.persistCheckIns(map)
    await GrowthStore.logActivity('checkin', today, '完成今日书写打卡')
  }

  static async isCheckedInToday(): Promise<boolean> {
    const map = await GrowthStore.loadCheckInMap()
    const rec = map.get(DateHelper.todayKey())
    return rec !== undefined && rec.note.length > 0
  }

  static async unlockedIds(): Promise<string[]> {
    await GrowthStore.ensurePref()
    const raw = await GrowthStore.getString(KEY_ACH, '')
    if (raw.length === 0) {
      return []
    }
    const out: string[] = []
    const parts = raw.split(',')
    for (const p of parts) {
      if (p.length > 0) {
        out.push(p)
      }
    }
    return out
  }

  static async unlock(id: string): Promise<boolean> {
    const ids = await GrowthStore.unlockedIds()
    for (const x of ids) {
      if (x === id) {
        return false
      }
    }
    ids.push(id)
    await GrowthStore.putString(KEY_ACH, ids.join(','))
    const defs = AchievementDef.all()
    for (const d of defs) {
      if (d.id === id) {
        await GrowthStore.logActivity('achievement', id, `解锁徽章：${d.name}`)
        break
      }
    }
    return true
  }

  private static async loadActivities(): Promise<ActivityItem[]> {
    await GrowthStore.ensurePref()
    const raw = await GrowthStore.getString(KEY_ACTIVITY, '')
    const out: ActivityItem[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parts = line.split('\t')
      if (parts.length < 6) {
        continue
      }
      const a = new ActivityItem()
      a.id = parts[0]
      a.kind = parts[1]
      a.refId = parts[2]
      a.title = parts[3].replace(/\\n/g, '\n')
      a.dateKey = parts[4]
      a.createdAt = parseInt(parts[5], 10)
      out.push(a)
    }
    return out
  }

  private static async persistActivities(items: ActivityItem[]): Promise<void> {
    const lines: string[] = []
    for (const a of items) {
      const title = a.title.replace(/\t/g, ' ').replace(/\n/g, '\\n')
      lines.push([a.id, a.kind, a.refId, title, a.dateKey, `${a.createdAt}`].join('\t'))
    }
    await GrowthStore.putString(KEY_ACTIVITY, lines.join('\n'))
  }

  private static async loadCheckInMap(): Promise<Map<string, CheckInRecord>> {
    await GrowthStore.ensurePref()
    const raw = await GrowthStore.getString(KEY_CHECKIN, '')
    const map = new Map<string, CheckInRecord>()
    if (raw.length === 0) {
      return map
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const parts = line.split('\t')
      if (parts.length < 3) {
        continue
      }
      const r = new CheckInRecord()
      r.dateKey = parts[0]
      r.note = parts[1].replace(/\\n/g, '\n')
      r.entryCount = parseInt(parts[2], 10)
      map.set(r.dateKey, r)
    }
    return map
  }

  private static async persistCheckIns(map: Map<string, CheckInRecord>): Promise<void> {
    const lines: string[] = []
    map.forEach((r: CheckInRecord) => {
      const note = r.note.replace(/\t/g, ' ').replace(/\n/g, '\\n')
      lines.push([r.dateKey, note, `${r.entryCount}`].join('\t'))
    })
    await GrowthStore.putString(KEY_CHECKIN, lines.join('\n'))
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (GrowthStore.pref === null) {
      return fallback
    }
    try {
      const v = await GrowthStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (GrowthStore.pref === null) {
      return
    }
    try {
      await GrowthStore.pref.put(key, value)
      await GrowthStore.pref.flush()
    } catch {
    }
  }
}
