import { Theme } from '../design-system/Theme'
import { RecipeItem } from '../../models/SolarModels'
import { SolarMedia } from '../../services/SolarMedia'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct RecipeListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop recipe: RecipeItem = new RecipeItem()
  onOpen: (id: string) => void = (_id: string) => {}

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(SolarMedia.resource(this.recipe.coverKey))
          .width('100%')
          .height(132)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: Theme.radius.md, topRight: Theme.radius.md })
        if (this.recipe.featured) {
          Text('推荐')
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
        Text(this.recipe.title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(`${CategoryEmojiUtil.markForSolarTerm(this.recipe.solarTerm)} ${this.recipe.solarTerm} · ${CategoryEmojiUtil.markForEffect(this.recipe.effect)} ${this.recipe.effect}`)
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
    .onClick(() => this.onOpen(this.recipe.id))
  }
}
