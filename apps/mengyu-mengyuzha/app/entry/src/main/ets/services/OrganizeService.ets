import { NoteItem, OrganizeHint } from '../models/SlipModels'
import { SlipDateUtil } from './SlipDateUtil'
import { SlipStore } from './SlipStore'

/** 规则化智慧整理：按今日条数与标签频次给出建议，不调用大模型。 */
export class OrganizeService {
  static hintForToday(): OrganizeHint {
    const hint = new OrganizeHint()
    const today = SlipStore.todayItems()
    hint.todayCount = today.length
    if (today.length === 0) {
      hint.message = '今天还没有灵感。记下一条小想法，整理建议会轻轻出现。'
      return hint
    }
    const counts = OrganizeService.tagCounts(today)
    let topTag = ''
    let topCount = 0
    const keys = counts.keys
    const vals = counts.vals
    let i = 0
    while (i < keys.length) {
      if (vals[i] > topCount) {
        topCount = vals[i]
        topTag = keys[i]
      }
      i += 1
    }
    hint.topTag = topTag
    hint.topCount = topCount
    if (topTag.length > 0 && topCount >= 2) {
      hint.message = `今天记录了 ${today.length} 条灵感，其中 ${topCount} 条与「${topTag}」有关。`
      hint.actionLabel = `整理到${topTag}`
    } else {
      hint.message = `今天记录了 ${today.length} 条灵感，可以按标签慢慢归类。`
    }
    return hint
  }

  static async applyTopTag(): Promise<boolean> {
    const hint = OrganizeService.hintForToday()
    if (hint.topTag.length === 0) {
      return false
    }
    const today = SlipDateUtil.todayIso()
    for (const n of SlipStore.all()) {
      if (n.noteDate !== today) {
        continue
      }
      const tags = n.tagList()
      let has = false
      for (const t of tags) {
        if (t === hint.topTag) {
          has = true
        }
      }
      if (!has && tags.length === 0) {
        n.tagsCsv = hint.topTag
        n.updatedAt = Date.now()
        await SlipStore.save(n)
      }
    }
    return true
  }

  private static tagCounts(items: NoteItem[]): TagCountBag {
    const bag = new TagCountBag()
    for (const n of items) {
      for (const t of n.tagList()) {
        let found = false
        let i = 0
        while (i < bag.keys.length) {
          if (bag.keys[i] === t) {
            bag.vals[i] = bag.vals[i] + 1
            found = true
          }
          i += 1
        }
        if (!found) {
          bag.keys.push(t)
          bag.vals.push(1)
        }
      }
    }
    return bag
  }
}

class TagCountBag {
  keys: string[] = []
  vals: number[] = []
}
