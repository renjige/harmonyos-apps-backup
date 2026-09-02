import { Theme } from '../design-system/Theme'

@Component
export struct ZhukeKpiCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop value: string = ''
  @Prop hint: string = ''
  @Prop tone: string = 'neutral'
  @Prop wide: boolean = false
  onTap: () => void = () => {}

  private valueColor(): string {
    if (this.tone === 'success') {
      return Theme.colors().success
    }
    if (this.tone === 'warn') {
      return Theme.colors().warning
    }
    if (this.tone === 'danger') {
      return Theme.colors().danger
    }
    return Theme.colors().brandPrimary
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text(this.label)
        .fontSize(Theme.type.overline)
        .fontColor(Theme.colors().textTertiary)
        .width('100%')
      Text(this.value)
        .fontSize(this.wide ? 40 : 32)
        .fontWeight(FontWeight.Lighter)
        .fontColor(this.valueColor())
        .width('100%')
      if (this.hint.length > 0) {
        Text(this.hint)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
    }
    .width('100%')
    .height(this.wide ? 168 : 120)
    .padding(Theme.space.cardPadding)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow(Theme.cardShadow())
    .onClick(() => this.onTap())
  }
}
