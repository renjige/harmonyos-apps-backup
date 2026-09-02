import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { RecipeCard } from '../components/kitchen/RecipeCard'
import { Recipe } from '../models/KitchenModels'
import { KitchenStore } from '../services/KitchenStore'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop refreshToken: number = 0
  @State filter: string = '全部'
  @State localRefresh: number = 0
  onOpenRecipe: (id: string) => void = (_id: string) => {}
  onToast: (message: string) => void = (_message: string) => {}

  private favorites(): Recipe[] {
    return KitchenStore.favoriteRecipes(this.filter)
  }

  private cancelFavorite(id: string): void {
    KitchenStore.toggleFavorite(id)
    this.localRefresh += 1
    this.onToast('已取消收藏')
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Column({ space: Theme.space.s2 }) {
          Text('收藏')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text('收藏几道喜欢的菜，下次打开就能快速找到。')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding({ top: Theme.space.s4 })
        .alignItems(HorizontalAlign.Start)

        Row({ space: Theme.space.s2 }) {
          this.FilterChip('全部')
          this.FilterChip('早餐')
          this.FilterChip('午餐')
          this.FilterChip('晚餐')
          this.FilterChip('汤羹')
        }
        .width('100%')

        if (this.favorites().length === 0) {
          AppEmpty({
            title: '还没有收藏菜谱',
            description: '收藏几道喜欢的菜，下次打开就能快速找到。'
          })
        } else {
          ForEach(this.favorites(), (item: Recipe) => {
            Column({ space: Theme.space.s2 }) {
              RecipeCard({
                recipe: item,
                compact: true,
                onTap: (): void => this.onOpenRecipe(item.id)
              })
              Text('取消收藏')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().danger)
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 8, bottom: 8 })
                .onClick(() => this.cancelFavorite(item.id))
            }
          }, (item: Recipe) => item.id)
        }
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  FilterChip(text: string) {
    Text(text)
      .fontSize(Theme.type.caption)
      .fontWeight(this.filter === text ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.filter === text ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.filter === text ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { this.filter = text })
  }
}
