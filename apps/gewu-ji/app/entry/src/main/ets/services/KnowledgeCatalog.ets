import { KnowledgeCategory, KnowledgeObject } from '../models/KnowledgeModels'
import { KnowledgeSeed } from '../data/KnowledgeSeed'
import { AtlasSeed } from '../data/AtlasSeed'
import { QuizItem, QuizOption } from '../models/FieldModels'

export class KnowledgeCatalog {
  private static pool: KnowledgeObject[] = []

  static loadPool(): KnowledgeObject[] {
    if (KnowledgeCatalog.pool.length === 0) {
      const base = KnowledgeSeed.buildPool()
      KnowledgeCatalog.applyLegacyAtlas(base)
      const extra = AtlasSeed.buildPool()
      for (const item of extra) {
        base.push(item)
      }
      KnowledgeCatalog.pool = base
    }
    return KnowledgeCatalog.pool
  }

  static resolveById(id: string): KnowledgeObject | undefined {
    const list = KnowledgeCatalog.loadPool()
    for (const item of list) {
      if (item.id === id) {
        return item
      }
    }
    return undefined
  }

  static dayOfYear(): number {
    const now = new Date()
    const start = new Date(now.getFullYear(), 0, 0)
    const diff = now.getTime() - start.getTime()
    const oneDay = 1000 * 60 * 60 * 24
    return Math.floor(diff / oneDay)
  }

  static todayObject(): KnowledgeObject {
    const list = KnowledgeCatalog.loadPool()
    if (list.length === 0) {
      return new KnowledgeObject()
    }
    const idx = KnowledgeCatalog.dayOfYear() % list.length
    return list[idx]
  }

  static filterByCategory(category: KnowledgeCategory): KnowledgeObject[] {
    const list = KnowledgeCatalog.loadPool()
    const out: KnowledgeObject[] = []
    for (const item of list) {
      if (item.category === category) {
        out.push(item)
      }
    }
    return out
  }

  static search(keyword: string): KnowledgeObject[] {
    const q = keyword.trim()
    const list = KnowledgeCatalog.loadPool()
    if (q.length === 0) {
      return list
    }
    const out: KnowledgeObject[] = []
    for (const item of list) {
      if (item.title.indexOf(q) >= 0 || item.summary.indexOf(q) >= 0 ||
        item.category.indexOf(q) >= 0 || item.atlasKind.indexOf(q) >= 0) {
        out.push(item)
      }
    }
    return out
  }

  static relatedOf(id: string): KnowledgeObject[] {
    const self = KnowledgeCatalog.resolveById(id)
    const out: KnowledgeObject[] = []
    if (self === undefined) {
      return out
    }
    const list = KnowledgeCatalog.loadPool()
    for (const item of list) {
      if (item.id !== id && item.category === self.category) {
        out.push(item)
      }
      if (out.length >= 2) {
        break
      }
    }
    return out
  }

  static inquiryPrompts(): string[] {
    const q: string[] = []
    q.push('此物当初要解决什么问题？')
    q.push('它如何改变了当时人们的生活？')
    q.push('今天我们还能从中学到什么？')
    return q
  }

  static filterByAtlas(kind: string): KnowledgeObject[] {
    const list = KnowledgeCatalog.loadPool()
    const out: KnowledgeObject[] = []
    for (const item of list) {
      if (kind === 'all' || item.atlasKind === kind) {
        out.push(item)
      }
    }
    return out
  }

  static defaultCover(atlasKind: string): string {
    if (atlasKind === '植物图鉴') {
      return 'atlas_lotus'
    }
    if (atlasKind === '动物图鉴') {
      return 'atlas_sparrow'
    }
    if (atlasKind === '昆虫图鉴') {
      return 'atlas_cicada'
    }
    if (atlasKind === '矿物图鉴') {
      return 'atlas_quartz'
    }
    return 'atlas_teapot'
  }

  static relatedKnowledge(atlasKind: string, excludeId: string): KnowledgeObject[] {
    const list = KnowledgeCatalog.loadPool()
    const out: KnowledgeObject[] = []
    for (const item of list) {
      if (item.id !== excludeId && item.atlasKind === atlasKind) {
        out.push(item)
      }
      if (out.length >= 3) {
        break
      }
    }
    return out
  }

  private static applyLegacyAtlas(list: KnowledgeObject[]): void {
    for (const item of list) {
      if (item.id === 'gw006' || item.id === 'gw015' || item.id === 'gw017') {
        item.atlasKind = '植物图鉴'
      } else if (item.id === 'gw004' || item.id === 'gw013' || item.id === 'gw018') {
        item.atlasKind = '矿物图鉴'
      } else {
        item.atlasKind = '日常物品'
      }
    }
  }

  static allCategories(): KnowledgeCategory[] {
    const cats: KnowledgeCategory[] = ['历史', '科学', '文化', '哲学', '艺术']
    return cats
  }

  static buildQuiz(obj: KnowledgeObject): QuizItem[] {
    const pool = KnowledgeCatalog.loadPool()
    const items: QuizItem[] = []
    const seed = KnowledgeCatalog.dayOfYear()
    for (const f of obj.facts) {
      if (items.length >= 3) {
        break
      }
      const bucket: QuizOption[] = []
      const ok = new QuizOption()
      ok.text = f.content
      ok.ok = true
      bucket.push(ok)
      for (const other of pool) {
        if (other.id === obj.id) {
          continue
        }
        for (const ofact of other.facts) {
          if (ofact.content !== f.content && bucket.length < 3) {
            const w = new QuizOption()
            w.text = ofact.content
            w.ok = false
            bucket.push(w)
          }
        }
      }
      if (bucket.length < 2) {
        continue
      }
      const q = new QuizItem()
      q.prompt = `「${obj.title}」的「${f.label}」对应哪一项？`
      q.options = KnowledgeCatalog.rotateOptions(bucket, seed + items.length)
      items.push(q)
    }
    return items
  }

  private static rotateOptions(opts: QuizOption[], seed: number): QuizOption[] {
    const len = opts.length
    const out: QuizOption[] = []
    if (len === 0) {
      return out
    }
    const start = seed % len
    let step = 0
    while (step < len) {
      const want = (start + step) % len
      let i = 0
      for (const o of opts) {
        if (i === want) {
          out.push(o)
        }
        i++
      }
      step++
    }
    return out
  }
}
