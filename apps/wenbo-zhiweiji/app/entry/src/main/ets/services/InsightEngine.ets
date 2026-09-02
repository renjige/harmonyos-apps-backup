import { CaptureItem, InsightDigest, KeywordHit } from '../models/ZhiweiModels'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

export class InsightEngine {
  static buildDaily(items: CaptureItem[], dateKey: string): InsightDigest {
    return InsightEngine.buildFrom(InsightEngine.dayItems(items, dateKey), 'day', dateKey)
  }

  static buildWeekly(items: CaptureItem[], endDate: string): InsightDigest {
    return InsightEngine.buildFrom(InsightEngine.weekItems(items, endDate), 'week', endDate)
  }

  static weekItems(items: CaptureItem[], endDate: string): CaptureItem[] {
    const weekItems: CaptureItem[] = []
    const keys = InsightEngine.lastDays(endDate, 7)
    for (const it of items) {
      if (InsightEngine.inKeySet(it, keys)) {
        weekItems.push(it)
      }
    }
    return weekItems
  }

  static dayItems(items: CaptureItem[], dateKey: string): CaptureItem[] {
    const out: CaptureItem[] = []
    for (const it of items) {
      if (InsightEngine.dateOf(InsightEngine.stampOf(it)) === dateKey) {
        out.push(it)
      }
    }
    return out
  }

  static inKeySet(it: CaptureItem, keys: string[]): boolean {
    const k = InsightEngine.dateOf(InsightEngine.stampOf(it))
    for (const d of keys) {
      if (d === k) {
        return true
      }
    }
    return false
  }

  static stampOf(it: CaptureItem): number {
    let ts = it.createdAt
    if (ts > 1000000000 && ts < 1000000000000) {
      ts = ts * 1000
    }
    if (ts >= 1000000000000) {
      return ts
    }
    ts = it.updatedAt
    if (ts > 1000000000 && ts < 1000000000000) {
      ts = ts * 1000
    }
    if (ts >= 1000000000000) {
      return ts
    }
    return Date.now()
  }

  static keywordHitsOf(csv: string): string[] {
    const out: string[] = []
    const parts = csv.split('、')
    for (const p of parts) {
      const w = p.trim()
      if (w.length > 0) {
        out.push(w)
      }
    }
    return out
  }

  static searchText(items: CaptureItem[], keyword: string): CaptureItem[] {
    const key = keyword.trim()
    const out: CaptureItem[] = []
    if (key.length === 0) {
      return out
    }
    for (const it of items) {
      const blob = `${it.title}${it.body}${it.customTag}`
      if (blob.indexOf(key) >= 0) {
        out.push(it)
      }
    }
    return out
  }

  static buildFrom(items: CaptureItem[], period: string, dateKey: string): InsightDigest {
    const out = new InsightDigest()
    out.id = `${period}_${dateKey}`
    out.period = period
    out.dateKey = dateKey
    out.captureCount = items.length
    out.generatedAt = Date.now()
    for (const it of items) {
      const cat = CategoryEmojiUtil.normalize(it.category)
      if (cat === 'work_tip') {
        out.workCount += 1
      } else if (cat === 'life_wiki') {
        out.lifeCount += 1
      } else if (cat === 'growth') {
        out.studyCount += 1
      } else {
        out.sparkCount += 1
      }
    }
    const hits = InsightEngine.extractKeywords(items)
    const words: string[] = []
    let i = 0
    for (const h of hits) {
      if (i >= 6) {
        break
      }
      words.push(h.word)
      i += 1
    }
    out.keywordCsv = words.join('、')
    out.summary = InsightEngine.composeSummary(items, words, period)
    return out
  }

  static dateOf(ts: number): string {
    const d = new Date(ts)
    const m = d.getMonth() + 1
    const day = d.getDate()
    const ms: string = m < 10 ? `0${m}` : `${m}`
    const ds: string = day < 10 ? `0${day}` : `${day}`
    return `${d.getFullYear()}-${ms}-${ds}`
  }

  static lastDays(endIso: string, count: number): string[] {
    const keys: string[] = []
    const y = Number.parseInt(endIso.substring(0, 4))
    const m = Number.parseInt(endIso.substring(5, 7))
    const d = Number.parseInt(endIso.substring(8, 10))
    if (Number.isNaN(y) || Number.isNaN(m) || Number.isNaN(d)) {
      return InsightEngine.lastDaysFromNow(count)
    }
    const anchor = new Date(y, m - 1, d, 12, 0, 0)
    for (let i = 0; i < count; i++) {
      const cur = new Date(anchor.getTime())
      cur.setDate(anchor.getDate() - i)
      keys.push(InsightEngine.dateOf(cur.getTime()))
    }
    return keys
  }

  static lastDaysFromNow(count: number): string[] {
    const keys: string[] = []
    const anchor = new Date()
    anchor.setHours(12, 0, 0, 0)
    for (let i = 0; i < count; i++) {
      const cur = new Date(anchor.getTime())
      cur.setDate(anchor.getDate() - i)
      keys.push(InsightEngine.dateOf(cur.getTime()))
    }
    return keys
  }

  private static composeSummary(items: CaptureItem[], words: string[], period: string): string {
    const count = items.length
    if (count === 0) {
      if (period === 'week') {
        return '近七日还没有微知识。记下一条生活百科或工作技巧后，这里会出现分类分布。'
      }
      return '今天还没有微知识。记下一条小发现，摘要会把重点轻轻收拢。'
    }
    const scope = period === 'week' ? '近七日' : '今日'
    const rows = InsightEngine.catLines(items)
    let keyLine = '尚未形成稳定关键词。'
    if (words.length > 0) {
      keyLine = `高频线索：${words.join('、')}。`
    }
    return `${scope}共 ${count} 条微知识。${rows}${keyLine}可点分类查看对应笔记，或收进个人知识库专题。`
  }

  private static catLines(items: CaptureItem[]): string {
    const parts: string[] = []
    const ids = CategoryEmojiUtil.allIds()
    for (const id of ids) {
      let n = 0
      for (const it of items) {
        if (CategoryEmojiUtil.normalize(it.category) === id) {
          n += 1
        }
      }
      if (n > 0) {
        parts.push(`${CategoryEmojiUtil.nameOf(id)} ${n}`)
      }
    }
    if (parts.length === 0) {
      return ''
    }
    return `分类：${parts.join('、')}。`
  }

  private static extractKeywords(items: CaptureItem[]): KeywordHit[] {
    const stop = InsightEngine.stopWords()
    const counts: KeywordHit[] = []
    for (const it of items) {
      const text = `${it.title}${it.body}${it.customTag}`
      const grams = InsightEngine.grams(text)
      for (const g of grams) {
        if (InsightEngine.isStop(g, stop)) {
          continue
        }
        let found: KeywordHit | null = null
        for (const c of counts) {
          if (c.word === g) {
            found = c
            break
          }
        }
        if (found !== null) {
          found.count += 1
        } else {
          const hit = new KeywordHit()
          hit.word = g
          hit.count = 1
          counts.push(hit)
        }
      }
    }
    counts.sort((a: KeywordHit, b: KeywordHit): number => {
      return b.count - a.count
    })
    return counts
  }

  private static grams(text: string): string[] {
    const out: string[] = []
    const chars: string[] = []
    for (let i = 0; i < text.length; i++) {
      const ch = text.substring(i, i + 1)
      if (InsightEngine.isCjk(ch)) {
        chars.push(ch)
      } else {
        chars.push('|')
      }
    }
    for (let i = 0; i < chars.length - 1; i++) {
      if (chars[i] !== '|' && chars[i + 1] !== '|') {
        out.push(`${chars[i]}${chars[i + 1]}`)
      }
    }
    for (let i = 0; i < chars.length - 2; i++) {
      if (chars[i] !== '|' && chars[i + 1] !== '|' && chars[i + 2] !== '|') {
        out.push(`${chars[i]}${chars[i + 1]}${chars[i + 2]}`)
      }
    }
    return out
  }

  private static isCjk(ch: string): boolean {
    if (ch.length === 0) {
      return false
    }
    const code = ch.charCodeAt(0)
    return code >= 0x4e00 && code <= 0x9fff
  }

  private static stopWords(): string[] {
    return ['的了', '了一', '一个', '我们', '自己', '什么', '如果', '因为', '所以', '但是', '然后', '还是',
      '可以', '不是', '没有', '这个', '那个', '就是', '还要', '一下', '今天', '明天', '已经']
  }

  private static isStop(word: string, stop: string[]): boolean {
    for (const s of stop) {
      if (s === word) {
        return true
      }
    }
    return word.length < 2
  }
}
