import { Theme } from '../design-system/Theme'
import { WikiItem } from '../../models/NqModels'
import { NqMedia } from '../../services/NqMedia'

@Component
export struct WikiGridCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: WikiItem = new WikiItem()
  onTap: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(NqMedia.resource(this.item.coverKey))
          .width('100%')
          .height(100)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
        Column()
          .width('100%')
          .height(48)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,26,26,0)', 0], ['rgba(26,26,26,0.78)', 1]]
          })
          .borderRadius({ bottomLeft: Theme.radius.md, bottomRight: Theme.radius.md })
        Text(this.item.title)
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, bottom: 6 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(100)

      Text(this.item.category)
        .fontSize(Theme.type.overline)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s2)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
