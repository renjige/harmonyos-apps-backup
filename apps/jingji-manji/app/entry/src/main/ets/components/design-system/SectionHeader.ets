import { Theme } from './Theme'

@Component
export struct SectionHeader {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop actionLabel: string = ''
  onAction: () => void = () => {}

  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      if (this.actionLabel.length > 0) {
        Text(this.actionLabel)
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => {
            this.onAction()
          })
      }
    }
    .width('100%')
  }
}
