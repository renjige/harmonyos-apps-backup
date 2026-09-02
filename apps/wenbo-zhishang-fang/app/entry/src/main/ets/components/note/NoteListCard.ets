import { Theme } from '../design-system/Theme'
import { MediaUriUtil } from '../../utils/MediaUriUtil'
import { AppIcon } from '../design-system/AppIcon'
import { SymbolCover } from '../design-system/SymbolVisual'
import { BookNote } from '../../models/BookNoteModels'
import { NoteStore } from '../../services/NoteStore'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct NoteListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: BookNote = new BookNote()
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      if (this.item.coverImage.length > 0) {
        Image(MediaUriUtil.imageSrc(this.item.coverImage))
          .width(64)
          .height(64)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.sm)
      } else {
        SymbolCover({ category: this.item.primaryTag(), tileSize: 64 })
      }
      Column({ space: 6 }) {
        Row({ space: 6 }) {
          Text(this.item.bookName)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          if (this.item.isFavorite) {
            AppIcon({ name: 'heart', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
          }
        }
        .width('100%')
        Text(this.item.excerptPreview())
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row({ space: 6 }) {
          Text(CategoryEmojiUtil.chipLabel(this.item.primaryTag()))
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
          if (this.item.pageLabel().length > 0) {
            Text(this.item.pageLabel())
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          Blank()
          Text(NoteStore.timeLabel(this.item.createdAt))
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
      }
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(44,62,107,0.08)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick((): void => { this.onOpen() })
  }
}
