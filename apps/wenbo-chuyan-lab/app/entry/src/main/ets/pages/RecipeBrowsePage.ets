import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { RecipeListCard } from '../components/kitchenlab/RecipeListCard'
import { RecipeItem } from '../models/KitchenLabModels'
import { KitchenLabBizService } from '../services/KitchenLabBizService'
import { KitchenLabDetailNav } from '../services/KitchenLabDetailNav'

@Component
export struct RecipeBrowsePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('kitchenTick') kitchenTick: number = 0
  @State recipes: RecipeItem[] = []
  @State cuisineFilter: string = '全部'
  @State difficultyFilter: string = '全部'
  @State loading: boolean = true

  private cuisines: string[] = ['全部', '家常菜', '川菜', '粤菜', '湘菜', '西餐', '汤羹', '轻食', '实验菜']
  private difficulties: string[] = ['全部', '简单', '中等']

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const cuisine = this.cuisineFilter === '全部' ? '' : this.cuisineFilter
    const diff = this.difficultyFilter === '全部' ? '' : this.difficultyFilter
    this.recipes = await KitchenLabBizService.loadRecipes(cuisine, diff)
    this.loading = false
  }

  build() {
    Column() {
      AppHeader({ title: '菜谱', subtitle: '按菜系与难度浏览' })
      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.cuisines, (c: string) => {
            Text(c)
              .fontSize(Theme.type.overline)
              .fontColor(this.cuisineFilter === c ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.cuisineFilter === c ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => {
                this.cuisineFilter = c
                void this.reload()
              })
          }, (c: string) => `c_${c}`)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.difficulties, (d: string) => {
            Text(d)
              .fontSize(Theme.type.overline)
              .fontColor(this.difficultyFilter === d ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.difficultyFilter === d ?
                Theme.colors().brandDeep : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => {
                this.difficultyFilter = d
                void this.reload()
              })
          }, (d: string) => `d_${d}`)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      if (this.loading) {
        Text('加载中…')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .layoutWeight(1)
      } else if (this.recipes.length === 0) {
        AppEmpty({
          title: '暂无菜谱',
          description: '请检查网络或稍后在管理后台添加栏目数据'
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.recipes, (r: RecipeItem) => {
              RecipeListCard({
                item: r,
                onTap: (): void => KitchenLabDetailNav.open('recipe', r.id)
              })
            }, (r: RecipeItem) => r.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
