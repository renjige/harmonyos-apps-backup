import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { ProjectsPage } from './ProjectsPage'
import { InspectionPage } from './InspectionPage'
import { DocumentsPage } from './DocumentsPage'
import { MinePage } from './MinePage'
import { ProjectDetailPage } from './ProjectDetailPage'
import { SafetyDetailPage } from './SafetyDetailPage'
import { SettingsPage } from './SettingsPage'
import { HelpPage } from './HelpPage'
import { ProfilePage } from './ProfilePage'
import { FeedbackPage } from './FeedbackPage'
import { AboutPage } from './AboutPage'
import { SubRoute } from '../navigation/SubRoute'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const labels: string[] = ['首页', '项目', '巡检', '资料', '我的']
    const names: AppIconName[] = ['home', 'biz', 'alert', 'chart', 'user']
    for (let i = 0; i < labels.length; i++) {
      const t = new TabItem()
      t.index = i
      t.name = names[i]
      t.label = labels[i]
      tabs.push(t)
    }
    return tabs
  }
}

/** 筑科建筑 — 五 Tab 智慧工程管理 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State subRoute: string = SubRoute.none
  @State bizRefresh: number = 0
  @State projectId: string = ''
  @State safetyId: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @Prop company: string = '筑科建筑工程有限公司'
  @Prop appName: string = '筑科建筑'
  @Prop tagline: string = '智慧工程管理'
  @Prop @Watch('onContentVersionChange') contentVersion: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  onContentVersionChange(): void {
    this.bizRefresh = this.bizRefresh + 1
  }

  private closeSub(): void {
    this.subRoute = SubRoute.none
    AppStorage.set('tabBarHidden', false)
  }

  private openSub(route: string): void {
    this.subRoute = route
    AppStorage.set('tabBarHidden', true)
  }

  private bumpRefresh(): void {
    this.bizRefresh = this.bizRefresh + 1
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            company: this.company,
            appName: this.appName,
            tagline: this.tagline,
            refreshToken: this.bizRefresh,
            onOpenProject: (id: string) => {
              this.projectId = id
              this.openSub(SubRoute.projectDetail)
            },
            onGoTab: (index: number) => { this.current = index }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          ProjectsPage({
            refreshToken: this.bizRefresh,
            onOpenDetail: (id: string) => {
              this.projectId = id
              this.openSub(SubRoute.projectDetail)
            }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          InspectionPage({
            refreshToken: this.bizRefresh,
            onOpenSafety: (id: string) => {
              this.safetyId = id
              this.openSub(SubRoute.safetyDetail)
            }
          }).layoutWeight(1)
        } else if (this.current === 3) {
          DocumentsPage({
            refreshToken: this.bizRefresh
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.bizRefresh,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => this.onLogout(),
            onOpenRoute: (route: string) => this.openSub(route)
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              Column({ space: 2 }) {
                Column() {
                  AppIcon({
                    name: t.name,
                    iconSize: Theme.icon.md,
                    active: this.current === t.index
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
                    Theme.colors().brandPrimary : Theme.colors().textTertiary)
              }
              .layoutWeight(1)
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .padding({ top: 4, bottom: 4 })
              .onClick(() => { this.current = t.index })
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .padding({ bottom: 2 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({
            width: { top: 1 },
            color: Theme.colors().strokeHairline
          })
        }
      }
      .width('100%')
      .height('100%')

      if (this.subRoute === SubRoute.projectDetail) {
        ProjectDetailPage({
          projectId: this.projectId,
          onBack: () => this.closeSub(),
          onChanged: () => this.bumpRefresh()
        }).width('100%').height('100%')
      } else if (this.subRoute === SubRoute.safetyDetail) {
        SafetyDetailPage({
          itemId: this.safetyId,
          onBack: () => this.closeSub(),
          onChanged: () => this.bumpRefresh()
        }).width('100%').height('100%')
      } else if (this.subRoute === SubRoute.settings) {
        SettingsPage({
          onBack: () => this.closeSub(),
          onLogout: () => {
            this.closeSub()
            this.onLogout()
          }
        }).width('100%').height('100%')
      } else if (this.subRoute === SubRoute.help) {
        HelpPage({
          onBack: () => this.closeSub()
        }).width('100%').height('100%')
      } else if (this.subRoute === SubRoute.profile) {
        ProfilePage({
          onBack: () => this.closeSub(),
          onOpenLogin: () => this.onOpenLogin()
        }).width('100%').height('100%')
      } else if (this.subRoute === SubRoute.feedback) {
        FeedbackPage({
          onBack: () => this.closeSub()
        }).width('100%').height('100%')
      } else if (this.subRoute === SubRoute.about) {
        AboutPage({
          appName: this.appName,
          onBack: () => this.closeSub()
        }).width('100%').height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
