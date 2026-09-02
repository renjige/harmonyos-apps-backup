import { Theme } from './Theme'

@Component
export struct GlassPanel {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop innerPadding: number = Theme.space.cardPadding
  @BuilderParam content: () => void

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .padding(this.innerPadding)
    .backgroundColor(Theme.isDark() ? Theme.colors().surfaceCard : Theme.colors().surfaceGlass)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeStrong })
    .backdropBlur(Theme.isDark() ? 20 : 12)
    .shadow({
      radius: 20,
      color: Theme.isDark() ? 'rgba(0,0,0,0.45)' : 'rgba(26,92,255,0.08)',
      offsetY: 8
    })
  }
}
