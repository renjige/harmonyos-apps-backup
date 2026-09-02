import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

@Component
export struct ZhukeQuickEntry {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop label: string = ''
  @Prop icon: AppIconName = 'biz'
  @Prop accent: boolean = false
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Column() {
        AppIcon({
          name: this.icon,
          iconSize: Theme.icon.lg,
          color: this.accent ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary
        })
      }
      .width(52)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.accent ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.lg)

      Text(this.label)
        .fontSize(Theme.type.footnote)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })
    .onClick(() => this.onTap())
  }
}
