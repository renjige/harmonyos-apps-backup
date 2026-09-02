import {
  EmotionOption, EmotionStat, InsightReport, KeywordItem, ObservationNote, TrendPoint
} from '../models/ObservationModels'
import { DateHelper } from './DateHelper'
import { ObservationStore } from './ObservationStore'

const STOP_WORDS: string[] = [
  '的', '了', '在', '是', '我', '有', '和', '就', '不', '人', '都', '一', '上', '也', '很',
  '到', '说', '要', '去', '你', '会', '着', '没有', '看', '好', '自己', '这', '那', '今天', '感觉'
]

const EMOTION_SCORE: Map<string, number> = new Map<string, number>([
  ['calm', 3],
  ['happy', 5],
  ['anxious', 2],
  ['tired', 1],
  ['focused', 4],
  ['expect', 4]
])

const WISDOM_LINES: string[] = [
  '慢下来，也是一种前进。你的记录正在帮你看见自己。',
  '情绪有起伏很正常，重要的是你愿意观察它们。',
  '每一则短笔记，都是与生活的一次温柔对话。',
  '专注与期待并存时，往往意味着你正在靠近目标。',
  '疲惫时记得休息；记录本身就已经是自我关怀。',
  '平静的日子同样珍贵，它们在构筑你的内在节奏。'
]

export class InsightService {
  static async emotionStats(startKey: string, endKey: string): Promise<EmotionStat[]> {
    const notes = await ObservationStore.notesInRange(startKey, endKey)
    const map = new Map<string, number>()
    for (const n of notes) {
      const prev = map.get(n.emotionKey) ?? 0
      map.set(n.emotionKey, prev + 1)
    }
    let total = 0
    map.forEach((c) => { total += c })
    const out: EmotionStat[] = []
    for (const em of EmotionOption.all()) {
      const s = new EmotionStat()
      s.key = em.key
      s.label = em.label
      s.color = em.color
      s.count = map.get(em.key) ?? 0
      s.ratio = total > 0 ? s.count / total : 0
      out.push(s)
    }
    return out
  }

  static async trendPoints(days: number): Promise<TrendPoint[]> {
    const keys = DateHelper.lastNDays(days)
    keys.reverse()
    const out: TrendPoint[] = []
    let idx = 0
    for (const key of keys) {
      const notes = await ObservationStore.notesForDate(key)
      let sum = 0
      for (const n of notes) {
        sum += EMOTION_SCORE.get(n.emotionKey) ?? 3
      }
      const p = new TrendPoint()
      p.dateKey = key
      if (days <= 7 || idx % 5 === 0) {
        p.label = DateHelper.displayShort(key)
      } else {
        p.label = ''
      }
      p.score = notes.length > 0 ? sum / notes.length : 0
      out.push(p)
      idx++
    }
    return out
  }

  static async keywords(limit: number, startKey: string, endKey: string): Promise<KeywordItem[]> {
    const notes = await ObservationStore.notesInRange(startKey, endKey)
    const map = new Map<string, number>()
    for (const n of notes) {
      InsightService.tokenize(n.text, map)
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
    const notes = await ObservationStore.notesInRange(start, end)
    const report = new InsightReport()
    report.periodLabel = weekly ? DateHelper.weekRangeLabel() : DateHelper.monthRangeLabel()
    report.noteCount = notes.length
    if (notes.length === 0) {
      report.mainEmotion = '尚无记录'
      report.mainEmotionRatio = 0
      report.peakHourLabel = '—'
      report.keywords = []
      report.wisdomMessage = '开始记录第一条漫观笔记，智慧洞察会在这里等你。'
      return report
    }
    const stats = await InsightService.emotionStats(start, end)
    let top = stats[0]
    for (const s of stats) {
      if (s.count > top.count) {
        top = s
      }
    }
    report.mainEmotion = top.label
    report.mainEmotionRatio = Math.round(top.ratio * 100)
    report.peakHourLabel = InsightService.peakHour(notes)
    const kws = await InsightService.keywords(5, start, end)
    report.keywords = []
    for (const k of kws) {
      report.keywords.push(k.word)
    }
    report.wisdomMessage = InsightService.pickWisdom(top.key, notes.length)
    return report
  }

  private static peakHour(notes: ObservationNote[]): string {
    const buckets = new Map<number, number>()
    for (const n of notes) {
      const h = new Date(n.createdAt).getHours()
      const prev = buckets.get(h) ?? 0
      buckets.set(h, prev + 1)
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

  private static pickWisdom(mainKey: string, count: number): string {
    let idx = count % WISDOM_LINES.length
    if (mainKey === 'anxious') {
      idx = 1
    } else if (mainKey === 'tired') {
      idx = 4
    } else if (mainKey === 'happy') {
      idx = 3
    } else if (mainKey === 'calm') {
      idx = 5
    }
    return WISDOM_LINES[idx]
  }

  private static tokenize(text: string, map: Map<string, number>): void {
    const chinese: string[] = []
    let latin = ''
    for (let i = 0; i < text.length; i++) {
      const ch = text.substring(i, i + 1)
      const code = ch.charCodeAt(0)
      if (code >= 0x4e00 && code <= 0x9fa5) {
        if (latin.length >= 2) {
          InsightService.addWord(latin.toLowerCase(), map)
        }
        latin = ''
        chinese.push(ch)
      } else if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122) || (code >= 48 && code <= 57)) {
        InsightService.flushChinese(chinese, map)
        latin += ch
      } else {
        if (latin.length >= 2) {
          InsightService.addWord(latin.toLowerCase(), map)
        }
        latin = ''
        InsightService.flushChinese(chinese, map)
      }
    }
    if (latin.length >= 2) {
      InsightService.addWord(latin.toLowerCase(), map)
    }
    InsightService.flushChinese(chinese, map)
  }

  private static flushChinese(chars: string[], map: Map<string, number>): void {
    if (chars.length >= 2) {
      for (let i = 0; i < chars.length - 1; i++) {
        const gram = `${chars[i]}${chars[i + 1]}`
        if (!InsightService.isStopGram(gram)) {
          InsightService.addWord(gram, map)
        }
      }
    }
    while (chars.length > 0) {
      chars.pop()
    }
  }

  private static isStopGram(word: string): boolean {
    const skip: string[] = ['的了', '了一', '了我', '是我', '我的', '在这', '这个', '今天', '没有', '自己', '感觉']
    for (const s of skip) {
      if (word === s) {
        return true
      }
    }
    const first = word.substring(0, 1)
    const second = word.substring(1, 2)
    const weak: string[] = ['的', '了', '在', '是', '和', '就', '也', '很', '都']
    for (const w of weak) {
      if (first === w || second === w) {
        return true
      }
    }
    return false
  }

  private static addWord(word: string, map: Map<string, number>): void {
    for (const sw of STOP_WORDS) {
      if (word === sw) {
        return
      }
    }
    const prev = map.get(word) ?? 0
    map.set(word, prev + 1)
  }
}
