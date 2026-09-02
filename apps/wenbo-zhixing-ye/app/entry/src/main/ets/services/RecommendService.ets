import { KnowledgeItem, RecommendItem, TagNode } from '../models/ZhixingModels'
import { ZhixingStore } from './ZhixingStore'

export class RecommendService {
  static async byTags(): Promise<RecommendItem[]> {
    const cloud = await ZhixingStore.tagCloud()
    const out: RecommendItem[] = []
    if (cloud.length === 0) {
      return out
    }
    let i = 0
    for (const n of cloud) {
      if (i >= 4) {
        break
      }
      out.push(RecommendService.make(n))
      i++
    }
    return out
  }

  private static make(n: TagNode): RecommendItem {
    const r = new RecommendItem()
    r.id = `rec_${n.name}`
    r.tag = n.name
    r.coverKey = 'cover_read'
    if (n.name.indexOf('阅读') >= 0 || n.name.indexOf('书') >= 0) {
      r.title = '精读一本方法论原著'
      r.reason = `你已有 ${n.count} 条与「${n.name}」相关的知识，建议选一章做阅读摘要`
      return r
    }
    if (n.name.indexOf('职场') >= 0 || n.name.indexOf('工作') >= 0) {
      r.title = '把一张工作卡片拆成三步计划'
      r.reason = `标签「${n.name}」出现 ${n.count} 次，适合转入行录跟踪`
      r.coverKey = 'cover_plan'
      return r
    }
    if (n.name.indexOf('习惯') >= 0) {
      r.title = '把高频标签变成每日打卡'
      r.reason = `「${n.name}」可绑定一个 21 天习惯`
      r.coverKey = 'cover_habit'
      return r
    }
    r.title = `围绕「${n.name}」补一张知识卡片`
    r.reason = `该标签已关联 ${n.count} 条，补一张结构化卡片能让图谱更完整`
    r.coverKey = 'cover_card'
    return r
  }

  static related(item: KnowledgeItem, pool: KnowledgeItem[]): KnowledgeItem[] {
    const tags = item.tagList()
    const out: KnowledgeItem[] = []
    if (tags.length === 0) {
      return out
    }
    for (const it of pool) {
      if (it.id === item.id) {
        continue
      }
      const other = it.tagList()
      let hit = false
      for (const t of tags) {
        for (const o of other) {
          if (t === o) {
            hit = true
          }
        }
      }
      if (hit) {
        out.push(it)
      }
      if (out.length >= 5) {
        break
      }
    }
    return out
  }
}
