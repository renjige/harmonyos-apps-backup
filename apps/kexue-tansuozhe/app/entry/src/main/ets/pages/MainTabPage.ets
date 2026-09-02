import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ExploreHubPage } from './ExploreHubPage'
import { AtlasPage } from './AtlasPage'
import { RecordPage } from './RecordPage'
import { MinePage } from './MinePage'
import { SearchOverlay } from './SearchOverlay'
import { DetailShell } from '../components/detail/DetailShell'
import { AtlasDetailPane } from '../components/detail/AtlasDetailPane'
import { RecordEditorOverlay } from './RecordEditorOverlay'
import { RecordDetailOverlay } from './RecordDetailOverlay'
import { StatsOverlay } from './StatsOverlay'
import { TimelineOverlay } from './TimelineOverlay'
import { ChallengeOverlay } from './ChallengeOverlay'
import { BadgesOverlay } from './BadgesOverlay'
import { DomainMapOverlay } from './DomainMapOverlay'
import { FavoritesOverlay } from './FavoritesOverlay'
import { TopicsOverlay } from './TopicsOverlay'
import { CalendarOverlay } from './CalendarOverlay'
import { LayoutConstants } from '../components/design-system/LayoutConstants'
import { ExploreNav } from '../services/ExploreNav'
import { ExploreToast } from '../services/ExploreToast'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const defs: string[][] = [
      ['0', 'home', '首页'],
      ['1', 'biz', '探索'],
      ['2', 'chart', '图鉴'],
      ['3', 'message', '记录'],
      ['4', 'user', '我的']
    ]
    for (const d of defs) {
      const t = new TabItem()
      t.index = parseInt(d[0], 10)
      t.name = d[1] as AppIconName
      t.label = d[2]
      tabs.push(t)
    }
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State toastText: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('mainTab') @Watch('onMainTab') mainTab: number = 0
  @StorageLink('showAtlasDetail') showAtlasDetail: boolean = false
  @StorageLink('showRecordEditor') showRecordEditor: boolean = false
  @StorageLink('showRecordDetail') showRecordDetail: boolean = false
  @StorageLink('showSearch') showSearch: boolean = false
  @StorageLink('showStats') showStats: boolean = false
  @StorageLink('showTimeline') showTimeline: boolean = false
  @StorageLink('showDomainMap') showDomainMap: boolean = false
  @StorageLink('showBadges') showBadges: boolean = false
  @StorageLink('showChallenge') showChallenge: boolean = false
  @StorageLink('showFavorites') showFavorites: boolean = false
  @StorageLink('showTopics') showTopics: boolean = false
  @StorageLink('showCalendar') showCalendar: boolean = false
  @StorageLink('atlasDetailId') atlasDetailId: string = ''
  @StorageLink('progressRev') progressRev: number = 0
  @StorageProp('globalToastTick') @Watch('onGlobalToast') globalToastTick: number = 0
  @Prop appName: string = '元素探索者'
  private tabs: TabItem[] = TabItem.all()
  private readonly tabBarHeight: number = Theme.nav.tabHeight
  private readonly tabDockBottom: number = LayoutConstants.TAB_DOCK_BOTTOM

  onMainTab(): void {
    if (this.mainTab >= 0 && this.mainTab <= 4) {
      this.current = this.mainTab
    }
  }

  private showToast(message: string): void {
    ExploreToast.show(message)
  }

  onGlobalToast(): void {
    const msg = AppStorage.get<string>('globalToast') ?? ''
    if (msg.length > 0) {
      this.toastText = msg
      setTimeout((): void => {
        this.toastText = ''
      }, 2800)
    }
  }

  private tabVisible(index: number): Visibility {
    return this.current === index ? Visibility.Visible : Visibility.Hidden
  }

  private tabHitTest(index: number): HitTestMode {
    return this.current === index ? HitTestMode.Default : HitTestMode.None
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
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick((): void => {
      ExploreNav.closeHubOverlays()
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      AppStorage.setOrCreate('mainTab', t.index)
    })
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        Stack() {
          HomePage()
            .width('100%')
            .height('100%')
            .visibility(this.tabVisible(0))
            .hitTestBehavior(this.tabHitTest(0))
          ExploreHubPage()
            .width('100%')
            .height('100%')
            .visibility(this.tabVisible(1))
            .hitTestBehavior(this.tabHitTest(1))
          AtlasPage()
            .width('100%')
            .height('100%')
            .visibility(this.tabVisible(2))
            .hitTestBehavior(this.tabHitTest(2))
          RecordPage()
            .width('100%')
            .height('100%')
            .visibility(this.tabVisible(3))
            .hitTestBehavior(this.tabHitTest(3))
          MinePage({
            appName: this.appName,
            onToast: (text: string): void => { this.showToast(text) }
          })
            .width('100%')
            .height('100%')
            .visibility(this.tabVisible(4))
            .hitTestBehavior(this.tabHitTest(4))
        }
        .width('100%')
        .height('100%')

        if (this.showAtlasDetail && this.atlasDetailId.length > 0) {
          Column() {
            DetailShell({
              title: '图鉴详情',
              onClose: (): void => { ExploreNav.closeAtlasDetail() }
            }) {
              AtlasDetailPane({
                atlasId: this.atlasDetailId,
                onToast: (text: string): void => { this.showToast(text) }
              })
            }
          }
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.colors().surfacePage)
          .zIndex(15)
        }

        if (this.showRecordEditor) {
          RecordEditorOverlay({ onToast: (text: string): void => { this.showToast(text) } })
            .width('100%')
            .height('100%')
            .zIndex(16)
        }

        if (this.showRecordDetail) {
          RecordDetailOverlay({ onToast: (text: string): void => { this.showToast(text) } })
            .width('100%')
            .height('100%')
            .zIndex(17)
        }

        if (this.showSearch) {
          SearchOverlay()
            .width('100%')
            .height('100%')
            .zIndex(14)
        }

        if (this.showStats) {
          StatsOverlay()
            .width('100%')
            .height('100%')
            .zIndex(18)
        }

        if (this.showTimeline) {
          TimelineOverlay()
            .width('100%')
            .height('100%')
            .zIndex(19)
        }

        if (this.showChallenge) {
          ChallengeOverlay()
            .width('100%')
            .height('100%')
            .zIndex(20)
        }

        if (this.showBadges) {
          BadgesOverlay()
            .width('100%')
            .height('100%')
            .zIndex(21)
        }

        if (this.showDomainMap) {
          DomainMapOverlay()
            .width('100%')
            .height('100%')
            .zIndex(22)
        }

        if (this.showFavorites) {
          FavoritesOverlay()
            .width('100%')
            .height('100%')
            .zIndex(23)
        }

        if (this.showTopics) {
          TopicsOverlay()
            .width('100%')
            .height('100%')
            .zIndex(24)
        }

        if (this.showCalendar) {
          CalendarOverlay()
            .width('100%')
            .height('100%')
            .zIndex(25)
        }

        if (this.toastText.length > 0) {
          Text(this.toastText)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textOnInverse)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().surfaceInverse)
            .borderRadius(Theme.radius.pill)
            .margin({ top: Theme.space.s8 })
            .zIndex(50)
        }
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
        .height(this.tabBarHeight)
        .margin({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: this.tabDockBottom
        })
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(VerticalAlign.Center)
        .backgroundColor(Theme.colors().surfaceGlass)
        .borderRadius(Theme.radius.sheet)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .shadow({ radius: 20, color: 'rgba(27,67,50,0.12)', offsetY: 4 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
