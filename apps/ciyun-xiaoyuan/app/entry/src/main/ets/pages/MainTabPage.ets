import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { HomePage } from './HomePage'
import { MeterPage } from './MeterPage'
import { AppreciatePage } from './AppreciatePage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AuthService } from '../services/AuthService'
import { CourtyardDetailNav } from '../services/CourtyardDetailNav'
import { PoemDetailPane } from '../components/detail/PoemDetailPane'
import { CipaiDetailPane } from '../components/detail/CipaiDetailPane'
import { RhymeDetailPane } from '../components/detail/RhymeDetailPane'
import { ArticleDetailPane } from '../components/detail/ArticleDetailPane'
import { WorkDetailPane } from '../components/detail/WorkDetailPane'
import { SimpleListPane } from '../components/detail/SimpleListPane'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '诗库'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'biz'
    t1.label = '格律'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'ai'
    t2.label = '赏析'
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
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('detailRoute') detailRoute: string = ''
  @StorageLink('switchTab') @Watch('onSwitchTabChange') switchTab: number = -1
  @Prop company: string = '词韵雅集'
  @Prop appName: string = '词韵小院'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    this.applySwitch()
  }

  onSwitchTabChange(): void {
    this.applySwitch()
  }

  private applySwitch(): void {
    if (this.switchTab >= 0 && this.switchTab <= 3) {
      this.current = this.switchTab
      AppStorage.setOrCreate('switchTab', -1)
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            tagline: this.tagline,
            onOpenMessages: () => { this.showMessages = true }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          MeterPage().layoutWeight(1)
        } else if (this.current === 2) {
          AppreciatePage().layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => {
              AuthService.logout()
              this.onLogout()
            }
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

      if (this.detailRoute.length > 0) {
        Column() {
          this.DetailHost()
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => { this.applySwitch() })
  }

  @Builder
  DetailHost() {
    if (CourtyardDetailNav.parseKind() === 'poem') {
      PoemDetailPane({
        poemId: CourtyardDetailNav.parseId(),
        onClose: (): void => { CourtyardDetailNav.close() }
      })
    } else if (CourtyardDetailNav.parseKind() === 'cipai') {
      CipaiDetailPane({
        cipaiId: CourtyardDetailNav.parseId(),
        onClose: (): void => { CourtyardDetailNav.close() }
      })
    } else if (CourtyardDetailNav.parseKind() === 'rhyme') {
      RhymeDetailPane({
        rhymeId: CourtyardDetailNav.parseId(),
        onClose: (): void => { CourtyardDetailNav.close() }
      })
    } else if (CourtyardDetailNav.parseKind() === 'article') {
      ArticleDetailPane({
        articleId: CourtyardDetailNav.parseId(),
        onClose: (): void => { CourtyardDetailNav.close() }
      })
    } else if (CourtyardDetailNav.parseKind() === 'work') {
      WorkDetailPane({
        workId: CourtyardDetailNav.parseId(),
        onClose: (): void => { CourtyardDetailNav.close() }
      })
    } else {
      SimpleListPane({
        kind: CourtyardDetailNav.parseId(),
        onClose: (): void => { CourtyardDetailNav.close() }
      })
    }
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
