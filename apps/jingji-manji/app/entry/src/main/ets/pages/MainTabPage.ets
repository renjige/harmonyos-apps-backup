import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { HomePage } from './HomePage'
import { RecordPage } from './RecordPage'
import { PlanPage } from './PlanPage'
import { GrowthPage } from './AnalyticsPage'
import { FavoritesPage } from './FavoritesPage'
import { CalendarPage } from './CalendarPage'
import { MinePage } from './MinePage'
import { MonthlyReportPage } from './MonthlyReportPage'
import { ReviewQuizPage } from './ReviewQuizPage'
import { SportRecordDetailPane } from '../components/detail/SportRecordDetailPane'
import { ChallengeDetailPane } from '../components/detail/ChallengeDetailPane'
import { PlanDetailPane } from '../components/detail/PlanDetailPane'
import { SportDetailNav } from '../services/SportDetailNav'
import { AuthService } from '../services/AuthService'
import { SportStore } from '../services/SportStore'

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
    t1.name = 'add'
    t1.label = '训练'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'biz'
    t2.label = '计划'
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

@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @State dataRefresh: number = 0
  @StorageLink('sportDataEpoch') sportDataEpoch: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('sportDetailId') @Watch('onSportDetailIdChange') sportDetailId: string = ''
  @StorageLink('challengeDetailId') challengeDetailId: string = ''
  @StorageLink('showCalendar') showCalendar: boolean = false
  @StorageLink('showDiagnose') showDiagnose: boolean = false
  @StorageLink('planDetailId') planDetailId: string = ''
  @StorageLink('showFavorites') showFavorites: boolean = false
  @StorageLink('showMonthlyReport') showMonthlyReport: boolean = false
  @Prop company: string = '漫记竞技'
  @Prop appName: string = '竞技漫记'
  @Prop tagline: string = ''
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  private bumpRefresh(): void {
    this.dataRefresh += 1
  }

  private onSportDetailIdChange(): void {
    if (this.sportDetailId.length === 0) {
      this.bumpRefresh()
      SportStore.notifyDataChanged()
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        if (this.current === 0) {
          HomePage({
            appName: this.appName,
            refreshToken: this.dataRefresh,
            sportEpoch: this.sportDataEpoch,
            onSwitchTab: (idx: number): void => {
              this.current = idx
            }
          }).layoutWeight(1)
        } else if (this.current === 1) {
          RecordPage({
            refreshToken: this.dataRefresh,
            sportEpoch: this.sportDataEpoch,
            onRequireAuth: (): void => {
              this.onRequireAuth()
            },
            onDataChanged: (): void => {
              this.bumpRefresh()
            }
          }).layoutWeight(1)
        } else if (this.current === 2) {
          PlanPage({
            refreshToken: this.dataRefresh,
            onRequireAuth: (): void => {
              this.onRequireAuth()
            },
            onDataChanged: (): void => {
              this.bumpRefresh()
            }
          }).layoutWeight(1)
        } else if (this.current === 3) {
          GrowthPage({
            refreshToken: this.dataRefresh
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            refreshToken: this.dataRefresh,
            onOpenLogin: (): void => {
              this.onOpenLogin()
            },
            onLogout: (): void => {
              AuthService.logout()
              this.onLogout()
            },
            onDataChanged: (): void => {
              this.bumpRefresh()
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
        .margin({ left: 16, right: 16, bottom: 12 })
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
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

      if (this.sportDetailId.length > 0) {
        SportRecordDetailPane({
          recordId: this.sportDetailId,
          refreshToken: this.dataRefresh,
          onChanged: (): void => {
            this.bumpRefresh()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.challengeDetailId.length > 0) {
        ChallengeDetailPane({
          challengeId: this.challengeDetailId,
          refreshToken: this.dataRefresh,
          onChanged: (): void => {
            this.bumpRefresh()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.planDetailId.length > 0) {
        PlanDetailPane({
          planId: this.planDetailId,
          refreshToken: this.dataRefresh,
          onChanged: (): void => {
            this.bumpRefresh()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(50)
      }

      if (this.showFavorites) {
        FavoritesPage({ refreshToken: this.dataRefresh })
          .width('100%')
          .height('100%')
          .zIndex(48)
      }

      if (this.showCalendar) {
        Column() {
          Row() {
            AppButton({
              label: '关闭日历',
              variant: 'secondary',
              onTap: (): void => {
                SportDetailNav.close()
              }
            })
          }
          .padding({ left: 16, right: 16, top: 12 })
          CalendarPage({
            refreshToken: this.dataRefresh,
            onAddRecord: (dateKey: string): void => {
              SportDetailNav.queueRecordForDate(dateKey)
              SportDetailNav.close()
              this.current = 1
            }
          }).layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(40)
      }

      if (this.showMonthlyReport) {
        MonthlyReportPage({ refreshToken: this.dataRefresh })
          .width('100%')
          .height('100%')
          .zIndex(46)
      }

      if (this.showDiagnose) {
        ReviewQuizPage({
          onGoRecord: (): void => {
            const cat = AppStorage.get<string>('lastDiagnoseCategory') ?? ''
            SportDetailNav.queueRecordFromDiagnose(cat)
            SportDetailNav.close()
            this.current = 1
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(45)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FloatingTabItem(t: TabItem) {
    if (t.index === 1) {
      Column({ space: 2 }) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(52)
            .height(52)
            .borderRadius(26)
            .linearGradient({ angle: 135, colors: Theme.brandGradient() })
            .shadow({
              radius: 16,
              color: 'rgba(26,92,255,0.45)',
              offsetY: 6
            })
          AppIcon({
            name: t.name,
            iconSize: Theme.icon.xl,
            color: Theme.colors().brandOnPrimary
          })
        }
        .margin({ top: -18 })
        Text(t.label)
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
      }
      .layoutWeight(1)
      .padding({ top: 4, bottom: 6 })
      .onClick(() => {
        this.current = t.index
        SportDetailNav.close()
      })
    } else {
      Column({ space: 4 }) {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.lg,
          active: this.current === t.index
        })
        Text(t.label)
          .fontSize(Theme.type.caption)
          .fontColor(this.current === t.index ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
          .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Regular)
      }
      .layoutWeight(1)
      .padding({ top: 10, bottom: 8 })
      .backgroundColor(this.current === t.index ? Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.current = t.index
        SportDetailNav.close()
      })
    }
  }
}
