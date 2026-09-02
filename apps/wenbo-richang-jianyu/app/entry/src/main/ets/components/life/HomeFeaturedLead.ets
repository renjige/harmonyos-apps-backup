import { Theme } from '../design-system/Theme'
import { JournalListCard } from '../journal/JournalListCard'
import { JournalItem } from '../../models/JournalModels'
import { JournalDetailNav } from '../../services/JournalDetailNav'

/** 精选生活片段（平台 API · 游客可浏览）置顶展示 */
@Component
export struct HomeFeaturedLead {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop items: JournalItem[] = []

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('精选生活片段')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('机构示例 · 可进详情')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
      .width('100%')
      if (this.items.length === 0) {
        Text('加载精选内容…')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.items, (item: JournalItem) => {
          JournalListCard({
            item: item,
            compact: false,
            onTap: (): void => { JournalDetailNav.openFeatured(item.id) }
          })
        }, (item: JournalItem) => `lead_${item.id}`)
      }
    }
    .width('100%')
  }
}
