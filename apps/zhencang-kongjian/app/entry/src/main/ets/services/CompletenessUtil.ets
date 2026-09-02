import { TreasureItem } from '../models/TreasureModels'

export class CompletenessUtil {
  static percent(item: TreasureItem): number {
    let filled = 0
    const total = 10
    if (item.imagePath.length > 0) {
      filled += 1
    }
    if (item.name.trim().length > 0) {
      filled += 1
    }
    if (item.categoryId.length > 0) {
      filled += 1
    }
    if (item.acquiredAt.length > 0) {
      filled += 1
    }
    if (item.source.length > 0) {
      filled += 1
    }
    if (item.collectReason.trim().length > 0 || item.story.trim().length > 0) {
      filled += 1
    }
    if (item.traits.trim().length > 0) {
      filled += 1
    }
    if (item.storageLocation.trim().length > 0) {
      filled += 1
    }
    if (item.archiveStatus.length > 0 && item.archiveStatus !== '刚入藏') {
      filled += 1
    }
    if (item.rating > 0 || item.personalReview.trim().length > 0) {
      filled += 1
    }
    return Math.round((filled / total) * 100)
  }

  static missingHint(item: TreasureItem): string {
    if (item.imagePath.length === 0) {
      return '添加藏品照片'
    }
    if (item.name.trim().length === 0) {
      return '填写藏品名称'
    }
    if (item.categoryId.length === 0) {
      return '选择分类'
    }
    if (item.collectReason.trim().length === 0 && item.story.trim().length === 0) {
      return '记录收藏故事或原因'
    }
    if (item.traits.trim().length === 0) {
      return '补充物品特点'
    }
    return '继续完善档案'
  }
}
