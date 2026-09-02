import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppRingChart, AppBarChart, BarChartItem } from '../components/design-system/AppChart'
import { FanDashboardSnapshot, TimelineEntry, AchievementDef, WeeklyReviewSnapshot } from '../models/FanGrowthModels'
import { FanStatsService } from '../services/FanStatsService'
import { TimelineService } from '../services/TimelineService'
import { AchievementService } from '../services/AchievementService'
import { StarDetailNav } from '../services/StarDetailNav'

class GrowthSegment {
  key: string = 'overview'
  label: string = ''

  static all(): GrowthSegment[] {
    const out: GrowthSegment[] = []
    const keys: string[] = ['overview', 'timeline', 'achievements']
    const labels: string[] = ['概览', '时间轴', '成就']
    let i = 0
    while (i < keys.length) {
      const s = new GrowthSegment()
      s.key = keys[i]
      s.label = labels[i]
      out.push(s)
      i += 1
    }
    return out
  }
}

/** 成长 Tab — 统计 · 时间轴 · 成就 · 周回顾 */
@Component
export struct GrowthPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('growthTick') growthTick: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State segment: string = 'overview'
  @State dash: FanDashboardSnapshot = new FanDashboardSnapshot()
  @State timeline: TimelineEntry[] = []
  @State week: WeeklyReviewSnapshot = new WeeklyReviewSnapshot()
  @State barItems: BarChartItem[] = []
  private segments: GrowthSegment[] = GrowthSegment.all()
  private achievements: AchievementDef[] = AchievementService.definitions()

  aboutToAppear(): void {
    this.reloadLocal()
  }

  onRefreshChange(): void {
    this.reloadLocal()
  }

  private reloadLocal(): void {
    this.dash = FanStatsService.dashboard()
    this.timeline = TimelineService.list(25)
    this.week = FanStatsService.weekReview()
    this.barItems = this.buildBars()
  }

  private buildBars(): BarChartItem[] {
    const items: BarChartItem[] = []
    const labels: string[] = ['已看', '笔记', '浏览', '测验', '对比']
    const values: number[] = [
      this.dash.watchedCount,
      this.dash.noteCount,
      this.dash.browseCount,
      this.dash.quizAttempts,
      this.dash.compareSetCount
    ]
    let i = 0
    while (i < labels.length) {
      const row = new BarChartItem()
      row.label = labels[i]
      row.value = values[i]
      items.push(row)
      i += 1
    }
    return items
  }

  private openTimelineEntry(entry: TimelineEntry): void {
    if (entry.refKind === 'event') {
      StarDetailNav.openEvent(entry.refId)
      return
    }
    if (entry.refKind === 'athlete') {
      StarDetailNav.openAthlete(entry.refId)
    }
  }

  build() {
    Column() {
      AppHeader({ title: '成长', subtitle: '我的数据 · 时间轴 · 球迷徽章' })
      Row({ space: Theme.space.s2 }) {
        ForEach(this.segments, (seg: GrowthSegment) => {
          Text(seg.label)
            .fontSize(Theme.type.caption)
            .fontWeight(this.segment === seg.key ? FontWeight.Medium : FontWeight.Normal)
            .fontColor(this.segment === seg.key ?
              Theme.colors().brandPrimary : Theme.colors().textSecondary)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.segment === seg.key ?
              Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.segment = seg.key })
        }, (seg: GrowthSegment) => seg.key)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s5 }) {
          if (this.segment === 'overview') {
            Row({ space: Theme.space.s3 }) {
              AppRingChart({
                title: '计划完成率',
                percent: this.dash.planProgress
              }).layoutWeight(1)
              Column({ space: Theme.space.s2 }) {
                Text(`连续 ${this.dash.streakDays} 天`)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                Text(`测验最佳 ${this.dash.quizBest} 题`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                Text(`成就 ${AchievementService.unlockedCount()}/${this.achievements.length}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')

            AppBarChart({ title: '我的球迷数据', items: this.barItems })

            Column({ space: Theme.space.s3 }) {
              Text('本周回顾')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(`已看 ${this.week.watchedCount} 场 · 笔记 ${this.week.notesCount} 条 · 挑战 ${this.week.quizAttempts} 次`)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
            .border({ width: 1, color: Theme.colors().strokeHairline })
          }

          if (this.segment === 'timeline') {
            if (this.timeline.length === 0) {
              AppEmpty({
                title: '还没有球迷动态',
                description: '浏览球星、加入计划或写笔记后会出现在这里'
              })
            } else {
              ForEach(this.timeline, (entry: TimelineEntry) => {
                Row({ space: Theme.space.s2 }) {
                  Text(entry.kindLabel())
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                  Column({ space: 2 }) {
                    Text(entry.title)
                      .fontSize(Theme.type.callout)
                      .fontColor(Theme.colors().textPrimary)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                    Text(`${entry.subtitle} · ${entry.timeLabel()}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  if (entry.refKind === 'event' || entry.refKind === 'athlete') {
                    AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
                  }
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .onClick((): void => { this.openTimelineEntry(entry) })
              }, (entry: TimelineEntry) => entry.id)
            }
          }

          if (this.segment === 'achievements') {
            ForEach(this.achievements, (def: AchievementDef) => {
              Row({ space: Theme.space.s3 }) {
                Column() {
                  AppIcon({
                    name: def.iconName === 'search' ? 'search' :
                      def.iconName === 'check' ? 'check' :
                        def.iconName === 'heart' ? 'heart' :
                          def.iconName === 'chart' ? 'chart' :
                            def.iconName === 'biz' ? 'biz' : 'star',
                    iconSize: Theme.icon.md,
                    color: AchievementService.isUnlocked(def.id) ?
                      Theme.colors().brandPrimary : Theme.colors().textTertiary
                  })
                }
                .width(44)
                .height(44)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(AchievementService.isUnlocked(def.id) ?
                  Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.lg)
                Column({ space: 2 }) {
                  Text(def.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(def.caption)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                if (AchievementService.isUnlocked(def.id)) {
                  AppIcon({ name: 'check', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
                }
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
            }, (def: AchievementDef) => def.id)
          }
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
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
