import { Theme } from '../design-system/Theme'

@Component
export struct ThoughtCardView {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop previewText: string = ''
  @Prop tagsLabel: string = ''
  @Prop shelfLabel: string = ''
  @Prop timeLabel: string = ''
  onOpen: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Text(this.previewText)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .lineHeight(24)
        .width('100%')
      Row() {
        if (this.shelfLabel.length > 0) {
          Text(this.shelfLabel)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 8 })
        }
        Text(this.tagsLabel.length > 0 ? this.tagsLabel : '未分类')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandAccent)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
        Blank()
        Text(this.timeLabel)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onOpen() })
  }
}
