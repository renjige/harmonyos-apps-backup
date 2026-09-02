import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ReadingMedia } from '../../services/ReadingMedia'

/** 通用阅读列表卡片 — 书籍/笔记/精选等 */
@Component
export struct ReadingListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop summary: string = ''
  @Prop coverKey: string = ''
  @Prop meta: string = ''
  @Prop tags: string[] = []
  @Prop compact: boolean = false
  @Prop showCover: boolean = true
  @Prop showRemove: boolean = false
  onTap: () => void = () => {}
  onRemove: () => void = () => {}

  @Builder
  TagRow() {
    if (this.tags.length > 0) {
      Row({ space: 6 }) {
        ForEach(this.tags.slice(0, 3), (tag: string) => {
          Text(tag)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.tagForeground())
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(Theme.tagBackground())
            .border({
              width: Theme.isDark() ? 1 : 0,
              color: Theme.colors().strokeStrong
            })
            .borderRadius(Theme.radius.pill)
        }, (tag: string) => tag)
      }
      .width('100%')
    }
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      if (this.showCover && this.coverKey.length > 0) {
        Image(ReadingMedia.coverMedia(this.coverKey))
          .width(this.compact ? 56 : 72)
          .height(this.compact ? 80 : 104)
          .borderRadius(Theme.radius.md)
          .objectFit(ImageFit.Cover)
      }
      Column({ space: 6 }) {
        Text(this.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(1)
            .width('100%')
        }
        if (this.summary.length > 0) {
          Text(this.summary)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(this.compact ? 1 : 2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        if (this.meta.length > 0) {
          Text(this.meta)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        this.TagRow()
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick((): void => { this.onTap() })
      if (this.showRemove) {
        Column({ space: 2 }) {
          AppIcon({ name: 'close', iconSize: Theme.icon.sm, color: Theme.colors().danger })
          Text('删除')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().danger)
        }
        .width(48)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onRemove() })
      } else {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
