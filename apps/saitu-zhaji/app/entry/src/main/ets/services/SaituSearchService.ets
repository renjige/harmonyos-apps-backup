import { SearchResultItem } from '../models/SaituGrowthModels'
import { SaituLocalStore } from './SaituLocalStore'
import { SaituTrackStore } from './SaituTrackStore'
import { SaituSportStore } from './SaituSportStore'

export class SaituSearchService {
  static async search(keyword: string, kindFilter: string, favoritesOnly: boolean): Promise<SearchResultItem[]> {
    const q = keyword.trim().toLowerCase()
    const out: SearchResultItem[] = []

    if (kindFilter === 'all' || kindFilter === 'record' || kindFilter === 'favorite') {
      const records = await SaituLocalStore.loadRecords()
      for (const r of records) {
        if (favoritesOnly && !r.favorite) {
          continue
        }
        if (kindFilter === 'record' || kindFilter === 'all' || (kindFilter === 'favorite' && r.favorite)) {
          if (SaituSearchService.matchRecord(r.content, r.tags, q)) {
            const item = new SearchResultItem()
            item.id = r.id
            item.kind = 'record'
            item.title = r.summaryLine(48)
            item.subtitle = r.tags.join(' · ')
            item.timestamp = r.createdAt
            item.favorite = r.favorite
            out.push(item)
          }
        }
      }
    }

    if (kindFilter === 'all' || kindFilter === 'sport' || kindFilter === 'favorite') {
      const events = await SaituSportStore.loadEvents()
      for (const e of events) {
        if (favoritesOnly && !e.favorite) {
          continue
        }
        if (kindFilter === 'sport' || kindFilter === 'all' || (kindFilter === 'favorite' && e.favorite)) {
          const hay = `${e.title} ${e.highlight} ${e.body} ${e.tags}`.toLowerCase()
          if (q.length === 0 || hay.indexOf(q) >= 0) {
            const item = new SearchResultItem()
            item.id = e.id
            item.kind = 'sport'
            item.title = e.title.length > 0 ? e.title : e.kindLabel()
            item.subtitle = `${e.kindLabel()} · ${e.eventDate}`
            item.timestamp = e.createdAt
            item.favorite = e.favorite
            out.push(item)
          }
        }
      }
    }

    if (kindFilter === 'all' || kindFilter === 'insight') {
      const insights = await SaituTrackStore.loadInsights()
      for (const s of insights) {
        if (favoritesOnly && !s.favorite) {
          continue
        }
        const hay = `${s.body} ${s.keywords}`.toLowerCase()
        if (q.length === 0 || hay.indexOf(q) >= 0) {
          const item = new SearchResultItem()
          item.id = s.id
          item.kind = 'insight'
          item.title = s.summaryLine()
          item.subtitle = s.periodLabel
          item.timestamp = s.createdAt
          item.favorite = s.favorite
          out.push(item)
        }
      }
    }

    out.sort((a, b) => b.timestamp - a.timestamp)
    return out
  }

  static async favoriteCount(): Promise<number> {
    let count = 0
    const records = await SaituLocalStore.loadRecords()
    for (const r of records) {
      if (r.favorite) {
        count++
      }
    }
    const events = await SaituSportStore.loadEvents()
    for (const e of events) {
      if (e.favorite) {
        count++
      }
    }
    const insights = await SaituTrackStore.loadInsights()
    for (const s of insights) {
      if (s.favorite) {
        count++
      }
    }
    return count
  }

  private static matchRecord(content: string, tags: string[], q: string): boolean {
    if (q.length === 0) {
      return true
    }
    if (content.toLowerCase().indexOf(q) >= 0) {
      return true
    }
    for (const t of tags) {
      if (t.toLowerCase().indexOf(q) >= 0) {
        return true
      }
    }
    return false
  }
}
