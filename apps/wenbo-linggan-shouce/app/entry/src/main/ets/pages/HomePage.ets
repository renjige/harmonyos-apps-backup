import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppCard } from '../components/design-system/AppCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { InspirationListCard } from '../components/inspiration/InspirationListCard'
import { InspirationItem, StatsData, TimelineEvent } from '../models/InspirationModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { InspirationMedia } from '../services/InspirationMedia'
import { AuthService } from '../services/AuthService'
import { AchievementService } from '../services/AchievementService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '灵感手册'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onCaptureInspiration: () => void = () => {}
  onOpenGrowth: () => void = () => {}
  onOpenTimeline: () => void = () => {}
  onOpenOrganize: () => void = () => {}
  onSwitchTab: (index: number) => void = () => {}
  @State featured: InspirationItem[] = []
  @State recentInspirations: InspirationItem[] = []
  @State activePlans: InspirationItem[] = []
  @State timelinePreview: TimelineEvent[] = []
  @State stats: StatsData = new StatsData()
  @State streak: number = 0
  @State todayDone: boolean = false
  @State checkingIn: boolean = false
  @State toastText: string = ''
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('checkInEpoch') checkInEpoch: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private greeting(): string {
    const hour = new Date().getHours()
    if (hour < 11) {
      return '早安，开启今日创作'
    }
    if (hour < 17) {
      return '午安，推进你的创意计划'
    }
    return '晚安，回顾今日灵感'
  }

  private todayLabel(): string {
    const d = new Date()
    const month = d.getMonth() + 1
    const day = d.getDate()
    const weekdays: string[] = ['日', '一', '二', '三', '四', '五', '六']
    return `${month}月${day}日 · 星期${weekdays[d.getDay()]}`
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.featured = await InspirationBizService.loadFeatured()
    if (AuthService.isLoggedIn()) {
      this.recentInspirations = await InspirationBizService.loadInspirations(this.currentUsername)
      this.stats = await InspirationBizService.loadStats(this.currentUsername)
      const plans = await InspirationBizService.loadCreativePlans(this.currentUsername)
      const active: InspirationItem[] = []
      for (const p of plans) {
        if (p.progress < 100) {
          active.push(p)
        }
      }
      this.activePlans = active.slice(0, 3)
      this.timelinePreview = await InspirationBizService.loadTimeline(this.currentUsername, 5)
      const checkIns = await InspirationBizService.loadCheckIns(this.currentUsername)
      this.streak = AchievementService.computeStreak(InspirationBizService.checkInDates(checkIns))
      this.todayDone = InspirationBizService.todayCheckedIn(checkIns)
    } else {
      this.recentInspirations = []
      this.activePlans = []
      this.timelinePreview = []
      this.stats = new StatsData()
      this.streak = 0
      this.todayDone = false
    }
    this.loading = false
  }

  private async handleCheckIn(): Promise<void> {
    if (!AuthService.requireAuth('sync_records')) {
      return
    }
    if (this.todayDone) {
      this.showToast('今日已打卡')
      return
    }
    this.checkingIn = true
    const ok = await InspirationBizService.checkInToday('工作台打卡')
    this.checkingIn = false
    if (ok) {
      this.showToast(`打卡成功 · 连续 ${this.streak + 1} 天`)
      await this.reload()
    } else {
      this.showToast('打卡失败，请稍后重试')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Row({ space: Theme.space.s3 }) {
            Image($r('app.media.logo'))
              .width(48)
              .height(48)
              .borderRadius(12)
              .objectFit(ImageFit.Cover)
            Column({ space: 6 }) {
              Text(this.greeting())
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(this.todayLabel())
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')

          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_latest_inspiration'))
              .width('100%')
              .height(168)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(168)
              .linearGradient({
                angle: 180,
                colors: [['rgba(27,42,65,0.05)', 0], ['rgba(27,42,65,0.82)', 1]]
              })
              .borderRadius(Theme.radius.xl)
            Column({ space: Theme.space.s3 }) {
              Text(AuthService.isLoggedIn() ? `连续创作 ${this.streak} 天` : '登录后开启创作工作台')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandAccent)
              Text(AuthService.isLoggedIn()
                ? `灵感 ${this.stats.inspirationCount} · 画板 ${this.stats.boardCount} · 计划 ${this.stats.planCount}`
                : '记录灵感、整理画板、推进计划')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textOnInverse)
                .width('100%')
              Row({ space: Theme.space.s3 }) {
                AppButton({
                  label: this.checkingIn ? '打卡中…' : (this.todayDone ? '今日已打卡' : '今日打卡'),
                  disabled: this.checkingIn || this.todayDone || !AuthService.isLoggedIn(),
                  onTap: (): void => { void this.handleCheckIn() }
                }).layoutWeight(1)
                AppButton({
                  label: '成长中心',
                  variant: 'secondary',
                  onTap: (): void => { this.onOpenGrowth() }
                }).layoutWeight(1)
              }
              .width('100%')
            }
            .padding(Theme.space.s5)
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            this.QuickAction('记录', 'book', (): void => { this.onCaptureInspiration() })
            this.QuickAction('画板', 'photo', (): void => { this.onSwitchTab(2) })
            this.QuickAction('计划', 'calendar', (): void => { this.onSwitchTab(3) })
            this.QuickAction('搜索', 'search', (): void => { this.onOpenOrganize() })
          }
          .width('100%')

          if (AuthService.isLoggedIn() && this.activePlans.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Row() {
                Text('进行中的计划')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text('全部')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => { this.onSwitchTab(3) })
              }
              .width('100%')
              ForEach(this.activePlans, (plan: InspirationItem) => {
                Column({ space: 8 }) {
                  Row() {
                    Text(plan.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.colors().textPrimary)
                      .layoutWeight(1)
                      .maxLines(1)
                    Text(`${plan.progress}%`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandAccent)
                  }
                  .width('100%')
                  Stack({ alignContent: Alignment.Start }) {
                    Row()
                      .width('100%')
                      .height(6)
                      .backgroundColor(Theme.colors().surfaceSubtle)
                      .borderRadius(Theme.radius.pill)
                    Row()
                      .width(`${plan.progress}%`)
                      .height(6)
                      .backgroundColor(Theme.colors().success)
                      .borderRadius(Theme.radius.pill)
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .onClick((): void => { InspirationDetailNav.openPlan(plan.id) })
              }, (plan: InspirationItem) => plan.id)
            }
            .width('100%')
          }

          if (AuthService.isLoggedIn()) {
            Column({ space: Theme.space.s3 }) {
              Row() {
                Text('最近动态')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text('时间轴')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => { this.onOpenTimeline() })
              }
              .width('100%')
              if (this.timelinePreview.length === 0) {
                AppEmpty({
                  title: '还没有创作动态',
                  description: '记录灵感或更新计划后，这里会出现你的轨迹'
                })
              } else {
                ForEach(this.timelinePreview, (ev: TimelineEvent) => {
                  Row({ space: Theme.space.s3 }) {
                    Text(ev.date.slice(5))
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textTertiary)
                      .width(48)
                    Column({ space: 4 }) {
                      Text(ev.title)
                        .fontSize(Theme.type.callout)
                        .fontColor(Theme.colors().textPrimary)
                        .width('100%')
                        .maxLines(1)
                      Text(ev.summary)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().textSecondary)
                        .width('100%')
                        .maxLines(1)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .onClick((): void => {
                    if (ev.kind === 'inspiration') {
                      InspirationDetailNav.openInspiration(ev.entityId)
                    } else if (ev.kind === 'board') {
                      InspirationDetailNav.openBoard(ev.entityId)
                    } else if (ev.kind === 'plan') {
                      InspirationDetailNav.openPlan(ev.entityId)
                    }
                  })
                }, (ev: TimelineEvent) => `${ev.kind}_${ev.entityId}_${ev.date}`)
              }
            }
            .width('100%')
          }

          if (this.loading) {
            AppLoading({ variant: 'skeleton' })
          } else {
            Column({ space: Theme.space.s3 }) {
              Text('推荐灵感')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              if (this.featured.length === 0) {
                AppEmpty({ title: '暂无推荐', description: '稍后再来看看新的创意灵感' })
              } else {
                Scroll() {
                  Row({ space: Theme.space.s3 }) {
                    ForEach(this.featured, (item: InspirationItem) => {
                      Column({ space: 8 }) {
                        Image(InspirationMedia.coverMedia(item.coverKey))
                          .width(140)
                          .height(100)
                          .borderRadius(Theme.radius.lg)
                          .objectFit(ImageFit.Cover)
                        Text(item.title)
                          .fontSize(Theme.type.caption)
                          .fontColor(Theme.colors().textPrimary)
                          .maxLines(2)
                          .width(140)
                      }
                      .onClick((): void => { InspirationDetailNav.openFeatured(item.id) })
                    }, (item: InspirationItem) => item.id)
                  }
                  .padding({ right: Theme.space.pageX })
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
              }
            }
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              Text('我的灵感')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              if (this.recentInspirations.length === 0) {
                AppEmpty({
                  title: '还没有灵感记录',
                  description: AuthService.isLoggedIn()
                    ? '点击上方快捷入口开始捕捉'
                    : '登录后可记录并同步你的灵感',
                  actionLabel: AuthService.isLoggedIn() ? '记录灵感' : '',
                  onAction: (): void => { this.onCaptureInspiration() }
                })
              } else {
                ForEach(this.recentInspirations.slice(0, 5), (item: InspirationItem) => {
                  InspirationListCard({
                    item: item,
                    compact: true,
                    onTap: (): void => { InspirationDetailNav.openInspiration(item.id) }
                  })
                }, (item: InspirationItem) => item.id)
              }
            }
            .width('100%')
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

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
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  QuickAction(label: string, icon: 'book' | 'photo' | 'calendar' | 'search', onTap: () => void) {
    Column({ space: 6 }) {
      Column() {
        AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.lg)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .onClick(onTap)
  }
}
