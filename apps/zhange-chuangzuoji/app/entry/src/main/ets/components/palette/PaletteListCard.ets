import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ColorPalette } from '../../models/PaletteModels'

@Component
export struct PaletteListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop palette: ColorPalette = new ColorPalette()
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text(this.palette.name)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
      }
      .width('100%')

      Row() {
        ForEach(this.palette.colors, (hex: string) => {
          Column()
            .layoutWeight(1)
            .height(44)
            .backgroundColor(hex)
        }, (hex: string) => hex)
      }
      .width('100%')
      .clip(true)
      .borderRadius(Theme.radius.sm)

      if (this.palette.note.length > 0) {
        Text(this.palette.note)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => { this.onTap() })
  }
}
