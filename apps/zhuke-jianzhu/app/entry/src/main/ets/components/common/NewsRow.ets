import { Theme } from '../design-system/Theme'
import { NewsItem } from '../../models/ZhukeModels'
import { ContentService } from '../../services/ContentService'
import { ContentCover } from './ContentCover'

@Component
export struct NewsRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: NewsItem = new NewsItem()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      ContentCover({
        imageKey: this.item.coverKey,
        coverHeight: 60,
        coverRadius: Theme.radius.sm,
        showGradient: false
      })
      .width(80)

      Column({ space: Theme.space.s1 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row() {
          Text(ContentService.newsCategoryLabel(this.item.category))
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({
              left: Theme.space.s2,
              right: Theme.space.s2,
              top: 2,
              bottom: 2
            })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
          Text(this.item.publishedAt)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .margin({ left: Theme.space.s2 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .clip(true)
    .onClick(() => this.onTap())
  }
}
