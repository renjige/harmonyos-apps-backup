import { JianEntry, JianOverview, MonthMoodCell, MoodStatItem } from '../models/JianModels'
import { DateHelper } from './DateHelper'
import { JianStore } from './JianStore'
import { MoodCatalog } from './MoodCatalog'

export class JianStatsService {
  static async overview(): Promise<JianOverview> {
    const list = await JianStore.loadAll()
    const ov = new JianOverview()
    ov.totalCount = list.length
    ov.streakDays = JianStatsService.computeStreak(list)
    ov.favoriteCount = 0
    for (const it of list) {
      if (it.isFavorite) {
        ov.favoriteCount++
      }
    }
    const quoteIds = await JianStore.favoriteQuoteIds()
    ov.favoriteCount += quoteIds.length
    return ov
  }

  static computeStreak(entries: JianEntry[]): number {
    const set = new Set<string>()
    for (const it of entries) {
      set.add(it.dateKey)
    }
    let streak = 0
    const cursor = new Date()
    for (let i = 0; i < 366; i++) {
      const key = DateHelper.keyFromDate(cursor)
      if (set.has(key)) {
        streak++
      } else if (i > 0) {
        break
      }
      cursor.setDate(cursor.getDate() - 1)
    }
    return streak
  }

  static async moodDistribution(): Promise<MoodStatItem[]> {
    const list = await JianStore.loadAll()
    const map = new Map<string, number>()
    for (const it of list) {
      if (it.moodId.length === 0) {
        continue
      }
      const prev = map.get(it.moodId) ?? 0
      map.set(it.moodId, prev + 1)
    }
    const out: MoodStatItem[] = []
    for (const m of MoodCatalog.all()) {
      const item = new MoodStatItem()
      item.moodId = m.id
      item.label = m.label
      item.color = m.color
      item.count = map.get(m.id) ?? 0
      if (item.count > 0) {
        out.push(item)
      }
    }
    return out
  }

  static async monthHeatmap(year: number, month: number): Promise<MonthMoodCell[]> {
    const list = await JianStore.loadAll()
    const byDate = new Map<string, JianEntry>()
    for (const it of list) {
      if (!byDate.has(it.dateKey)) {
        byDate.set(it.dateKey, it)
      }
    }
    const days = DateHelper.daysInMonth(year, month)
    const cells: MonthMoodCell[] = []
    for (let d = 1; d <= days; d++) {
      const ms = month < 10 ? `0${month}` : `${month}`
      const ds = d < 10 ? `0${d}` : `${d}`
      const key = `${year}-${ms}-${ds}`
      const cell = new MonthMoodCell()
      cell.dateKey = key
      const entry = byDate.get(key)
      if (entry !== undefined) {
        cell.hasEntry = true
        cell.moodId = entry.moodId
      }
      cells.push(cell)
    }
    return cells
  }
}
