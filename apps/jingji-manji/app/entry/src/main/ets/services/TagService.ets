import { SportRecord } from '../models/SportModels'
import { SportStore } from './SportStore'

export class TagItem {
  name: string = ''
  count: number = 0
}

export class RecordFilter {
  keyword: string = ''
  sportType: string = ''
  feeling: string = ''
  tag: string = ''
}

export class TagService {
  static parseTags(text: string): string[] {
    const out: string[] = []
    const parts = text.split(/[\s,，]+/)
    for (const part of parts) {
      const t = part.trim()
      if (t.startsWith('#') && t.length > 1) {
        out.push(t.substring(1))
      }
    }
    return out
  }

  static allTags(): TagItem[] {
    const map: TagItem[] = []
    for (const r of SportStore.list()) {
      const tags = TagService.parseTags(r.tags)
      for (const tag of tags) {
        let hit = false
        for (const item of map) {
          if (item.name === tag) {
            item.count += 1
            hit = true
            break
          }
        }
        if (!hit) {
          const item = new TagItem()
          item.name = tag
          item.count = 1
          map.push(item)
        }
      }
    }
    map.sort((a: TagItem, b: TagItem) => b.count - a.count)
    return map
  }

  static filter(filter: RecordFilter): SportRecord[] {
    const all = SportStore.list()
    const out: SportRecord[] = []
    for (const r of all) {
      if (filter.sportType.length > 0 && r.sportType !== filter.sportType) {
        continue
      }
      if (filter.feeling.length > 0 && r.feeling !== filter.feeling) {
        continue
      }
      if (filter.tag.length > 0) {
        const tags = TagService.parseTags(r.tags)
        let tagHit = false
        for (const t of tags) {
          if (t === filter.tag) {
            tagHit = true
            break
          }
        }
        if (!tagHit) {
          continue
        }
      }
      if (filter.keyword.length > 0) {
        const kw = filter.keyword.toLowerCase()
        const blob = `${r.sportType}${r.tags}${r.note}${r.takeaway}${r.nextFocus}`.toLowerCase()
        if (!blob.includes(kw)) {
          continue
        }
      }
      out.push(r)
    }
    return out
  }
}
