import { DiaryEntry, KeywordItem, MonthStats, WeekSummary } from '../models/DiaryModels'
import { DateHelper } from './DateHelper'
import { DiaryStore } from './DiaryStore'

const STOP_WORDS: string[] = [
  '的', '了', '在', '是', '我', '有', '和', '就', '不', '人', '都', '一', '一个', '上', '也', '很',
  '到', '说', '要', '去', '你', '会', '着', '没有', '看', '好', '自己', '这', '那', '今天', '感觉'
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
      const prev = stats.moodCounts.get(it.moodKey) ?? 0
      stats.moodCounts.set(it.moodKey, prev + 1)
    }
    stats.diaryDays = daySet.size
    stats.longestStreak = await DiaryStatsService.computeStreak(list)
    return stats
  }

  static async computeStreak(entries: DiaryEntry[]): Promise<number> {
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
      const text = `${it.title} ${it.body}`.replace(/\*\*/g, '').replace(/\*/g, '')
      DiaryStatsService.tokenize(text, map)
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

  static async weekSummary(): Promise<WeekSummary> {
    const ws = new WeekSummary()
    const now = new Date()
    const start = new Date(now)
    start.setDate(now.getDate() - now.getDay())
    const endKey = DateHelper.keyFromDate(now)
    const startKey = DateHelper.keyFromDate(start)
    const list = await DiaryStore.loadAll()
    const weekEntries: DiaryEntry[] = []
    for (const it of list) {
      if (it.dateKey >= startKey && it.dateKey <= endKey) {
        weekEntries.push(it)
      }
    }
    ws.entryCount = weekEntries.length
    ws.weekLabel = `${DateHelper.displayShort(startKey)} — ${DateHelper.displayShort(endKey)}`
    if (weekEntries.length === 0) {
      ws.summaryText = '本周尚未写日记，不妨今晚记录一点心情。'
      return ws
    }
    const map = new Map<string, number>()
    for (const it of weekEntries) {
      DiaryStatsService.tokenize(it.body, map)
    }
    const top: string[] = []
    map.forEach((count, word) => {
      if (top.length < 5) {
        top.push(`${word}(${count})`)
      }
    })
    ws.summaryText = `本周共 ${weekEntries.length} 篇，高频词：${top.join('、')}。`
    return ws
  }

  static async onThisDay(): Promise<DiaryEntry[]> {
    const now = new Date()
    const keys = DateHelper.sameDayKeys(now.getFullYear(), now.getMonth() + 1, now.getDate())
    const list = await DiaryStore.loadAll()
    const out: DiaryEntry[] = []
    for (const it of list) {
      for (const k of keys) {
        if (it.dateKey === k) {
          out.push(it)
        }
      }
    }
    return out
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
