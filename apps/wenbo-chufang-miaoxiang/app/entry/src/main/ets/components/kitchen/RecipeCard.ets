import { Theme } from '../design-system/Theme'
import { Recipe } from '../../models/KitchenModels'
import { RecipeCover } from './RecipeCover'

@Component
export struct RecipeCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop recipe: Recipe = new Recipe('', '', '', '', '', '', '', '', '', [], [], [])
  @Prop compact: boolean = false
  onTap: () => void = () => {}
  @State private pressed: boolean = false

  build() {
    Column({ space: Theme.space.s3 }) {
      RecipeCover({
        coverKey: this.recipe.coverKey,
        title: this.compact ? '' : this.recipe.title,
        imageHeight: this.compact ? 96 : 168,
        rounded: Theme.radius.card
      })
      Column({ space: Theme.space.s2 }) {
        if (this.compact) {
          Text(this.recipe.title)
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        Text(this.recipe.summary)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .lineHeight(20)
          .maxLines(this.compact ? 2 : 3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          this.MetaPill(this.recipe.timeText)
          this.MetaPill(this.recipe.difficulty)
          this.MetaPill(this.recipe.category)
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: Theme.space.s1, right: Theme.space.s1, bottom: Theme.space.s1 })
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 12, color: 'rgba(18,63,50,0.06)', offsetX: 0, offsetY: 4 })
    .scale({ x: this.pressed ? 0.985 : 1, y: this.pressed ? 0.985 : 1 })
    .animation({ duration: Theme.motion.fast, curve: Curve.EaseOut })
    .onTouch((e: TouchEvent) => {
      if (e.type === TouchType.Down) this.pressed = true
      if (e.type === TouchType.Up || e.type === TouchType.Cancel) this.pressed = false
    })
    .onClick(() => this.onTap())
  }

  @Builder
  MetaPill(text: string) {
    Text(text)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
  }
}
