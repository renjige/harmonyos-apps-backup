import { WisdomQuote } from '../models/JianModels'
import { JianStore } from './JianStore'
import { MoodCatalog } from './MoodCatalog'

export class WisdomService {
  private static morningQuotes(): WisdomQuote[] {
    return [
      WisdomQuote.create('m1', '晨光微照，今日宜慢下来，写下一笺心事。', '清晨陪伴', 'morning'),
      WisdomQuote.create('m2', '一日之计在于静，先安顿内心，再奔赴人间。', '清晨陪伴', 'morning'),
      WisdomQuote.create('m3', '把焦虑留在昨夜，把温柔交给此刻的纸笺。', '清晨陪伴', 'morning')
    ]
  }

  private static dayQuotes(): WisdomQuote[] {
    return [
      WisdomQuote.create('d1', '光阴不语，却在每一行字里留下痕迹。', '日间陪伴', 'day'),
      WisdomQuote.create('d2', '记录不是负担，是与自己温柔对话的仪式。', '日间陪伴', 'day'),
      WisdomQuote.create('d3', '心有所感，便落笔成笺；不必完美，只需真实。', '日间陪伴', 'day')
    ]
  }

  private static nightQuotes(): WisdomQuote[] {
    return [
      WisdomQuote.create('n1', '夜阑人静，把今日轻轻合上，留一页空白给明日。', '夜晚陪伴', 'night'),
      WisdomQuote.create('n2', '星光很淡，心绪很软，写下一笺便是与自己和解。', '夜晚陪伴', 'night'),
      WisdomQuote.create('n3', '今日已足够，不必苛责；静时笺会替你记得。', '夜晚陪伴', 'night')
    ]
  }

  static periodOfDay(): string {
    const h = new Date().getHours()
    if (h >= 5 && h < 11) {
      return 'morning'
    }
    if (h >= 11 && h < 18) {
      return 'day'
    }
    return 'night'
  }

  static async dailyQuote(): Promise<WisdomQuote> {
    const period = WisdomService.periodOfDay()
    let pool: WisdomQuote[] = WisdomService.dayQuotes()
    if (period === 'morning') {
      pool = WisdomService.morningQuotes()
    } else if (period === 'night') {
      pool = WisdomService.nightQuotes()
    }
    const entries = await JianStore.loadAll()
    let moodHint = ''
    if (entries.length > 0) {
      const recent = entries[0]
      if (recent.moodId.length > 0) {
        moodHint = MoodCatalog.labelOf(recent.moodId)
      }
    }
    const dayIndex = new Date().getDate() % pool.length
    const q = pool[dayIndex]
    if (moodHint.length > 0) {
      q.hint = `基于近期「${moodHint}」心境 · ${q.hint}`
    }
    return q
  }

  static allForPeriod(period: string): WisdomQuote[] {
    if (period === 'morning') {
      return WisdomService.morningQuotes()
    }
    if (period === 'night') {
      return WisdomService.nightQuotes()
    }
    return WisdomService.dayQuotes()
  }
}
