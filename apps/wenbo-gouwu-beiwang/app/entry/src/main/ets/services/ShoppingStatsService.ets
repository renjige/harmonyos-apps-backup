import { ShoppingLocalStore } from './ShoppingLocalStore'
import { ShoppingItem, ShoppingList } from '../models/ShoppingModels'

export class CategoryStat {
  name: string = ''
  count: number = 0
}

export class WeekDayStat {
  label: string = ''
  done: number = 0
}

export class ShoppingInsight {
  completionRate: number = 0
  streakDays: number = 0
  topCategory: string = '暂无'
  weekChecked: number = 0
  categories: CategoryStat[] = []
  weekBars: WeekDayStat[] = []
}

export class ShoppingStatsService {
  static insight(): ShoppingInsight {
    return ShoppingStatsService.insightForItems(ShoppingLocalStore.items(), ShoppingLocalStore.lists())
  }

  static insightForItems(items: ShoppingItem[], lists: ShoppingList[]): ShoppingInsight {
    const out = new ShoppingInsight()
    let total = 0
    let checked = 0
    for (const it of items) {
      total += 1
      if (it.completed) {
        checked += 1
      }
    }
    out.completionRate = total > 0 ? checked / total : 0
    out.weekChecked = ShoppingStatsService.weekCheckedCount(items)
    out.streakDays = ShoppingStatsService.streakDays(lists)
    out.categories = ShoppingStatsService.categoryBreakdown(items)
    out.weekBars = ShoppingStatsService.weekBars(items)
    if (out.categories.length > 0) {
      out.topCategory = out.categories[0].name
    }
    return out
  }

  static cloneInsight(src: ShoppingInsight): ShoppingInsight {
    const out = new ShoppingInsight()
    out.completionRate = src.completionRate
    out.streakDays = src.streakDays
    out.topCategory = src.topCategory
    out.weekChecked = src.weekChecked
    const cats: CategoryStat[] = []
    for (const row of src.categories) {
      const c = new CategoryStat()
      c.name = row.name
      c.count = row.count
      cats.push(c)
    }
    out.categories = cats
    const bars: WeekDayStat[] = []
    for (const row of src.weekBars) {
      const b = new WeekDayStat()
      b.label = row.label
      b.done = row.done
      bars.push(b)
    }
    out.weekBars = bars
    return out
  }

  static todayWeekIndex(): number {
    const d = new Date()
    const day = d.getDay()
    return day === 0 ? 6 : day - 1
  }

  private static weekCheckedCount(items: ShoppingItem[]): number {
    const start = ShoppingStatsService.weekStartMs()
    let count = 0
    for (const it of items) {
      if (!it.completed || it.updatedAt.length === 0) {
        continue
      }
      const ms = Date.parse(it.updatedAt)
      if (!Number.isNaN(ms) && ms >= start) {
        count += 1
      }
    }
    return count
  }

  private static weekStartMs(): number {
    const d = new Date()
    d.setHours(0, 0, 0, 0)
    const day = d.getDay()
    const offset = day === 0 ? 6 : day - 1
    d.setDate(d.getDate() - offset)
    return d.getTime()
  }

  private static streakDays(lists: ShoppingList[]): number {
    const doneDates: string[] = []
    for (const row of lists) {
      if (row.status !== 'done') {
        continue
      }
      const key = row.updatedAt.length >= 10 ? row.updatedAt.substring(0, 10) : row.dueDate
      if (key.length === 10 && doneDates.indexOf(key) < 0) {
        doneDates.push(key)
      }
    }
    let streak = 0
    const cursor = new Date()
    cursor.setHours(0, 0, 0, 0)
    for (let i = 0; i < 30; i++) {
      const y = cursor.getFullYear()
      const m = cursor.getMonth() + 1
      const day = cursor.getDate()
      const ms: string = m < 10 ? `0${m}` : `${m}`
      const ds: string = day < 10 ? `0${day}` : `${day}`
      const key = `${y}-${ms}-${ds}`
      if (doneDates.indexOf(key) >= 0) {
        streak += 1
        cursor.setDate(cursor.getDate() - 1)
      } else if (i === 0) {
        cursor.setDate(cursor.getDate() - 1)
      } else {
        break
      }
    }
    return streak
  }

  private static categoryBreakdown(items: ShoppingItem[]): CategoryStat[] {
    const map: CategoryStat[] = []
    for (const it of items) {
      const cat = it.category.length > 0 ? it.category : '其他'
      let found = false
      for (const row of map) {
        if (row.name === cat) {
          row.count += 1
          found = true
          break
        }
      }
      if (!found) {
        const row = new CategoryStat()
        row.name = cat
        row.count = 1
        map.push(row)
      }
    }
    for (let i = 0; i < map.length; i++) {
      for (let j = i + 1; j < map.length; j++) {
        if (map[j].count > map[i].count) {
          const tmp = map[i]
          map[i] = map[j]
          map[j] = tmp
        }
      }
    }
    const out: CategoryStat[] = []
    for (const row of map) {
      if (out.length >= 5) {
        break
      }
      out.push(row)
    }
    return out
  }

  private static weekBars(items: ShoppingItem[]): WeekDayStat[] {
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '日']
    const start = ShoppingStatsService.weekStartMs()
    const out: WeekDayStat[] = []
    for (let i = 0; i < 7; i++) {
      const row = new WeekDayStat()
      row.label = labels[i]
      row.done = 0
      out.push(row)
    }
    for (const it of items) {
      if (!it.completed || it.updatedAt.length === 0) {
        continue
      }
      const ms = Date.parse(it.updatedAt)
      if (Number.isNaN(ms) || ms < start) {
        continue
      }
      const idx = Math.floor((ms - start) / 86400000)
      if (idx >= 0 && idx < 7) {
        out[idx].done += 1
      }
    }
    return out
  }
}
