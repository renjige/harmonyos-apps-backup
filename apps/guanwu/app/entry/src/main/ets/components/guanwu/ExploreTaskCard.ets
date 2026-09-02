import { Theme } from '../design-system/Theme'
import { ExploreTaskDef } from '../../models/ObserveCatalog'

@Component
export struct ExploreTaskCard {
  onPick: (task: ExploreTaskDef) => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('探索任务')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('轻量任务帮助你持续观物，完成后会进入今日记录')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      ForEach(ExploreTaskDef.todayList(), (task: ExploreTaskDef) => {
        Row() {
          Column({ space: 4 }) {
            Text(task.title)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text(task.prompt)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .maxLines(2)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Text('去记录')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onClick((): void => this.onPick(task))
      }, (task: ExploreTaskDef) => task.key)
    }
    .width('100%')
  }
}
