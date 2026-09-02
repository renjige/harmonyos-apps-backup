import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecipeCover } from '../components/kitchen/RecipeCover'
import { Recipe, RecipeStep } from '../models/KitchenModels'
import { KitchenStore } from '../services/KitchenStore'

@Component
export struct RecipeDetailPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop recipeId: string = ''
  @Prop refreshToken: number = 0
  @State favorite: boolean = false
  @State completed: boolean = false
  onClose: () => void = () => {}
  onToast: (message: string) => void = (_message: string) => {}
  private lastAddMs: number = 0

  aboutToAppear(): void {
    KitchenStore.addHistory(this.recipeId)
    this.favorite = KitchenStore.isFavorite(this.recipeId)
    this.completed = KitchenStore.isRecipeCompleted(this.recipeId)
  }

  private recipe(): Recipe {
    return KitchenStore.findRecipe(this.recipeId)
  }

  private toggleFavorite(): void {
    this.favorite = KitchenStore.toggleFavorite(this.recipeId)
    this.onToast(this.favorite ? '已收藏，下次打开就能快速找到' : '已取消收藏')
  }

  private toggleCompleted(): void {
    this.completed = KitchenStore.toggleCompletedRecipe(this.recipeId)
    this.onToast(this.completed ? '已标记完成，今天做得不错' : '已取消完成标记')
  }

  private addToKitchenList(): void {
    const now = Date.now()
    if (now - this.lastAddMs < 600) {
      return
    }
    this.lastAddMs = now
    const count = KitchenStore.addRecipeIngredients(this.recipeId)
    if (count > 0) {
      this.onToast(`已加入厨房清单 ${count} 项`)
      return
    }
    this.onToast('这些食材已在清单中，已合并数量')
  }

  private addOneIngredient(line: string): void {
    const isNew = KitchenStore.addIngredientLine(line)
    this.onToast(isNew ? '已加入厨房清单' : '清单里已有这项，已合并数量')
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Row() {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: '#FFFFFF' })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(18,63,50,0.42)')
          .borderRadius(Theme.radius.pill)
          .rotate({ angle: 180 })
          .onClick(() => this.onClose())
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        .zIndex(2)

        Scroll() {
          Column({ space: Theme.space.s5 }) {
            RecipeCover({
              coverKey: this.recipe().coverKey,
              title: this.recipe().title,
              imageHeight: 300,
              rounded: Theme.radius.sheet
            })
            Column({ space: Theme.space.s3 }) {
              Text(this.recipe().summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .lineHeight(24)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                this.Meta(this.recipe().timeText)
                this.Meta(this.recipe().difficulty)
                this.Meta(this.recipe().servings)
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)

            this.IngredientsBlock()
            this.StepsBlock()
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 132 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')

      Column({ space: Theme.space.s3 }) {
        AppButton({
          label: '加入厨房清单',
          variant: 'primary',
          onTap: (): void => this.addToKitchenList()
        })
        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: this.favorite ? '已收藏' : '收藏',
            variant: 'secondary',
            onTap: (): void => this.toggleFavorite()
          })
          .layoutWeight(1)
          AppButton({
            label: this.completed ? '已完成' : '已完成这道菜',
            variant: 'secondary',
            onTap: (): void => this.toggleCompleted()
          })
          .layoutWeight(1)
        }
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s5 })
      .backgroundColor(Theme.colors().surfaceGlass)
      .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Meta(text: string) {
    Text(text)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
  }

  @Builder
  IngredientsBlock() {
    Column({ space: Theme.space.s3 }) {
      Text('食材')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.recipe().ingredients, (item: string) => {
        Row() {
          Text(item)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          AppIcon({ name: 'add', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
        }
        .width('100%')
        .padding({ top: 12, bottom: 12 })
        .border({ width: { bottom: 1 }, color: Theme.colors().strokeHairline })
        .onClick(() => this.addOneIngredient(item))
      }, (item: string) => item)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
  }

  @Builder
  StepsBlock() {
    Column({ space: Theme.space.s3 }) {
      Text('烹饪步骤')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.recipe().stepItems(), (item: RecipeStep) => {
        Row({ space: Theme.space.s3 }) {
          Text(item.numberText)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandOnPrimary)
            .textAlign(TextAlign.Center)
            .width(28)
            .height(28)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
          Text(item.text)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(24)
            .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }, (item: RecipeStep) => item.key)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
  }
}
