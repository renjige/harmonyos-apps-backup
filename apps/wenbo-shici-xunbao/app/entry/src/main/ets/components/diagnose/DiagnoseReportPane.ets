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
        .borderRadius(Theme.radius.lg)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)

        this.Block('适合你的读法', this.report.strength)
        this.Block('需要注意', this.report.weakness)
        this.Block('建议路径', this.report.opportunity)
        this.Block('学习节奏', this.report.threat)

        Column({ space: Theme.space.s2 }) {
          Text('下一步')
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
        .borderRadius(Theme.radius.lg)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)

        Column({ space: Theme.space.s2 }) {
          Text('推荐关卡')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text(this.report.matchCategory)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .borderRadius(Theme.radius.lg)
        .backgroundColor(Theme.colors().brandPrimaryContainer)

        AppButton({
          label: `开启「${this.report.matchCategory}」`,
          onTap: () => this.onBook()
        })
        AppButton({
          label: '重新匹配',
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
  Block(title: string, body: string) {
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
    .borderRadius(Theme.radius.lg)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
  }
}
