import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { TransformReport, TransformReportService, WeekBarItem } from '../../services/TransformReportService'
import { RecordStore } from '../../services/RecordStore'

@Component
export struct TransformReportPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onGoRecord: () => void = () => {}
  @State report: TransformReport = new TransformReport()
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const list = await RecordStore.loadAll()
    this.report = TransformReportService.build(list)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async copy(): Promise<void> {
    const ok = await TransformReportService.copyReport(this.report)
    this.showToast(ok ? '报告已复制，可粘贴到备忘或社交' : '复制失败')
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.report.headline)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s3 }) {
            this.Kpi('跨度', `${this.report.daysSpan}天`)
            this.Kpi('次数', `${this.report.sessionCount}`)
            this.Kpi('连续', `${this.report.streak}天`)
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            this.Line('体重变化', `${this.report.weightDelta} kg`)
            this.Line('距离变化', `${this.report.distanceDelta} km`)
            this.Line('时长变化', `${this.report.durationDelta} 分钟`)
            this.Line('主项', this.report.topSport.length > 0 ? this.report.topSport : '—')
            this.Line('最近间隔', `${this.report.lastGapDays} 天`)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Text('近 7 日节奏')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Row({ space: 6 }) {
            ForEach(this.report.weekBars, (bar: WeekBarItem) => {
              Column({ space: 4 }) {
                Column()
                  .width('100%')
                  .height(12 + bar.count * 18)
                  .backgroundColor(bar.count > 0 ? '#FF6B35' : Theme.colors().surfaceSubtle)
                  .borderRadius(4)
                Text(bar.label)
                  .fontSize(Theme.type.overline)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .justifyContent(FlexAlign.End)
              .height(90)
            }, (bar: WeekBarItem) => bar.label)
          }
          .width('100%')
          .alignItems(VerticalAlign.Bottom)

          Text(this.report.nextAction)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .lineHeight(22)
            .width('100%')

          AppButton({ label: '复制蜕变报告', variant: 'primary', onTap: (): void => { void this.copy() } })
          AppButton({
            label: '按建议去记录',
            variant: 'secondary',
            onTap: (): void => { this.onGoRecord() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  Kpi(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  Line(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.bodyS)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .layoutWeight(1)
      Text(value)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .width('100%')
  }
}
