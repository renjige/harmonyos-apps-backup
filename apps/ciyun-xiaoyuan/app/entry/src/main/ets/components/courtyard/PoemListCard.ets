import { Theme } from '../design-system/Theme'
import { CourtyardMedia } from '../../services/CourtyardMedia'


@Component
export struct PoemListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop poemId: string = ''
  @Prop title: string = ''
  @Prop meta: string = ''
  @Prop summary: string = ''
  @Prop coverKey: string = 'hero_courtyard'
  onOpen: (id: string) => void = (_id: string) => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Image(CourtyardMedia.cover(this.coverKey))
        .width(88)
        .height(88)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.sm)
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.meta)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .width('100%')
        Text(this.summary)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { this.onOpen(this.poemId) })
  }
}

