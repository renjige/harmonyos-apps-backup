import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { Journey, JourneyMilestone, JourneyProgress } from '../models/SaituModels'
import { JourneyPlan, CheckIn } from '../models/SaituGrowthModels'
import { SaituLocalStore } from '../services/SaituLocalStore'
import { SaituTrackStore } from '../services/SaituTrackStore'
import { SaituCheckInStore } from '../services/SaituCheckInStore'
import { SaituPlanStore } from '../services/SaituPlanStore'
import { SaituDetailNav } from '../services/SaituDetailNav'
import { CheckInCalendar } from '../components/growth/CheckInCalendar'

@Component
export struct JourneyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituJourneyEpoch') @Watch('onJourneyEpochChange') journeyEpoch: number = 0
  @StorageLink('saituTrackEpoch') @Watch('onTrackEpochChange') trackEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State journeys: Journey[] = []
  @State progress: JourneyProgress[] = []
  @State milestones: JourneyMilestone[] = []
  @State plans: JourneyPlan[] = []
  @State todayCheckIn: CheckIn | undefined = undefined
  @State checkStreak: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onJourneyEpochChange(): void {
    void this.reload()
  }

  onTrackEpochChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async reload(): Promise<void> {
    this.journeys = await SaituLocalStore.loadJourneys()
    this.progress = await SaituLocalStore.journeyProgress()
    this.milestones = await SaituTrackStore.loadMilestones()
    this.plans = await SaituPlanStore.loadPlans()
    this.todayCheckIn = await SaituCheckInStore.todayCheckIn()
    this.checkStreak = await SaituCheckInStore.checkInStreak()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('赛途推进')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('今日打卡')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(this.todayCheckIn !== undefined ? `已打卡 · 连续 ${this.checkStreak} 天` :
              `尚未打卡 · 连续 ${this.checkStreak} 天`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: this.todayCheckIn !== undefined ? '查看今日打卡' : '立即打卡',
              variant: 'primary',
              onTap: (): void => SaituDetailNav.openCheckInEditor('')
            })
            CheckInCalendar({
              refreshToken: this.refreshToken,
              onDayTap: (_key: string): void => SaituDetailNav.openCheckInEditor('')
            })
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row() {
            Text('我的旅途')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('管理')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => SaituDetailNav.openJourneyManage())
          }
          .width('100%')

          if (this.progress.length === 0) {
            AppEmpty({
              title: '还没有旅途',
              description: '创建旅途，把札记与节点组织成可推进的赛途'
            })
          } else {
            ForEach(this.progress, (p: JourneyProgress) => {
              Column({ space: Theme.space.s2 }) {
                Row({ space: Theme.space.s2 }) {
                  Column()
                    .width(8)
                    .height(28)
                    .backgroundColor(p.color)
                    .borderRadius(4)
                  Text(p.name)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Text(p.progressLabel)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .width('100%')
                Row() {
                  Row()
                    .width(`${Math.max(8, Math.round(p.ratio * 100))}%`)
                    .height(8)
                    .backgroundColor(p.color)
                    .borderRadius(4)
                }
                .width('100%')
                .height(8)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(4)
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => SaituDetailNav.openJourneyDetail(p.journeyId))
            }, (p: JourneyProgress) => p.rowKey())
          }

          Row() {
            Text('赛途计划')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('新建')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => SaituDetailNav.openNewPlan(''))
          }
          .width('100%')

          if (this.plans.length === 0) {
            Text('为旅途设定周期目标与任务清单，完成后进度同步更新。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.plans, (p: JourneyPlan) => {
              Column({ space: Theme.space.s2 }) {
                Row() {
                  Text(p.title.length > 0 ? p.title : '未命名计划')
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Blank()
                  Text(p.statusLabel())
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .width('100%')
                Text(p.progressLabel())
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => SaituDetailNav.openPlan(p.id))
            }, (p: JourneyPlan) => p.rowKey())
          }

          Row() {
            Text('赛途节点')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('添加')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => SaituDetailNav.openMilestoneEditor('', ''))
          }
          .width('100%')

          if (this.milestones.length === 0) {
            Text('节点是阶段目标，达成后看板进度才会前进。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.milestones, (m: JourneyMilestone) => {
              Row({ space: Theme.space.s3 }) {
                Column()
                  .width(12)
                  .height(12)
                  .borderRadius(6)
                  .backgroundColor(m.done ? Theme.colors().success : Theme.colors().brandPrimary)
                Column({ space: 4 }) {
                  Text(m.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(m.statusLabel())
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => SaituDetailNav.openMilestone(m.id))
            }, (m: JourneyMilestone) => m.rowKey())
          }

          Blank().height(this.bottomInset + Theme.space.s6)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)
      .edgeEffect(EdgeEffect.Spring)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
