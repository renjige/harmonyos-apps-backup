import { ElementCatalog, ElementRecord } from '../data/ElementCatalog'
import { ChallengeBank, ChallengeQuestion } from '../data/ChallengeBank'
import { TopicBank, ExploreTopic } from '../data/TopicBank'

export class ElementService {
  static all(): ElementRecord[] {
    return ElementCatalog.all()
  }

  static findBySymbol(symbol: string): ElementRecord | undefined {
    return ElementCatalog.findBySymbol(symbol)
  }

  static findByNumber(n: number): ElementRecord | undefined {
    return ElementCatalog.findByNumber(n)
  }

  static filterByGroup(filterGroup: string): ElementRecord[] {
    if (filterGroup.length === 0 || filterGroup === 'all') {
      return ElementCatalog.all()
    }
    return ElementCatalog.filterByGroup(filterGroup)
  }

  static dayOfYear(): number {
    const d = new Date()
    const start = new Date(d.getFullYear(), 0, 0)
    const diff = d.getTime() - start.getTime()
    return Math.floor(diff / (24 * 60 * 60 * 1000))
  }

  static dailyExplore(): ElementRecord {
    const all = ElementCatalog.all()
    if (all.length === 0) {
      return new ElementRecord()
    }
    const idx = ElementService.dayOfYear() % all.length
    return all[idx]
  }

  static featuredTopics(count: number): ExploreTopic[] {
    const all = TopicBank.all()
    const start = ElementService.dayOfYear() % all.length
    const out: ExploreTopic[] = []
    let i = 0
    while (i < count && i < all.length) {
      out.push(all[(start + i) % all.length])
      i++
    }
    return out
  }

  static search(keyword: string): ElementRecord[] {
    const q = keyword.trim().toLowerCase()
    if (q.length === 0) {
      return []
    }
    const out: ElementRecord[] = []
    for (const item of ElementCatalog.all()) {
      const numStr = `${item.atomicNumber}`
      if (item.symbol.toLowerCase() === q ||
        item.nameCn.indexOf(keyword.trim()) >= 0 ||
        item.nameEn.toLowerCase().indexOf(q) >= 0 ||
        numStr === q) {
        out.push(item)
      }
    }
    return out
  }

  static sameGroup(symbol: string): ElementRecord[] {
    const base = ElementCatalog.findBySymbol(symbol)
    if (base === undefined) {
      return []
    }
    const out: ElementRecord[] = []
    for (const item of ElementCatalog.all()) {
      if (item.group === base.group && item.period > 0) {
        out.push(item)
      }
    }
    return out
  }

  static samePeriod(symbol: string): ElementRecord[] {
    const base = ElementCatalog.findBySymbol(symbol)
    if (base === undefined) {
      return []
    }
    const out: ElementRecord[] = []
    for (const item of ElementCatalog.all()) {
      if (item.period === base.period) {
        out.push(item)
      }
    }
    return out
  }

  static related(symbol: string): ElementRecord[] {
    const base = ElementCatalog.findBySymbol(symbol)
    if (base === undefined) {
      return []
    }
    const out: ElementRecord[] = []
    for (const sym of base.relatedSymbols) {
      const found = ElementCatalog.findBySymbol(sym)
      if (found !== undefined) {
        out.push(found)
      }
    }
    return out
  }

  static quizSession(type: string): ChallengeQuestion[] {
    const pool = ChallengeBank.byType(type)
    if (pool.length === 0) {
      return []
    }
    const start = ElementService.dayOfYear() % pool.length
    const out: ChallengeQuestion[] = []
    let i = 0
    while (i < 5 && i < pool.length) {
      out.push(pool[(start + i) % pool.length])
      i++
    }
    return out
  }

  static challengeTypeLabel(type: string): string {
    if (type === 'identify') {
      return '符号识别'
    }
    if (type === 'property') {
      return '性质判断'
    }
    if (type === 'family') {
      return '家族归属'
    }
    if (type === 'life') {
      return '生活应用'
    }
    if (type === 'relation') {
      return '元素关系'
    }
    return '探索挑战'
  }

  static challengeTypeSummary(type: string): string {
    if (type === 'identify') {
      return '根据序数与中文名识别元素符号'
    }
    if (type === 'property') {
      return '判断状态、丰度与典型化学性质'
    }
    if (type === 'family') {
      return '碱金属、卤素、稀有气体等同族辨析'
    }
    if (type === 'life') {
      return '从日常场景反推对应元素'
    }
    if (type === 'relation') {
      return '常见化合物与伴生元素联想'
    }
    return '完成 5 题测验巩固记忆'
  }
}
