import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { HomePage } from './HomePage'
import { CoreBizPage } from './CoreBizPage'
import { AIAssistantPage } from './AIAssistantPage'
import { DashboardPage } from './DashboardPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
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
    t0.label = '首页'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '智企'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'ai'
    t2.label = 'AI'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'chart'
    t3.label = '看板'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

/** Tab ≤5。消息中心由首页入口进入。表单浮层时 tabBarHidden 隐藏底栏。 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State showMessages: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @Prop company: string = '观时文化'
  @Prop appName: string = '星座物候'
  @Prop tagline: string = '看星星，也看四季。以星座、物候、天象与生活观察，做成一本每日打开的数字天文生活杂志'
  @Prop quickCommands: string[] = ['分析本月经营概况', '生成经营周报', '待办任务优先级建议']
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            company: this.company,
            appName: this.appName,
            tagline: this.tagline,
            onOpenMessages: () => { this.showMessages = true }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          CoreBizPage({
            pageTitle: '智企',
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 2) {
          AIAssistantPage({
            quickCommands: this.quickCommands,
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 3) {
          DashboardPage({
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: () => this.onOpenLogin(),
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
          .shadow({ radius: 16, color: 'rgba(10,37,64,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showMessages) {
        Column() {
          MessagesPage().layoutWeight(1)
          AppButton({
            label: '返回',
            variant: 'secondary',
            onTap: () => { this.showMessages = false }
          }).margin(Theme.space.pageX)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
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
    })
  }
}
