import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { PredictionRow, PredictionSummary } from '../models/SportExtra'
import { AnalyticsService } from '../services/AnalyticsService'

@Component
export struct PredictionLabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State summary: PredictionSummary = new PredictionSummary()
  @State rows: PredictionRow[] = []
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.summary = await AnalyticsService.predictionLab()
    this.rows = await AnalyticsService.predictionRows()
  }

  private outcomeLabel(outcome: string): string {
    if (outcome === 'hit') {
      return '命中'
    }
    if (outcome === 'miss') {
      return '未中'
    }
    if (outcome === 'pending') {
      return '待结果'
    }
    return '难判定'
  }

  private outcomeColor(outcome: string): string {
    if (outcome === 'hit') {
      return Theme.colors().success
    }
    if (outcome === 'miss') {
      return Theme.colors().danger
    }
    return Theme.colors().textSecondary
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('预测实验室')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Column({ space: Theme.space.s2 }) {
              Text(`${this.summary.ratePercent}%`)
                .fontSize(40)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
              Text(this.summary.headline)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              Text('在工作台填写「赛前预测」，赛事档案里记录结果，系统自动对照。')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.lg)
            .alignItems(HorizontalAlign.Start)

            if (this.rows.length === 0) {
              AppEmpty({
                title: '还没有预测记录',
                description: '打开比赛工作台，写下赛前预测并保存',
                actionLabel: '',
                onAction: (): void => {}
              })
            } else {
              ForEach(this.rows, (row: PredictionRow) => {
                Column({ space: Theme.space.s2 }) {
                  Row() {
                    Text(row.title)
                      .fontSize(Theme.type.body)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .layoutWeight(1)
                    Text(this.outcomeLabel(row.outcome))
                      .fontSize(Theme.type.caption)
                      .fontColor(this.outcomeColor(row.outcome))
                  }
                  .width('100%')
                  Text(`${row.date} · 预测：${row.prediction}`)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  if (row.resultLabel.length > 0) {
                    Text(`实际：${row.resultLabel}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandPrimary)
                  }
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .alignItems(HorizontalAlign.Start)
              }, (row: PredictionRow) => row.matchId)
            }
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
    .width('100%')
    .height('100%')
    .zIndex(80)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
