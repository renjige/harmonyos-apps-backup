import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { PantryPage } from './PantryPage'
import { RecipeBrowsePage } from './RecipeBrowsePage'
import { ShoppingPage } from './ShoppingPage'
import { MinePage } from './MinePage'
import { NotesListPage } from './NotesListPage'
import { AuthService } from '../services/AuthService'
import { KitchenLabDetailNav } from '../services/KitchenLabDetailNav'
import { KitchenLabBizService } from '../services/KitchenLabBizService'
import { RecipeItem } from '../models/KitchenLabModels'
import { RecipeDetailPane } from '../components/detail/RecipeDetailPane'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'chart'
    t0.label = '看板'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'leaf'
    t1.label = '食材'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'book'
    t2.label = '菜谱'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'cart'
    t3.label = '采购'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

/** 五 Tab：看板 | 食材 | 菜谱 | 采购 | 我的；详情 Overlay 顶层 + tabBarHidden */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State toastText: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('kitchenRoute') @Watch('onRoute') route: string = ''
  @StorageLink('mainTab') @Watch('onMainTab') mainTab: number = 0
  @StorageLink('kitchenTick') kitchenTick: number = 0
  @State recipe: RecipeItem = new RecipeItem()
  @State showNotes: boolean = false
  @Prop company: string = '承德锐泓科技信息有限公司'
  @Prop appName: string = '厨验Lab'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    this.current = this.mainTab
  }

  onMainTab(): void {
    this.current = this.mainTab
  }

  onRoute(): void {
    void this.resolveRoute()
  }

  private kind(): string {
    return KitchenLabDetailNav.kindOf(this.route)
  }

  private async resolveRoute(): Promise<void> {
    const kind = this.kind()
    const id = KitchenLabDetailNav.idOf(this.route)
    if (kind === 'recipe' && id.length > 0) {
      const row = await KitchenLabBizService.loadRecipeById(id)
      if (row !== undefined) {
        this.recipe = row
      }
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            tagline: this.tagline,
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 1) {
          PantryPage({
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 2) {
          RecipeBrowsePage().layoutWeight(1)
        } else if (this.current === 3) {
          ShoppingPage({
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: () => this.onOpenLogin(),
            onOpenNotes: (): void => {
              this.showNotes = true
              AppStorage.setOrCreate('tabBarHidden', true)
            },
            onOpenRecipe: (id: string): void => KitchenLabDetailNav.open('recipe', id),
            onLogout: () => {
              AuthService.logout()
              this.onLogout()
            },
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
          .shadow({ radius: 16, color: 'rgba(45,52,54,0.08)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.kind() === 'recipe') {
        RecipeDetailPane({
          item: this.recipe,
          onRequireAuth: () => this.onRequireAuth(),
          onToast: (m: string): void => this.showToast(m)
        })
          .width('100%')
          .height('100%')
      }

      if (this.showNotes) {
        NotesListPage({
          onClose: (): void => {
            this.showNotes = false
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onToast: (m: string): void => this.showToast(m)
        })
          .width('100%')
          .height('100%')
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .maxLines(3)
        }
        .width('100%')
        .padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      AppStorage.setOrCreate('mainTab', t.index)
    })
  }
}
