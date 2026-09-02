import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { IngredientIdeaPage } from './IngredientIdeaPage'
import { FavoritesPage } from './FavoritesPage'
import { KitchenListPage } from './KitchenListPage'
import { MinePage } from './MinePage'
import { SearchPage } from './SearchPage'
import { CategoryPage } from './CategoryPage'
import { RecipeDetailPage } from './RecipeDetailPage'
import { IdeaResultPage } from './IdeaResultPage'

class KitchenTabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): KitchenTabItem[] {
    const tabs: KitchenTabItem[] = []
    const t0 = new KitchenTabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '首页'
    tabs.push(t0)
    const t1 = new KitchenTabItem()
    t1.index = 1
    t1.name = 'spark'
    t1.label = '灵感'
    tabs.push(t1)
    const t2 = new KitchenTabItem()
    t2.index = 2
    t2.name = 'heart'
    t2.label = '收藏'
    tabs.push(t2)
    const t3 = new KitchenTabItem()
    t3.index = 3
    t3.name = 'biz'
    t3.label = '清单'
    tabs.push(t3)
    const t4 = new KitchenTabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State fullScreenKind: string = ''
  @State selectedRecipeId: string = ''
  @State selectedCategory: string = '全部'
  @State selectedIngredients: string = ''
  @State refreshToken: number = 0
  @State toastText: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @Prop company: string = '魏文波'
  @Prop appName: string = '厨房妙想'
  @Prop tagline: string = '发现简单好吃的厨房灵感，让每天做饭变得更轻松'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: KitchenTabItem[] = KitchenTabItem.all()

  private openOverlay(name: string): void {
    this.fullScreenKind = name
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeOverlay(): void {
    this.fullScreenKind = ''
    AppStorage.setOrCreate('tabBarHidden', false)
    this.refreshToken += 1
  }

  private openRecipe(id: string): void {
    this.selectedRecipeId = id
    this.openOverlay('detail')
  }

  private openCategory(category: string): void {
    this.selectedCategory = category
    this.openOverlay('category')
  }

  private showToast(message: string): void {
    this.toastText = message
    this.refreshToken += 1
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            tagline: this.tagline,
            refreshToken: this.refreshToken,
            onOpenSearch: (): void => this.openOverlay('search'),
            onOpenRecipe: (id: string): void => this.openRecipe(id),
            onOpenCategory: (category: string): void => this.openCategory(category),
            onOpenIngredientIdea: (): void => { this.current = 1 }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          IngredientIdeaPage({
            onShowResults: (ingredients: string[]): void => {
              this.selectedIngredients = ingredients.join(',')
              this.openOverlay('results')
            }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          FavoritesPage({
            refreshToken: this.refreshToken,
            onOpenRecipe: (id: string): void => this.openRecipe(id),
            onToast: (message: string): void => this.showToast(message)
          }).layoutWeight(1)
        } else if (this.current === 3) {
          KitchenListPage({
            refreshToken: this.refreshToken,
            onToast: (message: string): void => this.showToast(message)
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenFavorites: (): void => { this.current = 2 },
            onOpenRecipe: (id: string): void => this.openRecipe(id)
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: KitchenTabItem) => {
              this.TabBarItem(t)
            }, (t: KitchenTabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
          .shadow({ radius: 16, color: 'rgba(18,63,50,0.08)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.fullScreenKind === 'search') {
        SearchPage({
          onClose: (): void => this.closeOverlay(),
          onOpenRecipe: (id: string): void => this.openRecipe(id)
        })
          .width('100%')
          .height('100%')
          .zIndex(12)
      } else if (this.fullScreenKind === 'category') {
        CategoryPage({
          category: this.selectedCategory,
          refreshToken: this.refreshToken,
          onClose: (): void => this.closeOverlay(),
          onOpenRecipe: (id: string): void => this.openRecipe(id)
        })
          .width('100%')
          .height('100%')
          .zIndex(12)
      } else if (this.fullScreenKind === 'detail') {
        RecipeDetailPage({
          recipeId: this.selectedRecipeId,
          refreshToken: this.refreshToken,
          onClose: (): void => this.closeOverlay(),
          onToast: (message: string): void => this.showToast(message)
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      } else if (this.fullScreenKind === 'results') {
        IdeaResultPage({
          selected: this.selectedIngredients,
          refreshToken: this.refreshToken,
          onClose: (): void => this.closeOverlay(),
          onOpenRecipe: (id: string): void => this.openRecipe(id)
        })
          .width('100%')
          .height('100%')
          .zIndex(12)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabBarItem(t: KitchenTabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      this.fullScreenKind = ''
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
