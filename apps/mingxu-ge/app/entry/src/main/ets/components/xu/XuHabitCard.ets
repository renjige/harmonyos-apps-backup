import { Theme } from '../design-system/Theme'

@Component
export struct XuHabitCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop done: boolean = false
  @Prop streak: number = 0
  onToggle: () => void = () => {}
  onOpen: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text(this.title)
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(2)
        .width('100%')
      Text(this.done ? '今日已打卡' : '今日未打卡')
        .fontSize(Theme.type.caption)
        .fontColor(this.done ? Theme.colors().success : Theme.colors().textSecondary)
        .width('100%')
      Text(`连续 ${this.streak} 天`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandAccent)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .constraintSize({ minHeight: 128 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.done ? Theme.colors().successContainer : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        TapGesture({ count: 1 })
          .onAction(() => {
            this.onToggle()
          }),
        LongPressGesture({ repeat: false, duration: 500 })
          .onAction(() => {
            this.onOpen()
          })
      )
    )
  }
}
