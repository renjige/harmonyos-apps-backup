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
      Column({ space: 2 }) {
        Text(this.title)
          .fontSize(Theme.type.titleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      if (this.actionLabel.length > 0) {
        Text(this.actionLabel)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onAction() })
      }
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}
