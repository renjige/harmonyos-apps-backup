import { Theme } from '../design-system/Theme'

@Component
export struct MessageDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemTitle: string = ''
  @Prop itemBody: string = ''
  @Prop itemTime: string = ''
  onClose: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .constraintSize({ minHeight: 44 })
          .onClick((): void => { this.onClose() })
        Text('通知详情')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.itemTitle.length > 0 ? this.itemTitle : '机构通知')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.itemTime.length > 0) {
            Text(this.itemTime)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.bodyMuted())
              .width('100%')
          }
          Text(this.itemBody)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
            .lineHeight(24)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
