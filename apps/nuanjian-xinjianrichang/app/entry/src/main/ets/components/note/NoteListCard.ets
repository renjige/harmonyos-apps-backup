import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { NoteItem } from '../../models/NoteModels'
import { MoodCatalog } from '../../services/MoodCatalog'
import { NoteDateUtil } from '../../services/NoteDateUtil'
import { HeartNoteMedia } from '../../services/HeartNoteMedia'

@Component
export struct NoteListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: NoteItem = new NoteItem()
  onTap: () => void = () => {}

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(NoteDateUtil.cardDate(this.item.noteDate))
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Blank()
        AppIcon({
          name: MoodCatalog.iconOf(this.item.mood),
          iconSize: Theme.icon.sm,
          color: MoodCatalog.colorOf(this.item.mood)
        })
      }
      .width('100%')
      Text(this.item.title.length > 0 ? this.item.title : '未命名心笺')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (this.item.body.length > 0) {
        Text(this.item.summary())
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      if (this.item.coverKey.length > 0 || this.item.photoUri0.length > 0) {
        Image(this.item.photoUri0.length > 0 ? this.item.photoUri0 : HeartNoteMedia.cover(this.item.coverKey))
          .width('100%')
          .height(140)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
      }
      Row({ space: 8 }) {
        Text(`${NoteDateUtil.cardDate(this.item.noteDate)} · ${this.item.period}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
        Blank()
        ForEach(this.item.tagList(), (tag: string) => {
          Text(`#${tag}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }, (tag: string) => tag)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 12, color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(39,35,33,0.05)', offsetY: 2, offsetX: 0 })
    .onClick((): void => { this.onTap() })
  }
}
