import { HttpClient } from './HttpClient'
import { CommonSenseFactsCache } from './CommonSenseFactsCache'
import { ApiResponse } from '../models/ApiModels'
import { CommonSenseTime, FactItem, FactListPayload, FactWire } from '../models/CommonSenseModels'

export class CommonSenseBizService {
  private static factCache: FactItem[] = []

  static async loadLocalFacts(): Promise<FactItem[]> {
    const cached = await CommonSenseFactsCache.loadCachedWires()
    if (cached.length > 0) {
      const out = CommonSenseFactsCache.mapWires(cached)
      if (out.length > 0) {
        CommonSenseBizService.factCache = out
        AppStorage.setOrCreate('factsLoadSource', 'cache')
        return out
      }
    }
    const boot = await CommonSenseFactsCache.loadBootstrapWires()
    if (boot.length > 0) {
      const out = CommonSenseFactsCache.mapWires(boot)
      if (out.length > 0) {
        CommonSenseBizService.factCache = out
        AppStorage.setOrCreate('factsLoadSource', 'bootstrap')
        return out
      }
    }
    return []
  }

  static async loadFacts(): Promise<FactItem[]> {
    let lastMsg = '网络请求失败'
    try {
      const res = await HttpClient.get<FactListPayload>('/biz/common-sense/facts')
      if (res.message.length > 0) {
        lastMsg = res.message
      }
      const wires = CommonSenseBizService.payloadWires(res)
      if (wires.length > 0) {
        const out = CommonSenseFactsCache.mapWires(wires)
        if (out.length > 0) {
          await CommonSenseFactsCache.saveWires(wires)
          CommonSenseBizService.factCache = out
          AppStorage.setOrCreate('factsLoadSource', 'network')
          AppStorage.setOrCreate('factsLoadHint', '')
          return out
        }
      }
    } catch {
    }

    const local = await CommonSenseBizService.loadLocalFacts()
    if (local.length > 0) {
      AppStorage.setOrCreate('factsLoadHint', lastMsg)
      return local
    }

    AppStorage.setOrCreate('factsLoadSource', 'empty')
    AppStorage.setOrCreate('factsLoadHint', lastMsg)
    return []
  }

  private static payloadWires(res: ApiResponse<FactListPayload>): FactWire[] {
    try {
      if (res.code !== 0) {
        return []
      }
      if (res.data === undefined) {
        return []
      }
      const list = res.data.list
      if (list === undefined) {
        return []
      }
      return list
    } catch {
      return []
    }
  }

  static async findFact(id: string): Promise<FactItem | undefined> {
    for (const item of CommonSenseBizService.factCache) {
      if (item.id === id) {
        return item
      }
    }
    try {
      const res = await HttpClient.get<FactWire>(`/biz/common-sense/facts/${id}`)
      if (res.code === 0 && res.data !== undefined) {
        const item = FactItem.fromWire(res.data)
        CommonSenseBizService.mergeFact(item)
        return item
      }
    } catch {
    }
    return undefined
  }

  static filterByCategory(list: FactItem[], category: string): FactItem[] {
    if (category.length === 0 || category === 'all') {
      return list
    }
    const out: FactItem[] = []
    for (const item of list) {
      if (item.category === category) {
        out.push(item)
      }
    }
    return out
  }

  static search(list: FactItem[], keyword: string): FactItem[] {
    const q = keyword.trim()
    if (q.length === 0) {
      return list
    }
    const out: FactItem[] = []
    for (const item of list) {
      if (item.title.indexOf(q) >= 0 ||
        item.summary.indexOf(q) >= 0 ||
        item.body.indexOf(q) >= 0 ||
        item.tags.indexOf(q) >= 0) {
        out.push(item)
      }
    }
    return out
  }

  static filterByScene(list: FactItem[], scene: string): FactItem[] {
    if (scene.length === 0 || scene === 'all') {
      return list
    }
    const out: FactItem[] = []
    for (const item of list) {
      if (item.scene === scene) {
        out.push(item)
      }
    }
    return out
  }

  static relatedFacts(list: FactItem[], current: FactItem, limit: number): FactItem[] {
    const same: FactItem[] = []
    const rest: FactItem[] = []
    for (const item of list) {
      if (item.id === current.id) {
        continue
      }
      if (item.category === current.category || item.scene === current.scene) {
        same.push(item)
      } else {
        rest.push(item)
      }
    }
    const out: FactItem[] = []
    for (const item of same) {
      if (out.length < limit) {
        out.push(item)
      }
    }
    for (const item of rest) {
      if (out.length < limit) {
        out.push(item)
      }
    }
    return out
  }

  static pickToday(list: FactItem[]): FactItem {
    if (list.length === 0) {
      return new FactItem()
    }
    const today = CommonSenseTime.todayKey()
    for (const item of list) {
      if (item.publishDate === today) {
        return item
      }
    }
    return list[list.length - 1]
  }

  static pickRandom(list: FactItem[]): FactItem {
    if (list.length === 0) {
      return new FactItem()
    }
    const idx = Math.floor(Math.random() * list.length)
    return list[idx]
  }

  static factForDate(list: FactItem[], dateKey: string): FactItem | undefined {
    for (const item of list) {
      if (item.publishDate === dateKey) {
        return item
      }
    }
    return undefined
  }

  static hotTags(list: FactItem[], limit: number): string[] {
    const pairs: TagCountPair[] = []
    for (const item of list) {
      const tags = item.tagList()
      for (const tag of tags) {
        let found = false
        for (let i = 0; i < pairs.length; i++) {
          if (pairs[i].tag === tag) {
            pairs[i].count = pairs[i].count + 1
            found = true
            break
          }
        }
        if (!found) {
          const pair = new TagCountPair()
          pair.tag = tag
          pair.count = 1
          pairs.push(pair)
        }
      }
    }
    pairs.sort((a: TagCountPair, b: TagCountPair) => b.count - a.count)
    const out: string[] = []
    for (let i = 0; i < pairs.length && i < limit; i++) {
      out.push(pairs[i].tag)
    }
    return out
  }

  static cachedFacts(): FactItem[] {
    const copy: FactItem[] = []
    for (const item of CommonSenseBizService.factCache) {
      copy.push(item)
    }
    return copy
  }

  private static mergeFact(item: FactItem): void {
    const next: FactItem[] = []
    let replaced = false
    for (const row of CommonSenseBizService.factCache) {
      if (row.id === item.id) {
        next.push(item)
        replaced = true
      } else {
        next.push(row)
      }
    }
    if (!replaced) {
      next.push(item)
    }
    CommonSenseBizService.factCache = next
  }
}

class TagCountPair {
  tag: string = ''
  count: number = 0
}
