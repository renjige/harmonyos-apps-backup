import { Theme } from '../components/design-system/Theme'
import { MoodCurveChart } from '../components/mood/MoodCurveChart'
import { EmotionCount, HighlightDay, MonthlyReportData } from '../models/MoodModels'
import { EmotionCatalog } from '../models/EmotionCatalog'
import { DateHelper } from '../services/DateHelper'
import { MonthlyReportService } from '../services/MonthlyReportService'

@Component
export struct MonthlyReportPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop reloadToken: number = 0
  @State year: number = new Date().getFullYear()
  @State month: number = new Date().getMonth() + 1
  @State report: MonthlyReportData = new MonthlyReportData()
  @State loading: boolean = true
  @State refreshSeen: number = 0

  aboutToAppear(): void {
    void this.load()
  }

  private onReload(): void {
    if (this.reloadToken !== this.refreshSeen) {
      this.refreshSeen = this.reloadToken
      void this.load()
    }
  }

  private async load(): Promise<void> {
    this.loading = true
    this.report = await MonthlyReportService.buildReport(this.year, this.month)
    this.loading = false
  }

  private shiftMonth(delta: number): void {
    let m = this.month + delta
    let y = this.year
    if (m > 12) {
      m = 1
      y++
    } else if (m < 1) {
      m = 12
      y--
    }
    this.month = m
    this.year = y
    void this.load()
  }

  private cloudFontSize(count: number, max: number): number {
    if (max <= 0) {
      return 12
    }
    const ratio = count / max
    return Math.round(12 + ratio * 14)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Text('‹')
            .fontSize(28)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => { this.shiftMonth(-1) })
          Column({ space: 2 }) {
            Text('情绪月痕报告')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(DateHelper.monthLabel(this.year, this.month))
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          Text('›')
            .fontSize(28)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => { this.shiftMonth(1) })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        if (this.loading) {
          Text('正在汇总月痕…')
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        } else {
          Row({ space: Theme.space.s4 }) {
            Column({ space: 4 }) {
              Text(`${this.report.recordDays}`)
                .fontSize(Theme.type.displayS)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text('记录天数')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)

            Column({ space: 4 }) {
              Text(`${this.report.avgScore}`)
                .fontSize(Theme.type.displayS)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandAccent)
              Text('平均能量')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('情绪词云')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            if (this.report.emotionCounts.length === 0) {
              Text('记录更多日子后，这里会出现你的情绪词云')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            } else {
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
                ForEach(this.report.emotionCounts, (ec: EmotionCount) => {
                  Text(ec.label)
                    .fontSize(this.cloudFontSize(ec.count, this.report.emotionCounts[0].count))
                    .fontColor(Theme.colors().brandDeep)
                    .fontWeight(FontWeight.Medium)
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .margin(6)
                }, (ec: EmotionCount) => ec.id)
              }
              .width('100%')
            }
          }
          .width('100%')
          .padding(Theme.space.s5)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: Theme.space.s3 }) {
            Text('情绪曲线')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            MoodCurveChart({ points: this.report.scorePoints, chartHeight: 140 })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: Theme.space.s3 }) {
            Text('高光时刻')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            if (this.report.highlights.length === 0) {
              Text('本月暂无高光记录')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            } else {
              Scroll() {
                Row({ space: Theme.space.s3 }) {
                  ForEach(this.report.highlights, (h: HighlightDay) => {
                    Column({ space: Theme.space.s2 }) {
                      if (h.imagePath.length > 0) {
                        Image(h.imagePath)
                          .width(200)
                          .height(100)
                          .borderRadius(Theme.radius.md)
                          .objectFit(ImageFit.Cover)
                      }
                      Text(DateHelper.displayDate(h.dateKey))
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      Text(`能量 ${h.score}`)
                        .fontSize(Theme.type.bodyS)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      Text(h.diary.length > 0 ? h.diary : '（无文字）')
                        .fontSize(Theme.type.bodyS)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .maxLines(3)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width(200)
                    }
                    .padding(Theme.space.s3)
                    .backgroundColor(Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.md)
                  }, (h: HighlightDay) => h.dateKey)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
            }
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Column({ space: Theme.space.s3 }) {
            Text('月度寄语')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.report.monthlyMessage)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(26)
              .fontStyle(FontStyle.Italic)
          }
          .width('100%')
          .padding(Theme.space.s5)
          .linearGradient({
            angle: 135,
            colors: [[Theme.colors().brandPrimaryContainer, 0], [Theme.colors().surfaceCard, 0.8]]
          })
          .borderRadius(Theme.radius.lg)
        }
      }
      .width('100%')
      .padding(Theme.space.pageX)
      .padding({ bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
    .onAppear((): void => { this.onReload() })
  }
}
