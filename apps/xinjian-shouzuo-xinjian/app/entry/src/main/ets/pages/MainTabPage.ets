import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { HomePage } from './HomePage'
import { ClassroomPage } from './ClassroomPage'
import { CreateHubPage } from './CreateHubPage'
import { GrowthPage } from './GrowthPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { WorkDetailPane } from '../components/detail/WorkDetailPane'
import { GuideDetailPane } from '../components/detail/GuideDetailPane'
import { AuthService } from '../services/AuthService'
import { CraftDetailNav } from '../services/CraftDetailNav'

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
    t1.name = 'ai'
    t1.label = '课堂'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'biz'
    t2.label = '创作'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'chart'
    t3.label = '成长'
    tabs.push(t3)
    const t4 = new TabItem()
    t4.index = 4
    t4.name = 'user'
    t4.label = '我的'
    tabs.push(t4)
    return tabs
  }
}

/** 5 Tab：首页 | 课堂 | 创作 | 成长 | 我的 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('createHubSegment') createHubSegment: number = 0
  @State current: number = 0
  @State showMessages: boolean = false
  @State detailRefresh: number = 0
  @State mineRefresh: number = 0
  @Prop @Watch('onLoginRefreshChange') loginRefresh: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('craftDetailWorkId') craftDetailWorkId: string = ''
  @StorageLink('craftDetailGuideId') craftDetailGuideId: string = ''
  @StorageLink('mainTabNavToken') @Watch('onMainTabNav') mainTabNavToken: number = 0
  @Prop company: string = '心笺生活美学'
  @Prop appName: string = '手作心笺'
  @Prop tagline: string = '手作记录与生活美学工具，温暖记录每一次创作灵感'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    AppStorage.setOrCreate('createHubSegment', 0)
    AppStorage.setOrCreate('craftDataEpoch', 0)
    AppStorage.setOrCreate('createFormOpen', false)
    AppStorage.setOrCreate('mainTabNavToken', 0)
    AppStorage.setOrCreate('mainTabNavTarget', -1)
  }

  onMainTabNav(): void {
    const target = AppStorage.get<number>('mainTabNavTarget') ?? -1
    if (target >= 0 && target <= 4) {
      this.current = target
      AppStorage.setOrCreate('mainTabNavTarget', -1)
    }
  }

  onLoginRefreshChange(): void {
    this.mineRefresh += 1
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          Column() {
            HomePage({
              refreshToken: this.detailRefresh,
              onOpenMessages: (): void => { this.showMessages = true },
              onOpenClassroom: (): void => { this.current = 1 },
              onOpenCreate: (): void => {
                AppStorage.setOrCreate('createHubSegment', 0)
                this.current = 2
              },
              onOpenGrowth: (): void => { this.current = 3 },
              onOpenCreateAssistant: (): void => {
                AppStorage.setOrCreate('createHubSegment', 2)
                this.current = 2
              },
              onRequireAuth: (): void => this.onRequireAuth()
            })
          }.layoutWeight(1)
        } else if (this.current === 1) {
          Column() {
            ClassroomPage()
          }.layoutWeight(1)
        } else if (this.current === 2) {
          Column() {
            CreateHubPage({
              onRequireAuth: (): void => this.onRequireAuth()
            })
          }.layoutWeight(1)
        } else if (this.current === 3) {
          Column() {
            GrowthPage({
              onRequireAuth: (): void => this.onRequireAuth()
            })
          }.layoutWeight(1)
        } else {
          Column() {
            MinePage({
              appName: this.appName,
              refreshToken: this.mineRefresh,
              onOpenLogin: (): void => this.onOpenLogin(),
              onLogout: (): void => {
                AuthService.logout()
                this.mineRefresh += 1
                this.onLogout()
              },
              onRequireAuth: (): void => this.onRequireAuth()
            })
          }.layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .backgroundColor(Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
          .shadow({ radius: 16, color: 'rgba(61,58,54,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showMessages) {
        Column() {
          Column() {
            MessagesPage()
          }.layoutWeight(1)
          Column() {
            AppButton({
              label: '返回',
              variant: 'secondary',
              onTap: (): void => { this.showMessages = false }
            })
          }.margin(Theme.space.pageX)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)
        .zIndex(15)
      }

      if (this.craftDetailGuideId.length > 0) {
        Column() {
          GuideDetailPane({
            guideId: this.craftDetailGuideId,
            onGoCreate: (): void => {
              this.onMainTabNav()
            }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(20)
      } else if (this.craftDetailWorkId.length > 0) {
        Column() {
          WorkDetailPane({
            workId: this.craftDetailWorkId,
            refreshToken: this.detailRefresh,
            onRequireAuth: (): void => this.onRequireAuth(),
            onChanged: (): void => {
              this.detailRefresh += 1
              this.mineRefresh += 1
              const v = AppStorage.get<number>('craftDataEpoch') ?? 0
              AppStorage.setOrCreate('craftDataEpoch', v + 1)
            }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(20)
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
            Theme.colors().brandDeep : Theme.colors().textSecondary
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
          Theme.colors().brandDeep : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      if (CraftDetailNav.isOpen()) {
        CraftDetailNav.close()
      }
      AppStorage.setOrCreate('tabBarHidden', false)
      this.current = t.index
      if (t.index === 4) {
        this.mineRefresh += 1
      }
    })
  }
}
