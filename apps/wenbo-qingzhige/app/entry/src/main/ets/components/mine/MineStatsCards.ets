import { Theme } from '../design-system/Theme'

@Component
export struct MineStatTile {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop value: string = '0'
  @Prop label: string = ''

  build() {
    Column({ space: 4 }) {
      Text(this.value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      Text(this.label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: Theme.space.s4, bottom: Theme.space.s4 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
