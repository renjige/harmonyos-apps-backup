import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { InspectionListPage } from './InspectionListPage'
import { IssueListPage } from './IssueListPage'
import { MinePage } from './MinePage'
import { QualityOverlayHost } from '../components/forms/QualityOverlayHost'
import { AuthService } from '../services/AuthService'
import { QualityNav } from '../services/QualityNav'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '首页'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '巡查'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'alert'
    t2.label = '问题'
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
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('qualityTab') current: number = 0
  @StorageLink('qualityToast') toastText: string = ''
  @StorageLink('qualityTick') refreshToken: number = 0
  @StorageLink('qualityDataVersion') dataVersion: string = '0'
  @Prop company: string = '筑科建筑工程有限公司'
  @Prop appName: string = '筑科质量巡查'
  @Prop tagline: string = '让每一次巡查，都有迹可循'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    if (this.toastText.length > 0) {
      this.scheduleToastClear()
    }
  }

  private scheduleToastClear(): void {
    const text = this.toastText
    setTimeout(() => {
      if (this.toastText === text) {
        this.toastText = ''
      }
    }, 2600)
  }

  build() {
    Stack() {
      Column() {
        Stack() {
          HomePage({
            appName: this.appName,
            tagline: this.tagline
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 0 ? Visibility.Visible : Visibility.None)

          InspectionListPage({ refreshToken: this.refreshToken })
            .width('100%')
            .height('100%')
            .visibility(this.current === 1 ? Visibility.Visible : Visibility.None)

          IssueListPage({ refreshToken: this.refreshToken, dataVersion: this.dataVersion })
            .width('100%')
            .height('100%')
            .visibility(this.current === 2 ? Visibility.Visible : Visibility.None)

          MinePage({
            appName: this.appName,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => {
              AuthService.logout()
              this.onLogout()
            },
            onOpenInspect: () => QualityNav.setTab(1),
            onOpenIssues: (filter: string) => {
              QualityNav.setIssueFilter(filter)
              QualityNav.setTab(2)
            }
          })
            .width('100%')
            .height('100%')
            .visibility(this.current === 3 ? Visibility.Visible : Visibility.None)
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
          .height(Theme.nav.tabHeight)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
          .shadow({ radius: 16, color: 'rgba(10,37,64,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      QualityOverlayHost()

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .maxLines(2)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ top: 48, left: 20, right: 20 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
        .onAppear(() => this.scheduleToastClear())
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
      QualityNav.bump()
    })
  }
}
