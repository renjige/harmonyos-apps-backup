import { HttpClient } from './HttpClient'
import {
  CategoryChip,
  InspirationItem,
  InspirationListPayload,
  InspirationWire,
  StyleChip
} from '../models/LanguageCraftModels'

export class LanguageCraftBizService {
  private static cache: InspirationItem[] = []

  static styleChips(): StyleChip[] {
    return [
      StyleChip.of('formal', '正式', '书面头尾，适合对上级'),
      StyleChip.of('warm', '亲切', '同步语气，适合同事'),
      StyleChip.of('brief', '简洁', '拆成可执行要点'),
      StyleChip.of('full', '详尽', '核心 / 补充 / 下一步')
    ]
  }

  static categoryChips(): CategoryChip[] {
    return [
      CategoryChip.of('', '全部'),
      CategoryChip.of('职场沟通', '职场沟通'),
      CategoryChip.of('学术写作', '学术写作'),
      CategoryChip.of('日常表达', '日常表达'),
      CategoryChip.of('创意文案', '创意文案')
    ]
  }

  static async loadInspirations(category: string = ''): Promise<InspirationItem[]> {
    let path = '/biz/language-craft/inspirations'
    if (category.length > 0) {
      path = `${path}?category=${encodeURIComponent(category)}`
    }
    const res = await HttpClient.get<InspirationListPayload>(path)
    const out: InspirationItem[] = []
    if (res.code === 0 && res.data !== undefined) {
      for (const w of res.data.list) {
        out.push(InspirationItem.fromWire(w))
      }
    }
    if (out.length > 0) {
      LanguageCraftBizService.cache = out
    }
    return out
  }

  static async findInspiration(id: string): Promise<InspirationItem | undefined> {
    for (const item of LanguageCraftBizService.cache) {
      if (item.id === id) {
        return item
      }
    }
    const res = await HttpClient.get<InspirationWire>(`/biz/language-craft/inspirations/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      const item = InspirationItem.fromWire(res.data)
      LanguageCraftBizService.merge(item)
      return item
    }
    return undefined
  }

  static filterByCategory(list: InspirationItem[], category: string): InspirationItem[] {
    if (category.length === 0) {
      return list
    }
    const out: InspirationItem[] = []
    for (const item of list) {
      if (item.category === category) {
        out.push(item)
      }
    }
    return out
  }

  private static merge(item: InspirationItem): void {
    const next: InspirationItem[] = []
    let found = false
    for (const row of LanguageCraftBizService.cache) {
      if (row.id === item.id) {
        next.push(item)
        found = true
      } else {
        next.push(row)
      }
    }
    if (!found) {
      next.unshift(item)
    }
    LanguageCraftBizService.cache = next
  }
}
