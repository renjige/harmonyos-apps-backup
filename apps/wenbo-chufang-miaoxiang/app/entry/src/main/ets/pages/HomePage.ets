import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecipeCard } from '../components/kitchen/RecipeCard'
import { RecipeCover } from '../components/kitchen/RecipeCover'
import { Recipe } from '../models/KitchenModels'
import { KitchenStore } from '../services/KitchenStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '厨房妙想'
  @Prop tagline: string = '发现简单好吃的厨房灵感，让每天做饭变得更轻松'
  @Prop refreshToken: number = 0
  onOpenSearch: () => void = () => {}
  onOpenRecipe: (id: string) => void = (_id: string) => {}
  onOpenCategory: (category: string) => void = (_category: string) => {}
  onOpenIngredientIdea: () => void = () => {}

  private featured: Recipe[] = KitchenStore.featured()
  private quick: Recipe[] = KitchenStore.byCategory('快手菜')
  private soups: Recipe[] = KitchenStore.byCategory('汤羹')

  build() {
    Scroll() {
      Column({ space: Theme.space.s6 }) {
        Column({ space: Theme.space.s2 }) {
          Text(this.appName)
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          Text('今天，厨房有什么新想法？')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding({ top: Theme.space.s4 })
        .alignItems(HorizontalAlign.Start)

        Row({ space: Theme.space.s3 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          Text('搜索菜谱、食材')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textTertiary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: 14, bottom: 14 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .onClick(() => this.onOpenSearch())

        this.HeroRecommendation()
        this.SectionHeader('厨房灵感', '今天吃点清爽的', '全部', '轻食')
        this.HorizontalRecipes(this.featured)
        this.IngredientIdeaEntry()
        this.SectionHeader('今日精选', '10 分钟快手菜', '更多', '快手菜')
        this.VerticalRecipes(this.quick)
        this.SectionHeader('推荐菜谱', '简单也能很好吃', '汤羹', '汤羹')
        this.VerticalRecipes(this.soups)
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  HeroRecommendation() {
    Column({ space: Theme.space.s3 }) {
      Text('今日推荐')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Stack({ alignContent: Alignment.BottomStart }) {
        RecipeCover({
          coverKey: 'tomato_egg_noodles',
          title: '',
          imageHeight: 228,
          rounded: Theme.radius.card
        })
        Column({ space: Theme.space.s2 }) {
          Text('为你挑选')
            .fontSize(Theme.type.caption)
            .fontColor('#FFFFFF')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor('rgba(18,63,50,0.42)')
            .borderRadius(Theme.radius.pill)
          Text('番茄鸡蛋焖面')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
          Text('酸甜番茄和柔软鸡蛋，十几分钟完成。')
            .fontSize(Theme.type.subhead)
            .fontColor('#FFFFFF')
            .maxLines(2)
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s5 })
      }
      .width('100%')
      .clip(true)
      .borderRadius(Theme.radius.card)
      .onClick(() => this.onOpenRecipe('tomato-egg-noodles'))
    }
  }

  @Builder
  IngredientIdeaEntry() {
    Row({ space: Theme.space.s4 }) {
      Column({ space: Theme.space.s2 }) {
        Text('食材妙想')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        Text('选几样家里现有食材，发现新做法。')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Column() {
        AppIcon({ name: 'spark', iconSize: Theme.icon.lg, color: Theme.colors().warning })
      }
      .width(52)
      .height(52)
      .borderRadius(18)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().warningContainer)
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().brandPrimaryContainer)
    .borderRadius(Theme.radius.card)
    .onClick(() => this.onOpenIngredientIdea())
  }

  @Builder
  SectionHeader(title: string, subtitle: string, action: string, category: string) {
    Row() {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text(action)
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .fontWeight(FontWeight.Medium)
        .onClick(() => this.onOpenCategory(category))
    }
    .width('100%')
  }

  @Builder
  HorizontalRecipes(items: Recipe[]) {
    Scroll() {
      Row({ space: Theme.space.s3 }) {
        ForEach(items, (item: Recipe) => {
          Column() {
            RecipeCard({
              recipe: item,
              compact: true,
              onTap: (): void => this.onOpenRecipe(item.id)
            })
          }
          .width(220)
        }, (item: Recipe) => item.id)
      }
      .padding({ right: Theme.space.pageX })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  @Builder
  VerticalRecipes(items: Recipe[]) {
    Column({ space: Theme.space.s4 }) {
      ForEach(items, (item: Recipe) => {
        RecipeCard({
          recipe: item,
          compact: true,
          onTap: (): void => this.onOpenRecipe(item.id)
        })
      }, (item: Recipe) => item.id)
    }
    .width('100%')
  }
}
