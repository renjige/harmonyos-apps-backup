import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DiagnoseReport } from '../../models/DiagnoseModels'

@Component
export struct DiagnoseReportPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop report: DiagnoseReport = new DiagnoseReport()
  onRetry: () => void = () => {}
  onClose: () => void = () => {}

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Column({ space: Theme.space.s2 }) {
          Text(this.report.title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.of(this.darkModeOn).textPrimary)
          Text(`${this.report.scoreLabel} · ${this.report.generatedAt}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).brandAccent)
          Text(this.report.summary)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .borderRadius(Theme.radius.lg)
        .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)

        this.ReportCard('表达优势', this.report.strength)
        this.ReportCard('待改进', this.report.weakness)
        this.ReportCard('练习方向', this.report.opportunity)
        this.ReportCard('注意事项', this.report.threat)

        Column({ space: Theme.space.s2 }) {
          Text('本周练习')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).textPrimary)
            .width('100%')
          ForEach(this.report.actions, (line: string, idx: number) => {
            Text(`${idx + 1}. ${line}`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
          }, (line: string, idx: number) => `a-${idx}`)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .borderRadius(Theme.radius.lg)
        .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)

        Column({ space: Theme.space.s2 }) {
          Text('推荐浏览')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).textPrimary)
          Text(this.report.matchCategory)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).brandPrimary)
          Text(this.report.matchHint)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .borderRadius(Theme.radius.lg)
        .backgroundColor(Theme.of(this.darkModeOn).brandPrimaryContainer)

        AppButton({
          label: '重新填写问卷',
          variant: 'secondary',
          onTap: (): void => { this.onRetry() }
        })
        AppButton({
          label: '完成',
          onTap: (): void => { this.onClose() }
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
  ReportCard(title: string, body: string) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.of(this.darkModeOn).brandAccent)
        .width('100%')
      Text(body)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.of(this.darkModeOn).textPrimary)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(Theme.space.s4)
    .borderRadius(Theme.radius.lg)
    .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
  }
}
