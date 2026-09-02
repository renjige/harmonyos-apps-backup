import { QuoteCard } from '../models/ZhiweiModels'

export class QuoteCatalog {
  static all(): QuoteCard[] {
    const list: QuoteCard[] = []
    list.push(QuoteCatalog.make('q01', '知微见著，把琐碎收成一条线索。', '知微集', '洞察', 'cover_spark'))
    list.push(QuoteCatalog.make('q02', '写下来的东西，才有机会被重新看见。', '收录札记', '收录', 'cover_work'))
    list.push(QuoteCatalog.make('q03', '一天只需一条清楚的重点，胜过十页含糊的计划。', '效率手记', '工作', 'cover_study'))
    list.push(QuoteCatalog.make('q04', '生活里的微光，往往藏在随手记下的半句话里。', '生活札', '生活', 'cover_life'))
    list.push(QuoteCatalog.make('q05', '整理不是为了完美，是为了下次能更快找到。', '整理观', '学习', 'empty_ink'))
    list.push(QuoteCatalog.make('q06', '优先级一旦标明，犹豫就会少一半。', '决断短笺', '工作', 'cover_work'))
    list.push(QuoteCatalog.make('q07', '灵感怕拖延，不怕短小。', '灵感边注', '灵感', 'cover_spark'))
    list.push(QuoteCatalog.make('q08', '每周回头看一次分类，比每天焦虑更有用。', '周记观', '洞察', 'cover_study'))
    list.push(QuoteCatalog.make('q09', '把听见的话变成文字，它就不再只是空气。', '口述备忘', '收录', 'cover_life'))
    list.push(QuoteCatalog.make('q10', '细处认真，大处才站得住。', '知微集', '洞察', 'empty_ink'))
    return list
  }

  static todayQuotes(): QuoteCard[] {
    const pool = QuoteCatalog.all()
    const seed = QuoteCatalog.daySeed()
    const picked: QuoteCard[] = []
    const start = seed % pool.length
    for (let n = 0; n < 5 && n < pool.length; n++) {
      const idx = (start + n) % pool.length
      picked.push(pool[idx])
    }
    return picked
  }

  static findById(id: string): QuoteCard | null {
    const pool = QuoteCatalog.all()
    for (const q of pool) {
      if (q.id === id) {
        return q
      }
    }
    return null
  }

  private static make(id: string, text: string, author: string, theme: string, coverKey: string): QuoteCard {
    const q = new QuoteCard()
    q.id = id
    q.text = text
    q.author = author
    q.theme = theme
    q.coverKey = coverKey
    return q
  }

  private static daySeed(): number {
    const d = new Date()
    return d.getFullYear() * 10000 + (d.getMonth() + 1) * 100 + d.getDate()
  }
}
