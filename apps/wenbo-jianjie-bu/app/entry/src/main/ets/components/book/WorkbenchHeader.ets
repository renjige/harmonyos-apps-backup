import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppRingChart } from '../design-system/AppChart'
import { ActivityItem, ThinkingPlanWeek, WorkbenchStats } from '../../models/GrowthModels'
import { AchievementService } from '../../services/AchievementService'

@Component
export struct WorkbenchHeader {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop statStamp: number = 0
  @Prop total: number = 0
  @Prop pendingJudge: number = 0
  @Prop starCount: number = 0
  @Prop weekWrite: number = 0
  @Prop streak: number = 0
  @Prop planDone: number = 0
  @Prop planTotal: number = 3
  @Prop todayWritten: boolean = false
  @Prop checkedIn: boolean = false
  @Prop plan: ThinkingPlanWeek = new ThinkingPlanWeek()
  @Prop activities: ActivityItem[] = []
  onCreate: () => void = () => {}
  onOpenTool: (kind: string) => void = (_k: string) => {}
  onOpenFavorites: () => void = () => {}
  onOpenReview: () => void = () => {}
  onOpenActivity: () => void = () => {}
  onOpenFilter: () => void = () => {}
  onTogglePlan: (index: number) => void = (_i: number) => {}
  onCheckIn: () => void = () => {}

  private planDoneCount(): number {
    let c = 0
    if (this.plan.done1) {
      c++
    }
    if (this.plan.done2) {
      c++
    }
    if (this.plan.done3) {
      c++
    }
    return c
  }

  private planPercent(): number {
    if (this.planTotal <= 0) {
      return 0
    }
    return this.planDoneCount() / this.planTotal
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Image($r('app.media.app_icon'))
          .width(36)
          .height(36)
          .borderRadius(10)
        Column({ space: 2 }) {
          Text('见解簿')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text('思考工作台 · 写判断 · 验收 · 成长')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 10 })
        Row() {
          AppIcon({ name: 'search', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onOpenFilter() })
      }
      .width('100%')
      .padding({ top: Theme.space.s4 })

      Row({ space: Theme.space.s4 }) {
        Column({ space: 6 }) {
          AppRingChart({
            title: '',
            percent: this.planPercent()
          })
          Text(`本周计划 ${this.planDoneCount()}/${this.planTotal}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .width(130)
        Column({ space: 8 }) {
          Text(this.todayWritten ? '今日已写 ✓' : '今日尚未落笔')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(`连续 ${this.streak} 天 · 待验收 ${this.pendingJudge} 条`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text(this.checkedIn ? '已打卡' : '点我完成今日打卡')
            .fontSize(Theme.type.caption)
            .fontColor(this.checkedIn ? Theme.colors().brandPrimary : Theme.colors().brandDeep)
            .width('100%')
            .onClick((): void => { this.onCheckIn() })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding(12)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)

      Row({ space: Theme.space.s2 }) {
        Column({ space: 2 }) {
          Text(`${this.total}`)
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
          Text('总见解')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .padding({ top: 8, bottom: 8 })
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 2 }) {
          Text(`${this.pendingJudge}`)
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
          Text('待验收')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .padding({ top: 8, bottom: 8 })
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 2 }) {
          Text(`${this.starCount}`)
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
          Text('星标')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .padding({ top: 8, bottom: 8 })
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
        .alignItems(HorizontalAlign.Center)

        Column({ space: 2 }) {
          Text(`${this.weekWrite}`)
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
          Text('本周写')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .padding({ top: 8, bottom: 8 })
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')

      Scroll() {
        Row({ space: 8 }) {
          this.QuickBtn('写见解', 'add', (): void => { this.onCreate() })
          this.QuickBtn('今日一问', 'sparkle', (): void => { this.onOpenTool('prompt') })
          this.QuickBtn('随机回看', 'refresh', (): void => { this.onOpenTool('recall') })
          this.QuickBtn('收藏', 'bookmark', (): void => { this.onOpenFavorites() })
          this.QuickBtn('回顾', 'calendar', (): void => { this.onOpenReview() })
        }
        .padding({ right: 4 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
      .width('100%')

      Column({ space: 6 }) {
        Text('本周思考计划')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        this.PlanRow(0, this.plan.goal1, this.plan.done1)
        this.PlanRow(1, this.plan.goal2, this.plan.done2)
        this.PlanRow(2, this.plan.goal3, this.plan.done3)
      }
      .width('100%')
      .padding(12)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)

      if (this.activities.length > 0) {
        Column({ space: 8 }) {
          Row() {
            Text('最近动态')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('查看全部')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.onOpenActivity() })
          }
          .width('100%')
          ForEach(this.activities, (a: ActivityItem) => {
            Row({ space: 8 }) {
              Text(AchievementService.labelForKind(a.kind))
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .width(56)
              Text(a.title)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
            }
            .width('100%')
          }, (a: ActivityItem) => a.id)
        }
        .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  QuickBtn(label: string, icon: 'add' | 'sparkle' | 'refresh' | 'bookmark' | 'calendar', action: () => void) {
    Column({ space: 4 }) {
      AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textPrimary)
    }
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick((): void => { action() })
  }

  @Builder
  PlanRow(index: number, label: string, done: boolean) {
    Row({ space: 8 }) {
      AppIcon({
        name: done ? 'check' : 'empty',
        iconSize: Theme.icon.md,
        color: done ? Theme.colors().brandPrimary : Theme.colors().textSecondary
      })
      Text(label)
        .fontSize(Theme.type.bodyS)
        .fontColor(done ? Theme.colors().textSecondary : Theme.colors().textPrimary)
        .decoration({ type: done ? TextDecorationType.LineThrough : TextDecorationType.None })
        .layoutWeight(1)
    }
    .width('100%')
    .onClick((): void => { this.onTogglePlan(index) })
  }
}
