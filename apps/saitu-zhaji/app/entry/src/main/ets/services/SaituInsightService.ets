import { InsightReport, KeywordItem, SaituRecord, TrendPoint } from '../models/SaituModels'
import { DateHelper } from './DateHelper'
import { SaituLocalStore } from './SaituLocalStore'

const STOP_WORDS: string[] = [
  '的', '了', '在', '是', '我', '有', '和', '就', '不', '人', '都', '一', '上', '也', '很',
  '到', '说', '要', '去', '你', '会', '着', '没有', '看', '好', '自己', '这', '那', '今天', '感觉'
]

const WISDOM_LINES: string[] = [
  '每一步记录，都是赛途上的里程碑。',
  '坚持写下心得，进步会在趋势里显现。',
  '旅途不在远方，而在你每日的札记里。',
  '标签与关键词，帮你看见自己关注的方向。',
  '连续记录的日子，是最值得骄傲的轨迹。',
  '回顾不是为了评判，而是为了更清楚地前行。'
]

export class SaituInsightService {
  static async trendPoints(days: number): Promise<TrendPoint[]> {
    const keys = DateHelper.lastNDays(days)
    keys.reverse()
    const out: TrendPoint[] = []
    for (const key of keys) {
      const items = await SaituLocalStore.recordsInRange(key, key)
      const p = new TrendPoint()
      p.dateKey = key
      p.count = items.length
      p.label = DateHelper.displayShort(key)
      out.push(p)
    }
    return out
  }

  static async keywords(limit: number, startKey: string, endKey: string): Promise<KeywordItem[]> {
    const records = await SaituLocalStore.recordsInRange(startKey, endKey)
    const map = new Map<string, number>()
    for (const r of records) {
      SaituInsightService.tokenize(r.content, map)
      for (const tag of r.tags) {
        SaituInsightService.addWord(tag, map)
      }
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

  static async buildReport(weekly: boolean): Promise<InsightReport> {
    const end = DateHelper.todayKey()
    const startDate = new Date()
    startDate.setDate(startDate.getDate() - (weekly ? 6 : 29))
    const start = DateHelper.keyFromDate(startDate)
    const records = await SaituLocalStore.recordsInRange(start, end)
    const report = new InsightReport()
    report.periodKind = weekly ? 'week' : 'month'
    report.periodLabel = weekly ? DateHelper.weekRangeLabel() : DateHelper.monthRangeLabel()
    report.recordCount = records.length
    if (records.length === 0) {
      report.topTag = '尚无记录'
      report.topTagRatio = 0
      report.peakHourLabel = '—'
      report.keywords = []
      report.wisdomMessage = '写下第一条赛途札记，智慧洞察会在这里呈现你的成长轨迹。'
      return report
    }
    const tagMap = new Map<string, number>()
    for (const r of records) {
      for (const tag of r.tags) {
        tagMap.set(tag, (tagMap.get(tag) ?? 0) + 1)
      }
    }
    let topTag = '无标签'
    let topCount = 0
    tagMap.forEach((c, tag) => {
      if (c > topCount) {
        topCount = c
        topTag = tag
      }
    })
    report.topTag = topTag
    report.topTagRatio = Math.round((topCount / records.length) * 100)
    report.peakHourLabel = SaituInsightService.peakHour(records)
    const kws = await SaituInsightService.keywords(8, start, end)
    report.keywords = []
    for (const k of kws) {
      report.keywords.push(k.word)
    }
    report.wisdomMessage = WISDOM_LINES[records.length % WISDOM_LINES.length]
    return report
  }

  static trendDeltaPercent(recent: TrendPoint[]): number {
    if (recent.length < 14) {
      return 0
    }
    let firstSum = 0
    let secondSum = 0
    for (let i = 0; i < 7; i++) {
      firstSum += recent[i].count
      secondSum += recent[i + 7].count
    }
    if (firstSum === 0) {
      return secondSum > 0 ? 100 : 0
    }
    return Math.round(((secondSum - firstSum) / firstSum) * 100)
  }

  private static peakHour(records: SaituRecord[]): string {
    const buckets = new Map<number, number>()
    for (const n of records) {
      const h = new Date(n.createdAt).getHours()
      buckets.set(h, (buckets.get(h) ?? 0) + 1)
    }
    let bestH = 20
    let bestC = 0
    buckets.forEach((c, h) => {
      if (c > bestC) {
        bestC = c
        bestH = h
      }
    })
    const endH = bestH + 1
    return `${bestH}:00 — ${endH > 23 ? '0' : `${endH}`}:00`
  }

  private static tokenize(text: string, map: Map<string, number>): void {
    const chinese: string[] = []
    let latin = ''
    for (let i = 0; i < text.length; i++) {
      const ch = text.substring(i, i + 1)
      const code = ch.charCodeAt(0)
      if (code >= 0x4e00 && code <= 0x9fa5) {
        if (latin.length >= 2) {
          SaituInsightService.addWord(latin.toLowerCase(), map)
        }
        latin = ''
        chinese.push(ch)
      } else if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122) || (code >= 48 && code <= 57)) {
        SaituInsightService.flushChinese(chinese, map)
        latin += ch
      } else {
        if (latin.length >= 2) {
          SaituInsightService.addWord(latin.toLowerCase(), map)
        }
        latin = ''
        SaituInsightService.flushChinese(chinese, map)
      }
    }
    if (latin.length >= 2) {
      SaituInsightService.addWord(latin.toLowerCase(), map)
    }
    SaituInsightService.flushChinese(chinese, map)
  }

  private static flushChinese(chars: string[], map: Map<string, number>): void {
    if (chars.length >= 2) {
      for (let i = 0; i < chars.length - 1; i++) {
        const gram = `${chars[i]}${chars[i + 1]}`
        SaituInsightService.addWord(gram, map)
      }
    }
    while (chars.length > 0) {
      chars.pop()
    }
  }

  private static addWord(word: string, map: Map<string, number>): void {
    for (const sw of STOP_WORDS) {
      if (word === sw) {
        return
      }
    }
    if (word.length < 2) {
      return
    }
    map.set(word, (map.get(word) ?? 0) + 1)
  }
}
