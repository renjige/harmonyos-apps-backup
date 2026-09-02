import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ActivityStrip } from '../components/moment/ActivityStrip'
import { MilestoneBadge, TagStat, WeekCompare, DayActivity } from '../models/MomentModels'
import { DateHelper } from '../services/DateHelper'
import { MomentStore } from '../services/MomentStore'
import { MomentNav } from '../services/MomentNav'

@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onOpenTimeline: () => void = () => {}
  @State compare: WeekCompare = new WeekCompare()
  @State milestones: MilestoneBadge[] = []
  @State tags: TagStat[] = []
  @State activityDays: DayActivity[] = []
  @State unlockedCount: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.compare = await MomentStore.weekCompare()
    this.milestones = await MomentStore.milestones()
    this.tags = await MomentStore.tagStats()
    this.activityDays = await MomentStore.last7DayActivity()
    let n = 0
    for (let i = 0; i < this.milestones.length; i++) {
      if (this.milestones[i].unlocked) {
        n++
      }
    }
    this.unlockedCount = n
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('成长')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })

        Text(this.compare.line)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .lineHeight(22)
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(16)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row({ space: Theme.space.s3 }) {
          this.StatCell(`${this.compare.thisNotes}`, '本周小事')
          this.StatCell(`${this.compare.thisDone}`, '完成待办')
          this.StatCell(`${this.unlockedCount}`, '成就')
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        ActivityStrip({ days: this.activityDays })

        Column({ space: Theme.space.s2 }) {
          Text('记录成就')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.milestones.length === 0) {
            AppEmpty({ title: '还没有成就', description: '坚持记录后会逐步解锁' })
          } else {
            ForEach(this.milestones, (m: MilestoneBadge) => {
              Row({ space: Theme.space.s3 }) {
                Column() {
                  AppIcon({
                    name: m.unlocked ? 'star' : 'empty',
                    iconSize: Theme.icon.md,
                    color: m.unlocked ? Theme.colors().warning : Theme.colors().textTertiary
                  })
                }
                .width(36)
                .height(36)
                .justifyContent(FlexAlign.Center)
                Column({ space: 2 }) {
                  Text(m.title)
                    .fontSize(Theme.type.body)
                    .fontColor(m.unlocked ? Theme.colors().textPrimary : Theme.colors().textSecondary)
                  Text(m.detail)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })
            }, (m: MilestoneBadge) => m.id)
          }
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(16)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.tags.length > 0) {
          Column({ space: Theme.space.s2 }) {
            Text('标签分布')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.tags, (s: TagStat) => {
              Row() {
                Text(`#${s.label}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(s.color)
                Blank()
                Text(`${s.count}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().textSecondary)
              }
              .width('100%')
            }, (s: TagStat) => s.label)
          }
          .width('100%')
          .padding(14)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(16)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        AppListRow({ title: '时光轴', subtitle: '月历圆点 · 当日小事 · 生活海报', onTap: (): void => this.onOpenTimeline() })
        AppListRow({ title: '生活见解', subtitle: '本周对照 · 星标精选', onTap: (): void => MomentNav.openInsight() })
        AppListRow({ title: '回顾中心', subtitle: '今日收束 · 本周复盘 · 本月卡片', onTap: (): void => MomentNav.openReviewCenter() })
        AppListRow({ title: '心情轨迹', subtitle: '近 14 日心情变化', onTap: (): void => MomentNav.openMoodTrend() })
        AppListRow({ title: '打卡日历', subtitle: '近 30 日记录轨迹', onTap: (): void => MomentNav.openCheckin() })
        AppListRow({ title: '生活专题', subtitle: '把小事收成主题合集', onTap: (): void => MomentNav.openTopics() })
        AppListRow({ title: '重要纪念日', subtitle: '生日 · 节日 · 到点提醒', onTap: (): void => MomentNav.openMemorials() })

        AppButton({
          label: '写本周复盘',
          variant: 'secondary',
          onTap: (): void => MomentNav.openWeeklyReview()
        })
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Row().height(this.bottomInset)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  StatCell(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(16)
  }
}
