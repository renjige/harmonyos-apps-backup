import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { NoteItem } from '../../models/SlipModels'
import { SlipDateUtil } from '../../services/SlipDateUtil'
import { SlipMedia } from '../../services/SlipMedia'

@Component
export struct InspirationListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: NoteItem = new NoteItem()
  @Prop compact: boolean = false
  onTap: () => void = () => {}

  build() {
    Column({ space: 10 }) {
      if (!this.compact) {
        Image(SlipMedia.cover(this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_paper_window'))
          .width('100%')
          .height(140)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
      }
      Text(this.item.body.length > 0 ? this.item.body : this.item.displayTitle())
        .fontSize(this.compact ? Theme.type.body : Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .lineHeight(this.compact ? 22 : 26)
        .width('100%')
        .maxLines(this.compact ? 3 : 5)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row({ space: 8 }) {
        ForEach(this.item.tagList(), (tag: string) => {
          Text(`#${tag}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }, (tag: string) => tag)
        Blank()
        if (this.item.favorited) {
          AppIcon({ name: 'bookmark', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
        }
        Text(this.item.timeLabel.length > 0 ? this.item.timeLabel : SlipDateUtil.cardDate(this.item.noteDate))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
      .width('100%')
    }
    .width('100%')
    .padding(this.compact ? Theme.space.s4 : Theme.space.cardPadding)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 10, color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(24,35,58,0.04)', offsetY: 2, offsetX: 0 })
    .onClick((): void => { this.onTap() })
  }
}
