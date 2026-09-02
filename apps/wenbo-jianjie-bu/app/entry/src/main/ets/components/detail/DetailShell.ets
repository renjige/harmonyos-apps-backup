import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct DetailShell {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  onClose: () => void = () => {}

  build() {
    Row() {
      Row() {
        AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .onClick((): void => { this.onClose() })
      Text(this.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      Column().width(44)
    }
    .width('100%')
    .padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2, bottom: Theme.space.s2 })
  }
}
