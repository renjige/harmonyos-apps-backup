import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct DetailShell {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = '详情'
  onClose: () => void = () => {}
  @BuilderParam content: () => void

  build() {
    Column() {
      Row({ space: Theme.space.s1 }) {
        Row({ space: Theme.space.s1 }) {
          AppIcon({ name: 'back', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          Text('返回')
            .fontSize(Theme.type.callout)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        }
        .padding({ right: Theme.space.s3, top: Theme.space.s2, bottom: Theme.space.s2 })
        .onClick((): void => { this.onClose() })

        Text(this.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Blank().width(72)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX - 4,
        right: Theme.space.pageX,
        top: Theme.space.s2,
        bottom: Theme.space.s1
      })
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Divider()
        .color(Theme.colors().strokeHairline)
        .strokeWidth(1)

      Column() {
        this.content()
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
