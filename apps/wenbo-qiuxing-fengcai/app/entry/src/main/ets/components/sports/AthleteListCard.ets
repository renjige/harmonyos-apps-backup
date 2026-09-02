import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AthleteItem } from '../../models/StarModels'
import { StarMedia } from '../../services/StarMedia'

@Component
export struct AthleteListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: AthleteItem = new AthleteItem()
  @Prop compact: boolean = false
  onTap: () => void = () => {}

  @Builder
  TagRow() {
    if (this.item.tags.length > 0) {
      Row({ space: 6 }) {
        ForEach(this.item.tags.slice(0, 3), (tag: string) => {
          Text(tag)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textOnBrandContainer : Theme.colors().textOnBrandContainer)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(Theme.colors().chipSecondaryBg)
            .borderRadius(Theme.radius.pill)
        }, (tag: string) => tag)
      }
      .width('100%')
    }
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      if (this.item.coverKey.length > 0) {
        Image(StarMedia.coverMedia(this.item.coverKey))
          .width(this.compact ? 64 : 80)
          .height(this.compact ? 64 : 80)
          .borderRadius(Theme.radius.lg)
          .objectFit(ImageFit.Cover)
      }
      Column({ space: 6 }) {
        Row({ space: 8 }) {
          Text(this.item.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          Text(this.item.sportLabel())
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textOnBrandContainer : Theme.colors().textOnBrandContainer)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(Theme.colors().chipSecondaryBg)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        if (this.item.metaLine().length > 0) {
          Text(this.item.metaLine())
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(1)
            .width('100%')
        }
        if (this.item.summary.length > 0) {
          Text(this.item.summary)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(this.compact ? 1 : 2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        this.TagRow()
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onTap() })
  }
}
