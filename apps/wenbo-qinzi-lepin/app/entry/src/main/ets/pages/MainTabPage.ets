import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { FamilyPage } from './FamilyPage'
import { GrowthPage } from './GrowthPage'
import { MinePage } from './MinePage'
import { ThemeListOverlay } from './ThemeListOverlay'
import { JigsawDetailOverlay } from './JigsawDetailOverlay'
import { JigsawPlayOverlay } from './JigsawPlayOverlay'
import { MessagesPage } from './MessagesPage'
import { AIAssistantPage } from './AIAssistantPage'
import { JigsawNav } from '../services/JigsawNav'
import { AuthService } from '../services/AuthService'
import { MedalItem, GuideItem } from '../models/JigsawModels'
import { JigsawBizService } from '../services/JigsawBizService'
import { JigsawMedia } from '../services/JigsawMedia'
import { ProgressStore } from '../services/ProgressStore'
import { DiagnoseService } from '../services/DiagnoseService'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '乐园'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'message'
    t1.label = '亲子'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'chart'
    t2.label = '成长'
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
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('jigRoute') jigRoute: string = ''
  @StorageLink('mainTab') @Watch('onMainTab') mainTab: number = 0
  @StorageLink('jigTick') tick: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '亲子乐拼'
  @Prop tagline: string = '一起拼，一起长'
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    this.current = this.mainTab
  }

  onMainTab(): void {
    this.current = this.mainTab
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage().layoutWeight(1)
        } else if (this.current === 1) {
          FamilyPage().layoutWeight(1)
        } else if (this.current === 2) {
          GrowthPage().layoutWeight(1)
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
          .shadow({ radius: 16, color: 'rgba(92,46,18,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.jigRoute === JigsawNav.THEME) {
        ThemeListOverlay().width('100%').height('100%')
      } else if (this.jigRoute === JigsawNav.DETAIL) {
        JigsawDetailOverlay().width('100%').height('100%')
      } else if (this.jigRoute === JigsawNav.PLAY) {
        JigsawPlayOverlay().width('100%').height('100%')
      } else if (this.jigRoute === JigsawNav.MESSAGES) {
        Column() {
          Row() {
            Text('返回')
              .fontSize(16)
              .fontColor(Theme.colors().brandPrimary)
              .onClick(() => { JigsawNav.setRoute(JigsawNav.NONE) })
            Text('消息')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .margin({ left: 12 })
          }
          .width('100%')
          .padding(16)
          MessagesPage().layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      } else if (this.jigRoute === JigsawNav.DIAGNOSE) {
        Column() {
          Row() {
            Text('返回')
              .fontSize(16)
              .fontColor(Theme.colors().brandPrimary)
              .onClick(() => { JigsawNav.setRoute(JigsawNav.NONE) })
            Text('陪伴建议')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .margin({ left: 12 })
          }
          .width('100%')
          .padding(16)
          AIAssistantPage({
            onBookFromAi: (category: string) => {
              JigsawNav.openTheme(DiagnoseService.themeKeyOf(category))
            }
          }).layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      } else if (this.jigRoute === JigsawNav.MEDALS) {
        MedalOverlay()
      } else if (this.jigRoute === JigsawNav.GUIDE) {
        GuideOverlay()
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
        .fontSize(11)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.current = t.index
      AppStorage.setOrCreate('mainTab', t.index)
    })
  }
}

@Component
struct MedalOverlay {
  @State items: MedalItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.items = await JigsawBizService.loadMedals()
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(16)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => { JigsawNav.setRoute(JigsawNav.NONE) })
        Text('成就徽章')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .margin({ left: 12 })
      }
      .width('100%')
      .padding(16)
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.items, (m: MedalItem) => {
            Row({ space: 12 }) {
              Image(JigsawMedia.cover(m.coverKey))
                .width(64)
                .height(64)
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
                .opacity(ProgressStore.isMedalOn(m.id) ? 1 : 0.4)
              Column({ space: 4 }) {
                Text(m.title)
                  .fontSize(16)
                  .fontColor(Theme.colors().textPrimary)
                Text(ProgressStore.isMedalOn(m.id) ? '已点亮' : m.summary)
                  .fontSize(13)
                  .fontColor(Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(12)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(16)
          }, (m: MedalItem) => m.id)
        }
        .padding({ left: 16, right: 16, bottom: 40 })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}

@Component
struct GuideOverlay {
  @State items: GuideItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.items = await JigsawBizService.loadGuides()
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(16)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => { JigsawNav.setRoute(JigsawNav.NONE) })
        Text('玩法说明')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .margin({ left: 12 })
      }
      .width('100%')
      .padding(16)
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.items, (g: GuideItem) => {
            Column({ space: 6 }) {
              Text(g.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(g.body)
                .fontSize(14)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
                .lineHeight(22)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(16)
          }, (g: GuideItem) => g.id)
        }
        .padding({ left: 16, right: 16, bottom: 40 })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
