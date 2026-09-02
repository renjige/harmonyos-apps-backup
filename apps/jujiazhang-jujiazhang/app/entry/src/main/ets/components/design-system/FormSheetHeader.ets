import { Theme } from './Theme'
import { AppIcon } from './AppIcon'

@Component
export struct FormSheetHeader {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  onClose: () => void = () => {}

  build() {
    Row() {
      Text(this.title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
      Row({ space: 6 }) {
        AppIcon({ name: 'close', iconSize: 18, color: Theme.colors().textPrimary })
        Text('关闭')
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.button)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onClick(() => this.onClose())
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 18, bottom: 8 })
  }
}
