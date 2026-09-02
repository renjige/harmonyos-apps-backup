import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { InsightReport, KeywordItem, TrendPoint, SavedInsight } from '../models/SaituModels'
import { DateHelper } from '../services/DateHelper'
import { SaituInsightService } from '../services/SaituInsightService'
import { SaituTrackStore } from '../services/SaituTrackStore'
import { SaituDetailNav } from '../services/SaituDetailNav'

@Component
export struct InsightPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State weekly: boolean = true
  @State report: InsightReport = new InsightReport()
  @State keywords: KeywordItem[] = []
  @State trends: TrendPoint[] = []
  @State trendDelta: number = 0
  @State saved: SavedInsight[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.report = await SaituInsightService.buildReport(this.weekly)
    const end = DateHelper.todayKey()
    const startDate = new Date()
    startDate.setDate(startDate.getDate() - (this.weekly ? 6 : 29))
    const startKey = DateHelper.keyFromDate(startDate)
    this.keywords = await SaituInsightService.keywords(12, startKey, end)
    this.trends = await SaituInsightService.trendPoints(this.weekly ? 7 : 30)
    this.trendDelta = SaituInsightService.trendDeltaPercent(await SaituInsightService.trendPoints(14))
    this.saved = await SaituTrackStore.loadInsights()
  }

  private async saveReport(): Promise<void> {
    if (this.report.recordCount === 0) {
      this.showToast('本周期还没有札记，先去记录再生成小结')
      return
    }
    const item = SavedInsight.fromReport(this.report)
    await SaituTrackStore.saveInsight(item)
    this.saved = await SaituTrackStore.loadInsights()
    this.showToast('成长小结已保存，可点开查看或复制')
  }

  @Builder
  PeriodChip(label: string, value: boolean) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.weekly === value ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.weekly === value ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.weekly = value
        void this.reload()
      })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('智慧洞察')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text('不是备忘录：根据你写下的赛途札记，本机统计出可保存的成长小结。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Row({ space: Theme.space.s2 }) {
            this.PeriodChip('周报', true)
            this.PeriodChip('月报', false)
          }

          Column({ space: Theme.space.s2 }) {
            Text(this.report.periodLabel)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
            Text(`本周期 ${this.report.recordCount} 条札记`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text(`高频标签：${this.report.topTag}（${this.report.topTagRatio}%）`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
            Text(`活跃时段：${this.report.peakHourLabel}`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .alignItems(HorizontalAlign.Start)

          AppButton({
            label: '保存本周期成长小结',
            variant: 'primary',
            onTap: (): void => { void this.saveReport() }
          })

          Text('成长词云')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          if (this.keywords.length === 0) {
            AppEmpty({ title: '暂无关键词', description: '多写几条带标签的札记后可见' })
          } else {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.keywords, (k: KeywordItem) => {
                Text(k.word)
                  .fontSize(Theme.type.bodyS + Math.min(6, k.count))
                  .fontColor(Theme.colors().brandPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
              }, (k: KeywordItem) => k.word)
            }
          }

          Text('记录趋势')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          if (this.trends.length === 0) {
            Text('暂无趋势数据')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
          } else {
            Scroll() {
              Row({ space: 8 }) {
                ForEach(this.trends, (p: TrendPoint) => {
                  Column({ space: 4 }) {
                    Text(`${p.count}`)
                      .fontSize(10)
                      .fontColor(Theme.colors().textSecondary)
                    Column()
                      .width(22)
                      .height(Math.max(8, p.count * 14))
                      .backgroundColor(Theme.colors().brandPrimary)
                      .borderRadius(4)
                    Text(p.label.length > 0 ? p.label : DateHelper.displayShort(p.dateKey))
                      .fontSize(10)
                      .fontColor(Theme.colors().textSecondary)
                      .maxLines(1)
                  }
                  .width(36)
                  .height(120)
                  .justifyContent(FlexAlign.End)
                }, (p: TrendPoint) => p.dateKey)
              }
              .padding({ left: 4, right: 4, top: 8, bottom: 8 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Auto)
            .edgeEffect(EdgeEffect.Spring)
            .width('100%')
            .height(148)
            Text(`近 7 天记录频率${this.trendDelta >= 0 ? '提升' : '变化'} ${Math.abs(this.trendDelta)}%`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
          }

          Column({ space: Theme.space.s2 }) {
            Text('智慧寄语')
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textTertiary)
            Text(this.report.wisdomMessage)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .lineHeight(22)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .alignItems(HorizontalAlign.Start)

          Text('已保存小结')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.saved.length === 0) {
            Text('保存后可在此回顾每一期成长轨迹，并复制分享。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.saved, (s: SavedInsight) => {
              Column({ space: 4 }) {
                Text(s.periodLabel)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                Text(s.summaryLine())
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => SaituDetailNav.openInsight(s.id))
            }, (s: SavedInsight) => s.id)
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
          .margin({ top: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
