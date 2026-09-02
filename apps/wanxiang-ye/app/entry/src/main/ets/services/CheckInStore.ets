import { WanXiangLocalStore } from './WanXiangLocalStore'
import { ReadingPlan } from '../models/UserKnowledgeModels'
import { TimelineService } from './TimelineService'

const KEY_DATES = 'checkin_dates'
const KEY_TODAY_READ = 'checkin_today_read'

export class CheckInStore {
  static async checkInToday(): Promise<number> {
    const today = ReadingPlan.dateKey(new Date())
    const dates = await CheckInStore.getDates()
    if (dates.indexOf(today) < 0) {
      dates.unshift(today)
      await WanXiangLocalStore.putString(KEY_DATES, dates.join(','))
      await TimelineService.log('checkin', '完成今日打卡', today)
    }
    return CheckInStore.streakFromDates(dates)
  }

  static async recordTodayRead(): Promise<void> {
    const today = ReadingPlan.dateKey(new Date())
    const raw = await WanXiangLocalStore.getString(KEY_TODAY_READ, '')
    const parts = raw.length > 0 ? raw.split('|') : ['', '0']
    let dateKey = parts[0]
    let count = parseInt(parts[1], 10)
    if (dateKey !== today) {
      dateKey = today
      count = 0
    }
    count++
    await WanXiangLocalStore.putString(KEY_TODAY_READ, `${today}|${count}`)
    await CheckInStore.checkInToday()
  }

  static async getTodayReadCount(): Promise<number> {
    const today = ReadingPlan.dateKey(new Date())
    const raw = await WanXiangLocalStore.getString(KEY_TODAY_READ, '')
    if (raw.length === 0) {
      return 0
    }
    const parts = raw.split('|')
    if (parts[0] !== today) {
      return 0
    }
    const n = parseInt(parts[1], 10)
    return Number.isNaN(n) ? 0 : n
  }

  static async getStreakDays(): Promise<number> {
    const dates = await CheckInStore.getDates()
    return CheckInStore.streakFromDates(dates)
  }

  static async getDates(): Promise<string[]> {
    const raw = await WanXiangLocalStore.getString(KEY_DATES, '')
    if (raw.length === 0) {
      return []
    }
    return raw.split(',').filter((d: string) => d.length > 0)
  }

  private static streakFromDates(dates: string[]): number {
    if (dates.length === 0) {
      return 0
    }
    let streak = 0
    const cursor = new Date()
    cursor.setHours(0, 0, 0, 0)
    for (let i = 0; i < 365; i++) {
      const key = ReadingPlan.dateKey(cursor)
      if (dates.indexOf(key) >= 0) {
        streak++
        cursor.setDate(cursor.getDate() - 1)
      } else {
        break
      }
    }
    return streak
  }
}
