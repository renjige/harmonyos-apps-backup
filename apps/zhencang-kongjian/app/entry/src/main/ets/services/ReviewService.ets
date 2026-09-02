import { OrganizeHint, ReviewSnippet, TreasureItem } from '../models/TreasureModels'
import { CompletenessUtil } from './CompletenessUtil'
import { TreasureStore } from './TreasureStore'

export class ReviewService {
  static todaySnippet(): ReviewSnippet {
    const out = new ReviewSnippet()
    const items = TreasureStore.activeItems()
    if (items.length === 0) {
      out.title = '时光回顾'
      out.body = '从第一件珍藏开始，这里会留下你的收藏足迹。'
      return out
    }
    const ann = ReviewService.anniversaryItem()
    if (ann !== null) {
      out.title = '往年今日'
      out.body = `一年前的这时候，你收藏了「${ann.name}」。`
      return out
    }
    const monthCount = TreasureStore.monthAddedCount()
    out.title = '本月回顾'
    out.body = monthCount > 0 ?
      `这个月你新增了 ${monthCount} 件珍藏，藏间正在变得丰富。` :
      '这个月还没有新珍藏，不妨为某件物品建一份档案。'
    return out
  }

  private static anniversaryItem(): TreasureItem | null {
    const now = new Date()
    const m = ReviewService.pad(now.getMonth() + 1)
    const d = ReviewService.pad(now.getDate())
    const key = `-${m}-${d}`
    for (const item of TreasureStore.activeItems()) {
      const dt = new Date(item.createdAt)
      const ik = `-${ReviewService.pad(dt.getMonth() + 1)}-${ReviewService.pad(dt.getDate())}`
      if (ik === key && now.getFullYear() - dt.getFullYear() >= 1) {
        return item
      }
    }
    return null
  }

  private static pad(n: number): string {
    return n < 10 ? `0${n}` : `${n}`
  }
}

export class SmartOrganizeService {
  static hints(): OrganizeHint[] {
    const out: OrganizeHint[] = []
    for (const item of TreasureStore.activeItems()) {
      if (item.categoryId.length === 0) {
        const h = new OrganizeHint()
        h.kind = 'no_category'
        h.title = item.name.length > 0 ? item.name : '未命名珍藏'
        h.detail = '尚未选择分类，建议归入书籍/纪念物等分类'
        h.refId = item.id
        out.push(h)
      }
      if (item.tagIds.length === 0) {
        const h = new OrganizeHint()
        h.kind = 'no_tag'
        h.title = item.name
        h.detail = '还没有标签，可添加「特别纪念」「旅行」等'
        h.refId = item.id
        out.push(h)
      }
      if (item.archiveStatus === '刚入藏' || item.listStatus === '待整理') {
        const h = new OrganizeHint()
        h.kind = 'pending'
        h.title = item.name
        h.detail = '档案尚未整理完成，完整度 ' + `${CompletenessUtil.percent(item)}%`
        h.refId = item.id
        out.push(h)
      }
    }
    return out.slice(0, 12)
  }
}
