import { PlanSlot, WeekPlan } from '../models/WorkoutModels'
import { DateHelper } from './DateHelper'
import { WorkoutStore } from './WorkoutStore'

const KEY_PLANS = 'week_plans'

export class PlanStore {
  static async loadPlan(weekKey: string): Promise<WeekPlan> {
    const all = await PlanStore.loadAll()
    for (const p of all) {
      if (p.weekKey === weekKey) {
        return p
      }
    }
    return WeekPlan.empty(weekKey)
  }

  static async savePlan(plan: WeekPlan): Promise<void> {
    const all = await PlanStore.loadAll()
    const next: WeekPlan[] = []
    let replaced = false
    for (const p of all) {
      if (p.weekKey === plan.weekKey) {
        next.push(plan)
        replaced = true
      } else {
        next.push(p)
      }
    }
    if (!replaced) {
      next.push(plan)
    }
    await PlanStore.persist(next)
  }

  static async todaySlot(): Promise<PlanSlot | undefined> {
    const today = DateHelper.todayKey()
    const plan = await PlanStore.loadPlan(DateHelper.weekKey(today))
    return plan.todaySlot(DateHelper.weekdayIndexMon0(today))
  }

  static async hasScheduledPlan(): Promise<boolean> {
    const today = DateHelper.todayKey()
    const plan = await PlanStore.loadPlan(DateHelper.weekKey(today))
    for (const s of plan.slots) {
      if (s.enabled) {
        return true
      }
    }
    return false
  }

  static applyStarter(plan: WeekPlan): WeekPlan {
    const types: string[] = ['running', 'strength', 'yoga', 'running', 'cycling', 'hiking', 'other']
    const mins: number[] = [30, 40, 25, 30, 40, 50, 0]
    const enabled: boolean[] = [true, true, true, true, true, true, false]
    const next = WeekPlan.empty(plan.weekKey)
    next.motto = plan.motto
    for (let i = 0; i < 7; i++) {
      next.slots[i].typeKey = types[i]
      next.slots[i].targetMinutes = mins[i] > 0 ? mins[i] : 30
      next.slots[i].enabled = enabled[i]
    }
    return next
  }

  private static async loadAll(): Promise<WeekPlan[]> {
    const raw = await WorkoutStore.readRaw(KEY_PLANS)
    const out: WeekPlan[] = []
    if (raw.length === 0) {
      return out
    }
    const lines = raw.split('\n')
    for (const line of lines) {
      if (line.length === 0) {
        continue
      }
      const parsed = PlanStore.parseLine(line)
      if (parsed !== undefined) {
        out.push(parsed)
      }
    }
    return out
  }

  private static async persist(items: WeekPlan[]): Promise<void> {
    const lines: string[] = []
    for (const p of items) {
      lines.push(PlanStore.serialize(p))
    }
    await WorkoutStore.writeRaw(KEY_PLANS, lines.join('\n'))
  }

  private static serialize(p: WeekPlan): string {
    const motto = p.motto.replace(/\t/g, ' ').replace(/\n/g, ' ')
    const slots: string[] = []
    for (const s of p.slots) {
      const on = s.enabled ? '1' : '0'
      slots.push(`${on}:${s.typeKey}:${s.targetMinutes}`)
    }
    return `${p.weekKey}\t${motto}\t${slots.join(';')}`
  }

  private static parseLine(line: string): WeekPlan | undefined {
    const parts = line.split('\t')
    if (parts.length < 3) {
      return undefined
    }
    const p = WeekPlan.empty(parts[0])
    p.motto = parts[1]
    const slotParts = parts[2].split(';')
    for (let i = 0; i < p.slots.length && i < slotParts.length; i++) {
      const bits = slotParts[i].split(':')
      if (bits.length >= 3) {
        p.slots[i].enabled = bits[0] === '1'
        p.slots[i].typeKey = bits[1]
        const mins = parseInt(bits[2], 10)
        p.slots[i].targetMinutes = isNaN(mins) || mins <= 0 ? 30 : mins
      }
    }
    return p
  }
}
