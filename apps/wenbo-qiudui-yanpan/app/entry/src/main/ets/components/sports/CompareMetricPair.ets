import { Theme } from '../design-system/Theme'

@Component
export struct CompareMetricPair {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop leftText: string = ''
  @Prop rightText: string = ''

  build() {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(this.label)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
        Text(this.leftText)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .alignItems(HorizontalAlign.Start)
      Column({ space: 4 }) {
        Text(this.label)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
        Text(this.rightText)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}
