import { MicroEssay, TagCloudItem } from '../models/EssayModels'

const STOP_WORDS: string[] = [
  '的', '了', '在', '是', '我', '有', '和', '就', '不', '人', '都', '一', '一个', '上', '也', '很',
  '到', '说', '要', '去', '你', '会', '着', '没有', '看', '好', '自己', '这', '那', '今天', '然后', '觉得'
]

export class SmartTagService {
  static extractFromText(title: string, body: string, limit: number): string[] {
    const text = `${title} ${MicroEssay.stripMarkup(body)}`
    const map = new Map<string, number>()
    SmartTagService.tokenize(text, map)
    SmartTagService.ngramChinese(text, map)
    const items: TagCloudItem[] = []
    map.forEach((count, word) => {
      const t = new TagCloudItem()
      t.name = word
      t.count = count
      items.push(t)
    })
    items.sort((a, b) => b.count - a.count)
    const out: string[] = []
    for (const it of items) {
      if (out.length >= limit) {
        break
      }
      out.push(it.name)
    }
    return out
  }

  static async buildCloud(essays: MicroEssay[]): Promise<TagCloudItem[]> {
    const map = new Map<string, number>()
    for (const e of essays) {
      for (const t of e.tagList()) {
        const prev = map.get(t) ?? 0
        map.set(t, prev + 1)
      }
      const auto = SmartTagService.extractFromText(e.title, e.body, 3)
      for (const t of auto) {
        if (!e.tagList().includes(t)) {
          const prev = map.get(t) ?? 0
          map.set(t, prev + 1)
        }
      }
    }
    const items: TagCloudItem[] = []
    map.forEach((count, name) => {
      const t = new TagCloudItem()
      t.name = name
      t.count = count
      items.push(t)
    })
    items.sort((a, b) => b.count - a.count)
    return items
  }

  static mergeTags(existing: string[], suggested: string[], maxTags: number): string[] {
    const set = new Set<string>()
    const out: string[] = []
    for (const t of existing) {
      const s = t.trim()
      if (s.length > 0 && !set.has(s)) {
        set.add(s)
        out.push(s)
      }
    }
    for (const t of suggested) {
      if (out.length >= maxTags) {
        break
      }
      const s = t.trim()
      if (s.length > 0 && !set.has(s)) {
        set.add(s)
        out.push(s)
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
      if (SmartTagService.isStop(p)) {
        continue
      }
      const prev = map.get(p) ?? 0
      map.set(p, prev + 1)
    }
  }

  private static ngramChinese(text: string, map: Map<string, number>): void {
    const chars: string[] = []
    for (let i = 0; i < text.length; i++) {
      const ch = text.charAt(i)
      const code = ch.codePointAt(0) ?? 0
      if (code >= 0x4e00 && code <= 0x9fff) {
        chars.push(ch)
      }
    }
    for (let i = 0; i < chars.length - 1; i++) {
      const bi = `${chars[i]}${chars[i + 1]}`
      if (SmartTagService.isStop(bi)) {
        continue
      }
      const prev = map.get(bi) ?? 0
      map.set(bi, prev + 1)
    }
  }

  private static isStop(word: string): boolean {
    for (const sw of STOP_WORDS) {
      if (word === sw) {
        return true
      }
    }
    return false
  }
}
