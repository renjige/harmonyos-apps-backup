import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { JournalItem } from '../../models/JournalModels'
import { JournalCoverImage } from './JournalCoverImage'
import { MoodCatalog } from '../../services/MoodCatalog'

@Component
export struct JournalListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: JournalItem = new JournalItem()
  @Prop compact: boolean = false
  @Prop showDelete: boolean = false
  onTap: () => void = () => {}
  onDelete: () => void = () => {}

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
        JournalCoverImage({
          coverKey: this.item.coverKey,
          imageSize: this.compact ? 64 : 80,
          cornerRadius: Theme.radius.lg
        })
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
          if (this.item.kind.length > 0) {
            Text(MoodCatalog.labelOf(this.item.kind))
              .fontSize(Theme.type.caption)
              .fontColor(MoodCatalog.chipTextColor(this.item.kind))
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor(MoodCatalog.colorOf(this.item.kind))
              .borderRadius(Theme.radius.pill)
          }
        }
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
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        this.TagRow()
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      if (this.showDelete) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
        }
        .width(36)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onDelete() })
      }
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
