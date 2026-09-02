import { CatalogItem, ThoughtCard } from '../models/ThoughtModels'

export class ClassifyService {
  static suggest(body: string, lexicon: CatalogItem[]): string[] {
    const text = body.toLowerCase()
    const out: string[] = []
    for (const row of lexicon) {
      const key = row.keywords.length > 0 ? row.keywords : row.title
      if (key.length > 0 && text.indexOf(key.toLowerCase()) >= 0) {
        const tag = row.tags.length > 0 ? row.tags : row.title
        ClassifyService.pushUnique(out, tag)
      }
    }
    const local: string[][] = [
      ['会议', '纪要', '对齐', '工作'],
      ['产品', '迭代', '需求', '项目'],
      ['读书', '摘录', '书评', '阅读'],
      ['散步', '晚饭', '周末', '生活'],
      ['点子', '突然想到', '如果', '灵感'],
      ['结构', '分层', '导图', '项目']
    ]
    for (const row of local) {
      if (text.indexOf(row[0]) >= 0 || text.indexOf(row[1]) >= 0 || text.indexOf(row[2]) >= 0) {
        ClassifyService.pushUnique(out, row[3])
      }
    }
    return out
  }

  static applyTags(card: ThoughtCard, tags: string[]): void {
    const now = card.tags()
    for (const t of tags) {
      ClassifyService.pushUnique(now, t)
    }
    card.tagsCsv = now.join(',')
  }

  static pushUnique(list: string[], name: string): void {
    const n = name.trim()
    if (n.length === 0) {
      return
    }
    for (const it of list) {
      if (it === n) {
        return
      }
    }
    list.push(n)
  }
}
