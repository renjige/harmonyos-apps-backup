import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { FeedItem } from '../../models/BowenModels'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct FeedCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop summary: string = ''
  @Prop meta: string = ''
  @Prop kind: string = 'thought'
  @Prop ts: number = 0
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        Text(CategoryEmojiUtil.markFor(this.kind))
          .fontSize(22)
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.sm)

      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (this.summary.length > 0) {
          Text(this.summary)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        Text(`${this.meta} · ${DateHelper.displayDateFromTs(this.ts)}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { this.onTap() })
  }
}

@Component
export struct FeedCardFromItem {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  item: FeedItem = new FeedItem()
  onTap: () => void = () => {}

  build() {
    FeedCard({
      title: this.item.title,
      summary: this.item.summary,
      meta: this.item.meta,
      kind: this.item.kind,
      ts: this.item.ts,
      onTap: (): void => { this.onTap() }
    })
  }
}
