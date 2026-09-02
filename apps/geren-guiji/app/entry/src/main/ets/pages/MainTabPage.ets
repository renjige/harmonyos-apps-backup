import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { FootprintHomePage } from './FootprintHomePage'
import { HistoryPage } from './HistoryPage'
import { InsightsPage } from './InsightsPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { TrackDetailPane } from '../components/detail/TrackDetailPane'
import { TrackDetailNav } from '../services/TrackDetailNav'
import { AuthService } from '../services/AuthService'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '足迹'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'calendar'
    t1.label = '历史'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '洞察'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'user'
    t3.label = '我的'
    tabs.push(t3)
    return tabs
  }
}

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State showMessages: boolean = false
  @State detailRefresh: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('trackDetailId') trackDetailId: string = ''
  @Prop company: string = '轨迹工坊'
  @Prop appName: string = '个人轨迹'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        if (this.current === 0) {
          FootprintHomePage({
            appName: this.appName,
            tagline: this.tagline,
            onOpenMessages: (): void => {
              this.showMessages = true
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          HistoryPage().layoutWeight(1)
        } else if (this.current === 2) {
          InsightsPage().layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: (): void => {
              this.onOpenLogin()
            },
            onLogout: (): void => {
              AuthService.logout()
              this.onLogout()
            }
          }).layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')

      if (!this.tabBarHidden) {
        Row() {
          ForEach(this.tabs, (t: TabItem) => {
            this.FloatingTabItem(t)
          }, (t: TabItem) => `${t.index}`)
        }
        .width('100%')
        .margin({ left: 16, right: 16, bottom: 16 })
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(Theme.colors().surfaceGlass)
        .borderRadius(Theme.radius.pill)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .shadow({
          radius: 24,
          color: Theme.isDark() ? 'rgba(0,0,0,0.40)' : 'rgba(26,35,50,0.12)',
          offsetY: 8
        })
        .backdropBlur(24)
      }

      if (this.showMessages) {
        Column() {
          MessagesPage().layoutWeight(1)
          AppButton({
            label: '返回',
            variant: 'secondary',
            onTap: (): void => {
              this.showMessages = false
              AppStorage.setOrCreate('tabBarHidden', false)
            }
          }).margin(Theme.space.pageX)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(15)
      }

      if (this.trackDetailId.length > 0) {
        TrackDetailPane({
          trackId: this.trackDetailId,
          onChanged: (): void => {
            this.detailRefresh += 1
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FloatingTabItem(t: TabItem) {
    Column({ space: 3 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: this.current === t.index ? Theme.icon.lg : Theme.icon.md,
          color: this.current === t.index ?
            Theme.colors().brandOnPrimary : Theme.colors().textSecondary
        })
      }
      .width(44)
      .height(32)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimary : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textTertiary)
    }
    .layoutWeight(1)
    .padding({ top: 8, bottom: 6 })
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
    })
  }
}
