import { Theme } from './Theme'

@Component
export struct StatTile {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop value: string = ''
  @Prop accent: boolean = false

  build() {
    Column({ space: 6 }) {
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
      Text(this.value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.accent ? Theme.colors().brandPrimary : Theme.colors().textPrimary)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Theme.colors().surfaceSubtle)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
