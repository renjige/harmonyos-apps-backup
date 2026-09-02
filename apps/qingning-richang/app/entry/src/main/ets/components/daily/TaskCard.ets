import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DailyTaskItem } from '../../models/DailyModels'

@Component
export struct TaskCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop task: DailyTaskItem = new DailyTaskItem()
  @Prop done: boolean = false
  @Prop expanded: boolean = false
  @Prop celebrate: boolean = false
  onToggleExpand: () => void = () => {}
  onComplete: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Column({ space: Theme.space.s3 }) {
          Text('每日一事')
            .fontSize(Theme.type.overline)
            .fontColor('rgba(255,255,255,0.88)')
            .fontWeight(FontWeight.Medium)
          Text(this.task.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width('100%')
          if (this.expanded) {
            Text(this.task.detail)
              .fontSize(Theme.type.body)
              .fontColor('rgba(255,255,255,0.92)')
              .lineHeight(24)
              .width('100%')
          } else {
            Text('轻触展开详情')
              .fontSize(Theme.type.footnote)
              .fontColor('rgba(255,255,255,0.75)')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding(Theme.space.s5)

        if (this.celebrate) {
          Text('✨')
            .fontSize(28)
            .margin({ top: 12, right: 16 })
        }
      }
      .width('100%')
      .linearGradient({
        angle: 135,
        colors: [['#7BC043', 0], ['#5A9A2E', 1]]
      })
      .borderRadius(Theme.radius.xl)
      .onClick(() => this.onToggleExpand())

      if (!this.done) {
        AppButton({
          label: this.expanded ? '已完成' : '展开并完成',
          onTap: (): void => { this.onComplete() }
        })
      } else {
        Column({ space: 4 }) {
          Text('今日已完成')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text(this.task.encourage)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(Theme.radius.md)
      }
    }
    .width('100%')
  }
}
