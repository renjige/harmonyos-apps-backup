import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { AchievementItem, StatsData } from '../models/InspirationModels'
import { AchievementService } from '../services/AchievementService'
import { InspirationBizService } from '../services/InspirationBizService'
import { AuthService } from '../services/AuthService'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct GrowthCenterPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onOpenWeeklyReview: () => void = () => {}
  @State stats: StatsData = new StatsData()
  @State achievements: AchievementItem[] = []
  @State streak: number = 0
  @State todayDone: boolean = false
  @State loading: boolean = true
  @State checkingIn: boolean = false
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('checkInEpoch') checkInEpoch: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.stats = await InspirationBizService.loadStats(this.currentUsername)
      const checkIns = await InspirationBizService.loadCheckIns(this.currentUsername)
      this.streak = AchievementService.computeStreak(InspirationBizService.checkInDates(checkIns))
      this.todayDone = InspirationBizService.todayCheckedIn(checkIns)
      this.achievements = await AchievementService.evaluate(this.currentUsername)
    } else {
      this.stats = new StatsData()
      this.achievements = []
      this.streak = 0
      this.todayDone = false
    }
    this.loading = false
  }

  private async handleCheckIn(): Promise<void> {
    if (!AuthService.requireAuth('sync_records')) {
      this.onRequireAuth()
      return
    }
    if (this.todayDone) {
      this.showToast('今日已打卡')
      return
    }
    this.checkingIn = true
    const ok = await InspirationBizService.checkInToday('今日创作打卡')
    this.checkingIn = false
    if (ok) {
      this.showToast(`打卡成功 · 已连续 ${this.streak + 1} 天`)
      await this.reload()
    } else {
      this.showToast('打卡失败，请稍后重试')
    }
  }

  private async copyWeekReview(): Promise<void> {
    const text = AchievementService.weekSummary(this.stats, this.streak)
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    const sys = pasteboard.getSystemPasteboard()
    await sys.setData(data)
    this.showToast('周回顾摘要已复制')
  }

  private achievementIcon(name: string): AppIconName {
    if (name === 'book' || name === 'photo' || name === 'calendar' || name === 'heart') {
      return name
    }
    return 'ai'
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Text('成长中心')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.loading) {
          AppLoading({ label: '加载成长数据…' }).layoutWeight(1)
        } else if (!AuthService.isLoggedIn()) {
          AppEmpty({
            title: '登录后查看成长数据',
            description: '打卡、成就与周回顾需登录后使用',
            actionLabel: '去登录',
            onAction: (): void => { this.onRequireAuth() }
          }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              AppStatCard({
                label: '连续创作',
                value: `${this.streak}`,
                trend: '天',
                positive: this.streak > 0
              })
              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '灵感',
                  value: `${this.stats.inspirationCount}`,
                  trend: '条',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '画板',
                  value: `${this.stats.boardCount}`,
                  trend: '本',
                  positive: true
                }).layoutWeight(1)
              }
              .width('100%')

              AppButton({
                label: this.checkingIn ? '打卡中…' : (this.todayDone ? '今日已打卡 ✓' : '今日创作打卡'),
                disabled: this.checkingIn || this.todayDone,
                onTap: (): void => { void this.handleCheckIn() }
              })

              Text('成就徽章')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .width('100%')
              Grid() {
                ForEach(this.achievements, (a: AchievementItem) => {
                  GridItem() {
                    Column({ space: 6 }) {
                      AppIcon({
                        name: this.achievementIcon(a.iconName),
                        iconSize: Theme.icon.lg,
                        color: a.unlocked ? Theme.colors().brandPrimary : Theme.colors().textTertiary
                      })
                      Text(a.title)
                        .fontSize(Theme.type.caption)
                        .fontColor(a.unlocked ? Theme.colors().textPrimary : Theme.colors().textTertiary)
                        .maxLines(2)
                        .textAlign(TextAlign.Center)
                    }
                    .width('100%')
                    .padding(Theme.space.s3)
                    .backgroundColor(a.unlocked ?
                      Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.lg)
                  }
                }, (a: AchievementItem) => a.id)
              }
              .columnsTemplate('1fr 1fr')
              .columnsGap(Theme.space.s3)
              .rowsGap(Theme.space.s3)
              .width('100%')

              AppButton({
                label: '查看本周回顾',
                variant: 'secondary',
                onTap: (): void => { this.onOpenWeeklyReview() }
              })

              AppButton({
                label: '复制本周回顾摘要',
                variant: 'secondary',
                onTap: (): void => { void this.copyWeekReview() }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
