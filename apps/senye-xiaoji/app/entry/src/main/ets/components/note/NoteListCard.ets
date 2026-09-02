import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { NoteItem } from '../../models/NoteModels'
import { MoodCatalog } from '../../services/MoodCatalog'
import { NoteDateUtil } from '../../services/NoteDateUtil'

@Component
export struct NoteListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: NoteItem = new NoteItem()
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Row({ space: Theme.space.s2 }) {
        Text(MoodCatalog.emojiOf(this.item.mood))
          .fontSize(18)
        Text(NoteDateUtil.displayDate(this.item.noteDate))
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(this.item.timeLabel)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
        Blank()
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text(this.item.preview())
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      if (this.item.tagList().length > 0) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.item.tagList(), (tag: string) => {
            Text(tag)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
              .margin({ right: 6, bottom: 4 })
          }, (tag: string) => `${this.item.id}_${tag}`)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onTap() })
  }
}
