import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecipeCard } from '../components/kitchen/RecipeCard'
import { Recipe } from '../models/KitchenModels'
import { KitchenStore } from '../services/KitchenStore'

@Component
export struct CategoryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop category: string = '全部'
  @Prop refreshToken: number = 0
  onClose: () => void = () => {}
  onOpenRecipe: (id: string) => void = (_id: string) => {}

  build() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => this.onClose())
        Column({ space: 2 }) {
          Text(this.category)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('发现新做法')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (KitchenStore.byCategory(this.category).length === 0) {
            AppEmpty({
              title: '这里还没有菜谱',
              description: '换个分类看看，也可以从首页继续发现。'
            })
          } else {
            ForEach(KitchenStore.byCategory(this.category), (item: Recipe) => {
              RecipeCard({
                recipe: item,
                compact: true,
                onTap: (): void => this.onOpenRecipe(item.id)
              })
            }, (item: Recipe) => item.id)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
