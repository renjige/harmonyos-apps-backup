import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { InspirationItem } from '../../models/InspirationModels'
import { InspirationCoverImage } from '../inspiration/InspirationCoverImage'

@Component
export struct InspirationListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: InspirationItem = new InspirationItem()
  @Prop compact: boolean = false
  onTap: () => void = () => {}

  @Builder
  TagRow() {
    if (this.item.tags.length > 0) {
      Row({ space: 6 }) {
        ForEach(this.item.tags.slice(0, 3), (tag: string) => {
          Text(tag)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
        }, (tag: string) => tag)
      }
      .width('100%')
    }
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      if (this.item.coverKey.length > 0) {
        InspirationCoverImage({
          coverKey: this.item.coverKey,
          imageWidth: this.compact ? 64 : 80,
          imageHeight: this.compact ? 64 : 80,
          useAspectRatio: false,
          cornerRadius: Theme.radius.lg
        })
      }
      Column({ space: 6 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (this.item.summary.length > 0) {
          Text(this.item.summary)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(this.compact ? 1 : 2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        if (this.item.recordDate.length > 0) {
          Text(this.item.recordDate)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
        this.TagRow()
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
