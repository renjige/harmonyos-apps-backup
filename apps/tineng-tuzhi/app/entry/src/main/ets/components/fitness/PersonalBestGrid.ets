import { Theme } from '../design-system/Theme'
import { PersonalBest } from '../../models/WorkoutModels'

@Component
export struct PersonalBestGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop items: PersonalBest[] = []

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('个人最佳')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.items, (pb: PersonalBest) => {
          Column({ space: 4 }) {
            Text(pb.value)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().brandPrimary)
            Text(`${pb.label}（${pb.unit}）`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .maxLines(2)
          }
          .width('47%')
          .padding(Theme.space.s3)
          .margin({ bottom: Theme.space.s2 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .alignItems(HorizontalAlign.Center)
        }, (pb: PersonalBest) => pb.key)
      }
      .width('100%')
    }
    .width('100%')
  }
}
