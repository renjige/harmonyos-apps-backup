import { DiaryEntry, KeywordItem, MonthStats } from '../models/DiaryModels'
import { DateHelper } from './DateHelper'
import { DiaryStore } from './DiaryStore'

const STOP_WORDS: string[] = [
  '的', '了', '在', '是', '我', '有', '和', '就', '不', '人', '都', '一', '一个', '上', '也', '很',
  '到', '说', '要', '去', '你', '会', '着', '没有', '看', '好', '自己', '这', '那', '今天', '感觉', '然后'
]

export class DiaryStatsService {
  static async monthStats(year: number, month: number): Promise<MonthStats> {
    const stats = new MonthStats()
    stats.year = year
    stats.month = month
    const list = await DiaryStore.loadAll()
    const prefix = `${year}-${month < 10 ? `0${month}` : `${month}`}`
    const daySet = new Set<string>()
    for (const it of list) {
      if (it.dateKey.indexOf(prefix) !== 0) {
        continue
      }
      daySet.add(it.dateKey)
      stats.totalWords += it.wordCount
    }
    stats.diaryDays = daySet.size
    stats.longestStreak = DiaryStatsService.computeStreak(list)
    return stats
  }

  static computeStreak(entries: DiaryEntry[]): number {
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

  static async keywords(limit: number): Promise<KeywordItem[]> {
    const list = await DiaryStore.loadAll()
    const map = new Map<string, number>()
    for (const it of list) {
      DiaryStatsService.tokenize(DiaryEntry.stripMarkup(it.body), map)
    }
    const items: KeywordItem[] = []
    map.forEach((count, word) => {
      const ki = new KeywordItem()
      ki.word = word
      ki.count = count
      items.push(ki)
    })
    items.sort((a, b) => b.count - a.count)
    if (items.length <= limit) {
      return items
    }
    return items.slice(0, limit)
  }

  private static tokenize(text: string, map: Map<string, number>): void {
    const cleaned = text.replace(/[^\u4e00-\u9fa5a-zA-Z0-9\s]/g, ' ')
    const parts = cleaned.split(/\s+/)
    for (const p of parts) {
      if (p.length < 2) {
        continue
      }
      let skip = false
      for (const sw of STOP_WORDS) {
        if (p === sw) {
          skip = true
          break
        }
      }
      if (skip) {
        continue
      }
      const prev = map.get(p) ?? 0
      map.set(p, prev + 1)
    }
  }
}
