import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { WardrobePage } from './WardrobePage'
import { OutfitPage } from './OutfitPage'
import { CalendarPage } from './CalendarPage'
import { MinePage } from './MinePage'
import { MessagesPage } from './MessagesPage'
import { AuthService } from '../services/AuthService'
import { WardrobeItemModel } from '../models/WardrobeModels'

class TabItem {
  index: number = 0
  name: AppIconName = 'wardrobe'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'wardrobe'
    t0.label = '衣橱'
    tabs.push(t0)

    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'sparkle'
    t1.label = '穿搭'
    tabs.push(t1)

    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'calendar'
    t2.label = '日历'
    tabs.push(t2)

    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'user'
    t3.label = '我的'
    tabs.push(t3)

    return tabs
  }
}

/**
 * 底部导航 4 个一级入口：衣橱、穿搭、日历、我的。
 * 消息中心由首页入口进入。表单浮层时 tabBarHidden 隐藏底栏。
 */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State showMessages: boolean = false
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @Prop company: string = '魏文波'
  @Prop appName: string = '清凉衣橱'
  @Prop tagline: string = '整理衣物，也整理每天的心情'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          WardrobePage({
            company: this.company,
            appName: this.appName,
            tagline: this.tagline,
            onOpenMessages: () => { this.showMessages = true },
            onNavigateToOutfitWithItem: (_item: WardrobeItemModel) => {
              this.current = 1
            }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          OutfitPage({
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 2) {
          CalendarPage({
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
          })
          .margin(Theme.space.s4)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfaceBackground)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private TabBarItem(t: TabItem) {
    Column() {
      Column({ space: 2 }) {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textTertiary
        })
        Text(t.label)
          .fontSize(Theme.type.caption2)
          .fontWeight(this.current === t.index ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textTertiary)
      }
      .width('100%')
      .height(Theme.icon.minTouch)
      .justifyContent(FlexAlign.Center)
      .borderRadius(Theme.radius.pill)
      .backgroundColor(this.current === t.index ? (Theme.isDark() ? '#1C332D' : '#EBF7F2') : 'transparent')
    }
    .layoutWeight(1)
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .onClick(() => { this.current = t.index })
  }
}
