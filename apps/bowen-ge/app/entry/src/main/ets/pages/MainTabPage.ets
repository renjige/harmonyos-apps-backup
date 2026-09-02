import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { DetailShell } from '../components/detail/DetailShell'
import { ThoughtDetailPane } from '../components/detail/ThoughtDetailPane'
import { ReadingDetailPane } from '../components/detail/ReadingDetailPane'
import { CardDetailPane } from '../components/detail/CardDetailPane'
import { SparkDetailPane } from '../components/detail/SparkDetailPane'
import { ThemeDetailPane } from '../components/detail/ThemeDetailPane'
import { StudyLogDetailPane } from '../components/detail/StudyLogDetailPane'
import { EntryEditorSheet } from '../components/editors/EntryEditorSheet'
import { GlobalSearchSheet } from '../components/search/GlobalSearchSheet'
import { HomePage } from './HomePage'
import { KnowledgePage } from './KnowledgePage'
import { ThemePage } from './ThemePage'
import { ReviewPage } from './ReviewPage'
import { MinePage } from './MinePage'
import { BowenNav } from '../services/BowenNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '博闻'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'book'
    t1.label = '知识'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'grid'
    t2.label = '专题'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'calendar'
    t3.label = '回顾'
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
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State refreshToken: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('thoughtDetailId') thoughtDetailId: string = ''
  @StorageLink('readingDetailId') readingDetailId: string = ''
  @StorageLink('cardDetailId') cardDetailId: string = ''
  @StorageLink('sparkDetailId') sparkDetailId: string = ''
  @StorageLink('themeDetailId') themeDetailId: string = ''
  @StorageLink('studyDetailId') studyDetailId: string = ''
  @StorageLink('editorOpen') @Watch('onEditorOpenChange') editorOpen: boolean = false
  @StorageLink('searchOpen') @Watch('onSearchOpenChange') searchOpen: boolean = false
  @StorageProp('bowenDataRev') @Watch('onDataRevChange') bowenDataRev: number = 0
  onPrivacyRevoked: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = 60
  private readonly tabSafeBottom: number = 16

  private bumpRefresh(): void {
    this.refreshToken = this.refreshToken + 1
  }

  onEditorOpenChange(): void {
    if (!this.editorOpen) {
      this.bumpRefresh()
    }
  }

  onSearchOpenChange(): void {
    if (!this.searchOpen) {
      this.bumpRefresh()
    }
  }

  onDataRevChange(): void {
    this.bumpRefresh()
  }

  private switchTab(index: number): void {
    AppStorage.setOrCreate('tabBarHidden', false)
    this.current = index
    this.refreshToken++
  }

  private hasDetail(): boolean {
    return this.thoughtDetailId.length > 0 || this.readingDetailId.length > 0 ||
      this.cardDetailId.length > 0 || this.sparkDetailId.length > 0 ||
      this.themeDetailId.length > 0 || this.studyDetailId.length > 0
  }

  private detailTitle(): string {
    if (this.readingDetailId.length > 0) {
      return '阅读沉淀'
    }
    if (this.cardDetailId.length > 0) {
      return '知识卡片'
    }
    if (this.sparkDetailId.length > 0) {
      return '灵感'
    }
    if (this.studyDetailId.length > 0) {
      return '学习记录'
    }
    if (this.themeDetailId.length > 0) {
      return '专题空间'
    }
    return '思考档案'
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onSwitchTab: (index: number): void => { this.switchTab(index) }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          KnowledgePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom
          }).layoutWeight(1)
        } else if (this.current === 2) {
          ThemePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom
          }).layoutWeight(1)
        } else if (this.current === 3) {
          ReviewPage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom
          }).layoutWeight(1)
        } else {
          MinePage({
            refreshToken: this.refreshToken,
            bottomInset: this.tabBarHeight + this.tabSafeBottom,
            onPrivacyRevoked: (): void => { this.onPrivacyRevoked() },
            onDataChanged: (): void => { this.bumpRefresh() }
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(this.tabBarHeight)
          .padding({ left: Theme.space.s3, right: Theme.space.s3, bottom: this.tabSafeBottom })
          .margin({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s2 })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 16, color: 'rgba(18,38,47,0.08)', offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.hasDetail()) {
        DetailShell({ title: this.detailTitle(), onClose: (): void => { BowenNav.closeDetails(); this.bumpRefresh() } }) {
          if (this.readingDetailId.length > 0) {
            ReadingDetailPane({ itemId: this.readingDetailId })
          } else if (this.studyDetailId.length > 0) {
            StudyLogDetailPane({ itemId: this.studyDetailId })
          } else if (this.cardDetailId.length > 0) {
            CardDetailPane({ itemId: this.cardDetailId })
          } else if (this.sparkDetailId.length > 0) {
            SparkDetailPane({ itemId: this.sparkDetailId })
          } else if (this.themeDetailId.length > 0) {
            ThemeDetailPane({ itemId: this.themeDetailId })
          } else {
            ThoughtDetailPane({ itemId: this.thoughtDetailId })
          }
        }
      }

      if (this.editorOpen) {
        EntryEditorSheet({
          onSaved: (): void => { this.bumpRefresh() }
        })
      }

      if (this.searchOpen) {
        GlobalSearchSheet()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          active: this.current === t.index,
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : Color.Transparent)
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(10)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick((): void => { this.switchTab(t.index) })
  }
}
