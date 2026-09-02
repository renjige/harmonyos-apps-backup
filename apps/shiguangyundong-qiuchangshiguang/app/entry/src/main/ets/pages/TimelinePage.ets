import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CourtBizService } from '../services/CourtBizService'
import { CourtDetailNav } from '../services/CourtDetailNav'
import { AuthService } from '../services/AuthService'
import { FanMemoryStore } from '../services/FanMemoryStore'
import { FanHubGrid } from '../components/court/FanHubGrid'
import { FanInsightCard } from '../components/court/FanInsightCard'
import { FanRecentFeed } from '../components/court/FanRecentFeed'
import { FanScenarioStrip } from '../components/court/FanScenarioStrip'
import { FanMemoryOverview } from '../components/court/FanMemoryOverview'
import { AppButton } from '../components/design-system/AppButton'
import { BookingItem } from '../models/CourtModels'

@Component
export struct TimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('fanEpoch') fanEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State pendingCount: number = 0
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async reload(): Promise<void> {
    this.loading = true
    await FanMemoryStore.ensureChallenges()
    await FanMemoryStore.touchStreak()
    let pending = 0
    if (this.isLoggedIn()) {
      const bookings: BookingItem[] = await CourtBizService.loadBookings(AuthService.currentUsername())
      for (let i = 0; i < bookings.length; i++) {
        if (bookings[i].status === 'pending') {
          pending++
        }
      }
    }
    this.pendingCount = pending
    this.loading = false
  }

  build() {
    Column() {
      AppHeader({ title: '拾光', subtitle: '12 项球迷能力 · 场景创作 · 成长报告' })

      if (this.loading) {
        Text('加载中…')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .padding(Theme.space.pageX)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            FanScenarioStrip()

            AppButton({
              label: '赛后全套复盘向导',
              onTap: (): void => {
                CourtDetailNav.openFanWizard()
              }
            })

            FanMemoryOverview({ refreshToken: this.refreshToken + this.fanEpoch })

            FanInsightCard({ refreshToken: this.refreshToken + this.fanEpoch })

            FanHubGrid({ refreshToken: this.refreshToken + this.fanEpoch })

            FanRecentFeed({ refreshToken: this.refreshToken + this.fanEpoch })

            Row({ space: Theme.space.s3 }) {
              Column({ space: 4 }) {
                Text('场地预约')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                Text(this.isLoggedIn()
                  ? (this.pendingCount > 0 ? `${this.pendingCount} 条待到场打卡` : '查看凭证、打卡或取消')
                  : '登录后可预约场馆并打卡')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onClick(() => {
              if (!this.isLoggedIn()) {
                this.onRequireAuth()
                return
              }
              CourtDetailNav.openBookings()
            })

            if (!this.isLoggedIn()) {
              AppEmpty({
                title: '笔记可先写，约场需登录',
                description: '观赛记录、日志、收藏册不申请任何系统权限',
                actionLabel: '去登录',
                onAction: (): void => {
                  this.onRequireAuth()
                }
              })
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
