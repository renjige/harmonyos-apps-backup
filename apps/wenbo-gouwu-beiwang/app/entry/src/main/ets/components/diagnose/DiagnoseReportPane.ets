import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DiagnoseReport } from '../../models/DiagnoseModels'

@Component
export struct DiagnoseReportPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop report: DiagnoseReport = new DiagnoseReport()
  onBook: () => void = () => {}
  onRetry: () => void = () => {}

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Column({ space: Theme.space.s2 }) {
          Text(this.report.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
          Text(`${this.report.scoreLabel} · ${this.report.generatedAt}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandAccent)
          Text(this.report.summary)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .borderRadius(Theme.radius.card)
        .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)

        this.SwotCard('优势 S', this.report.strength)
        this.SwotCard('短板 W', this.report.weakness)
        this.SwotCard('机会 O', this.report.opportunity)
        this.SwotCard('风险 T', this.report.threat)

        Column({ space: Theme.space.s2 }) {
          Text('行动清单')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
            .width('100%')
          ForEach(this.report.actions, (line: string, idx: number) => {
            Text(`${idx + 1}. ${line}`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
          }, (line: string, idx: number) => `a-${idx}`)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .borderRadius(Theme.radius.card)
        .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)

        Column({ space: Theme.space.s2 }) {
          Text('服务匹配')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
          Text(this.report.matchCategory)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          Text(this.report.matchHint)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .borderRadius(Theme.radius.card)
        .backgroundColor(Theme.colors().brandPrimaryContainer)

        AppButton({
          label: `去「${this.report.matchCategory}」预约顾问`,
          onTap: () => this.onBook()
        })
        AppButton({
          label: '重新诊断',
          variant: 'secondary',
          onTap: () => this.onRetry()
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
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  SwotCard(title: string, body: string) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandAccent)
        .width('100%')
      Text(body)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(Theme.space.s4)
    .borderRadius(Theme.radius.card)
    .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
  }
}
