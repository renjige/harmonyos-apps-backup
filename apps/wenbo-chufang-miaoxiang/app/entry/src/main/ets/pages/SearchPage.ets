import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecipeCard } from '../components/kitchen/RecipeCard'
import { Recipe } from '../models/KitchenModels'
import { KitchenStore } from '../services/KitchenStore'

@Component
export struct SearchPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State query: string = ''
  @State results: Recipe[] = []
  onClose: () => void = () => {}
  onOpenRecipe: (id: string) => void = (_id: string) => {}

  private runSearch(value: string): void {
    this.query = value
    this.results = KitchenStore.search(value)
  }

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
        TextInput({ text: this.query, placeholder: '搜索菜谱、食材' })
          .height(44)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .layoutWeight(1)
          .onChange((value: string) => this.runSearch(value))
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.query.trim().length === 0) {
            this.KeywordPanel()
          } else if (this.results.length === 0) {
            AppEmpty({
              title: '暂时没有找到相关菜谱',
              description: '试试换一种食材或关键词。'
            })
          } else {
            ForEach(this.results, (item: Recipe) => {
              RecipeCard({
                recipe: item,
                compact: true,
                onTap: (): void => this.onOpenRecipe(item.id)
              })
            }, (item: Recipe) => item.id)
          }
        }
        .width('100%')
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

  @Builder
  KeywordPanel() {
    Column({ space: Theme.space.s4 }) {
      Text('可以试试')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Column({ space: Theme.space.s2 }) {
        Row({ space: Theme.space.s2 }) {
          this.Keyword('鸡蛋')
          this.Keyword('番茄')
          this.Keyword('面条')
        }
        Row({ space: Theme.space.s2 }) {
          this.Keyword('汤羹')
          this.Keyword('早餐')
          this.Keyword('快手菜')
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
  }

  @Builder
  Keyword(text: string) {
    Text(text)
      .fontSize(Theme.type.subhead)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick(() => this.runSearch(text))
  }
}
