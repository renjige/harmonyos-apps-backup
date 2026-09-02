import { Theme } from '../design-system/Theme'
import { ArchiveSnap, MixShare, TimelineEvent, GoalProgress } from '../../models/TuceModels'
import { TuceEngine } from '../../services/TuceEngine'
import { TuceStore } from '../../services/TuceStore'
import { AppBarChart, AppRingChart, BarChartItem } from '../design-system/AppChart'
import { GoalProgressCard } from '../tuce/GoalProgressCard'

@Component
export struct ReviewPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State snap: ArchiveSnap = new ArchiveSnap()
  @State mix: MixShare[] = []
  @State events: TimelineEvent[] = []
  @State monthText: string = ''
  @State bars: BarChartItem[] = []
  @State goalProgress: GoalProgress = new GoalProgress()

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.snap = await TuceEngine.archive()
    this.mix = await TuceEngine.mix()
    this.events = await TuceEngine.timeline()
    const logs = await TuceStore.logs()
    this.monthText = TuceEngine.monthCount(logs.length)
    this.bars = await TuceEngine.weeklyBars()
    this.goalProgress = await TuceEngine.goalProgress()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('运动回顾')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.monthText)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(`训练 ${this.snap.sessions} 次 · 连续 ${this.snap.streak} 天 · 方案 ${this.snap.plans} 套 · 完成计划 ${this.snap.programsDone} 个`)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')

        GoalProgressCard({ progress: this.goalProgress })

        Row({ space: Theme.space.s3 }) {
          AppBarChart({ title: '本周频次', items: this.bars }).layoutWeight(1)
          AppRingChart({ title: '月目标', percent: this.goalProgress.monthlyPct }).layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Text('训练类型占比')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        if (this.mix.length === 0) {
          Text('完成一次训练后，这里会显示类型占比。')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        ForEach(this.mix, (s: MixShare) => {
          Row({ space: Theme.space.s2 }) {
            Text(s.label)
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width(80)
            Progress({ value: s.percent, total: 100, type: ProgressType.Linear })
              .layoutWeight(1)
              .height(8)
              .color(Theme.colors().brandPrimary)
              .backgroundColor(Theme.colors().surfaceSubtle)
              .style({ strokeWidth: 8 })
            Text(`${s.percent}%`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width(36)
          }
          .width('100%')
        }, (s: MixShare) => s.label)

        Text('成长时间轴')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.events, (e: TimelineEvent) => {
          Row({ space: Theme.space.s3 }) {
            Column()
              .width(10)
              .height(10)
              .borderRadius(5)
              .backgroundColor('#FF6B35')
              .margin({ top: 6 })
            Column({ space: 2 }) {
              Text(e.title)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(e.date)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
        }, (e: TimelineEvent) => `${e.date}_${e.title}`)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
  }
}
