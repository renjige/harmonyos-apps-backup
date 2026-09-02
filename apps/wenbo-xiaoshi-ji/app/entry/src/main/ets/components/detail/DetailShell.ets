import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct DetailShell {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  onClose: () => void = () => {}
  @BuilderParam body: () => void

  build() {
    Column() {
      Row() {
        Row({ space: 4 }) {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          Text('返回')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
        .onClick((): void => this.onClose())
        .padding({ left: 4, right: 12, top: 8, bottom: 8 })

        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Row().width(64)
      }
      .width('100%')
      .padding({ left: Theme.space.s2, right: Theme.space.s4, top: Theme.space.s4, bottom: Theme.space.s2 })

      Column() {
        this.body()
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
