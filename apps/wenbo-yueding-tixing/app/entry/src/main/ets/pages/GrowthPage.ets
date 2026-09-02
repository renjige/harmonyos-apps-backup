import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ToolEntry } from '../components/appointment/WorkbenchCards'
import { SectionTitle } from '../components/appointment/AppointmentCards'
import {
  AchievementDef,
  AchievementState,
  ActivityLogItem,
  CheckInRecord
} from '../models/GrowthModels'
import { MonthInsights } from '../models/AppointmentModels'
import { GrowthService } from '../services/GrowthService'
import { AppointmentService } from '../services/AppointmentService'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State loading: boolean = true
  @State streakDays: number = 0
  @State achievementUnlocked: number = 0
  @State achievementTotal: number = 0
  @State insights: MonthInsights = new MonthInsights()
  @State logs: ActivityLogItem[] = []
  @State heatmap: CheckInRecord[] = []
  @State achievements: AchievementState[] = []
  @Prop @Watch('onTick') refreshToken: number = 0
  onOpenInsights: () => void = () => {}
  onOpenReview: () => void = () => {}
  onOpenRhythm: () => void = () => {}
  onOpenItem: (id: string) => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const snap = await GrowthService.snapshot()
    this.streakDays = snap.streakDays
    this.achievementUnlocked = snap.achievementUnlocked
    this.achievementTotal = snap.achievementTotal
    this.insights = await AppointmentService.monthInsights()
    this.logs = GrowthService.recentLogs(8)
    this.heatmap = GrowthService.checkInHeatmapDays()
    this.achievements = GrowthService.achievementStates()
    await GrowthService.evaluateAchievements()
    this.achievements = GrowthService.achievementStates()
    this.loading = false
  }

  private defFor(state: AchievementState): AchievementDef | undefined {
    return GrowthService.defForKey(state.key)
  }

  private logTime(iso: string): string {
    if (iso.length < 16) {
      return iso
    }
    return iso.slice(5, 16).replace('T', ' ')
  }

  build() {
    Column() {
      AppHeader({ title: '成长', subtitle: '守约数据 · 打卡 · 成就 · 时间轴' })
      if (this.loading) {
        AppLoading({ label: '加载成长数据…' }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Row({ space: 12 }) {
              Column({ space: 4 }) {
                Text(`${this.streakDays}`)
                  .fontSize(Theme.type.title1)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                Text('连续守约天')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding(14)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              Column({ space: 4 }) {
                Text(`${this.achievementUnlocked}/${this.achievementTotal}`)
                  .fontSize(Theme.type.title1)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                Text('成就解锁')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding(14)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
            }
            .width('100%')

            Column({ space: 8 }) {
              SectionTitle({ title: '守约打卡（近 28 天）' })
              Row({ space: 4 }) {
                ForEach(this.heatmap, (rec: CheckInRecord) => {
                  Column()
                    .width(8)
                    .height(24)
                    .backgroundColor(rec.done ? Theme.colors().brandPrimary : Theme.colors().strokeHairline)
                    .borderRadius(4)
                }, (rec: CheckInRecord) => rec.date)
              }
              .width('100%')
            }
            .width('100%')
            .padding(14)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)

            Column({ space: 8 }) {
              SectionTitle({ title: '30 天守约率', action: '详情', onAction: (): void => { this.onOpenInsights() } })
              Text(`完成 ${this.insights.doneCount}/${this.insights.totalCount} · ${this.insights.rateText}`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              if (this.insights.suggestion.length > 0) {
                Text(this.insights.suggestion)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
            }
            .width('100%')
            .padding(14)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)

            Column({ space: 10 }) {
              SectionTitle({ title: '成就墙' })
              Grid() {
                ForEach(this.achievements, (state: AchievementState) => {
                  GridItem() {
                    Column({ space: 4 }) {
                      Text(this.defFor(state)?.iconLabel ?? '·')
                        .fontSize(Theme.type.title2)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(state.unlockedAt.length > 0 ?
                          Theme.colors().brandPrimary : Theme.colors().textTertiary)
                      Text(this.defFor(state)?.title ?? state.key)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().textSecondary)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .width('100%')
                    .padding(10)
                    .backgroundColor(state.unlockedAt.length > 0 ?
                      Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.lg)
                  }
                }, (state: AchievementState) => state.key)
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .columnsGap(8)
              .rowsGap(8)
              .width('100%')
            }
            .width('100%')

            Column({ space: 8 }) {
              SectionTitle({ title: '时间轴' })
              if (this.logs.length === 0) {
                AppEmpty({
                  title: '还没有动态',
                  description: '创建或完成约定后，这里会记录你的守约历程'
                })
              } else {
                ForEach(this.logs, (log: ActivityLogItem) => {
                  Row({ space: 8 }) {
                    Column({ space: 2 }) {
                      Text(`${GrowthService.activityLabel(log.type)}「${log.title}」`)
                        .fontSize(Theme.type.subhead)
                        .fontColor(Theme.colors().textPrimary)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('100%')
                      Text(this.logTime(log.occurredAt))
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().textSecondary)
                        .width('100%')
                    }
                    .layoutWeight(1)
                  }
                  .width('100%')
                  .padding(10)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .onClick((): void => {
                    if (log.refId.length > 0 && log.type !== 'plan_done') {
                      this.onOpenItem(log.refId)
                    }
                  })
                }, (log: ActivityLogItem) => log.id)
              }
            }
            .width('100%')

            ToolEntry({
              title: '本周复盘',
              subtitle: '完成率、最忙一天与守约建议',
              onTap: (): void => { this.onOpenReview() }
            })
            ToolEntry({
              title: '智能整理',
              subtitle: '8 题看清本周节奏，按建议创建约定',
              onTap: (): void => { this.onOpenRhythm() }
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
  }
}
