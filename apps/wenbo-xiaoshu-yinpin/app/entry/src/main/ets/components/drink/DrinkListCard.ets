import { Theme } from '../design-system/Theme'
import { DrinkItem } from '../../models/DrinkModels'
import { DrinkMedia } from '../../services/DrinkMedia'

@Component
export struct DrinkListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop drink: DrinkItem = new DrinkItem()
  onOpen: (id: string) => void = (_id: string) => {}

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(DrinkMedia.resource(this.drink.coverKey))
          .width('100%')
          .height(132)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: Theme.radius.md, topRight: Theme.radius.md })
        if (this.drink.isHot) {
          Text('热门')
            .fontSize(Theme.type.caption)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .margin({ left: 8, bottom: 8 })
            .backgroundColor(Theme.colors().brandAccent)
            .borderRadius(Theme.radius.pill)
        }
      }
      .width('100%')

      Column({ space: 4 }) {
        Text(this.drink.title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${this.drink.category} · ${this.drink.iceLevel}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .width('100%')
      }
      .padding({ left: 10, right: 10, top: 8, bottom: 12 })
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .clip(true)
    .onClick(() => this.onOpen(this.drink.id))
  }
}
