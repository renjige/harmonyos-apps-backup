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
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(`${this.report.scoreLabel} · ${this.report.generatedAt}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandAccent)
          Text(this.report.summary)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .borderRadius(Theme.radius.card)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)

        this.SwotCard('记录习惯', this.report.strength)
        this.SwotCard('容易散落', this.report.weakness)
        this.SwotCard('可整理方向', this.report.opportunity)
        this.SwotCard('需要留意', this.report.threat)

        Column({ space: Theme.space.s2 }) {
          Text('可以先做的事')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.report.actions, (line: string, idx: number) => {
            Text(`${idx + 1}. ${line}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }, (line: string, idx: number) => `a-${idx}`)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .borderRadius(Theme.radius.card)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)

        Column({ space: Theme.space.s2 }) {
          Text('整理入口')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(this.report.matchCategory)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text(this.report.matchHint)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .borderRadius(Theme.radius.card)
        .backgroundColor(Theme.colors().brandPrimaryContainer)

        AppButton({
          label: `去记下一条灵感`,
          onTap: () => this.onBook()
        })
        AppButton({
          label: '再整理一次',
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
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(Theme.space.s4)
    .borderRadius(Theme.radius.card)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
  }
}
