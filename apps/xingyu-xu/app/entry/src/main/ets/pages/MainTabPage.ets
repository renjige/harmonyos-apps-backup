import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { NarrativePage } from './NarrativePage'
import { ThemeSpacePage } from './ThemeSpacePage'
import { ReviewPage } from './ReviewPage'
import { MinePage } from './MinePage'
import { DetailShell } from '../components/detail/DetailShell'
import { NarrativeDetailPane } from '../components/detail/NarrativeDetailPane'
import { SparkDetailPane } from '../components/detail/SparkDetailPane'
import { ThemeDetailPane } from '../components/detail/ThemeDetailPane'
import { NarrativeEditorSheet } from '../components/xingyu/NarrativeEditorSheet'
import { SparkEditorSheet } from '../components/xingyu/SparkEditorSheet'
import { ThemeEditorSheet } from '../components/xingyu/ThemeEditorSheet'
import { SearchSheet, FavoritesSheet, AchievementSheet, TagManagerSheet } from '../components/xingyu/OverlaySheets'
import { XingyuNav } from '../services/XingyuNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '星隅'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '叙事'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'book'
    t2.label = '主题'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'calendar'
    t3.label = '回望'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @State current: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('xingyuTabIndex') @Watch('onTabLink') xingyuTabIndex: number = 0
  @StorageLink('xingyuNarrativeId') narrativeId: string = ''
  @StorageLink('xingyuSparkId') sparkId: string = ''
  @StorageLink('xingyuThemeId') themeId: string = ''
  @StorageLink('xingyuEditorKind') editorKind: string = ''
  @StorageLink('xingyuEditorId') editorId: string = ''
  @StorageLink('xingyuSearchOpen') searchOpen: boolean = false
  @StorageLink('xingyuFavOpen') favOpen: boolean = false
  @StorageLink('xingyuAchieveOpen') achieveOpen: boolean = false
  @StorageLink('xingyuTagsOpen') tagsOpen: boolean = false
  @Prop company: string = '星隅叙'
  @Prop appName: string = '星隅叙'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  onTabLink(): void {
    this.current = this.xingyuTabIndex
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({ appName: this.appName }).layoutWeight(1)
        } else if (this.current === 1) {
          NarrativePage().layoutWeight(1)
        } else if (this.current === 2) {
          ThemeSpacePage().layoutWeight(1)
        } else if (this.current === 3) {
          ReviewPage().layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => { this.onOpenLogin() },
            onLogout: (): void => { this.onLogout() }
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem): string => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .margin({ left: Theme.space.s3, right: Theme.space.s3, bottom: Theme.space.s3 })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }
      }
      .width('100%')
      .height('100%')

      if (this.narrativeId.length > 0) {
        DetailShell({ title: '叙事档案', onBack: (): void => { XingyuNav.closeNarrative() } }) {
          NarrativeDetailPane({ narrativeId: this.narrativeId })
        }
      }
      if (this.sparkId.length > 0) {
        DetailShell({ title: '灵感星库', onBack: (): void => { XingyuNav.closeSpark() } }) {
          SparkDetailPane({ sparkId: this.sparkId })
        }
      }
      if (this.themeId.length > 0) {
        DetailShell({ title: '主题空间', onBack: (): void => { XingyuNav.closeTheme() } }) {
          ThemeDetailPane({ themeId: this.themeId })
        }
      }
      if (this.editorKind === 'narrative') {
        NarrativeEditorSheet({ editorId: this.editorId })
          .width('100%')
          .height('100%')
      }
      if (this.editorKind === 'spark') {
        SparkEditorSheet({ editorId: this.editorId })
          .width('100%')
          .height('100%')
      }
      if (this.editorKind === 'theme') {
        ThemeEditorSheet({ editorId: this.editorId })
          .width('100%')
          .height('100%')
      }
      if (this.searchOpen) {
        SearchSheet()
          .width('100%')
          .height('100%')
      }
      if (this.favOpen) {
        FavoritesSheet()
          .width('100%')
          .height('100%')
      }
      if (this.achieveOpen) {
        AchievementSheet()
          .width('100%')
          .height('100%')
      }
      if (this.tagsOpen) {
        TagManagerSheet()
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }

  @Builder
  TabBarItem(t: TabItem) {
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
    .onClick((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      AppStorage.setOrCreate('xingyuTabIndex', t.index)
    })
  }
}
