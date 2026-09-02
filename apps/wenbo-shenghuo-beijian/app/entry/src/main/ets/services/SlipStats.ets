import { SlipItem, WeekBar } from '../models/SlipModels'
import { SlipDateUtil } from './SlipDateUtil'
import { SlipStore } from './SlipStore'

export class SlipStats {
  static todayOpen(items: SlipItem[]): SlipItem[] {
    const today = SlipDateUtil.todayIso()
    const out: SlipItem[] = []
    for (const n of items) {
      if (n.date === today && !n.isCompleted) {
        out.push(n)
      }
    }
    return out
  }

  static todayDone(items: SlipItem[]): SlipItem[] {
    const today = SlipDateUtil.todayIso()
    const out: SlipItem[] = []
    for (const n of items) {
      if (n.date === today && n.isCompleted) {
        out.push(n)
      }
    }
    return out
  }

  static upcoming(items: SlipItem[]): SlipItem[] {
    const today = SlipDateUtil.todayIso()
    const out: SlipItem[] = []
    for (const n of items) {
      if (n.date === today && n.isReminderEnabled && n.reminderTime.length > 0 && !n.isCompleted) {
        out.push(n)
      }
    }
    return out
  }

  static totalDone(items: SlipItem[]): number {
    let n = 0
    for (const it of items) {
      if (it.isCompleted) {
        n += 1
      }
    }
    return n
  }

  static weekDone(items: SlipItem[]): number {
    const now = new Date()
    const start = new Date(now.getTime())
    const lead = now.getDay() === 0 ? 6 : now.getDay() - 1
    start.setDate(now.getDate() - lead)
    const from = SlipDateUtil.toIso(start)
    let n = 0
    for (const it of items) {
      if (it.isCompleted && it.date >= from && it.date <= SlipDateUtil.todayIso()) {
        n += 1
      }
    }
    return n
  }

  static streakDays(items: SlipItem[]): number {
    let streak = 0
    const cursor = new Date()
    for (let i = 0; i < 60; i++) {
      const iso = SlipDateUtil.toIso(cursor)
      if (SlipStats.hasOnDate(items, iso)) {
        streak += 1
        cursor.setDate(cursor.getDate() - 1)
      } else {
        break
      }
    }
    return streak
  }

  static topCategory(items: SlipItem[]): string {
    const cats: string[] = ['生活', '工作', '家庭', '购物', '出行', '学习', '其他']
    let best = '生活'
    let bestN = 0
    for (const c of cats) {
      let n = 0
      for (const it of items) {
        if (it.category === c) {
          n += 1
        }
      }
      if (n > bestN) {
        bestN = n
        best = c
      }
    }
    return best
  }

  static weekBars(items: SlipItem[]): WeekBar[] {
    const now = new Date()
    const lead = now.getDay() === 0 ? 6 : now.getDay() - 1
    const start = new Date(now.getTime())
    start.setDate(now.getDate() - lead)
    const names: string[] = ['一', '二', '三', '四', '五', '六', '日']
    const out: WeekBar[] = []
    for (let i = 0; i < 7; i++) {
      const d = new Date(start.getTime())
      d.setDate(start.getDate() + i)
      const iso = SlipDateUtil.toIso(d)
      const bar = new WeekBar()
      bar.label = names[i]
      let total = 0
      let done = 0
      for (const it of items) {
        if (it.date === iso) {
          total += 1
          if (it.isCompleted) {
            done += 1
          }
        }
      }
      bar.total = total
      bar.done = done
      out.push(bar)
    }
    return out
  }

  private static hasOnDate(items: SlipItem[], iso: string): boolean {
    for (const it of items) {
      if (it.date === iso) {
        return true
      }
    }
    return false
  }

  static snapshot(): SlipItem[] {
    return SlipStore.sorted()
  }
}
