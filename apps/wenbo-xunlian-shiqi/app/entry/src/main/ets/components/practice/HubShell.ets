import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct HubShell {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop showBack: boolean = true
  @Prop padTab: boolean = false
  /** 父页增删改后递增，强制 @BuilderParam 内容重绘 */
  @Prop refreshToken: number = 0
  onClose: () => void = () => {}
  @BuilderParam body: () => void

  build() {
    Column() {
      Row({ space: Theme.space.s3 }) {
        if (this.showBack) {
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
        } else {
          Blank().width(8)
        }

        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)

        Blank().width(this.showBack ? 40 : 8)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.refreshToken >= 0) {
            this.body()
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: this.padTab ? Theme.space.s10 + 88 : Theme.space.s10
        })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.pageBg(this.themeEpoch))
  }
}
