import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ChapterHubPage } from './ChapterHubPage'
import { GoalsPage } from './GoalsPage'
import { GrowthPage } from './GrowthPage'
import { MinePage } from './MinePage'
import { GoalDetailPane } from '../components/detail/GoalDetailPane'
import { GoalCreateSheet } from '../components/detail/GoalCreateSheet'
import { TaskAddSheet } from '../components/detail/TaskAddSheet'
import { TaskDetailPane } from '../components/detail/TaskDetailPane'
import { ChapterCreateSheet } from '../components/detail/ChapterCreateSheet'
import { ChapterDetailPane } from '../components/detail/ChapterDetailPane'
import { SearchSheet } from '../components/yuedong/SearchSheet'
import { FavoritesSheet } from '../components/yuedong/FavoritesSheet'
import { CheckInSheet } from '../components/yuedong/CheckInSheet'
import { TagsManageSheet } from '../components/yuedong/TagsManageSheet'
import { YdHelpSheet } from '../components/yuedong/YdHelpSheet'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { YdDetailNav } from '../services/YdDetailNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: TabItem[] = []
    const d0 = new TabItem()
    d0.index = 0
    d0.name = 'home'
    d0.label = '今日'
    defs.push(d0)
    const d1 = new TabItem()
    d1.index = 1
    d1.name = 'biz'
    d1.label = '篇章'
    defs.push(d1)
    const d2 = new TabItem()
    d2.index = 2
    d2.name = 'check'
    d2.label = '目标'
    defs.push(d2)
    const d3 = new TabItem()
    d3.index = 3
    d3.name = 'chart'
    d3.label = '成长'
    defs.push(d3)
    const d4 = new TabItem()
    d4.index = 4
    d4.name = 'user'
    d4.label = '我的'
    defs.push(d4)
    for (const d of defs) {
      tabs.push(d)
    }
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('ydSwitchTab') @Watch('onSwitchTabChange') switchTab: number = -1
  @State current: number = 0
  @State dataRefresh: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('ydGoalDetailId') goalDetailId: string = ''
  @StorageLink('ydGoalCreateOpen') goalCreateOpen: boolean = false
  @StorageLink('ydTaskAddOpen') taskAddOpen: boolean = false
  @StorageLink('ydTaskDetailId') taskDetailId: string = ''
  @StorageLink('ydChapterCreateOpen') chapterCreateOpen: boolean = false
  @StorageLink('ydChapterDetailId') chapterDetailId: string = ''
  @StorageLink('ydSearchOpen') searchOpen: boolean = false
  @StorageLink('ydFavoritesOpen') favoritesOpen: boolean = false
  @StorageLink('ydCheckInOpen') checkInOpen: boolean = false
  @StorageLink('ydTagsOpen') tagsOpen: boolean = false
  @StorageLink('ydHelpOpen') helpOpen: boolean = false
  @StorageLink('ydLegalOpen') legalOpen: boolean = false
  @StorageLink('ydLegalKind') legalKind: string = 'privacy'
  @Prop appName: string = '跃动新章'
  private tabs: TabItem[] = TabItem.all()

  private bumpRefresh(): void {
    this.dataRefresh++
    const global = (AppStorage.get<number>('ydDataRefresh') ?? 0) + 1
    AppStorage.setOrCreate('ydDataRefresh', global)
  }

  aboutToAppear(): void {
    AppStorage.setOrCreate('ydSwitchTab', -1)
    AppStorage.setOrCreate('ydDataRefresh', 0)
    AppStorage.setOrCreate('ydLegalOpen', false)
    AppStorage.setOrCreate('ydLegalKind', 'privacy')
  }

  private onSwitchTabChange(): void {
    if (this.switchTab >= 0 && this.switchTab <= 4) {
      this.current = this.switchTab
      AppStorage.setOrCreate('ydSwitchTab', -1)
      this.bumpRefresh()
    }
  }

  build() {
    Stack() {
      Column() {
        Stack() {
          HomePage({
            appName: this.appName,
            refreshToken: this.dataRefresh,
            onDataChanged: (): void => { this.bumpRefresh() }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 0 ? Visibility.Visible : Visibility.None)
          ChapterHubPage({ refreshToken: this.dataRefresh })
            .width('100%')
            .height('100%')
            .visibility(this.current === 1 ? Visibility.Visible : Visibility.None)
          GoalsPage({ refreshToken: this.dataRefresh })
            .width('100%')
            .height('100%')
            .visibility(this.current === 2 ? Visibility.Visible : Visibility.None)
          GrowthPage({ refreshToken: this.dataRefresh })
            .width('100%')
            .height('100%')
            .visibility(this.current === 3 ? Visibility.Visible : Visibility.None)
          MinePage({
            appName: this.appName,
            refreshToken: this.dataRefresh
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 4 ? Visibility.Visible : Visibility.None)
        }
        .layoutWeight(1)
        .width('100%')

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .margin({ left: Theme.space.s2, right: Theme.space.s2, bottom: Theme.space.s3 })
          .padding({ top: 4, bottom: 4, left: 4, right: 4 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .shadow({ radius: 16, color: 'rgba(10,37,64,0.08)', offsetY: -2 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.goalDetailId.length > 0) {
        GoalDetailPane({ goalId: this.goalDetailId, onChanged: (): void => { this.bumpRefresh() } })
          .width('100%')
          .height('100%')
      }
      if (this.goalCreateOpen) {
        GoalCreateSheet({ onCreated: (): void => { this.bumpRefresh() } })
      }
      if (this.taskAddOpen) {
        TaskAddSheet({ onCreated: (): void => { this.bumpRefresh() } })
      }
      if (this.taskDetailId.length > 0) {
        TaskDetailPane({ taskId: this.taskDetailId, onChanged: (): void => { this.bumpRefresh() } })
      }
      if (this.chapterCreateOpen) {
        ChapterCreateSheet({ onCreated: (): void => { this.bumpRefresh() } })
      }
      if (this.chapterDetailId.length > 0) {
        ChapterDetailPane({ chapterId: this.chapterDetailId, onChanged: (): void => { this.bumpRefresh() } })
          .width('100%')
          .height('100%')
      }
      if (this.searchOpen) {
        SearchSheet()
      }
      if (this.favoritesOpen) {
        FavoritesSheet({ refreshToken: this.dataRefresh })
      }
      if (this.checkInOpen) {
        CheckInSheet({ onDone: (): void => { this.bumpRefresh() } })
      }
      if (this.tagsOpen) {
        TagsManageSheet()
      }
      if (this.helpOpen) {
        YdHelpSheet()
      }
      if (this.legalOpen) {
        LegalDocOverlay({
          kind: this.legalKind === 'agreement' ? 'agreement' : 'privacy',
          onClose: (): void => { YdDetailNav.closeLegal() }
        })
          .width('100%')
          .height('100%')
          .zIndex(200)
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
          iconSize: Theme.icon.sm,
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(40)
      .height(24)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(10)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height(Theme.nav.tabHeight - 4)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      this.bumpRefresh()
    })
  }
}
