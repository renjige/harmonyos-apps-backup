import { Theme } from '../design-system/Theme'
import { WeekMark } from '../../models/FieldModels'

@Component
export struct GewuWeekStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop marks: WeekMark[] = []
  onPick: (key: string) => void = (key: string) => {
    if (key.length === 0) {
      return
    }
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('七日物候')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('有观察记录的日期会点亮，点选可查看当天记录。')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row() {
        ForEach(this.marks, (m: WeekMark) => {
          Column({ space: 4 }) {
            Text(m.label)
              .fontSize(10)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Column()
              .width(14)
              .height(14)
              .borderRadius(7)
              .backgroundColor(m.hasRecord ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .onClick((): void => { this.onPick(m.key) })
        }, (m: WeekMark) => m.key)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }
}
