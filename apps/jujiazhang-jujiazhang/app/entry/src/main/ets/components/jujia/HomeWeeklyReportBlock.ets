import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct HomeWeeklyReportBlock {
  @Prop summary: string = ''
  @Prop headline: string = ''
  onOpenGrowth: () => void = () => {}

  build() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 4 }) {
          Text('本周家庭报告')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Text(this.headline)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        AppIcon({ name: 'chart', iconSize: 18, color: Theme.colors().textSecondary })
      }
      .width('100%')
      Text(this.summary)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Text('查看完整成长数据')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandPrimary)
        .width('100%')
        .onClick(() => this.onOpenGrowth())
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick(() => this.onOpenGrowth())
  }
}
