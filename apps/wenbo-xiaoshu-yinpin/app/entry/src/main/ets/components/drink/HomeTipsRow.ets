import { Theme } from '../design-system/Theme'
import { TipItem } from '../../models/DrinkModels'
import { DrinkDetailNav } from '../../services/DrinkDetailNav'
import { DrinkMedia } from '../../services/DrinkMedia'

@Component
export struct HomeTipsRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop tips: TipItem[] = []

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('消暑贴士')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Scroll() {
        Row({ space: Theme.space.s3 }) {
          ForEach(this.tips, (t: TipItem) => {
            Column({ space: 8 }) {
              Image(DrinkMedia.resource(t.coverKey))
                .width(168)
                .height(104)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sm)
              Text(t.title)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .maxLines(2)
                .width('100%')
            }
            .width(168)
            .onClick(() => DrinkDetailNav.openTip(t.id))
          }, (t: TipItem) => t.id)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
