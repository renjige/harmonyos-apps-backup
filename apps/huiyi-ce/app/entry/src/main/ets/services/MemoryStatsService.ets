import { ClassifyHint, MemoryOverview, TagCloudItem, WeekDigest } from '../models/MemoryModels'
import { MemoryStore } from './MemoryStore'
import { TagRecommendService } from './TagRecommendService'

export class MemoryStatsService {
  static async overview(): Promise<MemoryOverview> {
    const active = await MemoryStore.loadActive()
    const ov = new MemoryOverview()
    ov.total = active.length
    const now = new Date()
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1).getTime()
    let month = 0
    let fav = 0
    for (const it of active) {
      if (it.createTime >= monthStart) {
        month++
      }
      if (it.favorite) {
        fav++
      }
    }
    ov.monthNew = month
    ov.favoriteCount = fav
    const books = await MemoryStore.loadBooklets()
    ov.bookletCount = books.length
    const due = await MemoryStore.loadDueReview()
    ov.dueCount = due.length
    ov.streakDays = MemoryStore.streakDays(active)
    const tops = await MemoryStatsService.tagCloud()
    if (tops.length > 0) {
      ov.top1 = `${tops[0].name} ${tops[0].count}`
    }
    if (tops.length > 1) {
      ov.top2 = `${tops[1].name} ${tops[1].count}`
    }
    if (tops.length > 2) {
      ov.top3 = `${tops[2].name} ${tops[2].count}`
    }
    return ov
  }

  static async weekDigest(): Promise<WeekDigest> {
    const active = await MemoryStore.loadActive()
    const d = new WeekDigest()
    const now = Date.now()
    const weekStart = now - 7 * 24 * 60 * 60 * 1000
    let week = 0
    for (const it of active) {
      if (it.createTime >= weekStart) {
        week++
      }
    }
    d.weekCount = week
    const tops = await MemoryStatsService.tagCloud()
    if (tops.length > 0) {
      d.topTag = tops[0].name
    }
    const due = await MemoryStore.loadDueReview()
    d.dueCount = due.length
    d.streak = MemoryStore.streakDays(active)
    return d
  }

  static async tagCloud(): Promise<TagCloudItem[]> {
    const list = await MemoryStore.loadActive()
    const names: string[] = []
    const counts: number[] = []
    for (const it of list) {
      for (const t of it.tags) {
        let idx = -1
        for (let i = 0; i < names.length; i++) {
          if (names[i] === t) {
            idx = i
          }
        }
        if (idx < 0) {
          names.push(t)
          counts.push(1)
        } else {
          counts[idx] = counts[idx] + 1
        }
      }
    }
    const items: TagCloudItem[] = []
    let max = 1
    for (let i = 0; i < names.length; i++) {
      if (counts[i] > max) {
        max = counts[i]
      }
    }
    for (let i = 0; i < names.length; i++) {
      const row = new TagCloudItem()
      row.name = names[i]
      row.count = counts[i]
      row.fontSize = 13 + Math.floor((counts[i] / max) * 14)
      items.push(row)
    }
    items.sort((a: TagCloudItem, b: TagCloudItem) => b.count - a.count)
    return items
  }

  static async hints(): Promise<ClassifyHint[]> {
    const list = await MemoryStore.loadActive()
    const out: ClassifyHint[] = []
    for (const it of list) {
      if (!it.isUnclassified()) {
        continue
      }
      const rec = TagRecommendService.suggest(it.content)
      if (rec.length === 0) {
        continue
      }
      const h = new ClassifyHint()
      h.recordId = it.id
      h.preview = it.previewLine()
      h.suggested = rec[0]
      out.push(h)
      if (out.length >= 8) {
        break
      }
    }
    return out
  }

  static async applyHint(recordId: string, tag: string): Promise<void> {
    const found = await MemoryStore.findById(recordId)
    if (found === undefined) {
      return
    }
    if (!found.hasTag(tag)) {
      const next: string[] = []
      for (const t of found.tags) {
        next.push(t)
      }
      next.push(tag)
      found.tags = next
    }
    await MemoryStore.save(found)
  }
}
