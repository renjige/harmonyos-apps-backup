import { SenseCount, DayCount } from '../models/GrowthModels'
import { EssayStats, MicroEssay, SenseOption } from '../models/EssayModels'
import { EssayStore } from './EssayStore'
import { DateHelper } from './DateHelper'

export class EssayStatsService {
  static async loadStats(): Promise<EssayStats> {
    const stats = new EssayStats()
    const list = await EssayStore.loadAll()
    stats.essayCount = list.length
    for (const it of list) {
      stats.totalWords += it.wordCount
      if (it.favorite) {
        stats.favoriteCount++
      }
      if (EssayStore.isInWeek(it)) {
        stats.weekCount++
        stats.weekWords += it.wordCount
      }
    }
    stats.streakDays = EssayStatsService.computeStreak(list)
    stats.topTag = EssayStatsService.topTagOf(list)
    return stats
  }

  static topTagOf(list: MicroEssay[]): string {
    const tagNames: string[] = []
    const tagCounts: number[] = []
    for (const it of list) {
      const tags = it.tagList()
      for (const t of tags) {
        let found = false
        for (let i = 0; i < tagNames.length; i++) {
          if (tagNames[i] === t) {
            tagCounts[i] = tagCounts[i] + 1
            found = true
            break
          }
        }
        if (!found) {
          tagNames.push(t)
          tagCounts.push(1)
        }
      }
    }
    let top = ''
    let topN = 0
    for (let i = 0; i < tagNames.length; i++) {
      if (tagCounts[i] > topN) {
        topN = tagCounts[i]
        top = tagNames[i]
      }
    }
    return top
  }

  static senseCountsOf(list: MicroEssay[]): SenseCount[] {
    const opts = SenseOption.all()
    const out: SenseCount[] = []
    for (const s of opts) {
      const row = new SenseCount()
      row.key = s.key
      row.label = s.label
      row.count = 0
      for (const it of list) {
        if (it.senseKey === s.key) {
          row.count++
        }
      }
      out.push(row)
    }
    return out
  }

  static weekDayCountsOf(list: MicroEssay[]): DayCount[] {
    const today = DateHelper.todayKey()
    const labels: string[] = ['6天前', '5天前', '4天前', '3天前', '前天', '昨天', '今天']
    const out: DayCount[] = []
    for (let i = 0; i < 7; i++) {
      const key = DateHelper.addDaysKey(today, i - 6)
      const row = new DayCount()
      row.label = labels[i]
      row.count = 0
      for (const it of list) {
        if (EssayStore.resolvedDateKey(it) === key) {
          row.count++
        }
      }
      out.push(row)
    }
    return out
  }

  static computeStreak(entries: MicroEssay[]): number {
    const keys: string[] = []
    for (const it of entries) {
      const key = EssayStore.resolvedDateKey(it)
      if (key.length === 0) {
        continue
      }
      let exists = false
      for (const k of keys) {
        if (k === key) {
          exists = true
          break
        }
      }
      if (!exists) {
        keys.push(key)
      }
    }
    let streak = 0
    const cursor = new Date()
    for (let i = 0; i < 366; i++) {
      const key = DateHelper.keyFromDate(cursor)
      let hit = false
      for (const k of keys) {
        if (k === key) {
          hit = true
          break
        }
      }
      if (hit) {
        streak++
      } else if (i > 0) {
        break
      }
      cursor.setDate(cursor.getDate() - 1)
    }
    return streak
  }
}
