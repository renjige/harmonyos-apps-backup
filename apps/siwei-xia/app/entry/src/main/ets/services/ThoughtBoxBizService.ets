import { CatalogItem, CatalogListData } from '../models/ThoughtModels'
import { HttpClient } from './HttpClient'

export class ThoughtBoxBizService {
  static async loadTags(): Promise<CatalogItem[]> {
    return ThoughtBoxBizService.loadList('/biz/thought-box/tags')
  }

  static async loadLexicon(): Promise<CatalogItem[]> {
    return ThoughtBoxBizService.loadList('/biz/thought-box/lexicon')
  }

  static async loadGuides(): Promise<CatalogItem[]> {
    return ThoughtBoxBizService.loadList('/biz/thought-box/guides')
  }

  private static async loadList(path: string): Promise<CatalogItem[]> {
    const res = await HttpClient.get<CatalogListData>(path)
    const out: CatalogItem[] = []
    if (res.code !== 0 || res.data === undefined || res.data.list === undefined) {
      return out
    }
    for (const raw of res.data.list) {
      const row = new CatalogItem()
      row.id = ThoughtBoxBizService.textOf(raw.id)
      row.title = ThoughtBoxBizService.textOf(raw.title)
      const body = ThoughtBoxBizService.textOf(raw.body)
      const summary = ThoughtBoxBizService.textOf(raw.summary)
      row.body = body.length > 0 ? body : summary
      row.coverKey = ThoughtBoxBizService.textOf(raw.coverKey)
      if (row.coverKey.length === 0) {
        row.coverKey = ThoughtBoxBizService.textOf(raw.coverMedia)
      }
      row.tags = ThoughtBoxBizService.textOf(raw.tags)
      row.keywords = ThoughtBoxBizService.textOf(raw.keywords)
      if (row.coverKey.length === 0) {
        row.coverKey = 'cover_tags'
      }
      out.push(row)
    }
    return out
  }

  private static textOf(v: string): string {
    if (v === undefined || v === null) {
      return ''
    }
    return v
  }
}
