import { Theme } from '../components/design-system/Theme'
import { AppCard } from '../components/design-system/AppCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppButton } from '../components/design-system/AppButton'
import { WorkRecommendCarousel } from '../components/handcraft/WorkRecommendCarousel'
import { HandcraftWork } from '../models/HandcraftModels'
import { HandcraftBizService } from '../services/HandcraftBizService'
import { CraftLocalStore } from '../services/CraftLocalStore'
import { CraftDetailNav } from '../services/CraftDetailNav'
import { CraftStatsService } from '../services/CraftStatsService'
import { CraftDashboardStats } from '../models/CraftLocalModels'
import { CraftTimelineEvent } from '../models/CraftLocalModels'
import { CraftPlan } from '../models/CraftLocalModels'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('craftDataEpoch') @Watch('onDataChange') craftDataEpoch: number = 0
  onOpenMessages: () => void = () => {}
  onOpenClassroom: () => void = () => {}
  onOpenCreate: () => void = () => {}
  onOpenGrowth: () => void = () => {}
  onOpenCreateAssistant: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State works: HandcraftWork[] = []
  @State guides: HandcraftWork[] = []
  @State stats: CraftDashboardStats = new CraftDashboardStats()
  @State timeline: CraftTimelineEvent[] = []
  @State activePlan: CraftPlan | undefined = undefined
  @State lastGuideTitle: string = ''
  @State lastGuideId: string = ''
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  onDataChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.works = await HandcraftBizService.loadWorks()
    this.guides = await HandcraftBizService.loadGuides()
    this.stats = await CraftStatsService.loadDashboard(this.currentUsername)
    this.timeline = await CraftStatsService.timeline(this.currentUsername, 3)
    this.activePlan = CraftStatsService.activePlan()
    const g = CraftLocalStore.lastGuide()
    this.lastGuideId = g.guideId
    this.lastGuideTitle = g.title
    this.loading = false
  }

  private planPercent(): number {
    if (this.stats.planTotal <= 0) {
      return 0
    }
    return Math.floor(this.stats.planDone * 100 / this.stats.planTotal)
  }

  private greeting(): string {
    const h = new Date().getHours()
    if (h < 12) {
      return '上午好'
    }
    if (h < 18) {
      return '下午好'
    }
    return '晚上好'
  }

  private openLastGuide(): void {
    if (this.lastGuideId.length > 0) {
      CraftDetailNav.openGuide(this.lastGuideId)
      return
    }
    if (this.guides.length > 0) {
      void CraftLocalStore.setLastGuide(this.guides[0].id, this.guides[0].title)
      CraftDetailNav.openGuide(this.guides[0].id)
      return
    }
    this.onOpenClassroom()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        if (this.loading) {
          AppLoading({ label: '加载工作台…' })
        } else {
          this.HeroSection()
          this.StatsRow()
          this.QuickActions()
          this.ContinueSection()
          this.TimelineSection()
          this.GuideCarousel()
          AppCard({
            title: '机构通知',
            variant: 'outlined',
            onTap: (): void => this.onOpenMessages()
          }) {
            Row({ space: Theme.space.s2 }) {
              AppIcon({ name: 'message', iconSize: Theme.icon.md, color: Theme.colors().brandDeep })
              Text('创作提醒与教程更新')
                .fontSize(Theme.type.callout)
                .fontColor(Theme.colors().textSecondary)
            }.width('100%')
          }
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  HeroSection() {
    Column({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.hero_bg'))
          .width('100%')
          .height(168)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.xl)
        Column()
          .width('100%')
          .height(168)
          .linearGradient({
            angle: 180,
            colors: [['rgba(61,58,54,0.08)', 0], ['rgba(61,58,54,0.78)', 1]]
          })
          .borderRadius(Theme.radius.xl)
        Column({ space: 4 }) {
          Text(`手作心笺 · ${this.greeting()}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnInverse)
          Text(this.currentUsername.length > 0 ? this.currentUsername : '游客 · 可浏览官方课堂')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textOnInverse)
        }
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      AppCard({ title: '本周创作进度', variant: 'glass' }) {
        Column({ space: Theme.space.s2 }) {
          Row() {
            Text(`${this.planPercent()}%`)
              .fontSize(Theme.type.display)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandDeep)
            Blank()
            Text(`${this.stats.planDone}/${this.stats.planTotal} 步`)
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textSecondary)
          }.width('100%')
          Progress({ value: this.planPercent(), total: 100, type: ProgressType.Linear })
            .width('100%')
            .color(Theme.colors().brandDeep)
            .backgroundColor(Theme.colors().surfaceSubtle)
          Text(this.stats.todayCheckedIn ? '今日已打卡' : '今日尚未打卡 · 去成长页打卡')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }.width('100%')
      }
    }.width('100%')
  }

  @Builder
  StatsRow() {
    Row({ space: Theme.space.s2 }) {
      Column() {
        AppStatCard({
          label: '作品',
          value: `${this.stats.workCount}`
        })
      }.layoutWeight(1)
      Column() {
        AppStatCard({
          label: '灵感',
          value: `${this.stats.inspirationCount}`
        })
      }.layoutWeight(1)
    }.width('100%')
    Row({ space: Theme.space.s2 }) {
      Column() {
        AppStatCard({
          label: '收藏',
          value: `${this.stats.favoriteCount}`
        })
      }.layoutWeight(1)
      Column() {
        AppStatCard({
          label: '连续',
          value: `${this.stats.streakDays}天`
        })
      }.layoutWeight(1)
    }.width('100%')
  }

  @Builder
  QuickActions() {
    Column({ space: Theme.space.s2 }) {
      Text('快捷操作')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppButton({
            label: '记录作品',
            variant: 'primary',
            onTap: (): void => {
              if (this.currentUsername.length === 0) {
                this.onRequireAuth()
              } else {
                this.onOpenCreate()
              }
            }
          })
        }.layoutWeight(1)
        Column() {
          AppButton({
            label: '创作计划',
            variant: 'secondary',
            onTap: (): void => { this.onOpenGrowth() }
          })
        }.layoutWeight(1)
      }.width('100%')
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppButton({
            label: '浏览课堂',
            variant: 'secondary',
            onTap: (): void => { this.onOpenClassroom() }
          })
        }.layoutWeight(1)
        Column() {
          AppButton({
            label: '制作助手',
            variant: 'secondary',
            onTap: (): void => { this.onOpenCreateAssistant() }
          })
        }.layoutWeight(1)
      }.width('100%')
    }.width('100%')
  }

  @Builder
  ContinueSection() {
    AppCard({
      title: this.lastGuideTitle.length > 0 ? '继续跟做' : '开始跟做教程',
      variant: 'outlined',
      onTap: (): void => { this.openLastGuide() }
    }) {
      Column({ space: 6 }) {
        Text(this.lastGuideTitle.length > 0 ? this.lastGuideTitle : '进入课堂选择教程，跟做步骤更清晰')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        if (this.activePlan !== undefined) {
          Text(`进行中：${this.activePlan.title}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandDeep)
            .width('100%')
        }
      }.width('100%').alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  TimelineSection() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('最近动态')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('成长页查看全部')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandDeep)
          .onClick((): void => { this.onOpenGrowth() })
      }.width('100%')
      if (this.timeline.length === 0) {
        AppEmpty({
          title: '暂无动态',
          description: '记录作品或打卡后会出现在这里',
          actionLabel: '去创作',
          onAction: (): void => { this.onOpenCreate() }
        })
      } else {
        ForEach(this.timeline, (ev: CraftTimelineEvent) => {
          Row({ space: Theme.space.s3 }) {
            Text(ev.at.slice(5))
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width(48)
            Column({ space: 2 }) {
              Text(ev.title)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              Text(ev.kind)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }.alignItems(HorizontalAlign.Start).layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }, (ev: CraftTimelineEvent) => ev.id)
      }
    }.width('100%')
  }

  @Builder
  GuideCarousel() {
    Column({ space: Theme.space.s3 }) {
      Text('推荐课堂')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      if (this.works.length === 0) {
        AppEmpty({ title: '暂无推荐', description: '请检查网络后下拉刷新' })
      } else {
        WorkRecommendCarousel({
          works: this.works.slice(0, 6),
          onTapWork: (workId: string): void => { CraftDetailNav.openWork(workId) }
        })
        Image($r('app.media.cover_work_3'))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
          .margin({ top: Theme.space.s2 })
      }
    }.width('100%')
  }
}
