import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { JournalItem } from '../../models/JournalModels'
import { JournalMedia } from '../../services/JournalMedia'
import { JournalImageCatalog } from '../../services/JournalImageCatalog'

@Component
export struct JournalListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: JournalItem = new JournalItem()
  @Prop compact: boolean = false
  onTap: () => void = () => {}

  private thumbKey(): string {
    const keys = JournalItem.displayPhotoKeys(this.item)
    if (keys.length > 0) {
      return keys[0]
    }
    return this.item.coverKey
  }

  @Builder
  ThumbImage(key: string) {
    if (JournalImageCatalog.isLocalKey(key)) {
      Image(JournalImageCatalog.localUriFromKey(key))
        .width(this.compact ? 64 : 80)
        .height(this.compact ? 64 : 80)
        .borderRadius(Theme.radius.lg)
        .objectFit(ImageFit.Cover)
    } else {
      Image(JournalMedia.coverMedia(key))
        .width(this.compact ? 64 : 80)
        .height(this.compact ? 64 : 80)
        .borderRadius(Theme.radius.lg)
        .objectFit(ImageFit.Cover)
    }
  }

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
      if (this.thumbKey().length > 0) {
        this.ThumbImage(this.thumbKey())
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
