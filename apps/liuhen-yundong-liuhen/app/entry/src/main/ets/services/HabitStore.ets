import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { BodyLog, PrepList, SportChallenge, SportPlan, TipNote } from '../models/HabitModels'
import { DateHelper } from './DateHelper'
import { DataBus } from './DataBus'

const STORE = 'sport_habit_v1'
const KEY_CHECKINS = 'checkins'
const KEY_PLANS = 'plans'
const KEY_CHALLENGES = 'challenges'
const KEY_LISTS = 'lists'
const KEY_TIPS = 'tips'
const KEY_BODY = 'body'

export class HabitStore {
  private static pref: preferences.Preferences | null = null

  static async init(context: common.UIAbilityContext): Promise<void> {
    try {
      HabitStore.pref = await preferences.getPreferences(context, STORE)
      await HabitStore.ensureDefaults()
    } catch {
      HabitStore.pref = null
    }
  }

  static async ensureDefaults(): Promise<void> {
    const lists = await HabitStore.loadLists()
    if (lists.length === 0) {
      const a = new PrepList()
      a.id = 'list_run'
      a.title = '跑步装备'
      a.items = '跑鞋|水壶|毛巾|耳机'
      a.checks = '0,0,0,0'
      const b = new PrepList()
      b.id = 'list_gym'
      b.title = '健身用品'
      b.items = '运动服|护腕|训练巾|蛋白粉（可选）'
      b.checks = '0,0,0,0'
      const c = new PrepList()
      c.id = 'list_stretch'
      c.title = '拉伸动作'
      c.items = '大腿后侧|髋部|肩颈|小腿'
      c.checks = '0,0,0,0'
      await HabitStore.persistLists([a, b, c])
    }
    const ch = await HabitStore.loadChallenges()
    if (ch.length === 0) {
      await HabitStore.persistChallenges([
        SportChallenge.preset('ch_d7', '连续 7 天运动', 'd7'),
        SportChallenge.preset('ch_d21', '21 天习惯养成', 'd21'),
        SportChallenge.preset('ch_weekend', '本月周末户外', 'weekend')
      ])
    }
  }

  static async loadCheckinKeys(): Promise<string[]> {
    const raw = await HabitStore.getString(KEY_CHECKINS, '')
    if (raw.length === 0) {
      return []
    }
    return raw.split(',')
  }

  static async hasCheckin(dateKey: string): Promise<boolean> {
    const keys = await HabitStore.loadCheckinKeys()
    for (const k of keys) {
      if (k === dateKey) {
        return true
      }
    }
    return false
  }

  static async checkInToday(): Promise<boolean> {
    const today = DateHelper.todayKey()
    const keys = await HabitStore.loadCheckinKeys()
    for (const k of keys) {
      if (k === today) {
        return false
      }
    }
    keys.push(today)
    await HabitStore.putString(KEY_CHECKINS, keys.join(','))
    DataBus.bump()
    return true
  }

  static async checkinStreak(): Promise<number> {
    const set = await HabitStore.loadCheckinKeys()
    let streak = 0
    const cursor = new Date()
    const today = DateHelper.todayKey()
    let hasToday = false
    for (const k of set) {
      if (k === today) {
        hasToday = true
      }
    }
    if (!hasToday) {
      cursor.setDate(cursor.getDate() - 1)
    }
    for (let i = 0; i < 366; i++) {
      const key = DateHelper.keyFromDate(cursor)
      let hit = false
      for (const k of set) {
        if (k === key) {
          hit = true
        }
      }
      if (hit) {
        streak++
        cursor.setDate(cursor.getDate() - 1)
      } else {
        break
      }
    }
    return streak
  }

  static async loadPlans(): Promise<SportPlan[]> {
    const raw = await HabitStore.getString(KEY_PLANS, '')
    const out: SportPlan[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 4) {
        continue
      }
      const plan = new SportPlan()
      plan.id = p[0]
      plan.title = p[1]
      plan.kind = p[2]
      plan.target = parseInt(p[3], 10)
      plan.createdAt = p.length >= 5 ? parseInt(p[4], 10) : 0
      out.push(plan)
    }
    return out
  }

  static async savePlan(plan: SportPlan): Promise<void> {
    const list = await HabitStore.loadPlans()
    const next: SportPlan[] = []
    let found = false
    for (const x of list) {
      if (x.id === plan.id) {
        next.push(plan)
        found = true
      } else {
        next.push(x)
      }
    }
    if (!found) {
      next.unshift(plan)
    }
    await HabitStore.persistPlans(next)
    DataBus.bump()
  }

  static async deletePlan(id: string): Promise<void> {
    const list = await HabitStore.loadPlans()
    const next: SportPlan[] = []
    for (const x of list) {
      if (x.id !== id) {
        next.push(x)
      }
    }
    await HabitStore.persistPlans(next)
    DataBus.bump()
  }

  static async loadChallenges(): Promise<SportChallenge[]> {
    const raw = await HabitStore.getString(KEY_CHALLENGES, '')
    const out: SportChallenge[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 3) {
        continue
      }
      const c = new SportChallenge()
      c.id = p[0]
      c.title = p[1]
      c.kind = p[2]
      c.started = p.length >= 4 ? p[3] : ''
      c.done = p.length >= 5 ? parseInt(p[4], 10) : 0
      out.push(c)
    }
    return out
  }

  static async saveChallenge(ch: SportChallenge): Promise<void> {
    const list = await HabitStore.loadChallenges()
    const next: SportChallenge[] = []
    let found = false
    for (const x of list) {
      if (x.id === ch.id) {
        next.push(ch)
        found = true
      } else {
        next.push(x)
      }
    }
    if (!found) {
      next.push(ch)
    }
    await HabitStore.persistChallenges(next)
    DataBus.bump()
  }

  static async loadLists(): Promise<PrepList[]> {
    const raw = await HabitStore.getString(KEY_LISTS, '')
    const out: PrepList[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 3) {
        continue
      }
      const l = new PrepList()
      l.id = p[0]
      l.title = p[1]
      l.items = p[2]
      l.checks = p.length >= 4 ? p[3] : ''
      out.push(l)
    }
    return out
  }

  static async saveList(list: PrepList): Promise<void> {
    const all = await HabitStore.loadLists()
    const next: PrepList[] = []
    for (const x of all) {
      if (x.id === list.id) {
        next.push(PrepList.cloneOne(list))
      } else {
        next.push(PrepList.cloneOne(x))
      }
    }
    await HabitStore.persistLists(next)
    DataBus.bump()
  }

  static async toggleListItem(listId: string, itemIndex: number): Promise<PrepList[]> {
    const all = await HabitStore.loadLists()
    const next: PrepList[] = []
    for (const x of all) {
      if (x.id === listId) {
        const copy = PrepList.cloneOne(x)
        const items = copy.itemArr()
        const parts: string[] = []
        for (let i = 0; i < items.length; i++) {
          if (i === itemIndex) {
            parts.push(copy.isChecked(i) ? '0' : '1')
          } else {
            parts.push(copy.isChecked(i) ? '1' : '0')
          }
        }
        copy.checks = parts.join(',')
        next.push(copy)
      } else {
        next.push(PrepList.cloneOne(x))
      }
    }
    await HabitStore.persistLists(next)
    DataBus.bump()
    return next
  }

  static async loadTips(): Promise<TipNote[]> {
    const raw = await HabitStore.getString(KEY_TIPS, '')
    const out: TipNote[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length < 3) {
        continue
      }
      const t = new TipNote()
      t.id = p[0]
      t.title = p[1]
      t.body = p[2]
      out.push(t)
    }
    return out
  }

  static async saveTip(tip: TipNote): Promise<void> {
    const list = await HabitStore.loadTips()
    list.unshift(tip)
    const lines: string[] = []
    for (const t of list) {
      lines.push(`${t.id}\t${t.title}\t${t.body}`)
    }
    await HabitStore.putString(KEY_TIPS, lines.join('\n'))
    DataBus.bump()
  }

  static async deleteTip(id: string): Promise<void> {
    const list = await HabitStore.loadTips()
    const next: TipNote[] = []
    for (const t of list) {
      if (t.id !== id) {
        next.push(t)
      }
    }
    const lines: string[] = []
    for (const t of next) {
      lines.push(`${t.id}\t${t.title}\t${t.body}`)
    }
    await HabitStore.putString(KEY_TIPS, lines.join('\n'))
    DataBus.bump()
  }

  static async loadBody(dateKey: string): Promise<BodyLog> {
    const raw = await HabitStore.getString(KEY_BODY, '')
    const log = new BodyLog()
    log.dateKey = dateKey
    if (raw.length === 0) {
      return log
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      const p = line.split('\t')
      if (p.length >= 4 && p[0] === dateKey) {
        log.energy = p[1]
        log.feeling = p[2]
        log.recovery = p[3]
        return log
      }
    }
    return log
  }

  static async saveBody(log: BodyLog): Promise<void> {
    const raw = await HabitStore.getString(KEY_BODY, '')
    const lines: string[] = []
    let found = false
    if (raw.length > 0) {
      const old = raw.split('\n')
      for (const line of old) {
        const p = line.split('\t')
        if (p.length >= 1 && p[0] === log.dateKey) {
          lines.push(`${log.dateKey}\t${log.energy}\t${log.feeling}\t${log.recovery}`)
          found = true
        } else if (line.length > 0) {
          lines.push(line)
        }
      }
    }
    if (!found) {
      lines.push(`${log.dateKey}\t${log.energy}\t${log.feeling}\t${log.recovery}`)
    }
    await HabitStore.putString(KEY_BODY, lines.join('\n'))
    DataBus.bump()
  }

  static async clearAll(): Promise<void> {
    await HabitStore.putString(KEY_CHECKINS, '')
    await HabitStore.putString(KEY_PLANS, '')
    await HabitStore.putString(KEY_CHALLENGES, '')
    await HabitStore.putString(KEY_TIPS, '')
    await HabitStore.putString(KEY_BODY, '')
    await HabitStore.putString(KEY_LISTS, '')
    await HabitStore.ensureDefaults()
  }

  private static async persistPlans(list: SportPlan[]): Promise<void> {
    const lines: string[] = []
    for (const p of list) {
      lines.push(`${p.id}\t${p.title}\t${p.kind}\t${p.target}\t${p.createdAt}`)
    }
    await HabitStore.putString(KEY_PLANS, lines.join('\n'))
  }

  private static async persistChallenges(list: SportChallenge[]): Promise<void> {
    const lines: string[] = []
    for (const c of list) {
      lines.push(`${c.id}\t${c.title}\t${c.kind}\t${c.started}\t${c.done}`)
    }
    await HabitStore.putString(KEY_CHALLENGES, lines.join('\n'))
  }

  private static async persistLists(list: PrepList[]): Promise<void> {
    const lines: string[] = []
    for (const l of list) {
      lines.push(`${l.id}\t${l.title}\t${l.items}\t${l.checks}`)
    }
    await HabitStore.putString(KEY_LISTS, lines.join('\n'))
  }

  private static async getString(key: string, fallback: string): Promise<string> {
    if (HabitStore.pref === null) {
      return fallback
    }
    try {
      const v = await HabitStore.pref.get(key, fallback)
      return `${v}`
    } catch {
      return fallback
    }
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (HabitStore.pref === null) {
      return
    }
    try {
      await HabitStore.pref.put(key, value)
      await HabitStore.pref.flush()
    } catch {
      // ignore
    }
  }
}
