import { Theme } from '../design-system/Theme'
import { FavoritesCenterPane } from './FavoritesCenterPane'

@Component
export struct FavoritesCenterSheet {
  onClose: () => void = () => {}
  onChanged: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text('收藏中心')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭')
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Scroll() {
        FavoritesCenterPane({ onChanged: (): void => { this.onChanged() } })
          .padding(Theme.space.pageX)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
