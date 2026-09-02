import { Theme } from '../design-system/Theme'
import { LineArtCatalog } from '../../services/LineArtCatalog'
import { PaletteColor } from '../../models/DrawModels'

@Component
export struct ColorPaletteBar {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop picked: string = '#FF8A65'
  onPick: (hex: string, zh: string, en: string) => void = () => {}

  build() {
    Scroll() {
      Row({ space: Theme.space.s2 }) {
        ForEach(LineArtCatalog.palette(), (c: PaletteColor) => {
          Stack() {
            Circle()
              .width(44)
              .height(44)
              .fill(c.hex)
              .stroke(this.picked === c.hex ? Theme.colors().brandPrimary : Theme.colors().strokeHairline)
              .strokeWidth(this.picked === c.hex ? 3 : 1)
          }
          .width(48)
          .height(48)
          .onClick(() => {
            this.onPick(c.hex, c.nameZh, c.nameEn)
          })
        })
      }
      .padding({ left: Theme.space.s4, right: Theme.space.s4 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .height(56)
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
