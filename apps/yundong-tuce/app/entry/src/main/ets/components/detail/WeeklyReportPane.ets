import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { WeeklyReport } from '../../models/TuceModels'
import { TuceEngine } from '../../services/TuceEngine'
import { TuceClipboard } from '../../services/TuceClipboard'

@Component
export struct WeeklyReportPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('tuceReload') @Watch('onReload') reloadToken: number = 0
  @State report: WeeklyReport = new WeeklyReport()
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  onReload(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.report = await TuceEngine.weeklyReport()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private async copy(): Promise<void> {
    const ok = await TuceClipboard.copyText(this.report.bodyText)
    this.showToast(ok ? '周报已复制，可分享或粘贴备忘' : '复制失败')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.report.headline)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s3 }) {
            Column({ space: 4 }) {
              Text(`${this.report.weekDone}/${this.report.weekTarget}`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
              Text('本周次数')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .alignItems(HorizontalAlign.Center)

            Column({ space: 4 }) {
              Text(`${this.report.streak}`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
              Text('连续天数')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')

          Text(`主项：${this.report.topPlan}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text(this.report.categoryMix)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')

          Text(this.report.insight)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.report.nextAction)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')

          AppButton({ label: '复制训练周报', variant: 'primary', onTap: (): void => { void this.copy() } })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)

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
  }
}
