import { MixBar } from '../models/WorkoutModels'
import { DateHelper } from './DateHelper'
import { PlanStore } from './PlanStore'
import { StatsService } from './StatsService'
import { TrainingStore } from './TrainingStore'
import { WorkoutStore } from './WorkoutStore'
import { Milestone } from '../models/TrainingModels'

export class WisdomService {
  static async adviceLine(): Promise<string> {
    const totals = await StatsService.totals()
    const week = await StatsService.weekActiveDays()
    const slot = await PlanStore.todaySlot()
    const challenges = await TrainingStore.loadChallenges()
    if (totals.totalWorkouts === 0) {
      return '还没有训练日志。从动作图鉴选一个热身，记下今天的第一笔。'
    }
    if (slot !== undefined && slot.enabled && totals.todayMinutes < slot.targetMinutes) {
      return `今日计划还差 ${slot.targetMinutes - totals.todayMinutes} 分钟，完成后图志会更厚。`
    }
    for (const c of challenges) {
      if (!c.done) {
        return `挑战「${c.title}」仍在进行。先完成今天的打卡或记录。`
      }
    }
    if (week < 3) {
      return '本周出勤偏少。打开计划中心套用 7 天活力计划，比临时决定更容易坚持。'
    }
    const mix = await WisdomService.weekMix()
    if (mix.length === 1) {
      return `最近几乎只有「${mix[0].label}」。下周在图鉴里加一条拉伸或放松。`
    }
    return '节奏稳定。用成长页对照本月配比，挑一个主题空间练深一点。'
  }

  static async weekMix(): Promise<MixBar[]> {
    const keys = DateHelper.weekDateKeys(DateHelper.todayKey())
    if (keys.length < 7) {
      return []
    }
    return StatsService.sportMix(keys[0], keys[6])
  }

  static async milestones(): Promise<Milestone[]> {
    const list = await WorkoutStore.loadAll()
    const out: Milestone[] = []
    if (list.length === 0) {
      const empty = new Milestone()
      empty.id = 'start'
      empty.whenKey = DateHelper.todayKey()
      empty.title = '故事尚未开始'
      empty.detail = '记下第一笔训练，时间轴就会出现「开始训练」。'
      out.push(empty)
      return out
    }
    const first = list[list.length - 1]
    const m0 = new Milestone()
    m0.id = 'm-start'
    m0.whenKey = first.dateKey
    m0.title = '开始训练'
    m0.detail = '体能图志里的第一笔日志'
    out.push(m0)
    if (list.length >= 10) {
      const tenth = list[list.length - 10]
      const m1 = new Milestone()
      m1.id = 'm-10'
      m1.whenKey = tenth.dateKey
      m1.title = '完成第 10 次训练'
      m1.detail = '日志已经能看出节奏'
      out.push(m1)
    }
    const streak = await StatsService.streakDays()
    if (streak >= 7) {
      const m2 = new Milestone()
      m2.id = 'm-7'
      m2.whenKey = DateHelper.todayKey()
      m2.title = '7 天坚持'
      m2.detail = `当前连续 ${streak} 天`
      out.push(m2)
    }
    const ch = await TrainingStore.loadChallenges()
    for (const c of ch) {
      if (c.done) {
        const m3 = new Milestone()
        m3.id = `m-${c.id}`
        m3.whenKey = DateHelper.todayKey()
        m3.title = `完成挑战：${c.title}`
        m3.detail = '挑战馆已点亮对应徽章'
        out.push(m3)
      }
    }
    return out
  }

  static async monthCount(): Promise<number> {
    const d = new Date()
    const keys = DateHelper.monthKeys(d.getFullYear(), d.getMonth() + 1)
    if (keys.length === 0) {
      return 0
    }
    const list = await WorkoutStore.workoutsInRange(keys[0], keys[keys.length - 1])
    return list.length
  }
}
