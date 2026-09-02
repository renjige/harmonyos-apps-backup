import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { CaptureListCard } from '../components/capture/CaptureListCard'
import { TodayProgressCard } from '../components/workbench/TodayProgressCard'
import { StatQuadRow } from '../components/workbench/StatQuadRow'
import { QuickActionGrid } from '../components/workbench/QuickActionGrid'
import { ScenarioGuideCard } from '../components/workbench/ScenarioGuideCard'
import { RecentFeed } from '../components/workbench/RecentFeed'
import { CaptureItem, CaptureStats, LearnPlan, TodayProgress, TimelineEvent } from '../models/ZhiweiModels'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '知微集'
  @Prop tagline: string = ''
  @Prop @Watch('onRev') refreshToken: number = 0
  @State stats: CaptureStats = new CaptureStats()
  @State progress: TodayProgress = new TodayProgress()
  @State events: TimelineEvent[] = []
  @State pending: CaptureItem[] = []
  @State plan: LearnPlan | null = null
  @State planDone: number = 0
  @State dateLabel: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.dateLabel = ZhiweiStore.displayDate(ZhiweiStore.today())
    this.stats = ZhiweiStore.stats()
    this.progress = ZhiweiStore.todayProgress()
    this.events = ZhiweiStore.timelineEvents(3)
    this.pending = ZhiweiStore.pendingInbox(2)
    this.plan = ZhiweiStore.activePlan()
    if (this.plan !== null) {
      this.planDone = ZhiweiStore.planProgress(this.plan)
    } else {
      this.planDone = 0
    }
  }

  private summaryOf(item: CaptureItem): string {
    if (item.body.length <= 40) {
      return item.body
    }
    return `${item.body.substring(0, 40)}…`
  }

  build() {
    Column() {
      Row() {
        Column({ space: 2 }) {
          Text(this.appName)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .width('100%')
          Text(`${this.dateLabel} · ${ZhiweiStore.greeting()}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2, bottom: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack() {
            Image($r('app.media.hero_desk'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(140)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,26,46,0.08)', 0], ['rgba(26,26,46,0.75)', 1]]
              })
            Column({ space: 4 }) {
              Text('个人微知识工作台')
                .fontSize(Theme.type.caption)
                .fontColor('#F5F7FA')
                .width('100%')
              Text(this.tagline)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F5F7FA')
                .width('100%')
            }
            .width('100%')
            .padding({ left: 14, right: 14, bottom: 12 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .height(140)
          .borderRadius(Theme.radius.md)
          .clip(true)

          TodayProgressCard({ progress: this.progress })

          Column({ space: 6 }) {
            Text('推荐：从学习路径开始')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .width('100%')
            Text('三条引导路径（入门 / 职场 / 生活），逐步体验阅读、打卡、复习与整理，无需先记笔记。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            Text('进入学习路径 →')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colorOf(this.themeEpoch).brandPrimaryContainer)
          .borderRadius(Theme.radius.card)
          .onClick(() => ZhiweiNav.openLearningPath())

          ScenarioGuideCard()
          StatQuadRow({ stats: this.stats })
          QuickActionGrid()

          Row({ space: 10 }) {
            Image($r('app.media.banner_insight'))
              .width(72)
              .height(72)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.sm)
            Column({ space: 4 }) {
              Text('成长捷径')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                .width('100%')
              Text('周度洞察、本周回顾与成就墙，在「成长」Tab 一键进入')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.card)
          .onClick(() => {
            AppStorage.setOrCreate('zwTabJump', 1)
          })

          if (this.plan !== null) {
            Column({ space: 6 }) {
              Text(this.plan.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                .width('100%')
              Text(`进度 ${this.planDone} / ${this.plan.targetCount}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                .width('100%')
              Progress({
                value: this.planDone,
                total: this.plan.targetCount > 0 ? this.plan.targetCount : 1,
                type: ProgressType.Linear
              })
                .width('100%')
                .color(Theme.colorOf(this.themeEpoch).brandPrimary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.card)
            .onClick(() => ZhiweiNav.openPlan())
          }

          RecentFeed({ events: this.events })

          if (this.pending.length > 0) {
            Row() {
              Text('待跟进')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              Blank()
              Text('打开处理台')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colorOf(this.themeEpoch).brandPrimary)
                .onClick(() => ZhiweiNav.openInbox())
            }
            .width('100%')
            ForEach(this.pending, (item: CaptureItem) => {
              CaptureListCard({
                itemId: item.id,
                title: item.title,
                summary: this.summaryOf(item),
                category: item.category,
                priority: item.priority,
                status: item.status,
                timeLabel: ZhiweiStore.displayTime(item.updatedAt),
                onTap: (): void => ZhiweiNav.openCapture(item.id)
              })
            }, (item: CaptureItem) => `p_${item.id}`)
          }

          AppButton({
            label: '查看全部微知识',
            variant: 'secondary',
            onTap: (): void => ZhiweiNav.openAllCaptures()
          })
          Blank().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
    .id(`home_${this.themeEpoch}`)
  }
}
