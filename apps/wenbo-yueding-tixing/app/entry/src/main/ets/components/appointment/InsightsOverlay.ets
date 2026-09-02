import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { MonthInsights } from '../../models/AppointmentModels'

@Component
export struct InsightsOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop insights: MonthInsights = new MonthInsights()
  onClose: () => void = () => {}

  @Builder
  SceneBar(label: string, count: number, total: number, color: string) {
    Row({ space: 10 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width(36)
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(8)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
        Row()
          .width(total > 0 ? `${Math.max(8, Math.round(count * 100 / total))}%` : '0%')
          .height(8)
          .backgroundColor(color)
          .borderRadius(Theme.radius.pill)
      }
      .layoutWeight(1)
      Text(`${count}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textPrimary)
        .width(24)
        .textAlign(TextAlign.End)
    }
    .width('100%')
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text('守约洞察')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text(' ')
          .fontSize(Theme.type.subhead)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: 12 }) {
            Column({ space: 4 }) {
              Text(this.insights.rateText)
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
              Text('30 天守约率')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(16)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
            .alignItems(HorizontalAlign.Center)

            Column({ space: 4 }) {
              Text(`${this.insights.streakDays}`)
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().success)
              Text('连续完成天')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(16)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')

          Column({ space: 10 }) {
            Text(`近 30 天共 ${this.insights.totalCount} 条 · 完成 ${this.insights.doneCount} 条`)
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Text(`活跃时段：${this.insights.busiestHour}`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            if (this.insights.repeatActive > 0) {
              Text(`重复约定进行中 ${this.insights.repeatActive} 条 · 完成后自动生成下一周期`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().brandPrimary)
                .width('100%')
            }
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)

          Column({ space: 12 }) {
            Text('场景分布')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            this.SceneBar('工作', this.insights.workCount, this.insights.totalCount, Theme.colors().brandPrimary)
            this.SceneBar('生活', this.insights.lifeCount, this.insights.totalCount, '#0EA5E9')
            this.SceneBar('学习', this.insights.studyCount, this.insights.totalCount, '#8B5CF6')
            this.SceneBar('健康', this.insights.healthCount, this.insights.totalCount, '#10B981')
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)

          Text(this.insights.suggestion)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
            .padding(16)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.lg)

          AppButton({ label: '知道了', onTap: (): void => { this.onClose() } })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
