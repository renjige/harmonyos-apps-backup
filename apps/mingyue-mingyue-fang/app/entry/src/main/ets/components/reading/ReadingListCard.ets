import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ReadingMedia } from '../../services/ReadingMedia'
import { SymbolCover } from '../design-system/SymbolVisual'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

/** 通用阅读列表卡片 — 书籍/笔记/精选等 */
@Component
export struct ReadingListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop summary: string = ''
  @Prop coverKey: string = ''
  @Prop category: string = ''
  @Prop meta: string = ''
  @Prop tags: string[] = []
  @Prop compact: boolean = false
  @Prop showCover: boolean = true
  @Prop useSymbolCover: boolean = false
  @Prop showRemove: boolean = false
  onTap: () => void = () => {}
  onRemove: () => void = () => {}

  private primaryCategory(): string {
    if (this.category.length > 0) {
      return this.category
    }
    if (this.tags.length > 0) {
      return this.tags[0]
    }
    return ''
  }

  @Builder
  TagRow() {
    if (this.tags.length > 0) {
      Row({ space: 6 }) {
        ForEach(this.tags.slice(0, 3), (tag: string) => {
          Text(CategoryEmojiUtil.chipLabel(tag))
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
      if (this.useSymbolCover) {
        SymbolCover({
          category: this.primaryCategory(),
          coverKey: this.coverKey.length > 0 ? this.coverKey : 'cover_note',
          tileSize: this.compact ? 56 : 72,
          cornerRadius: Theme.radius.md
        })
      } else if (this.showCover && this.coverKey.length > 0) {
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
            .fontColor(Theme.colors().brandDeep)
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
            .fontColor(Theme.colors().textTertiary)
        }
        this.TagRow()
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick((): void => { this.onTap() })
      if (this.showRemove) {
        Column({ space: 2 }) {
          AppIcon({ name: 'trash', iconSize: Theme.icon.sm, color: Theme.colors().danger })
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
