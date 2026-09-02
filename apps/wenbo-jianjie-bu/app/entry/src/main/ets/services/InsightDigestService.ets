import { InsightEntry, KeywordItem } from '../models/InsightModels'
import { DateHelper } from './DateHelper'
import { InsightStore } from './InsightStore'

export class InsightDigestService {
  static async weekDigest(): Promise<string> {
    const days = DateHelper.lastNDays(7)
    const list = await InsightStore.loadAll()
    const recent: InsightEntry[] = []
    for (const n of list) {
      for (const d of days) {
        if (n.dateKey === d) {
          recent.push(n)
        }
      }
    }
    if (recent.length === 0) {
      return '本周还没有写下见解。点「+」记下此刻的思考，智慧摘要会在这里慢慢长出来。'
    }
    const words = InsightDigestService.keywordsFrom(recent)
    let top = '思考'
    let second = ''
    let wi = 0
    for (const w of words) {
      if (wi === 0) {
        top = w.word
      }
      if (wi === 1) {
        second = `、${w.word}`
      }
      wi++
    }
    let firstTitle = '未命名'
    for (const n of recent) {
      firstTitle = n.title
      break
    }
    return `近七日你写下了 ${recent.length} 条见解。高频主题偏「${top}${second}」。最近一条是「${firstTitle}」。继续写，洞见会更清楚。`
  }

  static async todayDigest(): Promise<string> {
    const today = DateHelper.todayKey()
    const list = await InsightStore.loadAll()
    const todayItems: InsightEntry[] = []
    for (const n of list) {
      if (n.dateKey === today) {
        todayItems.push(n)
      }
    }
    if (todayItems.length === 0) {
      return '今天还没有记录。用一条短见解开启今天的思考。'
    }
    return `今日已沉淀 ${todayItems.length} 条。先回看标题，再决定要不要补一句「所以呢」。`
  }

  static async keywordCloud(): Promise<KeywordItem[]> {
    const list = await InsightStore.loadAll()
    return InsightDigestService.keywordsFrom(list)
  }

  static keywordsFrom(list: InsightEntry[]): KeywordItem[] {
    const map = new Map<string, number>()
    const order: string[] = []
    for (const n of list) {
      InsightDigestService.collect(n.title, map, order)
      InsightDigestService.collect(n.body, map, order)
      const tags = n.tagList()
      for (const t of tags) {
        InsightDigestService.addWord(t, map, order)
      }
    }
    const items: KeywordItem[] = []
    let max = 1
    for (const w of order) {
      const c = map.get(w)
      const count = c !== undefined ? c : 0
      if (count > max) {
        max = count
      }
      const it = new KeywordItem()
      it.word = w
      it.count = count
      items.push(it)
    }
    items.sort((a, b) => b.count - a.count)
    const top: KeywordItem[] = []
    let i = 0
    for (const it of items) {
      if (i >= 24) {
        break
      }
      it.weight = max > 0 ? it.count / max : 1
      top.push(it)
      i++
    }
    return top
  }

  private static collect(text: string, map: Map<string, number>, order: string[]): void {
    let buf = ''
    for (let i = 0; i < text.length; i++) {
      const ch = text.substring(i, i + 1)
      const code = text.charCodeAt(i)
      const isCjk = code >= 0x4E00 && code <= 0x9FFF
      const isLetter = (code >= 65 && code <= 90) || (code >= 97 && code <= 122)
      const isDigit = code >= 48 && code <= 57
      if (isCjk || isLetter || isDigit) {
        buf = `${buf}${ch}`
      } else {
        if (buf.length >= 2 && buf.length <= 8 && !InsightDigestService.isStop(buf)) {
          InsightDigestService.addWord(buf, map, order)
        }
        buf = ''
      }
    }
    if (buf.length >= 2 && buf.length <= 8 && !InsightDigestService.isStop(buf)) {
      InsightDigestService.addWord(buf, map, order)
    }
  }

  private static addWord(word: string, map: Map<string, number>, order: string[]): void {
    if (!map.has(word)) {
      map.set(word, 0)
      order.push(word)
    }
    const cur = map.get(word)
    map.set(word, (cur !== undefined ? cur : 0) + 1)
  }

  private static isStop(w: string): boolean {
    const stops = '的了是在我有和就都不人也这上下要会把比那来去对与而及或所以如果因为可以自己什么一个不是还是没有这个我们你们他们然后但是于是今天明天'
    return stops.indexOf(w) >= 0
  }
}
