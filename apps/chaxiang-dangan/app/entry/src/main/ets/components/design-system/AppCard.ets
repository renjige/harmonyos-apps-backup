import { Theme } from './Theme'

export type AppCardVariant = 'plain' | 'glass' | 'stat' | 'inverse' | 'outlined'

@Component
export struct AppCard {
  @Prop variant: AppCardVariant = 'plain'
  @Prop title: string = ''
  onTap: () => void = () => {}
  @BuilderParam content: () => void

  private bg(): string {
    const c = Theme.colors()
    if (this.variant === 'inverse') {
      return c.surfaceInverse
    }
    if (this.variant === 'glass') {
      return c.surfaceGlass
    }
    return c.surfaceCard
  }

  build() {
    Column() {
      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.variant === 'inverse' ? Theme.colors().textOnInverse : Theme.colors().textPrimary)
          .width('100%')
          .margin({ bottom: Theme.space.s3 })
      }
      this.content()
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.bg())
    .borderRadius(Theme.radius.md)
    .border({
      width: this.variant === 'outlined' ? 1 : 0,
      color: Theme.colors().strokeHairline
    })
    .shadow({
      radius: this.variant === 'stat' || this.variant === 'glass' ? 16 : 8,
      color: Theme.isDark() ? 'rgba(0,0,0,0.35)' : 'rgba(10,37,64,0.06)',
      offsetX: 0,
      offsetY: this.variant === 'stat' ? 4 : 1
    })
    .onClick(() => this.onTap())
  }
}
